import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';
import '../models/arena_models.dart';
import '../services/arena_court_amenity_store.dart';
import '../services/arena_dummy_data.dart';
import '../widgets/arena_widgets.dart';

final ValueNotifier<List<_ArenaNotificationItem>> _arenaNotificationsNotifier =
    ValueNotifier<List<_ArenaNotificationItem>>([
  _ArenaNotificationItem(
    id: 'notif-1',
    title: 'Booking reminder pending',
    subtitle: 'North FC payment reminder is ready to send',
    time: '10 min ago',
    type: 'Payment',
    unread: true,
  ),
  _ArenaNotificationItem(
    id: 'notif-2',
    title: 'Session reminder',
    subtitle: 'Turf Field 1 booking starts at 6:00 PM',
    time: '30 min ago',
    type: 'Reminder',
    unread: true,
  ),
  _ArenaNotificationItem(
    id: 'notif-3',
    title: 'Booking confirmed',
    subtitle: 'Rahul Verma confirmed Turf Field 1',
    time: '2 hours ago',
    type: 'Booking',
    unread: false,
  ),
]);

bool _arenaNotificationsEnabled = true;
String _arenaLanguage = 'English';
String _arenaPrivacyLevel = 'Standard';
final Map<String, bool> _arenaNotificationTypePrefs = {
  'Booking': true,
  'Payment': true,
  'Reminder': true,
};

int _unreadArenaNotificationCount(List<_ArenaNotificationItem> items) =>
    items.where((item) => item.unread).length;

class _ArenaNotificationItem {
  const _ArenaNotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
    required this.unread,
  });

  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String type;
  final bool unread;

  _ArenaNotificationItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? time,
    String? type,
    bool? unread,
  }) {
    return _ArenaNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      type: type ?? this.type,
      unread: unread ?? this.unread,
    );
  }
}

class ArenaHomeScreen extends StatelessWidget {
  const ArenaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Arena Manager',
      currentIndex: 0,
      actions: [
        ValueListenableBuilder<List<_ArenaNotificationItem>>(
          valueListenable: _arenaNotificationsNotifier,
          builder: (context, items, _) {
            final unreadCount = _unreadArenaNotificationCount(items);
            return Stack(
              children: [
                IconButton(
                  onPressed: () => context.push(AppRoutes.arenaNotifications),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
                if (unreadCount > 0)
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
                      child: Text(
                        '$unreadCount',
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          },
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
              context.push(AppRoutes.arenaProfileMenu);
            } else if (value == 'settings') {
              context.push(AppRoutes.arenaProfile);
            } else if (value == 'notifications') {
              context.push(AppRoutes.arenaNotifications);
            } else if (value == 'logout') {
              context.push(AppRoutes.arenaLogoutConfirm);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'profile', child: Text('Profile')),
            PopupMenuItem(value: 'settings', child: Text('Settings')),
            PopupMenuItem(value: 'notifications', child: Text('Notifications')),
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
            (court) {
              final amenities = ArenaCourtAmenityStore.amenitiesForCourt(court);
              return Padding(
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
                        children: amenities
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
                      ArenaInfoRow(
                          'Rate', '${arenaMoney(court.baseRate)}/hour'),
                      ArenaInfoRow(
                        'Occupancy today',
                        '${court.occupancyBooked} / ${court.occupancyTotal} slots booked',
                      ),
                    ],
                  ),
                ),
              );
            },
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
    final amenities = ArenaCourtAmenityStore.amenitiesForCourt(court);
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
                          onPressed: () => context.push(
                              '${AppRoutes.arenaAddEditAsset}/${court.id}'),
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
                            ...amenities.map(
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
                            context.push(AppRoutes.arenaMaintenanceTask),
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

class ArenaAddEditAssetScreen extends StatefulWidget {
  const ArenaAddEditAssetScreen({super.key, this.courtId});

  final String? courtId;

  @override
  State<ArenaAddEditAssetScreen> createState() =>
      _ArenaAddEditAssetScreenState();
}

class _ArenaAddEditAssetScreenState extends State<ArenaAddEditAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sizeController = TextEditingController();
  final _othersController = TextEditingController(text: 'Cafe, Seating');
  final _customAmenityController = TextEditingController();
  final Set<String> _amenities = <String>{};
  final List<String> _customAmenities = <String>[];
  late final ArenaCourt? _court;

  @override
  void initState() {
    super.initState();
    _court = widget.courtId == null
        ? null
        : arenaCourts.firstWhere(
            (item) => item.id == widget.courtId,
            orElse: () => arenaCourts.first,
          );
    _nameController.text = _court?.name ?? 'Turf Field 1';
    _priceController.text = '${_court?.baseRate ?? 500}';
    _sizeController.text = _court?.size ?? '';
    final savedAmenities = _court == null
        ? <String>['Lights', 'Parking']
        : ArenaCourtAmenityStore.amenitiesForCourt(_court);
    _amenities
      ..clear()
      ..addAll(savedAmenities);
    _customAmenities
      ..clear()
      ..addAll(
        savedAmenities
            .where((item) => !arenaDefaultAmenities.contains(item))
            .toList(),
      );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _sizeController.dispose();
    _othersController.dispose();
    _customAmenityController.dispose();
    super.dispose();
  }

  List<String> get _amenityOptions => [
        ...arenaDefaultAmenities,
        ..._customAmenities,
      ];

  void _addCustomAmenity() {
    final amenity = _customAmenityController.text.trim();
    if (amenity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amenity name cannot be empty')),
      );
      return;
    }
    final exists = _amenityOptions.any(
      (item) => item.toLowerCase() == amenity.toLowerCase(),
    );
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amenity already exists')),
      );
      return;
    }
    setState(() {
      _customAmenities.add(amenity);
      _amenities.add(amenity);
      _customAmenityController.clear();
    });
  }

  void _removeCustomAmenity(String amenity) {
    setState(() {
      _customAmenities.remove(amenity);
      _amenities.remove(amenity);
    });
  }

