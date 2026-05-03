import 'package:flutter/material.dart';

Widget statusBadge(String status) {
  final config = _badgeConfig[status.toUpperCase()] ??
      (const Color(0xFF616161), const Color(0xFFF5F5F5));
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: config.$2,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: config.$1,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  );
}

const _badgeConfig = <String, (Color, Color)>{
  'ACTIVE': (Color(0xFF2E7D32), Color(0xFFE8F5E9)),
  'TRIAL': (Color(0xFF1565C0), Color(0xFFE3F2FD)),
  'INACTIVE': (Color(0xFF616161), Color(0xFFF5F5F5)),
  'PAUSED': (Color(0xFFF57F17), Color(0xFFFFF8E1)),
  'PAID': (Color(0xFF2E7D32), Color(0xFFE8F5E9)),
  'PENDING': (Color(0xFFF57F17), Color(0xFFFFF8E1)),
  'OVERDUE': (Color(0xFFC62828), Color(0xFFFFEBEE)),
  'LIVE': (Color(0xFF1565C0), Color(0xFFE3F2FD)),
  'COMPLETED': (Color(0xFF616161), Color(0xFFF5F5F5)),
  'CANCELLED': (Color(0xFFC62828), Color(0xFFFFEBEE)),
  'GOOD': (Color(0xFF2E7D32), Color(0xFFE8F5E9)),
  'FAIR': (Color(0xFFF57F17), Color(0xFFFFF8E1)),
  'POOR': (Color(0xFFC62828), Color(0xFFFFEBEE)),
  'DAMAGED': (Color(0xFFC62828), Color(0xFFFFEBEE)),
};

String rupeesFromPaise(dynamic paise) {
  if (paise == null) return '₹0';
  return '₹${(paise / 100).toStringAsFixed(0)}';
}

Widget loadingBody() => const Center(child: CircularProgressIndicator());

Widget errorBody(Object err, VoidCallback retry) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(err.toString(), textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          TextButton(onPressed: retry, child: const Text('Retry')),
        ],
      ),
    );

Widget emptyBody(String message) => Center(
      child: Text(message, style: const TextStyle(color: Colors.grey)),
    );

void showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}
