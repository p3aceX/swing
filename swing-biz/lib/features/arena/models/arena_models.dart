import 'package:flutter/material.dart';

enum ArenaStatus { open, closed }

enum BookingStatus { confirmed, pending, cancelled }

class ArenaBooking {
  const ArenaBooking({
    required this.id,
    required this.timeSlot,
    required this.sport,
    required this.customerName,
    required this.status,
    required this.courtName,
    required this.amount,
  });

  final String id;
  final String timeSlot;
  final String sport;
  final String customerName;
  final BookingStatus status;
  final String courtName;
  final int amount;
}

class ArenaAsset {
  const ArenaAsset({
    required this.name,
    required this.sport,
    required this.available,
  });

  final String name;
  final String sport;
  final bool available;
}

class ArenaQuickAction {
  const ArenaQuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}

class ArenaPaymentSummary {
  const ArenaPaymentSummary({
    required this.today,
    required this.weekly,
    required this.monthly,
    required this.upcomingPayout,
  });

  final int today;
  final int weekly;
  final int monthly;
  final int upcomingPayout;
}

String arenaStatusLabel(ArenaStatus status) {
  return switch (status) {
    ArenaStatus.open => 'Open',
    ArenaStatus.closed => 'Closed',
  };
}

String bookingStatusLabel(BookingStatus status) {
  return switch (status) {
    BookingStatus.confirmed => 'Confirmed',
    BookingStatus.pending => 'Pending',
    BookingStatus.cancelled => 'Cancelled',
  };
}

String arenaMoney(int amount) => 'Rs $amount';
