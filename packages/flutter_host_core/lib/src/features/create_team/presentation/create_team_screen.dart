import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_host_core/host_ui.dart';
import '../controller/create_team_controller.dart';

class HostCreateTeamScreen extends ConsumerStatefulWidget {
  const HostCreateTeamScreen({
    super.key,
    this.academyId,
    this.coachId,
    this.arenaId,
    this.onPickLogo,
    this.onUploadLogo,
    this.onSuccess,
    this.onCreated,
  });

  /// Stamp this team as owned by an academy. Pass from the club/coach app context.
  final String? academyId;

  /// Stamp this team as owned by a specific coach.
  final String? coachId;

  /// Stamp this team as owned by an arena.
  final String? arenaId;

  /// Called when user taps add/change logo. Should open the picker and return
  /// the image bytes + file extension (e.g. 'jpg'), or null if cancelled.
  final Future<({Uint8List bytes, String extension})?> Function()? onPickLogo;

  /// Called at submit time with the picked bytes. Should upload and return URL.
  final Future<String?> Function(Uint8List bytes, String extension)? onUploadLogo;

  /// Called after a squad is successfully created (e.g. to invalidate caches).
  final VoidCallback? onSuccess;

  /// Called with the new team ID after creation — use this to navigate to detail.
  /// If null, shows a success dialog that pops back instead.
  final void Function(String teamId)? onCreated;

  @override
  ConsumerState<HostCreateTeamScreen> createState() => _HostCreateTeamScreenState();
}

