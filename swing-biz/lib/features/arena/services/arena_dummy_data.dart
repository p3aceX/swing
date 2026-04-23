import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import '../models/arena_models.dart';

const arenaName = 'Greenfield Sports Arena';
const arenaType = 'Multi-sport';
const arenaStatus = ArenaStatus.open;
const arenaPayments = ArenaPaymentSummary(
  today: 18400,
  weekly: 126500,
  monthly: 486000,
  upcomingPayout: 92000,
);

const arenaBookings = [
  ArenaBooking(
    id: 'ab-1',
    timeSlot: '6:00 AM - 7:00 AM',
    sport: 'Cricket',
    customerName: 'Rahul Verma',
    status: BookingStatus.confirmed,
    courtName: 'Turf Ground A',
    amount: 2400,
  ),
  ArenaBooking(
    id: 'ab-2',
    timeSlot: '8:00 AM - 9:00 AM',
    sport: 'Football',
    customerName: 'North FC',
    status: BookingStatus.pending,
    courtName: 'Football Field',
    amount: 3200,
  ),
  ArenaBooking(
    id: 'ab-3',
    timeSlot: '5:00 PM - 6:00 PM',
    sport: 'Badminton',
    customerName: 'Aditi Rao',
    status: BookingStatus.confirmed,
    courtName: 'Court 2',
    amount: 800,
  ),
  ArenaBooking(
    id: 'ab-4',
    timeSlot: '9:00 PM - 10:00 PM',
    sport: 'Cricket',
    customerName: 'Private Event',
    status: BookingStatus.cancelled,
    courtName: 'Turf Ground B',
    amount: 0,
  ),
];

const arenaAssets = [
  ArenaAsset(name: 'Turf Ground A', sport: 'Cricket', available: true),
  ArenaAsset(name: 'Football Field', sport: 'Football', available: true),
  ArenaAsset(name: 'Court 2', sport: 'Badminton', available: true),
  ArenaAsset(name: 'Turf Ground B', sport: 'Cricket', available: false),
];

const arenaQuickActions = [
  ArenaQuickAction(
    title: 'Manage Slots',
    subtitle: 'Create time slots',
    icon: Icons.schedule_rounded,
    route: AppRoutes.arenaManageSlots,
  ),
  ArenaQuickAction(
    title: 'Bookings',
    subtitle: 'Approve & cancel',
    icon: Icons.book_online_rounded,
    route: AppRoutes.arenaBookings,
  ),
  ArenaQuickAction(
    title: 'Pricing',
    subtitle: 'Manual entries',
    icon: Icons.price_change_rounded,
    route: AppRoutes.arenaPricingManual,
  ),
  ArenaQuickAction(
    title: 'Calendar',
    subtitle: 'Daily / weekly',
    icon: Icons.calendar_month_rounded,
    route: AppRoutes.arenaCalendar,
  ),
  ArenaQuickAction(
    title: 'Block Slot',
    subtitle: 'Maintenance',
    icon: Icons.event_busy_rounded,
    route: AppRoutes.arenaBlockSlot,
  ),
  ArenaQuickAction(
    title: 'Maintenance',
    subtitle: 'Daily / weekly',
    icon: Icons.handyman_rounded,
    route: AppRoutes.arenaMaintenance,
  ),
  ArenaQuickAction(
    title: 'Assets',
    subtitle: 'Courts & grounds',
    icon: Icons.stadium_rounded,
    route: AppRoutes.arenaAssets,
  ),
  ArenaQuickAction(
    title: 'Earnings',
    subtitle: 'Revenue report',
    icon: Icons.account_balance_wallet_rounded,
    route: AppRoutes.arenaEarnings,
  ),
  ArenaQuickAction(
    title: 'Today',
    subtitle: 'Schedule view',
    icon: Icons.view_timeline_rounded,
    route: AppRoutes.arenaTodaySchedule,
  ),
];
