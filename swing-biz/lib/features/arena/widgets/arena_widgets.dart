import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../models/arena_models.dart';

const arenaBg = Color(0xFF0B0F0D);
const arenaCard = Color(0xFF17211C);
const arenaBorder = Color(0xFF243A30);
const arenaGreen = Color(0xFF10B981);
const arenaLightGreen = Color(0xFF9EF3C3);
const arenaText = Color(0xFFFFFFFF);
const arenaMuted = Color(0xFFB8C7BE);

class ArenaScaffold extends StatelessWidget {
  const ArenaScaffold({
    super.key,
    required this.title,
    required this.currentIndex,
    required this.child,
    this.actions,
  });

  final String title;
  final int currentIndex;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: arenaBg,
      appBar: AppBar(
        backgroundColor: arenaBg,
        foregroundColor: arenaText,
        title: Text(title),
        actions: actions,
      ),
      body: child,
      bottomNavigationBar: ArenaBottomNav(currentIndex: currentIndex),
    );
  }
}

class ArenaBottomNav extends StatelessWidget {
  const ArenaBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    const items = [
      _ArenaNavItem('Home', Icons.home_rounded, AppRoutes.arenaHome),
      _ArenaNavItem('Courts', Icons.stadium_rounded, AppRoutes.arenaAssets),
      _ArenaNavItem(
          'Bookings', Icons.book_online_rounded, AppRoutes.arenaBookings),
      _ArenaNavItem('Earnings', Icons.account_balance_wallet_rounded,
          AppRoutes.arenaEarnings),
      _ArenaNavItem('Settings', Icons.settings_rounded, AppRoutes.arenaProfile),
    ];

    return NavigationBar(
      backgroundColor: arenaCard,
      indicatorColor: arenaGreen.withValues(alpha: .25),
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => context.go(items[index].route),
      destinations: items
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.icon, color: arenaMuted),
              selectedIcon: Icon(item.icon, color: arenaLightGreen),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

class ArenaCard extends StatelessWidget {
  const ArenaCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: arenaCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: arenaBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x70000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class ArenaGlowIcon extends StatelessWidget {
  const ArenaGlowIcon(this.icon, {super.key, this.size = 42});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: arenaGreen.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: arenaGreen.withValues(alpha: .18),
            blurRadius: 14,
          ),
        ],
      ),
      child: Icon(icon, color: arenaLightGreen, size: size * .52),
    );
  }
}

class ArenaSectionTitle extends StatelessWidget {
  const ArenaSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: arenaText,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class ArenaStatusBadge extends StatelessWidget {
  const ArenaStatusBadge({
    super.key,
    required this.label,
    this.positive = true,
  });

  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? arenaGreen : const Color(0xFFEF4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: positive ? arenaLightGreen : const Color(0xFFFCA5A5),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

Color bookingStatusColor(BookingStatus status) {
  return switch (status) {
    BookingStatus.confirmed => arenaGreen,
    BookingStatus.pending => const Color(0xFFF59E0B),
    BookingStatus.cancelled => const Color(0xFFEF4444),
    BookingStatus.completed => const Color(0xFF3B82F6),
  };
}

class ArenaInfoRow extends StatelessWidget {
  const ArenaInfoRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: const TextStyle(color: arenaMuted))),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: arenaText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class ArenaTextField extends StatelessWidget {
  const ArenaTextField({
    super.key,
    required this.label,
    this.initialValue,
    this.keyboardType,
  });

  final String label;
  final String? initialValue;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        style: const TextStyle(color: arenaText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: arenaMuted),
          filled: true,
          fillColor: const Color(0xFF101812),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: arenaBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: arenaBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: arenaGreen, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class ArenaDropdown extends StatelessWidget {
  const ArenaDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
  });

  final String label;
  final String value;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        dropdownColor: arenaCard,
        style: const TextStyle(color: arenaText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: arenaMuted),
          filled: true,
          fillColor: const Color(0xFF101812),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: arenaBorder),
          ),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (_) {},
      ),
    );
  }
}

class ArenaPrimaryButton extends StatelessWidget {
  const ArenaPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: arenaGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class ArenaChoiceWrap extends StatelessWidget {
  const ArenaChoiceWrap({
    super.key,
    required this.items,
    this.selectedIndex = 0,
  });

  final List<String> items;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < items.length; i++)
          ChoiceChip(
            selected: i == selectedIndex,
            label: Text(items[i]),
            backgroundColor: arenaCard,
            selectedColor: arenaGreen.withValues(alpha: .25),
            side: BorderSide(
              color: i == selectedIndex ? arenaGreen : arenaBorder,
            ),
            labelStyle: const TextStyle(color: arenaText),
          ),
      ],
    );
  }
}

class _ArenaNavItem {
  const _ArenaNavItem(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}
