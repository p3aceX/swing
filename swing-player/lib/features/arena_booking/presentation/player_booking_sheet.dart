import 'dart:convert';
import 'dart:math' show min, max;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart'
    show
        ArenaAddon,
        ArenaListing,
        ArenaUnitOption,
        BookingPricingEngine,
        hostArenaBookingRepositoryProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../booking/domain/booking_models.dart';
import '../data/arena_slots_repository.dart';
import '../domain/arena_slots_models.dart';
import '../domain/player_booking_types.dart';
import 'widgets/duration_picker.dart';
import 'widgets/slot_time_grid.dart';

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
  ArenaSlots? _arenaSlots;
  bool _loadingAvail = false;
  int _loadId = 0;

  // ── Calendar state ────────────────────────────────────────────────────────────
  final Map<String, int?> _dateFillLevel = {};
  int _calendarLoadId = 0;
  late DateTime _displayedMonth;

  // ── Addons state ─────────────────────────────────────────────────────────────
  List<ArenaAddon> _addons = [];
  final Set<ArenaAddon> _selectedAddons = {};

  bool _booking = false;
  bool _phonePeReady = false;

  static const _stepLabels = ['Facility', 'Schedule', 'Confirm'];

  bool get _isNets => _selectedGroup?.isNetGroup == true;

  bool get _canNext {
    if (_step == 0) {
      if (_selectedGroup == null) return false;
      if (_isNets && (_selectedGroup!.netTypes.length > 1) && _selectedNetType == null) return false;
      if (!_isNets && _durationMins <= 0) return false;
      return true;
    }
    if (_step == 1) return _selectedSlot != null;
    return false;
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _groups = _buildGroups(widget.arena);
    _initPhonePe();
    _loadAvailability();
    _loadAddons();
    _loadUnitGroupMeta();
  }

  Future<void> _loadAddons() async {
    try {
      final addons = await ref
          .read(hostArenaBookingRepositoryProvider)
          .fetchArenaAddons(widget.arena.id);
      if (!mounted) return;
      setState(() => _addons = addons);
    } catch (_) {}
  }

  // Loads booking context with a minimal duration just to get unit group metadata
  // (package flags, rates) before the user selects a group/duration.
  Future<void> _loadUnitGroupMeta() async {
    try {
      final repo = ref.read(arenaSlotsRepositoryProvider);
      final slots = await repo.getArenaSlots(widget.arena.id, _selectedDate, 60);
      if (!mounted) return;
      // Only set if no real availability load has happened yet
      if (_arenaSlots == null) setState(() => _arenaSlots = slots);
    } catch (_) {}
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
    if (_durationMins <= 0 || _selectedGroup == null) return;
    final id = ++_loadId;
    setState(() {
      _loadingAvail = true;
      _selectedSlot = null;
    });
    try {
      final repo = ref.read(arenaSlotsRepositoryProvider);
      final slots = await repo.getArenaSlots(widget.arena.id, _selectedDate, _durationMins);
      if (!mounted || id != _loadId) return;
      setState(() {
        _arenaSlots = slots;
        _loadingAvail = false;
      });
    } catch (_) {
      if (!mounted || id != _loadId) return;
      setState(() {
        _arenaSlots = null;
        _loadingAvail = false;
      });
    }
  }

  // ── Calendar availability ─────────────────────────────────────────────────────

  void _loadCalendarAvailability() {
    final group = _selectedGroup;
    if (group == null) return;
    final loadId = ++_calendarLoadId;
    setState(() => _dateFillLevel.clear());
    final today = DateTime.now();
    final maxDays = widget.arena.advanceBookingDays > 0 ? widget.arena.advanceBookingDays : 30;
    final repo = ref.read(arenaSlotsRepositoryProvider);
    for (var i = 0; i <= maxDays; i++) {
      final date = DateTime(today.year, today.month, today.day + i);
      final dateStr = _dateKey(date);
      repo.getArenaSlots(widget.arena.id, date, _durationMins).then((slots) {
        if (!mounted || loadId != _calendarLoadId) return;
        final unitGroup = slots.unitGroups
            .where((g) => g.groupKey == group.key).firstOrNull;
        final count = unitGroup?.availableSlots.length ?? 0;
        setState(() => _dateFillLevel[dateStr] = count == 0 ? 2 : (count <= 2 ? 1 : 0));
      }).catchError((_) {
        if (!mounted || loadId != _calendarLoadId) return;
        setState(() => _dateFillLevel[dateStr] = 2);
      });
    }
  }

  // ── Slot computation ──────────────────────────────────────────────────────────

  List<PlayerSlot> get _availableSlots {
    final group = _selectedGroup;
    if (group == null || _arenaSlots == null) return [];

    final unitGroup = _arenaSlots!.unitGroups
        .where((g) => g.groupKey == group.key)
        .firstOrNull;
    if (unitGroup == null) return [];

    return unitGroup.availableSlots.map((s) {
      final variantCounts = <String, int>{
        for (final opt in s.netTypeOptions) opt.netType: opt.availableCount,
      };
      final total = s.availableCount ??
          (variantCounts.isEmpty ? 1 : variantCounts.values.fold<int>(0, (a, b) => a + b));
      return PlayerSlot(
        startTime: s.startTime,
        endTime: s.endTime,
        totalCount: total,
        variantCounts: variantCounts,
        isWeekendRate: s.isWeekendRate,
      );
    }).toList();
  }

  // ── Pricing ───────────────────────────────────────────────────────────────────

  int get _effectivePaise {
    final group = _selectedGroup;
    if (group == null) return 0;
    final addonsTotal = _selectedAddons.fold<int>(0, (s, a) => s + a.pricePaise);

    final slot = _selectedSlot;
    if (slot != null && _arenaSlots != null) {
      final unitGroup = _arenaSlots!.unitGroups
          .where((g) => g.groupKey == group.key).firstOrNull;
      final apiSlot = unitGroup?.availableSlots
          .where((s) => s.startTime == slot.startTime).firstOrNull;
      if (apiSlot != null) {
        if (group.isNetGroup && _selectedNetType != null) {
          final netOpt = apiSlot.netTypeOptions
              .where((o) => o.netType == _selectedNetType).firstOrNull;
          if (netOpt != null) return netOpt.totalAmountPaise + addonsTotal;
        }
        return apiSlot.totalAmountPaise + addonsTotal;
      }
    }

    // Fallback to local pricing engine when API data unavailable
    final unit = group.units.first;
    final variantRate = BookingPricingEngine.variantPricePerHour(unit, _selectedNetType);
    final base = BookingPricingEngine.computeTotal(
      unit, durationMins: _durationMins, variantPricePaise: variantRate,
    );
    return base + addonsTotal;
  }

  int get _payNowPaise {
    final advance = _selectedGroup?.minAdvancePaise ?? 0;
    return advance > 0 ? advance : _effectivePaise;
  }

  // ── Unit resolution ───────────────────────────────────────────────────────────

  String? get _resolvedUnitId {
    final group = _selectedGroup;
    if (group == null) return null;

    if (!group.isNetGroup) {
      final unitGroup = _arenaSlots?.unitGroups
          .where((g) => g.groupKey == group.key).firstOrNull;
      return unitGroup?.unitId ?? group.singleUnitId;
    }

    // For nets: use assignedUnitId from the selected slot's netTypeOptions
    final slot = _selectedSlot;
    if (slot != null && _arenaSlots != null) {
      final unitGroup = _arenaSlots!.unitGroups
          .where((g) => g.groupKey == group.key).firstOrNull;
      final apiSlot = unitGroup?.availableSlots
          .where((s) => s.startTime == slot.startTime).firstOrNull;
      if (apiSlot != null) {
        if (_selectedNetType != null) {
          final netOpt = apiSlot.netTypeOptions
              .where((o) => o.netType == _selectedNetType).firstOrNull;
          if (netOpt != null && netOpt.assignedUnitId.isNotEmpty) {
            return netOpt.assignedUnitId;
          }
        }
        if (apiSlot.assignedUnitId?.isNotEmpty == true) return apiSlot.assignedUnitId;
      }
    }

    return group.units.firstOrNull?.id;
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
    // Nets default to minSlot; grounds require explicit duration selection
    final int newDur = group.isNetGroup
        ? (group.minSlotMins > 0 ? group.minSlotMins : 60)
        : 0;
    setState(() {
      _selectedGroup = group;
      _selectedSlot = null;
      _durationMins = newDur;
      _selectedNetType = (group.isNetGroup && group.netTypes.length == 1)
          ? group.netTypes.first
          : null;
    });
    _loadAvailability();
    _loadCalendarAvailability();
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
    final netGroups = _groups.where((g) => g.isNetGroup).toList();
    final groundGroups = _groups.where((g) => !g.isNetGroup).toList();

    return switch (_step) {
      0 => _FacilityStep(
          netGroups: netGroups,
          groundGroups: groundGroups,
          loading: _loadingAvail && _selectedGroup == null,
          selectedGroup: _selectedGroup,
          selectedNetType: _selectedNetType,
          durationMins: _durationMins,
          scrollCtrl: scrollCtrl,
          arenaPhone: widget.arena.phone,
          apiUnitGroups: _arenaSlots?.unitGroups ?? const [],
          onGroupTap: _onGroupTap,
          onNetTypeTap: (t) => setState(() {
            _selectedNetType = t;
            _selectedSlot = null;
          }),
          onDurationChanged: (d) {
            setState(() {
              _durationMins = d;
              _selectedSlot = null;
            });
            _loadAvailability();
          },
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
          fillLevels: _dateFillLevel,
          displayedMonth: _displayedMonth,
          onMonthChanged: (m) => setState(() => _displayedMonth = m),
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
            _loadAvailability();
            _loadCalendarAvailability();
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
          addons: _addons,
          selectedAddons: _selectedAddons,
          onAddonToggle: (a) => setState(() {
            if (_selectedAddons.contains(a)) {
              _selectedAddons.remove(a);
            } else {
              _selectedAddons.add(a);
            }
          }),
          onPay: _pay,
        ),
      _ => const SizedBox(),
    };
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: context.bg,
          border: Border(
              top: BorderSide(color: context.stroke.withValues(alpha: 0.1))),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _back,
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.panel.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child:
                    Icon(Icons.arrow_back_rounded, color: context.fg, size: 20),
              ),
            ),
            if (_step < 2) ...[
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canNext ? _next : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.fg,
                      foregroundColor:
                          context.isDark ? Colors.black : Colors.white,
                      disabledBackgroundColor: context.panel,
                      disabledForegroundColor: context.fgSub,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text(
                      'NEXT',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.0),
                    ),
                  ),
                ),
              ),
            ],
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
    required this.netGroups,
    required this.groundGroups,
    required this.loading,
    required this.selectedGroup,
    required this.selectedNetType,
    required this.durationMins,
    required this.scrollCtrl,
    required this.arenaPhone,
    required this.apiUnitGroups,
    required this.onGroupTap,
    required this.onNetTypeTap,
    required this.onDurationChanged,
  });

  final List<BookingGroup> netGroups;
  final List<BookingGroup> groundGroups;
  final bool loading;
  final BookingGroup? selectedGroup;
  final String? selectedNetType;
  final int durationMins;
  final ScrollController scrollCtrl;
  final String? arenaPhone;
  final List<UnitGroupSlots> apiUnitGroups;
  final ValueChanged<BookingGroup> onGroupTap;
  final ValueChanged<String> onNetTypeTap;
  final ValueChanged<int> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    if (loading && netGroups.isEmpty && groundGroups.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.only(top: 12, bottom: 32),
      children: [
        if (netGroups.isNotEmpty) ...[
          _SectionLabel('CRICKET NETS'),
          const SizedBox(height: 12),
          for (final group in netGroups) ...[
            _FacilityItem(
              group: group,
              selected: selectedGroup == group,
              onTap: () => onGroupTap(group),
              durationMins: durationMins,
              selectedNetType: selectedNetType,
              onNetTypeTap: onNetTypeTap,
            ),
            const SizedBox(height: 12),
          ],
          _NetsPackageSection(
            apiUnitGroups: apiUnitGroups,
            phone: arenaPhone,
          ),
        ],
        if (groundGroups.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionLabel('GROUNDS & COURTS'),
          const SizedBox(height: 12),
          for (final group in groundGroups) ...[
            _FacilityItem(
              group: group,
              selected: selectedGroup == group,
              onTap: () => onGroupTap(group),
              durationMins: durationMins,
              onDurationChanged: onDurationChanged,
            ),
            const SizedBox(height: 12),
          ],
          _GroundsPackageSection(
            groundGroups: groundGroups,
            apiUnitGroups: apiUnitGroups,
            phone: arenaPhone,
          ),
        ],
      ],
    );
  }
}

