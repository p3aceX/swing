import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';
import '../../arena/screens/arena_profile_page.dart';
import '../../arena/services/arena_profile_providers.dart';
import '../../../core/notifications/notifications_screen.dart';
import '../../bookings/presentation/bookings_page.dart';
import '../../payments/presentation/payments_page.dart';
import '../../play/presentation/biz_play_tab.dart';

// ─── Home tab providers ───────────────────────────────────────────────────────

final _homeArenaProvider = StateProvider<String?>((ref) => null);
final _graphRangeProvider = StateProvider<String>((ref) => 'Month');

final _homeTodayBookingsProvider = FutureProvider.autoDispose
    .family<List<ArenaReservation>, String>((ref, arenaId) async {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  return ref
      .watch(hostArenaBookingRepositoryProvider)
      .listArenaBookings(arenaId, date: today);
});

final _homeAllBookingsProvider = FutureProvider.autoDispose
    .family<List<ArenaReservation>, String>((ref, arenaId) async {
  return ref
      .watch(hostArenaBookingRepositoryProvider)
      .listArenaBookings(arenaId);
});

final _homeTodayAvailabilityProvider = FutureProvider.autoDispose
    .family<Map<String, List<AvailabilitySlot>>, String>((ref, arenaId) async {
  return ref
      .watch(hostArenaBookingRepositoryProvider)
      .fetchAvailability(arenaId: arenaId, date: DateTime.now());
});

final _homeDateBookingsProvider = FutureProvider.autoDispose
    .family<List<ArenaReservation>, ({String arenaId, String date})>(
        (ref, input) async {
  return ref
      .watch(hostArenaBookingRepositoryProvider)
      .listArenaBookings(input.arenaId, date: input.date);
});

final _homeMonthPaymentsProvider = FutureProvider.autoDispose
    .family<ArenaPaymentsData, String>((ref, arenaId) async {
  final now = DateTime.now();
  final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  return ref
      .watch(hostArenaBookingRepositoryProvider)
      .fetchArenaPayments(arenaId, month: month);
});

final _homeMonthSummaryProvider = FutureProvider.autoDispose
    .family<Map<String, ArenaDaySummary>, String>((ref, arenaId) async {
  final now = DateTime.now();
  final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  return ref
      .watch(hostArenaBookingRepositoryProvider)
      .fetchMonthSummary(arenaId, month);
});

final _homeYearSummaryProvider = FutureProvider.autoDispose
    .family<List<(String, int)>, String>((ref, arenaId) async {
  final repo = ref.watch(hostArenaBookingRepositoryProvider);
  final now = DateTime.now();
  final results = <(String, int)>[];
  for (int i = 5; i >= 0; i--) {
    final d = DateTime(now.year, now.month - i);
    final monthKey = '${d.year}-${d.month.toString().padLeft(2, '0')}';
    final summary = await repo.fetchMonthSummary(arenaId, monthKey);
    final total = summary.values.fold(0, (s, e) => s + e.revenuePaise);
    results.add((DateFormat('MMM').format(d), total));
  }
  return results;
});

AsyncValue<List<T>> _combineAsyncLists<T>(List<AsyncValue<List<T>>> values) {
  if (values.any((v) => v.isLoading)) return const AsyncValue.loading();
  final error = values.where((v) => v.hasError).firstOrNull;
  if (error != null) return AsyncValue.error(error.error!, error.stackTrace!);
  return AsyncValue.data(values.expand((v) => v.value ?? <T>[]).toList());
}

AsyncValue<ArenaPaymentsData> _combinePayments(
  List<AsyncValue<ArenaPaymentsData>> values,
) {
  if (values.any((v) => v.isLoading)) return const AsyncValue.loading();
  final error = values.where((v) => v.hasError).firstOrNull;
  if (error != null) return AsyncValue.error(error.error!, error.stackTrace!);

  final rows = values.map((v) => v.value).whereType<ArenaPaymentsData>();
  return AsyncValue.data(
    ArenaPaymentsData(
      checkedInBookings: rows.expand((r) => r.checkedInBookings).toList(),
      pendingBookings: rows.expand((r) => r.pendingBookings).toList(),
    ),
  );
}

