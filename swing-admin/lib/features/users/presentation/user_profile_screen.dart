import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../data/users_repository.dart';
import '../domain/admin_user.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final async = ref.watch(userDetailProvider(userId));

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: compact
            ? null
            : AppBar(
                leading: IconButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      context.pop();
                    } else {
                      context.go('/users');
                    }
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
                title: const Text('User profile'),
                bottom: const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: 'Overview'),
                    Tab(text: 'Player'),
                    Tab(text: 'Access'),
                    Tab(text: 'Edit'),
                  ],
                ),
              ),
        body: Column(
          children: [
            if (compact)
              Container(
                color: AppColors.surface,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (Navigator.of(context).canPop()) {
                                context.pop();
                              } else {
                                context.go('/users');
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            'User profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        Tab(text: 'Overview'),
                        Tab(text: 'Player'),
                        Tab(text: 'Access'),
                        Tab(text: 'Edit'),
                      ],
                    ),
                  ],
                ),
              ),
            Expanded(
              child: async.when(
                data: (user) => _ProfileBody(user: user),
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (e, _) => ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      e.toString(),
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        _OverviewTab(user: user),
        _PlayerTab(user: user),
        _AccessTab(user: user),
        _EditTab(user: user),
      ],
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _HeroCard(user: user),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Contact',
          children: [
            _DetailRow('Name', user.name),
            _DetailRow('Email', user.email.isEmpty ? '—' : user.email),
            _DetailRow('Phone', user.phone.isEmpty ? '—' : user.phone),
            _DetailRow('City', user.city.isEmpty ? '—' : user.city),
            _DetailRow('Language', user.language.isEmpty ? '—' : user.language),
          ],
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Account',
          children: [
            _DetailRow('ID', user.id),
            _DetailRow('Primary role', user.type.label),
            _DetailRow('Active role', user.activeRole),
            _DetailRow('Created', _fmtDateTime(user.joinedAt)),
            _DetailRow('Updated',
                user.updatedAt == null ? '—' : _fmtDateTime(user.updatedAt!)),
            _DetailRow('Last login',
                user.lastLoginAt == null ? '—' : _fmtDateTime(user.lastLoginAt!)),
          ],
        ),
      ],
    );
  }
}

