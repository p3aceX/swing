import 'dart:convert';
import 'dart:math' show min, max;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart'
    show
        ArenaListing,
        ArenaReservation,
        ArenaUnitOption,
        BookingPricingEngine,
        NetVariant;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../booking/domain/booking_models.dart';
import '../data/arena_slots_repository.dart';
import '../domain/player_booking_types.dart';
import 'widgets/duration_picker.dart';
import 'widgets/slot_time_grid.dart';
import 'widgets/unit_group_card.dart' show BookingGroupCard;

const _kMerchantId = 'SU2507111540338505172019';
const _kAppSchema = 'swingplayer';
const _kPhonePeFlowId = 'SWINGPLAYER_FLOW';

Future<void> showPlayerBookingSheet(
  BuildContext context,
  ArenaListing arena,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PlayerBookingSheet(arena: arena),
  );
}

class PlayerBookingSheet extends ConsumerStatefulWidget {
  const PlayerBookingSheet({super.key, required this.arena});
  final ArenaListing arena;

  @override
  ConsumerState<PlayerBookingSheet> createState() => _PlayerBookingSheetState();
}

class _PlayerBookingSheetState extends ConsumerState<PlayerBookingSheet> {
  // ── Wizard state ─────────────────────────────────────────────────────────────
  int _step = 0;
  late final List<BookingGroup> _groups;
  BookingGroup? _selectedGroup;
  String? _selectedNetType;
  int _durationMins = 60;
  late DateTime _selectedDate;
  PlayerSlot? _selectedSlot;

  // ── Availability state ────────────────────────────────────────────────────────
  List<ArenaReservation> _allBookings = [];
  bool _loadingAvail = false;
  int _loadId = 0;

  bool _booking = false;
  bool _phonePeReady = false;

  static const _stepLabels = ['Facility', 'Schedule', 'Confirm'];

  bool get _isNets => _selectedGroup?.isNetGroup == true;

  bool get _canNext {
    if (_step == 0) {
      if (_selectedGroup == null) return false;
      if (_isNets && (_selectedGroup!.netTypes.length > 1) && _selectedNetType == null) return false;
      return true;
    }
    if (_step == 1) return _selectedSlot != null;
    return false;
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _groups = _buildGroups(widget.arena);
    _initPhonePe();
    _loadAvailability();
  }

  Future<void> _initPhonePe() async {
    final envs = kReleaseMode
        ? const <String>['PRODUCTION']
        : const <String>['PRODUCTION', 'SANDBOX'];
    Object? lastError;

    for (final env in envs) {
      try {
        debugPrint(
          '[PhonePe] init start env=$env merchantId=$_kMerchantId flowId=$_kPhonePeFlowId',
        );
        await PhonePePaymentSdk.init(env, _kMerchantId, _kPhonePeFlowId, false);
        if (!mounted) return;
        setState(() => _phonePeReady = true);
        debugPrint('[PhonePe] init success env=$env');
        return;
      } catch (e) {
        lastError = e;
        debugPrint('[PhonePe] init failed env=$env error=$e');
      }
    }

    if (!mounted) return;
    setState(() => _phonePeReady = false);
    _snack('PhonePe init failed: $lastError');
  }

  // ── Group building ────────────────────────────────────────────────────────────