class _FacilityItem extends StatelessWidget {
  const _FacilityItem({
    required this.group,
    required this.selected,
    required this.onTap,
    required this.durationMins,
    this.selectedNetType,
    this.onNetTypeTap,
    this.onDurationChanged,
  });

  final BookingGroup group;
  final bool selected;
  final VoidCallback onTap;
  final int durationMins;
  final String? selectedNetType;
  final ValueChanged<String>? onNetTypeTap;
  final ValueChanged<int>? onDurationChanged;

  @override
  Widget build(BuildContext context) {
    final imageUrl = group.photoUrls.isNotEmpty ? group.photoUrls.first : null;
    final isDark = context.isDark;

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected 
                ? (isDark ? const Color(0xFF151515) : Colors.white)
                : (isDark ? const Color(0xFF0D0D0D) : Colors.white),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected ? context.accent : context.stroke.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                if (imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.displayName.toUpperCase(),
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatUnitType(group.unitType).toUpperCase(),
                        style: TextStyle(
                          color: context.fgSub.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        group.isNetGroup
                            ? _netPriceRange(group.units).toUpperCase()
                            : _groundPriceLabel(group.units.first).toUpperCase(),
                        style: TextStyle(
                          color: context.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded,
                  color: selected ? context.accent : context.fgSub.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
        if (selected) ...[
          const SizedBox(height: 12),
          if (group.isNetGroup && group.netTypes.length > 1)
            _NetTypePicker(group: group, selected: selectedNetType, onChanged: onNetTypeTap!),
          if (!group.isNetGroup && onDurationChanged != null)
            _GroundDurationPicker(
              unit: group.units.first,
              selectedMins: durationMins,
              onChanged: onDurationChanged!,
            ),
        ],
      ],
    );
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
    required this.fillLevels,
    required this.displayedMonth,
    required this.onMonthChanged,
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
  final Map<String, int?> fillLevels;
  final DateTime displayedMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<PlayerSlot> onSlotSelected;
  final ValueChanged<int> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final maxDays = advanceBookingDays > 0 ? advanceBookingDays : 30;
    final maxDate = DateTime(today.year, today.month, today.day + maxDays);
    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      children: [
        _SectionLabel('Select Date'),
        const SizedBox(height: 12),
        _AvailabilityCalendar(
          selectedDate: selectedDate,
          displayedMonth: displayedMonth,
          maxDate: maxDate,
          fillLevels: fillLevels,
          onDateChanged: onDateChanged,
          onMonthChanged: onMonthChanged,
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
        const SizedBox(height: 28),
        _SectionLabel('Start time'),
        const SizedBox(height: 14),
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
    required this.addons,
    required this.selectedAddons,
    required this.onAddonToggle,
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
  final List<ArenaAddon> addons;
  final Set<ArenaAddon> selectedAddons;
  final ValueChanged<ArenaAddon> onAddonToggle;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final remaining = (effectivePaise - payNowPaise).clamp(0, effectivePaise);
    final cancelUntil = DateTime(date.year, date.month, date.day, _h(slot.startTime), _m(slot.startTime))
        .subtract(Duration(hours: arena.cancellationHours > 0 ? arena.cancellationHours : 24));

    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // ── Selection Summary ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.isDark ? const Color(0xFF0D0D0D) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.stroke.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  DateFormat('EEE, d MMM').format(date).toUpperCase(),
                  if (selectedNetType != null) '$selectedNetType NET' else group.displayName.toUpperCase(),
                ].join(' · '),
                style: TextStyle(
                  color: context.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${slot.startTime} – ${slot.endTime}',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(_dur(durationMins).toUpperCase(),
                  style: TextStyle(
                    color: context.fgSub.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  )),
            ],
          ),
        ),

