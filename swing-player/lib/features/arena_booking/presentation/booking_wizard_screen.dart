import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

import '../../../core/theme/app_colors.dart';
import '../data/arena_slots_repository.dart';
import '../domain/arena_slots_models.dart';
import 'widgets/duration_picker.dart';
import 'widgets/slot_time_grid.dart';
import 'widgets/unit_group_card.dart';

const _kMerchantId = 'SU2507111540338505172019';
const _kAppSchema = 'swingplayer';

class BookingWizardScreen extends ConsumerStatefulWidget {
  const BookingWizardScreen({
    super.key,
    required this.arenaId,
  });

  final String arenaId;

  @override
  ConsumerState<BookingWizardScreen> createState() =>
      _BookingWizardScreenState();
}

class _BookingWizardScreenState extends ConsumerState<BookingWizardScreen> {
  int _step = 0;
  ArenaSlots? _slots;
  bool _loading = false;
  bool _booking = false;
  int _requestId = 0;

  late DateTime _selectedDate;
  int _durationMins = 60;
  UnitGroupSlots? _selectedGroup;
  AvailableSlot? _selectedSlot;
  String? _selectedNetType;

  final _pageNotifier = ValueNotifier<int>(0);

  bool get _isNets => _selectedGroup?.isNetGroup == true;