  List<BookingGroup> _buildGroups(ArenaListing arena) {
    final netTypes = {'CRICKET_NET', 'INDOOR_NET'};
    final nets = arena.units.where((u) => netTypes.contains(u.unitType)).toList();
    final grounds = arena.units.where((u) => !netTypes.contains(u.unitType)).toList();

    final groups = <BookingGroup>[];

    if (nets.isNotEmpty) {
      final allTypes = nets
          .expand((u) => u.netVariants.isEmpty
              ? [u.netType ?? 'Standard']
              : u.netVariants.map((v) => v.type))
          .toSet()
          .toList();

      final allPrices = nets.expand((u) => u.netVariants.isEmpty
          ? [u.pricePerHourPaise]
          : u.netVariants.map((v) => v.pricePaise ?? u.pricePerHourPaise));
      final minPrice = allPrices.isEmpty ? 0 : allPrices.reduce(min);

      final totalNets = nets.fold<int>(0, (s, u) => s +
          (u.netVariants.isEmpty ? 1 : u.netVariants.fold<int>(0, (s2, v) => s2 + v.count)));

      groups.add(BookingGroup(
        key: 'NETS',
        displayName: 'Cricket Nets',
        unitType: nets.first.unitType,
        isNetGroup: true,
        units: nets,
        netTypes: allTypes,
        pricePerHourPaise: minPrice,
        minAdvancePaise: nets.map((u) => u.minAdvancePaise).reduce(min),
        minSlotMins: nets.map((u) => u.minSlotMins > 0 ? u.minSlotMins : 60).reduce(min),
        maxSlotMins: nets.map((u) => u.maxSlotMins).reduce(max),
        photoUrls: nets.expand((u) => u.photoUrls).toList(),
        hasFloodlights: nets.any((u) => u.hasFloodlights),
        totalCount: totalNets,
      ));
    }

    for (final unit in grounds) {
      groups.add(BookingGroup(
        key: unit.id,
        displayName: unit.unitTypeLabel ?? unit.name,
        unitType: unit.unitType,
        isNetGroup: false,
        units: [unit],
        netTypes: const [],
        pricePerHourPaise: unit.pricePerHourPaise,
        minAdvancePaise: unit.minAdvancePaise,
        minSlotMins: unit.minSlotMins > 0 ? unit.minSlotMins : 60,
        maxSlotMins: unit.maxSlotMins,
        photoUrls: unit.photoUrls,
        hasFloodlights: unit.hasFloodlights,
        totalCount: null,
      ));
    }

    return groups;
  }

  // ── Availability loading ──────────────────────────────────────────────────────

  Future<void> _loadAvailability() async {
    final id = ++_loadId;
    setState(() {
      _loadingAvail = true;
      _selectedSlot = null;
    });
    try {
      final repo = ref.read(arenaSlotsRepositoryProvider);
      final dateStr = _fmtDate(_selectedDate);
      final bookings = await repo.listArenaBusySlots(widget.arena.id, date: dateStr);
      if (!mounted || id != _loadId) return;
      setState(() {
        _allBookings = bookings;
        _loadingAvail = false;
      });
    } catch (_) {
      if (!mounted || id != _loadId) return;
      setState(() {
        _allBookings = [];
        _loadingAvail = false;
      });
    }
  }

  // ── Slot computation ──────────────────────────────────────────────────────────

  List<PlayerSlot> get _availableSlots {
    final group = _selectedGroup;
    if (group == null) return [];

    final firstUnit = group.units.first;
    final times = BookingPricingEngine.buildDaySlots(
      firstUnit,
      widget.arena.openTime,
      widget.arena.closeTime,
      _selectedDate,
      durationMins: _durationMins,
      bufferMins: widget.arena.bufferMins > 0 ? widget.arena.bufferMins : 30,
    );
    if (times.isEmpty) return [];

    final isWeekend = _selectedDate.weekday >= 6;
    final result = <PlayerSlot>[];

    for (final startTime in times) {
      final endTime = _addMins(startTime, _durationMins);

      if (group.isNetGroup) {
        final variantCounts = <String, int>{};
        for (final unit in group.units) {
          final variants = unit.netVariants.isEmpty
              ? [NetVariant(type: unit.netType ?? 'Standard', label: unit.netType ?? 'Standard', count: 1)]
              : unit.netVariants;

          for (final variant in variants) {
            final booked = _allBookings.where((b) =>
                b.unitId == unit.id &&
                b.status != 'CANCELLED' &&
                (b.netVariantType == null || b.netVariantType == variant.type) &&
                _overlaps(b.startTime, b.endTime, startTime, endTime)).length;
            final avail = (variant.count - booked).clamp(0, variant.count);
            if (avail > 0) {
              variantCounts[variant.type] = (variantCounts[variant.type] ?? 0) + avail;
            }
          }
        }

        if (variantCounts.isEmpty) continue;
        final total = variantCounts.values.fold(0, (s, c) => s + c);
        result.add(PlayerSlot(
          startTime: startTime,
          endTime: endTime,
          totalCount: total,
          variantCounts: variantCounts,
          isWeekendRate: isWeekend && group.units.any((u) => u.weekendMultiplier > 1.0),
        ));
      } else {
        final unit = group.units.first;
        final busy = BookingPricingEngine.isSlotBusy(
          startTime,
          _durationMins,
          bookings: _allBookings.where((b) => b.unitId == unit.id).toList(),
          timeBlocks: const [],
        );
        if (busy) continue;
        result.add(PlayerSlot(
          startTime: startTime,
          endTime: endTime,
          totalCount: 1,
          isWeekendRate: isWeekend && unit.weekendMultiplier > 1.0,
        ));
      }
    }
    return result;
  }

