import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../data/users_repository.dart';
import '../domain/admin_user.dart';

final _selectedTabProvider = StateProvider<UserTab>((_) => UserTab.all);
final _searchProvider = StateProvider<String>((_) => '');

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: ref.read(_searchProvider));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyQuery({int page = 1}) {
    final tab = ref.read(_selectedTabProvider);
    final search = ref.read(_searchProvider).trim();
    ref.read(usersQueryProvider.notifier).state = UsersQuery(
      role: tab.apiRole,
      search: search.isEmpty ? null : search,
      page: page,
      limit: 20,
    );
  }

  void _goToPage(int page) {
    final current = ref.read(usersQueryProvider);
    ref.read(usersQueryProvider.notifier).state = current.copyWith(page: page);
  }

  Future<void> _openCreateUser() async {
    final created = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => const _CreateUserDialog(),
    );
    if (created == true) {
      ref.invalidate(usersListProvider);
      ref.invalidate(userStatsProvider);
      ref.invalidate(onboardingTrendUsersProvider);
    }
  }

  void _showTrendSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (_) => const _OnboardingTrendSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final async = ref.watch(usersListProvider);
    final statsAsync = ref.watch(userStatsProvider);
    final selectedTab = ref.watch(_selectedTabProvider);

    return Scaffold(
      appBar: compact
          ? null
          : AppBar(
              title: const Text('Users'),
              actions: [
                IconButton(
                  onPressed: _showTrendSheet,
                  icon: const Icon(Icons.show_chart_rounded, size: 20),
                  tooltip: 'Onboarding trend',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: FilledButton.icon(
                    onPressed: _openCreateUser,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add user'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (compact)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _showTrendSheet,
                    icon: const Icon(Icons.show_chart_rounded, size: 16),
                    label: const Text('Trend'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _openCreateUser,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add user'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, compact ? 6 : 2, 20, 10),
            child: _UsersHero(
              statsAsync: statsAsync,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) => ref.read(_searchProvider.notifier).state = q,
              onSubmitted: (_) => _applyQuery(),
              decoration: InputDecoration(
                hintText: 'Search name, email, phone',
                prefixIcon: const Icon(Icons.search,
                    size: 18, color: AppColors.textMuted),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 38, minHeight: 38),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(_searchProvider.notifier).state = '';
                          _applyQuery();
                        },
                      ),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final t in UserTab.values)
                  _TextTab(
                    label: t.label,
                    selected: selectedTab == t,
                    onTap: () {
                      ref.read(_selectedTabProvider.notifier).state = t;
                      _applyQuery();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(usersListProvider);
                ref.invalidate(userStatsProvider);
                ref.invalidate(onboardingTrendUsersProvider);
                await ref.read(usersListProvider.future);
              },
              child: async.when(
                data: (page) => _UsersList(page: page),
                loading: () => const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (e, _) => _ErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(usersListProvider),
                  onSignOut: () =>
                      ref.read(authControllerProvider.notifier).logout(),
                ),
              ),
            ),
          ),
          async.maybeWhen(
            data: (page) => _PaginationBar(
              page: page,
              onPrev: page.hasPrev ? () => _goToPage(page.page - 1) : null,
              onNext: page.hasNext ? () => _goToPage(page.page + 1) : null,
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _UsersHero extends StatelessWidget {
  const _UsersHero({
    required this.statsAsync,
  });

  final AsyncValue<UserStats> statsAsync;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User operations',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Manage accounts, roles and onboarding',
            style: TextStyle(
              fontSize: 24,
              height: 1.08,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.9,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          statsAsync.when(
            data: (stats) => LayoutBuilder(
              builder: (context, constraints) {
                final cards = [
                  _HeroStatCard(
                    label: 'Total users',
                    value: _fmtInt(stats.total),
                    helper: 'All active records',
                  ),
                  _HeroStatCard(
                    label: 'Players',
                    value: _fmtInt(stats.players),
                    helper: 'Largest cohort',
                  ),
                  _HeroStatCard(
                    label: 'Biz',
                    value: _fmtInt(stats.biz),
                    helper: 'Business owners',
                  ),
                ];
                return Row(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(child: cards[i]),
                    ],
                  ],
                );
              },
            ),
            loading: () => const SizedBox(
              height: 88,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _HeroStatCard extends StatelessWidget {
  const _HeroStatCard({
    required this.label,
    required this.value,
    required this.helper,
  });

  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
              color: AppColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            helper,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingTrendSheet extends ConsumerWidget {
  const _OnboardingTrendSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(onboardingTrendUsersProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        child: async.when(
          data: (users) {
            final points = _buildTrendPoints(users);
            final total = points.fold<int>(0, (sum, point) => sum + point.count);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Onboarding trend',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total users captured from recent admin records',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: _TrendChart(points: points),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final point in points)
                      _TrendChip(
                        label: DateFormat('MMM').format(point.month),
                        value: point.count.toString(),
                      ),
                  ],
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 180,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              e.toString(),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.danger,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1E8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label  $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _TrendPoint {
  const _TrendPoint({
    required this.month,
    required this.count,
  });

  final DateTime month;
  final int count;
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points});

  final List<_TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxValue =
        points.isEmpty ? 1 : points.map((e) => e.count).reduce(math.max).clamp(1, 1 << 30);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$maxValue',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text('${(maxValue / 2).round()}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const Text('0',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final point in points)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          point.count.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: point.count / maxValue,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFF0B9A6),
                                      Color(0xFFE27F63),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          DateFormat('MMM').format(point.month),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

List<_TrendPoint> _buildTrendPoints(List<AdminUser> users) {
  final now = DateTime.now();
  final months = List.generate(6, (index) {
    final target = DateTime(now.year, now.month - (5 - index), 1);
    return DateTime(target.year, target.month, 1);
  });

  final counts = <DateTime, int>{
    for (final month in months) month: 0,
  };

  for (final user in users) {
    final month = DateTime(user.joinedAt.year, user.joinedAt.month, 1);
    if (counts.containsKey(month)) {
      counts[month] = counts[month]! + 1;
    }
  }

  return [
    for (final month in months)
      _TrendPoint(month: month, count: counts[month] ?? 0),
  ];
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.onPrev,
    required this.onNext,
  });
  final UsersPage page;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    if (page.total == 0) return const SizedBox.shrink();
    final start = (page.page - 1) * page.limit + 1;
    final end = (start + page.users.length - 1).clamp(start, page.total);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$start–$end of ${page.total}',
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Text(
            'Page ${page.page} / ${page.totalPages}',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 12),
          _PagerButton(icon: Icons.chevron_left, onTap: onPrev),
          const SizedBox(width: 6),
          _PagerButton(icon: Icons.chevron_right, onTap: onNext),
        ],
      ),
    );
  }
}