  static const _stepLabels = ['Facility', 'Schedule', 'Confirm'];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _initPhonePe();
    _load();
  }

  Future<void> _initPhonePe() async {
    try {
      await PhonePePaymentSdk.init('PRODUCTION', _kMerchantId, '', false);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageNotifier.dispose();
    super.dispose();
  }

  // ── Data ────────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    final rid = ++_requestId;
    final prevKey = _selectedGroup?.groupKey;
    setState(() {
      _loading = true;
      _selectedSlot = null;
    });
    try {
      final slots = await ref
          .read(arenaSlotsRepositoryProvider)
          .getArenaSlots(widget.arenaId, _selectedDate, _durationMins);
      if (!mounted || rid != _requestId) return;
      final restored = prevKey == null
          ? null
          : slots.unitGroups.where((g) => g.groupKey == prevKey).firstOrNull;
      setState(() {
        _slots = slots;
        _loading = false;
        _selectedGroup = restored;
        if (restored == null) _selectedNetType = null;
      });
    } catch (e) {
      if (!mounted || rid != _requestId) return;
      setState(() => _loading = false);
      _snack(ref
          .read(arenaSlotsRepositoryProvider)
          .messageFor(e, fallback: 'Could not load slots.'));
    }
  }

  // ── Navigation ───────────────────────────────────────────────────────────────

  bool get _canNext {
    if (_step == 0) {
      if (_selectedGroup == null) return false;
      if (_isNets &&
          (_selectedGroup?.netTypes.length ?? 0) > 1 &&
          _selectedNetType == null) return false;
      return true;
    }
    if (_step == 1) return _selectedSlot != null;
    return false;
  }

  void _next() {
    // Auto-select single net type before advancing
    if (_step == 0 &&
        _isNets &&
        (_selectedGroup?.netTypes.length ?? 0) == 1 &&
        _selectedNetType == null) {
      setState(() => _selectedNetType = _selectedGroup!.netTypes.first);
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.pop();
    }
  }

  // ── Payment ─────────────────────────────────────────────────────────────────

  String? get _resolvedUnitId {
    final g = _selectedGroup;
    final s = _selectedSlot;
    if (g == null || s == null) return null;
    if (g.isNetGroup) {
      if (_selectedNetType != null) {
        return s.netTypeOptions
                .where((o) => o.netType == _selectedNetType)
                .map((o) => o.assignedUnitId)
                .firstOrNull ??
            s.assignedUnitId;
      }
      return s.assignedUnitId;
    }
    return g.unitId;
  }

  int get _effectivePaise {
    final g = _selectedGroup;
    final s = _selectedSlot;
    if (g == null || s == null) return 0;
    if (g.isNetGroup && _selectedNetType != null) {
      return s.netTypeOptions
              .where((o) => o.netType == _selectedNetType)
              .map((o) => o.totalAmountPaise)
              .firstOrNull ??
          s.totalAmountPaise;
    }
    return s.totalAmountPaise;
  }

  int get _payNowPaise {
    final g = _selectedGroup;
    if (g == null) return 0;
    return g.minAdvancePaise > 0 ? g.minAdvancePaise : _effectivePaise;
  }

  Future<void> _pay() async {
    final g = _selectedGroup;
    final s = _selectedSlot;
    if (g == null || s == null) return;
    final unitId = _resolvedUnitId;
    if (unitId == null || unitId.isEmpty) {
      _snack('Could not assign a unit. Please try again.');
      return;
    }

    setState(() => _booking = true);
    final repo = ref.read(arenaSlotsRepositoryProvider);
    try {
      final hold = await repo.holdSlot(
        arenaId: widget.arenaId,
        unitId: unitId,
        date: _selectedDate,
        startTime: s.startTime,
        endTime: s.endTime,
      );

      final order = await repo.createPaymentOrder(_payNowPaise);

      final payload = jsonEncode({
        'orderId': order.orderId,
        'merchantId': _kMerchantId,
        'token': order.token,
        'paymentMode': {'type': 'PAY_PAGE'},
      });

      final response =
          await PhonePePaymentSdk.startTransaction(payload, _kAppSchema);
      if (!mounted) return;

      final status = response?['status']?.toString() ?? 'FAILURE';
      if (status == 'SUCCESS') {
        final booking = await repo.createBooking(
          holdId: hold.holdId,
          unitId: unitId,
          date: _selectedDate,
          startTime: s.startTime,
          endTime: s.endTime,
          phonePeOrderId: order.orderId,
          advancePaise: _payNowPaise,
          totalAmountPaise: _effectivePaise,
        );
        if (!mounted) return;
        setState(() => _booking = false);
        context.go('/booking/success', extra: booking);
      } else if (status == 'INTERRUPTED') {
        setState(() => _booking = false);
        _snack('Payment was cancelled.');
      } else {
        setState(() => _booking = false);
        final err = response?['error']?.toString() ?? '';
        _snack(err.isNotEmpty ? err : 'Payment failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _booking = false);
      _snack(repo.messageFor(e, fallback: 'Could not complete booking.'));
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Group selection ──────────────────────────────────────────────────────────

  void _onGroupTap(UnitGroupSlots group) {
    if (_selectedGroup == group) {
      setState(() {
        _selectedGroup = null;
        _selectedSlot = null;
        _selectedNetType = null;
      });
      return;
    }
    final newDur = group.minSlotMins > 0 ? group.minSlotMins : 60;
    final needsReload = newDur != _durationMins;
    setState(() {
      _selectedGroup = group;
      _selectedSlot = null;
      _durationMins = newDur;
      _selectedNetType = (group.isNetGroup && group.netTypes.length == 1)
          ? group.netTypes.first
          : null;
    });
    if (needsReload) _load();
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final arena = _slots?.arena;
    return Scaffold(
      backgroundColor: context.bg,
      body: Column(
        children: [
          // Photo hero + back button
          SizedBox(
            height: 200 + topPad,
            child: Stack(
              children: [
                Positioned.fill(
                  child: _PhotoHero(
                    photos: arena?.photoUrls ?? const [],
                    arena: arena,
                    pageNotifier: _pageNotifier,
                  ),
                ),
                Positioned(
                  top: topPad + 8,
                  left: 12,
                  child: _CircleBtn(
                    icon: Icons.arrow_back_rounded,
                    onTap: _back,
                  ),
                ),
              ],
            ),
          ),
          // Step progress bar + labels
          _StepBar(current: _step, labels: _stepLabels),
          // Step content
          Expanded(child: _buildStep()),
          // Bottom navigation
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _FacilityStep(
          slots: _slots,
          loading: _loading,
          selectedGroup: _selectedGroup,
          selectedNetType: _selectedNetType,
          durationMins: _durationMins,
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
            _load();
          },
        ),
      1 => _ScheduleStep(
          slots: _slots,
          loading: _loading,
          selectedDate: _selectedDate,
          selectedGroup: _selectedGroup!,
          selectedSlot: _selectedSlot,
          selectedNetType: _selectedNetType,
          durationMins: _durationMins,
          isNets: _isNets,
          onDateChanged: (d) {
            setState(() => _selectedDate = d);
            _load();
          },
          onSlotSelected: (s) => setState(() => _selectedSlot = s),
          onDurationChanged: (d) {
            setState(() {
              _durationMins = d;
              _selectedSlot = null;
            });
            _load();
          },
        ),
      2 => _ConfirmStep(
          arena: _slots!.arena,
          group: _selectedGroup!,
          slot: _selectedSlot!,
          date: _selectedDate,
          durationMins: _durationMins,
          selectedNetType: _selectedNetType,
          effectivePaise: _effectivePaise,
          payNowPaise: _payNowPaise,
          booking: _booking,
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
          border: Border(
            top: BorderSide(color: context.stroke.withValues(alpha: 0.2)),
          ),
        ),
        child: Row(
          children: [
            // Back / close
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
            // Step dots — centered in remaining space
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _step == i ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _step == i ? context.accent : context.panel,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Next (steps 0-1) — Pay button is inside step 2
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
                    minimumSize: const Size(0, 48),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
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

// ── Step 0: Facility ─────────────────────────────────────────────────────────

class _FacilityStep extends StatelessWidget {
  const _FacilityStep({
    required this.slots,
    required this.loading,
    required this.selectedGroup,
    required this.selectedNetType,
    required this.durationMins,
    required this.onGroupTap,
    required this.onNetTypeTap,
    required this.onDurationChanged,
  });

  final ArenaSlots? slots;
  final bool loading;
  final UnitGroupSlots? selectedGroup;
  final String? selectedNetType;
  final int durationMins;
  final ValueChanged<UnitGroupSlots> onGroupTap;
  final ValueChanged<String> onNetTypeTap;
  final ValueChanged<int> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    if (loading && slots == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    final groups = slots?.unitGroups ?? [];
    if (groups.isEmpty) {
      return Center(
        child: Text(
          'No facilities available.',
          style: TextStyle(color: context.fgSub, fontSize: 13),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
      children: [
        _Label('Select facility'),
        const SizedBox(height: 8),
        for (final group in groups) ...[
          UnitGroupCard(
            group: group,
            durationMins: durationMins,
            selected: selectedGroup == group,
            onTap: () => onGroupTap(group),
          ),
          if (selectedGroup == group) ...[
            // Ground: fixed duration chips
            if (!group.isNetGroup) ...[
              const SizedBox(height: 14),
              _Label('Duration'),
              const SizedBox(height: 8),
              DurationPicker(
                selectedMins: durationMins,
                groups: [group],
                onChanged: onDurationChanged,
              ),
            ],
            // Nets: net type picker (only when >1 type)
            if (group.isNetGroup && group.netTypes.length > 1) ...[
              const SizedBox(height: 14),
              _Label('Net type'),
              const SizedBox(height: 8),
              _NetTypePicker(
                group: group,
                selected: selectedNetType,
                onChanged: onNetTypeTap,
              ),
            ],
          ],
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

// ── Step 1: Schedule ─────────────────────────────────────────────────────────

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
    required this.onDateChanged,
    required this.onSlotSelected,
    required this.onDurationChanged,
  });

  final ArenaSlots? slots;
  final bool loading;
  final DateTime selectedDate;
  final UnitGroupSlots selectedGroup;
  final AvailableSlot? selectedSlot;
  final String? selectedNetType;
  final int durationMins;
  final bool isNets;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<AvailableSlot> onSlotSelected;
  final ValueChanged<int> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
      children: [
        _Label('Date'),
        const SizedBox(height: 10),
        _DateStrip(
          selectedDate: selectedDate,
          maxDays: slots?.arena.advanceBookingDays ?? 14,
          onChanged: onDateChanged,
        ),
        // Nets only: variable duration stepper
        if (isNets) ...[
          const SizedBox(height: 20),
          _Label('Duration'),
          const SizedBox(height: 8),
          DurationPicker(
            selectedMins: durationMins,
            groups: [selectedGroup],
            onChanged: onDurationChanged,
          ),
        ],
        const SizedBox(height: 20),
        _Label('Start time'),
        const SizedBox(height: 12),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else
          SlotTimeGrid(
            group: selectedGroup,
            selectedSlot: selectedSlot,
            selectedNetType: selectedNetType,
            onSelected: onSlotSelected,
          ),
      ],
    );
  }
}

// ── Step 2: Confirm & Pay ────────────────────────────────────────────────────

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
    required this.onPay,
  });

  final ArenaInfo arena;
  final UnitGroupSlots group;
  final AvailableSlot slot;
  final DateTime date;
  final int durationMins;
  final String? selectedNetType;
  final int effectivePaise;
  final int payNowPaise;
  final bool booking;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final remainingPaise =
        (effectivePaise - payNowPaise).clamp(0, effectivePaise);
    final cancelUntil = DateTime(
      date.year,
      date.month,
      date.day,
      _h(slot.startTime),
      _m(slot.startTime),
    ).subtract(Duration(hours: arena.cancellationHours));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text(
          arena.name,
          style: TextStyle(
            color: context.fg,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          [
            DateFormat('EEE, d MMM').format(date),
            if (selectedNetType != null)
              '$selectedNetType Net'
            else
              group.displayName,
          ].join(' · '),
          style: TextStyle(
            color: context.fgSub,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        _ConfirmRow('Time', '${slot.startTime} – ${slot.endTime}'),
        _ConfirmRow('Duration', _dur(durationMins)),
        const SizedBox(height: 6),
        if (slot.isWeekendRate)
          _ConfirmRow(
            'Rate',
            'Weekend',
            accent: context.warn,
          ),
        _ConfirmRow('Total', _inr(effectivePaise), strong: true),
        if (group.minAdvancePaise > 0) ...[
          _ConfirmRow(
            'Pay now',
            _inr(payNowPaise),
            strong: true,
            accent: context.accent,
          ),
          _ConfirmRow('At venue', _inr(remainingPaise)),
        ] else
          _ConfirmRow('Full payment', _inr(effectivePaise), strong: true),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 13,
              color: context.fgSub.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Cancel free before ${DateFormat('HH:mm, d MMM').format(cancelUntil)}',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: booking ? null : onPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5F259F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: booking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'Pay ${_inr(payNowPaise)} with PhonePe',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }
}

// ── Step progress bar ────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  const _StepBar({required this.current, required this.labels});

  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.bg,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Column(
        children: [
          // Progress segments
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
          // Labels
          Row(
            children: List.generate(labels.length, (i) {
              final active = i == current;
              return Expanded(
                child: Text(
                  labels[i],
                  textAlign: i == 0
                      ? TextAlign.left
                      : i == labels.length - 1
                          ? TextAlign.right
                          : TextAlign.center,
                  style: TextStyle(
                    color: active ? context.fg : context.fgSub,
                    fontSize: 11,
                    fontWeight:
                        active ? FontWeight.w800 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// ── Net type picker ──────────────────────────────────────────────────────────

class _NetTypePicker extends StatelessWidget {
  const _NetTypePicker({
    required this.group,
    required this.selected,
    required this.onChanged,
  });

  final UnitGroupSlots group;
  final String? selected;
  final ValueChanged<String> onChanged;

  int? _priceFor(String type) {
    for (final s in group.availableSlots) {
      final opt =
          s.netTypeOptions.where((o) => o.netType == type).firstOrNull;
      if (opt != null) return opt.totalAmountPaise;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final type in group.netTypes)
          GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: selected == type
                    ? context.accent.withValues(alpha: 0.09)
                    : context.panel.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: selected == type
                    ? Border.all(
                        color: context.accent.withValues(alpha: 0.4),
                        width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$type Net',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (_priceFor(type) != null)
                    Text(
                      _inr(_priceFor(type)!),
                      style: TextStyle(
                        color: selected == type ? context.accent : context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Icon(
                    selected == type
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected == type
                        ? context.accent
                        : context.fgSub.withValues(alpha: 0.35),
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

// ── Photo hero ───────────────────────────────────────────────────────────────

class _PhotoHero extends StatefulWidget {
  const _PhotoHero({
    required this.photos,
    required this.arena,
    required this.pageNotifier,
  });

  final List<String> photos;
  final ArenaInfo? arena;
  final ValueNotifier<int> pageNotifier;

  @override
  State<_PhotoHero> createState() => _PhotoHeroState();
}

class _PhotoHeroState extends State<_PhotoHero> {
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController();
    _ctrl.addListener(() {
      final page = _ctrl.page?.round() ?? 0;
      if (widget.pageNotifier.value != page) widget.pageNotifier.value = page;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    final arena = widget.arena;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (photos.isEmpty)
          ColoredBox(
            color: context.panel,
            child: Icon(
              Icons.stadium_rounded,
              color: context.fgSub.withValues(alpha: 0.25),
              size: 64,
            ),
          )
        else
          PageView.builder(
            controller: _ctrl,
            itemCount: photos.length,
            itemBuilder: (_, i) => Image.network(
              photos[i],
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : ColoredBox(color: context.panel, child: const SizedBox()),
              errorBuilder: (_, __, ___) => ColoredBox(
                color: context.panel,
                child: Icon(
                  Icons.stadium_rounded,
                  color: context.fgSub.withValues(alpha: 0.25),
                  size: 64,
                ),
              ),
            ),
          ),
        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.72),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
        ),
        // Arena name + city
        if (arena != null)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  arena.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: Colors.white60, size: 12),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        arena.city.isNotEmpty ? arena.city : arena.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        // Page dots
        if (photos.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: widget.pageNotifier,
              builder: (_, page, __) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  photos.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == page ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == page
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Date strip ───────────────────────────────────────────────────────────────

class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.selectedDate,
    required this.maxDays,
    required this.onChanged,
  });

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
          final date =
              DateTime(today.year, today.month, today.day + index);
          final selected = _sameDay(date, selectedDate);
          final label = switch (index) {
            0 => 'Today',
            1 => 'Tmrw',
            _ => DateFormat('EEE').format(date),
          };
          return GestureDetector(
            onTap: () => onChanged(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 76,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? context.accent
                    : context.panel.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : context.fg,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('d MMM').format(date),
                    style: TextStyle(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.75)
                          : context.fgSub,
                      fontSize: 10,
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

// ── Small widgets ────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: context.fgSub,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow(this.label, this.value,
      {this.strong = false, this.accent});
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
          Text(
            label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: accent ?? context.fg,
              fontSize: strong ? 15 : 13,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _inr(int paise) => '₹${(paise / 100).toStringAsFixed(0)}';

String _dur(int mins) {
  if (mins < 60) return '${mins}min';
  final h = mins ~/ 60;
  final m = mins % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

int _h(String time) => int.tryParse(time.split(':').first) ?? 0;

int _m(String time) {
  final parts = time.split(':');
  return parts.length < 2 ? 0 : (int.tryParse(parts[1]) ?? 0);
}