  // ── Pricing ───────────────────────────────────────────────────────────────────

  int get _effectivePaise {
    final group = _selectedGroup;
    if (group == null) return 0;
    final unit = _resolvedNetUnit() ?? group.units.first;
    final variantRate = BookingPricingEngine.variantPricePerHour(unit, _selectedNetType);
    return BookingPricingEngine.computeTotal(
      unit,
      durationMins: _durationMins,
      variantPricePaise: variantRate,
    );
  }

  int get _payNowPaise {
    final advance = _selectedGroup?.minAdvancePaise ?? 0;
    return advance > 0 ? advance : _effectivePaise;
  }

  // ── Unit resolution ───────────────────────────────────────────────────────────

  /// For net bookings: find the first unit+variant with remaining capacity.
  ArenaUnitOption? _resolvedNetUnit() {
    final group = _selectedGroup;
    final slot = _selectedSlot;
    if (group == null || slot == null || !group.isNetGroup) return null;

    for (final unit in group.units) {
      final variants = unit.netVariants.isEmpty
          ? [NetVariant(type: unit.netType ?? 'Standard', label: unit.netType ?? 'Standard', count: 1)]
          : unit.netVariants;

      for (final variant in variants) {
        if (_selectedNetType != null && variant.type != _selectedNetType) continue;
        final booked = _allBookings.where((b) =>
            b.unitId == unit.id &&
            b.status != 'CANCELLED' &&
            (b.netVariantType == null || b.netVariantType == variant.type) &&
            _overlaps(b.startTime, b.endTime, slot.startTime, slot.endTime)).length;
        if (booked < variant.count) return unit;
      }
    }
    return group.units.firstOrNull;
  }

  String? get _resolvedUnitId {
    final group = _selectedGroup;
    if (group == null) return null;
    if (!group.isNetGroup) return group.singleUnitId;
    return _resolvedNetUnit()?.id;
  }

  // ── Navigation ────────────────────────────────────────────────────────────────