class _HostCreateTeamScreenState extends ConsumerState<HostCreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _shortNameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _mottoCtrl = TextEditingController();
  final _homeGroundCtrl = TextEditingController();

  String _teamType = 'FRIENDLY';
  String? _ageGroup;
  String? _format;
  String? _skillLevel;
  bool _iAmCaptain = false;
  bool _isPublic = true;
  int? _foundedYear;
  Uint8List? _logoBytes;
  String? _logoExtension;

  static const _teamTypes = [
    ('CLUB', 'Club'),
    ('CORPORATE', 'Corporate'),
    ('ACADEMY', 'Academy'),
    ('SCHOOL', 'School'),
    ('COLLEGE', 'College'),
    ('DISTRICT', 'District'),
    ('STATE', 'State'),
    ('NATIONAL', 'National'),
    ('FRIENDLY', 'Friendly'),
    ('GULLY', 'Gully'),
  ];

  static const _ageGroups = [
    ('OPEN', 'Open'),
    ('U19', 'Under 19'),
    ('U23', 'Under 23'),
    ('U30', 'Under 30'),
    ('VETERANS', 'Veterans (35+)'),
  ];

  static const _formats = [
    ('T20', 'T20'),
    ('ODI', 'ODI (50 overs)'),
    ('TEST', 'Test / Multi-day'),
    ('ALL', 'All formats'),
  ];

  static const _skillLevels = [
    ('BEGINNER', 'Beginner'),
    ('INTERMEDIATE', 'Intermediate'),
    ('ADVANCED', 'Advanced'),
    ('PROFESSIONAL', 'Professional'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shortNameCtrl.dispose();
    _cityCtrl.dispose();
    _mottoCtrl.dispose();
    _homeGroundCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    String? logoUrl;
    if (_logoBytes != null && _logoExtension != null && widget.onUploadLogo != null) {
      logoUrl = await widget.onUploadLogo!(_logoBytes!, _logoExtension!);
    }

    final id = await ref.read(hostCreateTeamControllerProvider.notifier).createTeam(
      name: _nameCtrl.text.trim(),
      shortName: _shortNameCtrl.text.trim(),
      logoUrl: logoUrl,
      city: _cityCtrl.text.trim(),
      teamType: _teamType,
      iAmCaptain: _iAmCaptain,
      academyId: widget.academyId,
      coachId: widget.coachId,
      arenaId: widget.arenaId,
      motto: _mottoCtrl.text.trim(),
      homeGroundName: _homeGroundCtrl.text.trim(),
      foundedYear: _foundedYear,
      ageGroup: _ageGroup,
      format: _format,
      skillLevel: _skillLevel,
      isPublic: _isPublic,
    );

    if (!mounted) return;

    if (id != null && id.isNotEmpty) {
      widget.onSuccess?.call();
      if (widget.onCreated != null) {
        widget.onCreated!(id);
      } else {
        showDialog(
          context: context,
          builder: (_) => _SquadCreatedDialog(
            squadName: _nameCtrl.text.trim(),
            isCaptain: _iAmCaptain,
            onDone: () {
              Navigator.pop(context);
              Navigator.of(context).maybePop();
            },
          ),
        );
      }
    } else {
      final error = ref.read(hostCreateTeamControllerProvider).error ?? 'Something went wrong';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _pickLogo() async {
    if (widget.onPickLogo == null) return;
    final result = await widget.onPickLogo!();
    if (result == null || !mounted) return;
    setState(() {
      _logoBytes = result.bytes;
      _logoExtension = result.extension;
    });
  }

  void _removeLogo() => setState(() {
        _logoBytes = null;
        _logoExtension = null;
      });

  void _showPicker<T>({
    required String title,
    required List<(String, String)> options,
    required String? selected,
    required void Function(String?) onSelected,
    bool allowClear = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: title,
        options: options,
        selectedValue: selected,
        allowClear: allowClear,
        onSelected: (val) {
          onSelected(val);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _pickYear() async {
    final now = DateTime.now().year;
    final picked = await showDialog<int>(
      context: context,
      builder: (_) => _YearPickerDialog(
        initialYear: _foundedYear ?? now,
        minYear: 1900,
        maxYear: now,
      ),
    );
    if (picked != null) setState(() => _foundedYear = picked);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostCreateTeamControllerProvider);
    final typeLabel = _teamTypes.firstWhere((e) => e.$1 == _teamType).$2;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.fg, size: 20),
        ),
        title: Text(
          'New Squad',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Logo ─────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickLogo,
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: context.surf,
                      backgroundImage: _logoBytes != null ? MemoryImage(_logoBytes!) : null,
                      child: _logoBytes == null
                          ? Icon(Icons.shield_rounded, color: context.fgSub, size: 28)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Squad Logo',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (widget.onPickLogo != null)
                              TextButton.icon(
                                onPressed: _pickLogo,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: Icon(
                                  _logoBytes == null
                                      ? Icons.add_photo_alternate_rounded
                                      : Icons.edit_rounded,
                                  size: 16,
                                  color: context.accent,
                                ),
                                label: Text(
                                  _logoBytes == null ? 'Add photo' : 'Change',
                                  style: TextStyle(color: context.accent, fontSize: 13),
                                ),
                              ),
                            if (_logoBytes != null) ...[
                              const SizedBox(width: 16),
                              TextButton.icon(
                                onPressed: _removeLogo,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: Icon(Icons.close_rounded, size: 16, color: context.danger),
                                label: Text('Remove',
                                    style: TextStyle(color: context.danger, fontSize: 13)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.stroke),

            // ── Basic Info ────────────────────────────────────────────────────
            _SectionHeader(label: 'Basic Info'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SwingTextField(
                controller: _nameCtrl,
                hint: 'Squad name  (e.g. Mumbai Tigers)',
                prefixIcon: Icons.shield_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a squad name' : null,
              ),
            ),
            Divider(height: 1, indent: 20, color: context.stroke),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SwingTextField(
                controller: _cityCtrl,
                hint: 'City',
                prefixIcon: Icons.location_city_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a city' : null,
              ),
            ),
            Divider(height: 1, indent: 20, color: context.stroke),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SwingTextField(
                controller: _shortNameCtrl,
                hint: 'Short name  (e.g. MT)',
                prefixIcon: Icons.short_text_rounded,
                maxLength: 5,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
              ),
            ),
            Divider(height: 1, color: context.stroke),

            // ── Identity ──────────────────────────────────────────────────────
            _SectionHeader(label: 'Identity'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SwingTextField(
                controller: _mottoCtrl,
                hint: 'Team motto  (e.g. Play Hard, Win Harder)',
                prefixIcon: Icons.format_quote_rounded,
                maxLength: 80,
              ),
            ),
            Divider(height: 1, indent: 20, color: context.stroke),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SwingTextField(
                controller: _homeGroundCtrl,
                hint: 'Home ground  (e.g. Aishbagh Ground)',
                prefixIcon: Icons.stadium_rounded,
              ),
            ),
            Divider(height: 1, indent: 20, color: context.stroke),
            _PickerTile(
              icon: Icons.calendar_today_rounded,
              label: _foundedYear != null ? 'Founded $_foundedYear' : 'Founded year',
              isSet: _foundedYear != null,
              onTap: _pickYear,
              onClear: _foundedYear != null ? () => setState(() => _foundedYear = null) : null,
            ),
            Divider(height: 1, color: context.stroke),

            // ── Squad Type ────────────────────────────────────────────────────
            _SectionHeader(label: 'Squad Type'),
            _PickerTile(
              icon: Icons.category_rounded,
              label: typeLabel,
              isSet: true,
              onTap: () => _showPicker(
                title: 'Squad Type',
                options: _teamTypes,
                selected: _teamType,
                onSelected: (v) => setState(() => _teamType = v ?? 'FRIENDLY'),
              ),
            ),
            Divider(height: 1, indent: 20, color: context.stroke),
            _PickerTile(
              icon: Icons.people_alt_rounded,
              label: _ageGroup != null
                  ? _ageGroups.firstWhere((e) => e.$1 == _ageGroup).$2
                  : 'Age group  (optional)',
              isSet: _ageGroup != null,
              onTap: () => _showPicker(
                title: 'Age Group',
                options: _ageGroups,
                selected: _ageGroup,
                allowClear: true,
                onSelected: (v) => setState(() => _ageGroup = v),
              ),
              onClear: _ageGroup != null ? () => setState(() => _ageGroup = null) : null,
            ),
            Divider(height: 1, indent: 20, color: context.stroke),
            _PickerTile(
              icon: Icons.sports_cricket_rounded,
              label: _format != null
                  ? _formats.firstWhere((e) => e.$1 == _format).$2
                  : 'Format  (optional)',
              isSet: _format != null,
              onTap: () => _showPicker(
                title: 'Format',
                options: _formats,
                selected: _format,
                allowClear: true,
                onSelected: (v) => setState(() => _format = v),
              ),
              onClear: _format != null ? () => setState(() => _format = null) : null,
            ),
            Divider(height: 1, indent: 20, color: context.stroke),
            _PickerTile(
              icon: Icons.bar_chart_rounded,
              label: _skillLevel != null
                  ? _skillLevels.firstWhere((e) => e.$1 == _skillLevel).$2
                  : 'Skill level  (optional)',
              isSet: _skillLevel != null,
              onTap: () => _showPicker(
                title: 'Skill Level',
                options: _skillLevels,
                selected: _skillLevel,
                allowClear: true,
                onSelected: (v) => setState(() => _skillLevel = v),
              ),
              onClear: _skillLevel != null ? () => setState(() => _skillLevel = null) : null,
            ),
            Divider(height: 1, color: context.stroke),

            // ── Settings ──────────────────────────────────────────────────────
            _SectionHeader(label: 'Settings'),
            SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              secondary: Icon(Icons.star_rounded,
                  color: _iAmCaptain ? context.accent : context.fgSub, size: 22),
              title: Text(
                'I am the Captain',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _iAmCaptain ? context.accent : context.fg,
                    ),
              ),
              subtitle: Text('Assign roles like captain/keeper later',
                  style: TextStyle(color: context.fgSub, fontSize: 12)),
              value: _iAmCaptain,
              activeTrackColor: context.accent,
              onChanged: (v) => setState(() => _iAmCaptain = v),
            ),
            Divider(height: 1, indent: 20, color: context.stroke),
            SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              secondary: Icon(Icons.public_rounded,
                  color: _isPublic ? context.accent : context.fgSub, size: 22),
              title: Text(
                'Public Squad',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _isPublic ? context.accent : context.fg,
                    ),
              ),
              subtitle: Text(
                _isPublic
                    ? 'Discoverable by other players'
                    : 'Only visible to members',
                style: TextStyle(color: context.fgSub, fontSize: 12),
              ),
              value: _isPublic,
              activeTrackColor: context.accent,
              onChanged: (v) => setState(() => _isPublic = v),
            ),
            Divider(height: 1, color: context.stroke),

            // ── Submit ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
              child: SwingSubmitButton(
                label: 'Create Squad',
                isLoading: state.isSubmitting,
                onTap: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: context.fgSub,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
        ),
      );
}

