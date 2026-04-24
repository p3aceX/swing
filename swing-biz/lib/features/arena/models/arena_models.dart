import 'package:flutter/material.dart';

enum ArenaStatus { open, closed }

enum CourtStatus { active, maintenance, closed }

enum SlotStatus { available, booked, blocked }

enum BookingStatus { confirmed, pending, cancelled, completed }

enum PaymentStatus { paid, pending, partial }

class ArenaBooking {
  const ArenaBooking({
    required this.id,
    required this.confirmationNumber,
    required this.date,
    required this.timeSlot,
    required this.duration,
    required this.sport,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.status,
    required this.paymentStatus,
    required this.courtName,
    required this.amount,
    required this.specialRequest,
  });

  final String id;
  final String confirmationNumber;
  final String date;
  final String timeSlot;
  final String duration;
  final String sport;
  final String customerName;
  final String phone;
  final String email;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String courtName;
  final int amount;
  final String specialRequest;
}

class ArenaCourt {
  const ArenaCourt({
    required this.id,
    required this.name,
    required this.sportType,
    required this.size,
    required this.status,
    required this.amenities,
    required this.baseRate,
    required this.peakRate,
    required this.offPeakRate,
    required this.occupancyBooked,
    required this.occupancyTotal,
    required this.openingHours,
    required this.days,
    required this.maintenanceHistory,
  });

  final String id;
  final String name;
  final String sportType;
  final String size;
  final CourtStatus status;
  final List<String> amenities;
  final int baseRate;
  final int peakRate;
  final int offPeakRate;
  final int occupancyBooked;
  final int occupancyTotal;
  final String openingHours;
  final String days;
  final List<String> maintenanceHistory;
}

class ArenaSlot {
  const ArenaSlot({
    required this.id,
    required this.courtId,
    required this.courtName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.price,
    required this.status,
    this.blockReason,
  });

  final String id;
  final String courtId;
  final String courtName;
  final String date;
  final String startTime;
  final String endTime;
  final String duration;
  final int price;
  final SlotStatus status;
  final String? blockReason;
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
    required this.yearToDate,
    required this.pending,
  });

  final int today;
  final int weekly;
  final int monthly;
  final int yearToDate;
  final int pending;
}

class ArenaSettlement {
  const ArenaSettlement({
    required this.date,
    required this.amount,
    required this.method,
    required this.period,
  });

  final String date;
  final int amount;
  final String method;
  final String period;
}

class ArenaReview {
  const ArenaReview({
    required this.customerName,
    required this.date,
    required this.rating,
    required this.review,
    this.replyDate,
  });

  final String customerName;
  final String date;
  final double rating;
  final String review;
  final String? replyDate;
}

String arenaMoney(int amount) => 'Rs $amount';

String arenaStatusLabel(ArenaStatus status) {
  return switch (status) {
    ArenaStatus.open => 'Open',
    ArenaStatus.closed => 'Closed',
  };
}

String courtStatusLabel(CourtStatus status) {
  return switch (status) {
    CourtStatus.active => 'Active',
    CourtStatus.maintenance => 'Under Maintenance',
    CourtStatus.closed => 'Closed',
  };
}

String bookingStatusLabel(BookingStatus status) {
  return switch (status) {
    BookingStatus.confirmed => 'Confirmed',
    BookingStatus.pending => 'Pending',
    BookingStatus.cancelled => 'Cancelled',
    BookingStatus.completed => 'Completed',
  };
}

String paymentStatusLabel(PaymentStatus status) {
  return switch (status) {
    PaymentStatus.paid => 'Paid',
    PaymentStatus.pending => 'Pending',
    PaymentStatus.partial => 'Partial',
  };
}

String slotStatusLabel(SlotStatus status) {
  return switch (status) {
    SlotStatus.available => 'Available',
    SlotStatus.booked => 'Booked',
    SlotStatus.blocked => 'Blocked',
  };
}