        // ── Addons Section ───────────────────────────────────────────────────
        if (addons.isNotEmpty) ...[
          const SizedBox(height: 32),
          _SectionLabel('Addons'),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: addons.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final addon = addons[i];
                final sel = selectedAddons.contains(addon);
                return GestureDetector(
                  onTap: () => onAddonToggle(addon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 130,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sel ? context.accent.withValues(alpha: 0.08) : context.panel.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sel ? context.accent : context.stroke.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          addon.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _inr(addon.pricePaise),
                          style: TextStyle(
                            color: sel ? context.accent : context.fgSub,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 32),
        _SectionLabel('Summary'),
        const SizedBox(height: 12),
        if (slot.isWeekendRate) _ConfirmRow('Rate', 'Weekend rate', accent: context.warn),
        _ConfirmRow('Subtotal', _inr(effectivePaise - selectedAddons.fold<int>(0, (s, a) => s + a.pricePaise))),
        if (selectedAddons.isNotEmpty)
          _ConfirmRow('Addons', _inr(selectedAddons.fold<int>(0, (s, a) => s + a.pricePaise))),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Divider(height: 1, thickness: 0.5),
        ),
        _ConfirmRow('Total', _inr(effectivePaise), strong: true),
        
        if (group.minAdvancePaise > 0) ...[
          const SizedBox(height: 8),
          _ConfirmRow('Pay now', _inr(payNowPaise), strong: true, accent: context.accent),
          _ConfirmRow('At venue', _inr(remaining)),
        ] else
          _ConfirmRow('Full payment', _inr(effectivePaise), strong: true),
        
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.panel.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: context.fgSub.withValues(alpha: 0.6)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cancel free before ${DateFormat('HH:mm, d MMM').format(cancelUntil)}',
                  style: TextStyle(
                    color: context.fgSub.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 62,
          child: ElevatedButton(
            onPressed: booking ? null : onPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5F259F), // PhonePe Purple
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: booking
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : Text('PAY ${_inr(payNowPaise).toUpperCase()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.5)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: opts.map((opt) {
          // selectedMins == 0 means nothing chosen yet — show all as unselected
          final selected = selectedMins > 0 && selectedMins == opt.durationMins;
          return GestureDetector(
            onTap: () => onChanged(opt.durationMins),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: selected ? context.accent : context.panel.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    opt.label,
                    style: TextStyle(
                      color: selected ? Colors.white : context.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _inr(opt.pricePaise),
                    style: TextStyle(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.8)
                          : context.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final type in group.netTypes)
            GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                decoration: BoxDecoration(
                  color: selected == type
                      ? context.accent
                      : context.panel.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$type Net'.toUpperCase(),
                      style: TextStyle(
                        color: selected == type ? Colors.white : context.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (_priceFor(type) != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_inr(_priceFor(type)!)}/hr',
                        style: TextStyle(
                          color: selected == type
                              ? Colors.white.withValues(alpha: 0.75)
                              : context.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Package sections ──────────────────────────────────────────────────────────

class _NetsPackageSection extends StatelessWidget {
  const _NetsPackageSection({required this.apiUnitGroups, this.phone});

  final List<UnitGroupSlots> apiUnitGroups;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final netsSlots = apiUnitGroups.where((g) => g.isNetGroup).toList();
    final ratePaise = netsSlots
        .where((g) => g.monthlyPassRatePaise != null)
        .map((g) => g.monthlyPassRatePaise!)
        .fold<int?>(null, (best, v) => best == null ? v : (v < best ? v : best));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('PACKAGES'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _PackageCard(
            icon: Icons.workspace_premium_rounded,
            title: 'Monthly Pass',
            description: 'Unlimited net sessions for a full month',
            ratePaise: ratePaise,
            rateLabel: '/month',
            phone: phone,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _GroundsPackageSection extends StatelessWidget {
  const _GroundsPackageSection({
    required this.groundGroups,
    required this.apiUnitGroups,
    this.phone,
  });

  final List<BookingGroup> groundGroups;
  final List<UnitGroupSlots> apiUnitGroups;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final groundKeys = groundGroups.map((g) => g.key).toSet();
    final groundSlots = apiUnitGroups.where((g) => groundKeys.contains(g.groupKey)).toList();
    final minDays = groundSlots
        .where((g) => g.minBulkDays != null)
        .map((g) => g.minBulkDays!)
        .fold<int?>(null, (best, v) => best == null ? v : (v < best ? v : best));
    final ratePaise = groundSlots
        .where((g) => g.bulkDayRatePaise != null)
        .map((g) => g.bulkDayRatePaise!)
        .fold<int?>(null, (best, v) => best == null ? v : (v < best ? v : best));
    final description = minDays != null
        ? 'Book $minDays+ days at discounted rates'
        : 'Book multiple days at discounted rates';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('PACKAGES'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _PackageCard(
            icon: Icons.calendar_month_rounded,
            title: 'Bulk Booking',
            description: description,
            ratePaise: ratePaise,
            rateLabel: '/day',
            phone: phone,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ── Package card (Bulk / Monthly) ─────────────────────────────────────────────

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.icon,
    required this.title,
    required this.description,
    this.ratePaise,
    this.rateLabel,
    this.phone,
  });

  final IconData icon;
  final String title;
  final String description;
  final int? ratePaise;
  final String? rateLabel; // e.g. '/month' or '/day'
  final String? phone;

  bool get _hasPricing => ratePaise != null && ratePaise! > 0;

  void _contact(BuildContext context) async {
    final p = phone;
    if (p == null || p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact the arena to enquire.')),
      );
      return;
    }
    final digits = p.replaceAll(RegExp(r'\D'), '');
    final wa = Uri.parse('https://wa.me/91$digits?text=${Uri.encodeComponent('Hi, I\'d like to know more about ${title.replaceAll('\n', ' ')}.')}');
    if (await canLaunchUrl(wa)) {
      await launchUrl(wa, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(Uri.parse('tel:$digits'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final priceText = _hasPricing
        ? '₹${(ratePaise! / 100).toStringAsFixed(0)}${rateLabel ?? ''}'
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.stroke.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: context.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: context.fgSub.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                if (priceText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    priceText,
                    style: TextStyle(
                      color: context.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!_hasPricing)
            GestureDetector(
              onTap: () => _contact(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: context.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ENQUIRE',
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Availability calendar ─────────────────────────────────────────────────────

class _AvailabilityCalendar extends StatelessWidget {
  const _AvailabilityCalendar({
    required this.selectedDate,
    required this.displayedMonth,
    required this.maxDate,
    required this.fillLevels,
    required this.onDateChanged,
    required this.onMonthChanged,
  });

  final DateTime selectedDate;
  final DateTime displayedMonth;
  final DateTime maxDate;
  final Map<String, int?> fillLevels;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime> onMonthChanged;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final firstOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final startOffset = (firstOfMonth.weekday - 1) % 7;
    final daysInMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    final canGoPrev = displayedMonth.isAfter(DateTime(today.year, today.month));
    final canGoNext = DateTime(displayedMonth.year, displayedMonth.month + 1)
        .isBefore(DateTime(maxDate.year, maxDate.month + 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: nav + month + year ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _NavBtn(
                icon: Icons.chevron_left_rounded,
                enabled: canGoPrev,
                onTap: canGoPrev ? () => onMonthChanged(
                    DateTime(displayedMonth.year, displayedMonth.month - 1)) : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy').format(displayedMonth),
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              _NavBtn(
                icon: Icons.chevron_right_rounded,
                enabled: canGoNext,
                onTap: canGoNext ? () => onMonthChanged(
                    DateTime(displayedMonth.year, displayedMonth.month + 1)) : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // ── Weekday labels ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: _days.map((d) => Expanded(
              child: Center(
                child: Text(
                  d.substring(0, 1),
                  style: TextStyle(
                    color: context.fgSub.withValues(alpha: 0.3),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 8),
        // ── Date grid ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.72,
              mainAxisSpacing: 2,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (_, i) {
              if (i < startOffset) return const SizedBox();
              final day = i - startOffset + 1;
              final date = DateTime(displayedMonth.year, displayedMonth.month, day);
              final isPast = date.isBefore(todayDate);
              final isBeyond = date.isAfter(maxDate);
              final disabled = isPast || isBeyond;
              return _DateCell(
                day: day,
                isSelected: _sameDay(date, selectedDate),
                isToday: _sameDay(date, todayDate),
                isDisabled: disabled,
                fillLevel: disabled ? null : fillLevels[_dateKey(date)],
                onTap: disabled ? null : () => onDateChanged(date),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // ── Legend ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _CalLegend(color: const Color(0xFF4ADE80), label: 'Open'),
              const SizedBox(width: 20),
              _CalLegend(color: const Color(0xFFFBBF24), label: 'Few left'),
              const SizedBox(width: 20),
              _CalLegend(color: const Color(0xFFF87171), label: 'Full'),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.enabled, this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? context.panel.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? context.fg
              : context.fgSub.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}

class _CalLegend extends StatelessWidget {
  const _CalLegend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: context.fgSub.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// fillLevel: null=disabled/unknown, 0=open, 1=few left, 2=full
class _DateCell extends StatelessWidget {
  const _DateCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.fillLevel,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;
  final int? fillLevel;
  final VoidCallback? onTap;

  static const _green = Color(0xFF4ADE80);
  static const _amber = Color(0xFFFBBF24);
  static const _red   = Color(0xFFF87171);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    Color? dotColor;
    if (!isDisabled && !isSelected) {
      if (fillLevel == 0) dotColor = _green;
      else if (fillLevel == 1) dotColor = _amber;
      else if (fillLevel == 2) dotColor = _red;
    }

    final numColor = isDisabled
        ? context.fgSub.withValues(alpha: 0.2)
        : isSelected
            ? (isDark ? Colors.black : Colors.white)
            : fillLevel == 2
                ? context.fgSub.withValues(alpha: 0.5)
                : context.fg;

    final circleBg = isSelected
        ? context.accent
        : (isToday && !isSelected)
            ? context.accent.withValues(alpha: 0.12)
            : Colors.transparent;

    final circleBorder = isToday && !isSelected
        ? Border.all(color: context.accent.withValues(alpha: 0.5), width: 1.5)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: circleBg,
              shape: BoxShape.circle,
              border: circleBorder,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: numColor,
                  fontSize: 14,
                  fontWeight: (isSelected || isToday)
                      ? FontWeight.w900
                      : FontWeight.w500,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: dotColor ?? Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
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

String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';


String _inr(int paise) => '₹${(paise / 100).toStringAsFixed(0)}';

String _dur(int mins) {
  if (mins < 60) return '${mins}min';
  final h = mins ~/ 60;
  final m = mins % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}




int _h(String t) => int.tryParse(t.split(':').first) ?? 0;
int _m(String t) {
  final p = t.split(':');
  return p.length < 2 ? 0 : (int.tryParse(p[1]) ?? 0);
}

String _formatUnitType(String raw) {
  final t = raw.trim().toUpperCase();
  if (t.contains('TURF')) return 'Turf';
  if (t.contains('GROUND')) return 'Ground';
  if (t.contains('NET')) return 'Nets';
  if (t.contains('INDOOR')) return 'Indoor';
  if (t.contains('CENTER') || t.contains('CENTRE')) return 'Center wicket';
  return raw.isEmpty ? 'Unit' : raw;
}

String _groundPriceLabel(ArenaUnitOption unit) {
  if (unit.price4HrPaise != null && unit.price4HrPaise! > 0) {
    return '₹${(unit.price4HrPaise! / 100).toStringAsFixed(0)} / 4 hr match';
  }
  if (unit.price8HrPaise != null && unit.price8HrPaise! > 0) {
    return '₹${(unit.price8HrPaise! / 100).toStringAsFixed(0)} / 8 hr match';
  }
  if (unit.priceFullDayPaise != null && unit.priceFullDayPaise! > 0) {
    return '₹${(unit.priceFullDayPaise! / 100).toStringAsFixed(0)} / full day';
  }
  if (unit.pricePerHourPaise > 0) {
    final minSlot = unit.minSlotMins > 0 ? unit.minSlotMins : 240;
    final matchPrice = ((unit.pricePerHourPaise * minSlot) / 60).round();
    final hrs = minSlot ~/ 60;
    return '₹${(matchPrice / 100).toStringAsFixed(0)} / ${hrs}hr match';
  }
  return '';
}

String _netPriceRange(List<ArenaUnitOption> units) {
  final prices = <int>[];
  for (final u in units) {
    if (u.netVariants.isEmpty) {
      if (u.pricePerHourPaise > 0) prices.add(u.pricePerHourPaise);
    } else {
      for (final v in u.netVariants) {
        final p = v.pricePaise ?? u.pricePerHourPaise;
        if (p > 0) prices.add(p);
      }
    }
  }
  if (prices.isEmpty) return '';
  final lo = prices.reduce((a, b) => a < b ? a : b);
  final hi = prices.reduce((a, b) => a > b ? a : b);
  final loStr = '₹${(lo / 100).toStringAsFixed(0)}';
  if (lo == hi) return '$loStr/hr';
  final hiStr = '₹${(hi / 100).toStringAsFixed(0)}';
  return '$loStr–$hiStr/hr';
}

