import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../arena/services/arena_profile_providers.dart';

String _ballTypeLabel(String bt) => switch (bt) {
      'LEATHER' => 'Leather',
      'TENNIS' => 'Tennis',
      'TAPE' => 'Tape Ball',
      'RUBBER' => 'Rubber',
      _ => bt,
    };

// ─── Models ───────────────────────────────────────────────────────────────────

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

class _AvailableSlot {
  const _AvailableSlot({
    required this.unitId,
    required this.unitName,
    required this.startTime,
    required this.endTime,
    required this.totalAmountPaise,
  });
  final String unitId;
  final String unitName;
  final String startTime;
  final String endTime;
  final int totalAmountPaise;

  int get halfPricePaise => totalAmountPaise ~/ 2;

  String get displayStart {
    try {
      final p = startTime.split(':');
      final h = int.parse(p[0]);
      final m = p[1];
      final ampm = h < 12 ? 'AM' : 'PM';
      final hr = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$hr:$m $ampm';
    } catch (_) {
      return startTime;
    }
  }

  String get displayEnd {
    try {
      final p = endTime.split(':');
      final h = int.parse(p[0]);
      final m = p[1];
      final ampm = h < 12 ? 'AM' : 'PM';
      final hr = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$hr:$m $ampm';
    } catch (_) {
      return endTime;
    }
  }
}

// ─── Format → duration mapping ────────────────────────────────────────────────

int _durationForFormat(String format) {
  switch (format) {
    case 'T10':
    case 'T20':
      return 240; // 4 hr
    case 'ODI':
      return 480; // 8 hr
    case 'Test':
      return 720; // full day
    default:
      return 240;
  }
}

// ─── Split Booking Sheet ──────────────────────────────────────────────────────

class SplitBookingSheet extends ConsumerStatefulWidget {
  const SplitBookingSheet({
    super.key,
    this.arena,
    required this.initialDate,
  });

  final ArenaListing? arena;
  final DateTime initialDate;

  @override
  ConsumerState<SplitBookingSheet> createState() => _SplitBookingSheetState();
}

class _SplitBookingSheetState extends ConsumerState<SplitBookingSheet> {
  int _step = 0;

  // Step 0
  ArenaListing? _arena;

  // Step 1
  String _format = 'T20';
  String? _ballType;
  late DateTime _date;
  _AvailableSlot? _slot;
  List<_AvailableSlot> _slots = [];
  bool _loadingSlots = false;
  String? _slotsError;

