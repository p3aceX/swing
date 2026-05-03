import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ─── Team search model ────────────────────────────────────────────────────────

class _Team {
  const _Team({required this.id, required this.name, required this.city});
  final String id;
  final String name;
  final String city;

  factory _Team.fromJson(Map<String, dynamic> j) => _Team(
        id: j['id'] as String? ?? j['teamId'] as String? ?? '',
        name: j['name'] as String? ?? j['teamName'] as String? ?? '',
        city: j['city'] as String? ?? '',
      );
}

// ─── Split Booking Sheet ──────────────────────────────────────────────────────

class SplitBookingSheet extends ConsumerStatefulWidget {
  const SplitBookingSheet({
    super.key,
    required this.arena,
    required this.initialDate,
  });

  final ArenaListing arena;
  final DateTime initialDate;

  @override
  ConsumerState<SplitBookingSheet> createState() => _SplitBookingSheetState();
}

class _SplitBookingSheetState extends ConsumerState<SplitBookingSheet> {
  int _step = 0;

  // Step 1
  ArenaUnitOption? _unit;
  late DateTime _date;
  String? _slot;
  List<String> _slots = [];

  // Step 2
  String _format = 'T20';
  final _searchCtrl = TextEditingController();
  List<_Team> _teamResults = [];
  _Team? _team;
  bool _searching = false;

  // Submit
  bool _loading = false;
  String? _error;

