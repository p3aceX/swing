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

  // null = not yet chosen; 'session' = pick a slot; 'package' = open package sheet
  String? _bookingMode;
  VoidCallback? _packageAction;

  bool _booking = false;
  bool _phonePeReady = false;

  // 0=Facility  1=Options (session vs package)  2=Schedule  3=Confirm
  static const _stepLabels = ['Facility', 'Options', 'Schedule', 'Confirm'];

  bool get _isNets => _selectedGroup?.isNetGroup == true;

  bool _groupHasPackage(BookingGroup group) {
    if (group.isNetGroup) {
      // Only counts if a monthly pass exists for the specific selected net type
      final selectedType = _selectedNetType;
      if (selectedType == null) return false;
      const netUnitTypes = {'CRICKET_NET', 'INDOOR_NET'};
      for (final u in widget.arena.units.where((u) => netUnitTypes.contains(u.unitType))) {
        if (u.netVariants.isNotEmpty) {
          for (final v in u.netVariants) {
            if (v.type.toUpperCase() == selectedType.toUpperCase() &&
                v.monthlyPassRatePaise != null && v.monthlyPassRatePaise! > 0) return true;
          }
        } else {
          final uType = (u.netType ?? '').toUpperCase();
          if ((uType.isEmpty || uType == selectedType.toUpperCase()) &&
              u.monthlyPassRatePaise != null && u.monthlyPassRatePaise! > 0) return true;
        }
      }
      return false;
    } else {
      final unitId = group.singleUnitId;
      for (final u in widget.arena.units.where((u) => unitId == null || u.id == unitId)) {
        if (u.bulkDayRatePaise != null && u.bulkDayRatePaise! > 0) return true;
      }
      return false;
    }
  }

  _PackageInfo? _computeNetsPackage(BuildContext context, BookingGroup group) {
    // Only show monthly pass for the net type the user actually selected.
    final selectedType = _selectedNetType;
    if (selectedType == null) return null;

    const netUnitTypes = {'CRICKET_NET', 'INDOOR_NET'};
    final netUnits = widget.arena.units.where((u) => netUnitTypes.contains(u.unitType)).toList();
    int? bestRate; String? bestLabel, bestUnitId, bestNetType, bestOpenTime, bestCloseTime; int bestMins = 60;
    for (final u in netUnits) {
      if (u.netVariants.isNotEmpty) {
        for (final v in u.netVariants) {
          if (v.type.toUpperCase() != selectedType.toUpperCase()) continue;
          if (v.monthlyPassRatePaise != null && v.monthlyPassRatePaise! > 0 &&
              (bestRate == null || v.monthlyPassRatePaise! < bestRate)) {
            bestRate = v.monthlyPassRatePaise; bestLabel = v.label;
            bestUnitId = u.id; bestNetType = v.type;
            bestMins = u.minSlotMins > 0 ? u.minSlotMins : 60;
            bestOpenTime = u.openTime; bestCloseTime = u.closeTime;
          }
        }
      } else {
        final unitType = (u.netType ?? '').toUpperCase();
        if (unitType.isNotEmpty && unitType != selectedType.toUpperCase()) continue;
        if (u.monthlyPassRatePaise != null && u.monthlyPassRatePaise! > 0 &&
            (bestRate == null || u.monthlyPassRatePaise! < bestRate)) {
          bestRate = u.monthlyPassRatePaise; bestLabel = u.unitTypeLabel ?? u.name;
          bestUnitId = u.id; bestNetType = u.netType ?? selectedType;
          bestMins = u.minSlotMins > 0 ? u.minSlotMins : 60;
          bestOpenTime = u.openTime; bestCloseTime = u.closeTime;
        }
      }
    }
    if (bestRate == null) return null;
    final rate = bestRate, uid = bestUnitId ?? netUnits.firstOrNull?.id ?? '';
    final label = bestLabel ?? 'Cricket Net', netType = bestNetType ?? '', mins = bestMins;
    final openTime = bestOpenTime, closeTime = bestCloseTime;
    return _PackageInfo(
      icon: Icons.workspace_premium_rounded,
      title: 'Monthly Pass',
      priceText: '${_inr(rate)}/month',
      description: 'Unlimited sessions for a month',
      onTap: () => showModalBottomSheet(
        context: context, isScrollControlled: true, useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _MonthlyPassSheet(arenaId: widget.arena.id, arenaName: widget.arena.name,
            unitId: uid, label: label, netType: netType, ratePaise: rate, minSlotMins: mins,
            openTime: openTime, closeTime: closeTime),
      ),
    );
  }

  _PackageInfo? _computeGroundPackage(BuildContext context, BookingGroup group) {
    const netTypes = {'CRICKET_NET', 'INDOOR_NET'};
    final unitId = group.singleUnitId;
    final groundUnits = widget.arena.units
        .where((u) => !netTypes.contains(u.unitType) && (unitId == null || u.id == unitId))
        .toList();
    final minDays = groundUnits.where((u) => u.minBulkDays != null).map((u) => u.minBulkDays!)
        .fold<int?>(null, (b, v) => b == null ? v : (v < b ? v : b));
    final ratePaise = groundUnits.where((u) => u.bulkDayRatePaise != null && u.bulkDayRatePaise! > 0)
        .map((u) => u.bulkDayRatePaise!)
        .fold<int?>(null, (b, v) => b == null ? v : (v < b ? v : b));
    if (ratePaise == null || ratePaise == 0) return null;
    final uid = unitId ?? groundUnits.firstOrNull?.id ?? '';
    final days = minDays ?? 5;
    final mins = groundUnits.where((u) => u.minSlotMins > 0).map((u) => u.minSlotMins)
        .fold<int>(240, (b, v) => v < b ? v : b);
    final openTime = groundUnits.map((u) => u.openTime).whereType<String>().firstOrNull;
    final closeTime = groundUnits.map((u) => u.closeTime).whereType<String>().firstOrNull;
    return _PackageInfo(
      icon: Icons.calendar_month_rounded,
      title: 'Bulk Booking',
      priceText: '${_inr(ratePaise)}/day',
      description: 'Book $days+ days at a discounted rate',
      onTap: () => showModalBottomSheet(
        context: context, isScrollControlled: true, useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _BulkBookingSheet(arenaId: widget.arena.id, arenaName: widget.arena.name,
            unitId: uid, groundName: group.displayName, minBulkDays: days,
            bulkDayRatePaise: ratePaise, minSlotMins: mins,
            openTime: openTime, closeTime: closeTime),
      ),
    );
  }

  _PackageInfo? _buildPackageInfo(BuildContext context) {
    final g = _selectedGroup;
    if (g == null) return null;
    return g.isNetGroup ? _computeNetsPackage(context, g) : _computeGroundPackage(context, g);
  }

  bool get _canNext {
    if (_step == 0) {
      if (_selectedGroup == null) return false;
      if (_isNets && (_selectedGroup!.netTypes.length > 1) && _selectedNetType == null) return false;
      if (!_isNets && _durationMins <= 0) return false;
      return true;
    }
    if (_step == 1) return _bookingMode != null;
    if (_step == 2) return _selectedSlot != null;
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
    if (_step == 0) {
      if (_isNets && _selectedGroup!.netTypes.length == 1 && _selectedNetType == null) {
        setState(() => _selectedNetType = _selectedGroup!.netTypes.first);
      }
      // skip Options step when no package available for this group
      final nextStep = _groupHasPackage(_selectedGroup!) ? 1 : 2;
      setState(() { _step = nextStep; _bookingMode = nextStep == 2 ? 'session' : null; });
      if (nextStep == 2) _loadAvailability();
      return;
    }
    if (_step == 1) {
      if (_bookingMode == 'package') {
        _packageAction?.call();
        return;
      }
      // session — go to schedule
      setState(() => _step = 2);
      _loadAvailability();
      return;
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else if (_step == 2 && !_groupHasPackage(_selectedGroup!)) {
      // skipped Options, go straight back to Facility
      setState(() { _step = 0; _bookingMode = null; });
    } else {
      setState(() => _step--);
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
      _selectedAddons.clear();
      _bookingMode = null;
      _packageAction = null;
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
          arenaUnits: widget.arena.units,
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
      1 => _OptionsStep(
          group: _selectedGroup!,
          durationMins: _durationMins,
          bookingMode: _bookingMode,
          packageInfo: _buildPackageInfo(context),
          scrollCtrl: scrollCtrl,
          onModeChange: (m, {VoidCallback? action}) => setState(() {
            _bookingMode = m;
            if (action != null) _packageAction = action;
          }),
        ),
      2 => _ScheduleStep(
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
      3 => _ConfirmStep(
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
          addons: _addons
              .where((a) => a.unitId == null || a.unitId == _resolvedUnitId)
              .toList(),
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
            if (_step < 3) ...[
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

// ── Package info ──────────────────────────────────────────────────────────────

class _PackageInfo {
  const _PackageInfo({
    required this.icon,
    required this.title,
    required this.priceText,
    required this.description,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String priceText;
  final String description;
  final VoidCallback onTap;
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
    required this.arenaUnits,
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
  final List<ArenaUnitOption> arenaUnits;
  final ValueChanged<BookingGroup> onGroupTap;
  final ValueChanged<String> onNetTypeTap;
  final ValueChanged<int> onDurationChanged;

  bool _hasPackage(BookingGroup group) {
    if (group.isNetGroup) {
      const t = {'CRICKET_NET', 'INDOOR_NET'};
      for (final u in arenaUnits.where((u) => t.contains(u.unitType))) {
        if (u.monthlyPassRatePaise != null && u.monthlyPassRatePaise! > 0) return true;
        for (final v in u.netVariants) {
          if (v.monthlyPassRatePaise != null && v.monthlyPassRatePaise! > 0) return true;
        }
      }
      return false;
    } else {
      final uid = group.singleUnitId;
      for (final u in arenaUnits.where((u) => uid == null || u.id == uid)) {
        if (u.bulkDayRatePaise != null && u.bulkDayRatePaise! > 0) return true;
      }
      return false;
    }
  }

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
              hasPackage: _hasPackage(group),
              onTap: () => onGroupTap(group),
              durationMins: durationMins,
              selectedNetType: selectedNetType,
              onNetTypeTap: onNetTypeTap,
            ),
            const SizedBox(height: 12),
          ],
        ],
        if (groundGroups.isNotEmpty) ...[
          if (netGroups.isNotEmpty) const SizedBox(height: 12),
          _SectionLabel('GROUNDS & COURTS'),
          const SizedBox(height: 12),
          for (final group in groundGroups) ...[
            _FacilityItem(
              group: group,
              selected: selectedGroup == group,
              hasPackage: _hasPackage(group),
              onTap: () => onGroupTap(group),
              durationMins: durationMins,
              onDurationChanged: onDurationChanged,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _FacilityItem extends StatelessWidget {
  const _FacilityItem({
    required this.group,
    required this.selected,
    required this.hasPackage,
    required this.onTap,
    required this.durationMins,
    this.selectedNetType,
    this.onNetTypeTap,
    this.onDurationChanged,
  });

  final BookingGroup group;
  final bool selected;
  final bool hasPackage;
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            group.isNetGroup
                                ? _netPriceRange(group.units)
                                : _groundPriceLabel(group.units.first),
                            style: TextStyle(
                              color: context.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (hasPackage) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: context.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                group.isNetGroup ? 'MONTHLY PASS' : 'BULK BOOKING',
                                style: TextStyle(
                                  color: context.accent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ],
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

// ── Step 1: Options ───────────────────────────────────────────────────────────

class _OptionsStep extends StatelessWidget {
  const _OptionsStep({
    required this.group,
    required this.durationMins,
    required this.bookingMode,
    required this.packageInfo,
    required this.scrollCtrl,
    required this.onModeChange,
  });

  final BookingGroup group;
  final int durationMins;
  final String? bookingMode;
  final _PackageInfo? packageInfo;
  final ScrollController scrollCtrl;
  final void Function(String? mode, {VoidCallback? action}) onModeChange;

  @override
  Widget build(BuildContext context) {
    final sessionPrice = group.isNetGroup
        ? _netPriceRange(group.units)
        : _groundPriceLabel(group.units.first, durationMins: durationMins);

    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        Text(
          group.displayName,
          style: TextStyle(
            color: context.fg,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'How would you like to book?',
          style: TextStyle(
            color: context.fgSub,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        _OptionCard(
          icon: group.isNetGroup
              ? Icons.sports_cricket_rounded
              : Icons.schedule_rounded,
          title: 'Book a Session',
          subtitle: group.isNetGroup
              ? 'Pick a date, time and duration'
              : 'Pick a date and a time slot',
          priceText: sessionPrice.isNotEmpty ? sessionPrice : null,
          priceLabel: group.isNetGroup ? null : null,
          isSelected: bookingMode == 'session',
          onTap: () => onModeChange('session'),
        ),
        if (packageInfo != null) ...[
          const SizedBox(height: 12),
          _OptionCard(
            icon: packageInfo!.icon,
            title: packageInfo!.title,
            subtitle: packageInfo!.description,
            priceText: packageInfo!.priceText,
            isSelected: bookingMode == 'package',
            onTap: () => onModeChange('package', action: packageInfo!.onTap),
          ),
        ],
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.priceText,
    this.priceLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? priceText;
  final String? priceLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? context.accent.withValues(alpha: 0.07)
              : (isDark ? const Color(0xFF0D0D0D) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? context.accent : context.stroke.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.accent.withValues(alpha: 0.15)
                    : context.panel.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? context.accent : context.fgSub,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? context.accent : context.fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.fgSub.withValues(alpha: 0.65),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (priceText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      priceText!,
                      style: TextStyle(
                        color: context.accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? context.accent : Colors.transparent,
                border: Border.all(
                  color: isSelected ? context.accent : context.stroke.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded,
                      size: 14,
                      color: isDark ? Colors.black : Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: Schedule ──────────────────────────────────────────────────────────

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
    // Prefer the unit-level advanceBookingDays; fall back to arena-level, then 30.
    final unitDays = selectedGroup.units
        .map((u) => u.advanceBookingDays ?? 0)
        .where((d) => d > 0)
        .fold<int>(0, (a, b) => b > a ? b : a);
    final maxDays = unitDays > 0 ? unitDays : (advanceBookingDays > 0 ? advanceBookingDays : 30);
    final maxDate = DateTime(today.year, today.month, today.day + maxDays);
    final dateLabel = DateFormat('EEE, d MMM').format(selectedDate);

    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        // Calendar
        _AvailabilityCalendar(
          selectedDate: selectedDate,
          displayedMonth: displayedMonth,
          maxDate: maxDate,
          fillLevels: fillLevels,
          onDateChanged: onDateChanged,
          onMonthChanged: onMonthChanged,
        ),

        // Duration segmented control (nets only)
        if (isNets) ...[
          const SizedBox(height: 20),
          _SegmentedDurationPicker(
            selectedMins: durationMins,
            constraints: selectedGroup.units.map(DurationConstraints.fromUnit).toList(),
            onChanged: onDurationChanged,
          ),
        ],

        const SizedBox(height: 24),

        // Slots header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                dateLabel,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              if (!loading && slots.isNotEmpty)
                Text(
                  '${slots.length} slot${slots.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (loading)
          _SlotSkeleton()
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

class _SegmentedDurationPicker extends StatelessWidget {
  const _SegmentedDurationPicker({
    required this.selectedMins,
    required this.constraints,
    required this.onChanged,
  });

  final int selectedMins;
  final List<DurationConstraints> constraints;
  final ValueChanged<int> onChanged;

  static const _durations = [60, 120, 240, 480];

  List<int> get _validDurations {
    if (constraints.isEmpty) return _durations;
    return _durations.where((mins) => constraints.every((c) {
      final min = c.minSlotMins > 0 ? c.minSlotMins : 60;
      final withinMin = mins >= min;
      final withinMax = c.maxSlotMins <= 0 || mins <= c.maxSlotMins;
      return withinMin && withinMax;
    })).toList();
  }

  int? _savingPercent(int mins) {
    if (mins != 240 && mins != 480) return null;
    final hours = mins ~/ 60;
    int best = 0;
    for (final c in constraints) {
      final packagePrice = mins == 240 ? c.price4HrPaise : c.price8HrPaise;
      if (packagePrice == null || packagePrice <= 0) continue;
      final regular = c.pricePerHourPaise * hours;
      if (regular <= 0 || packagePrice >= regular) continue;
      final saving = (((regular - packagePrice) / regular) * 100).round();
      if (saving > best) best = saving;
    }
    return best > 0 ? best : null;
  }

  @override
  Widget build(BuildContext context) {
    final valid = _validDurations;
    if (valid.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: context.panel.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (int i = 0; i < valid.length; i++) ...[
              Expanded(
                child: _SegmentChip(
                  mins: valid[i],
                  selected: selectedMins == valid[i],
                  saving: _savingPercent(valid[i]),
                  onTap: () => onChanged(valid[i]),
                ),
              ),
              if (i < valid.length - 1) const SizedBox(width: 3),
            ],
          ],
        ),
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.mins,
    required this.selected,
    required this.saving,
    required this.onTap,
  });

  final int mins;
  final bool selected;
  final int? saving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected ? context.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${mins ~/ 60}hr',
              style: TextStyle(
                color: selected ? Colors.white : context.fg,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            if (saving != null) ...[
              const SizedBox(height: 2),
              Text(
                'save $saving%',
                style: TextStyle(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.7)
                      : context.success,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                  height: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SlotSkeleton extends StatefulWidget {
  @override
  State<_SlotSkeleton> createState() => _SlotSkeletonState();
}

class _SlotSkeletonState extends State<_SlotSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final opacity = 0.08 + _anim.value * 0.12;
          final color = context.fg.withValues(alpha: opacity);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.55,
            ),
            itemCount: 9,
            itemBuilder: (_, __) => Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
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

// ── Availability calendar — horizontal day strip ──────────────────────────────

class _AvailabilityCalendar extends StatefulWidget {
  const _AvailabilityCalendar({
    required this.selectedDate,
    required this.displayedMonth,
    required this.maxDate,
    required this.fillLevels,
    required this.onDateChanged,
    required this.onMonthChanged,
  });

  final DateTime selectedDate;
  final DateTime displayedMonth;  // unused in strip mode, kept for API compat
  final DateTime maxDate;
  final Map<String, int?> fillLevels;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime> onMonthChanged;  // unused in strip mode

  @override
  State<_AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<_AvailabilityCalendar> {
  static const int _visibleCount = 7;
  static const double _cellGap = 6;
  static const double _padH = 20;

  late final ScrollController _scroll;
  late final List<DateTime> _dates;
  double _cellW = 44; // computed on first build

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final totalDays = widget.maxDate.difference(todayDate).inDays + 1;
    _dates = List.generate(totalDays, (i) => todayDate.add(Duration(days: i)));
    _scroll = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected(animate: false));
  }

  @override
  void didUpdateWidget(_AvailabilityCalendar old) {
    super.didUpdateWidget(old);
    if (!_sameDay(old.selectedDate, widget.selectedDate)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected(animate: true));
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToSelected({required bool animate}) {
    final idx = _dates.indexWhere((d) => _sameDay(d, widget.selectedDate));
    if (idx < 0 || !_scroll.hasClients) return;
    final stride = _cellW + _cellGap;
    final viewportW = _scroll.position.viewportDimension;
    final offset = stride * idx + _padH - (viewportW - _cellW) / 2;
    final target = offset.clamp(0.0, _scroll.position.maxScrollExtent);
    if (animate) {
      _scroll.animateTo(target,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
    } else {
      _scroll.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final monthLabel = DateFormat('MMMM yyyy').format(widget.selectedDate);
    final screenW = MediaQuery.of(context).size.width;
    // fit exactly 7 cells: screenW = 2*padH + 7*cellW + 6*cellGap
    _cellW = (screenW - 2 * _padH - (_visibleCount - 1) * _cellGap) / _visibleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _padH),
          child: Text(
            monthLabel,
            style: TextStyle(
              color: context.fg,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 72,
          child: ListView.builder(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: _padH),
            itemCount: _dates.length,
            itemExtent: _cellW + _cellGap,
            itemBuilder: (context, i) {
              final date = _dates[i];
              final isToday = _sameDay(date, todayDate);
              final isSelected = _sameDay(date, widget.selectedDate);
              final fillLevel = widget.fillLevels[_dateKey(date)];
              return Padding(
                padding: const EdgeInsets.only(right: _cellGap),
                child: _DateStripCell(
                  date: date,
                  cellWidth: _cellW,
                  isSelected: isSelected,
                  isToday: isToday,
                  fillLevel: fillLevel,
                  onTap: () => widget.onDateChanged(date),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _DateStripCell extends StatelessWidget {
  const _DateStripCell({
    required this.date,
    required this.cellWidth,
    required this.isSelected,
    required this.isToday,
    required this.fillLevel,
    required this.onTap,
  });

  final DateTime date;
  final double cellWidth;
  final bool isSelected;
  final bool isToday;
  final int? fillLevel;
  final VoidCallback onTap;

  static const _green = Color(0xFF4ADE80);
  static const _amber = Color(0xFFFBBF24);
  static const _red   = Color(0xFFF87171);

  Color? _stripeColor() {
    if (isSelected || fillLevel == null) return null;
    if (fillLevel == 0) return _green;
    if (fillLevel == 1) return _amber;
    if (fillLevel == 2) return _red;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final stripe = _stripeColor();
    final dayName = DateFormat('EEE').format(date).toUpperCase();
    final dayNum = date.day;

    final textColor = isSelected
        ? (isDark ? Colors.black : Colors.white)
        : fillLevel == 2
            ? context.fgSub.withValues(alpha: 0.4)
            : context.fg;

    final subColor = isSelected
        ? (isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.65))
        : context.fgSub;

    final cellBg = isSelected
        ? context.accent
        : isToday
            ? context.accent.withValues(alpha: 0.1)
            : context.panel.withValues(alpha: 0.45);

    final cellBorder = isToday && !isSelected
        ? Border.all(color: context.accent.withValues(alpha: 0.5), width: 1.5)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: cellWidth,
        decoration: BoxDecoration(
          color: cellBg,
          borderRadius: BorderRadius.circular(12),
          border: cellBorder,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        color: subColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$dayNum',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              if (stripe != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 3,
                    color: stripe.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),
        ),
      ),
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
    // Used by bulk booking sheet — keep old circle style
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
                  fontWeight: (isSelected || isToday) ? FontWeight.w900 : FontWeight.w500,
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

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.enabled, this.onTap});
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? context.fg : context.fgSub.withValues(alpha: 0.2),
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

String _groundPriceLabel(ArenaUnitOption unit, {int durationMins = 0}) {
  final minSlot = unit.minSlotMins > 0 ? unit.minSlotMins : 60;
  final effective = (durationMins >= minSlot) ? durationMins : minSlot;
  if (effective >= 720 && unit.priceFullDayPaise != null && unit.priceFullDayPaise! > 0) {
    return '₹${(unit.priceFullDayPaise! / 100).toStringAsFixed(0)} / full day';
  }
  if (effective >= 480 && unit.price8HrPaise != null && unit.price8HrPaise! > 0) {
    return '₹${(unit.price8HrPaise! / 100).toStringAsFixed(0)} / 8 hr';
  }
  if (effective >= 240 && unit.price4HrPaise != null && unit.price4HrPaise! > 0) {
    return '₹${(unit.price4HrPaise! / 100).toStringAsFixed(0)} / 4 hr';
  }
  if (unit.pricePerHourPaise > 0) {
    final price = ((unit.pricePerHourPaise * effective) / 60).round();
    final hrs = effective ~/ 60;
    return '₹${(price / 100).toStringAsFixed(0)} / ${hrs}hr';
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



// ── Monthly Pass Sheet ────────────────────────────────────────────────────────

class _MonthlyPassSheet extends ConsumerStatefulWidget {
  const _MonthlyPassSheet({
    required this.arenaId,
    required this.arenaName,
    required this.unitId,
    required this.label,
    required this.netType,
    required this.ratePaise,
    required this.minSlotMins,
    this.openTime,
    this.closeTime,
  });

  final String arenaId;
  final String arenaName;
  final String unitId;
  final String label;
  final String netType;
  final int ratePaise;
  final int minSlotMins;
  final String? openTime;
  final String? closeTime;

  @override
  ConsumerState<_MonthlyPassSheet> createState() => _MonthlyPassSheetState();
}

class _MonthlyPassSheetState extends ConsumerState<_MonthlyPassSheet> {
  late int _startHour;
  late DateTime _startDate;
  bool _booking = false;
  bool _phonePeReady = false;

  int get _openHour => _h(widget.openTime ?? '05:00');
  int get _closeHour {
    // Last valid start = closeTime minus one slot duration
    final closeH = _h(widget.closeTime ?? '23:00');
    final closeM = _m(widget.closeTime ?? '23:00');
    final latestStartMins = closeH * 60 + closeM - widget.minSlotMins;
    return latestStartMins ~/ 60;
  }

  @override
  void initState() {
    super.initState();
    _startHour = _openHour;
    _startDate = DateTime.now().add(const Duration(days: 1));
    _initPhonePe();
  }

  Future<void> _initPhonePe() async {
    final ready = await _initPhonePeSdk();
    if (!mounted) return;
    setState(() => _phonePeReady = ready);
  }

  String _hhmm(int h) => '${h.toString().padLeft(2, '0')}:00';

  String get _endTimeStr {
    final endMins = _startHour * 60 + widget.minSlotMins;
    return '${(endMins ~/ 60).toString().padLeft(2, '0')}:${(endMins % 60).toString().padLeft(2, '0')}';
  }

  DateTime get _endDate => DateTime(_startDate.year, _startDate.month + 1, _startDate.day);

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _book() async {
    if (_booking) return;
    if (!_phonePeReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment not ready. Please try again.')),
      );
      return;
    }
    setState(() => _booking = true);
    final repo = ref.read(arenaSlotsRepositoryProvider);
    try {
      final order = await repo.createPaymentOrder(widget.ratePaise);
      debugPrint('[PhonePe] monthly pass order=${order.orderId} amount=${order.amountPaise}');
      final paid = await _phonePeTransact(order, (msg) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      });
      if (!mounted) return;
      if (!paid) { setState(() => _booking = false); return; }
      await repo.createMonthlyPass(
        arenaUnitId: widget.unitId,
        startTime: _hhmm(_startHour),
        endTime: _endTimeStr,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
        variantType: widget.netType,
        phonePeOrderId: order.orderId,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.label} Monthly Pass booked!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _booking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(repo.messageFor(e, fallback: 'Could not book monthly pass.'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: context.stroke.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  Text('${widget.label} Monthly Pass',
                    style: TextStyle(color: context.fg, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Text('${_inr(widget.ratePaise)}/month',
                    style: TextStyle(color: context.accent, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 28),

                  _SectionLabel('Session time'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: (_closeHour - _openHour + 1).clamp(1, 24),
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final h = _openHour + i;
                        final sel = _startHour == h;
                        return GestureDetector(
                          onTap: () => setState(() => _startHour = h),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel ? context.accent : context.panel.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(_hhmm(h),
                              style: TextStyle(
                                color: sel ? Colors.white : context.fg,
                                fontSize: 14, fontWeight: FontWeight.w900,
                              )),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${_hhmm(_startHour)} – $_endTimeStr · ${_dur(widget.minSlotMins)} per session',
                    style: TextStyle(color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 28),

                  _SectionLabel('Start date'),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickStartDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: context.panel.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 16, color: context.accent),
                          const SizedBox(width: 10),
                          Text(DateFormat('EEE, d MMM yyyy').format(_startDate),
                            style: TextStyle(color: context.fg, fontSize: 15, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          Icon(Icons.chevron_right_rounded, size: 18, color: context.fgSub.withValues(alpha: 0.4)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Valid until ${DateFormat('d MMM yyyy').format(_endDate)}',
                    style: TextStyle(color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 36),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: !_booking ? _book : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: context.panel,
                        disabledForegroundColor: context.fgSub,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _booking
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : Text('BOOK – ${_inr(widget.ratePaise)}/MONTH',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bulk Booking Sheet ────────────────────────────────────────────────────────

class _BulkBookingSheet extends ConsumerStatefulWidget {
  const _BulkBookingSheet({
    required this.arenaId,
    required this.arenaName,
    required this.unitId,
    required this.groundName,
    required this.minBulkDays,
    required this.bulkDayRatePaise,
    required this.minSlotMins,
    this.openTime,
    this.closeTime,
  });

  final String arenaId;
  final String arenaName;
  final String unitId;
  final String groundName;
  final int minBulkDays;
  final int bulkDayRatePaise;
  final int minSlotMins;
  final String? openTime;
  final String? closeTime;

  @override
  ConsumerState<_BulkBookingSheet> createState() => _BulkBookingSheetState();
}

class _BulkBookingSheetState extends ConsumerState<_BulkBookingSheet> {
  final Set<DateTime> _selectedDates = {};
  late DateTime _displayedMonth;
  bool _booking = false;
  bool _phonePeReady = false;

  // availability: null=loading, 0=open, 1=few, 2=full
  final Map<String, int?> _avail = {};
  int _availLoadId = 0;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadMonthAvail();
    _initPhonePe();
  }

  Future<void> _initPhonePe() async {
    final ready = await _initPhonePeSdk();
    if (!mounted) return;
    setState(() => _phonePeReady = ready);
  }

  void _loadMonthAvail() {
    final loadId = ++_availLoadId;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final maxDate = todayDate.add(const Duration(days: 90));
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final repo = ref.read(arenaSlotsRepositoryProvider);

    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, d);
      if (date.isBefore(todayDate) || date.isAfter(maxDate)) continue;
      final key = _dateKey(date);
      repo.getArenaSlots(widget.arenaId, date, widget.minSlotMins).then((slots) {
        if (!mounted || loadId != _availLoadId) return;
        final group = slots.unitGroups.where((g) => g.unitId == widget.unitId || g.groupKey == widget.unitId).firstOrNull;
        final count = group?.availableSlots.length ?? 0;
        final level = count == 0 ? 2 : (count <= 2 ? 1 : 0);
        setState(() {
          _avail[key] = level;
          if (level == 2) _selectedDates.remove(date);
        });
      }).catchError((_) {
        if (!mounted || loadId != _availLoadId) return;
        setState(() => _avail[_dateKey(date)] = 2);
      });
    }
  }

  String get _startTimeStr => widget.openTime ?? '05:00';
  String get _endTimeStr => widget.closeTime ?? '23:00';

  int get _totalPaise => widget.bulkDayRatePaise * _selectedDates.length;

  bool get _canBook => _selectedDates.length >= widget.minBulkDays;

  void _toggleDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    setState(() {
      if (_selectedDates.contains(key)) _selectedDates.remove(key);
      else _selectedDates.add(key);
    });
  }

  Future<void> _book() async {
    if (!_canBook || _booking) return;
    if (!_phonePeReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment not ready. Please try again.')),
      );
      return;
    }
    setState(() => _booking = true);
    final repo = ref.read(arenaSlotsRepositoryProvider);
    try {
      final order = await repo.createPaymentOrder(_totalPaise);
      debugPrint('[PhonePe] bulk booking order=${order.orderId} amount=${order.amountPaise}');
      final paid = await _phonePeTransact(order, (msg) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      });
      if (!mounted) return;
      if (!paid) { setState(() => _booking = false); return; }
      final sorted = _selectedDates.toList()..sort();
      final dates = sorted.map((d) => DateFormat('yyyy-MM-dd').format(d)).toList();
      await repo.createBulkBooking(
        arenaUnitId: widget.unitId,
        startTime: _startTimeStr,
        endTime: _endTimeStr,
        dates: dates,
        phonePeOrderId: order.orderId,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedDates.length} days booked for ${widget.groundName}!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _booking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(repo.messageFor(e, fallback: 'Could not complete bulk booking.'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final maxDate = todayDate.add(const Duration(days: 90));
    final firstOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final startOffset = (firstOfMonth.weekday - 1) % 7;
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final canGoPrev = _displayedMonth.isAfter(DateTime(today.year, today.month));
    final canGoNext = DateTime(_displayedMonth.year, _displayedMonth.month + 1)
        .isBefore(DateTime(maxDate.year, maxDate.month + 1));

    return DraggableScrollableSheet(
      initialChildSize: 0.93,
      minChildSize: 0.6,
      maxChildSize: 0.97,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: context.stroke.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.only(top: 20, bottom: 40),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bulk Booking',
                          style: TextStyle(color: context.fg, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                        const SizedBox(height: 4),
                        Text('${widget.groundName} · ${_inr(widget.bulkDayRatePaise)}/day',
                          style: TextStyle(color: context.accent, fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Month nav
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(DateFormat('MMMM yyyy').format(_displayedMonth),
                            style: TextStyle(color: context.fg, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: context.panel.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _NavBtn(icon: Icons.chevron_left_rounded, enabled: canGoPrev,
                                onTap: canGoPrev ? () {
                                  setState(() {
                                    _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
                                    _avail.clear();
                                  });
                                  _loadMonthAvail();
                                } : null),
                              Container(width: 1, height: 16, color: context.fgSub.withValues(alpha: 0.1)),
                              _NavBtn(icon: Icons.chevron_right_rounded, enabled: canGoNext,
                                onTap: canGoNext ? () {
                                  setState(() {
                                    _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
                                    _avail.clear();
                                  });
                                  _loadMonthAvail();
                                } : null),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'].map((d) => Expanded(
                        child: Center(child: Text(d,
                          style: TextStyle(color: context.fgSub.withValues(alpha: 0.35), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3))),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7, childAspectRatio: 0.85, mainAxisSpacing: 4, crossAxisSpacing: 2),
                      itemCount: startOffset + daysInMonth,
                      itemBuilder: (_, i) {
                        if (i < startOffset) return const SizedBox();
                        final day = i - startOffset + 1;
                        final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
                        final outOfRange = date.isBefore(todayDate) || date.isAfter(maxDate);
                        final fillLevel = outOfRange ? null : _avail[_dateKey(date)];
                        final disabled = outOfRange || fillLevel == 2;
                        return _DateCell(
                          day: day,
                          isSelected: _selectedDates.contains(date),
                          isToday: _sameDay(date, todayDate),
                          isDisabled: disabled,
                          fillLevel: outOfRange ? null : fillLevel,
                          onTap: disabled ? null : () => _toggleDate(date),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text('${_selectedDates.length} days selected',
                          style: TextStyle(color: context.fg, fontSize: 14, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 8),
                        if (_selectedDates.length < widget.minBulkDays)
                          Text('(min ${widget.minBulkDays})',
                            style: TextStyle(color: context.warn, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('$_startTimeStr – $_endTimeStr · full day',
                      style: TextStyle(color: context.fgSub, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),

                  if (_selectedDates.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total (${_selectedDates.length} × ${_inr(widget.bulkDayRatePaise)})',
                            style: TextStyle(color: context.fgSub, fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(_inr(_totalPaise),
                            style: TextStyle(color: context.accent, fontSize: 18, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 36),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (_canBook && !_booking) ? _book : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: context.panel,
                          disabledForegroundColor: context.fgSub,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _booking
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : Text(
                                _selectedDates.length >= widget.minBulkDays
                                    ? 'BOOK – ${_inr(_totalPaise)}'
                                    : 'SELECT ${widget.minBulkDays - _selectedDates.length} MORE DAY${widget.minBulkDays - _selectedDates.length == 1 ? '' : 'S'}',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ── Shared PhonePe helper ─────────────────────────────────────────────────────

/// Initialises the PhonePe SDK (idempotent across sheets).
Future<bool> _initPhonePeSdk() async {
  final envs = kReleaseMode
      ? const <String>['PRODUCTION']
      : const <String>['PRODUCTION', 'SANDBOX'];
  for (final env in envs) {
    try {
      await PhonePePaymentSdk.init(env, _kMerchantId, _kPhonePeFlowId, false);
      debugPrint('[PhonePe] init success env=$env');
      return true;
    } catch (e) {
      debugPrint('[PhonePe] init failed env=$env error=$e');
    }
  }
  return false;
}

/// Runs the PhonePe payment UI for [order].
/// Returns true if payment completed, false if cancelled/failed.
/// Calls [onError] with a user-facing message on non-fatal failures.
/// Throws on hard errors (missing token+redirect, bad URL, etc.).
Future<bool> _phonePeTransact(
  ArenaPaymentOrder order,
  void Function(String) onError,
) async {
  if (order.orderId.trim().isEmpty) throw Exception('Missing PhonePe order ID.');
  if (order.token.trim().isNotEmpty) {
    final payload = jsonEncode({
      'orderId': order.orderId,
      'merchantId': _kMerchantId,
      'token': order.token,
      'paymentMode': {'type': 'PAY_PAGE'},
    });
    debugPrint('[PhonePe] startTransaction orderId=${order.orderId}');
    final response = await PhonePePaymentSdk.startTransaction(payload, _kAppSchema);
    if (response == null) {
      onError('PhonePe did not return a response. Please try again.');
      return false;
    }
    final status = response['status']?.toString() ?? 'FAILURE';
    debugPrint('[PhonePe] transaction status=$status');
    if (status == 'SUCCESS') return true;
    if (status == 'INTERRUPTED') { onError('Payment was cancelled.'); return false; }
    final err = response['error']?.toString() ?? '';
    onError(err.isNotEmpty ? err : 'Payment failed. Please try again.');
    return false;
  } else {
    final redirect = order.redirectUrl;
    if (redirect == null || redirect.trim().isEmpty) {
      throw Exception('PhonePe token and redirect URL both missing.');
    }
    final uri = Uri.tryParse(redirect.trim());
    if (uri == null) throw Exception('Invalid PhonePe redirect URL.');
    debugPrint('[PhonePe] launching redirectUrl=$redirect');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) { onError('Could not open PhonePe checkout. Please try again.'); return false; }
    await Future<void>.delayed(const Duration(seconds: 2));
    return true;
  }
}

