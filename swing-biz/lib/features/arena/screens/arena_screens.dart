import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';
import '../models/arena_models.dart';
import '../services/arena_dummy_data.dart';
import '../widgets/arena_widgets.dart';

class ArenaHomeScreen extends StatelessWidget {
  const ArenaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Arena',
      currentIndex: 0,
      actions: [
        IconButton(
          tooltip: 'Profile',
          icon: const Icon(Icons.settings_rounded),
          onPressed: () => context.push(AppRoutes.arenaProfile),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _ArenaHeaderCard(),
          const ArenaSectionTitle("Today's Bookings"),
          ...arenaBookings.take(3).map(
                (booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BookingCard(booking: booking),
                ),
              ),
          const ArenaSectionTitle('Quick Actions'),
          const _ArenaQuickActionGrid(),
          const ArenaSectionTitle('Arena Assets'),
          ...arenaAssets.map(
            (asset) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ArenaCard(
                child: Row(
                  children: [
                    const ArenaGlowIcon(Icons.stadium_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asset.name,
                            style: const TextStyle(
                              color: arenaText,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            asset.sport,
                            style: const TextStyle(color: arenaMuted),
                          ),
                        ],
                      ),
                    ),
                    ArenaStatusBadge(
                      label: asset.available ? 'Available' : 'Blocked',
                      positive: asset.available,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArenaBookingsScreen extends StatelessWidget {
  const ArenaBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      child: ArenaScaffold(
        title: 'Bookings',
        currentIndex: 1,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _FilterRow(),
            ),
            TabBar(
              labelColor: arenaLightGreen,
              unselectedLabelColor: arenaMuted,
              indicatorColor: arenaGreen,
              tabs: [
                Tab(text: 'Today'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _BookingManagementList(),
                  _BookingManagementList(),
                  _BookingManagementList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArenaManageSlotsScreen extends StatefulWidget {
  const ArenaManageSlotsScreen({super.key});

  @override
  State<ArenaManageSlotsScreen> createState() => _ArenaManageSlotsScreenState();
}

class _ArenaManageSlotsScreenState extends State<ArenaManageSlotsScreen> {
  bool recurring = true;

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Manage Slots',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ArenaDropdown(
                  label: 'Select Arena Asset',
                  value: 'Turf Ground A',
                  items: ['Turf Ground A', 'Football Field', 'Badminton Court'],
                ),
                const Row(
                  children: [
                    Expanded(
                        child: ArenaTextField(
                            label: 'Start Time', initialValue: '06:00 AM')),
                    SizedBox(width: 10),
                    Expanded(
                        child: ArenaTextField(
                            label: 'End Time', initialValue: '07:00 AM')),
                  ],
                ),
                const Text('Slot Duration',
                    style: TextStyle(color: arenaMuted)),
                const SizedBox(height: 8),
                const ArenaChoiceWrap(
                    items: ['30 min', '60 min', 'Custom'], selectedIndex: 1),
                const SizedBox(height: 16),
                const Text('Days', style: TextStyle(color: arenaMuted)),
                const SizedBox(height: 8),
                const ArenaChoiceWrap(
                    items: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: recurring,
                  activeThumbColor: arenaGreen,
                  title: const Text('Recurring Slot',
                      style: TextStyle(color: arenaText)),
                  subtitle: const Text('Daily / Weekly',
                      style: TextStyle(color: arenaMuted)),
                  onChanged: (value) => setState(() => recurring = value),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No conflict found for selected asset and time.',
                  style: TextStyle(color: arenaLightGreen),
                ),
                const SizedBox(height: 14),
                ArenaPrimaryButton(
                  label: 'Save Slot',
                  icon: Icons.save_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Slot created successfully')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArenaPricingManualScreen extends StatefulWidget {
  const ArenaPricingManualScreen({super.key});

  @override
  State<ArenaPricingManualScreen> createState() =>
      _ArenaPricingManualScreenState();
}

class _ArenaPricingManualScreenState extends State<ArenaPricingManualScreen> {
  bool peak = true;
  bool weekend = true;
  bool paid = true;

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Pricing & Manual Entry',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ArenaSectionTitle('Pricing Rules'),
                const ArenaDropdown(
                    label: 'Select Sport',
                    value: 'Cricket',
                    items: ['Cricket', 'Football', 'Badminton']),
                const ArenaTextField(
                    label: 'Price per hour',
                    initialValue: '2400',
                    keyboardType: TextInputType.number),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: arenaGreen,
                  value: peak,
                  title: const Text('Peak pricing',
                      style: TextStyle(color: arenaText)),
                  onChanged: (value) => setState(() => peak = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: arenaGreen,
                  value: weekend,
                  title: const Text('Weekend pricing',
                      style: TextStyle(color: arenaText)),
                  onChanged: (value) => setState(() => weekend = value),
                ),
                ArenaPrimaryButton(
                    label: 'Save Pricing',
                    icon: Icons.price_check_rounded,
                    onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ArenaSectionTitle('Manual Booking Entry'),
                const ArenaTextField(label: 'Customer Name'),
                const ArenaTextField(
                    label: 'Mobile Number', keyboardType: TextInputType.phone),
                const ArenaDropdown(
                    label: 'Sport',
                    value: 'Cricket',
                    items: ['Cricket', 'Football', 'Badminton']),
                const ArenaTextField(
                    label: 'Time Slot', initialValue: '8:00 PM - 9:00 PM'),
                const ArenaTextField(
                    label: 'Amount', keyboardType: TextInputType.number),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: arenaGreen,
                  value: paid,
                  title: const Text('Mark as Paid',
                      style: TextStyle(color: arenaText)),
                  subtitle: Text(paid ? 'Paid' : 'Unpaid',
                      style: const TextStyle(color: arenaMuted)),
                  onChanged: (value) => setState(() => paid = value),
                ),
                ArenaPrimaryButton(
                    label: 'Save Entry',
                    icon: Icons.add_card_rounded,
                    onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArenaCalendarScreen extends StatelessWidget {
  const ArenaCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final slots = [
      ('6 AM', 'Available', arenaGreen),
      ('8 AM', 'Pending', const Color(0xFFF59E0B)),
      ('5 PM', 'Booked', const Color(0xFFEF4444)),
      ('9 PM', 'Blocked', const Color(0xFF6B7280)),
    ];
    return ArenaScaffold(
      title: 'Calendar',
      currentIndex: 1,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ArenaChoiceWrap(items: ['Monthly', 'Weekly']),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (context, index) {
              final slot = slots[index];
              return ArenaCard(
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: arenaCard,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Booking Details',
                            style: TextStyle(
                                color: arenaText,
                                fontWeight: FontWeight.w900,
                                fontSize: 18)),
                        const SizedBox(height: 12),
                        ArenaInfoRow('Time', slot.$1),
                        ArenaInfoRow('Status', slot.$2),
                      ],
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(slot.$1,
                        style: const TextStyle(
                            color: arenaText, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    Container(
                        width: double.infinity,
                        height: 7,
                        decoration: BoxDecoration(
                            color: slot.$3,
                            borderRadius: BorderRadius.circular(99))),
                    const SizedBox(height: 8),
                    Text(slot.$2, style: const TextStyle(color: arenaMuted)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ArenaBlockSlotScreen extends StatelessWidget {
  const ArenaBlockSlotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Block Slot',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ArenaDropdown(
                    label: 'Select Asset',
                    value: 'Turf Ground A',
                    items: [
                      'Turf Ground A',
                      'Football Field',
                      'Badminton Court'
                    ]),
                const ArenaTextField(
                    label: 'Date Range', initialValue: '23 Apr - 24 Apr'),
                const ArenaTextField(
                    label: 'Time Range', initialValue: '2:00 PM - 5:00 PM'),
                const ArenaDropdown(
                    label: 'Reason',
                    value: 'Maintenance',
                    items: ['Maintenance', 'Private', 'Other']),
                ArenaPrimaryButton(
                    label: 'Block Slot',
                    icon: Icons.event_busy_rounded,
                    onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArenaMaintenanceScreen extends StatelessWidget {
  const ArenaMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: ArenaScaffold(
        title: 'Maintenance',
        currentIndex: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: arenaLightGreen,
              unselectedLabelColor: arenaMuted,
              indicatorColor: arenaGreen,
              tabs: [Tab(text: 'Daily'), Tab(text: 'Weekly')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _MaintenanceList(tasks: [
                    'Net inspection',
                    'Light check',
                    'Turf cleaning'
                  ]),
                  _MaintenanceList(tasks: [
                    'Deep turf wash',
                    'Boundary repair',
                    'Inventory audit'
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArenaBookingDetailScreen extends StatelessWidget {
  const ArenaBookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final booking = arenaBookings.firstWhere(
      (item) => item.id == bookingId,
      orElse: () => arenaBookings.first,
    );
    return ArenaScaffold(
      title: 'Booking Detail',
      currentIndex: 1,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const ArenaGlowIcon(Icons.book_online_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        booking.customerName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: arenaText,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    ArenaStatusBadge(
                      label: bookingStatusLabel(booking.status),
                      positive: booking.status != BookingStatus.cancelled,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ArenaInfoRow('Time slot', booking.timeSlot),
                ArenaInfoRow('Sport', booking.sport),
                ArenaInfoRow('Court / Ground', booking.courtName),
                ArenaInfoRow('Amount', arenaMoney(booking.amount)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.event_repeat_rounded),
                  label: const Text('Reschedule'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cancel_rounded),
                  label: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ArenaSlotsScreen extends StatelessWidget {
  const ArenaSlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Slots',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SlotActionCard(
            icon: Icons.add_alarm_rounded,
            title: 'Create / Edit Slots',
            subtitle: 'Set time windows for daily availability',
          ),
          _SlotActionCard(
            icon: Icons.currency_rupee_rounded,
            title: 'Slot Pricing',
            subtitle: 'Set price per hour and peak pricing',
          ),
          _SlotActionCard(
            icon: Icons.block_rounded,
            title: 'Block / Unblock Slots',
            subtitle: 'Maintenance or private events',
          ),
          _SlotActionCard(
            icon: Icons.repeat_rounded,
            title: 'Recurring Setup',
            subtitle: 'Repeat weekday or weekend slot patterns',
          ),
        ],
      ),
    );
  }
}

class ArenaPaymentsScreen extends StatelessWidget {
  const ArenaPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Payments',
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              children: [
                ArenaInfoRow('Today', arenaMoney(arenaPayments.today)),
                ArenaInfoRow('Weekly', arenaMoney(arenaPayments.weekly)),
                ArenaInfoRow('Monthly', arenaMoney(arenaPayments.monthly)),
                ArenaInfoRow(
                  'Upcoming payout',
                  arenaMoney(arenaPayments.upcomingPayout),
                ),
              ],
            ),
          ),
          const ArenaSectionTitle('Payment History'),
          ...arenaBookings.where((booking) => booking.amount > 0).map(
                (booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ArenaCard(
                    child: Row(
                      children: [
                        const ArenaGlowIcon(Icons.receipt_long_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            booking.customerName,
                            style: const TextStyle(
                              color: arenaText,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          arenaMoney(booking.amount),
                          style: const TextStyle(
                            color: arenaLightGreen,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 8),
          const Text(
            'GST-ready structure can be enabled with billing setup.',
            style: TextStyle(color: arenaMuted),
          ),
        ],
      ),
    );
  }
}

class ArenaProfileScreen extends ConsumerWidget {
  const ArenaProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ArenaScaffold(
      title: 'Profile',
      currentIndex: 4,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  arenaName,
                  style: TextStyle(
                    color: arenaText,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 14),
                const ArenaInfoRow('Type', arenaType),
                const ArenaInfoRow('Contact', '+91 90000 11111'),
                const ArenaInfoRow('Documents', 'Uploaded'),
                const ArenaInfoRow('Bank details', 'Added'),
                const ArenaInfoRow('Plan', 'Free'),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(sessionControllerProvider.notifier)
                        .setActiveProfile(null);
                    if (context.mounted) context.go(AppRoutes.roleSelection);
                  },
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('Switch role'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(sessionControllerProvider.notifier).signOut(),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArenaAssetsScreen extends StatelessWidget {
  const ArenaAssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Arena Assets',
      currentIndex: 4,
      actions: [
        IconButton(
          tooltip: 'Add asset',
          icon: const Icon(Icons.add_rounded),
          onPressed: () => context.push(AppRoutes.arenaAddEditAsset),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...arenaAssets.map(
            (asset) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ArenaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const ArenaGlowIcon(Icons.stadium_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            asset.name,
                            style: const TextStyle(
                              color: arenaText,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        ArenaStatusBadge(
                          label: asset.available
                              ? 'Available'
                              : 'Under Maintenance',
                          positive: asset.available,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ArenaInfoRow('Supported Sports', asset.sport),
                    ArenaPrimaryButton(
                      label: 'Edit Asset',
                      icon: Icons.edit_rounded,
                      onPressed: () =>
                          context.push(AppRoutes.arenaAddEditAsset),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArenaAddEditAssetScreen extends StatefulWidget {
  const ArenaAddEditAssetScreen({super.key});

  @override
  State<ArenaAddEditAssetScreen> createState() =>
      _ArenaAddEditAssetScreenState();
}

class _ArenaAddEditAssetScreenState extends State<ArenaAddEditAssetScreen> {
  bool active = true;

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Add / Edit Asset',
      currentIndex: 4,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ArenaTextField(
                    label: 'Asset Name', initialValue: 'Turf Ground A'),
                const ArenaDropdown(
                    label: 'Asset Type',
                    value: 'Turf',
                    items: ['Turf', 'Ground', 'Court']),
                const Text('Supported Sports',
                    style: TextStyle(color: arenaMuted)),
                const SizedBox(height: 8),
                const ArenaChoiceWrap(
                    items: ['Cricket', 'Football', 'Badminton']),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.image_rounded),
                  label: const Text('Upload Image'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: arenaGreen,
                  value: active,
                  title:
                      const Text('Active', style: TextStyle(color: arenaText)),
                  onChanged: (value) => setState(() => active = value),
                ),
                ArenaPrimaryButton(
                    label: 'Save Asset',
                    icon: Icons.save_rounded,
                    onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArenaEarningsScreen extends StatelessWidget {
  const ArenaEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Earnings',
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                  child:
                      _EarningCard('Today', arenaMoney(arenaPayments.today))),
              const SizedBox(width: 10),
              Expanded(
                  child: _EarningCard(
                      'This Week', arenaMoney(arenaPayments.weekly))),
            ],
          ),
          const SizedBox(height: 10),
          _EarningCard('This Month', arenaMoney(arenaPayments.monthly)),
          const ArenaSectionTitle('Transactions'),
          ...arenaBookings.where((booking) => booking.amount > 0).map(
                (booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ArenaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ArenaInfoRow('Date', '23 Apr 2026'),
                        ArenaInfoRow('Booking ID', booking.id.toUpperCase()),
                        ArenaInfoRow('Sport', booking.sport),
                        ArenaInfoRow('Amount', arenaMoney(booking.amount)),
                        const ArenaInfoRow('Payment Mode', 'UPI'),
                      ],
                    ),
                  ),
                ),
              ),
          ArenaPrimaryButton(
              label: 'Export CSV',
              icon: Icons.download_rounded,
              onPressed: () {}),
        ],
      ),
    );
  }
}

class ArenaTodayScheduleScreen extends StatelessWidget {
  const ArenaTodayScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: "Today's Schedule",
      currentIndex: 0,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final booking in arenaBookings)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ArenaCard(
                onTap: () =>
                    context.push('${AppRoutes.arenaBookings}/${booking.id}'),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 64,
                      decoration: BoxDecoration(
                        color: bookingStatusColor(booking.status),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.timeSlot,
                              style: const TextStyle(
                                  color: arenaText,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text('${booking.sport} | ${booking.customerName}',
                              style: const TextStyle(color: arenaMuted)),
                        ],
                      ),
                    ),
                    ArenaStatusBadge(
                      label: bookingStatusLabel(booking.status),
                      positive: booking.status != BookingStatus.cancelled,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  const BookingCard(
      {super.key, required this.booking, this.showActions = false});

  final ArenaBooking booking;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final statusColor = bookingStatusColor(booking.status);
    return ArenaCard(
      onTap: () => context.push('${AppRoutes.arenaBookings}/${booking.id}'),
      child: Column(
        children: [
          Row(
            children: [
              const ArenaGlowIcon(Icons.confirmation_number_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.timeSlot,
                      style: const TextStyle(
                        color: arenaText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${booking.sport} | ${booking.customerName}',
                      style: const TextStyle(color: arenaMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  bookingStatusLabel(booking.status),
                  style: TextStyle(
                    color: statusColor == arenaGreen
                        ? arenaLightGreen
                        : statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Cancel'),
                  ),
                ),
                IconButton(
                  tooltip: 'Contact User',
                  onPressed: () {},
                  icon: const Icon(Icons.call_rounded, color: arenaLightGreen),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ArenaHeaderCard extends StatelessWidget {
  const _ArenaHeaderCard();

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ArenaGlowIcon(Icons.stadium_rounded, size: 52),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arenaName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: arenaText,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(arenaType, style: TextStyle(color: arenaMuted)),
                  ],
                ),
              ),
              ArenaStatusBadge(label: arenaStatusLabel(arenaStatus)),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Earnings today',
            style: TextStyle(color: arenaMuted),
          ),
          const SizedBox(height: 4),
          Text(
            arenaMoney(arenaPayments.today),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: arenaLightGreen,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _BookingManagementList extends StatelessWidget {
  const _BookingManagementList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final booking in arenaBookings)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: BookingCard(booking: booking, showActions: true),
          ),
      ],
    );
  }
}

class _MaintenanceList extends StatelessWidget {
  const _MaintenanceList({required this.tasks});

  final List<String> tasks;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final task in tasks)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ArenaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ArenaGlowIcon(Icons.cleaning_services_rounded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task,
                          style: const TextStyle(
                            color: arenaText,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const ArenaStatusBadge(label: 'Pending', positive: false),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const ArenaInfoRow('Asset', 'Turf Ground A'),
                  const ArenaInfoRow('Assigned Staff', 'Vikram'),
                  ArenaPrimaryButton(
                    label: 'Mark as Completed',
                    icon: Icons.check_rounded,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ArenaPrimaryButton(
          label: 'Add Maintenance Task',
          icon: Icons.add_task_rounded,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _EarningCard extends StatelessWidget {
  const _EarningCard(this.label, this.amount);

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ArenaGlowIcon(Icons.trending_up_rounded),
          const SizedBox(height: 14),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: arenaLightGreen,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: arenaMuted)),
        ],
      ),
    );
  }
}

class _ArenaQuickActionGrid extends StatelessWidget {
  const _ArenaQuickActionGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: arenaQuickActions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.38,
      ),
      itemBuilder: (context, index) {
        final action = arenaQuickActions[index];
        return ArenaCard(
          onTap: () => context.push(action.route),
          child: Row(
            children: [
              ArenaGlowIcon(action.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: const TextStyle(
                        color: arenaText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      action.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: arenaMuted, fontSize: 12),
                    ),
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

class _FilterRow extends StatelessWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterPill('Date'),
        _FilterPill('Sport'),
        _FilterPill('Status'),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: arenaCard,
      side: const BorderSide(color: arenaBorder),
      labelStyle: const TextStyle(color: arenaMuted),
    );
  }
}

class _SlotActionCard extends StatelessWidget {
  const _SlotActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ArenaCard(
        child: Row(
          children: [
            ArenaGlowIcon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: arenaText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: arenaMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