AsyncValue<Map<String, ArenaDaySummary>> _combineSummaries(
  List<AsyncValue<Map<String, ArenaDaySummary>>> values,
) {
  if (values.any((v) => v.isLoading)) return const AsyncValue.loading();
  final error = values.where((v) => v.hasError).firstOrNull;
  if (error != null) return AsyncValue.error(error.error!, error.stackTrace!);

  final combined = <String, ArenaDaySummary>{};
  for (final value in values) {
    for (final entry
        in (value.value ?? const <String, ArenaDaySummary>{}).entries) {
      final current = combined[entry.key];
      combined[entry.key] = ArenaDaySummary(
        count: (current?.count ?? 0) + entry.value.count,
        revenuePaise: (current?.revenuePaise ?? 0) + entry.value.revenuePaise,
      );
    }
  }
  return AsyncValue.data(combined);
}

AsyncValue<List<(String, int)>> _combineYearSummaries(
  List<AsyncValue<List<(String, int)>>> values,
) {
  if (values.any((v) => v.isLoading)) return const AsyncValue.loading();
  final error = values.where((v) => v.hasError).firstOrNull;
  if (error != null) return AsyncValue.error(error.error!, error.stackTrace!);

  final labels = <String>[];
  final totals = <String, int>{};
  for (final value in values) {
    for (final row in value.value ?? const <(String, int)>[]) {
      if (!totals.containsKey(row.$1)) labels.add(row.$1);
      totals[row.$1] = (totals[row.$1] ?? 0) + row.$2;
    }
  }
  return AsyncValue.data(
      labels.map((label) => (label, totals[label] ?? 0)).toList());
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _index = 0;
  void _setIndex(int i) => setState(() => _index = i);
  static const _navItems = [
    _NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
    _NavItem(Icons.stadium_rounded, Icons.stadium_outlined, 'Arenas'),
    _NavItem(Icons.calendar_month_rounded, Icons.calendar_month_outlined,
        'Bookings'),
    _NavItem(Icons.account_balance_wallet_rounded,
        Icons.account_balance_wallet_outlined, 'Payments'),
    _NavItem(
        Icons.sports_cricket_rounded, Icons.sports_cricket_outlined, 'Play'),
  ];
  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeTab(),
      const _ArenasTab(),
      const _BookingsTab(),
      const _PaymentsTab(),
      const BizPlayTab(),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar:
          _BottomNav(currentIndex: _index, items: _navItems, onTap: _setIndex),
    );
  }
}

class _NavItem {
  const _NavItem(this.activeIcon, this.inactiveIcon, this.label);
  final IconData activeIcon, inactiveIcon;
  final String label;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav(
      {required this.currentIndex, required this.items, required this.onTap});
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4))
      ]),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 8, bottom),
        child: Row(
            children: List.generate(
                items.length,
                (i) => Expanded(
                    child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onTap(i),
                        child: _NavTile(
                            item: items[i], selected: i == currentIndex))))),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.selected});
  final _NavItem item;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
              top: BorderSide(
                  color: selected ? primary : Colors.transparent, width: 2.5))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(selected ? item.activeIcon : item.inactiveIcon,
            size: 24, color: selected ? primary : const Color(0xFF98A2B3)),
        const SizedBox(height: 5),
        Text(item.label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? primary : const Color(0xFF98A2B3),
                letterSpacing: 0.2))
      ]),
    );
  }
}

void _showProfileSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _ProfileSheet());
}

class _ProfileAvatar extends ConsumerWidget {
  const _ProfileAvatar();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider).valueOrNull;
    final initial = (me?.user.name ?? 'U').isNotEmpty
        ? (me?.user.name ?? 'U')[0].toUpperCase()
        : 'U';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(18)),
      alignment: Alignment.center,
      child: Text(initial,
          style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 14,
              fontWeight: FontWeight.w800)),
    );
  }
}

class _ProfileSheet extends ConsumerStatefulWidget {
  const _ProfileSheet();

  @override
  ConsumerState<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends ConsumerState<_ProfileSheet> {
  final _formKey = GlobalKey<FormState>();
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
  final _beneficiaryName = TextEditingController();
  final _accountNumber = TextEditingController();
  final _ifsc = TextEditingController();
  final _upi = TextEditingController();

  bool _editMode = false;
  bool _saving = false;
  String? _loadedAccountId;

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
    _beneficiaryName.dispose();
    _accountNumber.dispose();
    _ifsc.dispose();
    _upi.dispose();
    super.dispose();
  }

