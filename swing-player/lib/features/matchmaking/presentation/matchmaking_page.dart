import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ── Domain stubs — replace with real providers ────────────────────────────────

enum AgeGroup {
  u12('U-12'),
  u16('U-16'),
  u19('U-19'),
  open('Open'),
  corporate('Corporate'),
  veterans('Veterans 40+');

  const AgeGroup(this.label);
  final String label;
}

enum MatchFormat {
  t10('T10'),
  t20('T20'),
  thirtyOver('30 Overs'),
  boxCricket('Box');

  const MatchFormat(this.label);
  final String label;
}

enum MatchTiming {
  morning('Morning', '6am–12pm', Icons.wb_sunny_outlined),
  afternoon('Afternoon', '12–4pm', Icons.wb_cloudy_outlined),
  evening('Evening', '4–8pm', Icons.wb_twilight_outlined),
  night('Night', '8pm+', Icons.nights_stay_outlined);

  const MatchTiming(this.label, this.range, this.icon);
  final String label;
  final String range;
  final IconData icon;
}

class TeamStub {
  const TeamStub({
    required this.id,
    required this.name,
    required this.ageGroup,
    required this.matchesPlayed,
  });
  final String id;
  final String name;
  final AgeGroup ageGroup;
  final int matchesPlayed;
}

const mockTeams = [
  TeamStub(id: '1', name: 'Challengers XI', ageGroup: AgeGroup.open, matchesPlayed: 24),
  TeamStub(id: '2', name: 'Fire Blasters', ageGroup: AgeGroup.u19, matchesPlayed: 11),
  TeamStub(id: '3', name: 'Corporate Wolves', ageGroup: AgeGroup.corporate, matchesPlayed: 7),
];

// ── Page ──────────────────────────────────────────────────────────────────────

enum _LobbyState { idle, searching, matched }

class MatchmakingPage extends StatefulWidget {
  const MatchmakingPage({super.key});

  @override
  State<MatchmakingPage> createState() => _MatchmakingPageState();
}

class _MatchmakingPageState extends State<MatchmakingPage> {
  _LobbyState _lobbyState = _LobbyState.idle;

  TeamStub _team = mockTeams.first;
  MatchFormat _format = MatchFormat.t20;
  DateTime _date = DateTime.now();
  MatchTiming _timing = MatchTiming.evening;
  MatchTiming? _nudge;

  void _enterLobby() {
    setState(() {
      _lobbyState = _LobbyState.searching;
      _nudge = _timing == MatchTiming.evening ? MatchTiming.night : null;
    });
  }

  void _switchNudge(MatchTiming t) {
    setState(() {
      _timing = t;
      _nudge = null;
      _lobbyState = _LobbyState.matched;
    });
  }

  void _leaveLobby() => setState(() => _lobbyState = _LobbyState.idle);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          child: switch (_lobbyState) {
            _LobbyState.idle => _IdleLobby(
                key: const ValueKey('idle'),
                teams: mockTeams,
                selectedTeam: _team,
                selectedFormat: _format,
                selectedDate: _date,
                selectedTiming: _timing,
                onTeam: (t) => setState(() => _team = t),
                onFormat: (f) => setState(() => _format = f),
                onDate: (d) => setState(() => _date = d),
                onTiming: (t) => setState(() => _timing = t),
                onEnter: _enterLobby,
              ),
            _LobbyState.searching => _SearchingLobby(
                key: const ValueKey('searching'),
                team: _team,
                format: _format,
                date: _date,
                timing: _timing,
                nudge: _nudge,
                onSwitch: _switchNudge,
                onLeave: _leaveLobby,
              ),
            _LobbyState.matched => _MatchedLobby(
                key: const ValueKey('matched'),
                team: _team,
                format: _format,
                date: _date,
                timing: _timing,
                onConfirm: () => Navigator.pop(context),
                onDecline: () => setState(() => _lobbyState = _LobbyState.searching),
              ),
          },
        ),
      ),
    );
  }
}