// ── Picker tile ────────────────────────────────────────────────────────────────

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.isSet,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final bool isSet;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: context.fgSub, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSet ? context.fg : context.fgSub,
                      ),
                ),
              ),
              if (onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: Icon(Icons.close_rounded, color: context.fgSub, size: 18),
                )
              else
                Icon(Icons.chevron_right_rounded, color: context.fgSub, size: 20),
            ],
          ),
        ),
      );
}

// ── Generic picker sheet ───────────────────────────────────────────────────────

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.allowClear = false,
  });

  final String title;
  final List<(String, String)> options;
  final String? selectedValue;
  final void Function(String?) onSelected;
  final bool allowClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: context.stroke, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900)),
          ),
          Divider(height: 1, color: context.stroke),
          if (allowClear && selectedValue != null)
            InkWell(
              onTap: () => onSelected(null),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Text('Clear selection',
                    style: TextStyle(color: context.danger, fontWeight: FontWeight.w600)),
              ),
            ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: options.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, indent: 20, color: context.stroke),
              itemBuilder: (context, index) {
                final opt = options[index];
                final isSelected = opt.$1 == selectedValue;
                return InkWell(
                  onTap: () => onSelected(opt.$1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opt.$2,
                            style: TextStyle(
                              color: isSelected ? context.accent : context.fg,
                              fontWeight:
                                  isSelected ? FontWeight.w800 : FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_rounded, color: context.accent, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Year picker dialog ─────────────────────────────────────────────────────────

class _YearPickerDialog extends StatefulWidget {
  const _YearPickerDialog({
    required this.initialYear,
    required this.minYear,
    required this.maxYear,
  });

  final int initialYear;
  final int minYear;
  final int maxYear;

  @override
  State<_YearPickerDialog> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<_YearPickerDialog> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(
      widget.maxYear - widget.minYear + 1,
      (i) => widget.maxYear - i,
    );
    return AlertDialog(
      backgroundColor: context.bg,
      title: Text('Founded Year',
          style: const TextStyle(fontWeight: FontWeight.w900)),
      content: SizedBox(
        width: 200,
        height: 260,
        child: ListWheelScrollView.useDelegate(
          itemExtent: 44,
          perspective: 0.003,
          diameterRatio: 2.5,
          physics: const FixedExtentScrollPhysics(),
          controller: FixedExtentScrollController(
              initialItem: years.indexOf(_selected).clamp(0, years.length - 1)),
          onSelectedItemChanged: (i) => setState(() => _selected = years[i]),
          childDelegate: ListWheelChildListDelegate(
            children: years
                .map((y) => Center(
                      child: Text(
                        '$y',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: y == _selected
                              ? FontWeight.w900
                              : FontWeight.w400,
                          color: y == _selected ? context.accent : context.fgSub,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: context.fgSub))),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

// ── Success dialog ─────────────────────────────────────────────────────────────

class _SquadCreatedDialog extends StatelessWidget {
  const _SquadCreatedDialog({
    required this.squadName,
    required this.isCaptain,
    required this.onDone,
  });

  final String squadName;
  final bool isCaptain;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.surf,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_rounded, color: context.accent, size: 40),
            const SizedBox(height: 16),
            Text(
              'Squad Created!',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(
              '"$squadName" is ready.\n\n${isCaptain ? 'You are set as captain.' : 'Add players and assign roles from the squad page.'}',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.fgSub, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: onDone, child: const Text('Done')),
            ),
          ],
        ),
      ),
    );
  }
}