  void _sync(BizMeResponse me) {
    final b = me.businessAccount;
    final key = b?.id ?? 'new:${me.user.id}';
    if (_loadedAccountId == key) return;
    _loadedAccountId = key;
    _businessName.text = b?.businessName ?? '';
    _contactName.text = b?.contactName ?? me.user.name ?? '';
    _phone.text = b?.phone ?? me.user.phone;
    _email.text = b?.email ?? me.user.email ?? '';
    _address.text = b?.address ?? '';
    _city.text = b?.city ?? '';
    _state.text = b?.state ?? '';
    _pincode.text = b?.pincode ?? '';
    _gst.text = b?.gstNumber ?? '';
    _pan.text = b?.panNumber ?? '';
    _beneficiaryName.text = b?.beneficiaryName ?? '';
    _accountNumber.text = b?.accountNumber ?? '';
    _ifsc.text = b?.ifscCode ?? '';
    _upi.text = b?.upiId ?? '';
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _optionalEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!text.contains('@')) return 'Enter a valid email';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(hostBizRepositoryProvider).upsertBusinessDetails(
            BusinessDetailsInput(
              businessName: _businessName.text.trim(),
              contactName: _contactName.text.trim(),
              phone: _phone.text.trim(),
              email: _email.text.trim(),
              address: _address.text.trim(),
              city: _city.text.trim(),
              state: _state.text.trim(),
              pincode: _pincode.text.trim(),
              gstNumber: _gst.text.trim(),
              panNumber: _pan.text.trim(),
              beneficiaryName: _beneficiaryName.text.trim(),
              accountNumber: _accountNumber.text.trim(),
              ifscCode: _ifsc.text.trim().toUpperCase(),
              upiId: _upi.text.trim(),
            ),
          );
      ref.invalidate(meProvider);
      if (!mounted) return;
      setState(() {
        _editMode = false;
        _saving = false;
        _loadedAccountId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meAsync = ref.watch(meProvider);
    final bottom = MediaQuery.of(context).padding.bottom;
    final scheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (ctx, controller) => meAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (me) {
          if (me == null) return const SizedBox();
          _sync(me);
          final b = me.businessAccount;
          final title = b?.businessName ?? me.user.name ?? 'Business Profile';
          final initial = title.isNotEmpty ? title[0].toUpperCase() : 'B';
          return DefaultTabController(
            length: 3,
            child: Form(
              key: _formKey,
              child: ListView(
                controller: controller,
                padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + bottom),
                children: [
                  Center(
                      child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(2)))),
                  Row(children: [
                    Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(16)),
                        alignment: Alignment.center,
                        child: Text(initial,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900))),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xFF101828),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text(me.user.phone,
                              style: const TextStyle(
                                  color: Color(0xFF667085),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600))
                        ])),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        foregroundColor: _editMode
                            ? const Color(0xFF667085)
                            : scheme.primary,
                      ),
                      tooltip: _editMode ? 'Cancel' : 'Edit profile',
                      onPressed: _saving
                          ? null
                          : () => setState(() => _editMode = !_editMode),
                      icon: Icon(
                          _editMode ? Icons.close_rounded : Icons.edit_rounded),
                    ),
                  ]),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB))),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                          color: scheme.primary,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      labelColor: scheme.onPrimary,
                      unselectedLabelColor: const Color(0xFF667085),
                      labelStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800),
                      unselectedLabelStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                      tabs: const [
                        Tab(text: 'Account'),
                        Tab(text: 'Business'),
                        Tab(text: 'Banking'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 456,
                    child: TabBarView(
                      children: [
                        _ProfileTabFields(children: [
                          _ProfileTextField(
                              controller: _contactName,
                              label: 'Contact name',
                              icon: Icons.person_outline_rounded,
                              enabled: _editMode),
                          _ProfileTextField(
                              controller: _phone,
                              label: 'Phone',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              enabled: _editMode),
                          _ProfileTextField(
                              controller: _email,
                              label: 'Email',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: _optionalEmail,
                              enabled: _editMode),
                        ]),
                        _ProfileTabFields(children: [
                          _ProfileTextField(
                              controller: _businessName,
                              label: 'Business name',
                              icon: Icons.business_outlined,
                              validator: _required,
                              enabled: _editMode),
                          _ProfileTextField(
                              controller: _address,
                              label: 'Address',
                              icon: Icons.location_on_outlined,
                              maxLines: 2,
                              enabled: _editMode),
                          Row(children: [
                            Expanded(
                                child: _ProfileTextField(
                                    controller: _city,
                                    label: 'City',
                                    icon: Icons.location_city_outlined,
                                    enabled: _editMode)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _ProfileTextField(
                                    controller: _state,
                                    label: 'State',
                                    icon: Icons.map_outlined,
                                    enabled: _editMode)),
                          ]),
                          Row(children: [
                            Expanded(
                                child: _ProfileTextField(
                                    controller: _pincode,
                                    label: 'Pincode',
                                    icon: Icons.pin_drop_outlined,
                                    enabled: _editMode)),
                          ]),
                          _ProfileTextField(
                              controller: _gst,
                              label: 'GST',
                              icon: Icons.receipt_long_outlined,
                              enabled: _editMode),
                          _ProfileTextField(
                              controller: _pan,
                              label: 'PAN',
                              icon: Icons.credit_card_outlined,
                              enabled: _editMode),
                        ]),
                        _ProfileTabFields(children: [
                          _ProfileTextField(
                              controller: _beneficiaryName,
                              label: 'Beneficiary name',
                              icon: Icons.badge_outlined,
                              enabled: _editMode),
                          _ProfileTextField(
                              controller: _accountNumber,
                              label: 'Account number',
                              icon: Icons.account_balance_outlined,
                              keyboardType: TextInputType.number,
                              enabled: _editMode),
                          _ProfileTextField(
                              controller: _ifsc,
                              label: 'IFSC',
                              icon: Icons.domain_verification_outlined,
                              enabled: _editMode),
                          _ProfileTextField(
                              controller: _upi,
                              label: 'UPI',
                              icon: Icons.qr_code_2_rounded,
                              enabled: _editMode),
                        ]),
                      ],
                    ),
                  ),
                  if (_editMode) ...[
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check_rounded),
                      label: Text(_saving ? 'Saving...' : 'Save profile'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _SheetActionRow(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      destructive: true,
                      onTap: () => ref
                          .read(sessionControllerProvider.notifier)
                          .signOut()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTabFields extends StatelessWidget {
  const _ProfileTabFields({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ...children.expand((child) => [child, const SizedBox(height: 12)]),
        ],
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.enabled,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(
          color: Color(0xFF101828), fontSize: 14, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: Color(0xFF667085), fontWeight: FontWeight.w700),
        prefixIcon: Icon(icon,
            size: 19,
            color: enabled ? scheme.primary : const Color(0xFF98A2B3)),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE1E5EA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
    );
  }
}

class _SheetActionRow extends StatelessWidget {
  const _SheetActionRow(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.destructive = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
  @override
  Widget build(BuildContext context) {
    final color =
        destructive ? const Color(0xFFD92D20) : const Color(0xFF101828);
    return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, color: color))
            ])));
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arenasAsync = ref.watch(ownedArenasProvider);
    final me = ref.watch(meProvider).valueOrNull;
    return arenasAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(child: Text('$e')),
      data: (arenas) {
        final businessName =
            me?.businessAccount?.businessName ?? me?.user.name ?? 'Arena';
        final selectedArenaId = ref.watch(_homeArenaProvider);
        final selectedArenas = selectedArenaId == null
            ? arenas
            : arenas.where((a) => a.id == selectedArenaId).toList();
        final allBookings = _combineAsyncLists(
          selectedArenas
              .map((a) => ref.watch(_homeAllBookingsProvider(a.id)))
              .toList(),
        );
        final todayAvailability = _combineAsyncLists(
          selectedArenas
              .map((a) => ref
                  .watch(_homeTodayAvailabilityProvider(a.id))
                  .whenData((slotsByUnit) =>
                      slotsByUnit.values.expand((slots) => slots).toList()))
              .toList(),
        );
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              _HeroHeader(businessName: businessName, ref: ref),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _HomeArenaFilter(
                      arenas: arenas,
                      selectedArenaId: selectedArenaId,
                      onSelected: (id) =>
                          ref.read(_homeArenaProvider.notifier).state = id,
                    ),
                    _HomeMetricStrip(
                      bookingsAsync: allBookings,
                      slotsAsync: todayAvailability,
                    ),
                    _HomeGraphTabs(arenas: selectedArenas),
                    const SizedBox(height: 28),
                    const Center(
                      child: Text(
                        'Welcome to Swing Biz',
                        style: TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeGraphTabs extends ConsumerWidget {
  const _HomeGraphTabs({required this.arenas});

  final List<ArenaListing> arenas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBookings = _combineAsyncLists(
      arenas.map((a) => ref.watch(_homeAllBookingsProvider(a.id))).toList(),
    );

    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking vs Revenue',
                style: TextStyle(
                  color: Color(0xFF101828),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'All booking history grouped by date',
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 260,
                child: allBookings.when(
                  loading: () => const _ChartLoading(),
                  error: (e, _) => const _ChartMessage('Could not load graph'),
                  data: (bookings) =>
                      _BookingRevenueLineChart(bookings: bookings),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeArenaFilter extends StatelessWidget {
  const _HomeArenaFilter({
    required this.arenas,
    required this.selectedArenaId,
    required this.onSelected,
  });

  final List<ArenaListing> arenas;
  final String? selectedArenaId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = <({String? id, String label})>[
      (id: null, label: 'All'),
      ...arenas.map((arena) => (id: arena.id, label: arena.name)),
    ];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = item.id == selectedArenaId;
          return ChoiceChip(
            selected: selected,
            label: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            showCheckmark: false,
            onSelected: (_) => onSelected(item.id),
            selectedColor: Theme.of(context).colorScheme.primary,
            backgroundColor: const Color(0xFFF9FAFB),
            side: BorderSide(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xFFE5E7EB),
            ),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF667085),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          );
        },
      ),
    );
  }
}