class _PagerButton extends StatelessWidget {
  const _PagerButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _TextTab extends StatelessWidget {
  const _TextTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.textPrimary : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.textPrimary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _UsersList extends StatelessWidget {
  const _UsersList({required this.page});
  final UsersPage page;

  @override
  Widget build(BuildContext context) {
    final users = page.users;
    if (users.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text(
              'No users match your filters',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _UserRow(user: users[i]),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user});
  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (user.email.isNotEmpty) user.email,
      if (user.phone.isNotEmpty) user.phone,
    ].join('  ·  ');

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => context.go('/users/${user.id}'),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _UserAvatar(name: user.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.5,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isBlocked) ...[
                          const SizedBox(width: 8),
                          const _BlockedTag(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle.isEmpty ? 'No contact info' : subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MiniPill(label: user.type.label),
                        if (user.city.isNotEmpty) _MiniPill(label: user.city),
                        _MiniPill(
                          label:
                              'Joined ${DateFormat('d MMM y').format(user.joinedAt)}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? 'U' : name.characters.first.toUpperCase();
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECE3),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _BlockedTag extends StatelessWidget {
  const _BlockedTag();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.danger.withValues(alpha: 0.1),
      ),
      child: const Text(
        'Blocked',
        style: TextStyle(
          fontSize: 10.5,
          color: AppColors.danger,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.onSignOut,
  });
  final Object error;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final isAuth =
        error is ApiException && (error as ApiException).isUnauthorized;
    final title = isAuth ? 'Admin session not active' : 'Couldn\'t load users';
    final hint = isAuth
        ? 'Your access token is missing or expired. Sign out and sign in again to refresh it.'
        : error.toString();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                hint,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: onRetry,
                    child: const Text('Try again'),
                  ),
                  if (isAuth) ...[
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: onSignOut,
                      child: const Text('Sign out'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CreateUserDialog extends ConsumerStatefulWidget {
  const _CreateUserDialog();

  @override
  ConsumerState<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends ConsumerState<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  UserType _role = UserType.player;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool get _requiresPassword =>
      _role == UserType.admin || _role == UserType.support;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(usersRepositoryProvider).create(
            CreateUserPayload(
              name: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              phone: _phoneCtrl.text.trim(),
              role: _role,
              password: _requiresPassword ? _passwordCtrl.text : null,
            ),
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create user',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'POST /admin/users',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close,
                          size: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _FieldLabel('Name'),
                TextFormField(
                  controller: _nameCtrl,
                  enabled: !_submitting,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'Full name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name required' : null,
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Email'),
                TextFormField(
                  controller: _emailCtrl,
                  enabled: !_submitting,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration:
                      const InputDecoration(hintText: 'name@example.com'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email required';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Phone'),
                TextFormField(
                  controller: _phoneCtrl,
                  enabled: !_submitting,
                  keyboardType: TextInputType.phone,
                  decoration:
                      const InputDecoration(hintText: '+91 98765 43210'),
                ),
                const SizedBox(height: 12),
                const _FieldLabel('Role'),
                _RoleDropdown(
                  value: _role,
                  enabled: !_submitting,
                  onChanged: (r) => setState(() => _role = r),
                ),
                if (_requiresPassword) ...[
                  const SizedBox(height: 12),
                  const _FieldLabel('Password'),
                  TextFormField(
                    controller: _passwordCtrl,
                    enabled: !_submitting,
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: 'Minimum 8 characters'),
                    validator: (v) {
                      if (!_requiresPassword) return null;
                      if (v == null || v.isEmpty) return 'Password required';
                      if (v.length < 8) return 'Too short';
                      return null;
                    },
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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

class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });
  final UserType value;
  final bool enabled;
  final ValueChanged<UserType> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<UserType>(
      initialValue: value,
      onChanged: !enabled
          ? null
          : (v) {
              if (v != null) onChanged(v);
            },
      decoration: const InputDecoration(isDense: true),
      icon: const Icon(Icons.expand_more,
          size: 18, color: AppColors.textSecondary),
      items: [
        for (final t in UserType.values)
          DropdownMenuItem(
            value: t,
            child: Text(
              t.label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

String _fmtInt(int n) => NumberFormat.decimalPattern('en_IN').format(n);
