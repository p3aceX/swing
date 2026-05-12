import 'package:flutter/material.dart';

import '../../../theme/host_colors.dart';
import '../domain/scoring_models.dart';

class _DismissalMeta {
  const _DismissalMeta(this.key, this.label, this.icon);
  final String key;
  final String label;
  final IconData icon;
}

const _kDismissals = [
  _DismissalMeta('BOWLED',            'Bowled',    Icons.sports_cricket),
  _DismissalMeta('CAUGHT',            'Caught',    Icons.back_hand_outlined),
  _DismissalMeta('CAUGHT_BEHIND',     'Ct Behind', Icons.hearing),
  _DismissalMeta('CAUGHT_AND_BOWLED', 'C & B',     Icons.link),
  _DismissalMeta('LBW',               'LBW',       Icons.block),
  _DismissalMeta('RUN_OUT',           'Run Out',   Icons.directions_run),
  _DismissalMeta('STUMPED',           'Stumped',   Icons.sports_baseball),
  _DismissalMeta('HIT_WICKET',        'Hit Wkt',   Icons.construction),
  _DismissalMeta('RETIRED_HURT',      'Ret Hurt',  Icons.medical_services),
  _DismissalMeta('RETIRED_OUT',       'Ret Out',   Icons.exit_to_app),
];

// Which dismissals are valid per delivery type
const _kValidOn = <String, Set<String>>{
  'LEGAL': {
    'BOWLED', 'CAUGHT', 'CAUGHT_BEHIND', 'CAUGHT_AND_BOWLED',
    'LBW', 'RUN_OUT', 'STUMPED', 'HIT_WICKET', 'RETIRED_HURT', 'RETIRED_OUT',
  },
  'WIDE':    {'RUN_OUT', 'STUMPED', 'RETIRED_HURT', 'RETIRED_OUT'},
  'NO_BALL': {'RUN_OUT', 'RETIRED_HURT', 'RETIRED_OUT'},
};

// On a free hit (legal delivery after a no-ball) only these apply
const _kFreeHitValid = {'RUN_OUT', 'HIT_WICKET', 'RETIRED_HURT', 'RETIRED_OUT'};

// These dismissals don't need a fielder recorded
const _kNoFielder = {'BOWLED', 'HIT_WICKET', 'RETIRED_HURT', 'RETIRED_OUT'};

class WicketSheet extends StatefulWidget {
  const WicketSheet({
    super.key,
    required this.strikerName,
    required this.nonStrikerName,
    required this.fieldingTeam,
    required this.onConfirm,
    this.isFreeHit = false,
    this.keeperId,
    this.bowlerId,
  });

  final String strikerName;
  final String nonStrikerName;
  final List<ScoringMatchPlayer> fieldingTeam;
  final bool isFreeHit;
  final String? keeperId;
  final String? bowlerId;

  final void Function({
    required String dismissalType,
    required String deliveryType,
    String? fielderId,
    required bool dismissedIsStriker,
    required int completedRuns,
    bool crossed,
  }) onConfirm;

  @override
  State<WicketSheet> createState() => _WicketSheetState();
}

class _WicketSheetState extends State<WicketSheet> {
  String _deliveryType = 'LEGAL';
  String _dismissalType = 'BOWLED';
  bool _dismissedIsStriker = true;
  String? _fielderId;
  int _completedRuns = 0;

  @override
  void initState() {
    super.initState();
    _syncAutoFielder();
  }

  bool _isValid(String key) {
    if (widget.isFreeHit && _deliveryType == 'LEGAL') {
      return _kFreeHitValid.contains(key);
    }
    return _kValidOn[_deliveryType]?.contains(key) ?? false;
  }

  bool get _needsFielder => !_kNoFielder.contains(_dismissalType);

  String? get _autoFielderId {
    if (_dismissalType == 'CAUGHT_BEHIND' || _dismissalType == 'STUMPED') {
      return widget.keeperId;
    }
    if (_dismissalType == 'CAUGHT_AND_BOWLED' || _dismissalType == 'LBW') {
      return widget.bowlerId;
    }
    return null;
  }

  void _syncAutoFielder() {
    final auto = _autoFielderId;
    if (auto != null) _fielderId = auto;
  }

  void _selectDismissal(String key) {
    if (!_isValid(key)) return;
    setState(() {
      _dismissalType = key;
      if (key != 'RUN_OUT') _dismissedIsStriker = true;
      _syncAutoFielder();
    });
  }

  void _onDeliveryChanged(String type) {
    setState(() {
      _deliveryType = type;
      // If current dismissal is no longer valid, pick first valid one
      if (!_isValid(_dismissalType)) {
        _dismissalType = _kDismissals
            .firstWhere((m) => _isValid(m.key), orElse: () => _kDismissals.first)
            .key;
        if (_dismissalType != 'RUN_OUT') _dismissedIsStriker = true;
      }
      _syncAutoFielder();
    });
  }

  String _fielderName(String? id) {
    if (id == null || id.isEmpty) return 'Unknown';
    for (final p in widget.fieldingTeam) {
      if (p.profileId == id || p.userId == id) return p.name;
    }
    return 'Unknown';
  }