class _HomeMetricStrip extends StatelessWidget {
  const _HomeMetricStrip({
    required this.bookingsAsync,
    required this.slotsAsync,
  });

  final AsyncValue<List<ArenaReservation>> bookingsAsync;
  final AsyncValue<List<AvailabilitySlot>> slotsAsync;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: bookingsAsync.isLoading || slotsAsync.isLoading
          ? const Row(
              children: [
                Expanded(child: _MetricSkeleton()),
                SizedBox(width: 12),
                Expanded(child: _MetricSkeleton()),
              ],
            )
          : bookingsAsync.hasError || slotsAsync.hasError
              ? const Row(
                  children: [
                    Expanded(
                      child: _HomeMetricBox(
                        title: 'Checked In / Bookings',
                        value: '--',
                        subtitle: 'All time',
                        icon: Icons.done_all_rounded,
                        background: Color(0xFFEAFBF3),
                        accent: Color(0xFF059669),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _HomeMetricBox(
                        title: 'Booked Slots / Total',
                        value: '--',
                        subtitle: 'Today',
                        icon: Icons.event_available_rounded,
                        background: Color(0xFFEFF6FF),
                        accent: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                )
              : Builder(builder: (context) {
                  final bookings =
                      bookingsAsync.value ?? const <ArenaReservation>[];
                  final slots = slotsAsync.value ?? const <AvailabilitySlot>[];
                  final active = bookings.where(_isActiveBooking).toList();
                  final checkedIn = active.where((b) {
                    final status = b.status.toUpperCase();
                    return status == 'CHECKED_IN' || status == 'COMPLETED';
                  }).length;
                  final totalSlots = slots.length;
                  final bookedSlots =
                      slots.where((slot) => !slot.available).length;
                  return Row(
                    children: [
                      Expanded(
                        child: _HomeMetricBox(
                          title: 'Checked In / Bookings',
                          value: '$checkedIn/${active.length}',
                          subtitle: 'All time',
                          icon: Icons.done_all_rounded,
                          background: const Color(0xFFEAFBF3),
                          accent: const Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HomeMetricBox(
                          title: 'Booked Slots / Total',
                          value: '$bookedSlots/$totalSlots',
                          subtitle: 'Today',
                          icon: Icons.event_available_rounded,
                          background: const Color(0xFFEFF6FF),
                          accent: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  );
                }),
    );
  }
}

class _BookingRevenueLineChart extends StatelessWidget {
  const _BookingRevenueLineChart({required this.bookings});

  final List<ArenaReservation> bookings;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<ArenaReservation>>{};
    for (final booking in bookings) {
      final date = booking.bookingDate;
      if (date == null) continue;
      final key = DateFormat('yyyy-MM-dd').format(date);
      grouped.putIfAbsent(key, () => <ArenaReservation>[]).add(booking);
    }
    final keys = grouped.keys.toList()..sort();
    if (keys.isEmpty) {
      return const _ChartMessage('No bookings yet');
    }
    final days = keys.map((key) {
      return (
        day: DateTime.parse(key),
        bookings: grouped[key] ?? const <ArenaReservation>[]
      );
    }).toList();
    final bookingCounts = days
        .map((row) => row.bookings.where(_isActiveBooking).length.toDouble())
        .toList();
    final revenue = days.map((row) {
      return row.bookings
              .where(_countsAsRevenue)
              .fold<int>(0, (sum, booking) => sum + booking.totalAmountPaise) /
          100;
    }).toList();
    final collected = days.map((row) {
      return row.bookings.fold<int>(
            0,
            (sum, booking) =>
                sum +
                (booking.isPaid
                    ? booking.totalAmountPaise
                    : booking.advancePaise),
          ) /
          100;
    }).toList();
    final totalBookings =
        bookingCounts.fold<int>(0, (sum, count) => sum + count.toInt());
    final totalRevenue = days.fold<int>(0, (sum, row) {
      return sum +
          row.bookings.where(_countsAsRevenue).fold<int>(
              0, (daySum, booking) => daySum + booking.totalAmountPaise);
    });
    final totalCollected = days.fold<int>(0, (sum, row) {
      return sum +
          row.bookings.fold<int>(
            0,
            (daySum, booking) =>
                daySum +
                (booking.isPaid
                    ? booking.totalAmountPaise
                    : booking.advancePaise),
          );
    });
    final maxBookings = bookingCounts.fold<double>(
        0, (max, value) => value > max ? value : max);
    final maxRevenue =
        revenue.fold<double>(0, (max, value) => value > max ? value : max);
    final maxCollected =
        collected.fold<double>(0, (max, value) => value > max ? value : max);
    if (maxBookings == 0 && maxRevenue == 0 && maxCollected == 0) {
      return const _ChartMessage('No active booking data yet');
    }

    List<FlSpot> normalizedSpots(List<double> values, double maxValue) {
      return List.generate(values.length, (index) {
        final normalized =
            maxValue == 0 ? 0.0 : (values[index] / maxValue) * 100;
        return FlSpot(index.toDouble(), normalized);
      });
    }

    final bookingSpots = normalizedSpots(bookingCounts, maxBookings);
    final revenueSpots = normalizedSpots(revenue, maxRevenue);
    final collectedSpots = normalizedSpots(collected, maxCollected);
    final primary = Theme.of(context).colorScheme.primary;
    const blue = Color(0xFF2563EB);
    const amber = Color(0xFFF59E0B);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _TrendTotal(
                label: 'Bookings',
                value: totalBookings.toString(),
                color: primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TrendTotal(
                label: 'Revenue',
                value: '₹${_compactAmount(totalRevenue / 100)}',
                color: blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TrendTotal(
                label: 'Collected',
                value: '₹${_compactAmount(totalCollected / 100)}',
                color: amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _TrendLegend(color: primary, label: 'Bookings'),
            const SizedBox(width: 14),
            const _TrendLegend(color: blue, label: 'Revenue'),
            const SizedBox(width: 14),
            const _TrendLegend(color: amber, label: 'Collected'),
            const Spacer(),
            const Text(
              'Shape comparison',
              style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 10,
                  fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (days.length - 1).toDouble(),
              minY: 0,
              maxY: 110,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF101828),
                  getTooltipItems: (spots) => spots.map((spot) {
                    final index = spot.x.round().clamp(0, days.length - 1);
                    final text = switch (spot.barIndex) {
                      0 => '${bookingCounts[index].toInt()} bookings',
                      1 => '₹${_compactAmount(revenue[index])} revenue',
                      _ => '₹${_compactAmount(collected[index])} collected',
                    };
                    return LineTooltipItem(
                      text,
                      const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800),
                    );
                  }).toList(),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: Color(0xFFF2F4F7),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    interval:
                        days.length > 7 ? (days.length / 6).ceilToDouble() : 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= days.length) {
                        return const SizedBox.shrink();
                      }
                      final label = days.length <= 7
                          ? DateFormat('E').format(days[index].day)
                          : DateFormat('d MMM').format(days[index].day);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: bookingSpots,
                  isCurved: true,
                  color: primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primary.withValues(alpha: 0.18),
                        primary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                LineChartBarData(
                  spots: revenueSpots,
                  isCurved: true,
                  color: blue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  dashArray: const [8, 4],
                ),
                LineChartBarData(
                  spots: collectedSpots,
                  isCurved: true,
                  color: amber,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  dashArray: const [3, 4],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendTotal extends StatelessWidget {
  const _TrendTotal({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0)),
          const SizedBox(height: 3),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Color(0xFF101828),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0)),
        ],
      ),
    );
  }
}

class _TrendLegend extends StatelessWidget {
  const _TrendLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 11,
                fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _ChartLoading extends StatelessWidget {
  const _ChartLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _ChartMessage extends StatelessWidget {
  const _ChartMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF98A2B3),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _compactAmount(double value) {
  if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return value.toStringAsFixed(0);
}

bool _isActiveBooking(ArenaReservation booking) {
  final status = booking.status.toUpperCase();
  return status != 'CANCELLED' &&
      status != 'CANCELLED_BY_OWNER' &&
      status != 'HELD';
}

bool _countsAsRevenue(ArenaReservation booking) {
  final status = booking.status.toUpperCase();
  return status == 'CONFIRMED' ||
      status == 'CHECKED_IN' ||
      status == 'COMPLETED' ||
      booking.paidAt != null;
}

class _HomeMetricBox extends StatelessWidget {
  const _HomeMetricBox({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.accent,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [background, Colors.white],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 19),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: accent,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: accent.withValues(alpha: 0.72),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSkeleton extends StatelessWidget {
  const _MetricSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.businessName, required this.ref});
  final String businessName;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              businessName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF101828),
                  letterSpacing: -0.5),
            ),
          ),
          const SizedBox(width: 8),
          _HeaderIconBtn(
            icon: Icons.auto_awesome_rounded,
            tooltip: "What's New",
            onTap: () => _showWhatsNew(context),
          ),
          const SizedBox(width: 4),
          _NotificationBell(
            onTap: () => context
                .push(AppRoutes.arenaNotifications)
                .then((_) => ref.invalidate(bizUnreadCountProvider)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showProfileSheet(context, ref),
            child: const _ProfileAvatar(),
          ),
        ],
      ),
    );
  }

  void _showWhatsNew(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _WhatsNewSheet(),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  const _HeaderIconBtn(
      {required this.icon, required this.onTap, this.tooltip = ''});
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 24, color: const Color(0xFF344054)),
          ),
        ),
      );
}

