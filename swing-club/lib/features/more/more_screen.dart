import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.groups_outlined, 'Batches', '/more/batches'),
      (Icons.person_pin_outlined, 'Coaches', '/more/coaches'),
      (Icons.payments_outlined, 'Fees', '/more/fees'),
      (Icons.campaign_outlined, 'Announcements', '/more/announcements'),
      (Icons.inventory_2_outlined, 'Inventory', '/more/inventory'),
      (Icons.settings_outlined, 'Settings', '/more/settings'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final (icon, label, route) = items[i];
          return ListTile(
            leading: Icon(icon, color: const Color(0xFF0057C8)),
            title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            onTap: () => context.go(route),
          );
        },
      ),
    );
  }
}