  void _saveCourt() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_court != null) {
      ArenaCourtAmenityStore.saveAmenities(
        courtId: _court.id,
        amenities: _amenities.toList(),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Court "${_nameController.text}" saved successfully',
        ),
      ),
    );
    context.go(AppRoutes.arenaAssets);
  }

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Add / Edit Court',
      currentIndex: 1,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: arenaText),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Court name is required'
                        : null,
                    decoration: _arenaInputDecoration('Court Name'),
                  ),
                  const SizedBox(height: 12),
                  const ArenaDropdown(
                    label: 'Court Type',
                    value: 'Cricket',
                    items: ['Cricket', 'Football', 'Badminton'],
                  ),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: arenaText),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Price per slot is required'
                        : null,
                    decoration: _arenaInputDecoration('Price Per Slot'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _sizeController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Court size / Dimension'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Court Description'),
                  ),
                  const SizedBox(height: 14),
                  const Text('Amenities', style: TextStyle(color: arenaMuted)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _amenityOptions
                        .map(
                          (item) => FilterChip(
                            label: Text(item),
                            selected: _amenities.contains(item),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _amenities.add(item);
                                } else {
                                  _amenities.remove(item);
                                }
                              });
                            },
                            backgroundColor: arenaBg,
                            selectedColor: arenaGreen.withValues(alpha: .22),
                            side: const BorderSide(color: arenaBorder),
                            labelStyle: const TextStyle(color: arenaText),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _customAmenityController,
                          style: const TextStyle(color: arenaText),
                          decoration:
                              _arenaInputDecoration('Add custom amenity'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.tonal(
                        onPressed: _addCustomAmenity,
                        child: const Text('+ Add Amenity'),
                      ),
                    ],
                  ),
                  if (_customAmenities.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Custom Amenities',
                      style: TextStyle(color: arenaMuted),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _customAmenities
                          .map(
                            (item) => InputChip(
                              label: Text(item),
                              selected: _amenities.contains(item),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _amenities.add(item);
                                  } else {
                                    _amenities.remove(item);
                                  }
                                });
                              },
                              onDeleted: () => _removeCustomAmenity(item),
                              backgroundColor: arenaBg,
                              selectedColor: arenaGreen.withValues(alpha: .22),
                              side: const BorderSide(color: arenaBorder),
                              labelStyle: const TextStyle(color: arenaText),
                              deleteIconColor: arenaMuted,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _othersController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Others'),
                  ),
                  const SizedBox(height: 12),
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
                    onPressed: () =>
                        context.push(AppRoutes.arenaCourtPhotoSource),
                    icon: const Icon(Icons.upload_rounded),
                    label: const Text('Upload Photo'),
                  ),
                  const SizedBox(height: 14),
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
                          onPressed: _saveCourt,
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
                          onPressed: () => context
                              .push('${AppRoutes.arenaBlockSlot}/${slot.id}'),
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
                      onPressed: () =>
                          context.push('${AppRoutes.arenaSlotForm}/${slot.id}'),
                      child: const Text('Edit Slot'),
                    ),
                    OutlinedButton(
                        onPressed: () => context
                            .push('${AppRoutes.arenaSlotDelete}/${slot.id}'),
                        child: const Text('Delete')),
                    OutlinedButton(
                      onPressed: () => context
                          .push('${AppRoutes.arenaBlockSlot}/${slot.id}'),
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

class ArenaSlotFormScreen extends StatefulWidget {
  const ArenaSlotFormScreen({super.key, this.slotId});

  final String? slotId;

  @override
  State<ArenaSlotFormScreen> createState() => _ArenaSlotFormScreenState();
}

class _ArenaSlotFormScreenState extends State<ArenaSlotFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ArenaSlot? _slot;
  late String _selectedCourtName;
  late final TextEditingController _dateController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late final TextEditingController _durationController;
  late final TextEditingController _priceController;
  late final TextEditingController _reasonController;
  bool _useCourtDefaultPrice = true;
  String _status = 'Available';

  @override
  void initState() {
    super.initState();
    _slot = widget.slotId == null
        ? null
        : arenaSlots.firstWhere(
            (item) => item.id == widget.slotId,
            orElse: () => arenaSlots.first,
          );
    _selectedCourtName = _slot?.courtName ?? arenaCourts.first.name;
    _dateController = TextEditingController(text: _slot?.date ?? '24 Apr 2026');
    _startController =
        TextEditingController(text: _slot?.startTime ?? '7:00 PM');
    _endController = TextEditingController(text: _slot?.endTime ?? '8:00 PM');
    _durationController =
        TextEditingController(text: _slot?.duration ?? '1 hour');
    _priceController = TextEditingController(
        text: '${_slot?.price ?? _selectedCourt.baseRate}');
    _reasonController =
        TextEditingController(text: _slot?.blockReason ?? 'Maintenance');
    _status = slotStatusLabel(_slot?.status ?? SlotStatus.available);
    _useCourtDefaultPrice =
        (_slot?.price ?? _selectedCourt.baseRate) == _selectedCourt.baseRate;
    _syncDefaultPrice();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startController.dispose();
    _endController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  ArenaCourt get _selectedCourt => arenaCourts.firstWhere(
        (court) => court.name == _selectedCourtName,
        orElse: () => arenaCourts.first,
      );

  void _syncDefaultPrice() {
    if (!_useCourtDefaultPrice) return;
    final price = _selectedCourt.baseRate;
    if (price <= 0) {
      _priceController.clear();
      return;
    }
    _priceController.text = '$price';
  }

  int? _validatedPrice() {
    if (_useCourtDefaultPrice) {
      final defaultPrice = _selectedCourt.baseRate;
      if (defaultPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Court default price is missing')),
        );
        return null;
      }
      _priceController.text = '$defaultPrice';
      return defaultPrice;
    }

    final price = int.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid slot price')),
      );
      return null;
    }
    return price;
  }

  void _saveSlot() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final price = _validatedPrice();
    if (price == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.slotId == null
              ? 'Slot created with price Rs $price'
              : 'Slot updated with price Rs $price',
        ),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Create / Edit Slot',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCourtName,
                    dropdownColor: arenaCard,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Court'),
                    items: arenaCourts
                        .map(
                          (court) => DropdownMenuItem(
                            value: court.name,
                            child: Text(court.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedCourtName = value;
                        _syncDefaultPrice();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dateController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Date'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Date is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _startController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Start time'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Start time is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _endController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('End time'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'End time is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _durationController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Duration'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: arenaGreen,
                    value: _useCourtDefaultPrice,
                    onChanged: (value) {
                      setState(() {
                        _useCourtDefaultPrice = value;
                        _syncDefaultPrice();
                      });
                    },
                    title: const Text(
                      'Use Court Default Price',
                      style: TextStyle(color: arenaText),
                    ),
                    subtitle: Text(
                      _useCourtDefaultPrice
                          ? 'Using ${arenaMoney(_selectedCourt.baseRate)} from ${_selectedCourt.name}'
                          : 'Manual slot price enabled',
                      style: const TextStyle(color: arenaMuted),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    enabled: !_useCourtDefaultPrice,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Price for this slot'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Price is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    dropdownColor: arenaCard,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Status'),
                    items: const ['Available', 'Blocked']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _status = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _reasonController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Reason'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: _filledStyle(),
                          onPressed: _saveSlot,
                          child: Text(
                            widget.slotId == null
                                ? 'Create Slot'
                                : 'Save Changes',
                          ),
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
                    onPressed: () => context.push(AppRoutes.arenaBulkSlotForm),
                    icon: const Icon(Icons.grid_view_rounded),
                    label: const Text('Create Multiple Slots'),
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

class ArenaBulkSlotFormScreen extends StatefulWidget {
  const ArenaBulkSlotFormScreen({super.key});

  @override
  State<ArenaBulkSlotFormScreen> createState() =>
      _ArenaBulkSlotFormScreenState();
}

class _ArenaBulkSlotFormScreenState extends State<ArenaBulkSlotFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedCourtName;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;
  late final TextEditingController _durationController;
  late final TextEditingController _priceController;
  bool _useCourtDefaultPrice = true;
  bool _repeatWeekly = false;
  String _status = 'Available';

  @override
  void initState() {
    super.initState();
    _selectedCourtName = arenaCourts.first.name;
    _startDateController = TextEditingController(text: '24 Apr 2026');
    _endDateController = TextEditingController(text: '30 Apr 2026');
    _startTimeController = TextEditingController(text: '6:00 PM');
    _endTimeController = TextEditingController(text: '7:00 PM');
    _durationController = TextEditingController(text: '60');
    _priceController =
        TextEditingController(text: '${_selectedCourt.baseRate}');
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  ArenaCourt get _selectedCourt => arenaCourts.firstWhere(
        (court) => court.name == _selectedCourtName,
        orElse: () => arenaCourts.first,
      );

  void _syncDefaultPrice() {
    if (!_useCourtDefaultPrice) return;
    if (_selectedCourt.baseRate <= 0) {
      _priceController.clear();
      return;
    }
    _priceController.text = '${_selectedCourt.baseRate}';
  }

  DateTime? _parseDate(String value) {
    try {
      return DateFormat('dd MMM yyyy').parseStrict(value);
    } catch (_) {
      return null;
    }
  }

  TimeOfDay? _parseTime(String value) {
    try {
      final parsed = DateFormat('h:mm a').parseStrict(value);
      return TimeOfDay.fromDateTime(parsed);
    } catch (_) {
      return null;
    }
  }

  int? _validatedPrice() {
    if (_useCourtDefaultPrice) {
      final defaultPrice = _selectedCourt.baseRate;
      if (defaultPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Court default price is missing')),
        );
        return null;
      }
      _priceController.text = '$defaultPrice';
      return defaultPrice;
    }

    final price = int.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid slot price')),
      );
      return null;
    }
    return price;
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);

  String _formatTime(DateTime date) => DateFormat('h:mm a').format(date);

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) return '$hours hr $minutes min';
    if (hours > 0) return hours == 1 ? '1 hour' : '$hours hours';
    return '${duration.inMinutes} min';
  }

  bool _overlapsExisting(
    DateTime start,
    DateTime end,
    Iterable<ArenaSlot> slots,
  ) {
    for (final slot in slots) {
      final slotDate = _parseDate(slot.date);
      final slotStartTime = _parseTime(slot.startTime);
      final slotEndTime = _parseTime(slot.endTime);
      if (slotDate == null || slotStartTime == null || slotEndTime == null) {
        continue;
      }
      final slotStart = _combine(slotDate, slotStartTime);
      final slotEnd = _combine(slotDate, slotEndTime);
      if (start.isBefore(slotEnd) && end.isAfter(slotStart)) {
        return true;
      }
    }
    return false;
  }

  void _createMultipleSlots() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final startDate = _parseDate(_startDateController.text.trim());
    final endDate = _parseDate(_endDateController.text.trim());
    final startTime = _parseTime(_startTimeController.text.trim());
    final endTime = _parseTime(_endTimeController.text.trim());
    final durationMinutes = int.tryParse(_durationController.text.trim());
    final price = _validatedPrice();

    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid date range')),
      );
      return;
    }
    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid start and end times')),
      );
      return;
    }
    if (durationMinutes == null || durationMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid slot duration in minutes')),
      );
      return;
    }
    if (price == null) return;
    if (endDate.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    final firstWindowStart = _combine(startDate, startTime);
    final firstWindowEnd = _combine(startDate, endTime);
    if (!firstWindowEnd.isAfter(firstWindowStart)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }
    final requestedWindowMinutes =
        firstWindowEnd.difference(firstWindowStart).inMinutes;
    if (durationMinutes > requestedWindowMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Slot duration cannot exceed the selected time range'),
        ),
      );
      return;
    }

    final courtSlots =
        arenaSlots.where((slot) => slot.courtId == _selectedCourt.id).toList();
    final generated = <ArenaSlot>[];
    final step =
        _repeatWeekly ? const Duration(days: 7) : const Duration(days: 1);
    var dayCursor = startDate;
    var sequence = 0;

    while (!dayCursor.isAfter(endDate)) {
      final windowStart = _combine(dayCursor, startTime);
      final windowEnd = _combine(dayCursor, endTime);
      var slotStart = windowStart;

      while (!slotStart
          .add(Duration(minutes: durationMinutes))
          .isAfter(windowEnd)) {
        final slotEnd = slotStart.add(Duration(minutes: durationMinutes));

        if (_overlapsExisting(
            slotStart, slotEnd, [...courtSlots, ...generated])) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Duplicate or overlapping slot found on ${_formatDate(dayCursor)} at ${_formatTime(slotStart)}',
              ),
            ),
          );
          return;
        }

        generated.add(
          ArenaSlot(
            id: 'generated-${_selectedCourt.id}-${slotStart.millisecondsSinceEpoch}-$sequence',
            courtId: _selectedCourt.id,
            courtName: _selectedCourt.name,
            date: _formatDate(dayCursor),
            startTime: _formatTime(slotStart),
            endTime: _formatTime(slotEnd),
            duration: _formatDuration(slotEnd.difference(slotStart)),
            price: price,
            status: _status == 'Blocked'
                ? SlotStatus.blocked
                : SlotStatus.available,
            blockReason:
                _status == 'Blocked' ? 'Blocked during bulk creation' : null,
          ),
        );

        slotStart = slotEnd;
        sequence += 1;
      }

      dayCursor = dayCursor.add(step);
    }

    if (generated.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No slots generated for the selected range')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${generated.length} slots created for ${_selectedCourt.name}',
        ),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Create Multiple Slots',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCourtName,
                    dropdownColor: arenaCard,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Court'),
                    items: arenaCourts
                        .map(
                          (court) => DropdownMenuItem(
                            value: court.name,
                            child: Text(court.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedCourtName = value;
                        _syncDefaultPrice();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _startDateController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Start date'),
                    validator: (value) =>
                        value == null || _parseDate(value.trim()) == null
                            ? 'Enter date as DD MMM YYYY'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _endDateController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('End date'),
                    validator: (value) =>
                        value == null || _parseDate(value.trim()) == null
                            ? 'Enter date as DD MMM YYYY'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _startTimeController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Start time'),
                    validator: (value) =>
                        value == null || _parseTime(value.trim()) == null
                            ? 'Enter time as H:MM AM/PM'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _endTimeController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('End time'),
                    validator: (value) =>
                        value == null || _parseTime(value.trim()) == null
                            ? 'Enter time as H:MM AM/PM'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: arenaText),
                    decoration:
                        _arenaInputDecoration('Slot duration (minutes)'),
                    validator: (value) {
                      final minutes = int.tryParse((value ?? '').trim());
                      return minutes == null || minutes <= 0
                          ? 'Enter a valid duration'
                          : null;
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: arenaGreen,
                    value: _repeatWeekly,
                    onChanged: (value) => setState(() => _repeatWeekly = value),
                    title: const Text(
                      'Repeat Weekly',
                      style: TextStyle(color: arenaText),
                    ),
                    subtitle: Text(
                      _repeatWeekly
                          ? 'Creates one slot each week in the selected range'
                          : 'Creates one slot each day in the selected range',
                      style: const TextStyle(color: arenaMuted),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: arenaGreen,
                    value: _useCourtDefaultPrice,
                    onChanged: (value) {
                      setState(() {
                        _useCourtDefaultPrice = value;
                        _syncDefaultPrice();
                      });
                    },
                    title: const Text(
                      'Use Court Default Price',
                      style: TextStyle(color: arenaText),
                    ),
                    subtitle: Text(
                      _useCourtDefaultPrice
                          ? 'Using ${arenaMoney(_selectedCourt.baseRate)} from ${_selectedCourt.name}'
                          : 'Manual slot price enabled',
                      style: const TextStyle(color: arenaMuted),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    enabled: !_useCourtDefaultPrice,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Price for each slot'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Price is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    dropdownColor: arenaCard,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Status'),
                    items: const ['Available', 'Blocked']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _status = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: _filledStyle(),
                          onPressed: _createMultipleSlots,
                          child: const Text('Create Slots'),
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
                    OutlinedButton(
                      onPressed: () => context.push(
                        '${AppRoutes.arenaBookingEdit}/${booking.id}',
                      ),
                      child: const Text('Edit'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.push(
                        '${AppRoutes.arenaBookingCancel}/${booking.id}',
                      ),
                      child: const Text('Cancel'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.push(
                        '${AppRoutes.arenaBookingReminder}/${booking.id}',
                      ),
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

class ArenaBookingFormScreen extends StatefulWidget {
  const ArenaBookingFormScreen({super.key});

  @override
  State<ArenaBookingFormScreen> createState() => _ArenaBookingFormScreenState();
}

class _ArenaBookingFormScreenState extends State<ArenaBookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _priceController;
  late final TextEditingController _notesController;
  String _selectedCustomer = arenaBookings.first.customerName;
  late ArenaCourt _selectedCourt;
  late ArenaSlot _selectedSlot;
  bool _manualPriceEnabled = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCourt = arenaCourts.first;
    _selectedSlot = arenaSlots.firstWhere(
      (slot) => slot.courtId == _selectedCourt.id,
      orElse: () => arenaSlots.first,
    );
    _dateController = TextEditingController(text: _selectedSlot.date);
    _timeController = TextEditingController(
      text: '${_selectedSlot.startTime} - ${_selectedSlot.endTime}',
    );
    _priceController = TextEditingController(text: '${_selectedSlot.price}');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _createBooking() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      final price = int.tryParse(_priceController.text.trim());
      if (price == null || price <= 0) {
        throw const FormatException('Invalid booking amount');
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking created successfully')),
      );
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      context.go(AppRoutes.arenaBookings);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  List<ArenaSlot> get _availableSlots {
    final slots = arenaSlots
        .where((slot) => slot.courtId == _selectedCourt.id)
        .toList(growable: false);
    if (slots.isNotEmpty) return slots;
    return [
      ArenaSlot(
        id: 'draft-${_selectedCourt.id}',
        courtId: _selectedCourt.id,
        courtName: _selectedCourt.name,
        date: _dateController.text,
        startTime: '6:00 PM',
        endTime: '7:00 PM',
        duration: '1 hour',
        price: _selectedCourt.baseRate,
        status: SlotStatus.available,
      ),
    ];
  }

  void _syncSlot(ArenaSlot slot) {
    _selectedSlot = slot;
    _dateController.text = slot.date;
    _timeController.text = '${slot.startTime} - ${slot.endTime}';
    if (!_manualPriceEnabled) {
      _priceController.text = '${slot.price}';
    }
  }

  Future<void> _pickBookingDate() async {
    final parsed = DateFormat('dd MMM yyyy').parse(_dateController.text);
    final picked = await showDatePicker(
      context: context,
      initialDate: parsed,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    setState(() {
      _dateController.text = DateFormat('dd MMM yyyy').format(picked);
    });
  }

  Future<void> _pickBookingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked == null) return;
    final endMinutes = picked.hour * 60 + picked.minute + 60;
    final end = TimeOfDay(hour: endMinutes ~/ 60, minute: endMinutes % 60);
    setState(() {
      _timeController.text = '${picked.format(context)} - ${end.format(context)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Create Booking',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCustomer,
                    dropdownColor: arenaCard,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('User / Customer'),
                    items: arenaBookings
                        .map(
                          (booking) => DropdownMenuItem(
                            value: booking.customerName,
                            child: Text(booking.customerName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCustomer = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCourt.id,
                    dropdownColor: arenaCard,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Court'),
                    items: arenaCourts
                        .map(
                          (court) => DropdownMenuItem(
                            value: court.id,
                            child: Text(court.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedCourt = arenaCourts.firstWhere(
                          (court) => court.id == value,
                        );
                        _syncSlot(_availableSlots.first);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSlot.id,
                    dropdownColor: arenaCard,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Court / Slot'),
                    items: _availableSlots
                        .map(
                          (slot) => DropdownMenuItem(
                            value: slot.id,
                            child: Text(
                              '${slot.date} - ${slot.startTime} - ${slot.endTime}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _syncSlot(
                          _availableSlots.firstWhere((slot) => slot.id == value),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _pickBookingDate,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Date'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Date is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _timeController,
                    readOnly: true,
                    onTap: _pickBookingTime,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Date & Time'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Time is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _manualPriceEnabled,
                    contentPadding: EdgeInsets.zero,
                    activeColor: arenaGreen,
                    title: const Text(
                      'Allow manual price edit',
                      style: TextStyle(color: arenaText),
                    ),
                    subtitle: const Text(
                      'Use the selected slot price by default.',
                      style: TextStyle(color: arenaMuted),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _manualPriceEnabled = value;
                        if (!value) {
                          _priceController.text = '${_selectedSlot.price}';
                        }
                      });
                    },
                  ),
                  TextFormField(
                    controller: _priceController,
                    enabled: _manualPriceEnabled,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Price'),
                    validator: (value) {
                      final amount = int.tryParse(value?.trim() ?? '');
                      if (amount == null || amount <= 0) {
                        return 'Enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Notes (optional)'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: _filledStyle(),
                          onPressed: _isSaving ? null : _createBooking,
                          child:
                              Text(_isSaving ? 'Saving...' : 'Save Booking'),
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
              onPressed: () => context.push(AppRoutes.arenaPricingEdit),
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
            onPressed: () => context.push(AppRoutes.arenaExportReport),
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
                                          onPressed: () => context.push(
                                            '${AppRoutes.arenaPaymentActions}?bookingId=${booking.id}&tab=reminder',
                                          ),
                                          child: const Text('Send Reminder'),
                                        ),
                                        OutlinedButton(
                                          onPressed: () => context.push(
                                            '${AppRoutes.arenaPaymentActions}?bookingId=${booking.id}&tab=payment',
                                          ),
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
                    children: [
                      ArenaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Analytics',
                              style: TextStyle(
                                color: arenaText,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Open the analytics dashboard for monthly earnings and payment status charts.',
                              style: TextStyle(color: arenaMuted),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              style: _filledStyle(),
                              onPressed: () =>
                                  context.push(AppRoutes.arenaAnalytics),
                              child: const Text('Open Analytics Dashboard'),
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
                onTap: () => context.push(
                  '${AppRoutes.arenaReviewDetail}/${review.customerName.toLowerCase().replaceAll(' ', '-')}',
                ),
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
                    Text(
                      review.replyDate != null
                          ? 'You replied on ${review.replyDate}'
                          : 'Open review details to reply, mark helpful, or report.',
                      style: const TextStyle(color: arenaMuted),
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

class ArenaProfileScreen extends ConsumerStatefulWidget {
  const ArenaProfileScreen({super.key});

  @override
  ConsumerState<ArenaProfileScreen> createState() => _ArenaProfileScreenState();
}

class _ArenaProfileScreenState extends ConsumerState<ArenaProfileScreen> {
  late bool _notificationsEnabled;
  late String _language;
  late String _privacyLevel;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = _arenaNotificationsEnabled;
    _language = _arenaLanguage;
    _privacyLevel = _arenaPrivacyLevel;
  }

  void _saveSettings() {
    _arenaNotificationsEnabled = _notificationsEnabled;
    _arenaLanguage = _language;
    _arenaPrivacyLevel = _privacyLevel;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style:
                      TextStyle(color: arenaText, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: arenaGreen,
                  value: _notificationsEnabled,
                  title: const Text(
                    'Notification toggle',
                    style: TextStyle(color: arenaText),
                  ),
                  subtitle: const Text(
                    'Enable booking, payment, and review alerts',
                    style: TextStyle(color: arenaMuted),
                  ),
                  onChanged: (value) =>
                      setState(() => _notificationsEnabled = value),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _language,
                  dropdownColor: arenaCard,
                  style: const TextStyle(color: arenaText),
                  decoration: _arenaInputDecoration('Language'),
                  items: const ['English', 'Hindi', 'Gujarati']
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _language = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _privacyLevel,
                  dropdownColor: arenaCard,
                  style: const TextStyle(color: arenaText),
                  decoration: _arenaInputDecoration('Privacy options'),
                  items: const ['Standard', 'Restricted', 'Private']
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _privacyLevel = value);
                    }
                  },
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
                    onPressed: _saveSettings,
                    child: const Text('Save Settings'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: _filledStyle(),
                    onPressed: () => context.push(AppRoutes.arenaLogoutConfirm),
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

class ArenaEditPricingScreen extends StatefulWidget {
  const ArenaEditPricingScreen({super.key});

  @override
  State<ArenaEditPricingScreen> createState() => _ArenaEditPricingScreenState();
}

class _ArenaEditPricingScreenState extends State<ArenaEditPricingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _hourlyController;
  late final TextEditingController _weekdayController;
  late final TextEditingController _weekendController;
  late final TextEditingController _peakController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _hourlyController =
        TextEditingController(text: '${arenaCourts.first.baseRate}');
    _weekdayController =
        TextEditingController(text: '${arenaCourts.first.offPeakRate}');
    _weekendController =
        TextEditingController(text: '${arenaCourts.first.baseRate}');
    _peakController =
        TextEditingController(text: '${arenaCourts.first.peakRate}');
  }

  @override
  void dispose() {
    _hourlyController.dispose();
    _weekdayController.dispose();
    _weekendController.dispose();
    _peakController.dispose();
    super.dispose();
  }

  Future<void> _savePricing() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pricing updated successfully')),
    );
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Edit Pricing',
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _hourlyController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Hourly price'),
                    validator: _requiredAmount,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _weekdayController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Weekday price'),
                    validator: _requiredAmount,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _weekendController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Weekend price'),
                    validator: _requiredAmount,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _peakController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Peak time price'),
                    validator: _requiredAmount,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: _filledStyle(),
                          onPressed: _isSaving ? null : _savePricing,
                          child: Text(_isSaving ? 'Saving...' : 'Save'),
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
          ),
        ],
      ),
    );
  }
}

class ArenaExportReportScreen extends StatefulWidget {
  const ArenaExportReportScreen({super.key});

  @override
  State<ArenaExportReportScreen> createState() => _ArenaExportReportScreenState();
}

class _ArenaExportReportScreenState extends State<ArenaExportReportScreen> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime(2026, 4, 1),
    end: DateTime(2026, 4, 24),
  );
  String _reportType = 'Revenue Report';
  bool _isExporting = false;

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDateRange: _range,
    );
    if (picked != null) {
      setState(() => _range = picked);
    }
  }

  Future<void> _export() async {
    setState(() => _isExporting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isExporting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report downloaded successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy');
    return ArenaScaffold(
      title: 'Export Report',
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Date range',
                    style: TextStyle(color: arenaText),
                  ),
                  subtitle: Text(
                    '${formatter.format(_range.start)} - ${formatter.format(_range.end)}',
                    style: const TextStyle(color: arenaMuted),
                  ),
                  trailing: const Icon(Icons.date_range_rounded,
                      color: arenaLightGreen),
                  onTap: _pickRange,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _reportType,
                  dropdownColor: arenaCard,
                  style: const TextStyle(color: arenaText),
                  decoration: _arenaInputDecoration('Report type'),
                  items: const [
                    'Revenue Report',
                    'Settlement Report',
                    'Pending Payment Report'
                  ]
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _reportType = value);
                  },
                ),
                const SizedBox(height: 16),
                if (_isExporting) ...[
                  const LinearProgressIndicator(
                    backgroundColor: arenaBorder,
                    valueColor: AlwaysStoppedAnimation(arenaGreen),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: _filledStyle(),
                    onPressed: _isExporting ? null : _export,
                    child: Text(_isExporting ? 'Exporting...' : 'Export PDF'),
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

class ArenaPaymentActionScreen extends StatefulWidget {
  const ArenaPaymentActionScreen({
    super.key,
    this.bookingId,
    this.initialTab,
  });

  final String? bookingId;
  final String? initialTab;

  @override
  State<ArenaPaymentActionScreen> createState() => _ArenaPaymentActionScreenState();
}

class _ArenaPaymentActionScreenState extends State<ArenaPaymentActionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _amountController;
  late final TextEditingController _dueDateController;
  late final TextEditingController _paymentDateController;
  String _selectedUser = arenaBookings.first.customerName;
  String _paymentMode = 'Cash';

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTab == 'payment' ? 1 : 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    final booking = widget.bookingId == null
        ? arenaBookings.first
        : arenaBookings.firstWhere(
            (item) => item.id == widget.bookingId,
            orElse: () => arenaBookings.first,
          );
    _selectedUser = booking.customerName;
    _amountController = TextEditingController(text: '${booking.amount}');
    _dueDateController = TextEditingController(text: booking.date);
    _paymentDateController = TextEditingController(text: booking.date);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
    _paymentDateController.dispose();
    super.dispose();
  }

  void _showActionMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Payment Action',
      currentIndex: 3,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: arenaLightGreen,
            unselectedLabelColor: arenaMuted,
            indicatorColor: arenaGreen,
            tabs: const [
              Tab(text: 'Send Reminder'),
              Tab(text: 'Record Payment'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ArenaCard(
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _selectedUser,
                            dropdownColor: arenaCard,
                            style: const TextStyle(color: arenaText),
                            decoration: _arenaInputDecoration('Select user'),
                            items: arenaBookings
                                .map(
                                  (booking) => DropdownMenuItem(
                                    value: booking.customerName,
                                    child: Text(booking.customerName),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedUser = value);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: arenaText),
                            decoration: _arenaInputDecoration('Amount'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dueDateController,
                            style: const TextStyle(color: arenaText),
                            decoration: _arenaInputDecoration('Due date'),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: _filledStyle(),
                              onPressed: () =>
                                  _showActionMessage('Reminder sent successfully'),
                              child: const Text('Send Reminder'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ArenaCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: arenaText),
                            decoration: _arenaInputDecoration('Amount'),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _paymentMode,
                            dropdownColor: arenaCard,
                            style: const TextStyle(color: arenaText),
                            decoration: _arenaInputDecoration('Mode'),
                            items: const ['Cash', 'UPI', 'Card']
                                .map(
                                  (mode) => DropdownMenuItem(
                                    value: mode,
                                    child: Text(mode),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _paymentMode = value);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _paymentDateController,
                            style: const TextStyle(color: arenaText),
                            decoration: _arenaInputDecoration('Date'),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: _filledStyle(),
                              onPressed: () => _showActionMessage(
                                'Payment recorded successfully',
                              ),
                              child: const Text('Save Payment'),
                            ),
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
    );
  }
}

class ArenaAnalyticsDashboardScreen extends StatelessWidget {
  const ArenaAnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final monthlyBars = <MapEntry<String, int>>[
      const MapEntry('Jan', 38000),
      const MapEntry('Feb', 42000),
      const MapEntry('Mar', 56000),
      MapEntry('Apr', arenaPayments.monthly),
    ];
    final paymentBreakdown = {
      'Paid': arenaBookings
          .where((booking) => booking.paymentStatus == PaymentStatus.paid)
          .length,
      'Pending': arenaBookings
          .where((booking) => booking.paymentStatus == PaymentStatus.pending)
          .length,
      'Partial': arenaBookings
          .where((booking) => booking.paymentStatus == PaymentStatus.partial)
          .length,
    };
    return ArenaScaffold(
      title: 'Analytics Dashboard',
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: const [
              Expanded(child: _MetricCard('Rs 1,85,000', 'Total earnings')),
              SizedBox(width: 10),
              Expanded(child: _MetricCard('Rs 52,000', 'Monthly earnings')),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: _MetricCard('3', 'Paid bookings')),
              SizedBox(width: 10),
              Expanded(child: _MetricCard('1', 'Pending / partial')),
            ],
          ),
          const ArenaSectionTitle('Monthly Earnings'),
          ArenaCard(child: _ArenaBarChart(data: monthlyBars)),
          const ArenaSectionTitle('Payment Status'),
          ArenaCard(child: _ArenaPieChart(data: paymentBreakdown)),
        ],
      ),
    );
  }
}

class ArenaReviewDetailScreen extends StatefulWidget {
  const ArenaReviewDetailScreen({super.key, required this.reviewId});

  final String reviewId;

  @override
  State<ArenaReviewDetailScreen> createState() => _ArenaReviewDetailScreenState();
}

class _ArenaReviewDetailScreenState extends State<ArenaReviewDetailScreen> {
  late final ArenaReview _review;
  late final TextEditingController _replyController;
  bool _helpful = false;
  String _reportReason = 'Spam';

  @override
  void initState() {
    super.initState();
    _review = arenaReviews.firstWhere(
      (item) => item.customerName.toLowerCase().replaceAll(' ', '-') == widget.reviewId,
      orElse: () => arenaReviews.first,
    );
    _replyController = TextEditingController();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Review Detail',
      currentIndex: 4,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _review.customerName,
                  style: const TextStyle(
                    color: arenaText,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_review.date} - ${_review.rating} / 5',
                  style: const TextStyle(color: arenaMuted),
                ),
                const SizedBox(height: 12),
                Text(_review.review, style: const TextStyle(color: arenaText)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _replyController,
                  maxLines: 3,
                  style: const TextStyle(color: arenaText),
                  decoration: _arenaInputDecoration('Reply to review'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: _filledStyle(),
                        onPressed: () => _showMessage('Reply sent successfully'),
                        child: const Text('Reply'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _helpful = !_helpful);
                          _showMessage(
                            _helpful
                                ? 'Review marked as helpful'
                                : 'Helpful flag removed',
                          );
                        },
                        child: Text(_helpful ? 'Helpful' : 'Mark Helpful'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _reportReason,
                  dropdownColor: arenaCard,
                  style: const TextStyle(color: arenaText),
                  decoration: _arenaInputDecoration('Report reason'),
                  items: const ['Spam', 'Abuse', 'Irrelevant']
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _reportReason = value);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showMessage('Review reported successfully'),
                    child: const Text('Report Review'),
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

class ArenaProfileMenuScreen extends StatelessWidget {
  const ArenaProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Profile Menu',
      currentIndex: 4,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuTile(
            title: 'Profile',
            icon: Icons.person_outline_rounded,
            onTap: () => context.push(AppRoutes.arenaAccount),
          ),
          _MenuTile(
            title: 'Settings',
            icon: Icons.settings_outlined,
            onTap: () => context.push(AppRoutes.arenaProfile),
          ),
          _MenuTile(
            title: 'Notifications',
            icon: Icons.notifications_none_rounded,
            onTap: () => context.push(AppRoutes.arenaNotifications),
          ),
          _MenuTile(
            title: 'Logout',
            icon: Icons.logout_rounded,
            onTap: () => context.push(AppRoutes.arenaLogoutConfirm),
          ),
        ],
      ),
    );
  }
}

class ArenaAccountScreen extends StatelessWidget {
  const ArenaAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Profile',
      currentIndex: 4,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arenaName,
                  style: TextStyle(
                    color: arenaText,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 12),
                ArenaInfoRow('Role', 'Arena'),
                ArenaInfoRow('Email', 'ops@greenfieldarena.in'),
                ArenaInfoRow('Phone', '+91 98765 90909'),
                ArenaInfoRow('City', 'Ahmedabad'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArenaNotificationsScreen extends StatefulWidget {
  const ArenaNotificationsScreen({super.key});

  @override
  State<ArenaNotificationsScreen> createState() => _ArenaNotificationsScreenState();
}

class _ArenaNotificationsScreenState extends State<ArenaNotificationsScreen> {
  void _markAsRead(_ArenaNotificationItem item) {
    final updated = _arenaNotificationsNotifier.value
        .map((entry) => entry.id == item.id ? entry.copyWith(unread: false) : entry)
        .toList(growable: false);
    _arenaNotificationsNotifier.value = updated;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: ArenaScaffold(
        title: 'Notifications',
        currentIndex: 0,
        actions: [
          TextButton(
            onPressed: () => context.push(AppRoutes.arenaNotificationPrefs),
            child: const Text('Preferences'),
          ),
        ],
        child: ValueListenableBuilder<List<_ArenaNotificationItem>>(
          valueListenable: _arenaNotificationsNotifier,
          builder: (context, items, _) {
            final unread = items.where((item) => item.unread).toList(growable: false);
            final sessionReminders = items
                .where((item) => item.type == 'Reminder')
                .toList(growable: false);
            return Column(
              children: [
                const TabBar(
                  labelColor: arenaLightGreen,
                  unselectedLabelColor: arenaMuted,
                  indicatorColor: arenaGreen,
                  tabs: [
                    Tab(text: 'Unread'),
                    Tab(text: 'All'),
                    Tab(text: 'Session Reminder'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ArenaNotificationList(
                        items: unread,
                        onTap: _markAsRead,
                      ),
                      _ArenaNotificationList(
                        items: items,
                        onTap: _markAsRead,
                      ),
                      _ArenaNotificationList(
                        items: sessionReminders,
                        onTap: _markAsRead,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ArenaNotificationPreferencesScreen extends StatefulWidget {
  const ArenaNotificationPreferencesScreen({super.key});

  @override
  State<ArenaNotificationPreferencesScreen> createState() =>
      _ArenaNotificationPreferencesScreenState();
}

class _ArenaNotificationPreferencesScreenState
    extends State<ArenaNotificationPreferencesScreen> {
  late Map<String, bool> _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = Map<String, bool>.from(_arenaNotificationTypePrefs);
  }

  void _savePrefs() {
    _arenaNotificationTypePrefs
      ..clear()
      ..addAll(_preferences);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification preferences saved')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Notification Preferences',
      currentIndex: 0,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              children: [
                for (final entry in _preferences.entries)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: arenaGreen,
                    value: entry.value,
                    title: Text(
                      entry.key,
                      style: const TextStyle(color: arenaText),
                    ),
                    onChanged: (value) {
                      setState(() => _preferences[entry.key] = value);
                    },
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: _filledStyle(),
                    onPressed: _savePrefs,
                    child: const Text('Save Preferences'),
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

class ArenaLogoutConfirmScreen extends ConsumerWidget {
  const ArenaLogoutConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ArenaScaffold(
      title: 'Logout',
      currentIndex: 4,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ArenaCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: arenaText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: _filledStyle(),
                        onPressed: () =>
                            ref.read(sessionControllerProvider.notifier).signOut(),
                        child: const Text('Logout'),
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
        ),
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
  const ArenaBlockSlotScreen({super.key, this.slotId});

  final String? slotId;

  @override
  Widget build(BuildContext context) {
    final slot = slotId == null
        ? null
        : arenaSlots.firstWhere(
            (item) => item.id == slotId,
            orElse: () => arenaSlots.first,
          );
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
                ArenaTextField(
                    label: 'Date Range',
                    initialValue: slot?.date ?? '23 Apr - 24 Apr'),
                ArenaTextField(
                    label: 'Time Range',
                    initialValue: slot == null
                        ? '2:00 PM - 5:00 PM'
                        : '${slot.startTime} - ${slot.endTime}'),
                const ArenaDropdown(
                  label: 'Reason',
                  value: 'Maintenance',
                  items: ['Maintenance', 'Private', 'Other'],
                ),
                FilledButton(
                  style: _filledStyle(),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Slot updated successfully')),
                    );
                    context.pop();
                  },
                  child: Text(slot == null ? 'Block Slot' : 'Save Block'),
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
                    _MaintenanceTaskData('daily-1', 'Net inspection', 'Daily',
                        'Inspect nets for tears', '24 Apr 2026'),
                    _MaintenanceTaskData('daily-2', 'Lighting check', 'Daily',
                        'Verify lights before evening slots', '24 Apr 2026'),
                    _MaintenanceTaskData('daily-3', 'Turf brushing', 'Daily',
                        'Brush turf and clear debris', '24 Apr 2026'),
                  ]),
                  _MaintenanceList(tasks: const [
                    _MaintenanceTaskData('weekly-1', 'Deep turf wash', 'Weekly',
                        'Wash and sanitize turf', '26 Apr 2026'),
                    _MaintenanceTaskData('weekly-2', 'Boundary repair',
                        'Weekly', 'Repair outer mesh and posts', '26 Apr 2026'),
                    _MaintenanceTaskData(
                        'weekly-3',
                        'Equipment audit',
                        'Weekly',
                        'Audit cones, bibs, and balls',
                        '26 Apr 2026'),
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

  final List<_MaintenanceTaskData> tasks;

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
                    task.name,
                    style: const TextStyle(
                      color: arenaText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Frequency: ${task.frequency}',
                      style: const TextStyle(color: arenaMuted)),
                  Text('Description: ${task.description}',
                      style: const TextStyle(color: arenaMuted)),
                  Text('Assigned Date: ${task.assignedDate}',
                      style: const TextStyle(color: arenaMuted)),
                  const Text('Status: Pending',
                      style: TextStyle(color: arenaMuted)),
                  const SizedBox(height: 10),
                  FilledButton(
                    style: _filledStyle(),
                    onPressed: () => context.push(
                      '${AppRoutes.arenaMaintenanceComplete}/${task.id}',
                    ),
                    child: const Text('Mark as Completed'),
                  ),
                ],
              ),
            ),
          ),
        ),
        FilledButton.icon(
          style: _filledStyle(),
          onPressed: () => context.push(AppRoutes.arenaMaintenanceTask),
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('Add Maintenance Task'),
        ),
      ],
    );
  }
}

class _MaintenanceTaskData {
  const _MaintenanceTaskData(
    this.id,
    this.name,
    this.frequency,
    this.description,
    this.assignedDate,
  );

  final String id;
  final String name;
  final String frequency;
  final String description;
  final String assignedDate;
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ArenaCard(
        onTap: onTap,
        child: Row(
          children: [
            ArenaGlowIcon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: arenaText,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: arenaMuted),
          ],
        ),
      ),
    );
  }
}

class _ArenaNotificationList extends StatelessWidget {
  const _ArenaNotificationList({
    required this.items,
    required this.onTap,
  });

  final List<_ArenaNotificationItem> items;
  final ValueChanged<_ArenaNotificationItem> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No notifications available',
            style: TextStyle(color: arenaMuted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ArenaCard(
            onTap: () => onTap(item),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ArenaGlowIcon(
                  item.type == 'Booking'
                      ? Icons.book_online_rounded
                      : item.type == 'Payment'
                          ? Icons.payments_outlined
                          : Icons.alarm_rounded,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: arenaText,
                          fontWeight:
                              item.unread ? FontWeight.w900 : FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(item.subtitle,
                          style: const TextStyle(color: arenaMuted)),
                      const SizedBox(height: 4),
                      Text(item.time, style: const TextStyle(color: arenaMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

class _ArenaBarChart extends StatelessWidget {
  const _ArenaBarChart({required this.data});

  final List<MapEntry<String, int>> data;

  @override
  Widget build(BuildContext context) {
    final maxValue = data.map((entry) => entry.value).fold<int>(0, math.max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bar chart',
          style: TextStyle(color: arenaText, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data
                .map(
                  (entry) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            arenaMoney(entry.value),
                            style: const TextStyle(
                              color: arenaMuted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: maxValue == 0
                                ? 0
                                : 110 * (entry.value / maxValue),
                            decoration: BoxDecoration(
                              color: arenaGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.key,
                            style: const TextStyle(color: arenaText),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _ArenaPieChart extends StatelessWidget {
  const _ArenaPieChart({required this.data});

  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<int>(0, (sum, value) => sum + value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pie chart',
          style: TextStyle(color: arenaText, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: Row(
            children: [
              Expanded(
                child: CustomPaint(
                  painter: _ArenaPiePainter(data: data),
                  child: Center(
                    child: Text(
                      '$total\nbookings',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: arenaText),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.entries.map((entry) {
                    final color = _pieColors[data.keys.toList().indexOf(entry.key) %
                        _pieColors.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${entry.key} (${entry.value})',
                              style: const TextStyle(color: arenaText),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

const _pieColors = [
  arenaGreen,
  Color(0xFFF59E0B),
  Color(0xFF60A5FA),
];

class _ArenaPiePainter extends CustomPainter {
  const _ArenaPiePainter({required this.data});

  final Map<String, int> data;

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) return;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: math.min(size.width, size.height) / 2.4,
    );
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 24;
    double startAngle = -math.pi / 2;
    final entries = data.entries.toList(growable: false);
    for (var i = 0; i < entries.length; i++) {
      final sweep = (entries[i].value / total) * math.pi * 2;
      paint.color = _pieColors[i % _pieColors.length];
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _ArenaPiePainter oldDelegate) =>
      oldDelegate.data != data;
}

class ArenaCourtPhotoSourceScreen extends StatelessWidget {
  const ArenaCourtPhotoSourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Upload Photos',
      currentIndex: 1,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Camera opened')),
                    );
                    context.pop();
                  },
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Open Camera'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gallery opened')),
                    );
                    context.pop();
                  },
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Pick from Gallery'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArenaDeleteSlotScreen extends StatelessWidget {
  const ArenaDeleteSlotScreen({super.key, required this.slotId});

  final String slotId;

  @override
  Widget build(BuildContext context) {
    final slot = arenaSlots.firstWhere(
      (item) => item.id == slotId,
      orElse: () => arenaSlots.first,
    );
    return ArenaScaffold(
      title: 'Delete Slot',
      currentIndex: 2,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ArenaCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Delete ${slot.courtName} ${slot.startTime} - ${slot.endTime}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: arenaText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: _filledStyle(),
                        onPressed: () => context.go(AppRoutes.arenaSlots),
                        child: const Text('Delete Slot'),
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
        ),
      ),
    );
  }
}

class ArenaEditBookingScreen extends StatefulWidget {
  const ArenaEditBookingScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<ArenaEditBookingScreen> createState() => _ArenaEditBookingScreenState();
}

class _ArenaEditBookingScreenState extends State<ArenaEditBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ArenaBooking _booking;
  late final TextEditingController _customerController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _amountController;
  late final TextEditingController _specialRequestsController;

  @override
  void initState() {
    super.initState();
    _booking = arenaBookings.firstWhere(
      (item) => item.id == widget.bookingId,
      orElse: () => arenaBookings.first,
    );
    _customerController = TextEditingController(text: _booking.customerName);
    _phoneController = TextEditingController(text: _booking.phone);
    _emailController = TextEditingController(text: _booking.email);
    _dateController = TextEditingController(text: _booking.date);
    _timeController = TextEditingController(text: _booking.timeSlot);
    _amountController = TextEditingController(text: '${_booking.amount}');
    _specialRequestsController =
        TextEditingController(text: _booking.specialRequest);
  }

  @override
  void dispose() {
    _customerController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _amountController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _updateBooking() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      final amount = int.tryParse(_amountController.text.trim());
      if (amount == null || amount <= 0) {
        throw const FormatException('Invalid booking amount');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking updated successfully')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Edit Booking',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _customerController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Customer name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Customer name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Phone'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Phone is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Email'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dateController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Date'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Date is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _timeController,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Time'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Time is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Amount'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Amount is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _specialRequestsController,
                    maxLines: 3,
                    style: const TextStyle(color: arenaText),
                    decoration: _arenaInputDecoration('Special Requests'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    style: _filledStyle(),
                    onPressed: _updateBooking,
                    child: const Text('Save Booking'),
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

class ArenaCancelBookingScreen extends StatefulWidget {
  const ArenaCancelBookingScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<ArenaCancelBookingScreen> createState() =>
      _ArenaCancelBookingScreenState();
}

class _ArenaCancelBookingScreenState extends State<ArenaCancelBookingScreen> {
  late final ArenaBooking _booking;
  late BookingStatus _status;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _booking = arenaBookings.firstWhere(
      (item) => item.id == widget.bookingId,
      orElse: () => arenaBookings.first,
    );
    _status = _booking.status;
  }

  Future<void> _cancelBooking() async {
    if (_isSubmitting || _status == BookingStatus.cancelled) return;
    setState(() => _isSubmitting = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() {
        _status = BookingStatus.cancelled;
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled successfully')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to cancel booking. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Cancel Booking',
      currentIndex: 2,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ArenaCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cancel booking for ${_booking.customerName}?',
                  style: const TextStyle(
                    color: arenaText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                ArenaStatusBadge(
                  label: bookingStatusLabel(_status),
                  positive: _status == BookingStatus.confirmed ||
                      _status == BookingStatus.completed,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: _filledStyle(),
                        onPressed: _cancelBooking,
                        child: Text(
                          _isSubmitting
                              ? 'Cancelling...'
                              : _status == BookingStatus.cancelled
                                  ? 'Booking Cancelled'
                                  : 'Cancel Booking',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Keep Booking'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ArenaResendReminderScreen extends StatelessWidget {
  const ArenaResendReminderScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final booking = arenaBookings.firstWhere(
      (item) => item.id == bookingId,
      orElse: () => arenaBookings.first,
    );
    return ArenaScaffold(
      title: 'Resend Reminder',
      currentIndex: 2,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminder for ${booking.customerName}',
                  style: const TextStyle(
                    color: arenaText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A reminder notification will be sent with date, time, and court details.',
                  style: TextStyle(color: arenaMuted),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: _filledStyle(),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Reminder sent successfully')),
                    );
                    context.go('${AppRoutes.arenaBookings}/$bookingId');
                  },
                  child: const Text('Send Reminder'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArenaMaintenanceTaskScreen extends StatelessWidget {
  const ArenaMaintenanceTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Add Maintenance Task',
      currentIndex: 1,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ArenaCard(
            child: Column(
              children: [
                const ArenaTextField(label: 'Task Name'),
                const ArenaDropdown(
                  label: 'Frequency',
                  value: 'Daily',
                  items: ['Daily', 'Weekly'],
                ),
                const ArenaTextField(label: 'Description'),
                const ArenaTextField(
                    label: 'Assigned Date', initialValue: '24 Apr 2026'),
                const SizedBox(height: 12),
                FilledButton(
                  style: _filledStyle(),
                  onPressed: () => context.go(AppRoutes.arenaMaintenance),
                  child: const Text('Save Task'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArenaMaintenanceCompleteScreen extends StatelessWidget {
  const ArenaMaintenanceCompleteScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    return ArenaScaffold(
      title: 'Complete Task',
      currentIndex: 1,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ArenaCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mark maintenance task "$taskId" as completed?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: arenaText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: _filledStyle(),
                        onPressed: () => context.go(AppRoutes.arenaMaintenance),
                        child: const Text('Mark Completed'),
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
        ),
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

String? _requiredAmount(String? value) {
  final amount = int.tryParse(value?.trim() ?? '');
  if (amount == null || amount <= 0) {
    return 'Enter a valid amount';
  }
  return null;
}

InputDecoration _arenaInputDecoration(String label) {
  return InputDecoration(
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
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFEF4444)),
    ),
  );
}

Color _slotColor(SlotStatus status) {
  return switch (status) {
    SlotStatus.available => arenaGreen,
    SlotStatus.booked => const Color(0xFFEF4444),
    SlotStatus.blocked => const Color(0xFF6B7280),
  };
}
