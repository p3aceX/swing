import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_host_core/host_ui.dart';
import '../controller/create_team_controller.dart';

class HostCreateTeamScreen extends ConsumerStatefulWidget {
  const HostCreateTeamScreen({
    super.key,
    this.onPickLogo,
    this.onUploadLogo,
    this.onSuccess,
  });

  /// Called when user taps add/change logo. Should open the picker and return
  /// the image bytes + file extension (e.g. 'jpg'), or null if cancelled.
  final Future<({Uint8List bytes, String extension})?> Function()? onPickLogo;

  /// Called at submit time with the picked bytes. Should upload and return URL.
  final Future<String?> Function(Uint8List bytes, String extension)?
      onUploadLogo;

  /// Called after a squad is successfully created (e.g. to invalidate caches).
  final VoidCallback? onSuccess;

  @override
  ConsumerState<HostCreateTeamScreen> createState() =>
      _HostCreateTeamScreenState();
}

class _HostCreateTeamScreenState extends ConsumerState<HostCreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _cityController = TextEditingController();

  String _teamType = 'FRIENDLY';
  bool _iAmCaptain = false;
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

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    String? logoUrl;
    if (_logoBytes != null &&
        _logoExtension != null &&
        widget.onUploadLogo != null) {
      logoUrl = await widget.onUploadLogo!(_logoBytes!, _logoExtension!);
    }

    final id = await ref
        .read(hostCreateTeamControllerProvider.notifier)
        .createTeam(
          name: _nameController.text.trim(),
          shortName: _shortNameController.text.trim(),
          logoUrl: logoUrl,
          city: _cityController.text.trim(),
          teamType: _teamType,
          iAmCaptain: _iAmCaptain,
        );

    if (!mounted) return;

    if (id != null && id.isNotEmpty) {
      widget.onSuccess?.call();
      showDialog(
        context: context,
        builder: (_) => _SquadCreatedDialog(
          squadName: _nameController.text.trim(),
          isCaptain: _iAmCaptain,
          onDone: () {
            Navigator.pop(context);
            Navigator.of(context).maybePop();
          },
        ),
      );
    } else {
      final error = ref.read(hostCreateTeamControllerProvider).error ??
          'Something went wrong';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
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
    final state = ref.watch(hostCreateTeamControllerProvider);
    final selectedLabel =
        _teamTypes.firstWhere((e) => e.$1 == _teamType).$2;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.fg, size: 20),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickLogo,
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: context.surf,
                      backgroundImage: _logoBytes != null
                          ? MemoryImage(_logoBytes!)
                          : null,
                      child: _logoBytes == null
                          ? Icon(Icons.shield_rounded,
                              color: context.fgSub, size: 28)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Squad Logo',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (widget.onPickLogo != null)
                              TextButton.icon(
                                onPressed: _pickLogo,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
                                  style: TextStyle(
                                      color: context.accent, fontSize: 13),
                                ),
                              ),
                            if (_logoBytes != null) ...[
                              const SizedBox(width: 16),
                              TextButton.icon(
                                onPressed: _removeLogo,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: Icon(Icons.close_rounded,
                                    size: 16, color: context.danger),
                                label: Text(
                                  'Remove',
                                  style: TextStyle(
                                      color: context.danger, fontSize: 13),
                                ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text(
                'Basic Info',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: context.fgSub,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SwingTextField(
                controller: _nameController,
                hint: 'Squad name  (e.g. Mumbai Tigers)',
                prefixIcon: Icons.shield_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Enter a squad name'
                        : null,
              ),
            ),
            Divider(height: 1, indent: 20, color: context.stroke),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SwingTextField(
                controller: _cityController,
                hint: 'City',
                prefixIcon: Icons.location_city_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a city' : null,
              ),
            ),
            Divider(height: 1, indent: 20, color: context.stroke),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SwingTextField(
                controller: _shortNameController,
                hint: 'Short name  (e.g. MT)',
                prefixIcon: Icons.short_text_rounded,
                maxLength: 5,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[A-Za-z0-9]')),
                ],
              ),
            ),
            Divider(height: 1, color: context.stroke),

            // ── Squad Type ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text(
                'Squad Type',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: context.fgSub,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
              ),
            ),
            InkWell(
              onTap: _showTypeSelector,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.category_rounded,
                        color: context.fgSub, size: 20),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        selectedLabel,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: context.fgSub, size: 20),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: context.stroke),

            // ── Captain toggle ────────────────────────────────────────────────
            SwitchListTile.adaptive(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              secondary: Icon(Icons.star_rounded,
                  color: _iAmCaptain ? context.accent : context.fgSub,
                  size: 22),
              title: Text(
                'I am the Captain',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _iAmCaptain ? context.accent : context.fg,
                    ),
              ),
              subtitle: Text(
                'Assign roles like captain/keeper later',
                style: TextStyle(color: context.fgSub, fontSize: 12),
              ),
              value: _iAmCaptain,
              activeTrackColor: context.accent,
              onChanged: (v) => setState(() => _iAmCaptain = v),
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

// ── Type selection sheet ───────────────────────────────────────────────────────

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
                  color: context.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text(
              'Squad Type',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          Divider(height: 1, color: context.stroke),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: options.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, indent: 20, color: context.stroke),
              itemBuilder: (context, index) {
                final type = options[index];
                final isSelected = type.$1 == selectedType;
                return InkWell(
                  onTap: () => onSelected(type.$1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            type.$2,
                            style: TextStyle(
                              color:
                                  isSelected ? context.accent : context.fg,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_rounded,
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
              style: TextStyle(
                  color: context.fgSub, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onDone,
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
