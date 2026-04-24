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
      title: 'Arena Manager',
      currentIndex: 0,
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () => context.push(AppRoutes.sharedNotifications),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: arenaGreen,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '3',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          icon: const CircleAvatar(
            radius: 16,
            backgroundColor: arenaGreen,
            child:
                Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
          ),
          onSelected: (value) {
            if (value == 'profile') {
              context.push(AppRoutes.sharedProfileMenu);
            } else if (value == 'search') {
              context.push(AppRoutes.sharedSearch);
            } else if (value == 'settings') {
              context.push(AppRoutes.arenaProfile);
            } else if (value == 'logout') {
              context.push(AppRoutes.sharedLogoutConfirm);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'profile', child: Text('Account')),
            PopupMenuItem(value: 'search', child: Text('Search')),
            PopupMenuItem(value: 'settings', child: Text('Settings')),
            PopupMenuItem(value: 'logout', child: Text('Logout')),
          ],
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _ArenaBanner(),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: _MetricCard('Rs 8,500', "Today's Revenue")),
              SizedBox(width: 10),
              Expanded(child: _MetricCard('6 / 10', "Today's Bookings")),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: _MetricCard('60%', 'Occupancy')),
              SizedBox(width: 10),
              Expanded(child: _MetricCard('Rs 2,000', 'Pending Payment')),
            ],
          ),
          const ArenaSectionTitle('Quick Access'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: arenaQuickActions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .96,
            ),
            itemBuilder: (context, index) {
              final action = arenaQuickActions[index];
              return ArenaCard(
                onTap: () => context.push(action.route),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ArenaGlowIcon(action.icon),
                    const SizedBox(height: 10),
                    Text(
                      action.title,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: arenaText,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const ArenaSectionTitle("Today's Bookings"),
          ...arenaBookings.take(3).map(
                (booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BookingCard(booking: booking),
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
      title: 'Courts & Grounds',
      currentIndex: 1,
      actions: [
        TextButton.icon(
          onPressed: () => context.push(AppRoutes.arenaAddEditAsset),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Court'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ArenaCard(
            child: Column(
              children: [
                ArenaDropdown(
                  label: 'Sport Type',
                  value: 'All',
                  items: ['All', 'Cricket', 'Football', 'Badminton'],
                ),
                ArenaDropdown(
                  label: 'Status',
                  value: 'All',
                  items: ['All', 'Active', 'Under Maintenance', 'Closed'],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '4 Courts',
            style: TextStyle(
              color: arenaText,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          ...arenaCourts.map(
            (court) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ArenaCard(
                onTap: () =>
                    context.push('${AppRoutes.arenaCourtDetail}/${court.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const ArenaGlowIcon(Icons.stadium_rounded),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                court.name,
                                style: const TextStyle(
                                  color: arenaText,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                court.sportType,
                                style: const TextStyle(color: arenaMuted),
                              ),
                            ],
                          ),
                        ),
                        ArenaStatusBadge(
                          label: courtStatusLabel(court.status),
                          positive: court.status == CourtStatus.active,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: court.amenities
                          .map((item) => Chip(
                                label: Text(item),
                                backgroundColor: arenaBg,
                                side: const BorderSide(color: arenaBorder),
                                labelStyle: const TextStyle(
                                    color: arenaMuted, fontSize: 12),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    ArenaInfoRow('Rate', '${arenaMoney(court.baseRate)}/hour'),
                    ArenaInfoRow(
                      'Occupancy today',
                      '${court.occupancyBooked} / ${court.occupancyTotal} slots booked',
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

class ArenaCourtDetailScreen extends StatelessWidget {
  const ArenaCourtDetailScreen({super.key, required this.courtId});

  final String courtId;

  @override
  Widget build(BuildContext context) {
    final court = arenaCourts.firstWhere(
      (item) => item.id == courtId,
      orElse: () => arenaCourts.first,
    );
    final courtSlots =
        arenaSlots.where((slot) => slot.courtId == court.id).toList();
    final courtBookings = arenaBookings
        .where((booking) => booking.courtName == court.name)
        .toList();

    return DefaultTabController(
      length: 4,
      child: ArenaScaffold(
        title: 'Court Detail',
        currentIndex: 1,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ArenaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const ArenaGlowIcon(Icons.stadium_rounded, size: 52),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                court.name,
                                style: const TextStyle(
                                  color: arenaText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                court.sportType,
                                style: const TextStyle(color: arenaMuted),
                              ),
                            ],
                          ),
                        ),
                        ArenaStatusBadge(
                          label: courtStatusLabel(court.status),
                          positive: court.status == CourtStatus.active,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () =>
                              context.push(AppRoutes.arenaAddEditAsset),
                          child: const Text('Edit'),
                        ),
                        OutlinedButton(
                            onPressed: () {}, child: const Text('Delete')),
                        OutlinedButton(
                          onPressed: () =>
                              context.push(AppRoutes.arenaBookings),
                          child: const Text('View Bookings'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const TabBar(
              labelColor: arenaLightGreen,
              unselectedLabelColor: arenaMuted,
              indicatorColor: arenaGreen,
              isScrollable: true,
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Availability / Slots'),
                Tab(text: 'Bookings'),
                Tab(text: 'Maintenance'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ArenaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ArenaInfoRow('Court name', court.name),
                            ArenaInfoRow('Sport type', court.sportType),
                            ArenaInfoRow('Size / dimension', court.size),
                            ArenaInfoRow(
                              'Status',
                              courtStatusLabel(court.status),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Amenities',
                              style: TextStyle(
                                color: arenaText,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...court.amenities.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  item,
                                  style: const TextStyle(color: arenaMuted),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ArenaInfoRow(
                              'Base rate',
                              '${arenaMoney(court.baseRate)}/hour',
                            ),
                            ArenaInfoRow(
                              'Peak rate',
                              '${arenaMoney(court.peakRate)}/hour',
                            ),
                            ArenaInfoRow(
                              'Off-peak rate',
                              '${arenaMoney(court.offPeakRate)}/hour',
                            ),
                            ArenaInfoRow('Opening hours', court.openingHours),
                            ArenaInfoRow('Days', court.days),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...courtSlots.map(
                        (slot) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ArenaCard(
                            onTap: () => context.push(
                              '${AppRoutes.arenaSlotDetail}/${slot.id}',
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${slot.startTime} - ${slot.endTime}',
                                  style: const TextStyle(
                                    color: arenaText,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  slotStatusLabel(slot.status),
                                  style: const TextStyle(color: arenaMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: _filledStyle(),
                        onPressed: () => context.push(AppRoutes.arenaSlotForm),
                        child: const Text('Add Slot'),
                      ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...courtBookings.map(
                        (booking) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: BookingCard(booking: booking),
                        ),
                      ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...court.maintenanceHistory.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ArenaCard(
                            child: Text(
                              item,
                              style: const TextStyle(color: arenaMuted),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: _filledStyle(),
                        onPressed: () =>
                            context.push(AppRoutes.arenaMaintenance),
                        child: const Text('Schedule Maintenance'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArenaAddEditAssetScreen extends StatelessWidget {
  const ArenaAddEditAssetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Add / Edit Court',
      currentIndex: 1,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ArenaTextField(
                    label: 'Court name', initialValue: 'Turf Field 1'),
                const ArenaDropdown(
                  label: 'Sport type',
                  value: 'Cricket',
                  items: ['Cricket', 'Football', 'Badminton'],
                ),
                const ArenaTextField(label: 'Court size / Dimension'),
                const ArenaTextField(label: 'Description'),
                const SizedBox(height: 8),
                const Text('Amenities', style: TextStyle(color: arenaMuted)),
                const SizedBox(height: 8),
                const ArenaChoiceWrap(
                  items: ['Lights', 'Parking', 'Water', 'Changing Rooms'],
                ),
                const SizedBox(height: 14),
                const ArenaTextField(
                  label: 'Others',
                  initialValue: 'Cafe, Seating',
                ),
                const ArenaTextField(
                    label: 'Opening time', initialValue: '6:00 AM'),
                const ArenaTextField(
                    label: 'Closing time', initialValue: '10:00 PM'),
                const ArenaDropdown(
                  label: 'Days of operation',
                  value: 'Mon-Sun',
                  items: ['Mon-Sun', 'Mon-Sat'],
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_rounded),
                  label: const Text('Upload Photo'),
                ),
                const SizedBox(height: 14),
                const ArenaTextField(
                  label: 'Base rate',
                  initialValue: '500',
                  keyboardType: TextInputType.number,
                ),
                const ArenaTextField(
                  label: 'Peak rate',
                  initialValue: '700',
                  keyboardType: TextInputType.number,
                ),
                const ArenaTextField(
                  label: 'Off-peak rate',
                  initialValue: '300',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: _filledStyle(),
                        onPressed: () => context.pop(),
                        child: const Text('Save Court'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
      actions: [
        TextButton.icon(
          onPressed: () => context.push(AppRoutes.arenaSlotForm),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Create Slot'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ArenaCard(
            child: Column(
              children: [
                ArenaDropdown(
                  label: 'Court',
                  value: 'All courts',
                  items: ['All courts', 'Turf Field 1', 'Football Ground'],
                ),
                ArenaDropdown(
                  label: 'Status',
                  value: 'All',
                  items: ['All', 'Available', 'Booked', 'Blocked'],
                ),
                ArenaTextField(label: 'Date', initialValue: '23 Apr 2026'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '32 Slots',
            style: TextStyle(
              color: arenaText,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          ...arenaSlots.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ArenaCard(
                onTap: () =>
                    context.push('${AppRoutes.arenaSlotDetail}/${slot.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${slot.courtName} - ${slot.startTime} to ${slot.endTime}',
                      style: const TextStyle(
                        color: arenaText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${slot.date} - ${slotStatusLabel(slot.status)} - ${arenaMoney(slot.price)}',
                      style: const TextStyle(color: arenaMuted),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.push(
                            '${AppRoutes.arenaSlotDetail}/${slot.id}',
                          ),
                          child: const Text('View Details'),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: Text(
                            slot.status == SlotStatus.blocked
                                ? 'Unblock'
                                : 'Block',
                          ),
                        ),
                      ],
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

class ArenaManageSlotsScreen extends StatelessWidget {
  const ArenaManageSlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ArenaSlotFormScreen();
  }
}

class ArenaSlotDetailScreen extends StatelessWidget {
  const ArenaSlotDetailScreen({super.key, required this.slotId});

  final String slotId;

  @override
  Widget build(BuildContext context) {
    final slot = arenaSlots.firstWhere(
      (item) => item.id == slotId,
      orElse: () => arenaSlots.first,
    );
    return ArenaScaffold(
      title: 'Slot Detail',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.courtName,
                  style: const TextStyle(
                    color: arenaText,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                ArenaInfoRow('Date', slot.date),
                ArenaInfoRow('Time', '${slot.startTime} - ${slot.endTime}'),
                ArenaInfoRow('Duration', slot.duration),
                ArenaInfoRow('Price', arenaMoney(slot.price)),
                ArenaInfoRow('Status', slotStatusLabel(slot.status)),
                if (slot.blockReason != null)
                  ArenaInfoRow('Reason', slot.blockReason!),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => context.push(AppRoutes.arenaSlotForm),
                      child: const Text('Edit Slot'),
                    ),
                    OutlinedButton(
                        onPressed: () {}, child: const Text('Delete')),
                    OutlinedButton(
                      onPressed: () {},
                      child: Text(
                        slot.status == SlotStatus.blocked
                            ? 'Unblock Slot'
                            : 'Block Slot',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArenaSlotFormScreen extends StatelessWidget {
  const ArenaSlotFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Create / Edit Slot',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ArenaDropdown(
                  label: 'Court',
                  value: 'Turf Field 1',
                  items: [
                    'Turf Field 1',
                    'Football Ground',
                    'Badminton Court A'
                  ],
                ),
                const ArenaTextField(
                    label: 'Date', initialValue: '23 Apr 2026'),
                const ArenaTextField(
                    label: 'Start time', initialValue: '7:00 PM'),
                const ArenaTextField(
                    label: 'End time', initialValue: '8:00 PM'),
                const ArenaTextField(label: 'Duration', initialValue: '1 hour'),
                const SizedBox(height: 8),
                const ArenaTextField(
                  label: 'Price for this slot',
                  initialValue: '700',
                  keyboardType: TextInputType.number,
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Use Court Default Price'),
                ),
                const SizedBox(height: 12),
                const ArenaDropdown(
                  label: 'Status',
                  value: 'Available',
                  items: ['Available', 'Blocked'],
                ),
                const ArenaTextField(
                    label: 'Reason', initialValue: 'Maintenance'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: _filledStyle(),
                        onPressed: () => context.pop(),
                        child: const Text('Create Slot'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text('Create Multiple Slots'),
                ),
              ],
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
    return DefaultTabController(
      length: 4,
      child: ArenaScaffold(
        title: 'Bookings',
        currentIndex: 2,
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.arenaBookingForm),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New Booking'),
          ),
        ],
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ArenaCard(
                child: Column(
                  children: [
                    ArenaDropdown(
                      label: 'Status',
                      value: 'All',
                      items: [
                        'All',
                        'Confirmed',
                        'Pending',
                        'Cancelled',
                        'Completed'
                      ],
                    ),
                    ArenaTextField(
                        label: 'Date range', initialValue: '23 Apr - 30 Apr'),
                    ArenaTextField(label: 'Search by customer name'),
                  ],
                ),
              ),
            ),
            const TabBar(
              labelColor: arenaLightGreen,
              unselectedLabelColor: arenaMuted,
              indicatorColor: arenaGreen,
              tabs: [
                Tab(text: 'All'),
                Tab(text: 'Confirmed'),
                Tab(text: 'Pending'),
                Tab(text: 'Completed'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _BookingList(bookings: arenaBookings),
                  _BookingList(
                    bookings: arenaBookings
                        .where((item) => item.status == BookingStatus.confirmed)
                        .toList(),
                  ),
                  _BookingList(
                    bookings: arenaBookings
                        .where((item) => item.status == BookingStatus.pending)
                        .toList(),
                  ),
                  _BookingList(
                    bookings: arenaBookings
                        .where((item) => item.status == BookingStatus.completed)
                        .toList(),
                  ),
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
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${booking.courtName} - ${booking.timeSlot}',
                  style: const TextStyle(
                    color: arenaText,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  booking.customerName,
                  style: const TextStyle(color: arenaMuted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ArenaStatusBadge(
                      label: bookingStatusLabel(booking.status),
                      positive: booking.status == BookingStatus.confirmed ||
                          booking.status == BookingStatus.completed,
                    ),
                    ArenaStatusBadge(
                      label: paymentStatusLabel(booking.paymentStatus),
                      positive: booking.paymentStatus == PaymentStatus.paid,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ArenaInfoRow('Confirmation number', booking.confirmationNumber),
                ArenaInfoRow('Booking date', booking.date),
                ArenaInfoRow('Duration', booking.duration),
                ArenaInfoRow('Customer phone', booking.phone),
                ArenaInfoRow('Customer email', booking.email),
                ArenaInfoRow('Amount', arenaMoney(booking.amount)),
                ArenaInfoRow(
                    'Special request',
                    booking.specialRequest.isEmpty
                        ? 'None'
                        : booking.specialRequest),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(onPressed: () {}, child: const Text('Edit')),
                    OutlinedButton(
                        onPressed: () {}, child: const Text('Cancel')),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Resend Reminder'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking Timeline',
                  style: TextStyle(
                    color: arenaText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                ...arenaTimeline.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child:
                        Text(item, style: const TextStyle(color: arenaMuted)),
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

class ArenaBookingFormScreen extends StatelessWidget {
  const ArenaBookingFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Create Booking',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ArenaTextField(label: 'Customer name'),
                const ArenaTextField(label: 'Phone'),
                const ArenaTextField(label: 'Email'),
                const ArenaDropdown(
                  label: 'Court',
                  value: 'Turf Field 1',
                  items: [
                    'Turf Field 1',
                    'Football Ground',
                    'Badminton Court A'
                  ],
                ),
                const ArenaTextField(
                    label: 'Date', initialValue: '24 Apr 2026'),
                const ArenaDropdown(
                  label: 'Time',
                  value: '6:00 PM - 7:00 PM',
                  items: ['6:00 PM - 7:00 PM', '7:00 PM - 8:00 PM'],
                ),
                const ArenaTextField(label: 'Duration', initialValue: '1 hour'),
                const ArenaTextField(label: 'Price', initialValue: '500'),
                const ArenaTextField(label: 'Discount', initialValue: '0'),
                const ArenaTextField(label: 'Total', initialValue: '500'),
                const ArenaDropdown(
                  label: 'Payment status',
                  value: 'Paid',
                  items: ['Paid', 'Pending'],
                ),
                const ArenaDropdown(
                  label: 'Payment method',
                  value: 'UPI',
                  items: ['Cash', 'Card', 'UPI', 'Bank Transfer'],
                ),
                const ArenaTextField(label: 'Special Requests'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: _filledStyle(),
                        onPressed: () => context.pop(),
                        child: const Text('Create Booking'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArenaPricingManualScreen extends StatelessWidget {
  const ArenaPricingManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Pricing',
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: _filledStyle(),
              onPressed: () {},
              child: const Text('Edit Pricing'),
            ),
          ),
          const SizedBox(height: 12),
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Base Pricing',
                  style:
                      TextStyle(color: arenaText, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                ...arenaCourts.map(
                  (court) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ArenaInfoRow(
                      court.name,
                      '${arenaMoney(court.baseRate)}/hour',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dynamic Pricing',
                  style:
                      TextStyle(color: arenaText, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12),
                ArenaInfoRow('Peak Hours', '6:00 PM - 8:00 PM'),
                ArenaInfoRow('Surcharge', '+Rs 200 / +40%'),
                ArenaInfoRow('Days', 'Mon, Tue, Wed, Thu, Fri'),
                Divider(color: arenaBorder),
                ArenaInfoRow('Off-Peak', '6:00 AM - 12:00 PM'),
                ArenaInfoRow('Discount', '-Rs 100 / -20%'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pricing Rules',
                  style:
                      TextStyle(color: arenaText, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12),
                Text(
                  'Peak hour surcharge applies Mon-Fri. Off-peak discount applies on morning slots.',
                  style: TextStyle(color: arenaMuted),
                ),
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
    return DefaultTabController(
      length: 4,
      child: ArenaScaffold(
        title: 'Earnings',
        currentIndex: 3,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Export Report'),
          ),
        ],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  const ArenaTextField(
                      label: 'Date range', initialValue: 'Apr 2026'),
                  Row(
                    children: const [
                      Expanded(child: _MetricCard('Rs 8,500', 'Today')),
                      SizedBox(width: 10),
                      Expanded(child: _MetricCard('Rs 52,000', 'This Week')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Expanded(child: _MetricCard('Rs 1,85,000', 'This Month')),
                      SizedBox(width: 10),
                      Expanded(
                          child: _MetricCard('Rs 18,50,000', 'Year to Date')),
                    ],
                  ),
                ],
              ),
            ),
            const TabBar(
              labelColor: arenaLightGreen,
              unselectedLabelColor: arenaMuted,
              indicatorColor: arenaGreen,
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Payment Status'),
                Tab(text: 'Settlements'),
                Tab(text: 'Analytics'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ArenaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Court-wise Revenue',
                              style: TextStyle(
                                color: arenaText,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...arenaRevenueByCourt.entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ArenaInfoRow(
                                  entry.key,
                                  arenaMoney(entry.value),
                                ),
                              ),
                            ),
                            const Divider(color: arenaBorder),
                            const ArenaInfoRow(
                                'Most booked court', 'Turf Field 1'),
                            const ArenaInfoRow(
                                'Peak slot', '7:00 PM - 8:00 PM'),
                            const ArenaInfoRow('Best day', 'Saturday'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...arenaBookings
                          .where((item) =>
                              item.paymentStatus != PaymentStatus.paid)
                          .map(
                            (booking) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ArenaCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.confirmationNumber,
                                      style: const TextStyle(
                                        color: arenaText,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ArenaInfoRow(
                                        'Customer', booking.customerName),
                                    ArenaInfoRow(
                                        'Amount', arenaMoney(booking.amount)),
                                    ArenaInfoRow('Date due', booking.date),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        OutlinedButton(
                                          onPressed: () {},
                                          child: const Text('Send Reminder'),
                                        ),
                                        OutlinedButton(
                                          onPressed: () {},
                                          child: const Text('Record Payment'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...arenaSettlements.map(
                        (settlement) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ArenaCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ArenaInfoRow(
                                    'Settlement date', settlement.date),
                                ArenaInfoRow(
                                    'Amount', arenaMoney(settlement.amount)),
                                ArenaInfoRow('Method', settlement.method),
                                ArenaInfoRow('Period', settlement.period),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      ArenaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analytics',
                              style: TextStyle(
                                color: arenaText,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Revenue trend, occupancy by slot, and peak-hour heatmap blocks are prepared as API-ready placeholders.',
                              style: TextStyle(color: arenaMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArenaPaymentsScreen extends StatelessWidget {
  const ArenaPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ArenaEarningsScreen();
  }
}

class ArenaReviewsScreen extends StatelessWidget {
  const ArenaReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Reviews',
      currentIndex: 4,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average rating 4.3 / 5',
                  style: TextStyle(
                    color: arenaText,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text('28 reviews', style: TextStyle(color: arenaMuted)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...arenaReviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ArenaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      style: const TextStyle(
                        color: arenaText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${review.date} - ${review.rating} / 5',
                      style: const TextStyle(color: arenaMuted),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.review,
                      style: const TextStyle(color: arenaText),
                    ),
                    const SizedBox(height: 10),
                    if (review.replyDate != null)
                      Text(
                        'You replied on ${review.replyDate}',
                        style: const TextStyle(color: arenaMuted),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () => _showReplyDialog(context),
                            child: const Text('Reply'),
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('Mark Helpful'),
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('Report'),
                          ),
                        ],
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

class ArenaProfileScreen extends ConsumerWidget {
  const ArenaProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ArenaScaffold(
      title: 'Arena Settings',
      currentIndex: 4,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Facility Information',
                  style:
                      TextStyle(color: arenaText, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12),
                ArenaInfoRow('Facility', arenaName),
                ArenaInfoRow('Address', 'Sector 9, Ahmedabad'),
                ArenaInfoRow('Phone', '+91 98765 90909'),
                ArenaInfoRow('Email', 'ops@greenfieldarena.in'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription Plan',
                  style:
                      TextStyle(color: arenaText, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12),
                ArenaInfoRow('Current plan', 'Professional'),
                Text('Up to 4 courts, booking management, revenue analytics',
                    style: TextStyle(color: arenaMuted)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Methods',
                  style:
                      TextStyle(color: arenaText, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12),
                ArenaInfoRow('Bank account', 'XXXXXX2109'),
                ArenaInfoRow('Settlement frequency', 'Weekly'),
                ArenaInfoRow('Settlement method', 'Bank Transfer'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style:
                      TextStyle(color: arenaText, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 12),
                Text('Booking notifications',
                    style: TextStyle(color: arenaText)),
                SizedBox(height: 8),
                Text('Payment reminders', style: TextStyle(color: arenaText)),
                SizedBox(height: 8),
                Text('Review alerts', style: TextStyle(color: arenaText)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Help & Support',
                  style:
                      TextStyle(color: arenaText, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                const Text('Contact Support',
                    style: TextStyle(color: arenaText)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: _filledStyle(),
                    onPressed: () =>
                        ref.read(sessionControllerProvider.notifier).signOut(),
                    child: const Text('Logout'),
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

class ArenaTodayScheduleScreen extends StatelessWidget {
  const ArenaTodayScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: "Today's Schedule",
      currentIndex: 0,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: arenaBookings
            .where((booking) => booking.date == '23 Apr 2026')
            .map(
              (booking) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BookingCard(booking: booking),
              ),
            )
            .toList(),
      ),
    );
  }
}

class ArenaCalendarScreen extends StatelessWidget {
  const ArenaCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Calendar',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ArenaChoiceWrap(items: ['Monthly', 'Weekly'], selectedIndex: 1),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: arenaSlots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, index) {
              final slot = arenaSlots[index];
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
                        const Text(
                          'Booking Details',
                          style: TextStyle(
                            color: arenaText,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ArenaInfoRow('Court', slot.courtName),
                        ArenaInfoRow(
                            'Time', '${slot.startTime} - ${slot.endTime}'),
                        ArenaInfoRow('Status', slotStatusLabel(slot.status)),
                      ],
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.courtName,
                      style: const TextStyle(
                        color: arenaText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _slotColor(slot.status),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${slot.startTime} - ${slot.endTime}',
                      style: const TextStyle(color: arenaMuted),
                    ),
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
                  value: 'Turf Field 1',
                  items: [
                    'Turf Field 1',
                    'Football Ground',
                    'Badminton Court A'
                  ],
                ),
                const ArenaTextField(
                    label: 'Date Range', initialValue: '23 Apr - 24 Apr'),
                const ArenaTextField(
                    label: 'Time Range', initialValue: '2:00 PM - 5:00 PM'),
                const ArenaDropdown(
                  label: 'Reason',
                  value: 'Maintenance',
                  items: ['Maintenance', 'Private', 'Other'],
                ),
                FilledButton(
                  style: _filledStyle(),
                  onPressed: () => context.pop(),
                  child: const Text('Block Slot'),
                ),
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
    return DefaultTabController(
      length: 2,
      child: ArenaScaffold(
        title: 'Maintenance',
        currentIndex: 1,
        child: Column(
          children: [
            const TabBar(
              labelColor: arenaLightGreen,
              unselectedLabelColor: arenaMuted,
              indicatorColor: arenaGreen,
              tabs: [Tab(text: 'Daily'), Tab(text: 'Weekly')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _MaintenanceList(tasks: const [
                    'Net inspection',
                    'Lighting check',
                    'Turf brushing',
                  ]),
                  _MaintenanceList(tasks: const [
                    'Deep turf wash',
                    'Boundary repair',
                    'Equipment audit',
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

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking});

  final ArenaBooking booking;

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      onTap: () => context.push('${AppRoutes.arenaBookings}/${booking.id}'),
      child: Row(
        children: [
          const ArenaGlowIcon(Icons.book_online_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${booking.timeSlot} - ${booking.courtName}',
                  style: const TextStyle(
                    color: arenaText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.customerName,
                  style: const TextStyle(color: arenaMuted),
                ),
              ],
            ),
          ),
          ArenaStatusBadge(
            label: bookingStatusLabel(booking.status),
            positive: booking.status == BookingStatus.confirmed ||
                booking.status == BookingStatus.completed,
          ),
        ],
      ),
    );
  }
}

class _ArenaBanner extends StatelessWidget {
  const _ArenaBanner();

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
                      'Welcome back, Greenfield Sports Arena',
                      style: TextStyle(
                        color: arenaText,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('Today\'s Status',
                        style: TextStyle(color: arenaMuted)),
                  ],
                ),
              ),
              ArenaStatusBadge(label: 'Open'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({required this.bookings});

  final List<ArenaBooking> bookings;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (bookings.isEmpty)
          const ArenaCard(
            child:
                Text('No bookings today', style: TextStyle(color: arenaMuted)),
          ),
        ...bookings.map(
          (booking) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ArenaCard(
              onTap: () =>
                  context.push('${AppRoutes.arenaBookings}/${booking.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${booking.date} - ${booking.timeSlot}',
                    style: const TextStyle(
                      color: arenaText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${booking.courtName} - ${booking.customerName}',
                    style: const TextStyle(color: arenaMuted),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ArenaStatusBadge(
                        label: bookingStatusLabel(booking.status),
                        positive: booking.status == BookingStatus.confirmed ||
                            booking.status == BookingStatus.completed,
                      ),
                      ArenaStatusBadge(
                        label: paymentStatusLabel(booking.paymentStatus),
                        positive: booking.paymentStatus == PaymentStatus.paid,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
        ...tasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ArenaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task,
                    style: const TextStyle(
                      color: arenaText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Asset: Turf Field 1',
                      style: TextStyle(color: arenaMuted)),
                  const Text('Status: Pending',
                      style: TextStyle(color: arenaMuted)),
                  const SizedBox(height: 10),
                  FilledButton(
                    style: _filledStyle(),
                    onPressed: () {},
                    child: const Text('Mark as Completed'),
                  ),
                ],
              ),
            ),
          ),
        ),
        FilledButton.icon(
          style: _filledStyle(),
          onPressed: () {},
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('Add Maintenance Task'),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
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

ButtonStyle _filledStyle() {
  return FilledButton.styleFrom(
    backgroundColor: arenaGreen,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

Color _slotColor(SlotStatus status) {
  return switch (status) {
    SlotStatus.available => arenaGreen,
    SlotStatus.booked => const Color(0xFFEF4444),
    SlotStatus.blocked => const Color(0xFF6B7280),
  };
}

Future<void> _showReplyDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: arenaCard,
      title: const Text('Reply to Review', style: TextStyle(color: arenaText)),
      content: const ArenaTextField(label: 'Response'),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: _filledStyle(),
          onPressed: () => context.pop(),
          child: const Text('Send Reply'),
        ),
      ],
    ),
  );
}
