import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart'
    show hostArenaBookingRepositoryProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../data/player_booking_repository.dart';
import '../domain/booking_models.dart';

enum BookingDuration { hr1, hr4, hr8, fullDay }

class ArenaDetailScreen extends ConsumerStatefulWidget {
  const ArenaDetailScreen(
      {super.key, required this.arenaId, this.initialArena});

  final String arenaId;
  final ArenaListing? initialArena;

  @override
  ConsumerState<ArenaDetailScreen> createState() => _ArenaDetailScreenState();
}

class _ArenaDetailScreenState extends ConsumerState<ArenaDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  ArenaUnitOption? _selectedUnit;
  BookingDuration _selectedDuration = BookingDuration.hr1;
  AvailabilitySlot? _selectedStartSlot;
  final Set<ArenaAddon> _selectedAddons = {};
  late final Razorpay _razorpay;

  ArenaListing? _arena;
  PlayerSlotsData? _playerSlots;
  List<ArenaAddon> _addons = [];
  bool _loadingArena = false;
  bool _loadingAvailability = false;
  bool _bookingInProgress = false;
  String? _pendingBookingId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    _loadAddons();
    _arena = widget.initialArena;
    if (_arena != null) {
      _configureInitialUnit(_arena!);
    } else {
      _loadArena();
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadAddons() async {
    try {
      final addons = await ref
          .read(hostArenaBookingRepositoryProvider)
          .fetchArenaAddons(widget.arenaId);
      if (!mounted) return;
      setState(() {
        _addons = addons;
      });
    } catch (_) {
      if (!mounted) return;
    }
  }

  Future<void> _loadArena() async {
    setState(() => _loadingArena = true);
    try {
      final arena = await ref
          .read(hostArenaBookingRepositoryProvider)
          .fetchArenaDetail(widget.arenaId);
      if (!mounted) return;
      setState(() {
        _arena = arena;
        _loadingArena = false;
      });
      _configureInitialUnit(arena);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingArena = false);
    }
  }

  void _configureInitialUnit(ArenaListing arena) {
    if (arena.units.isEmpty) return;
    setState(() {
      _selectedUnit = arena.units.first;
      _selectedDuration = _durationForMinutes(_selectedUnit!.minSlotMins);
    });
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    if (_selectedUnit == null) return;
    setState(() => _loadingAvailability = true);
    try {
      final slots =
          await ref.read(hostArenaBookingRepositoryProvider).fetchPlayerSlots(
                arenaId: widget.arenaId,
                date: _selectedDate,
                durationMins: _durationMins,
              );
      if (!mounted) return;
      setState(() {
        _playerSlots = slots;
        _loadingAvailability = false;
        _selectedStartSlot = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingAvailability = false);
    }
  }

  int get _durationHrs {
    switch (_selectedDuration) {
      case BookingDuration.hr1:
        return 1;
      case BookingDuration.hr4:
        return 4;
      case BookingDuration.hr8:
        return 8;
      case BookingDuration.fullDay:
        return 12;
    }
  }

  int get _durationMins => _durationHrs * 60;

  BookingDuration _durationForMinutes(int mins) {
    if (mins <= 60) return BookingDuration.hr1;
    if (mins <= 240) return BookingDuration.hr4;
    if (mins <= 480) return BookingDuration.hr8;
    return BookingDuration.fullDay;
  }

  ArenaBookingQuote get _pricingQuote {
    if (_selectedUnit == null) {
      return const ArenaBookingQuote(
        baseAmountPaise: 0,
        addonAmountPaise: 0,
        gstPaise: 0,
        totalAmountPaise: 0,
        durationMins: 0,
      );
    }

    final addons = _selectedAddons
        .map((addon) => ArenaSelectedAddon(
              id: addon.id,
              name: addon.name,
              pricePaise: addon.pricePaise,
              unit: addon.unit,
            ))
        .toList();
    // Use backend-computed price when available (already includes weekend + block pricing)
    final precomputed = _selectedStartSlot?.totalSlotPaise;
    return ArenaBookingPricing.quote(
      unit: _selectedUnit!,
      start: _quoteStartDateTime(),
      durationMins: _durationMins,
      addons: addons,
      precomputedBasePaise: precomputed,
    );
  }

  double get _basePrice => _pricingQuote.baseAmountPaise / 100;

  double get _addonTotal => _pricingQuote.addonAmountPaise / 100;

  double get _gst => _pricingQuote.gstPaise / 100;

  double get _grandTotal => _pricingQuote.totalAmountPaise / 100;

  bool get _isGroundUnit {
    final unit = _selectedUnit;
    if (unit == null) return false;
    final t = unit.unitType;
    if (t == 'FULL_GROUND' || t == 'HALF_GROUND') return true;
    // Ground units always have min 4h slots — reliable proxy when unitType is missing
    if (unit.minSlotMins >= 240) return true;
    // Also check PlayerUnitGroup data from slots response
    final slotsData = _playerSlots;
    if (slotsData != null) {
      final group = slotsData.unitGroups
          .where((g) => g.groupKey == unit.id || g.unitId == unit.id)
          .firstOrNull;
      if (group != null) {
        if (group.unitType == 'FULL_GROUND' || group.unitType == 'HALF_GROUND') return true;
        if (group.minSlotMins >= 240) return true;
      }
    }
    return false;
  }

  int get _unitMinAdvancePaise {
    final slotsData = _playerSlots;
    final unit = _selectedUnit;
    if (slotsData != null && unit != null) {
      final isNet =
          unit.unitType == 'CRICKET_NET' || unit.unitType == 'INDOOR_NET';
      final group = isNet
          ? slotsData.unitGroups.where((g) => g.isNetsGroup).firstOrNull
          : slotsData.unitGroups
              .where((g) => g.groupKey == unit.id || g.unitId == unit.id)
              .firstOrNull;
      if (group != null) return group.minAdvancePaise;
    }
    return unit?.minAdvancePaise ?? 0;
  }

  DateTime _quoteStartDateTime() {
    final slot = _selectedStartSlot;
    if (slot == null) return _selectedDate;
    final raw = slot.startTime.trim();
    final time = raw.contains('AM') || raw.contains('PM')
        ? DateFormat('h:mm a').parse(raw)
        : DateFormat('HH:mm').parse(raw);
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      time.hour,
      time.minute,
    );
  }

  List<AvailabilitySlot> _selectableSlots(ArenaListing arena) {
    final unit = _selectedUnit;
    if (unit == null) return const [];
    final slotsData = _playerSlots;
    if (slotsData == null) return const [];

    final isNet =
        unit.unitType == 'CRICKET_NET' || unit.unitType == 'INDOOR_NET';
    PlayerUnitGroup? group;
    if (isNet) {
      group = slotsData.unitGroups
          .where((g) => g.isNetsGroup)
          .firstOrNull;
    } else {
      group = slotsData.unitGroups
          .where((g) => g.groupKey == unit.id || g.unitId == unit.id)
          .firstOrNull;
    }
    if (group == null) return const [];

    return group.availableSlots.map((s) {
      final perHour = _durationMins > 0
          ? (s.totalAmountPaise * 60 / _durationMins).round()
          : unit.pricePerHourPaise;
      return AvailabilitySlot(
        startTime: s.startTime,
        endTime: s.endTime,
        available: true,
        pricePerHourPaise: perHour,
        totalSlotPaise: s.totalAmountPaise,
        assignedUnitId: s.assignedUnitId,
      );
    }).toList();
  }

  int _toMins(String value) {
    final raw = value.trim();
    try {
      final dt =
          raw.toUpperCase().contains('AM') || raw.toUpperCase().contains('PM')
              ? DateFormat('h:mm a').parse(raw)
              : DateFormat('HH:mm').parse(raw);
      return dt.hour * 60 + dt.minute;
    } catch (_) {
      return 0;
    }
  }

  String _timeAfter(String startTime, int minutes) {
    final total = _toMins(startTime) + minutes;
    final hour = (total ~/ 60).toString().padLeft(2, '0');
    final minute = (total % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  AvailabilitySlot? _matchSelectedSlot(List<AvailabilitySlot> slots) {
    final selected = _selectedStartSlot;
    if (selected == null) return null;
    for (final slot in slots) {
      if (slot.startTime == selected.startTime &&
          slot.endTime == selected.endTime) {
        return slot;
      }
    }
    for (final slot in slots) {
      if (slot.startTime == selected.startTime) return slot;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final arena = _arena;
    if (arena == null || _loadingArena) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final locality = arena.address.split(',').first.trim();
    final selectableSlots = _selectableSlots(arena);
    final selectedStartSlot = _matchSelectedSlot(selectableSlots);

    return Scaffold(
      backgroundColor: context.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _SliverHeader(arena: arena),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 180 + MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(arena.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: context.fg,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1)),
                            const SizedBox(height: 4),
                            Text(locality.toUpperCase(),
                                style: TextStyle(
                                    color: context.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1)),
                          ],
                        ),
                      ),
                      _RatingBadge(),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _AmenitiesSection(arena: arena),
                  const SizedBox(height: 40),
                  _sectionTitle('1. CHOOSE YOUR COURT'),
                  const SizedBox(height: 16),
                  _UnitSelector(
                    units: arena.units,
                    selectedId: _selectedUnit?.id,
                    onSelect: (unit) {
                      setState(() {
                        _selectedUnit = unit;
                        _selectedDuration =
                            _durationForMinutes(unit.minSlotMins);
                        _selectedStartSlot = null;
                        _selectedAddons.clear();
                      });
                      _loadAvailability();
                    },
                  ),
                  const SizedBox(height: 40),
                  _sectionTitle('2. SELECT DURATION'),
                  const SizedBox(height: 16),
                  _DurationSelector(
                    selected: _selectedDuration,
                    unit: _selectedUnit,
                    isGround: _isGroundUnit,
                    onSelect: (d) {
                      final unit = _selectedUnit;
                      final mins = _durationMinsFor(d);
                      if (unit != null && mins < unit.minSlotMins) {
                        _showSnack(
                            'Minimum booking is ${unit.minSlotMins ~/ 60}hr');
                        return;
                      }
                      if (unit != null && mins > unit.maxSlotMins) {
                        _showSnack('Max ${unit.maxSlotMins ~/ 60}hr booking');
                        return;
                      }
                      setState(() {
                        _selectedDuration = d;
                        _selectedStartSlot = null;
                      });
                      _loadAvailability();
                    },
                  ),
                  const SizedBox(height: 40),
                  _sectionTitle('3. PICK DATE & START TIME'),
                  const SizedBox(height: 16),
                  _DatePicker(
                    selected: _selectedDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 14)),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _selectedStartSlot = null;
                        });
                        _loadAvailability();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _SlotPicker(
                    loading: _loadingAvailability,
                    slots: selectableSlots,
                    selected: selectedStartSlot,
                    onSelect: (s) => setState(() => _selectedStartSlot = s),
                    isGround: _isGroundUnit,
                  ),
                  const SizedBox(height: 40),
                  if ((_selectedUnit?.addons ?? _addons).isNotEmpty) ...[
                    _sectionTitle('4. ADD-ONS'),
                    const SizedBox(height: 16),
                    ...(_selectedUnit?.addons.isNotEmpty == true
                            ? _selectedUnit!.addons
                            : _addons)
                        .map((addon) => _AddonTile(
                              addon: addon,
                              isSelected: _selectedAddons.contains(addon),
                              onChanged: (v) => setState(() => v!
                                  ? _selectedAddons.add(addon)
                                  : _selectedAddons.remove(addon)),
                            )),
                  ],
                  const SizedBox(height: 40),
                  _sectionTitle('ABOUT ARENA'),
                  const SizedBox(height: 12),
                  Text(
                    arena.description.isNotEmpty
                        ? arena.description
                        : 'Welcome to ${arena.name}, Bhopal\'s premier sports destination. We offer high-quality ${arena.sports.join(', ')} facilities with professional standards.',
                    style: TextStyle(
                        color: context.fgSub,
                        fontSize: 15,
                        height: 1.6,
                        fontWeight: FontWeight.w500),
                  ),
                  if (_selectedUnit?.boundarySize != null) ...[
                    const SizedBox(height: 16),
                    _MetaRow(Icons.straighten_rounded, 'Boundary Size',
                        '${_selectedUnit!.boundarySize} Yards'),
                  ],
                  _MetaRow(Icons.timer_outlined, 'Booking Buffer',
                      '${arena.bufferMins} mins'),
                  _MetaRow(Icons.history_rounded, 'Cancellation',
                      'Up to ${arena.cancellationHours}h before'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: selectedStartSlot == null
          ? null
          : _BookingSummarySheet(
              base: _basePrice,
              addons: _addonTotal,
              gst: _gst,
              total: _grandTotal,
              durationMins: _durationMins,
              advancePaise: _unitMinAdvancePaise,
              onReserve: _showPaymentOptions,
              loading: _bookingInProgress,
            ),
    );
  }

  int _durationMinsFor(BookingDuration duration) {
    switch (duration) {
      case BookingDuration.hr1:
        return 60;
      case BookingDuration.hr4:
        return 240;
      case BookingDuration.hr8:
        return 480;
      case BookingDuration.fullDay:
        return 720;
    }
  }

  void _showPaymentOptions() {
    final unit = _selectedUnit;
    final slot = _selectedStartSlot;
    if (unit == null || slot == null) return;
    if (_durationMins < unit.minSlotMins) {
      _showSnack('Minimum booking is ${unit.minSlotMins ~/ 60}hr');
      return;
    }
    if (_durationMins > unit.maxSlotMins) {
      _showSnack('Max ${unit.maxSlotMins ~/ 60}hr booking');
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: context.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => _PaymentOptionsSheet(
        unitName: unit.name,
        date: _selectedDate,
        startTime: slot.startTime,
        endTime: _timeAfter(slot.startTime, _durationMins),
        base: _basePrice,
        gst: _gst,
        total: _grandTotal,
        advancePaise: _unitMinAdvancePaise,
        onCash: () => _processBooking(isCash: true),
        onOnline: () => _processBooking(isCash: false),
      ),
    );
  }

  Future<void> _processBooking({required bool isCash}) async {
    Navigator.pop(context);
    if (isCash) {
      _showSnack(
          'Online-only bookings supported. Walk-ins accepted at the arena.');
      return;
    }
    final unit = _selectedUnit;
    final slot = _selectedStartSlot;
    if (unit == null || slot == null) return;
    setState(() => _bookingInProgress = true);
    final repo = ref.read(playerBookingRepositoryProvider);
    final bookingDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final endTime = _timeAfter(slot.startTime, _durationMins);
    // Use assignedUnitId from the slot (important for NETS grouping where
    // the backend picks a specific net unit at slot-generation time).
    final effectiveUnitId =
        slot.assignedUnitId?.isNotEmpty == true ? slot.assignedUnitId! : unit.id;
    try {
      await repo.holdSlot(
        arenaUnitId: effectiveUnitId,
        bookingDate: bookingDate,
        startTime: slot.startTime,
        endTime: endTime,
      );
      if (!mounted) return;
      final confirmed = await _showHeldSlotSheet(
        unitName: unit.name,
        date: _selectedDate,
        startTime: slot.startTime,
        endTime: endTime,
      );
      if (confirmed != true) {
        if (mounted) setState(() => _bookingInProgress = false);
        return;
      }
      final booking = await repo.createBooking(
        arenaUnitId: effectiveUnitId,
        bookingDate: bookingDate,
        startTime: slot.startTime,
        endTime: endTime,
        totalPricePaise: _pricingQuote.totalAmountPaise,
      );
      _pendingBookingId = booking.id;
      final order = await repo.createPaymentOrder(booking.id);
      if (order.orderId.isEmpty || order.amountPaise <= 0) {
        throw Exception('Could not create payment order.');
      }
      _razorpay.open({
        'key': order.key,
        'amount': order.amountPaise,
        'currency': order.currency,
        'name': 'Swing Arena Booking',
        'description': '${_arena?.name ?? 'Arena'} - ${unit.name}',
        'order_id': order.orderId,
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _bookingInProgress = false);
      final msg = repo.messageFor(error, fallback: 'Could not start booking.');
      // If the slot was just taken by another user, refresh so the UI reflects reality
      if (msg.toLowerCase().contains('already booked') ||
          msg.toLowerCase().contains('too soon') ||
          msg.toLowerCase().contains('slot')) {
        setState(() => _selectedStartSlot = null);
        _loadAvailability();
      }
      _showSnack(msg);
    }
  }

  Future<bool?> _showHeldSlotSheet({
    required String unitName,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: context.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _HeldSlotSheet(
        unitName: unitName,
        date: date,
        startTime: startTime,
        endTime: endTime,
        base: _basePrice,
        gst: _gst,
        total: _grandTotal,
        advancePaise: _unitMinAdvancePaise,
      ),
    );
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    final bookingId = _pendingBookingId;
    if (bookingId == null) return;
    try {
      final booking =
          await ref.read(playerBookingRepositoryProvider).verifyPayment(
                bookingId: bookingId,
                razorpayPaymentId: response.paymentId ?? '',
                razorpayOrderId: response.orderId ?? '',
                razorpaySignature: response.signature ?? '',
              );
      if (!mounted) return;
      setState(() => _bookingInProgress = false);
      context.go('/booking/success', extra: booking);
    } catch (error) {
      if (!mounted) return;
      setState(() => _bookingInProgress = false);
      _showSnack(ref.read(playerBookingRepositoryProvider).messageFor(
            error,
            fallback: 'Payment verification failed.',
          ));
      context.push('/bookings/$bookingId');
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (mounted) setState(() => _bookingInProgress = false);
    final message = response.message?.trim().isNotEmpty == true
        ? response.message!.trim()
        : 'Payment was not completed.';
    _showSnack(message);
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    _showSnack('${response.walletName ?? 'Wallet'} selected');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5));
  }
}