  static const _formats = ['T10', 'T20', 'ODI', 'Test'];

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    if (widget.arena.units.isNotEmpty) {
      _unit = widget.arena.units.first;
      _rebuildSlots();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── slot generation (same logic as AddBookingSheet) ───────────────────────

  int _toMins(String t) {
    try {
      final p = t.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    } catch (_) {
      return 0;
    }
  }

  String _fromMins(int m) =>
      '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

  String _displaySlot(String t) {
    try {
      final p = t.split(':');
      final h = int.parse(p[0]);
      final min = p[1];
      final ampm = h < 12 ? 'AM' : 'PM';
      final hr = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$hr:$min $ampm';
    } catch (_) {
      return t;
    }
  }

  void _rebuildSlots() {
    final unit = _unit;
    if (unit == null) {
      setState(() => _slots = []);
      return;
    }
    final arena = widget.arena;
    final openMins = _toMins(unit.openTime ?? arena.openTime ?? '06:00');
    final closeMins = _toMins(unit.closeTime ?? arena.closeTime ?? '23:00');
    final durMins = unit.isGround ? 120 : 60;
    final increment =
        unit.isGround ? durMins : (unit.slotIncrementMins > 0 ? unit.slotIncrementMins : 60);

    final isToday = DateUtils.isSameDay(_date, DateTime.now());
    final nowMins = DateTime.now().hour * 60 + DateTime.now().minute;
    final buffer = arena.bufferMins;

    final slots = <String>[];
    for (var m = openMins; m + durMins <= closeMins; m += increment) {
      if (isToday && m < nowMins + buffer) continue;
      slots.add(_fromMins(m));
    }
    setState(() {
      _slots = slots;
      if (_slot != null && !slots.contains(_slot)) _slot = null;
    });
  }

  // ── team search ───────────────────────────────────────────────────────────

  Future<void> _searchTeams(String q) async {
    if (q.trim().length < 2) {
      setState(() => _teamResults = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final dio = ref.read(hostDioProvider);
      final resp = await dio.get(
        '/player/teams/search',
        queryParameters: {'q': q.trim(), 'limit': 20},
      );
      final body = resp.data;
      final raw = (body is Map)
          ? ((body['data'] ?? body)['teams'] ?? body['data'] ?? body)
          : body;
      final list = raw is List ? raw : [];
      setState(() {
        _teamResults =
            list.whereType<Map<String, dynamic>>().map(_Team.fromJson).toList();
        _searching = false;
      });
    } catch (_) {
      setState(() => _searching = false);
    }
  }

  // ── submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = ref.read(hostDioProvider);
      await dio.post(
        '/bookings/arena/${widget.arena.id}/split',
        data: {
          'unitId': _unit!.id,
          'date': DateFormat('yyyy-MM-dd').format(_date),
          'slotTime': _slot,
          'format': _format,
          'teamId': _team?.id,
          'teamName': _team?.name,
        },
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  // ── half price helper ─────────────────────────────────────────────────────

  String get _halfPriceLabel {
    final unit = _unit;
    if (unit == null) return '';
    final half = unit.pricePerHourPaise ~/ 2;
    return '₹${(half / 100).toStringAsFixed(0)}/team';
  }

  // ── steps ─────────────────────────────────────────────────────────────────

  bool get _step1Valid => _unit != null && _slot != null;
  bool get _step2Valid => _team != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Split Booking',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _StepBar(step: _step, total: 3),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _step == 0
            ? _buildStep1()
            : _step == 1
                ? _buildStep2()
                : _buildStep3(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(_error!,
                      style: const TextStyle(
                          color: Color(0xFFDC2626), fontSize: 13)),
                ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _canProceed ? _proceed : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF111827),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _step < 2 ? 'Continue' : 'Create Split Booking',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canProceed {
    if (_loading) return false;
    if (_step == 0) return _step1Valid;
    if (_step == 1) return _step2Valid;
    return true;
  }

  void _proceed() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  // ── Step 1: Unit + Date + Slot ─────────────────────────────────────────────

  Widget _buildStep1() {
    return ListView(
      key: const ValueKey(0),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      children: [
        _SectionLabel(label: 'Court / Ground'),
        const SizedBox(height: 8),
        // Unit selector
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.arena.units.map((u) {
            final selected = _unit?.id == u.id;
            return GestureDetector(
              onTap: () {
                setState(() => _unit = u);
                _rebuildSlots();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF111827)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF111827)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Text(
                  u.name,
                  style: TextStyle(
                    color:
                        selected ? Colors.white : const Color(0xFF374151),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _SectionLabel(label: 'Date'),
        const SizedBox(height: 8),
        _DateStrip(
          selected: _date,
          onSelect: (d) {
            setState(() => _date = d);
            _rebuildSlots();
          },
        ),
        const SizedBox(height: 24),
        _SectionLabel(label: 'Slot'),
        const SizedBox(height: 8),
        if (_slots.isEmpty)
          const Text('No slots available for this date.',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _slots.map((s) {
              final selected = _slot == s;
              return GestureDetector(
                onTap: () => setState(() => _slot = s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF111827)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF111827)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    _displaySlot(s),
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(0xFF374151),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ── Step 2: Format + Team ──────────────────────────────────────────────────

  Widget _buildStep2() {
    return ListView(
      key: const ValueKey(1),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      children: [
        _SectionLabel(label: 'Format'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _formats.map((f) {
            final selected = _format == f;
            return GestureDetector(
              onTap: () => setState(() => _format = f),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF111827)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF111827)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF374151),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _SectionLabel(label: 'Team (already confirmed)'),
        const SizedBox(height: 8),
        TextField(
          controller: _searchCtrl,
          onChanged: _searchTeams,
          decoration: InputDecoration(
            hintText: 'Search by team name or city',
            hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF), fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded,
                color: Color(0xFF9CA3AF), size: 20),
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child:
                          CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF111827)),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
          ),
        ),
        if (_team != null) ...[
          const SizedBox(height: 10),
          _SelectedTeamRow(
            team: _team!,
            onClear: () => setState(() {
              _team = null;
              _searchCtrl.clear();
              _teamResults = [];
            }),
          ),
        ],
        if (_teamResults.isNotEmpty && _team == null) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: _teamResults.asMap().entries.map((e) {
                final i = e.key;
                final t = e.value;
                return GestureDetector(
                  onTap: () => setState(() {
                    _team = t;
                    _teamResults = [];
                    _searchCtrl.text = t.name;
                  }),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      if (i > 0)
                        Divider(
                            height: 1,
                            color: Colors.grey.shade100),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.name,
                                    style: const TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (t.city.isNotEmpty)
                                    Text(
                                      t.city,
                                      style: const TextStyle(
                                        color: Color(0xFF9CA3AF),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.add_circle_outline_rounded,
                                color: Color(0xFF9CA3AF), size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 8),
        const Text(
          'No team yet? Leave blank — the system will find one from open lobbies.',
          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
        ),
      ],
    );
  }

  // ── Step 3: Confirm ────────────────────────────────────────────────────────

  Widget _buildStep3() {
    final dateStr = DateFormat('EEE, MMM d').format(_date);
    return ListView(
      key: const ValueKey(2),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      children: [
        const Text(
          'Review Split Booking',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'This creates a lobby in the player app. The system will match a rival team — or your confirmed team can find one.',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              _ConfirmRow(
                  label: 'Arena', value: widget.arena.name),
              const SizedBox(height: 10),
              _ConfirmRow(
                  label: 'Court',
                  value: _unit?.name ?? ''),
              const SizedBox(height: 10),
              _ConfirmRow(
                  label: 'Date',
                  value: '$dateStr · ${_displaySlot(_slot!)}'),
              const SizedBox(height: 10),
              _ConfirmRow(label: 'Format', value: _format),
              const SizedBox(height: 10),
              _ConfirmRow(
                label: 'Team',
                value: _team?.name ?? 'TBD — system will match',
              ),
              if (_halfPriceLabel.isNotEmpty) ...[
                Divider(
                    height: 20, color: Colors.grey.shade200),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Price per team',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _halfPriceLabel,
                      style: const TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Color(0xFF9CA3AF), size: 16),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Slot is soft-blocked. Full payment collected when both teams confirm.',
                style:
                    TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  const _StepBar({required this.step, required this.total});
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return Expanded(
          child: Container(
            height: 2,
            color: i <= step
                ? const Color(0xFF111827)
                : const Color(0xFFE5E7EB),
          ),
        );
      }),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF374151),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.selected, required this.onSelect});
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(
        14, (i) => DateTime(today.year, today.month, today.day + i));
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final d = days[i];
          final isSel = DateUtils.isSameDay(d, selected);
          return GestureDetector(
            onTap: () => onSelect(d),
            child: Container(
              width: 52,
              decoration: BoxDecoration(
                color: isSel
                    ? const Color(0xFF111827)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSel
                      ? const Color(0xFF111827)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(d),
                    style: TextStyle(
                      color: isSel
                          ? Colors.white.withValues(alpha: 0.7)
                          : const Color(0xFF9CA3AF),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      color: isSel
                          ? Colors.white
                          : const Color(0xFF111827),
                      fontSize: 18,
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

class _SelectedTeamRow extends StatelessWidget {
  const _SelectedTeamRow({required this.team, required this.onClear});
  final _Team team;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF059669), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (team.city.isNotEmpty)
                  Text(team.city,
                      style: const TextStyle(
                          color: Color(0xFF6B7280), fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close_rounded,
                color: Color(0xFF9CA3AF), size: 18),
          ),
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
                color: Color(0xFF9CA3AF), fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