class _NotificationBell extends ConsumerWidget {
  const _NotificationBell({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(bizUnreadCountProvider);
    final unread = unreadAsync.maybeWhen(data: (n) => n, orElse: () => 0);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              unread > 0
                  ? Icons.notifications_rounded
                  : Icons.notifications_none_rounded,
              size: 24,
              color: const Color(0xFF344054),
            ),
            if (unread > 0)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WhatsNewSheet extends StatelessWidget {
  const _WhatsNewSheet();

  static const _items = [
    (
      Icons.calendar_month_rounded,
      'Booking Check-ins',
      'Collect payments at check-in — mark bookings paid on the spot.'
    ),
    (
      Icons.layers_rounded,
      'Unit Management',
      'Add courts, nets and grounds with per-slot pricing and lead times.'
    ),
    (
      Icons.link_rounded,
      'Linked Units',
      'Link nets inside a ground — booking the ground blocks linked nets automatically.'
    ),
    (
      Icons.bar_chart_rounded,
      'Revenue Dashboard',
      'Monthly and daily revenue charts now live on the Home tab.'
    ),
    (
      Icons.sports_rounded,
      'Play Tab',
      'Create and manage matches and tournaments directly from the app.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottom),
      children: [
        Center(
          child: Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const Row(children: [
          Icon(Icons.auto_awesome_rounded, size: 20, color: Color(0xFF101828)),
          SizedBox(width: 10),
          Text("What's New",
              style: TextStyle(
                  color: Color(0xFF101828),
                  fontSize: 18,
                  fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 4),
        const Text('Latest updates to Swing Biz',
            style: TextStyle(
                color: Color(0xFF667085),
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        ..._items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(10)),
                    child:
                        Icon(item.$1, size: 18, color: const Color(0xFF344054)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$2,
                            style: const TextStyle(
                                color: Color(0xFF101828),
                                fontSize: 14,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(item.$3,
                            style: const TextStyle(
                                color: Color(0xFF667085),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _ArenasTab extends ConsumerWidget {
  const _ArenasTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arenasAsync = ref.watch(ownedArenasProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 16, 18),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Arenas',
                        style: TextStyle(
                            color: Color(0xFF101828),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5)),
                    SizedBox(height: 2),
                    Text('Manage your venues',
                        style: TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => const _ArenaHelpSheet(),
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Icons.help_outline_rounded,
                      color: Color(0xFF667085), size: 22),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => context.push(AppRoutes.createArena),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101828),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Add Arena',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.refresh(ownedArenasProvider.future),
            child: arenasAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _CenteredMessage(
                    title: 'Could not load arenas', message: '$e'),
              ),
              data: (arenas) {
                if (arenas.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _CenteredMessage(
                      title: 'No arenas yet',
                      message:
                          'Add your first arena to start managing bookings.',
                      action: GestureDetector(
                        onTap: () => context.push(AppRoutes.createArena),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 13),
                          decoration: BoxDecoration(
                            color: const Color(0xFF101828),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Add Your First Arena',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: arenas.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ArenaCard(arena: arenas[i]),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ArenaCard extends ConsumerWidget {
  const _ArenaCard({required this.arena});
  final ArenaListing arena;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = _joinNonEmpty([arena.city, arena.state]);
    final address = loc.isNotEmpty
        ? loc
        : (arena.address.isNotEmpty ? arena.address : 'Location not set');
    final initial = arena.name.isNotEmpty ? arena.name[0].toUpperCase() : 'A';
    final unitCount = arena.units.length;
    final photoUrl = arena.photoUrls.isNotEmpty ? arena.photoUrls.first : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top info row — tappable
          Material(
            color: Colors.transparent,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: InkWell(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              onTap: () =>
                  context.push('${AppRoutes.arenaProfile}/${arena.id}'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 54,
                        height: 54,
                        child: photoUrl != null
                            ? Image.network(photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _ArenaInitialBox(initial))
                            : _ArenaInitialBox(initial),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(arena.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xFF101828),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2)),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.location_on_outlined,
                                size: 13, color: Color(0xFF98A2B3)),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color(0xFF667085),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFFD0D5DD), size: 20),
                  ],
                ),
              ),
            ),
          ),
          // Stat pills
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _StatPill(Icons.access_time_rounded,
                    '${arena.openTime}–${arena.closeTime}'),
                _StatPill(Icons.layers_outlined,
                    '$unitCount unit${unitCount == 1 ? '' : 's'}'),
                if (arena.sports.isNotEmpty)
                  _StatPill(Icons.sports_cricket_outlined,
                      arena.sports.take(2).join(', ')),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF2F4F7)),
          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: _CardAction(
                    icon: Icons.edit_outlined,
                    label: 'Edit Arena',
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: const Color(0xFFF3F4F6),
                      builder: (_) => ArenaDetailSheet(
                        arena: arena,
                        startEditing: true,
                      ),
                    ).then((_) => ref.invalidate(ownedArenasProvider)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CardAction(
                    icon: Icons.layers_rounded,
                    label: 'Manage Units',
                    filled: true,
                    onTap: () =>
                        context.push('${AppRoutes.arenaProfile}/${arena.id}'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArenaInitialBox extends StatelessWidget {
  const _ArenaInitialBox(this.initial);
  final String initial;
  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF101828),
        alignment: Alignment.center,
        child: Text(initial,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900)),
      );
}

class _StatPill extends StatelessWidget {
  const _StatPill(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFF667085)),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final bg = filled ? const Color(0xFF101828) : const Color(0xFFF7F8FA);
    final fg = filled ? Colors.white : const Color(0xFF344054);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: fg, fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();
  @override
  Widget build(BuildContext context) => const BookingsPage();
}

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab();
  @override
  Widget build(BuildContext context) => const PaymentsPage();
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage(
      {required this.title, required this.message, this.action});
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF667085))),
            if (action != null) ...[const SizedBox(height: 16), action!]
          ])));
}

