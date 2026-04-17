import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../create_match/presentation/form_widgets.dart';
import '../../teams/controller/teams_controller.dart';
import '../controller/create_team_controller.dart';

class CreateTeamScreen extends ConsumerStatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  ConsumerState<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _imagePicker = ImagePicker();

  String _teamType = 'FRIENDLY';
  bool _iAmCaptain = false;
  XFile? _logoFile;
  Uint8List? _logoBytes;

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

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(createTeamControllerProvider.notifier).createTeam(
          name: _nameController.text.trim(),
          shortName: _shortNameController.text.trim(),
          logoFile: _logoFile,
          city: _cityController.text.trim(),
          teamType: _teamType,
          iAmCaptain: _iAmCaptain,
        );

    if (!mounted) return;

    if (ok) {
      ref.invalidate(teamsControllerProvider);
      showDialog(
        context: context,
        builder: (_) => _SquadCreatedDialog(
          squadName: _nameController.text.trim(),
          isCaptain: _iAmCaptain,
          onDone: () {
            Navigator.pop(context);
            context.pop();
          },
        ),
      );
    } else {
      final error = ref.read(createTeamControllerProvider).error ??
          'Something went wrong';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _pickLogo() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _logoFile = file;
        _logoBytes = bytes;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not pick the team logo.')),
      );
    }
  }

  void _removeLogo() {
    setState(() {
      _logoFile = null;
      _logoBytes = null;
    });
  }

  void _showTypeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TypeSelectionSheet(
        options: _teamTypes,
        selectedType: _teamType,
        onSelected: (val) {
          setState(() => _teamType = val);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createTeamControllerProvider);
    final darkBg = const Color(0xFF050505);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.stroke),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: context.fg, size: 18),
          ),
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            const SwingSectionLabel(label: 'Team Logo'),
            const SizedBox(height: 12),
            _TeamLogoPicker(
              imageBytes: _logoBytes,
              onPick: _pickLogo,
              onRemove: _logoFile == null ? null : _removeLogo,
            ),
            const SizedBox(height: 32),

            const SwingSectionLabel(label: 'Basic Info'),
            const SizedBox(height: 12),
            SwingTextField(
              controller: _nameController,
              hint: 'e.g. Mumbai Tigers',
              prefixIcon: Icons.shield_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a squad name' : null,
            ),
            const SizedBox(height: 16),
            SwingTextField(
              controller: _cityController,
              hint: 'City',
              prefixIcon: Icons.location_city_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a city' : null,
            ),
            const SizedBox(height: 16),
            SwingTextField(
              controller: _shortNameController,
              hint: 'Short Name (e.g. MT)',
              prefixIcon: Icons.short_text_rounded,
              maxLength: 5,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              ],
            ),
            const SizedBox(height: 32),

            const SwingSectionLabel(label: 'Squad Type'),
            const SizedBox(height: 12),
            _SquadTypeSelector(
              value: _teamTypes.firstWhere((e) => e.$1 == _teamType).$2,
              onTap: _showTypeSelector,
            ),
            const SizedBox(height: 32),

            // Captain toggle
            GestureDetector(
              onTap: () => setState(() => _iAmCaptain = !_iAmCaptain),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _iAmCaptain ? context.accent : context.stroke,
                    width: _iAmCaptain ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _iAmCaptain
                            ? context.accent.withValues(alpha: 0.1)
                            : context.bg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: _iAmCaptain ? context.accent : context.fgSub,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'I am the Captain',
                            style: TextStyle(
                              color: _iAmCaptain ? context.accent : context.fg,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Assign roles like captain/keeper later',
                            style: TextStyle(color: context.fgSub, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _iAmCaptain
                          ? Icon(Icons.check_circle_rounded,
                              key: const ValueKey('checked'),
                              color: context.accent,
                              size: 24)
                          : Icon(Icons.radio_button_unchecked_rounded,
                              key: const ValueKey('unchecked'),
                              color: context.fgSub.withValues(alpha: 0.3),
                              size: 24),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            SwingSubmitButton(
              label: 'Create Squad',
              isLoading: state.isSubmitting,
              onTap: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _SquadTypeSelector extends StatelessWidget {
  const _SquadTypeSelector({required this.value, required this.onTap});
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.stroke),
        ),
        child: Row(
          children: [
            Icon(Icons.category_rounded, color: context.fgSub, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: context.fgSub),
          ],
        ),
      ),
    );
  }
}

class _TypeSelectionSheet extends StatelessWidget {
  const _TypeSelectionSheet({
    required this.options,
    required this.selectedType,
    required this.onSelected,
  });

  final List<(String, String)> options;
  final String selectedType;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: context.stroke, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.stroke,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select Squad Type',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final type = options[index];
                final isSelected = type.$1 == selectedType;
                return GestureDetector(
                  onTap: () => onSelected(type.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.accent.withValues(alpha: 0.1)
                          : context.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? context.accent : context.stroke,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            type.$2,
                            style: TextStyle(
                              color: isSelected ? context.accent : context.fg,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded,
                              color: context.accent, size: 20),
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
      backgroundColor: context.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child:
                  Icon(Icons.shield_rounded, color: context.accent, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              'Squad Created!',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              '"$squadName" is ready.\n\n${isCaptain ? 'You are set as captain.' : 'Personalize the squad by adding players and assigning roles.'}',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.fgSub, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: onDone,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: context.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Done',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
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

class _TeamLogoPicker extends StatelessWidget {
  const _TeamLogoPicker({
    required this.imageBytes,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? imageBytes;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: context.bg,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: imageBytes != null
                ? Image.memory(imageBytes!, fit: BoxFit.cover)
                : Icon(Icons.shield_rounded, color: context.fgSub.withValues(alpha: 0.3), size: 34),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Squad Logo',
                  style: TextStyle(
                        color: context.fg,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _LogoActionChip(
                      icon: imageBytes == null
                          ? Icons.add_photo_alternate_rounded
                          : Icons.edit_rounded,
                      label: imageBytes == null ? 'Add' : 'Change',
                      onTap: onPick,
                    ),
                    if (onRemove != null) ...[
                      const SizedBox(width: 8),
                      _LogoActionChip(
                        icon: Icons.close_rounded,
                        label: 'Delete',
                        onTap: onRemove!,
                        isDanger: true,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoActionChip extends StatelessWidget {
  const _LogoActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDanger ? context.danger.withValues(alpha: 0.1) : context.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDanger ? context.danger.withValues(alpha: 0.2) : context.stroke,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDanger ? context.danger : context.fg,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                    color: isDanger ? context.danger : context.fg,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