class _PlayerTab extends StatelessWidget {
  const _PlayerTab({required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    final profile = user.playerProfile;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (profile == null)
          const _EmptyCard(
            title: 'No player profile',
            body: 'This user does not currently expose a nested player profile in the admin API response.',
          )
        else ...[
          _SectionCard(
            title: 'Player profile',
            children: [
              _DetailRow('Username', profile.username.isEmpty ? '—' : profile.username),
              _DetailRow('Gender', profile.gender.isEmpty ? '—' : profile.gender),
              _DetailRow('DOB',
                  profile.dateOfBirth == null ? '—' : DateFormat('d MMM y').format(profile.dateOfBirth!)),
              _DetailRow('Role', profile.playerRole.isEmpty ? '—' : profile.playerRole),
              _DetailRow('Batting', profile.battingStyle.isEmpty ? '—' : profile.battingStyle),
              _DetailRow('Bowling', profile.bowlingStyle.isEmpty ? '—' : profile.bowlingStyle),
              _DetailRow('Level', profile.level.isEmpty ? '—' : profile.level),
              _DetailRow('Verification',
                  profile.verificationLevel.isEmpty ? '—' : profile.verificationLevel),
              _DetailRow('Location',
                  [profile.city, profile.state].where((e) => e.isNotEmpty).join(', ').ifEmpty('—')),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Performance snapshot',
            children: [
              _DetailRow('Swing index', profile.swingIndex.toStringAsFixed(1)),
              _DetailRow('Matches played', profile.matchesPlayed.toString()),
              _DetailRow('Matches won', profile.matchesWon.toString()),
              _DetailRow('Runs', profile.totalRuns.toString()),
              _DetailRow('Highest score', profile.highestScore.toString()),
              _DetailRow('Wickets', profile.totalWickets.toString()),
              _DetailRow('Followers', profile.followersCount.toString()),
              _DetailRow('Following', profile.followingCount.toString()),
            ],
          ),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Bio',
              children: [
                Text(
                  profile.bio,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

class _AccessTab extends ConsumerStatefulWidget {
  const _AccessTab({required this.user});

  final AdminUser user;

  @override
  ConsumerState<_AccessTab> createState() => _AccessTabState();
}

class _AccessTabState extends ConsumerState<_AccessTab> {
  bool _busy = false;
  String? _message;

  Future<void> _toggleBlocked() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await ref
          .read(usersRepositoryProvider)
          .setBlocked(widget.user.id, !widget.user.isBlocked);
      ref.invalidate(userDetailProvider(widget.user.id));
      ref.invalidate(usersListProvider);
      setState(() {
        _message = widget.user.isBlocked ? 'User unblocked' : 'User blocked';
      });
    } catch (e) {
      setState(() => _message = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionCard(
          title: 'Roles & status',
          children: [
            _DetailRow('Roles',
                user.roles.isEmpty ? user.type.apiRole : user.roles.join(', ')),
            _DetailRow('Active role', user.activeRole),
            _DetailRow('Verified', user.isVerified ? 'Yes' : 'No'),
            _DetailRow('Active', user.isActive ? 'Yes' : 'No'),
            _DetailRow('Blocked', user.isBlocked ? 'Yes' : 'No'),
            _DetailRow('Banned', user.isBanned ? 'Yes' : 'No'),
            _DetailRow('Block reason',
                user.blockedReason.isEmpty ? '—' : user.blockedReason),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            FilledButton.icon(
              onPressed: _busy ? null : _toggleBlocked,
              icon: Icon(
                user.isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                size: 16,
              ),
              label: Text(user.isBlocked ? 'Unblock user' : 'Block user'),
            ),
          ],
        ),
        if (_message != null) ...[
          const SizedBox(height: 10),
          Text(
            _message!,
            style: TextStyle(
              fontSize: 12.5,
              color: _message!.toLowerCase().contains('user ')
                  ? AppColors.textSecondary
                  : AppColors.danger,
            ),
          ),
        ],
      ],
    );
  }
}

class _EditTab extends ConsumerStatefulWidget {
  const _EditTab({required this.user});

  final AdminUser user;

  @override
  ConsumerState<_EditTab> createState() => _EditTabState();
}

class _EditTabState extends ConsumerState<_EditTab> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _languageCtrl;
  bool _saving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
    _languageCtrl = TextEditingController(text: widget.user.language);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _languageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      await ref.read(usersRepositoryProvider).update(widget.user.id, {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        'language':
            _languageCtrl.text.trim().isEmpty ? null : _languageCtrl.text.trim(),
      });
      ref.invalidate(userDetailProvider(widget.user.id));
      ref.invalidate(usersListProvider);
      setState(() => _message = 'Profile updated');
    } catch (e) {
      setState(() => _message = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionCard(
          title: 'Edit basic profile',
          children: [
            const _FieldLabel('Name'),
            TextField(controller: _nameCtrl),
            const SizedBox(height: 12),
            const _FieldLabel('Email'),
            TextField(controller: _emailCtrl),
            const SizedBox(height: 12),
            const _FieldLabel('Phone'),
            TextField(controller: _phoneCtrl),
            const SizedBox(height: 12),
            const _FieldLabel('Language'),
            TextField(controller: _languageCtrl),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save changes'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 10),
              Text(
                _message!,
                style: TextStyle(
                  fontSize: 12.5,
                  color: _message == 'Profile updated'
                      ? AppColors.textSecondary
                      : AppColors.danger,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: user.avatarUrl.isNotEmpty
                ? Image.network(
                    user.avatarUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _FallbackAvatar(name: user.name),
                  )
                : _FallbackAvatar(name: user.name),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.8,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.type.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(label: 'ID ${user.id}'),
                    if (user.city.isNotEmpty) _InfoChip(label: user.city),
                    _InfoChip(
                      label: 'Joined ${DateFormat('d MMM y').format(user.joinedAt)}',
                    ),
                    if (user.isBlocked) const _InfoChip(label: 'Blocked', danger: true),
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

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECE3),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? 'U' : name.characters.first.toUpperCase(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    this.danger = false,
  });

  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: danger
            ? AppColors.danger.withValues(alpha: 0.1)
            : const Color(0xFFF7F3EC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: danger ? AppColors.danger : AppColors.textSecondary,
        ),
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

String _fmtDateTime(DateTime value) {
  return DateFormat('d MMM y, h:mm a').format(value);
}