  void _next() {
    if (!_canNext) return;
    if (_step == 0 && _isNets && (_selectedGroup!.netTypes.length == 1) && _selectedNetType == null) {
      setState(() => _selectedNetType = _selectedGroup!.netTypes.first);
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  // ── Payment ───────────────────────────────────────────────────────────────────

  Future<void> _pay() async {
    final slot = _selectedSlot;
    if (slot == null) return;
    if (!_phonePeReady) {
      _snack('PhonePe is not ready. Please reopen booking and try again.');
      return;
    }
    final unitId = _resolvedUnitId;
    if (unitId == null || unitId.isEmpty) {
      _snack('Could not assign a unit. Please try again.');
      return;
    }
    setState(() => _booking = true);
    debugPrint(
      '[PhonePe] pay start arena=${widget.arena.id} unit=$unitId '
      'date=${DateFormat('yyyy-MM-dd').format(_selectedDate)} '
      'slot=${slot.startTime}-${slot.endTime} payNow=$_payNowPaise total=$_effectivePaise',
    );
    final repo = ref.read(arenaSlotsRepositoryProvider);
    try {
      final hold = await repo.holdSlot(
        arenaId: widget.arena.id,
        unitId: unitId,
        date: _selectedDate,
        startTime: slot.startTime,
        endTime: slot.endTime,
      );
      debugPrint('[PhonePe] hold success holdId=${hold.holdId}');
      final order = await repo.createPaymentOrder(_payNowPaise);
      debugPrint(
        '[PhonePe] order created orderId=${order.orderId} '
        'tokenLen=${order.token.length} amount=${order.amountPaise}',
      );
      if (order.orderId.trim().isEmpty) {
        throw Exception('Missing PhonePe order ID.');
      }
      bool paymentCompleted = false;
      if (order.token.trim().isNotEmpty) {
        final payload = jsonEncode({
          'orderId': order.orderId,
          'merchantId': _kMerchantId,
          'token': order.token,
          'paymentMode': {'type': 'PAY_PAGE'},
        });
        debugPrint('[PhonePe] startTransaction payload=$payload');

        final response = await PhonePePaymentSdk.startTransaction(payload, _kAppSchema);
        if (!mounted) return;
        if (response == null) {
          setState(() => _booking = false);
          debugPrint('[PhonePe] startTransaction response=null');
          _snack('PhonePe did not return a payment response. Please try again.');
          return;
        }
        debugPrint('[PhonePe] startTransaction response=$response');

        final status = response['status']?.toString() ?? 'FAILURE';
        debugPrint('[PhonePe] transaction status=$status');
        if (status == 'SUCCESS') {
          paymentCompleted = true;
        } else if (status == 'INTERRUPTED') {
          setState(() => _booking = false);
          debugPrint('[PhonePe] transaction interrupted');
          _snack('Payment was cancelled.');
          return;
        } else {
          setState(() => _booking = false);
          final err = response['error']?.toString() ?? '';
          debugPrint('[PhonePe] transaction failed err=$err');
          _snack(err.isNotEmpty ? err : 'Payment failed. Please try again.');
          return;
        }
      } else {
        final redirect = order.redirectUrl;
        if (redirect == null || redirect.trim().isEmpty) {
          throw Exception(
              'PhonePe token and redirect URL both missing from server response.');
        }
        final uri = Uri.tryParse(redirect.trim());
        if (uri == null) {
          throw Exception('Invalid PhonePe redirect URL.');
        }
        debugPrint('[PhonePe] token missing, launching redirectUrl=$redirect');
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!mounted) return;
        if (!launched) {
          setState(() => _booking = false);
          _snack('Could not open PhonePe checkout. Please try again.');
          return;
        }
        _snack('Complete payment and return to app to confirm booking.');
        await Future<void>.delayed(const Duration(seconds: 2));
        paymentCompleted = true;
      }

      if (paymentCompleted) {
        final booking = await _createBookingWithPendingRetry(
          repo: repo,
          holdId: hold.holdId,
          unitId: unitId,
          date: _selectedDate,
          startTime: slot.startTime,
          endTime: slot.endTime,
          phonePeOrderId: order.orderId,
          advancePaise: _payNowPaise,
          totalAmountPaise: _effectivePaise,
        );
        debugPrint('[PhonePe] booking create success bookingId=${booking.id}');
        if (!mounted) return;
        Navigator.of(context).pop();
        context.go('/booking/success', extra: booking);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _booking = false);
      if (e is DioException) {
        debugPrint(
          '[PhonePe] dio error status=${e.response?.statusCode} '
          'path=${e.requestOptions.path} data=${e.response?.data}',
        );
      }
      debugPrint('[PhonePe] pay exception: $e');
      _snack(repo.messageFor(e, fallback: 'Could not complete booking.'));
    }
  }

  bool _isPaymentPendingError(Object error) {
    if (error is! DioException) return false;
    final data = error.response?.data;
    if (data is! Map) return false;
    final map = Map<String, dynamic>.from(data);
    final raw = map['error'];
    if (raw is Map) {
      final err = Map<String, dynamic>.from(raw);
      final code = '${err['code'] ?? ''}'.trim().toUpperCase();
      final msg = '${err['message'] ?? ''}'.toUpperCase();
      return code == 'PAYMENT_NOT_COMPLETED' || msg.contains('STATE: PENDING');
    }
    final msg = '${map['message'] ?? ''}'.toUpperCase();
    return msg.contains('PAYMENT_NOT_COMPLETED') || msg.contains('STATE: PENDING');
  }

  Future<PlayerBooking> _createBookingWithPendingRetry({
    required ArenaSlotsRepository repo,
    required String holdId,
    required String unitId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String phonePeOrderId,
    required int advancePaise,
    required int totalAmountPaise,
  }) async {
    const maxAttempts = 7;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await repo.createBooking(
          holdId: holdId,
          unitId: unitId,
          date: date,
          startTime: startTime,
          endTime: endTime,
          phonePeOrderId: phonePeOrderId,
          advancePaise: advancePaise,
          totalAmountPaise: totalAmountPaise,
        );
      } catch (e) {
        if (!_isPaymentPendingError(e) || attempt == maxAttempts) rethrow;
        final waitSeconds = attempt <= 2 ? 2 : 3;
        debugPrint(
          '[PhonePe] payment pending; retry booking confirm '
          'attempt=$attempt/$maxAttempts wait=${waitSeconds}s',
        );
        await Future<void>.delayed(Duration(seconds: waitSeconds));
      }
    }
    throw Exception('Payment confirmation timeout.');
  }

  void _onGroupTap(BookingGroup group) {
    if (_selectedGroup == group) {
      setState(() {
        _selectedGroup = null;
        _selectedSlot = null;
        _selectedNetType = null;
      });
      return;
    }
    int newDur = group.minSlotMins > 0 ? group.minSlotMins : 60;
    if (!group.isNetGroup && group.units.isNotEmpty) {
      final opts = BookingPricingEngine.durationOptions(group.units.first);
      if (opts.isNotEmpty) newDur = opts.first.durationMins;
    }
    setState(() {
      _selectedGroup = group;
      _selectedSlot = null;
      _durationMins = newDur;
      _selectedNetType = (group.isNetGroup && group.netTypes.length == 1)
          ? group.netTypes.first
          : null;
    });
    _loadAvailability();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.93,
      minChildSize: 0.6,
      maxChildSize: 0.97,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.stroke.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ArenaHeader(arena: widget.arena),
            const SizedBox(height: 4),
            _SheetStepBar(current: _step, labels: _stepLabels),
            Expanded(child: _buildStep(scrollCtrl)),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(ScrollController scrollCtrl) {
    return switch (_step) {
      0 => _FacilityStep(
          groups: _groups,
          loading: _loadingAvail && _selectedGroup == null,
          selectedGroup: _selectedGroup,
          selectedNetType: _selectedNetType,
          durationMins: _durationMins,
          scrollCtrl: scrollCtrl,
          onGroupTap: _onGroupTap,
          onNetTypeTap: (t) => setState(() {
            _selectedNetType = t;
            _selectedSlot = null;
          }),
          onDurationChanged: (d) => setState(() {
            _durationMins = d;
            _selectedSlot = null;
          }),
        ),
      1 => _ScheduleStep(
          slots: _availableSlots,
          loading: _loadingAvail,
          selectedDate: _selectedDate,
          selectedGroup: _selectedGroup!,
          selectedSlot: _selectedSlot,
          selectedNetType: _selectedNetType,
          durationMins: _durationMins,
          isNets: _isNets,
          advanceBookingDays: widget.arena.advanceBookingDays,
          scrollCtrl: scrollCtrl,
          onDateChanged: (d) {
            setState(() {
              _selectedDate = d;
              _selectedSlot = null;
            });
            _loadAvailability();
          },
          onSlotSelected: (s) => setState(() => _selectedSlot = s),
          onDurationChanged: (d) {
            setState(() {
              _durationMins = d;
              _selectedSlot = null;
            });
          },
        ),
      2 => _ConfirmStep(
          arena: widget.arena,
          group: _selectedGroup!,
          slot: _selectedSlot!,
          date: _selectedDate,
          durationMins: _durationMins,
          selectedNetType: _selectedNetType,
          effectivePaise: _effectivePaise,
          payNowPaise: _payNowPaise,
          booking: _booking,
          scrollCtrl: scrollCtrl,
          onPay: _pay,
        ),
      _ => const SizedBox(),
    };
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: context.bg,
          border: Border(top: BorderSide(color: context.stroke.withValues(alpha: 0.15))),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _back,
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.panel.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.arrow_back_rounded, color: context.fg, size: 22),
              ),
            ),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _step == i ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _step == i ? context.accent : context.panel,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
              ),
            ),
            if (_step < 2)
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _canNext ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: context.panel,
                    disabledForegroundColor: context.fgSub,
                    elevation: 0,
                    minimumSize: const Size(0, 48),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Next', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

