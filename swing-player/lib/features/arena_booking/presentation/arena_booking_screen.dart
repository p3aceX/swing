import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../data/arena_slots_repository.dart';
import '../domain/arena_slots_models.dart';
import 'widgets/booking_confirm_sheet.dart';
import 'widgets/duration_picker.dart';
import 'widgets/slot_time_grid.dart';
import 'widgets/unit_group_card.dart';

class ArenaBookingScreen extends ConsumerStatefulWidget {
  const ArenaBookingScreen({
    super.key,
    required this.arenaId,
    this.initialDate,
  });

  final String arenaId;
  final DateTime? initialDate;

  @override
  ConsumerState<ArenaBookingScreen> createState() => _ArenaBookingScreenState();
}

class _ArenaBookingScreenState extends ConsumerState<ArenaBookingScreen> {
  late final Razorpay _razorpay;
  late DateTime _selectedDate;
  int _durationMins = 60;
  UnitGroupSlots? _selectedGroup;
  AvailableSlot? _selectedSlot;
  String? _selectedNetType;
  ArenaSlots? _slots;
  bool _loading = false;
  bool _booking = false;
  int _requestId = 0;

  final _photoPageNotifier = ValueNotifier<int>(0);

  SlotHold? _pendingHold;
  String? _pendingUnitId;
  int? _pendingPayNowPaise;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    _load();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _photoPageNotifier.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    final previousGroupKey = _selectedGroup?.groupKey;
    setState(() {
      _loading = true;
      _selectedSlot = null;
    });
    try {
      final slots = await ref
          .read(arenaSlotsRepositoryProvider)
          .getArenaSlots(widget.arenaId, _selectedDate, _durationMins);
      if (!mounted || requestId != _requestId) return;

      debugPrint('[Booking] duration=$_durationMins  groups=${slots.unitGroups.length}');
      for (final g in slots.unitGroups) {
        debugPrint(
          '[Booking]   group=${g.groupKey} displayName=${g.displayName} '
          'minSlot=${g.minSlotMins} maxSlot=${g.maxSlotMins} '
          'isNet=${g.isNetGroup} netTypes=${g.netTypes} '
          'slots=${g.availableSlots.length}',
        );
        if (g.availableSlots.isNotEmpty) {
          final s = g.availableSlots.first;
          debugPrint(
            '[Booking]     first slot ${s.startTime}-${s.endTime} '
            'amount=${s.totalAmountPaise} netOpts=${s.netTypeOptions.map((o) => '${o.netType}:${o.totalAmountPaise}').toList()}',
          );
        }
      }

      // Restore previously selected group from fresh data using groupKey
      final restoredGroup = previousGroupKey == null
          ? null
          : slots.unitGroups
              .where((g) => g.groupKey == previousGroupKey)
              .firstOrNull;

      setState(() {
        _slots = slots;
        _loading = false;
        _selectedGroup = restoredGroup;
        if (restoredGroup == null) _selectedNetType = null;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() => _loading = false);
      _showSnack(ref.read(arenaSlotsRepositoryProvider).messageFor(
            error,
            fallback: 'Could not load slots.',
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final slots = _slots;
    final arena = slots?.arena;
    final photos = arena?.photoUrls ?? const [];

    return Scaffold(
      backgroundColor: context.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: context.bg,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _CircleIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => context.pop(),
              ),
            ),
            actions: [
              if (arena?.phone != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CircleIconButton(
                    icon: Icons.phone_rounded,
                    onTap: () {},
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _PhotoHero(
                photos: photos,
                arena: arena,
                pageNotifier: _photoPageNotifier,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amenity badges
                if (arena != null) _AmenityRow(arena: arena),
                // Description
                if (arena?.description?.isNotEmpty == true) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(
                      arena!.description!,
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 13,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                _Divider(),
                const SizedBox(height: 22),
                _SectionLabel('Date'),
                const SizedBox(height: 12),
                _DateStrip(
                  selectedDate: _selectedDate,
                  maxDays: arena?.advanceBookingDays ?? 14,
                  onChanged: (date) {
                    setState(() => _selectedDate = date);
                    _load();
                  },
                ),
                const SizedBox(height: 26),
                _SectionLabel('Select facility'),
                const SizedBox(height: 8),
                if (_loading)
                  _UnitGroupSkeleton()
                else if (slots == null || slots.unitGroups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Text(
                      'No facilities available.',
                      style: TextStyle(color: context.fgSub, fontSize: 13),
                    ),
                  )
                else
                  for (final group in slots.unitGroups) ...[
                    UnitGroupCard(
                      group: group,
                      durationMins: _durationMins,
                      selected: _selectedGroup == group,
                      onTap: () {
                        if (_selectedGroup == group) {
                          setState(() {
                            _selectedGroup = null;
                            _selectedSlot = null;
                            _selectedNetType = null;
                          });
                        } else {
                          final newDuration = group.minSlotMins > 0
                              ? group.minSlotMins
                              : 60;
                          final needsReload = newDuration != _durationMins;
                          setState(() {
                            _selectedGroup = group;
                            _selectedSlot = null;
                            _durationMins = newDuration;
                            _selectedNetType = group.isNetGroup &&
                                    group.netTypes.isNotEmpty
                                ? group.netTypes.first
                                : null;
                          });
                          // _load() will restore _selectedGroup via groupKey match
                          if (needsReload) _load();
                        }
                      },
                    ),
                    // Duration picker — shown after facility is selected
                    if (_selectedGroup == group) ...[
                      const SizedBox(height: 16),
                      _SectionLabel('Duration'),
                      const SizedBox(height: 10),
                      DurationPicker(
                        selectedMins: _durationMins,
                        groups: [group],
                        onChanged: (mins) {
                          setState(() {
                            _durationMins = mins;
                            _selectedSlot = null;
                          });
                          _load();
                        },
                      ),
                    ],
                    // Net type picker — inline, right below duration
                    if (_selectedGroup == group &&
                        group.isNetGroup &&
                        group.netTypes.length > 1) ...[
                      const SizedBox(height: 16),
                      _InlineNetTypePicker(
                        group: group,
                        selected: _selectedNetType,
                        onChanged: (t) => setState(() {
                          _selectedNetType = t;
                          _selectedSlot = null;
                        }),
                      ),
                    ],
                    // Time grid — inline, below net picker (or duration if no net picker)
                    if (_selectedGroup == group &&
                        (!group.isNetGroup ||
                            group.netTypes.length <= 1 ||
                            _selectedNetType != null)) ...[
                      const SizedBox(height: 20),
                      _SectionLabel('Start time'),
                      const SizedBox(height: 12),
                      SlotTimeGrid(
                        group: group,
                        selectedSlot: _selectedSlot,
                        selectedNetType: _selectedNetType,
                        onSelected: (slot) =>
                            setState(() => _selectedSlot = slot),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        slot: _selectedSlot,
        group: _selectedGroup,
        durationMins: _durationMins,
        loading: _booking,
        onBook: _selectedSlot == null ? null : _showConfirmSheet,
      ),
    );
  }

  Future<void> _showConfirmSheet() async {
    final slots = _slots;
    final group = _selectedGroup;
    final slot = _selectedSlot;
    if (slots == null || group == null || slot == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BookingConfirmSheet(
        arena: slots.arena,
        group: group,
        slot: slot,
        date: _selectedDate,
        durationMins: _durationMins,
        loading: _booking,
        onConfirm: _bookSlot,
        selectedNetType: _selectedNetType,
      ),
    );
  }

  Future<void> _bookSlot() async {
    final slots = _slots;
    final group = _selectedGroup;
    final slot = _selectedSlot;
    if (slots == null || group == null || slot == null) return;

    // For nets, prefer the unit assigned to the chosen net type
    String? unitId;
    if (group.isNetGroup) {
      debugPrint('[Book] net group selectedNetType=$_selectedNetType slot netOpts=${slot.netTypeOptions.map((o) => '${o.netType}→${o.assignedUnitId}').toList()}');
      if (_selectedNetType != null) {
        unitId = slot.netTypeOptions
            .where((o) => o.netType == _selectedNetType)
            .map((o) => o.assignedUnitId)
            .firstOrNull;
      }
      unitId ??= slot.assignedUnitId;
    } else {
      unitId = group.unitId;
    }
    debugPrint('[Book] resolved unitId=$unitId  slot=${slot.startTime}-${slot.endTime}  group=${group.groupKey}');
    if (unitId == null || unitId.isEmpty) {
      _showSnack('Could not assign a unit for this slot.');
      return;
    }

    Navigator.of(context).pop();
    setState(() => _booking = true);
    final repo = ref.read(arenaSlotsRepositoryProvider);
    try {
      final hold = await repo.holdSlot(
        arenaId: widget.arenaId,
        unitId: unitId,
        date: _selectedDate,
        startTime: slot.startTime,
        endTime: slot.endTime,
      );
      final payNowPaise = group.minAdvancePaise > 0
          ? group.minAdvancePaise
          : slot.totalAmountPaise;
      final order = await repo.createPaymentOrder(payNowPaise);
      _pendingHold = hold;
      _pendingUnitId = unitId;
      _pendingPayNowPaise = payNowPaise;
      _razorpay.open({
        'key': order.key,
        'order_id': order.razorpayOrderId,
        'amount': payNowPaise,
        'currency': order.currency,
        'name': slots.arena.name,
        'description': '${group.displayName} · ${slot.startTime}',
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _booking = false);
      _showSnack(repo.messageFor(error, fallback: 'Could not start booking.'));
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse payment) async {
    final hold = _pendingHold;
    final unitId = _pendingUnitId;
    final payNowPaise = _pendingPayNowPaise;
    final group = _selectedGroup;
    final slot = _selectedSlot;
    if (hold == null ||
        unitId == null ||
        payNowPaise == null ||
        group == null ||
        slot == null) {
      setState(() => _booking = false);
      return;
    }
    try {
      final booking =
          await ref.read(arenaSlotsRepositoryProvider).createBooking(
                holdId: hold.holdId,
                unitId: unitId,
                date: _selectedDate,
                startTime: slot.startTime,
                endTime: slot.endTime,
                razorpayPaymentId: payment.paymentId ?? '',
                razorpayOrderId: payment.orderId ?? '',
                razorpaySignature: payment.signature ?? '',
                advancePaise: payNowPaise,
                totalAmountPaise: slot.totalAmountPaise,
              );
      if (!mounted) return;
      setState(() => _booking = false);
      context.go('/booking/success', extra: booking);
    } catch (error) {
      if (!mounted) return;
      setState(() => _booking = false);
      _showSnack(ref.read(arenaSlotsRepositoryProvider).messageFor(
            error,
            fallback: 'Payment captured, but booking confirmation failed.',
          ));
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (mounted) setState(() => _booking = false);
    _showSnack(response.message ?? 'Payment was not completed.');
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    _showSnack('${response.walletName ?? 'Wallet'} selected');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

// ── Photo hero ────────────────────────────────────────────────────────────────

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
        // Photo or placeholder
        if (photos.isEmpty)
          ColoredBox(
            color: context.panel,
            child: Icon(Icons.stadium_rounded,
                color: context.fgSub.withValues(alpha: 0.25), size: 64),
          )
        else
          PageView.builder(
            controller: _ctrl,
            itemCount: photos.length,
            itemBuilder: (_, i) => Image.network(
              photos[i],
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : ColoredBox(color: context.panel, child: const SizedBox()),
              errorBuilder: (_, __, ___) => ColoredBox(
                color: context.panel,
                child: Icon(Icons.stadium_rounded,
                    color: context.fgSub.withValues(alpha: 0.25), size: 64),
              ),
            ),
          ),
        // Bottom gradient + arena info
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.78),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
        ),
        // Arena name + city at bottom
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
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: Colors.white60, size: 13),
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
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        // Page indicator dots
        if (photos.length > 1)
          Positioned(
            bottom: 12,
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
                    width: i == page ? 18 : 6,
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

// ── Amenity row ───────────────────────────────────────────────────────────────

class _AmenityRow extends StatelessWidget {
  const _AmenityRow({required this.arena});
  final ArenaInfo arena;

  @override
  Widget build(BuildContext context) {
    final badges = [
      if (arena.hasParking) (Icons.local_parking_rounded, 'Parking'),
      if (arena.hasLights) (Icons.light_mode_rounded, 'Lights'),
      if (arena.hasWashrooms) (Icons.wc_rounded, 'Washrooms'),
      if (arena.hasCanteen) (Icons.restaurant_rounded, 'Canteen'),
      if (arena.hasCCTV) (Icons.videocam_rounded, 'CCTV'),
      if (arena.hasScorer) (Icons.scoreboard_rounded, 'Scorer'),
    ];
    if (badges.isEmpty) return const SizedBox(height: 20);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 16),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: badges.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final badge = badges[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: context.panel.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badge.$1, size: 13, color: context.accent),
                  const SizedBox(width: 5),
                  Text(
                    badge.$2,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Date strip ────────────────────────────────────────────────────────────────

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
          final date = DateTime(today.year, today.month, today.day + index);
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

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title.toUpperCase(),
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

// ── Flat divider ──────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: context.stroke.withValues(alpha: 0.3),
    );
  }
}

// ── Unit group skeleton ───────────────────────────────────────────────────────

class _UnitGroupSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.panel.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: context.panel.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 11,
                      width: 80,
                      decoration: BoxDecoration(
                        color: context.panel.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.slot,
    required this.group,
    required this.durationMins,
    required this.loading,
    required this.onBook,
  });

  final AvailableSlot? slot;
  final UnitGroupSlots? group;
  final int durationMins;
  final bool loading;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    final hasSelection = slot != null;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: context.bg,
          border: Border(
              top: BorderSide(color: context.stroke.withValues(alpha: 0.25))),
        ),
        child: Row(
          children: [
            Expanded(
              child: hasSelection
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currency(slot!.totalAmountPaise),
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '${slot!.startTime} – ${slot!.endTime}',
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Select a slot to continue',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      hasSelection ? context.accent : context.panel,
                  foregroundColor:
                      hasSelection ? Colors.white : context.fgSub,
                  minimumSize: const Size(136, 52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: hasSelection ? Colors.white : context.fgSub),
                      )
                    : const Text(
                        'Book Now',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Circle icon button (over photos) ─────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
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

// ── Net type sub-picker ───────────────────────────────────────────────────────

// ── Inline net type picker ────────────────────────────────────────────────────

class _InlineNetTypePicker extends StatelessWidget {
  const _InlineNetTypePicker({
    required this.group,
    required this.selected,
    required this.onChanged,
  });

  final UnitGroupSlots group;
  final String? selected;
  final ValueChanged<String> onChanged;

  int? _priceFor(String type) {
    for (final slot in group.availableSlots) {
      final opt =
          slot.netTypeOptions.where((o) => o.netType == type).firstOrNull;
      if (opt != null) return opt.totalAmountPaise;
    }
    return null;
  }

  int? _availableFor(String type) {
    int? best;
    for (final slot in group.availableSlots) {
      final opt =
          slot.netTypeOptions.where((o) => o.netType == type).firstOrNull;
      if (opt != null && (best == null || opt.availableCount > best)) {
        best = opt.availableCount;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final type in group.netTypes) ...[
          GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.fromLTRB(36, 0, 20, 0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
                  // Left accent line for selected
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$type Net',
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Builder(builder: (ctx) {
                          final avail = _availableFor(type);
                          final total = group.totalCount;
                          if (avail == null) return const SizedBox.shrink();
                          final scarce = avail <= 2;
                          final label = total != null
                              ? '$avail/$total free'
                              : '$avail available';
                          return Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              label,
                              style: TextStyle(
                                color:
                                    scarce ? context.warn : context.fgSub,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Builder(builder: (ctx) {
                    final price = _priceFor(type);
                    if (price == null) return const SizedBox.shrink();
                    return Text(
                      '₹${(price / 100).toStringAsFixed(0)}',
                      style: TextStyle(
                        color: selected == type
                            ? context.accent
                            : context.fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    );
                  }),
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
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _currency(int paise) => '₹${(paise / 100).toStringAsFixed(0)}';