// ── Idle lobby ────────────────────────────────────────────────────────────────

class _IdleLobby extends StatelessWidget {
  const _IdleLobby({
    super.key,
    required this.teams,
    required this.selectedTeam,
    required this.selectedFormat,
    required this.selectedDate,
    required this.selectedTiming,
    required this.onTeam,
    required this.onFormat,
    required this.onDate,
    required this.onTiming,
    required this.onEnter,
  });

  final List<TeamStub> teams;
  final TeamStub selectedTeam;
  final MatchFormat selectedFormat;
  final DateTime selectedDate;
  final MatchTiming selectedTiming;
  final ValueChanged<TeamStub> onTeam;
  final ValueChanged<MatchFormat> onFormat;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<MatchTiming> onTiming;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_rounded,
                    color: context.fg, size: 22),
              ),
              Text(
                'Lobby',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Team ──
                _MiniLabel('YOUR TEAM'),
                const SizedBox(height: 4),
                Text(
                  'Matched only within the same age group',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ...teams.map((t) => _TeamRow(
                      team: t,
                      selected: selectedTeam.id == t.id,
                      onTap: () => onTeam(t),
                    )),

                const SizedBox(height: 28),
                Container(height: 1, color: context.stroke.withValues(alpha: 0.4)),
                const SizedBox(height: 28),

                // ── Format ──
                _MiniLabel('FORMAT'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MatchFormat.values.map((f) {
                    final sel = selectedFormat == f;
                    return GestureDetector(
                      onTap: () => onFormat(f),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: sel ? context.ctaBg : context.panel,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          f.label,
                          style: TextStyle(
                            color: sel ? context.ctaFg : context.fg,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),
                Container(height: 1, color: context.stroke.withValues(alpha: 0.4)),
                const SizedBox(height: 28),

                // ── Date ──
                _MiniLabel('DATE'),
                const SizedBox(height: 12),
                _DateStrip(selected: selectedDate, onSelect: onDate),

                const SizedBox(height: 28),
                Container(height: 1, color: context.stroke.withValues(alpha: 0.4)),
                const SizedBox(height: 28),

                // ── Timing ──
                _MiniLabel('TIMING'),
                const SizedBox(height: 12),
                ...MatchTiming.values.map((t) {
                  final sel = selectedTiming == t;
                  return GestureDetector(
                    onTap: () => onTiming(t),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: sel ? context.ctaBg : context.panel,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(t.icon,
                                size: 18,
                                color: sel ? context.ctaFg : context.fgSub),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                t.label,
                                style: TextStyle(
                                  color: sel ? context.ctaFg : context.fg,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              t.range,
                              style: TextStyle(
                                color: sel
                                    ? context.ctaFg.withValues(alpha: 0.7)
                                    : context.fgSub,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // Sticky CTA
        Padding(
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
          child: GestureDetector(
            onTap: onEnter,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: context.ctaBg,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.radar_rounded, color: context.ctaFg, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Enter Lobby',
                    style: TextStyle(
                      color: context.ctaFg,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Team row ──────────────────────────────────────────────────────────────────

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.team,
    required this.selected,
    required this.onTap,
  });
  final TeamStub team;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? context.accent : context.stroke,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                team.name,
                style: TextStyle(
                  color: selected ? context.fg : context.fgSub,
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Text(
              team.ageGroup.label,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${team.matchesPlayed} matches',
              style: TextStyle(
                color: context.fgSub.withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Date strip ────────────────────────────────────────────────────────────────

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.selected, required this.onSelect});
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  static final _days = List.generate(7, (i) {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day + i);
  });

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _label(DateTime d, int i) {
    if (i == 0) return 'Today';
    if (i == 1) return 'Tmrw';
    return _dayNames[d.weekday - 1];
  }

  bool _same(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_days.length, (i) {
        final d = _days[i];
        final sel = _same(selected, d);
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(d),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(right: i < _days.length - 1 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 58,
                decoration: BoxDecoration(
                  color: sel ? context.ctaBg : context.panel,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _label(d, i),
                      style: TextStyle(
                        color: sel ? context.ctaFg : context.fgSub,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${d.day}',
                      style: TextStyle(
                        color: sel ? context.ctaFg : context.fg,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Searching lobby ───────────────────────────────────────────────────────────

class _SearchingLobby extends StatelessWidget {
  const _SearchingLobby({
    super.key,
    required this.team,
    required this.format,
    required this.date,
    required this.timing,
    required this.nudge,
    required this.onSwitch,
    required this.onLeave,
  });

  final TeamStub team;
  final MatchFormat format;
  final DateTime date;
  final MatchTiming timing;
  final MatchTiming? nudge;
  final ValueChanged<MatchTiming> onSwitch;
  final VoidCallback onLeave;

  String _dateStr(DateTime d) {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final t = DateTime(d.year, d.month, d.day);
    if (t == today) return 'Today';
    if (t == today.add(const Duration(days: 1))) return 'Tomorrow';
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[d.month]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.panel,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.8, color: context.accent),
                ),
                const SizedBox(width: 8),
                Text(
                  'IN LOBBY',
                  style: TextStyle(
                    color: context.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Team name — hero
          Text(
            team.name,
            style: TextStyle(
              color: context.fg,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${team.ageGroup.label}  ·  ${format.label}  ·  ${timing.label}  ·  ${_dateStr(date)}',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 48),
          Text(
            'Searching for opponent...',
            style: TextStyle(
              color: context.fg,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (nudge != null) ...[
            const SizedBox(height: 40),
            Container(
                height: 1,
                color: context.stroke.withValues(alpha: 0.4)),
            const SizedBox(height: 32),
            Text(
              'Team waiting for ${nudge!.label}',
              style: TextStyle(
                color: context.fg,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Switch and match instantly',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () => onSwitch(nudge!),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: context.panel,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(nudge!.icon, color: context.fg, size: 17),
                    const SizedBox(width: 10),
                    Text(
                      'Play ${nudge!.label}',
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        color: context.fgSub, size: 15),
                  ],
                ),
              ),
            ),
          ],

          const Spacer(),

          GestureDetector(
            onTap: onLeave,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Leave Lobby',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Matched lobby ─────────────────────────────────────────────────────────────

class _MatchedLobby extends StatelessWidget {
  const _MatchedLobby({
    super.key,
    required this.team,
    required this.format,
    required this.date,
    required this.timing,
    required this.onConfirm,
    required this.onDecline,
  });

  final TeamStub team;
  final MatchFormat format;
  final DateTime date;
  final MatchTiming timing;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;

  String _dateStr(DateTime d) {
    final n = DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final t = DateTime(d.year, d.month, d.day);
    if (t == today) return 'Today';
    if (t == today.add(const Duration(days: 1))) return 'Tomorrow';
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[d.month]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'MATCH FOUND',
              style: TextStyle(
                color: context.accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Ground — hero
          Text(
            'Cheetah Cricket\nGround',
            style: TextStyle(
              color: context.fg,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Koramangala  ·  ${format.label}  ·  ${timing.label}  ·  ${_dateStr(date)}',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${team.name}  ·  ${team.ageGroup.label}',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 48),

          // Fee
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹900',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'your share  ·  ground fee ÷ 2',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: GestureDetector(
              onTap: onConfirm,
              child: Container(
                decoration: BoxDecoration(
                  color: context.ctaBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Confirm & Pay  ₹900',
                  style: TextStyle(
                    color: context.ctaFg,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Opponent has 15 min to confirm',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: onDecline,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Decline',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _MiniLabel extends StatelessWidget {
  const _MiniLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.fgSub,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}
