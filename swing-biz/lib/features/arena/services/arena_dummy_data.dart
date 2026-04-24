import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import '../models/arena_models.dart';

const arenaName = 'Greenfield Sports Arena';
const arenaType = 'Multi-sport';
const arenaStatus = ArenaStatus.open;

const arenaPayments = ArenaPaymentSummary(
  today: 8500,
  weekly: 52000,
  monthly: 185000,
  yearToDate: 1850000,
  pending: 2000,
);

const arenaCourts = [
  ArenaCourt(
    id: 'court-1',
    name: 'Turf Field 1',
    sportType: 'Cricket',
    size: '70m x 50m',
    status: CourtStatus.active,
    amenities: ['Lights', 'Parking', 'Water', 'Changing Rooms'],
    baseRate: 500,
    peakRate: 700,
    offPeakRate: 300,
    occupancyBooked: 6,
    occupancyTotal: 8,
    openingHours: '6:00 AM - 10:00 PM',
    days: 'Mon-Sun',
    maintenanceHistory: ['12 Apr 2026 - Net replacement'],
  ),
  ArenaCourt(
    id: 'court-2',
    name: 'Football Ground',
    sportType: 'Football',
    size: '90m x 45m',
    status: CourtStatus.active,
    amenities: ['Parking', 'Water', 'Lights'],
    baseRate: 800,
    peakRate: 1000,
    offPeakRate: 600,
    occupancyBooked: 4,
    occupancyTotal: 6,
    openingHours: '6:00 AM - 11:00 PM',
    days: 'Mon-Sun',
    maintenanceHistory: ['08 Apr 2026 - Turf brush service'],
  ),
  ArenaCourt(
    id: 'court-3',
    name: 'Badminton Court A',
    sportType: 'Badminton',
    size: '13.4m x 6.1m',
    status: CourtStatus.maintenance,
    amenities: ['Parking', 'Changing Rooms'],
    baseRate: 400,
    peakRate: 550,
    offPeakRate: 300,
    occupancyBooked: 3,
    occupancyTotal: 8,
    openingHours: '7:00 AM - 10:00 PM',
    days: 'Mon-Sun',
    maintenanceHistory: ['20 Apr 2026 - Flooring polish'],
  ),
  ArenaCourt(
    id: 'court-4',
    name: 'Badminton Court B',
    sportType: 'Badminton',
    size: '13.4m x 6.1m',
    status: CourtStatus.closed,
    amenities: ['Water'],
    baseRate: 350,
    peakRate: 450,
    offPeakRate: 250,
    occupancyBooked: 0,
    occupancyTotal: 8,
    openingHours: '7:00 AM - 10:00 PM',
    days: 'Mon-Sat',
    maintenanceHistory: ['01 Apr 2026 - Closed for repainting'],
  ),
];

const arenaSlots = [
  ArenaSlot(
    id: 'slot-1',
    courtId: 'court-1',
    courtName: 'Turf Field 1',
    date: '23 Apr 2026',
    startTime: '6:00 PM',
    endTime: '7:00 PM',
    duration: '1 hour',
    price: 500,
    status: SlotStatus.booked,
  ),
  ArenaSlot(
    id: 'slot-2',
    courtId: 'court-1',
    courtName: 'Turf Field 1',
    date: '23 Apr 2026',
    startTime: '7:00 PM',
    endTime: '8:00 PM',
    duration: '1 hour',
    price: 700,
    status: SlotStatus.available,
  ),
  ArenaSlot(
    id: 'slot-3',
    courtId: 'court-2',
    courtName: 'Football Ground',
    date: '23 Apr 2026',
    startTime: '8:00 PM',
    endTime: '9:00 PM',
    duration: '1 hour',
    price: 1000,
    status: SlotStatus.blocked,
    blockReason: 'Maintenance',
  ),
];

