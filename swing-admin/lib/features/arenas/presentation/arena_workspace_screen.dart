import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

// ignore_for_file: use_build_context_synchronously, deprecated_member_use, unnecessary_underscores, use_null_aware_elements

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/admin_detail_widgets.dart';
import '../data/arenas_repository.dart';
import '../domain/arena_workspace_models.dart';

class ArenaWorkspaceScreen extends ConsumerStatefulWidget {
  const ArenaWorkspaceScreen({super.key, required this.arenaId});
  final String arenaId;

  @override
  ConsumerState<ArenaWorkspaceScreen> createState() =>
      _ArenaWorkspaceScreenState();
}

class _ArenaWorkspaceScreenState extends ConsumerState<ArenaWorkspaceScreen> {
  final ImagePicker _picker = ImagePicker();
  DateTime _availabilityDate = DateTime.now();
  DateTime _blocksDate = DateTime.now();
  DateTime _bookingsDate = DateTime.now();
  String? _availabilityUnitId;
  String? _blocksUnitId;
  bool _recurringBlocksOnly = false;

  static const _sportOptions = <String>[
    'CRICKET',
    'FUTSAL',
    'PICKLEBALL',
    'BADMINTON',
    'FOOTBALL',
    'OTHER',
  ];

  static const _weekdays = <int, String>{
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(arenaDetailProvider(widget.arenaId));
    final compact = MediaQuery.sizeOf(context).width < 760;

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: compact
            ? null
            : AppBar(
                leading: IconButton(
                  onPressed: () => context.go('/arenas'),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  tooltip: 'Back to arenas',
                ),
                title: const Text('Arena workspace'),
                actions: [
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: _refreshArena,
                    icon: const Icon(Icons.refresh, size: 18),
                  ),
                  const SizedBox(width: 8),
                ],
                bottom: const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: 'Overview'),
                    Tab(text: 'Photos'),
                    Tab(text: 'Units'),
                    Tab(text: 'Blocks'),
                    Tab(text: 'Availability'),
                    Tab(text: 'Bookings'),
                    Tab(text: 'Admin'),
                  ],
                ),
              ),
        body: detailAsync.when(
          data: (arena) {
            if (_availabilityUnitId == null && arena.units.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || _availabilityUnitId != null) return;
                setState(() => _availabilityUnitId = arena.units.first.id);
              });
            }
            if (_blocksUnitId == null && arena.units.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || _blocksUnitId != null) return;
                setState(() => _blocksUnitId = arena.units.first.id);
              });
            }

            final bookingsAsync = ref.watch(
              arenaBookingsProvider((
                arenaId: widget.arenaId,
                date: _apiDate(_bookingsDate),
              )),
            );
            final blocksAsync = ref.watch(
              arenaBlocksProvider((
                arenaId: widget.arenaId,
                date: _apiDate(_blocksDate),
                unitId: _blocksUnitId,
                recurringOnly: _recurringBlocksOnly,
              )),
            );
            final availabilityAsync = ref.watch(
              arenaAvailabilityProvider((
                arenaId: widget.arenaId,
                date: _apiDate(_availabilityDate),
                unitId: _availabilityUnitId,
              )),
            );
            final statsAsync = ref.watch(arenaStatsProvider(widget.arenaId));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (compact)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.go('/arenas'),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                          ),
                          tooltip: 'Back to arenas',
                        ),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Text(
                            'Arena workspace',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh',
                          onPressed: _refreshArena,
                          icon: const Icon(
                            Icons.refresh,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Hard delete arena',
                          onPressed: () => _confirmDelete(arena),
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (compact)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: const TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        Tab(text: 'Overview'),
                        Tab(text: 'Photos'),
                        Tab(text: 'Units'),
                        Tab(text: 'Blocks'),
                        Tab(text: 'Availability'),
                        Tab(text: 'Bookings'),
                        Tab(text: 'Admin'),
                      ],
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _OverviewTab(
                        arena: arena,
                        statsAsync: statsAsync,
                        onEdit: () => _openCoreEditor(arena),
                        onRefreshStats: () =>
                            ref.invalidate(arenaStatsProvider(widget.arenaId)),
                      ),
                      _PhotosTab(
                        photos: arena.photoUrls,
                        onEdit: () => _openPhotosEditor(arena),
                      ),
                      _UnitsTab(
                        units: arena.units,
                        onAdd: () => _openUnitDialog(),
                        onEdit: (unit) => _openUnitEditor(unit: unit),
                        onDelete: (unit) async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Remove unit?'),
                              content: Text(
                                'This will disable ${unit.name} from the arena workspace.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true) return;
                          await ref
                              .read(arenasRepositoryProvider)
                              .deleteUnit(unit.id);
                          ref.invalidate(arenaDetailProvider(widget.arenaId));
                        },
                      ),
                      _BlocksTab(
                        blocksAsync: blocksAsync,
                        units: arena.units,
                        selectedDate: _blocksDate,
                        recurringOnly: _recurringBlocksOnly,
                        selectedUnitId: _blocksUnitId,
                        onPickDate: _pickBlocksDate,
                        onToggleRecurring: () => setState(() {
                          _recurringBlocksOnly = !_recurringBlocksOnly;
                        }),
                        onChangeUnit: (value) =>
                            setState(() => _blocksUnitId = value),
                        onAdd: () => _openBlockDialog(arena),
                        onDelete: (blockId) async {
                          await ref
                              .read(arenasRepositoryProvider)
                              .deleteBlock(blockId);
                          ref.invalidate(
                            arenaBlocksProvider((
                              arenaId: widget.arenaId,
                              date: _apiDate(_blocksDate),
                              unitId: _blocksUnitId,
                              recurringOnly: _recurringBlocksOnly,
                            )),
                          );
                          ref.invalidate(
                            arenaAvailabilityProvider((
                              arenaId: widget.arenaId,
                              date: _apiDate(_availabilityDate),
                              unitId: _availabilityUnitId,
                            )),
                          );
                        },
                      ),
                      _AvailabilityTab(
                        availabilityAsync: availabilityAsync,
                        units: arena.units,
                        selectedDate: _availabilityDate,
                        selectedUnitId: _availabilityUnitId,
                        onPickDate: _pickAvailabilityDate,
                        onChangeUnit: (value) =>
                            setState(() => _availabilityUnitId = value),
                      ),
                      _BookingsTab(
                        bookingsAsync: bookingsAsync,
                        selectedDate: _bookingsDate,
                        onPickDate: _pickBookingsDate,
                      ),
                      _AdminTab(
                        arena: arena,
                        onVerify: () => _openVerifySheet(arena),
                        onToggleSwing: () async {
                          await ref
                              .read(arenasRepositoryProvider)
                              .toggleSwingArena(arena.id);
                          ref.invalidate(arenaDetailProvider(widget.arenaId));
                          ref.invalidate(arenasListProvider);
                        },
                        onDelete: () async {
                          await ref
                              .read(arenasRepositoryProvider)
                              .deleteArena(arena.id);
                          if (!mounted) return;
                          ref.invalidate(arenasListProvider);
                          context.go('/arenas');
                        },
                        onAddManager: () => _openManagerDialog(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (e, _) => _ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(arenaDetailProvider(widget.arenaId)),
          ),
        ),
      ),
    );
  }

  void _refreshArena() {
    ref.invalidate(arenaDetailProvider(widget.arenaId));
    ref.invalidate(arenaStatsProvider(widget.arenaId));
    ref.invalidate(
      arenaBookingsProvider((
        arenaId: widget.arenaId,
        date: _apiDate(_bookingsDate),
      )),
    );
    ref.invalidate(
      arenaBlocksProvider((
        arenaId: widget.arenaId,
        date: _apiDate(_blocksDate),
        unitId: _blocksUnitId,
        recurringOnly: _recurringBlocksOnly,
      )),
    );
    ref.invalidate(
      arenaAvailabilityProvider((
        arenaId: widget.arenaId,
        date: _apiDate(_availabilityDate),
        unitId: _availabilityUnitId,
      )),
    );
  }

  Future<void> _pickAvailabilityDate() async {
    final next = await _pickDate(_availabilityDate);
    if (next != null) setState(() => _availabilityDate = next);
  }

  Future<void> _pickBlocksDate() async {
    final next = await _pickDate(_blocksDate);
    if (next != null) setState(() => _blocksDate = next);
  }

  Future<void> _pickBookingsDate() async {
    final next = await _pickDate(_bookingsDate);
    if (next != null) setState(() => _bookingsDate = next);
  }

  Future<DateTime?> _pickDate(DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
  }

  String _apiDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<List<String>> _uploadPickedImages(String folder) async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return const [];
    final repo = ref.read(arenasRepositoryProvider);
    final uploaded = <String>[];
    for (final file in picked) {
      final bytes = await file.readAsBytes();
      final url = await repo.uploadMedia(
        folder: folder,
        bytes: bytes,
        filename: file.name,
      );
      if (url.isNotEmpty) uploaded.add(url);
    }
    return uploaded;
  }

  Future<void> _openCoreEditor(ArenaDetail arena) async {
    final name = TextEditingController(text: arena.name);
    final description = TextEditingController(text: arena.description ?? '');
    final address = TextEditingController(text: arena.address);
    final city = TextEditingController(text: arena.city);
    final state = TextEditingController(text: arena.state);
    final pincode = TextEditingController(text: arena.pincode ?? '');
    final latitude = TextEditingController(
      text: arena.latitude == null ? '' : arena.latitude!.toString(),
    );
    final longitude = TextEditingController(
      text: arena.longitude == null ? '' : arena.longitude!.toString(),
    );
    final phone = TextEditingController(text: arena.phone ?? '');
    final openTime = TextEditingController(text: arena.openTime);
    final closeTime = TextEditingController(text: arena.closeTime);
    final advanceBookingDays = TextEditingController(
      text: arena.advanceBookingDays?.toString() ?? '',
    );
    final bufferMins = TextEditingController(
      text: arena.bufferMins?.toString() ?? '',
    );
    final cancellationHours = TextEditingController(
      text: arena.cancellationHours?.toString() ?? '',
    );
    final selectedSports = arena.sports.isEmpty
        ? <String>{'CRICKET'}
        : arena.sports.toSet();
    final operatingDays = arena.operatingDays.isEmpty
        ? <int>{1, 2, 3, 4, 5, 6, 7}
        : arena.operatingDays.toSet();
    bool hasParking = arena.hasParking;
    bool hasLights = arena.hasLights;
    bool hasWashrooms = arena.hasWashrooms;
    bool hasCanteen = arena.hasCanteen;
    bool hasCCTV = arena.hasCCTV;
    bool hasScorer = arena.hasScorer;
    bool isActive = arena.isActive;
    bool saving = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> save() async {
              setDialogState(() => saving = true);
              try {
                final payload = <String, dynamic>{
                  'name': name.text.trim(),
                  if (description.text.trim().isNotEmpty)
                    'description': description.text.trim(),
                  'address': address.text.trim(),
                  'city': city.text.trim(),
                  'state': state.text.trim(),
                  if (pincode.text.trim().isNotEmpty)
                    'pincode': pincode.text.trim(),
                  if (latitude.text.trim().isNotEmpty)
                    'latitude': double.parse(latitude.text.trim()),
                  if (longitude.text.trim().isNotEmpty)
                    'longitude': double.parse(longitude.text.trim()),
                  if (phone.text.trim().isNotEmpty) 'phone': phone.text.trim(),
                  'sports': selectedSports.toList(),
                  'hasParking': hasParking,
                  'hasLights': hasLights,
                  'hasWashrooms': hasWashrooms,
                  'hasCanteen': hasCanteen,
                  'hasCCTV': hasCCTV,
                  'hasScorer': hasScorer,
                  if (openTime.text.trim().isNotEmpty)
                    'openTime': openTime.text.trim(),
                  if (closeTime.text.trim().isNotEmpty)
                    'closeTime': closeTime.text.trim(),
                  'operatingDays': operatingDays.toList()..sort(),
                  if (advanceBookingDays.text.trim().isNotEmpty)
                    'advanceBookingDays': int.parse(
                      advanceBookingDays.text.trim(),
                    ),
                  if (bufferMins.text.trim().isNotEmpty)
                    'bufferMins': int.parse(bufferMins.text.trim()),
                  if (cancellationHours.text.trim().isNotEmpty)
                    'cancellationHours': int.parse(
                      cancellationHours.text.trim(),
                    ),
                  'isActive': isActive,
                };
                await ref
                    .read(arenasRepositoryProvider)
                    .updateArena(arena.id, payload);
                ref.invalidate(arenaDetailProvider(widget.arenaId));
                ref.invalidate(arenasListProvider);
                if (mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              } finally {
                if (mounted) {
                  setDialogState(() => saving = false);
                }
              }
            }

            return AlertDialog(
              title: const Text('Edit core details'),
              content: SizedBox(
                width: 760,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: description,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: address,
                        decoration: const InputDecoration(labelText: 'Address'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: city,
                              decoration: const InputDecoration(
                                labelText: 'City',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: state,
                              decoration: const InputDecoration(
                                labelText: 'State',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: pincode,
                              decoration: const InputDecoration(
                                labelText: 'Pincode',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: latitude,
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: longitude,
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: openTime,
                              decoration: const InputDecoration(
                                labelText: 'Open time',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: closeTime,
                              decoration: const InputDecoration(
                                labelText: 'Close time',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: advanceBookingDays,
                              decoration: const InputDecoration(
                                labelText: 'Advance booking days',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: bufferMins,
                              decoration: const InputDecoration(
                                labelText: 'Buffer mins',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: cancellationHours,
                              decoration: const InputDecoration(
                                labelText: 'Cancellation hours',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final sport in _sportOptions)
                              FilterChip(
                                label: Text(sport),
                                selected: selectedSports.contains(sport),
                                onSelected: (selected) => setDialogState(() {
                                  if (selected) {
                                    selectedSports.add(sport);
                                  } else {
                                    selectedSports.remove(sport);
                                  }
                                  if (selectedSports.isEmpty) {
                                    selectedSports.add('CRICKET');
                                  }
                                }),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final entry in _weekdays.entries)
                              FilterChip(
                                label: Text(entry.value),
                                selected: operatingDays.contains(entry.key),
                                onSelected: (selected) => setDialogState(() {
                                  if (selected) {
                                    operatingDays.add(entry.key);
                                  } else {
                                    operatingDays.remove(entry.key);
                                  }
                                  if (operatingDays.isEmpty) {
                                    operatingDays.addAll(_weekdays.keys);
                                  }
                                }),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        children: [
                          FilterChip(
                            label: const Text('Parking'),
                            selected: hasParking,
                            onSelected: (v) =>
                                setDialogState(() => hasParking = v),
                          ),
                          FilterChip(
                            label: const Text('Lights'),
                            selected: hasLights,
                            onSelected: (v) =>
                                setDialogState(() => hasLights = v),
                          ),
                          FilterChip(
                            label: const Text('Washrooms'),
                            selected: hasWashrooms,
                            onSelected: (v) =>
                                setDialogState(() => hasWashrooms = v),
                          ),
                          FilterChip(
                            label: const Text('Canteen'),
                            selected: hasCanteen,
                            onSelected: (v) =>
                                setDialogState(() => hasCanteen = v),
                          ),
                          FilterChip(
                            label: const Text('CCTV'),
                            selected: hasCCTV,
                            onSelected: (v) =>
                                setDialogState(() => hasCCTV = v),
                          ),
                          FilterChip(
                            label: const Text('Scorer'),
                            selected: hasScorer,
                            onSelected: (v) =>
                                setDialogState(() => hasScorer = v),
                          ),
                          FilterChip(
                            label: const Text('Active'),
                            selected: isActive,
                            onSelected: (v) =>
                                setDialogState(() => isActive = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Manage arena photos from the Photos tab using uploads.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: saving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    name.dispose();
    description.dispose();
    address.dispose();
    city.dispose();
    state.dispose();
    pincode.dispose();
    latitude.dispose();
    longitude.dispose();
    phone.dispose();
    openTime.dispose();
    closeTime.dispose();
    advanceBookingDays.dispose();
    bufferMins.dispose();
    cancellationHours.dispose();
    if (result == true) {
      ref.invalidate(arenaDetailProvider(widget.arenaId));
    }
  }

  Future<void> _openPhotosEditor(ArenaDetail arena) async {
    final photoUrls = [...arena.photoUrls];
    bool saving = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit photos'),
              content: SizedBox(
                width: 760,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: saving
                                ? null
                                : () async {
                                    setDialogState(() => saving = true);
                                    try {
                                      final uploaded =
                                          await _uploadPickedImages(
                                            'arenas/${arena.id}/photos',
                                          );
                                      if (uploaded.isNotEmpty) {
                                        setDialogState(() {
                                          photoUrls.addAll(uploaded);
                                        });
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      }
                                    } finally {
                                      if (mounted) {
                                        setDialogState(() => saving = false);
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.upload, size: 18),
                            label: const Text('Upload photos'),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${photoUrls.length} uploaded',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (photoUrls.isEmpty)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Upload arena photos to populate the gallery.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (var i = 0; i < photoUrls.length; i++)
                              _UploadedPhotoCard(
                                url: photoUrls[i],
                                onRemove: () =>
                                    setDialogState(() => photoUrls.removeAt(i)),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setDialogState(() => saving = true);
                          try {
                            await ref
                                .read(arenasRepositoryProvider)
                                .updateArena(arena.id, {
                                  'photoUrls': photoUrls,
                                });
                            ref.invalidate(arenaDetailProvider(widget.arenaId));
                            ref.invalidate(arenasListProvider);
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setDialogState(() => saving = false);
                            }
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openUnitDialog() async {
    await _openUnitEditor();
  }

  Future<void> _openUnitEditor({ArenaUnitDetail? unit}) async {
    final name = TextEditingController(text: unit?.name ?? '');
    final price = TextEditingController(
      text: unit == null ? '' : unit.pricePerHourPaise.toString(),
    );
    final peakPrice = TextEditingController(
      text: unit?.peakPricePaise?.toString() ?? '',
    );
    final minSlotMins = TextEditingController(
      text: (unit?.minSlotMins ?? 60).toString(),
    );
    final maxSlotMins = TextEditingController(
      text: (unit?.maxSlotMins ?? 240).toString(),
    );
    final unitPhotos = <String>[...?unit?.photoUrls];
    String unitType = unit?.unitType ?? 'FULL_GROUND';
    bool saving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> addPhotos() async {
              setDialogState(() => saving = true);
              try {
                final uploaded = await _uploadPickedImages(
                  unit == null
                      ? 'arenas/${widget.arenaId}/units/new'
                      : 'arenas/${widget.arenaId}/units/${unit.id}',
                );
                if (uploaded.isNotEmpty) {
                  setDialogState(() => unitPhotos.addAll(uploaded));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              } finally {
                if (mounted) {
                  setDialogState(() => saving = false);
                }
              }
            }

            Future<void> save() async {
              setDialogState(() => saving = true);
              try {
                final payload = <String, dynamic>{
                  'name': name.text.trim(),
                  'unitType': unitType,
                  'pricePerHourPaise': int.parse(price.text.trim()),
                  if (peakPrice.text.trim().isNotEmpty)
                    'peakPricePaise': int.parse(peakPrice.text.trim()),
                  if (minSlotMins.text.trim().isNotEmpty)
                    'minSlotMins': int.parse(minSlotMins.text.trim()),
                  if (maxSlotMins.text.trim().isNotEmpty)
                    'maxSlotMins': int.parse(maxSlotMins.text.trim()),
                  if (unitPhotos.isNotEmpty) 'photoUrls': unitPhotos,
                };
                if (unit == null) {
                  final created = await ref
                      .read(arenasRepositoryProvider)
                      .addUnit(widget.arenaId, payload);
                  if (unitPhotos.isNotEmpty) {
                    await ref.read(arenasRepositoryProvider).updateUnit(
                      created.id,
                      {'photoUrls': unitPhotos},
                    );
                  }
                } else {
                  await ref
                      .read(arenasRepositoryProvider)
                      .updateUnit(unit.id, payload);
                }
                ref.invalidate(arenaDetailProvider(widget.arenaId));
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              } finally {
                if (mounted) {
                  setDialogState(() => saving = false);
                }
              }
            }

            return AlertDialog(
              title: Text(unit == null ? 'Add unit' : 'Edit unit'),
              content: SizedBox(
                width: 720,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: unitType,
                        items:
                            const [
                                  'FULL_GROUND',
                                  'HALF_GROUND',
                                  'TURF',
                                  'CRICKET_NET',
                                  'INDOOR_NET',
                                  'MULTI_SPORT',
                                  'OTHER',
                                ]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => unitType = value);
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Unit type',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: price,
                              decoration: const InputDecoration(
                                labelText: 'Price per hour (paise)',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: peakPrice,
                              decoration: const InputDecoration(
                                labelText: 'Peak price (paise)',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: minSlotMins,
                              decoration: const InputDecoration(
                                labelText: 'Min slot mins',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: maxSlotMins,
                              decoration: const InputDecoration(
                                labelText: 'Max slot mins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: saving ? null : addPhotos,
                              icon: const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 18,
                              ),
                              label: const Text('Upload unit photos'),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${unitPhotos.length} uploaded',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (unitPhotos.isEmpty)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Upload photos for this specific unit.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (var i = 0; i < unitPhotos.length; i++)
                              _UploadedPhotoCard(
                                url: unitPhotos[i],
                                onRemove: () => setDialogState(
                                  () => unitPhotos.removeAt(i),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: saving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    name.dispose();
    price.dispose();
    peakPrice.dispose();
    minSlotMins.dispose();
    maxSlotMins.dispose();
  }

  Future<void> _openBlockDialog(ArenaDetail arena) async {
    final units = arena.units;
    if (units.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add a unit first')));
      return;
    }
    final startTime = TextEditingController(text: '10:00');
    final endTime = TextEditingController(text: '11:00');
    final reason = TextEditingController();
    String unitId = units.first.id;
    DateTime? oneTimeDate = DateTime.now();
    final selectedWeekdays = <int>{};
    bool recurring = false;
    bool saving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> save() async {
              setDialogState(() => saving = true);
              try {
                final payload = <String, dynamic>{
                  'unitId': unitId,
                  'startTime': startTime.text.trim(),
                  'endTime': endTime.text.trim(),
                  if (reason.text.trim().isNotEmpty)
                    'reason': reason.text.trim(),
                };
                if (recurring) {
                  payload['weekdays'] = selectedWeekdays.toList()..sort();
                } else {
                  payload['date'] = _apiDate(oneTimeDate ?? DateTime.now());
                }
                await ref
                    .read(arenasRepositoryProvider)
                    .createBlock(widget.arenaId, payload);
                ref.invalidate(
                  arenaBlocksProvider((
                    arenaId: widget.arenaId,
                    date: _apiDate(_blocksDate),
                    unitId: _blocksUnitId,
                    recurringOnly: _recurringBlocksOnly,
                  )),
                );
                ref.invalidate(
                  arenaAvailabilityProvider((
                    arenaId: widget.arenaId,
                    date: _apiDate(_availabilityDate),
                    unitId: _availabilityUnitId,
                  )),
                );
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              } finally {
                if (mounted) {
                  setDialogState(() => saving = false);
                }
              }
            }

            return AlertDialog(
              title: const Text('Add block'),
              content: SizedBox(
                width: 720,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: unitId,
                        items: units
                            .map(
                              (unit) => DropdownMenuItem(
                                value: unit.id,
                                child: Text(unit.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => unitId = value);
                          }
                        },
                        decoration: const InputDecoration(labelText: 'Unit'),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: recurring,
                        onChanged: (value) => setDialogState(() {
                          recurring = value;
                          if (recurring) {
                            selectedWeekdays.addAll({1, 2, 3, 4, 5, 6, 7});
                          } else {
                            selectedWeekdays.clear();
                          }
                        }),
                        title: const Text('Recurring block'),
                        subtitle: const Text(
                          'Use weekdays instead of a single date',
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (!recurring)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Block date'),
                          subtitle: Text(
                            oneTimeDate == null
                                ? 'Pick a date'
                                : _apiDate(oneTimeDate!),
                          ),
                          trailing: const Icon(Icons.calendar_month_outlined),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: oneTimeDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setDialogState(() => oneTimeDate = picked);
                            }
                          },
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final entry in _weekdays.entries)
                              FilterChip(
                                label: Text(entry.value),
                                selected: selectedWeekdays.contains(entry.key),
                                onSelected: (selected) => setDialogState(() {
                                  if (selected) {
                                    selectedWeekdays.add(entry.key);
                                  } else {
                                    selectedWeekdays.remove(entry.key);
                                  }
                                }),
                              ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: startTime,
                              decoration: const InputDecoration(
                                labelText: 'Start time',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: endTime,
                              decoration: const InputDecoration(
                                labelText: 'End time',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: reason,
                        decoration: const InputDecoration(labelText: 'Reason'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: saving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    startTime.dispose();
    endTime.dispose();
    reason.dispose();
  }

  Future<void> _openManagerDialog() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    bool saving = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> save() async {
              setDialogState(() => saving = true);
              try {
                await ref.read(arenasRepositoryProvider).addManager(
                  widget.arenaId,
                  {'name': name.text.trim(), 'phone': phone.text.trim()},
                );
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              } finally {
                if (mounted) {
                  setDialogState(() => saving = false);
                }
              }
            }

            return AlertDialog(
              title: const Text('Add manager'),
              content: SizedBox(
                width: 560,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phone,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: saving
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    name.dispose();
    phone.dispose();
  }

  Future<void> _openVerifySheet(ArenaDetail arena) async {
    String grade = arena.arenaGrade ?? 'CLUB';
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verify arena',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: grade,
                items: const ['GULLY', 'CLUB', 'DISTRICT', 'ELITE']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    grade = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Arena grade'),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await ref
                        .read(arenasRepositoryProvider)
                        .verifyArena(arena.id, grade);
                    ref.invalidate(arenaDetailProvider(widget.arenaId));
                    ref.invalidate(arenasListProvider);
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Apply verification'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(ArenaDetail arena) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hard delete arena?'),
          content: Text(
            'This permanently deletes ${arena.name} and all related arena data that the backend allows. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Hard delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await ref.read(arenasRepositoryProvider).deleteArena(arena.id);
    if (!mounted) return;
    ref.invalidate(arenasListProvider);
    context.go('/arenas');
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.arena,
    required this.statsAsync,
    required this.onEdit,
    required this.onRefreshStats,
  });
  final ArenaDetail arena;
  final AsyncValue<ArenaStatsDetail> statsAsync;
  final VoidCallback onEdit;
  final VoidCallback onRefreshStats;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AdminSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AdminInfoPill(
                              label: arena.verified
                                  ? 'Verified'
                                  : 'Pending review',
                              icon: arena.verified
                                  ? Icons.verified_rounded
                                  : Icons.hourglass_top_rounded,
                            ),
                            if (arena.swingEnabled)
                              const AdminInfoPill(
                                label: 'Swing enabled',
                                icon: Icons.sports_cricket_rounded,
                              ),
                            AdminInfoPill(
                              label: arena.isActive ? 'Active' : 'Inactive',
                              icon: arena.isActive
                                  ? Icons.toggle_on_rounded
                                  : Icons.toggle_off_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          arena.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          [
                            if (arena.city.isNotEmpty) arena.city,
                            if (arena.state.isNotEmpty) arena.state,
                            if (arena.pincode?.isNotEmpty == true)
                              arena.pincode!,
                          ].join(', '),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if ((arena.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            arena.description!,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.45,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 18),
                    _HeroBadgeStack(arena: arena),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit arena'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onRefreshStats,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh stats'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        statsAsync.when(
          data: (stats) => LayoutBuilder(
            builder: (context, constraints) {
              final metricWidth = constraints.maxWidth >= 960
                  ? (constraints.maxWidth - 24) / 4
                  : constraints.maxWidth >= 640
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: metricWidth,
                    child: _MetricCard(
                      title: 'Total bookings',
                      value: '${stats.totalBookings}',
                      icon: Icons.event_available_rounded,
                    ),
                  ),
                  SizedBox(
                    width: metricWidth,
                    child: _MetricCard(
                      title: 'Completed',
                      value: '${stats.completedBookings}',
                      icon: Icons.verified_rounded,
                    ),
                  ),
                  SizedBox(
                    width: metricWidth,
                    child: _MetricCard(
                      title: 'Revenue',
                      value:
                          '₹${(stats.totalRevenuePaise / 100).toStringAsFixed(0)}',
                      icon: Icons.payments_rounded,
                    ),
                  ),
                  SizedBox(
                    width: metricWidth,
                    child: _MetricCard(
                      title: 'Units',
                      value: '${arena.unitCount}',
                      icon: Icons.stadium_outlined,
                    ),
                  ),
                ],
              );
            },
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final leftWidth = constraints.maxWidth >= 920
                ? (constraints.maxWidth * 0.58)
                : constraints.maxWidth;
            final rightWidth = constraints.maxWidth >= 920
                ? (constraints.maxWidth * 0.42) - 12
                : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: leftWidth,
                  child: AdminKeyValueCard(
                    title: 'Arena details',
                    rows: [
                      AdminKeyValueRowData(
                        'Owner',
                        arena.owner?.userName ?? '—',
                      ),
                      AdminKeyValueRowData(
                        'Business',
                        arena.owner?.businessName ?? '—',
                      ),
                      AdminKeyValueRowData(
                        'Contact',
                        arena.phone ?? arena.owner?.userPhone ?? '—',
                      ),
                      AdminKeyValueRowData(
                        'Timing',
                        '${arena.openTime} – ${arena.closeTime}',
                      ),
                      AdminKeyValueRowData(
                        'Sports',
                        arena.sports.isEmpty ? '—' : arena.sports.join(', '),
                      ),
                      AdminKeyValueRowData(
                        'Operating days',
                        arena.operatingDays.isEmpty
                            ? '—'
                            : arena.operatingDays
                                  .map((d) => _weekdayLabel(d))
                                  .join(', '),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: rightWidth,
                  child: AdminKeyValueCard(
                    title: 'Ops snapshot',
                    rows: [
                      AdminKeyValueRowData(
                        'Photos',
                        '${arena.photoUrls.length}',
                      ),
                      AdminKeyValueRowData(
                        'Ratings',
                        arena.totalRatings > 0
                            ? '${arena.rating.toStringAsFixed(1)}★ (${arena.totalRatings})'
                            : '—',
                      ),
                      AdminKeyValueRowData('Plan', arena.planTier ?? '—'),
                      AdminKeyValueRowData('Grade', arena.arenaGrade ?? '—'),
                      AdminKeyValueRowData(
                        'Verified',
                        arena.verifiedAt == null
                            ? '—'
                            : DateFormat(
                                'dd MMM yyyy',
                              ).format(arena.verifiedAt!),
                      ),
                      AdminKeyValueRowData(
                        'Status',
                        arena.isActive ? 'Active' : 'Inactive',
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        if (arena.photoUrls.isNotEmpty) ...[
          const AdminSectionHeader(
            title: 'Photos',
            subtitle: 'Primary media pulled from the arena photoUrls array.',
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: arena.photoUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final url = arena.photoUrls[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.textMuted,
                                ),
                              ),
                        ),
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Photo ${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ] else ...[
          const AdminSectionHeader(
            title: 'Photos',
            subtitle: 'No photos are attached yet.',
          ),
          const SizedBox(height: 10),
          AdminSurfaceCard(
            child: Row(
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add arena photos from the Photos tab using device uploads.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: onEdit,
                  child: const Text('Edit photos'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PhotosTab extends StatelessWidget {
  const _PhotosTab({required this.photos, required this.onEdit});
  final List<String> photos;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No photos uploaded yet',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('Add photos'),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit photos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final url in photos)
              Container(
                width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  color: AppColors.surface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 10,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.textMuted,
                                ),
                              ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        url,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _UnitsTab extends StatelessWidget {
  const _UnitsTab({
    required this.units,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });
  final List<ArenaUnitDetail> units;
  final VoidCallback onAdd;
  final ValueChanged<ArenaUnitDetail> onEdit;
  final Future<void> Function(ArenaUnitDetail unit) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add unit'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (units.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(
              child: Text(
                'No units yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          for (final unit in units) ...[
            _SummaryCard(
              title: unit.name,
              trailing: unit.isActive
                  ? const _StatusPill(label: 'Active', color: Colors.green)
                  : const _StatusPill(
                      label: 'Disabled',
                      color: AppColors.textSecondary,
                    ),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _UnitChip(label: unit.unitType),
                    _UnitChip(label: unit.sport ?? 'No sport'),
                    _UnitChip(label: '${unit.capacity ?? 0} capacity'),
                    _UnitChip(
                      label:
                          '${unit.minSlotMins ?? 0}–${unit.maxSlotMins ?? 0} mins',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _KV(
                        label: 'Price/hour',
                        value:
                            '₹${(unit.pricePerHourPaise / 100).toStringAsFixed(0)}',
                      ),
                    ),
                    if (unit.peakPricePaise != null)
                      Expanded(
                        child: _KV(
                          label: 'Peak',
                          value:
                              '₹${(unit.peakPricePaise! / 100).toStringAsFixed(0)}',
                        ),
                      ),
                  ],
                ),
                if (unit.photoUrls.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: unit.photoUrls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final url = unit.photoUrls[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 132,
                            color: AppColors.bg,
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => onEdit(unit),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                    IconButton(
                      onPressed: unit.isActive ? () => onDelete(unit) : null,
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.danger,
                      ),
                      tooltip: 'Remove unit',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
      ),
    );
  }
}

class _BlocksTab extends StatelessWidget {
  const _BlocksTab({
    required this.blocksAsync,
    required this.units,
    required this.selectedDate,
    required this.recurringOnly,
    required this.selectedUnitId,
    required this.onPickDate,
    required this.onToggleRecurring,
    required this.onChangeUnit,
    required this.onAdd,
    required this.onDelete,
  });

  final AsyncValue<List<ArenaTimeBlockDetail>> blocksAsync;
  final List<ArenaUnitDetail> units;
  final DateTime selectedDate;
  final bool recurringOnly;
  final String? selectedUnitId;
  final VoidCallback onPickDate;
  final VoidCallback onToggleRecurring;
  final ValueChanged<String?> onChangeUnit;
  final VoidCallback onAdd;
  final Future<void> Function(String blockId) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add block'),
            ),
            OutlinedButton.icon(
              onPressed: onPickDate,
              icon: const Icon(Icons.calendar_month_outlined, size: 18),
              label: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
            ),
            FilterChip(
              label: const Text('Recurring only'),
              selected: recurringOnly,
              onSelected: (_) => onToggleRecurring(),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String?>(
                value: selectedUnitId,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All units'),
                  ),
                  for (final unit in units)
                    DropdownMenuItem<String?>(
                      value: unit.id,
                      child: Text(unit.name),
                    ),
                ],
                onChanged: onChangeUnit,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        blocksAsync.when(
          data: (blocks) {
            if (blocks.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                  child: Text(
                    'No blocks found',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final block in blocks) ...[
                  _SummaryCard(
                    title:
                        '${block.unitName} • ${block.startTime}–${block.endTime}',
                    trailing: block.isRecurring
                        ? const _StatusPill(
                            label: 'Recurring',
                            color: AppColors.textSecondary,
                          )
                        : const _StatusPill(
                            label: 'One-time',
                            color: AppColors.textPrimary,
                          ),
                    children: [
                      _KV(label: 'Reason', value: block.reason ?? '—'),
                      _KV(
                        label: 'Scope',
                        value: block.isRecurring
                            ? 'Weekdays: ${block.weekdays.map((d) => _ArenaWorkspaceScreenState._weekdays[d] ?? d).join(', ')}'
                            : (block.date == null
                                  ? '—'
                                  : DateFormat(
                                      'dd MMM yyyy',
                                    ).format(block.date!)),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () => onDelete(block.id),
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.danger,
                          ),
                          tooltip: 'Delete block',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (e, _) => Text(
            e.toString(),
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    );
  }
}

class _AvailabilityTab extends StatelessWidget {
  const _AvailabilityTab({
    required this.availabilityAsync,
    required this.units,
    required this.selectedDate,
    required this.selectedUnitId,
    required this.onPickDate,
    required this.onChangeUnit,
  });

  final AsyncValue<List<ArenaAvailabilityUnitDetail>> availabilityAsync;
  final List<ArenaUnitDetail> units;
  final DateTime selectedDate;
  final String? selectedUnitId;
  final VoidCallback onPickDate;
  final ValueChanged<String?> onChangeUnit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: onPickDate,
              icon: const Icon(Icons.calendar_month_outlined, size: 18),
              label: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
            ),
            SizedBox(
              width: 240,
              child: DropdownButtonFormField<String?>(
                value: selectedUnitId,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All units'),
                  ),
                  for (final unit in units)
                    DropdownMenuItem<String?>(
                      value: unit.id,
                      child: Text(unit.name),
                    ),
                ],
                onChanged: onChangeUnit,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        availabilityAsync.when(
          data: (rows) {
            if (rows.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                  child: Text(
                    'No availability found',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final row in rows) ...[
                  _SummaryCard(
                    title: row.unitName,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final slot in row.slots) _SlotPill(slot: slot),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (e, _) => Text(
            e.toString(),
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab({
    required this.bookingsAsync,
    required this.selectedDate,
    required this.onPickDate,
  });

  final AsyncValue<List<ArenaBookingDetail>> bookingsAsync;
  final DateTime selectedDate;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        OutlinedButton.icon(
          onPressed: onPickDate,
          icon: const Icon(Icons.calendar_month_outlined, size: 18),
          label: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
        ),
        const SizedBox(height: 12),
        bookingsAsync.when(
          data: (bookings) {
            if (bookings.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                  child: Text(
                    'No bookings found',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final booking in bookings) ...[
                  _SummaryCard(
                    title:
                        '${booking.unitName} • ${booking.startTime}–${booking.endTime}',
                    trailing: _StatusPill(
                      label: booking.status,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      _KV(
                        label: 'Customer',
                        value: booking.customerName ?? '—',
                      ),
                      _KV(label: 'Phone', value: booking.customerPhone ?? '—'),
                      _KV(
                        label: 'Total',
                        value:
                            '₹${(booking.totalAmountPaise / 100).toStringAsFixed(0)}',
                      ),
                      if (booking.date != null)
                        _KV(
                          label: 'Date',
                          value: DateFormat(
                            'dd MMM yyyy',
                          ).format(booking.date!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (e, _) => Text(
            e.toString(),
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    );
  }
}

class _AdminTab extends StatelessWidget {
  const _AdminTab({
    required this.arena,
    required this.onVerify,
    required this.onToggleSwing,
    required this.onDelete,
    required this.onAddManager,
  });

  final ArenaDetail arena;
  final VoidCallback onVerify;
  final VoidCallback onToggleSwing;
  final VoidCallback onDelete;
  final VoidCallback onAddManager;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: onVerify,
              icon: const Icon(Icons.verified_outlined, size: 18),
              label: const Text('Verify'),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: onToggleSwing,
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: Text(
                arena.swingEnabled ? 'Disable Swing' : 'Enable Swing',
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: onAddManager,
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text('Add manager'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          title: 'Admin controls',
          children: [
            _KV(label: 'Grade', value: arena.arenaGrade ?? '—'),
            _KV(
              label: 'Verified at',
              value: arena.verifiedAt == null
                  ? '—'
                  : DateFormat('dd MMM yyyy').format(arena.verifiedAt!),
            ),
            _KV(
              label: 'Created',
              value: arena.createdAt == null
                  ? '—'
                  : DateFormat('dd MMM yyyy').format(arena.createdAt!),
            ),
            _KV(
              label: 'Updated',
              value: arena.updatedAt == null
                  ? '—'
                  : DateFormat('dd MMM yyyy').format(arena.updatedAt!),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onDelete,
            tooltip: 'Hard delete arena',
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  const _KV({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AdminSurfaceCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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

class _HeroBadgeStack extends StatelessWidget {
  const _HeroBadgeStack({required this.arena});
  final ArenaDetail arena;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _HeroBadge(label: '${arena.unitCount}', caption: 'Units'),
        const SizedBox(height: 10),
        _HeroBadge(label: '${arena.photoUrls.length}', caption: 'Photos'),
        const SizedBox(height: 10),
        _HeroBadge(
          label: arena.totalRatings > 0 ? arena.rating.toStringAsFixed(1) : '—',
          caption: 'Rating',
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label, required this.caption});

  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadedPhotoCard extends StatelessWidget {
  const _UploadedPhotoCard({required this.url, required this.onRemove});

  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Uploaded',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Remove',
                  icon: const Icon(Icons.close, size: 16),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _weekdayLabel(int weekday) {
  switch (weekday) {
    case 1:
      return 'Mon';
    case 2:
      return 'Tue';
    case 3:
      return 'Wed';
    case 4:
      return 'Thu';
    case 5:
      return 'Fri';
    case 6:
      return 'Sat';
    case 7:
      return 'Sun';
    default:
      return weekday.toString();
  }
}

class _SlotPill extends StatelessWidget {
  const _SlotPill({required this.slot});
  final ArenaAvailabilitySlotDetail slot;

  @override
  Widget build(BuildContext context) {
    final isAvailable = slot.available;
    final color = isAvailable ? Colors.green : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Text(
        '${slot.start} - ${slot.end}${slot.reason != null ? ' • ${slot.reason}' : ''}',
        style: TextStyle(
          fontSize: 11.5,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Couldn\'t reach API',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