// ─── Arena help sheet ─────────────────────────────────────────────────────────

class _ArenaHelpSheet extends StatelessWidget {
  const _ArenaHelpSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE1E5EA),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'How it works',
            style: TextStyle(
                color: Color(0xFF101828),
                fontSize: 18,
                fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          const _HelpItem(
            icon: Icons.stadium_rounded,
            iconColor: Color(0xFF064E3B),
            iconBg: Color(0xFFD1FAE5),
            title: 'Arena',
            body:
                'Your venue on Swing. Set up the name, location, sports, and operating hours. Players search and discover your arena to make bookings.',
          ),
          const SizedBox(height: 16),
          const _HelpItem(
            icon: Icons.grid_view_rounded,
            iconColor: Color(0xFF0EA5E9),
            iconBg: Color(0xFFE0F2FE),
            title: 'Unit',
            body:
                'A bookable court or space inside your arena — e.g. "Court 1", "Turf A", "Net 2". Each unit has its own slot timings, pricing, and photos. Players pick a unit when they book.',
          ),
          const SizedBox(height: 16),
          const _HelpItem(
            icon: Icons.calendar_month_rounded,
            iconColor: Color(0xFF7C3AED),
            iconBg: Color(0xFFEDE9FE),
            title: 'Booking',
            body:
                'A confirmed time slot reservation by a player for one of your units. You can view upcoming and past bookings, check payment status, and manage check-ins from the Bookings tab.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  const _HelpItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Color(0xFF101828),
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(body,
                  style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.45)),
            ],
          ),
        ),
      ],
    );
  }
}

String _joinNonEmpty(List<String?> v, {String s = ', '}) => v
    .where((x) => x != null && x.trim().isNotEmpty)
    .map((x) => x!.trim())
    .join(s);
int _toMins(String t) {
  try {
    final p = t.split(':').map(int.parse).toList();
    return p[0] * 60 + p[1];
  } catch (_) {
    return 0;
  }
}
