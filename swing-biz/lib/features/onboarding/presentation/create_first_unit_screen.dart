import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';

const _bg = Color(0xFFF3F4F6);
const _surface = Color(0xFFFFFFFF);
const _line = Color(0xFFE1E5EA);
const _text = Color(0xFF0D1117);
const _muted = Color(0xFF6E7685);
const _deep = Color(0xFF064E3B);
const _accent = Color(0xFF059669);

class CreateFirstUnitScreen extends ConsumerStatefulWidget {
  const CreateFirstUnitScreen({super.key, required this.arenaId});

  final String arenaId;

  @override
  ConsumerState<CreateFirstUnitScreen> createState() =>
      _CreateFirstUnitScreenState();
}

class _CreateFirstUnitScreenState extends ConsumerState<CreateFirstUnitScreen> {
  final _priceCtrl = TextEditingController();
  String _unitType = 'CRICKET_NET';
  int _quantity = 1;
  int _slotMins = 60;
  bool _saving = false;

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  String get _defaultLabel =>
      _unitType == 'FULL_GROUND' ? 'Full Ground' : 'Net';

  Future<void> _save() async {
    final priceRupees = int.tryParse(_priceCtrl.text.trim()) ?? 0;
    if (priceRupees <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid price')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(hostArenaBookingRepositoryProvider);
      final pricePaise = priceRupees * 100;
      for (var i = 0; i < _quantity; i++) {
        final name = _quantity == 1 ? _defaultLabel : '$_defaultLabel ${i + 1}';
        final input = {
          'name': name,
          'unitType': _unitType,
          'sport': 'CRICKET',
          'pricePerHourPaise': _unitType == 'FULL_GROUND'
              ? pricePaise ~/ 4
              : pricePaise,
          if (_unitType == 'FULL_GROUND') 'price4HrPaise': pricePaise,
          'minSlotMins': _slotMins,
          'maxSlotMins': _slotMins,
          'slotIncrementMins': _slotMins,
          'operatingDays': [1, 2, 3, 4, 5, 6, 7],
        };
        await repo.createArenaUnit(widget.arenaId, input);
      }
      if (mounted) context.go(AppRoutes.dashboard);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create unit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGround = _unitType == 'FULL_GROUND';
    final priceText = _priceCtrl.text.trim();
    final priceValid = int.tryParse(priceText) != null &&
        int.parse(priceText) > 0;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text(
          'Add your first unit',
          style: TextStyle(
            color: _text,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => context.go(AppRoutes.dashboard),
            child: const Text(
              'Skip',
              style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'A unit is what players book — a net, a ground, a box.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Unit type
                  _SectionLabel('Unit type'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _TypeTile(
                          label: 'Cricket Net',
                          icon: Icons.sports_cricket_rounded,
                          selected: _unitType == 'CRICKET_NET',
                          onTap: () => setState(() {
                            _unitType = 'CRICKET_NET';
                            _slotMins = 60;
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TypeTile(
                          label: 'Full Ground',
                          icon: Icons.grass_rounded,
                          selected: _unitType == 'FULL_GROUND',
                          onTap: () => setState(() {
                            _unitType = 'FULL_GROUND';
                            _slotMins = 240;
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quantity
                  _SectionLabel('How many?'),
                  const SizedBox(height: 10),
                  Row(
                    children: [1, 2, 3, 4].map((q) {
                      final selected = _quantity == q;
                      return Padding(
                        padding: EdgeInsets.only(right: q < 4 ? 8 : 0),
                        child: GestureDetector(
                          onTap: () => setState(() => _quantity = q),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 56,
                            height: 48,
                            decoration: BoxDecoration(
                              color: selected ? _deep : _surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? _deep : _line,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$q',
                              style: TextStyle(
                                color: selected ? Colors.white : _text,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Slot duration
                  _SectionLabel(
                    isGround ? 'Minimum booking duration' : 'Slot duration',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: isGround
                        ? [120, 240, 360].map((m) => _slotChip(m)).toList()
                        : [30, 60].map((m) => _slotChip(m)).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Price
                  _SectionLabel(
                    isGround ? 'Price for 4 hours (₹)' : 'Price per hour (₹)',
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    autofocus: false,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _text,
                    ),
                    decoration: InputDecoration(
                      hintText: isGround ? '2000' : '500',
                      prefixText: '₹ ',
                      prefixStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _muted,
                      ),
                      filled: true,
                      fillColor: _surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: _deep, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can add more units and update prices anytime.',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: _bg,
                border: Border(top: BorderSide(color: _line)),
              ),
              child: FilledButton(
                onPressed: !priceValid || _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _deep,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _quantity == 1
                            ? 'Add unit and go to dashboard'
                            : 'Add $_quantity units and go to dashboard',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotChip(int mins) {
    final selected = _slotMins == mins;
    final label = mins < 60
        ? '${mins}m'
        : mins == 60
            ? '1 hr'
            : '${mins ~/ 60} hr';
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _slotMins = mins),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _deep : _surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? _deep : _line),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : _text,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: _text,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      );
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _deep : _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _deep : _line),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? Colors.white : _deep,
                size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : _text,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: _accent, size: 18),
          ],
        ),
      ),
    );
  }
}