const arenaBookings = [
  ArenaBooking(
    id: 'ab-1',
    confirmationNumber: 'GF-2401',
    date: '23 Apr 2026',
    timeSlot: '6:00 PM - 7:00 PM',
    duration: '1 hour',
    sport: 'Cricket',
    customerName: 'Rahul Verma',
    phone: '+91 98765 10101',
    email: 'rahul@example.com',
    status: BookingStatus.confirmed,
    paymentStatus: PaymentStatus.paid,
    courtName: 'Turf Field 1',
    amount: 500,
    specialRequest: 'Need cones for warm-up.',
  ),
  ArenaBooking(
    id: 'ab-2',
    confirmationNumber: 'GF-2402',
    date: '23 Apr 2026',
    timeSlot: '7:00 PM - 8:00 PM',
    duration: '1 hour',
    sport: 'Football',
    customerName: 'North FC',
    phone: '+91 98765 20202',
    email: 'manager@northfc.in',
    status: BookingStatus.pending,
    paymentStatus: PaymentStatus.pending,
    courtName: 'Football Ground',
    amount: 1000,
    specialRequest: '',
  ),
  ArenaBooking(
    id: 'ab-3',
    confirmationNumber: 'GF-2403',
    date: '23 Apr 2026',
    timeSlot: '8:00 AM - 9:00 AM',
    duration: '1 hour',
    sport: 'Badminton',
    customerName: 'Aditi Rao',
    phone: '+91 98765 30303',
    email: 'aditi@example.com',
    status: BookingStatus.completed,
    paymentStatus: PaymentStatus.paid,
    courtName: 'Badminton Court A',
    amount: 400,
    specialRequest: 'Racket rental requested.',
  ),
  ArenaBooking(
    id: 'ab-4',
    confirmationNumber: 'GF-2404',
    date: '24 Apr 2026',
    timeSlot: '5:00 PM - 6:00 PM',
    duration: '1 hour',
    sport: 'Cricket',
    customerName: 'Private Event',
    phone: '+91 98765 40404',
    email: 'events@example.com',
    status: BookingStatus.cancelled,
    paymentStatus: PaymentStatus.partial,
    courtName: 'Turf Field 1',
    amount: 700,
    specialRequest: 'Private coaching setup.',
  ),
];

const arenaQuickActions = [
  ArenaQuickAction(
    title: 'Courts',
    subtitle: 'Manage facility spaces',
    icon: Icons.stadium_rounded,
    route: AppRoutes.arenaAssets,
  ),
  ArenaQuickAction(
    title: 'Slots',
    subtitle: 'Create and block time slots',
    icon: Icons.schedule_rounded,
    route: AppRoutes.arenaSlots,
  ),
  ArenaQuickAction(
    title: 'Bookings',
    subtitle: 'Track and update bookings',
    icon: Icons.book_online_rounded,
    route: AppRoutes.arenaBookings,
  ),
  ArenaQuickAction(
    title: 'Pricing',
    subtitle: 'Rates and peak rules',
    icon: Icons.price_change_rounded,
    route: AppRoutes.arenaPricingManual,
  ),
  ArenaQuickAction(
    title: 'Earnings',
    subtitle: 'Revenue and settlements',
    icon: Icons.account_balance_wallet_rounded,
    route: AppRoutes.arenaEarnings,
  ),
  ArenaQuickAction(
    title: 'Reviews',
    subtitle: 'Customer feedback',
    icon: Icons.reviews_rounded,
    route: AppRoutes.arenaReviews,
  ),
  ArenaQuickAction(
    title: 'Settings',
    subtitle: 'Facility preferences',
    icon: Icons.settings_rounded,
    route: AppRoutes.arenaProfile,
  ),
];

const arenaSettlements = [
  ArenaSettlement(
    date: '15 Apr 2026',
    amount: 68000,
    method: 'Bank Transfer',
    period: 'Apr 1 - Apr 15',
  ),
  ArenaSettlement(
    date: '31 Mar 2026',
    amount: 121000,
    method: 'NEFT',
    period: 'Mar 16 - Mar 31',
  ),
];

const arenaReviews = [
  ArenaReview(
    customerName: 'Rahul Verma',
    date: '22 Apr 2026',
    rating: 4.5,
    review: 'Great facilities and courteous staff.',
    replyDate: '23 Apr 2026',
  ),
  ArenaReview(
    customerName: 'Aditi Rao',
    date: '20 Apr 2026',
    rating: 4.0,
    review: 'Clean courts and easy booking flow.',
  ),
  ArenaReview(
    customerName: 'North FC',
    date: '18 Apr 2026',
    rating: 4.3,
    review: 'Lighting and parking are reliable during evening sessions.',
  ),
];

const arenaRevenueByCourt = {
  'Turf Field 1': 65000,
  'Football Ground': 55000,
  'Badminton Court A': 48000,
  'Badminton Court B': 17000,
};

const arenaTimeline = [
  'Booking created on 20 Apr 2026',
  'Reminder sent on 22 Apr 2026',
  'Payment recorded on 23 Apr 2026',
];
