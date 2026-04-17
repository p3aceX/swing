import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart'
    show hostArenaBookingRepositoryProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
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

  Map<String, List<AvailabilitySlot>> _availability = {};
  List<ArenaAddon> _addons = [];
  bool _loadingAvailability = false;

  @override
  void initState() {
    super.initState();
    _loadAddons();
    if (widget.initialArena != null && widget.initialArena!.units.isNotEmpty) {
      _selectedUnit = widget.initialArena!.units.first;
      _loadAvailability();
    }
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

  Future<void> _loadAvailability() async {
    if (_selectedUnit == null) return;
    setState(() => _loadingAvailability = true);
    try {
      final avail =
          await ref.read(hostArenaBookingRepositoryProvider).fetchAvailability(
                arenaId: widget.arenaId,
                date: _selectedDate,
              );
      if (!mounted) return;
      setState(() {
        _availability = avail;
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

    final start = _quoteStartDateTime();
    return ArenaBookingPricing.quote(
      unit: _selectedUnit!,
      start: start,
      durationMins: _durationHrs * 60,
      addons: _selectedAddons
          .map(
            (addon) => ArenaSelectedAddon(
              id: addon.id,
              name: addon.name,
              pricePaise: addon.pricePaise,
              unit: addon.unit,
            ),
          )
          .toList(),
    );
  }

  double get _basePrice => _pricingQuote.baseAmountPaise / 100;

  double get _addonTotal => _pricingQuote.addonAmountPaise / 100;

  double get _gst => _pricingQuote.gstPaise / 100;

  double get _grandTotal => _pricingQuote.totalAmountPaise / 100;

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
    final resolved = ArenaAvailabilityEngine.buildUnitSlots(
      date: _selectedDate,
      unit: unit,
      arenaOpenTime: arena.openTime,
      arenaCloseTime: arena.closeTime,
      apiSlots: _availability[unit.id] ?? const [],
    );
    return ArenaAvailabilityEngine.selectableStartSlots(
      slots: resolved,
      durationMins: _durationHrs * 60,
    );
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
    final arena = widget.initialArena;
    if (arena == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 180),
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
                                style: TextStyle(
                                    color: context.fg,
                                    fontSize: 28,
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
                        _selectedStartSlot = null;
                      });
                      _loadAvailability();
                    },
                  ),
                  const SizedBox(height: 40),
                  _sectionTitle('2. SELECT DURATION'),
                  const SizedBox(height: 16),
                  _DurationSelector(
                    selected: _selectedDuration,
                    onSelect: (d) => setState(() {
                      _selectedDuration = d;
                      _selectedStartSlot = null;
                    }),
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
                  ),
                  const SizedBox(height: 40),
                  if (_addons.isNotEmpty) ...[
                    _sectionTitle('4. ADD-ONS'),
                    const SizedBox(height: 16),
                    ..._addons.map((addon) => _AddonTile(
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
              duration: _durationHrs,
              onReserve: _showPaymentOptions,
            ),
    );
  }

  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => _PaymentOptionsSheet(
        total: _grandTotal,
        onCash: () => _processBooking(isCash: true),
        onOnline: () => _processBooking(isCash: false),
      ),
    );
  }

  Future<void> _processBooking({required bool isCash}) async {
    Navigator.pop(context);
    // TODO: Implement actual repository calls for booking
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isCash
            ? 'Booking requested (Pay at Arena)'
            : 'Redirecting to payment...')));
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
          return GestureDetector(
            onTap: () => onSelect(unit),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 150,
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
  const _DurationSelector({required this.selected, required this.onSelect});
  final BookingDuration selected;
  final ValueChanged<BookingDuration> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _durationChip('1h', BookingDuration.hr1),
        _durationChip('4h', BookingDuration.hr4),
        _durationChip('8h', BookingDuration.hr8),
        _durationChip('Day', BookingDuration.fullDay),
      ],
    );
  }

  Widget _durationChip(String label, BookingDuration d) {
    final isSelected = selected == d;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(d),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color:
                    isSelected ? Colors.white : Colors.grey.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.black : Colors.grey,
                    fontWeight: FontWeight.w900,
                    fontSize: 13)),
          ),
        ),
      ),
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
  const _SlotPicker(
      {required this.loading,
      required this.slots,
      this.selected,
      required this.onSelect});
  final bool loading;
  final List<AvailabilitySlot> slots;
  final AvailabilitySlot? selected;
  final ValueChanged<AvailabilitySlot> onSelect;

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(strokeWidth: 2)));
    if (slots.isEmpty)
      return const Text('No slots available.',
          style: TextStyle(color: Colors.grey, fontSize: 13));

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
            child: Text(s.startTime,
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
      expandedHeight: 320,
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
  const _BookingSummarySheet(
      {required this.base,
      required this.addons,
      required this.gst,
      required this.total,
      required this.duration,
      required this.onReserve});
  final double base, addons, gst, total;
  final int duration;
  final VoidCallback onReserve;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
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
                    Text('FOR $duration HOURS',
                        style: TextStyle(
                            color: context.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onReserve,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(160, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Reserve Now',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(val,
            style: const TextStyle(
                color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _PaymentOptionsSheet extends StatelessWidget {
  const _PaymentOptionsSheet(
      {required this.total, required this.onCash, required this.onOnline});
  final double total;
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
            Text('Final amount to pay: ₹${total.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 32),
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