// ── Supporting Components ───────────────────────────────────────────────────

class _RatingBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: context.panel.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.star_rounded, color: context.gold, size: 18),
          const SizedBox(width: 4),
          Text('4.8',
              style: TextStyle(
                  color: context.fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _AmenitiesSection extends StatelessWidget {
  const _AmenitiesSection({required this.arena});
  final ArenaListing arena;

  @override
  Widget build(BuildContext context) {
    final list = [
      if (arena.hasParking) (Icons.local_parking_rounded, 'Parking'),
      if (arena.hasLights) (Icons.lightbulb_rounded, 'Lights'),
      if (arena.hasWashrooms) (Icons.wc_rounded, 'Washroom'),
      if (arena.hasCanteen) (Icons.restaurant_rounded, 'Canteen'),
      if (arena.hasCCTV) (Icons.videocam_rounded, 'CCTV'),
      if (arena.hasScorer) (Icons.edit_note_rounded, 'Digital Scorer'),
    ];

    if (list.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AMENITIES',
            style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: list
              .map((a) => Column(
                    children: [
                      Icon(a.$1, color: context.fgSub, size: 24),
                      const SizedBox(height: 4),
                      Text(a.$2,
                          style: TextStyle(
                              color: context.fgSub,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _UnitSelector extends StatelessWidget {
  const _UnitSelector(
      {required this.units, this.selectedId, required this.onSelect});
  final List<ArenaUnitOption> units;
  final String? selectedId;
  final ValueChanged<ArenaUnitOption> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: units.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final unit = units[i];
          final isSelected = selectedId == unit.id;
          final cardWidth = (MediaQuery.of(context).size.width * 0.38).clamp(120.0, 180.0);
          return GestureDetector(
            onTap: () => onSelect(unit),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: cardWidth,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.accent
                    : context.panel.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isSelected
                        ? context.accent
                        : context.stroke.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(unit.name,
                      style: TextStyle(
                          color: isSelected ? Colors.white : context.fg,
                          fontWeight: FontWeight.w800,
                          fontSize: 14),
                      maxLines: 1),
                  const SizedBox(height: 2),
                  Text(unit.unitType.split('_').first,
                      style: TextStyle(
                          color: isSelected ? Colors.white70 : context.fgSub,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DurationSelector extends StatelessWidget {
  const _DurationSelector({
    required this.selected,
    required this.unit,
    required this.onSelect,
    this.isGround = false,
  });
  final BookingDuration selected;
  final ArenaUnitOption? unit;
  final ValueChanged<BookingDuration> onSelect;
  final bool isGround;

  @override
  Widget build(BuildContext context) {
    const all = [
      ('1h', BookingDuration.hr1, 60),
      ('4h', BookingDuration.hr4, 240),
      ('8h', BookingDuration.hr8, 480),
      ('Day', BookingDuration.fullDay, 720),
    ];
    final visible = all.where((item) {
      final mins = item.$3;
      if (unit == null) return true;
      return mins >= unit!.minSlotMins && mins <= unit!.maxSlotMins;
    }).toList();

    return Row(
      children: visible.map((item) {
        final isSelected = selected == item.$2;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(item.$2),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Colors.grey.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(item.$1,
                    style: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.w900,
                        fontSize: 13)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({required this.selected, required this.onTap});
  final DateTime selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: context.panel.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.stroke.withOpacity(0.1))),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: context.accent, size: 18),
            const SizedBox(width: 12),
            Text(DateFormat('EEEE, d MMMM').format(selected),
                style: TextStyle(
                    color: context.fg,
                    fontWeight: FontWeight.w800,
                    fontSize: 15)),
            const Spacer(),
            const Icon(Icons.expand_more_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _SlotPicker extends StatelessWidget {
  const _SlotPicker({
    required this.loading,
    required this.slots,
    this.selected,
    required this.onSelect,
    this.isGround = false,
  });
  final bool loading;
  final List<AvailabilitySlot> slots;
  final AvailabilitySlot? selected;
  final ValueChanged<AvailabilitySlot> onSelect;
  final bool isGround;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (slots.isEmpty) {
      return const Text('No slots available.',
          style: TextStyle(color: Colors.grey, fontSize: 13));
    }

    if (isGround) {
      return Column(
        children: slots.map((s) {
          final isSel = selected == s;
          final period = _slotPeriod(s.startTime);
          final icon = _slotPeriodIcon(s.startTime);
          final price = s.totalSlotPaise != null
              ? '₹${(s.totalSlotPaise! / 100).toStringAsFixed(0)}'
              : '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => onSelect(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSel ? context.accent : context.panel.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: isSel ? context.accent : context.stroke.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Icon(icon,
                        color: isSel ? Colors.white : context.accent, size: 20),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(period,
                              style: TextStyle(
                                  color: isSel ? Colors.white : context.fg,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(
                              '${_fmt12h(s.startTime)} – ${_fmt12h(s.endTime)}',
                              style: TextStyle(
                                  color: isSel
                                      ? Colors.white.withOpacity(0.8)
                                      : context.fgSub,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (price.isNotEmpty)
                      Text(price,
                          style: TextStyle(
                              color: isSel ? Colors.white : context.fg,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((s) {
        final isSelected = selected == s;
        final isAvail = s.available;
        return GestureDetector(
          onTap: isAvail ? () => onSelect(s) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.accent
                  : (isAvail
                      ? context.panel.withOpacity(0.3)
                      : context.panel.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isSelected ? context.accent : Colors.transparent),
            ),
            child: Text(_fmt12h(s.startTime),
                style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isAvail ? context.fg : Colors.grey.withOpacity(0.3)),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    decoration: isAvail ? null : TextDecoration.lineThrough)),
          ),
        );
      }).toList(),
    );
  }
}

class _AddonTile extends StatelessWidget {
  const _AddonTile(
      {required this.addon, required this.isSelected, required this.onChanged});
  final ArenaAddon addon;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: isSelected,
      onChanged: onChanged,
      title: Text(addon.name,
          style: TextStyle(
              color: context.fg, fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text(
          '₹${(addon.pricePaise / 100).toStringAsFixed(0)} / session',
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
      activeColor: context.accent,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.accent),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  color: context.fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SliverHeader extends StatelessWidget {
  const _SliverHeader({required this.arena});
  final ArenaListing arena;

  @override
  Widget build(BuildContext context) {
    final imageUrl = arena.photoUrls.isNotEmpty ? arena.photoUrls.first : null;
    return SliverAppBar(
      expandedHeight: (MediaQuery.of(context).size.height * 0.38).clamp(220, 360),
      backgroundColor: context.bg,
      pinned: true,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.3),
          child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => context.pop()),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: imageUrl != null
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : Container(color: context.panel),
      ),
    );
  }
}

class _BookingSummarySheet extends StatelessWidget {
  const _BookingSummarySheet({
    required this.base,
    required this.addons,
    required this.gst,
    required this.total,
    required this.durationMins,
    required this.advancePaise,
    required this.loading,
    required this.onReserve,
  });
  final double base, addons, gst, total;
  final int durationMins;
  final int advancePaise;
  final bool loading;
  final VoidCallback onReserve;

  String get _durationLabel {
    if (durationMins >= 720) return 'FULL DAY';
    final hrs = durationMins ~/ 60;
    return 'FOR $hrs HOUR${hrs == 1 ? '' : 'S'}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 40 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: context.bg,
        border: Border(top: BorderSide(color: context.stroke.withOpacity(0.3))),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, -10))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _summaryRow('Subtotal', '₹${(base + addons).toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          _summaryRow('GST (18%)', '₹${gst.toStringAsFixed(2)}'),
          if (advancePaise > 0) ...[
            const SizedBox(height: 4),
            _summaryRow(
              'Advance required',
              '₹${(advancePaise / 100).toStringAsFixed(0)}',
              highlight: true,
            ),
          ],
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('₹${total.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: context.fg,
                            fontSize: 24,
                            fontWeight: FontWeight.w900)),
                    Text(_durationLabel,
                        style: TextStyle(
                            color: context.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: loading ? null : onReserve,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(160, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Reserve Now',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String val, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: highlight ? Colors.orange : Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        Text(val,
            style: TextStyle(
                color: highlight ? Colors.orange : Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _PaymentOptionsSheet extends StatelessWidget {
  const _PaymentOptionsSheet({
    required this.unitName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.base,
    required this.gst,
    required this.total,
    required this.advancePaise,
    required this.onCash,
    required this.onOnline,
  });
  final String unitName;
  final DateTime date;
  final String startTime, endTime;
  final double base, gst, total;
  final int advancePaise;
  final VoidCallback onCash, onOnline;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: _Handle()),
            const SizedBox(height: 24),
            Text('Confirm Booking',
                style: TextStyle(
                    color: context.fg,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text(
                '$unitName • ${DateFormat('d MMM').format(date)} • $startTime-$endTime',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 18),
            _sheetRow('Base', '₹${base.toStringAsFixed(2)}'),
            _sheetRow('GST', '₹${gst.toStringAsFixed(2)}'),
            _sheetRow('Total', '₹${total.toStringAsFixed(2)}', strong: true),
            if (advancePaise > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Advance of ₹${(advancePaise / 100).toStringAsFixed(0)} required at booking',
                      style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            _PaymentTile(
                icon: Icons.flash_on_rounded,
                title: 'Pay Online',
                subtitle: 'UPI, Card, Netbanking',
                onTap: onOnline),
            const SizedBox(height: 12),
            _PaymentTile(
                icon: Icons.payments_rounded,
                title: 'Pay at Arena',
                subtitle: 'Pay via Cash or UPI at venue',
                onTap: onCash),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sheetRow(String label, String value, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: strong ? FontWeight.w900 : FontWeight.w600)),
          Text(value,
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: strong ? FontWeight.w900 : FontWeight.w700)),
        ],
      ),
    );
  }
}

class _HeldSlotSheet extends StatelessWidget {
  const _HeldSlotSheet({
    required this.unitName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.base,
    required this.gst,
    required this.total,
    required this.advancePaise,
  });

  final String unitName;
  final DateTime date;
  final String startTime, endTime;
  final double base, gst, total;
  final int advancePaise;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: _Handle()),
            const SizedBox(height: 22),
            Text('Slot held for 10 min',
                style: TextStyle(
                    color: context.fg,
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              '$unitName • ${DateFormat('EEEE, d MMM').format(date)} • $startTime-$endTime',
              style: TextStyle(
                  color: context.fgSub,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 22),
            _HeldRow('Base', '₹${base.toStringAsFixed(2)}'),
            _HeldRow('GST', '₹${gst.toStringAsFixed(2)}'),
            _HeldRow('Total', '₹${total.toStringAsFixed(2)}', strong: true),
            if (advancePaise > 0) ...[
              const SizedBox(height: 8),
              _HeldRow('Advance required', '₹${(advancePaise / 100).toStringAsFixed(0)}', accent: true),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.accent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeldRow extends StatelessWidget {
  const _HeldRow(this.label, this.value, {this.strong = false, this.accent = false});
  final String label, value;
  final bool strong;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ? Colors.orange : (strong ? context.fg : context.fgSub);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: strong || accent ? FontWeight.w700 : FontWeight.w600)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: strong || accent ? FontWeight.w900 : FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();
  @override
  Widget build(BuildContext context) => Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2)));
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: context.panel.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.stroke.withOpacity(0.1))),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: context.accent.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(icon, color: context.accent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: context.fg,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                  Text(subtitle,
                      style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }
}

// ─── Ground slot period helpers ──────────────────────────────────────────────

String _slotPeriod(String hhmm) {
  final h = int.tryParse(hhmm.split(':').first) ?? 0;
  if (h < 4) return 'Late Night';
  if (h < 12) return 'Morning';
  if (h < 16) return 'Afternoon';
  if (h < 20) return 'Evening';
  return 'Night';
}

IconData _slotPeriodIcon(String hhmm) {
  final h = int.tryParse(hhmm.split(':').first) ?? 0;
  if (h < 4) return Icons.bedtime_rounded;
  if (h < 12) return Icons.wb_sunny_rounded;
  if (h < 16) return Icons.wb_cloudy_rounded;
  if (h < 20) return Icons.wb_twilight_rounded;
  return Icons.nights_stay_rounded;
}

String _fmt12h(String hhmm) {
  final parts = hhmm.split(':');
  final h = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
  final suffix = h < 12 ? 'am' : 'pm';
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  return m == 0 ? '$h12$suffix' : '$h12:${m.toString().padLeft(2, '0')}$suffix';
}
