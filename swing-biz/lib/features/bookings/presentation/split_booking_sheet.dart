import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../arena/services/arena_profile_providers.dart';

// ─── Theme tokens (pulled from AppTheme via context) ─────────────────────────

class _Tokens {
  const _Tokens({
    required this.text,
    required this.muted,
    required this.faint,
    required this.hair,
    required this.bg,
    required this.tint,
    required this.accent,
    required this.onAccent,
  });
  final Color text;
  final Color muted;
  final Color faint;
  final Color hair;
  final Color bg;
  final Color tint;
  final Color accent;
  final Color onAccent;

  factory _Tokens.of(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return _Tokens(
      text: s.onSurface,
      muted: s.onSurface.withValues(alpha: 0.6),
      faint: s.onSurface.withValues(alpha: 0.4),
      hair: s.outline,
      bg: s.surface,
      tint: s.surfaceContainerHighest,
      accent: s.primary,
      onAccent: s.onPrimary,
    );
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class _Team {
  const _Team({required this.id, required this.name, required this.city});
  final String id;
  final String name;
  final String city;

  factory _Team.fromJson(Map<String, dynamic> j) => _Team(
        id: (j['id'] as String?) ?? (j['teamId'] as String?) ?? '',
        name: (j['name'] as String?) ?? (j['teamName'] as String?) ?? '',
        city: (j['city'] as String?) ?? '',
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

  String _fmt(String t) {
    try {
      final p = t.split(':');
      final h = int.parse(p[0]);
      final m = p[1];
      final ampm = h < 12 ? 'AM' : 'PM';
      final hr = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$hr:$m $ampm';
    } catch (_) {
      return t;
    }
  }

  String get displayStart => _fmt(startTime);
  String get displayEnd => _fmt(endTime);
}

String _ballTypeLabel(String bt) => switch (bt) {
      'LEATHER' => 'Leather',
      'TENNIS' => 'Tennis',
      'TAPE' => 'Tape Ball',
      'RUBBER' => 'Rubber',
      _ => bt,
    };

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

String _formatDurationLabel(String format) {
  switch (format) {
    case 'T10':
      return '~3 hrs';
    case 'T20':
      return '~4 hrs';
    case 'ODI':
      return '~8 hrs';
    case 'Test':
      return 'Full day';
    default:
      return '';
  }
}

// ─── Step metadata ────────────────────────────────────────────────────────────

const List<({String code, String label, String header, String hint})> _steps = [
  (
    code: 'WHERE',
    label: 'Where',
    header: 'Where will it be played?',
    hint: 'Pick one of your arenas. The match-up will only be visible to '
        'players looking at this venue.',
  ),
  (
    code: 'STYLE',
    label: 'Style',
    header: 'What kind of match?',
    hint: 'Format decides the slot duration. Ball type filters who picks it '
        'up — leather and tape ball players rarely overlap.',
  ),
  (
    code: 'WHEN',
    label: 'When',
    header: 'Pick a date and slot.',
    hint: 'The slot is held for 48 hours while a rival team is found. '
        'Each side pays half the ground fee.',
  ),
  (
    code: 'WHO',
    label: 'Who',
    header: 'Which team is playing?',
    hint: 'They take one side of the match. The system shows the slot to '
        'players in the app — when a rival team picks it up, the match is '
        'locked and both teams pay the advance.',
  ),
  (
    code: 'SEND',
    label: 'Review',
    header: 'Ready to send the request?',
    hint: 'Once you create this, players will see it as an open Match-Up in '
        'the app. You\'ll get a notification the moment a team picks it up.',
  ),
];

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
  // 0 Where · 1 Style · 2 When · 3 Who · 4 Review
  int _step = 0;

  // Step 0
  ArenaListing? _arena;

  // Step 1
  String _format = 'T20';
  String? _ballType;

  // Step 2
  late DateTime _date;
  _AvailableSlot? _slot;
  List<_AvailableSlot> _slots = [];
  bool _loadingSlots = false;
  String? _slotsError;

  // Step 3
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
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── data ──────────────────────────────────────────────────────────────────

  Future<void> _fetchSlots() async {
    if (_arena == null) return;
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
    } catch (_) {
      setState(() {
        _slotsError = 'Could not load slots';
        _loadingSlots = false;
      });
    }
  }

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
    } catch (_) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  // ── navigation ────────────────────────────────────────────────────────────

