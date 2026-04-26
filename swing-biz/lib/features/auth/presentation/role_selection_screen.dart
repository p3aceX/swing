import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';
import '../controller/auth_controller.dart';

const _bg = Color(0xFFF3F4F6);
const _surface = Color(0xFFFFFFFF);
const _line = Color(0xFFE1E5EA);
const _text = Color(0xFF0D1117);
const _muted = Color(0xFF6E7685);
const _accent = Color(0xFF059669);
const _deep = Color(0xFF064E3B);

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  final _businessName = TextEditingController();
  final _contactName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  final _gst = TextEditingController();
  final _pan = TextEditingController();
  final _bankAccount = TextEditingController();
  final _ifsc = TextEditingController();
  final _beneficiary = TextEditingController();
  final _upiId = TextEditingController();

  bool _editing = false;
  int _profileTab = 0;
  String? _seededBusinessId;
  String _savedBankAccount = '';
  String _savedIfsc = '';
  String _savedBeneficiary = '';
  String _savedUpiId = '';

  @override
  void dispose() {
    _businessName.dispose();
    _contactName.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    _pincode.dispose();
    _gst.dispose();
    _pan.dispose();
    _bankAccount.dispose();
    _ifsc.dispose();
    _beneficiary.dispose();
    _upiId.dispose();
    super.dispose();
  }

  void _seed(BusinessAccount? business) {
    if (_editing) return;
    final id = business?.id ?? 'none';
    final previousId = _seededBusinessId;
    if (previousId == id) return;
    _seededBusinessId = id;
    _businessName.text = business?.businessName ?? '';
    _contactName.text = business?.contactName ?? '';
    _phone.text = business?.phone ?? '';
    _email.text = business?.email ?? '';
    _address.text = business?.address ?? '';
    _city.text = business?.city ?? '';
    _state.text = business?.state ?? '';
    _pincode.text = business?.pincode ?? '';
    _gst.text = business?.gstNumber ?? '';
    _pan.text = business?.panNumber ?? '';

    if (previousId != null && previousId != id) {
      _savedBankAccount = '';
      _savedIfsc = '';
      _savedBeneficiary = '';
      _savedUpiId = '';
      _restorePaymentSnapshot();
    }
  }

  Future<bool> _saveBusiness() async {
    if (_businessName.text.trim().isEmpty) {
      setState(() => _profileTab = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business name is required')),
      );
      return false;
    }

    try {
      await ref.read(hostBizRepositoryProvider).upsertBusinessDetails(
            BusinessDetailsInput(
              businessName: _businessName.text.trim(),
              contactName: _emptyToNull(_contactName.text),
              phone: _emptyToNull(_phone.text),
              email: _emptyToNull(_email.text),
              address: _emptyToNull(_address.text),
              city: _emptyToNull(_city.text),
              state: _emptyToNull(_state.text),
              pincode: _emptyToNull(_pincode.text),
              gstNumber: _emptyToNull(_gst.text),
              panNumber: _emptyToNull(_pan.text),
            ),
          );
      _savePaymentSnapshot();
      ref.invalidate(meProvider);
      if (!mounted) return false;
      setState(() {
        _editing = false;
        _seededBusinessId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      return true;
    } catch (error) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save profile: $error')),
      );
      return false;
    }
  }

  void _cancelEdit(BusinessAccount? business) {
    setState(() {
      _editing = false;
      _seededBusinessId = null;
    });
    _seed(business);
    _restorePaymentSnapshot();
  }

  void _savePaymentSnapshot() {
    _savedBankAccount = _bankAccount.text;
    _savedIfsc = _ifsc.text;
    _savedBeneficiary = _beneficiary.text;
    _savedUpiId = _upiId.text;
  }

  void _restorePaymentSnapshot() {
    _bankAccount.text = _savedBankAccount;
    _ifsc.text = _savedIfsc;
    _beneficiary.text = _savedBeneficiary;
    _upiId.text = _savedUpiId;
  }

  @override
  Widget build(BuildContext context) {
    final meAsync = ref.watch(meProvider);
    final session = ref.watch(sessionControllerProvider);
    final cameFromDashboard = session.status == AuthStatus.authenticated;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () async {
            if (cameFromDashboard) {
              if (context.mounted) context.go(AppRoutes.dashboard);
              return;
            }
            ref.read(authControllerProvider.notifier).resetToPhone();
            await ref.read(sessionControllerProvider.notifier).signOut();
            if (context.mounted) context.go(AppRoutes.login);
          },
        ),
      ),
      body: SafeArea(
        child: meAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load profile.\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _muted),
              ),
            ),
          ),
          data: (me) {
            if (me == null) {
              return const Center(
                child: Text(
                  'Profile unavailable. Please login again.',
                  style: TextStyle(color: _muted),
                ),
              );
            }

            _seed(me.businessAccount);
            final activeRole = session.activeProfile;
            final profiles =
                me.businessStatus.availableProfiles.toSet().toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _CompactProfileCard(
                  me: me,
                  activeProfile: activeRole == null
                      ? 'No workspace'
                      : _roleTitle(activeRole),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _ProfileDetailsPage(
                        me: me,
                        activeProfile: activeRole == null
                            ? 'No workspace'
                            : _roleTitle(activeRole),
                        selectedTab: _profileTab,
                        controllers: _ProfileControllers(
                          businessName: _businessName,
                          contactName: _contactName,
                          phone: _phone,
                          email: _email,
                          address: _address,
                          city: _city,
                          state: _state,
                          pincode: _pincode,
                          gst: _gst,
                          pan: _pan,
                          bankAccount: _bankAccount,
                          ifsc: _ifsc,
                          beneficiary: _beneficiary,
                          upiId: _upiId,
                        ),
                        onTabChanged: (tab) =>
                            setState(() => _profileTab = tab),
                        onCancel: () => _cancelEdit(me.businessAccount),
                        onSave: _saveBusiness,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _WorkspacesSection(
                  profiles: profiles,
                  activeRole: activeRole,
                  onCreateProfile: () => context.go(AppRoutes.chooseProfile),
                  onSelectRole: (role) async {
                    await ref
                        .read(sessionControllerProvider.notifier)
                        .setActiveProfile(role);
                    if (context.mounted) context.go(AppRoutes.dashboard);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CompactProfileCard extends StatelessWidget {
  const _CompactProfileCard({
    required this.me,
    required this.activeProfile,
    required this.onTap,
  });

  final BizMeResponse me;
  final String activeProfile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              _Avatar(name: me.user.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fallback(me.user.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _fallback(me.businessAccount?.businessName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _StatusChip(label: activeProfile),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: _muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileDetailsPage extends StatefulWidget {
  const _ProfileDetailsPage({
    required this.me,
    required this.activeProfile,
    required this.selectedTab,
    required this.controllers,
    required this.onTabChanged,
    required this.onCancel,
    required this.onSave,
  });

  final BizMeResponse me;
  final String activeProfile;
  final int selectedTab;
  final _ProfileControllers controllers;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onCancel;
  final Future<bool> Function() onSave;

  @override
  State<_ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<_ProfileDetailsPage> {
  late int _selectedTab;
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.selectedTab;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final saved = await widget.onSave();
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (saved) _editing = false;
    });
  }

  void _cancel() {
    widget.onCancel();
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Profile details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _ProfileCard(
              me: widget.me,
              activeProfile: widget.activeProfile,
              editing: _editing,
              saving: _saving,
              selectedTab: _selectedTab,
              controllers: widget.controllers,
              onTabChanged: (tab) {
                widget.onTabChanged(tab);
                setState(() => _selectedTab = tab);
              },
              onEdit: () => setState(() => _editing = true),
              onCancel: _cancel,
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.me,
    required this.activeProfile,
    required this.editing,
    required this.saving,
    required this.selectedTab,
    required this.controllers,
    required this.onTabChanged,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
  });

  final BizMeResponse me;
  final String activeProfile;
  final bool editing;
  final bool saving;
  final int selectedTab;
  final _ProfileControllers controllers;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(name: me.user.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fallback(me.user.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_fallback(me.businessAccount?.businessName)} • ${me.user.phone}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _StatusChip(label: activeProfile),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (editing)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Cancel',
                      onPressed: saving ? null : onCancel,
                      icon: const Icon(Icons.close_rounded),
                    ),
                    FilledButton(
                      onPressed: saving ? null : onSave,
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: _text,
                        minimumSize: const Size(54, 38),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ],
                )
              else
                IconButton.filled(
                  tooltip: 'Edit profile',
                  onPressed: onEdit,
                  style: IconButton.styleFrom(
                    backgroundColor: _deep,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.edit_rounded),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _ProfileTabs(
            selected: selectedTab,
            onChanged: onTabChanged,
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: switch (selectedTab) {
              0 => _OwnerDetailsTab(key: const ValueKey('owner'), me: me),
              1 => _BusinessDetailsTab(
                  key: const ValueKey('business'),
                  editing: editing,
                  controllers: controllers,
                ),
              _ => _PaymentDetailsTab(
                  key: const ValueKey('payment'),
                  editing: editing,
                  controllers: controllers,
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final initial = _fallback(name)[0].toUpperCase();
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _deep,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _text,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const tabs = ['Owner details', 'Business details', 'Payment details'];
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final active = selected == index;
          return InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? _deep : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: active ? Colors.white : _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OwnerDetailsTab extends StatelessWidget {
  const _OwnerDetailsTab({super.key, required this.me});

  final BizMeResponse me;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: [
        _ReadRow('Owner name', _fallback(me.user.name)),
        _ReadRow('Phone', _fallback(me.user.phone)),
        _ReadRow('Email', _fallback(me.user.email)),
        _ReadRow('Owner ID', _fallback(me.user.id)),
      ],
    );
  }
}

class _BusinessDetailsTab extends StatelessWidget {
  const _BusinessDetailsTab({
    super.key,
    required this.editing,
    required this.controllers,
  });

  final bool editing;
  final _ProfileControllers controllers;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: [
        _EditRow(
          label: 'Business name',
          controller: controllers.businessName,
          editing: editing,
        ),
        _EditRow(
          label: 'Contact name',
          controller: controllers.contactName,
          editing: editing,
        ),
        _EditRow(
          label: 'Phone',
          controller: controllers.phone,
          editing: editing,
          keyboardType: TextInputType.phone,
        ),
        _EditRow(
          label: 'Email',
          controller: controllers.email,
          editing: editing,
          keyboardType: TextInputType.emailAddress,
        ),
        _EditRow(
          label: 'Address',
          controller: controllers.address,
          editing: editing,
          maxLines: 2,
        ),
        _EditRow(
          label: 'City',
          controller: controllers.city,
          editing: editing,
        ),
        _EditRow(
          label: 'State',
          controller: controllers.state,
          editing: editing,
        ),
        _EditRow(
          label: 'Pincode',
          controller: controllers.pincode,
          editing: editing,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }
}

class _PaymentDetailsTab extends StatelessWidget {
  const _PaymentDetailsTab({
    super.key,
    required this.editing,
    required this.controllers,
  });

  final bool editing;
  final _ProfileControllers controllers;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: [
        _EditRow(
          label: 'GST',
          controller: controllers.gst,
          editing: editing,
          textCapitalization: TextCapitalization.characters,
        ),
        _EditRow(
          label: 'PAN',
          controller: controllers.pan,
          editing: editing,
          textCapitalization: TextCapitalization.characters,
        ),
        _EditRow(
          label: 'Bank account',
          controller: controllers.bankAccount,
          editing: editing,
          keyboardType: TextInputType.number,
        ),
        _EditRow(
          label: 'IFSC',
          controller: controllers.ifsc,
          editing: editing,
          textCapitalization: TextCapitalization.characters,
        ),
        _EditRow(
          label: 'Beneficiary',
          controller: controllers.beneficiary,
          editing: editing,
        ),
        _EditRow(
          label: 'UPI ID',
          controller: controllers.upiId,
          editing: editing,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}

class _WorkspacesSection extends StatelessWidget {
  const _WorkspacesSection({
    required this.profiles,
    required this.activeRole,
    required this.onCreateProfile,
    required this.onSelectRole,
  });

  final List<BizProfileType> profiles;
  final BizProfileType? activeRole;
  final VoidCallback onCreateProfile;
  final ValueChanged<BizProfileType> onSelectRole;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Workspaces',
                style: TextStyle(
                  color: _text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onCreateProfile,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: _deep,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (profiles.isEmpty)
          _EmptyWorkspaceCard(onCreateProfile: onCreateProfile)
        else
          ...profiles.map(
            (profile) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RoleCard(
                title: _roleTitle(profile),
                subtitle: _roleSubtitle(profile),
                icon: _roleIcon(profile),
                selected: activeRole == profile,
                onTap: () => onSelectRole(profile),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyWorkspaceCard extends StatelessWidget {
  const _EmptyWorkspaceCard({required this.onCreateProfile});

  final VoidCallback onCreateProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No workspaces available yet.',
            style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onCreateProfile,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Workspace'),
            style: FilledButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: _text,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadRow extends StatelessWidget {
  const _ReadRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _text,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditRow extends StatelessWidget {
  const _EditRow({
    required this.label,
    required this.controller,
    required this.editing,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final bool editing;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    if (!editing) return _ReadRow(label, _fallback(controller.text));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _deep, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? _deep : _line,
              width: selected ? 1.3 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected ? _accent : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _line),
                ),
                child: Icon(icon, color: _text, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: selected ? _deep : _muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileControllers {
  const _ProfileControllers({
    required this.businessName,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.gst,
    required this.pan,
    required this.bankAccount,
    required this.ifsc,
    required this.beneficiary,
    required this.upiId,
  });

  final TextEditingController businessName;
  final TextEditingController contactName;
  final TextEditingController phone;
  final TextEditingController email;
  final TextEditingController address;
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController pincode;
  final TextEditingController gst;
  final TextEditingController pan;
  final TextEditingController bankAccount;
  final TextEditingController ifsc;
  final TextEditingController beneficiary;
  final TextEditingController upiId;
}

String _fallback(String? value) {
  final safe = value?.trim() ?? '';
  return safe.isEmpty ? 'Not set' : safe;
}

String? _emptyToNull(String value) {
  final safe = value.trim();
  return safe.isEmpty ? null : safe;
}

String _roleTitle(BizProfileType role) => switch (role) {
      BizProfileType.academy => 'Academy Owner',
      BizProfileType.coach => 'Coach',
      BizProfileType.arena => 'Arena Owner',
      BizProfileType.arenaManager => 'Arena Manager',
      BizProfileType.store => 'Store',
    };

String _roleSubtitle(BizProfileType role) => switch (role) {
      BizProfileType.academy => 'Academy operations',
      BizProfileType.coach => 'Sessions and students',
      BizProfileType.arena => 'Bookings and pricing',
      BizProfileType.arenaManager => 'Courts and schedules',
      BizProfileType.store => 'Inventory and orders',
    };

IconData _roleIcon(BizProfileType role) => switch (role) {
      BizProfileType.academy => Icons.school_rounded,
      BizProfileType.coach => Icons.sports_rounded,
      BizProfileType.arena => Icons.stadium_rounded,
      BizProfileType.arenaManager => Icons.manage_accounts_rounded,
      BizProfileType.store => Icons.storefront_rounded,
    };