  bool get _canConfirm {
    if (!_isValid(_dismissalType)) return false;
    if (_needsFielder && _autoFielderId == null && _fielderId == null) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.88),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Handle(color: context.fg),
          Flexible(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    child: Row(
                      children: [
                        const Icon(Icons.sports_cricket, color: Color(0xFFEF4444), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Record Wicket',
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (widget.isFreeHit) ...[
                          const SizedBox(width: 8),
                          _FreeHitBadge(),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _Label('DELIVERY TYPE', context),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _DeliveryChip(
                        label: 'Legal',
                        selected: _deliveryType == 'LEGAL',
                        color: const Color(0xFF10B981),
                        onTap: () => _onDeliveryChanged('LEGAL'),
                      ),
                      const SizedBox(width: 8),
                      _DeliveryChip(
                        label: 'Wide',
                        selected: _deliveryType == 'WIDE',
                        color: const Color(0xFFF59E0B),
                        onTap: () => _onDeliveryChanged('WIDE'),
                      ),
                      const SizedBox(width: 8),
                      _DeliveryChip(
                        label: 'No Ball',
                        selected: _deliveryType == 'NO_BALL',
                        color: const Color(0xFFEF4444),
                        onTap: () => _onDeliveryChanged('NO_BALL'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _Label('HOW OUT', context),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.95,
                    children: _kDismissals.map((m) {
                      final valid = _isValid(m.key);
                      final selected = _dismissalType == m.key;
                      return _DismissalBox(
                        meta: m,
                        selected: selected,
                        enabled: valid,
                        onTap: () => _selectDismissal(m.key),
                      );
                    }).toList(),
                  ),

                  if (_dismissalType == 'RUN_OUT') ...[
                    const SizedBox(height: 16),
                    _Label('WHO IS OUT', context),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _BatterToggle(
                            label: widget.strikerName,
                            sublabel: 'Striker',
                            selected: _dismissedIsStriker,
                            onTap: () => setState(() => _dismissedIsStriker = true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _BatterToggle(
                            label: widget.nonStrikerName,
                            sublabel: 'Non-Striker',
                            selected: !_dismissedIsStriker,
                            onTap: () => setState(() => _dismissedIsStriker = false),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (_needsFielder) ...[
                    const SizedBox(height: 16),
                    _Label('FIELDER', context),
                    const SizedBox(height: 8),
                    if (_autoFielderId != null)
                      _AutoFilledFielder(name: _fielderName(_fielderId))
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _fielderId,
                        decoration: InputDecoration(
                          hintText: 'Select fielder',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('None'),
                          ),
                          ...widget.fieldingTeam.map(
                            (p) => DropdownMenuItem<String>(
                              value: p.profileId,
                              child: Text(p.name),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _fielderId = v),
                      ),
                  ],

                  const SizedBox(height: 16),
                  _Label('COMPLETED RUNS', context),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i < 4 ? 6 : 0),
                          child: SizedBox(
                            height: 44,
                            child: Material(
                              color: _completedRuns == i
                                  ? const Color(0xFFB91C1C)
                                  : context.fg.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () => setState(() => _completedRuns = i),
                                borderRadius: BorderRadius.circular(8),
                                child: Center(
                                  child: Text(
                                    '$i',
                                    style: TextStyle(
                                      color: _completedRuns == i
                                          ? Colors.white
                                          : context.fg,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _canConfirm
                          ? () => widget.onConfirm(
                                dismissalType: _dismissalType,
                                deliveryType: _deliveryType,
                                fielderId: _needsFielder
                                    ? (_fielderId ?? _autoFielderId)
                                    : null,
                                dismissedIsStriker: _dismissedIsStriker,
                                completedRuns: _completedRuns,
                                crossed: false,
                              )
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFB91C1C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Confirm Wicket',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Small widgets ─────────────────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  const _Handle({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: child,
      );
}

class _FreeHitBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange, width: 1),
        ),
        child: const Text(
          'FREE HIT',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

Widget _Label(String text, BuildContext context) => Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );

class _DeliveryChip extends StatelessWidget {
  const _DeliveryChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
}

class _DismissalBox extends StatelessWidget {
  const _DismissalBox({
    required this.meta,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final _DismissalMeta meta;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final bg = selected
        ? const Color(0xFFB91C1C)
        : fg.withValues(alpha: enabled ? 0.08 : 0.04);
    return Opacity(
      opacity: enabled ? 1.0 : 0.30,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: selected
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: fg.withValues(alpha: enabled ? 0.14 : 0.06),
                    ),
                  ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  meta.icon,
                  size: 22,
                  color: selected ? Colors.white : fg,
                ),
                const SizedBox(height: 4),
                Text(
                  meta.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : fg,
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BatterToggle extends StatelessWidget {
  const _BatterToggle({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: selected ? const Color(0xFFB91C1C) : fg.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                sublabel,
                style: TextStyle(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.7)
                      : fg.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoFilledFielder extends StatelessWidget {
  const _AutoFilledFielder({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: fg, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            'auto',
            style: TextStyle(color: fg.withValues(alpha: 0.4), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