  bool get _stepValid {
    switch (_step) {
      case 0:
        return _arena != null;
      case 1:
        return _ballType != null; // format always defaulted
      case 2:
        return _slot != null;
      case 3:
        return _team != null;
      default:
        return true;
    }
  }

  bool get _canProceed => !_loading && _stepValid;

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }
    if (widget.arena != null && _step == 1) {
      // Arena was pre-selected — close instead of going back to step 0.
      Navigator.pop(context);
      return;
    }
    setState(() => _step--);
  }

  void _proceed() {
    if (_step == 1 && _slots.isEmpty) {
      // First entry into When — kick off slot fetch with current format.
      _fetchSlots();
    }
    if (_step == 4) {
      _submit();
      return;
    }
    setState(() => _step++);
    if (_step == 2) _fetchSlots();
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = _Tokens.of(context);
    final meta = _steps[_step];

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(_step == 0 || (widget.arena != null && _step == 1)
              ? Icons.close_rounded
              : Icons.arrow_back_rounded),
          color: t.text,
          onPressed: _back,
        ),
        title: Text(
          'Match-Up Request',
          style: TextStyle(
            color: t.text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _ProgressDots(step: _step, total: _steps.length, t: t),
          const SizedBox(height: 18),
          _StepHeader(meta: meta, currentStep: _step + 1, total: _steps.length, t: t),
          const SizedBox(height: 14),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _bodyForStep(t),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        t: t,
        canProceed: _canProceed,
        loading: _loading,
        error: _error,
        primaryLabel: _step == 4 ? 'Send Match-Up Request' : 'Continue',
        onPrimary: _proceed,
      ),
    );
  }

  Widget _bodyForStep(_Tokens t) {
    switch (_step) {
      case 0:
        return _buildWhere(t);
      case 1:
        return _buildStyle(t);
      case 2:
        return _buildWhen(t);
      case 3:
        return _buildWho(t);
      default:
        return _buildReview(t);
    }
  }

  // ── 0. Where ──────────────────────────────────────────────────────────────

  Widget _buildWhere(_Tokens t) {
    final arenasAsync = ref.watch(ownedArenasProvider);
    return arenasAsync.when(
      loading: () => Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: t.accent),
        ),
      ),
      error: (_, __) => Center(
        child: Text('Could not load arenas',
            style: TextStyle(color: t.muted, fontSize: 13)),
      ),
      data: (arenas) => ListView(
        key: const ValueKey('where'),
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: [
          for (final a in arenas) _SelectableRow(
            t: t,
            selected: _arena?.id == a.id,
            title: a.name,
            subtitle: a.address.isNotEmpty ? a.address : null,
            onTap: () => setState(() => _arena = a),
          ),
        ],
      ),
    );
  }

  // ── 1. Style — Format + Ball Type ─────────────────────────────────────────

  Widget _buildStyle(_Tokens t) {
    return ListView(
      key: const ValueKey('style'),
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        _SectionLabel(t: t, label: 'FORMAT'),
        const SizedBox(height: 4),
        for (final f in _formats) _SelectableRow(
          t: t,
          selected: _format == f,
          title: f,
          subtitle: _formatDurationLabel(f),
          onTap: () {
            setState(() {
              _format = f;
              _slot = null; // re-pick slot since duration changes
              _slots = [];
            });
          },
        ),
        const SizedBox(height: 22),
        _SectionLabel(t: t, label: 'BALL TYPE'),
        const SizedBox(height: 4),
        for (final bt in const ['LEATHER', 'TENNIS', 'TAPE', 'RUBBER'])
          _SelectableRow(
            t: t,
            selected: _ballType == bt,
            title: _ballTypeLabel(bt),
            onTap: () => setState(() => _ballType = bt),
          ),
      ],
    );
  }

  // ── 2. When — Date + Slot ─────────────────────────────────────────────────

  Widget _buildWhen(_Tokens t) {
    return ListView(
      key: const ValueKey('when'),
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        _SectionLabel(t: t, label: 'DATE'),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _DateStrip(
            t: t,
            selected: _date,
            onSelect: (d) {
              setState(() {
                _date = d;
                _slot = null;
              });
              _fetchSlots();
            },
          ),
        ),
        const SizedBox(height: 22),
        _SectionLabel(t: t, label: 'SLOT'),
        const SizedBox(height: 4),
        if (_loadingSlots)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: t.accent),
              ),
            ),
          )
        else if (_slotsError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(_slotsError!,
                style: TextStyle(color: t.muted, fontSize: 13)),
          )
        else if (_slots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'No slots available on ${DateFormat('EEE, MMM d').format(_date)}.\nTry another date.',
              style: TextStyle(color: t.muted, fontSize: 13, height: 1.4),
            ),
          )
        else
          for (final s in _slots) _SelectableRow(
            t: t,
            selected:
                _slot?.startTime == s.startTime && _slot?.unitId == s.unitId,
            title: '${s.displayStart} – ${s.displayEnd}',
            subtitle: s.unitName,
            trailing: '₹${(s.halfPricePaise / 100).toStringAsFixed(0)} / team',
            onTap: () => setState(() => _slot = s),
          ),
      ],
    );
  }

  // ── 3. Who — Team ─────────────────────────────────────────────────────────

  Widget _buildWho(_Tokens t) {
    return ListView(
      key: const ValueKey('who'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      children: [
        TextField(
          controller: _searchCtrl,
          onChanged: _searchTeams,
          style: TextStyle(color: t.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search team name or city',
            hintStyle: TextStyle(color: t.faint, fontSize: 13),
            prefixIcon: Icon(Icons.search_rounded, color: t.faint, size: 20),
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                  )
                : null,
            filled: true,
            fillColor: t.tint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: t.accent, width: 1.4),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        if (_team != null) ...[
          const SizedBox(height: 10),
          _SelectedTeamPill(
            t: t,
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
          for (var i = 0; i < _teamResults.length; i++)
            _TeamResultRow(
              t: t,
              team: _teamResults[i],
              isFirst: i == 0,
              onTap: () => setState(() {
                _team = _teamResults[i];
                _teamResults = [];
                _searchCtrl.text = _teamResults[i].name;
              }),
            ),
        ],
        if (_team == null && _teamResults.isEmpty &&
            _searchCtrl.text.length < 2) ...[
          const SizedBox(height: 30),
          Center(
            child: Text(
              'Start typing to find a team.',
              style: TextStyle(color: t.faint, fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }

  // ── 4. Review ─────────────────────────────────────────────────────────────

  Widget _buildReview(_Tokens t) {
    final s = _slot!;
    final dateStr = DateFormat('EEE, MMM d').format(_date);
    return ListView(
      key: const ValueKey('review'),
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        _SectionLabel(t: t, label: 'DETAILS'),
        const SizedBox(height: 4),
        _ReviewRow(t: t, label: 'Arena', value: _arena!.name),
        _ReviewRow(t: t, label: 'Court', value: s.unitName),
        _ReviewRow(t: t, label: 'When', value: '$dateStr  ·  ${s.displayStart} – ${s.displayEnd}'),
        _ReviewRow(t: t, label: 'Format', value: '$_format  ·  ${_formatDurationLabel(_format)}'),
        _ReviewRow(t: t, label: 'Ball', value: _ballTypeLabel(_ballType ?? '')),
        _ReviewRow(t: t, label: 'Team', value: _team!.name),
        const SizedBox(height: 22),
        _SectionLabel(t: t, label: 'COST'),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Per team',
                  style: TextStyle(
                    color: t.muted,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '₹${(s.halfPricePaise / 100).toStringAsFixed(0)}',
                style: TextStyle(
                  color: t.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        Container(height: 0.5, color: t.hair),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Slot is held for 48 hours. Both teams pay the advance once a '
            'rival picks it up — only then is the match locked.',
            style: TextStyle(color: t.muted, fontSize: 12.5, height: 1.5),
          ),
        ),
      ],
    );
  }
}

// ─── Components ───────────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.step, required this.total, required this.t});
  final int step;
  final int total;
  final _Tokens t;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          for (int i = 0; i < total; i++) ...[
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: i <= step ? t.accent : t.hair,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < total - 1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.meta,
    required this.currentStep,
    required this.total,
    required this.t,
  });
  final ({String code, String label, String header, String hint}) meta;
  final int currentStep;
  final int total;
  final _Tokens t;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step $currentStep of $total · ${meta.label.toUpperCase()}',
            style: TextStyle(
              color: t.accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            meta.header,
            style: TextStyle(
              color: t.text,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            meta.hint,
            style: TextStyle(color: t.muted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.t});
  final String label;
  final _Tokens t;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        label,
        style: TextStyle(
          color: t.faint,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _SelectableRow extends StatelessWidget {
  const _SelectableRow({
    required this.t,
    required this.selected,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final _Tokens t;
  final bool selected;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: t.hair, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // selection dot
            SizedBox(
              width: 18,
              height: 18,
              child: selected
                  ? Container(
                      decoration: BoxDecoration(
                        color: t.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded,
                          color: t.onAccent, size: 12),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: t.hair, width: 1.2),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: t.text,
                      fontSize: 15,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(color: t.muted, fontSize: 12.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 10),
              Text(
                trailing!,
                style: TextStyle(
                  color: selected ? t.accent : t.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip(
      {required this.selected, required this.onSelect, required this.t});
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  final _Tokens t;

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
                color: isSel ? t.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSel ? t.accent : t.hair,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(d),
                    style: TextStyle(
                      color: isSel ? t.onAccent.withValues(alpha: 0.7) : t.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      color: isSel ? t.onAccent : t.text,
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

class _SelectedTeamPill extends StatelessWidget {
  const _SelectedTeamPill(
      {required this.t, required this.team, required this.onClear});
  final _Tokens t;
  final _Team team;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: t.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: t.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  team.name,
                  style: TextStyle(
                    color: t.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (team.city.isNotEmpty)
                  Text(
                    team.city,
                    style: TextStyle(color: t.muted, fontSize: 12),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: Icon(Icons.close_rounded, color: t.muted, size: 18),
          ),
        ],
      ),
    );
  }
}

class _TeamResultRow extends StatelessWidget {
  const _TeamResultRow({
    required this.t,
    required this.team,
    required this.isFirst,
    required this.onTap,
  });
  final _Tokens t;
  final _Team team;
  final bool isFirst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: isFirst
                ? BorderSide(color: t.hair, width: 0.5)
                : BorderSide.none,
            bottom: BorderSide(color: t.hair, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    team.name,
                    style: TextStyle(
                      color: t.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (team.city.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      team.city,
                      style: TextStyle(color: t.muted, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.add_rounded, color: t.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(
      {required this.t, required this.label, required this.value});
  final _Tokens t;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.hair, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(color: t.muted, fontSize: 12.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: t.text,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.t,
    required this.canProceed,
    required this.loading,
    required this.error,
    required this.primaryLabel,
    required this.onPrimary,
  });

  final _Tokens t;
  final bool canProceed;
  final bool loading;
  final String? error;
  final String primaryLabel;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  error!,
                  style: const TextStyle(
                      color: Color(0xFFDC2626), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: canProceed ? onPrimary : null,
                style: FilledButton.styleFrom(
                  backgroundColor: t.accent,
                  foregroundColor: t.onAccent,
                  disabledBackgroundColor: t.hair,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: t.onAccent),
                      )
                    : Text(
                        primaryLabel,
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
    );
  }
}
