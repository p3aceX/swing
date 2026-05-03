import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MoreItem(icon: Icons.groups_rounded, label: 'Batches', subtitle: 'Manage groups', route: '/more/batches', color: const Color(0xFF0057C8)),
      _MoreItem(icon: Icons.sports_cricket_rounded, label: 'Coaches', subtitle: 'Your team', route: '/more/coaches', color: const Color(0xFF1B8A5A)),
      _MoreItem(icon: Icons.receipt_long_rounded, label: 'Fees', subtitle: 'Payments & dues', route: '/more/fees', color: const Color(0xFFD97706)),
      _MoreItem(icon: Icons.campaign_rounded, label: 'Announcements', subtitle: 'Posts & updates', route: '/more/announcements', color: const Color(0xFF7C3AED)),
      _MoreItem(icon: Icons.inventory_2_rounded, label: 'Inventory', subtitle: 'Equipment & stock', route: '/more/inventory', color: const Color(0xFF0891B2)),
      _MoreItem(icon: Icons.settings_rounded, label: 'Settings', subtitle: 'App & profile', route: '/more/settings', color: const Color(0xFF64748B)),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F2EB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _MoreCard(item: items[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final String route;
  final Color color;
  const _MoreItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.route,
    required this.color,
  });
}

class _MoreCard extends StatelessWidget {
  final _MoreItem item;
  const _MoreCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(item.route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE0DED6), width: 1),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const Spacer(),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF071B3D),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