  // Step 2
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
    if (widget.arena != null) {
      _arena = widget.arena;
      _step = 1;
      _fetchSlots();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── fetch slots from arena API ────────────────────────────────────────────

  Future<void> _fetchSlots() async {
    setState(() {
      _loadingSlots = true;
      _slotsError = null;
      _slot = null;
    });
    try {
      final dio = ref.read(hostDioProvider);
      final dateStr = DateFormat('yyyy-MM-dd').format(_date);
      final duration = _durationForFormat(_format);
      final resp = await dio.get(
        '/arenas/${_arena!.id}/slots',
        queryParameters: {'date': dateStr, 'durationMins': duration},
      );
      final body = resp.data;
      final data = (body is Map) ? (body['data'] ?? body) : body;
      final groups = (data is Map) ? (data['unitGroups'] as List?) ?? [] : [];
      final slots = <_AvailableSlot>[];
      for (final g in groups.whereType<Map>()) {
        final unitType = g['unitType'] as String? ?? '';
        if (unitType != 'FULL_GROUND' && unitType != 'HALF_GROUND') continue;
        final unitId = g['unitId'] as String? ?? '';
        final unitName = g['displayName'] as String? ?? g['name'] as String? ?? unitId;
        final available = (g['availableSlots'] as List?) ?? [];
        for (final s in available.whereType<Map>()) {
          slots.add(_AvailableSlot(
            unitId: unitId,
            unitName: unitName,
            startTime: s['startTime'] as String? ?? '',
            endTime: s['endTime'] as String? ?? '',
            totalAmountPaise: (s['totalAmountPaise'] as num?)?.toInt() ?? 0,
          ));
        }
      }
      setState(() {
        _slots = slots;
        _loadingSlots = false;
      });
    } catch (e) {
      setState(() {
        _slotsError = 'Could not load slots';
        _loadingSlots = false;
      });
    }
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
      final payload = {
        'unitId': _slot!.unitId,
        'date': DateFormat('yyyy-MM-dd').format(_date),
        'slotTime': _slot!.startTime,
        'format': _format,
        if (_ballType != null) 'ballType': _ballType,
        'teamId': _team!.id,
        'teamName': _team!.name,
      };
      await dio.post(
        '/bookings/arena/${_arena!.id}/split',
        data: payload,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  // ── navigation ────────────────────────────────────────────────────────────

  bool get _step0Valid => _arena != null;
  bool get _step1Valid => _slot != null;
  bool get _step2Valid => _team != null;

  bool get _canProceed {
    if (_loading) return false;
    if (_step == 0) return _step0Valid;
    if (_step == 1) return _step1Valid;
    if (_step == 2) return _step2Valid;
    return true;
  }

  void _proceed() {
    if (_step == 0) {
      setState(() => _step = 1);
      _fetchSlots();
    } else if (_step < 3) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

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
          'Invitation',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _StepBar(step: _step, total: 4),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _step == 0
            ? _buildStep0()
            : _step == 1
                ? _buildStep1()
                : _step == 2
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
                          _step < 3 ? 'Continue' : 'Create Invitation',
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

  // ── Step 0: Select Arena ──────────────────────────────────────────────────

  Widget _buildStep0() {
    final arenasAsync = ref.watch(ownedArenasProvider);
    return arenasAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF111827)),
      ),
      error: (_, __) => const Center(
        child: Text('Could not load arenas', style: TextStyle(color: Color(0xFF9CA3AF))),
      ),
      data: (arenas) => ListView(
        key: const ValueKey(0),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        children: [
          _SectionLabel(label: 'Select Arena'),
          const SizedBox(height: 4),
          const Text(
            'Choose which arena this invitation is for.',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          ),
          const SizedBox(height: 16),
          ...arenas.map((a) {
            final selected = _arena?.id == a.id;
            return GestureDetector(
              onTap: () => setState(() => _arena = a),
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.name,
                            style: TextStyle(
                              color: selected ? Colors.white : const Color(0xFF111827),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (a.address.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              a.address,
                              style: TextStyle(
                                color: selected ? Colors.white60 : const Color(0xFF9CA3AF),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Step 1: Format + Date + Slot (from API) ────────────────────────────────

  Widget _buildStep1() {
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
              onTap: () {
                setState(() {
                  _format = f;
                  _slot = null;
                });
                _fetchSlots();
              },
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
                child: Column(
                  children: [
                    Text(
                      f,
                      style: TextStyle(
                        color:
                            selected ? Colors.white : const Color(0xFF374151),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDurationLabel(f),
                      style: TextStyle(
                        color: selected
                            ? Colors.white70
                            : const Color(0xFF9CA3AF),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _SectionLabel(label: 'Ball Type'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['LEATHER', 'TENNIS', 'TAPE', 'RUBBER'].map((bt) {
            final sel = _ballType == bt;
            return GestureDetector(
              onTap: () => setState(() => _ballType = sel ? null : bt),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: sel ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Text(
                  _ballTypeLabel(bt),
                  style: TextStyle(
                    color: sel ? Colors.white : const Color(0xFF374151),
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
            setState(() {
              _date = d;
              _slot = null;
            });
            _fetchSlots();
          },
        ),
        const SizedBox(height: 24),
        _SectionLabel(label: 'Available Slots'),
        const SizedBox(height: 8),
        if (_loadingSlots)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: Color(0xFF111827)),
            ),
          )
        else if (_slotsError != null)
          Text(_slotsError!,
              style: const TextStyle(
                  color: Color(0xFF9CA3AF), fontSize: 13))
        else if (_slots.isEmpty)
          const Text('No slots available for this date.',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13))
        else
          Column(
            children: _slots.map((s) {
              final selected = _slot?.startTime == s.startTime &&
                  _slot?.unitId == s.unitId;
              return GestureDetector(
                onTap: () => setState(() => _slot = s),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF111827)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF111827)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${s.displayStart} – ${s.displayEnd}',
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF111827),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              s.unitName,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white60
                                    : const Color(0xFF9CA3AF),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${(s.halfPricePaise / 100).toStringAsFixed(0)}/team',
                            style: TextStyle(
                              color: selected
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFF059669),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'half price',
                            style: TextStyle(
                              color: selected
                                  ? Colors.white38
                                  : const Color(0xFF9CA3AF),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  String _formatDurationLabel(String format) {
    switch (format) {
      case 'T10':
      case 'T20':
        return '4 hrs';
      case 'ODI':
        return '8 hrs';
      case 'Test':
        return 'Full day';
      default:
        return '';
    }
  }

  // ── Step 2: Team (optional) ────────────────────────────────────────────────

  Widget _buildStep2() {
    return ListView(
      key: const ValueKey(2),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      children: [
        _SectionLabel(label: 'Team'),
        const SizedBox(height: 4),
        const Text(
          'The team who will play. They create the lobby — the system then finds a rival.',
          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchCtrl,
          onChanged: _searchTeams,
          decoration: InputDecoration(
            hintText: 'Search by team name or city',
            hintStyle:
                const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
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
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF111827)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        Divider(height: 1, color: Colors.grey.shade100),
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
                                  Text(t.name,
                                      style: const TextStyle(
                                        color: Color(0xFF111827),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  if (t.city.isNotEmpty)
                                    Text(t.city,
                                        style: const TextStyle(
                                            color: Color(0xFF9CA3AF),
                                            fontSize: 12)),
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
      ],
    );
  }

  // ── Step 3: Confirm ────────────────────────────────────────────────────────

  Widget _buildStep3() {
    final s = _slot!;
    final dateStr = DateFormat('EEE, MMM d').format(_date);
    return ListView(
      key: const ValueKey(3),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      children: [
        const Text(
          'Review Invitation',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Creates a lobby in the player app. System will match a rival team — or your confirmed team can find one.',
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
              _ConfirmRow(label: 'Arena', value: _arena!.name),
              const SizedBox(height: 10),
              _ConfirmRow(label: 'Court', value: s.unitName),
              const SizedBox(height: 10),
              _ConfirmRow(
                  label: 'Date',
                  value: '$dateStr · ${s.displayStart} – ${s.displayEnd}'),
              const SizedBox(height: 10),
              _ConfirmRow(label: 'Format', value: _format),
              const SizedBox(height: 10),
              _ConfirmRow(label: 'Team', value: _team!.name),
              Divider(height: 20, color: Colors.grey.shade200),
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
                    '₹${(s.halfPricePaise / 100).toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Icon(Icons.info_outline_rounded,
                color: Color(0xFF9CA3AF), size: 16),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Slot is soft-blocked. Full payment collected when both teams confirm.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
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
                          ? Colors.white60
                          : const Color(0xFF9CA3AF),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      color: isSel ? Colors.white : const Color(0xFF111827),
                      fontSize: 16,
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
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, color: Color(0xFF059669), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              team.name,
              style: const TextStyle(
                color: Color(0xFF065F46),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close_rounded,
                color: Color(0xFF059669), size: 18),
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
          width: 60,
          child: Text(label,
              style: const TextStyle(
                  color: Color(0xFF9CA3AF), fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              )),
        ),
      ],
    );
  }
}