// ── Arena header ──────────────────────────────────────────────────────────────

class _ArenaHeader extends StatelessWidget {
  const _ArenaHeader({required this.arena});
  final ArenaListing arena;

  @override
  Widget build(BuildContext context) {
    final imageUrl = arena.photoUrls.isNotEmpty ? arena.photoUrls.first : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 52,
              height: 52,
              child: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ColoredBox(color: context.panel))
                  : ColoredBox(
                      color: context.panel,
                      child: Icon(Icons.stadium_rounded, color: context.fgSub.withValues(alpha: 0.3), size: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(arena.name,
                    style: TextStyle(color: context.fg, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  arena.city.isNotEmpty ? arena.city : arena.address.split(',').first.trim(),
                  style: TextStyle(color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step bar ──────────────────────────────────────────────────────────────────

class _SheetStepBar extends StatelessWidget {
  const _SheetStepBar({required this.current, required this.labels});
  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Column(
        children: [
          Row(
            children: List.generate(labels.length, (i) {
              final filled = i <= current;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < labels.length - 1 ? 4 : 0),
                  height: 3,
                  decoration: BoxDecoration(
                    color: filled ? context.accent : context.panel,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(labels.length, (i) {
              final active = i == current;
              return Expanded(
                child: Text(
                  labels[i],
                  textAlign: i == 0 ? TextAlign.left : i == labels.length - 1 ? TextAlign.right : TextAlign.center,
                  style: TextStyle(
                    color: active ? context.fg : context.fgSub,
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Step 0: Facility ──────────────────────────────────────────────────────────

class _FacilityStep extends StatelessWidget {
  const _FacilityStep({
    required this.groups,
    required this.loading,
    required this.selectedGroup,
    required this.selectedNetType,
    required this.durationMins,
    required this.scrollCtrl,
    required this.onGroupTap,
    required this.onNetTypeTap,
    required this.onDurationChanged,
  });

  final List<BookingGroup> groups;
  final bool loading;
  final BookingGroup? selectedGroup;
  final String? selectedNetType;
  final int durationMins;
  final ScrollController scrollCtrl;
  final ValueChanged<BookingGroup> onGroupTap;
  final ValueChanged<String> onNetTypeTap;
  final ValueChanged<int> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    if (loading && groups.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (groups.isEmpty) {
      return Center(
        child: Text('No facilities available.', style: TextStyle(color: context.fgSub, fontSize: 13)),
      );
    }
    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      children: [
        _SectionLabel('Select facility'),
        const SizedBox(height: 8),
        for (final group in groups) ...[
          BookingGroupCard(
            group: group,
            // For grounds, always use the first valid option duration so the
            // card is never disabled by a mismatch with the global _durationMins.
            durationMins: group.isNetGroup ? durationMins : _groupDuration(group),
            selected: selectedGroup == group,
            onTap: () => onGroupTap(group),
            priceForDuration: _priceForDuration(group, _groupDuration(group)),
          ),
          if (selectedGroup == group) ...[
            if (group.isNetGroup && group.netTypes.length > 1) ...[
              const SizedBox(height: 14),
              _SectionLabel('Net type'),
              const SizedBox(height: 8),
              _NetTypePicker(group: group, selected: selectedNetType, onChanged: onNetTypeTap),
            ],
            if (group.isNetGroup && group.netTypes.length <= 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Text(
                  'Tap Next to pick your date and time slot.',
                  style: TextStyle(color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            if (!group.isNetGroup) ...[
              const SizedBox(height: 14),
              _SectionLabel('Duration'),
              const SizedBox(height: 8),
              _GroundDurationPicker(
                unit: group.units.first,
                selectedMins: durationMins,
                onChanged: onDurationChanged,
              ),
            ],
          ],
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  int _groupDuration(BookingGroup group) {
    if (group.isNetGroup || group.units.isEmpty) return durationMins;
    final opts = BookingPricingEngine.durationOptions(group.units.first);
    return opts.isNotEmpty ? opts.first.durationMins : (group.minSlotMins > 0 ? group.minSlotMins : 60);
  }

  int? _priceForDuration(BookingGroup group, int dur) {
    if (group.units.isEmpty) return null;
    final opts = BookingPricingEngine.durationOptions(group.units.first);
    if (opts.isEmpty) return null;
    return (opts.where((o) => o.durationMins == dur).firstOrNull ?? opts.first).pricePaise;
  }
}

// ── Step 1: Schedule ──────────────────────────────────────────────────────────

class _ScheduleStep extends StatelessWidget {
  const _ScheduleStep({
    required this.slots,
    required this.loading,
    required this.selectedDate,
    required this.selectedGroup,
    required this.selectedSlot,
    required this.selectedNetType,
    required this.durationMins,
    required this.isNets,
    required this.advanceBookingDays,
    required this.scrollCtrl,
    required this.onDateChanged,
    required this.onSlotSelected,
    required this.onDurationChanged,
  });

  final List<PlayerSlot> slots;
  final bool loading;
  final DateTime selectedDate;
  final BookingGroup selectedGroup;
  final PlayerSlot? selectedSlot;
  final String? selectedNetType;
  final int durationMins;
  final bool isNets;
  final int advanceBookingDays;
  final ScrollController scrollCtrl;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<PlayerSlot> onSlotSelected;
  final ValueChanged<int> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      children: [
        _SectionLabel('Date'),
        const SizedBox(height: 10),
        _DateStrip(
          selectedDate: selectedDate,
          maxDays: advanceBookingDays > 0 ? advanceBookingDays : 14,
          onChanged: onDateChanged,
        ),
        if (isNets) ...[
          const SizedBox(height: 20),
          _SectionLabel('Duration'),
          const SizedBox(height: 8),
          DurationPicker(
            selectedMins: durationMins,
            constraints: selectedGroup.units.map(DurationConstraints.fromUnit).toList(),
            onChanged: onDurationChanged,
          ),
        ],
        const SizedBox(height: 20),
        _SectionLabel('Start time'),
        const SizedBox(height: 12),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else
          PlayerSlotGrid(
            slots: slots,
            selectedSlot: selectedSlot,
            isNetGroup: selectedGroup.isNetGroup,
            selectedNetType: selectedNetType,
            onSelected: onSlotSelected,
          ),
      ],
    );
  }
}

// ── Step 2: Confirm & Pay ─────────────────────────────────────────────────────

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep({
    required this.arena,
    required this.group,
    required this.slot,
    required this.date,
    required this.durationMins,
    required this.selectedNetType,
    required this.effectivePaise,
    required this.payNowPaise,
    required this.booking,
    required this.scrollCtrl,
    required this.onPay,
  });

  final ArenaListing arena;
  final BookingGroup group;
  final PlayerSlot slot;
  final DateTime date;
  final int durationMins;
  final String? selectedNetType;
  final int effectivePaise;
  final int payNowPaise;
  final bool booking;
  final ScrollController scrollCtrl;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final remaining = (effectivePaise - payNowPaise).clamp(0, effectivePaise);
    final cancelUntil = DateTime(date.year, date.month, date.day, _h(slot.startTime), _m(slot.startTime))
        .subtract(Duration(hours: arena.cancellationHours > 0 ? arena.cancellationHours : 24));

    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.panel.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  DateFormat('EEE, d MMM').format(date),
                  if (selectedNetType != null) '$selectedNetType Net' else group.displayName,
                ].join(' · '),
                style: TextStyle(color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                '${slot.startTime} – ${slot.endTime}',
                style: TextStyle(color: context.fg, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const SizedBox(height: 2),
              Text(_dur(durationMins),
                  style: TextStyle(color: context.fgSub, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (slot.isWeekendRate) _ConfirmRow('Rate', 'Weekend rate', accent: context.warn),
        _ConfirmRow('Total', _inr(effectivePaise), strong: true),
        if (group.minAdvancePaise > 0) ...[
          _ConfirmRow('Pay now', _inr(payNowPaise), strong: true, accent: context.accent),
          _ConfirmRow('At venue', _inr(remaining)),
        ] else
          _ConfirmRow('Full payment', _inr(effectivePaise), strong: true),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: 13, color: context.fgSub.withValues(alpha: 0.55)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Cancel free before ${DateFormat('HH:mm, d MMM').format(cancelUntil)}',
                style: TextStyle(color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: booking ? null : onPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5F259F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: booking
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Pay ${_inr(payNowPaise)} with PhonePe',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

// ── Ground duration picker ────────────────────────────────────────────────────

class _GroundDurationPicker extends StatelessWidget {
  const _GroundDurationPicker({
    required this.unit,
    required this.selectedMins,
    required this.onChanged,
  });

  final ArenaUnitOption unit;
  final int selectedMins;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final opts = BookingPricingEngine.durationOptions(unit);
    if (opts.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: opts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final opt = opts[i];
          final selected = selectedMins == opt.durationMins;
          return GestureDetector(
            onTap: () => onChanged(opt.durationMins),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? context.accent : context.panel.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    opt.label,
                    style: TextStyle(
                      color: selected ? Colors.white : context.fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _inr(opt.pricePaise),
                    style: TextStyle(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.8)
                          : context.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Net type picker ───────────────────────────────────────────────────────────

class _NetTypePicker extends StatelessWidget {
  const _NetTypePicker({required this.group, required this.selected, required this.onChanged});
  final BookingGroup group;
  final String? selected;
  final ValueChanged<String> onChanged;

  int? _priceFor(String type) {
    for (final unit in group.units) {
      final variant = unit.netVariants.where((v) => v.type == type).firstOrNull;
      if (variant?.pricePaise != null) return variant!.pricePaise;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final type in group.netTypes)
          GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: selected == type
                    ? context.accent.withValues(alpha: 0.09)
                    : context.panel.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: selected == type
                    ? Border.all(color: context.accent.withValues(alpha: 0.4), width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('$type Net',
                        style: TextStyle(color: context.fg, fontSize: 14, fontWeight: FontWeight.w800)),
                  ),
                  if (_priceFor(type) != null)
                    Text(
                      '${_inr(_priceFor(type)!)}/hr',
                      style: TextStyle(
                        color: selected == type ? context.accent : context.fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Icon(
                    selected == type ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: selected == type ? context.accent : context.fgSub.withValues(alpha: 0.35),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Date strip ────────────────────────────────────────────────────────────────

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.selectedDate, required this.maxDays, required this.onChanged});
  final DateTime selectedDate;
  final int maxDays;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final count = maxDays.clamp(0, 60) + 1;
    return SizedBox(
      height: 66,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = DateTime(today.year, today.month, today.day + index);
          final sel = _sameDay(date, selectedDate);
          final label = switch (index) { 0 => 'Today', 1 => 'Tmrw', _ => DateFormat('EEE').format(date) };
          return GestureDetector(
            onTap: () => onChanged(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 76,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? context.accent : context.panel.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: sel ? Colors.white : context.fg, fontSize: 12, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(DateFormat('d MMM').format(date),
                      style: TextStyle(
                          color: sel ? Colors.white.withValues(alpha: 0.75) : context.fgSub,
                          fontSize: 10, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: context.fgSub, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.4),
      ),
    );
  }
}

// ── Confirm row ───────────────────────────────────────────────────────────────

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow(this.label, this.value, {this.strong = false, this.accent});
  final String label, value;
  final bool strong;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: context.fgSub, fontSize: 13, fontWeight: strong ? FontWeight.w800 : FontWeight.w600)),
          Text(value,
              style: TextStyle(
                  color: accent ?? context.fg,
                  fontSize: strong ? 15 : 13,
                  fontWeight: strong ? FontWeight.w900 : FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

String _inr(int paise) => '₹${(paise / 100).toStringAsFixed(0)}';

String _dur(int mins) {
  if (mins < 60) return '${mins}min';
  final h = mins ~/ 60;
  final m = mins % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _addMins(String time, int mins) {
  final parts = time.split(':').map(int.parse).toList();
  final total = parts[0] * 60 + parts[1] + mins;
  final h = (total ~/ 60).clamp(0, 23);
  final m = total % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

bool _overlaps(String s1, String e1, String s2, String e2) {
  final s1m = _toMins(s1), e1m = _toMins(e1);
  final s2m = _toMins(s2), e2m = _toMins(e2);
  return s1m < e2m && e1m > s2m;
}

int _toMins(String t) {
  final parts = t.split(':');
  if (parts.length < 2) return 0;
  return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
}

int _h(String t) => int.tryParse(t.split(':').first) ?? 0;
int _m(String t) {
  final p = t.split(':');
  return p.length < 2 ? 0 : (int.tryParse(p[1]) ?? 0);
}
