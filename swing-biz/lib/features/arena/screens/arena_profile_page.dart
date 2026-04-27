import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../core/api/api_client.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/image_compressor.dart';
import '../services/arena_profile_providers.dart';

// ─── Color palette ───────────────────────────────────────────────────────────
const _bg = Color(0xFFF3F4F6);
const _surface = Color(0xFFFFFFFF);
const _line = Color(0xFFE1E5EA);
const _text = Color(0xFF0D1117);
const _muted = Color(0xFF6E7685);
const _accent = Color(0xFF059669);
const _deep = Color(0xFF064E3B);

// ─── Page ────────────────────────────────────────────────────────────────────

class ArenaProfilePage extends ConsumerStatefulWidget {
  const ArenaProfilePage({super.key, this.arenaId});

  final String? arenaId;

  @override
  ConsumerState<ArenaProfilePage> createState() => _ArenaProfilePageState();
}

class _ArenaProfilePageState extends ConsumerState<ArenaProfilePage> {
  Future<List<String>> _pickAndUploadUnitPhotos({
    required String folder,
    required int remainingSlots,
  }) async {
    if (remainingSlots <= 0) return const [];
    final files = await ImagePicker().pickMultiImage();
    if (files.isEmpty) return const [];

    final uploads = <String>[];
    for (final file in files.take(remainingSlots)) {
      final compressedFile = await ImageCompressor.compress(file.path);
      if (compressedFile == null) continue;

      final form = FormData.fromMap({
        'folder': folder,
        'file': await MultipartFile.fromFile(compressedFile.path, filename: '${p.basenameWithoutExtension(file.name)}.jpg'),
      });
      final response = await ApiClient.instance.dio.post(
        '/media/upload',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      final payload = response.data as Map<String, dynamic>;
      final data = (payload['data'] ?? payload) as Map<String, dynamic>;
      final url = (data['publicUrl'] ?? data['url'] ?? data['link']) as String?;
      if (url != null && url.isNotEmpty) uploads.add(url);
    }
    return uploads;
  }

  Future<void> _openUnitSheet(ArenaListing arena,
      [ArenaUnitOption? unit]) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _bg,
      builder: (context) => UnitEditorSheet(
        arenaId: arena.id,
        unit: unit,
        onPickPhotos: (currentCount) => _pickAndUploadUnitPhotos(
          folder: 'arenas/${arena.id}/units',
          remainingSlots: 3 - currentCount,
        ),
      ),
    );
    if (changed == true) {
      ref.invalidate(arenaDetailProvider);
      ref.invalidate(arenaDetailByIdProvider);
      ref.invalidate(ownedArenasProvider);
    }
  }

  Future<void> _deleteUnit(ArenaUnitOption unit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove unit?'),
        content: Text('${unit.name} will be hidden from booking setup.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(hostArenaBookingRepositoryProvider)
          .deleteArenaUnit(unit.id);
      ref.invalidate(arenaDetailProvider);
      ref.invalidate(arenaDetailByIdProvider);
      ref.invalidate(ownedArenasProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Unit removed')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Remove failed: $error')));
    }
  }

  void _openArenaDetailSheet(ArenaListing arena) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _bg,
      builder: (_) => _ArenaDetailSheet(arena: arena),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arenaAsync = widget.arenaId == null
        ? ref.watch(arenaDetailProvider)
        : ref.watch(arenaDetailByIdProvider(widget.arenaId!));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text(
          'Arena Setup',
          style: TextStyle(
            color: _text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _text),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.dashboard);
            }
          },
        ),
      ),
      body: arenaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(message: '$error'),
        data: (arena) {
          if (arena == null) return const _EmptyState();
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _ArenaSummaryCard(
                    arena: arena,
                    onTap: () => _openArenaDetailSheet(arena),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'UNITS',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _openUnitSheet(arena),
                        icon: const Icon(Icons.add_rounded, size: 17),
                        label: const Text('Add unit'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _deep,
                          foregroundColor: Colors.white,
                          visualDensity: VisualDensity.compact,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (arena.units.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _line),
                      ),
                      child: const Icon(
                        Icons.sports_cricket_rounded,
                        color: _muted,
                        size: 28,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
                  sliver: SliverList.separated(
                    itemCount: arena.units.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final unit = arena.units[index];
                      return _UnitCard(
                        unit: unit,
                        onTap: () => context.push(
                            '${AppRoutes.arenaUnitDetail}/${arena.id}/${unit.id}'),
                        onEdit: () => _openUnitSheet(arena, unit),
                        onDelete: () => _deleteUnit(unit),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Arena summary card (hero, tappable) ────────────────────────────────────

class _ArenaSummaryCard extends StatelessWidget {
  const _ArenaSummaryCard({required this.arena, required this.onTap});

  final ArenaListing arena;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = arena.photoUrls.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 172,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasPhoto)
                Image.network(
                  arena.photoUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: _deep),
                )
              else
                Container(
                  color: _deep,
                  child: const Icon(
                    Icons.stadium_rounded,
                    color: Colors.white70,
                    size: 52,
                  ),
                ),
              // gradient overlay
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                    stops: [0.25, 1.0],
                  ),
                ),
              ),
              // content
              Positioned(
                left: 16,
                right: 56,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      arena.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    if (arena.city.isNotEmpty || arena.state.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          _joinNonEmpty([arena.city, arena.state]),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (arena.sports.isNotEmpty)
                          _CardChip(arena.sports.first),
                        _CardChip('${arena.openTime} – ${arena.closeTime}'),
                        if (arena.units.isNotEmpty)
                          _CardChip('${arena.units.length} units'),
                      ],
                    ),
                  ],
                ),
              ),
              // edit icon
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardChip extends StatelessWidget {
  const _CardChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Arena detail bottom sheet ───────────────────────────────────────────────

class _ArenaDetailSheet extends ConsumerStatefulWidget {
  const _ArenaDetailSheet({required this.arena});

  final ArenaListing arena;

  @override
  ConsumerState<_ArenaDetailSheet> createState() => _ArenaDetailSheetState();
}

class _ArenaDetailSheetState extends ConsumerState<_ArenaDetailSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;
  late final TextEditingController _latitudeCtrl;
  late final TextEditingController _longitudeCtrl;
  late final TextEditingController _openTimeCtrl;
  late final TextEditingController _closeTimeCtrl;
  late final TextEditingController _advanceBookingDaysCtrl;
  late final TextEditingController _bufferMinsCtrl;
  late final TextEditingController _cancellationHoursCtrl;

  bool _editing = false;
  bool _saving = false;
  bool _uploading = false;
  bool _hasParking = false;
  bool _hasLights = false;
  bool _hasWashrooms = false;
  bool _hasCanteen = false;
  bool _hasCctv = false;
  bool _hasScorer = false;
  bool _hasFoodArea = false;
  bool _hasSeating = false;
  bool _hasChangingRoom = false;
  bool _hasDrinkingWater = false;
  bool _hasFirstAid = false;
  bool _hasEquipmentRental = false;
  List<int> _operatingDays = const [];
  List<String> _photoUrls = const [];
  List<String> _sports = const [];

  @override
  void initState() {
    super.initState();
    _initFrom(widget.arena);
  }

  void _initFrom(ArenaListing arena) {
    _nameCtrl = TextEditingController(text: arena.name);
    _descriptionCtrl = TextEditingController(text: arena.description);
    _phoneCtrl = TextEditingController(text: arena.phone ?? '');
    _addressCtrl = TextEditingController(text: arena.address);
    _cityCtrl = TextEditingController(text: arena.city);
    _stateCtrl = TextEditingController(text: arena.state);
    _pincodeCtrl = TextEditingController(text: arena.pincode);
    _latitudeCtrl =
        TextEditingController(text: arena.latitude?.toString() ?? '');
    _longitudeCtrl =
        TextEditingController(text: arena.longitude?.toString() ?? '');
    _openTimeCtrl = TextEditingController(text: arena.openTime);
    _closeTimeCtrl = TextEditingController(text: arena.closeTime);
    _advanceBookingDaysCtrl =
        TextEditingController(text: '${arena.advanceBookingDays}');
    _bufferMinsCtrl = TextEditingController(text: '${arena.bufferMins}');
    _cancellationHoursCtrl =
        TextEditingController(text: '${arena.cancellationHours}');
    _hasParking = arena.hasParking;
    _hasLights = arena.hasLights;
    _hasWashrooms = arena.hasWashrooms;
    _hasCanteen = arena.hasCanteen;
    _hasCctv = arena.hasCCTV;
    _hasScorer = arena.hasScorer;
    _hasFoodArea = arena.hasCanteen;
    _operatingDays = arena.operatingDays.isEmpty
        ? const [1, 2, 3, 4, 5, 6, 7]
        : List<int>.from(arena.operatingDays);
    _photoUrls = List<String>.from(arena.photoUrls);
    _sports = List<String>.from(arena.sports);
  }

  void _reset() {
    final arena = widget.arena;
    _nameCtrl.text = arena.name;
    _descriptionCtrl.text = arena.description;
    _phoneCtrl.text = arena.phone ?? '';
    _addressCtrl.text = arena.address;
    _cityCtrl.text = arena.city;
    _stateCtrl.text = arena.state;
    _pincodeCtrl.text = arena.pincode;
    _latitudeCtrl.text = arena.latitude?.toString() ?? '';
    _longitudeCtrl.text = arena.longitude?.toString() ?? '';
    _openTimeCtrl.text = arena.openTime;
    _closeTimeCtrl.text = arena.closeTime;
    _advanceBookingDaysCtrl.text = '${arena.advanceBookingDays}';
    _bufferMinsCtrl.text = '${arena.bufferMins}';
    _cancellationHoursCtrl.text = '${arena.cancellationHours}';
    _hasParking = arena.hasParking;
    _hasLights = arena.hasLights;
    _hasWashrooms = arena.hasWashrooms;
    _hasCanteen = arena.hasCanteen;
    _hasCctv = arena.hasCCTV;
    _hasScorer = arena.hasScorer;
    _hasFoodArea = arena.hasCanteen;
    _operatingDays = arena.operatingDays.isEmpty
        ? const [1, 2, 3, 4, 5, 6, 7]
        : List<int>.from(arena.operatingDays);
    _photoUrls = List<String>.from(arena.photoUrls);
    _sports = List<String>.from(arena.sports);
  }

  @override
  void dispose() {
    for (final ctrl in [
      _nameCtrl,
      _descriptionCtrl,
      _phoneCtrl,
      _addressCtrl,
      _cityCtrl,
      _stateCtrl,
      _pincodeCtrl,
      _latitudeCtrl,
      _longitudeCtrl,
      _openTimeCtrl,
      _closeTimeCtrl,
      _advanceBookingDaysCtrl,
      _bufferMinsCtrl,
      _cancellationHoursCtrl,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAndUploadPhotos() async {
    final files = await ImagePicker().pickMultiImage();
    if (files.isEmpty) return;
    setState(() => _uploading = true);
    try {
      final uploads = <String>[];
      for (final file in files) {
        final compressedFile = await ImageCompressor.compress(file.path);
        if (compressedFile == null) continue;

        final form = FormData.fromMap({
          'folder': 'arenas/${widget.arena.id}',
          'file': await MultipartFile.fromFile(compressedFile.path, filename: '${p.basenameWithoutExtension(file.name)}.jpg'),
        });
        final response = await ApiClient.instance.dio.post(
          '/media/upload',
          data: form,
          options: Options(contentType: 'multipart/form-data'),
        );
        final payload = response.data as Map<String, dynamic>;
        final data = (payload['data'] ?? payload) as Map<String, dynamic>;
        final url = (data['publicUrl'] ?? data['url'] ?? data['link']) as String?;
        if (url != null && url.isNotEmpty) uploads.add(url);
      }
      if (!mounted || uploads.isEmpty) return;
      setState(() => _photoUrls = [..._photoUrls, ...uploads]);
    } catch (error) {
      if (!mounted) return;
      String msg = error.toString();
      if (error is DioException) {
        msg = error.response?.data?['message'] ?? error.message ?? msg;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo upload failed: $msg')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _saveArena() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(hostArenaBookingRepositoryProvider)
          .updateArena(widget.arena.id, {
        'name': _nameCtrl.text.trim(),
        'description': _emptyToNull(_descriptionCtrl.text),
        'phone': _emptyToNull(_phoneCtrl.text),
        'address': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'pincode': _pincodeCtrl.text.trim(),
        'latitude': _parseDouble(_latitudeCtrl.text),
        'longitude': _parseDouble(_longitudeCtrl.text),
        'advanceBookingDays': _intValue(_advanceBookingDaysCtrl.text),
        'bufferMins': _intValue(_bufferMinsCtrl.text),
        'cancellationHours': _intValue(_cancellationHoursCtrl.text),
        'operatingDays': _operatingDays,
        'photoUrls': _photoUrls,
        'sports': _sports,
        'hasParking': _hasParking,
        'hasLights': _hasLights,
        'hasWashrooms': _hasWashrooms,
        'hasCanteen': _hasCanteen,
        'hasCCTV': _hasCctv,
        'hasScorer': _hasScorer,
      });
      ref.invalidate(arenaDetailProvider);
      ref.invalidate(arenaDetailByIdProvider);
      ref.invalidate(ownedArenasProvider);
      if (!mounted) return;
      setState(() => _editing = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Arena updated')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Update failed: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        minChildSize: 0.6,
        maxChildSize: 0.96,
        builder: (ctx, controller) => Form(
          key: _formKey,
          child: Column(
            children: [
              // sheet header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.arena.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _text,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            _editing ? 'Editing' : 'Arena details',
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_editing)
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () => setState(() {
                                  _reset();
                                  _editing = false;
                                }),
                        child: const Text('Cancel'),
                      ),
                    if (!_editing)
                      IconButton(
                        onPressed: () => setState(() => _editing = true),
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: _deep,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: _line),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  children: [
                    _overviewSection(),
                    const SizedBox(height: 20),
                    _rulesSection(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              if (_editing)
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    decoration: const BoxDecoration(
                      color: _bg,
                      border: Border(top: BorderSide(color: _line)),
                    ),
                    child: FilledButton(
                      onPressed: _saving || _uploading ? null : _saveArena,
                      style: FilledButton.styleFrom(
                        backgroundColor: _deep,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Arena'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('OVERVIEW'),
        _Panel(children: [
          _field('Arena name', _nameCtrl, widget.arena.name, required: true),
          _field('Description', _descriptionCtrl,
              _fallback(widget.arena.description),
              maxLines: 3),
          _field(
            'Booking phone',
            _phoneCtrl,
            _fallback(widget.arena.phone),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
          _readRow(
              'Primary sport', _sports.isEmpty ? 'Not set' : _sports.first),
        ]),
        const SizedBox(height: 16),
        const _SectionLabel('LOCATION'),
        _Panel(children: [
          _field('Pincode', _pincodeCtrl, _fallback(widget.arena.pincode)),
          _field('City', _cityCtrl, _fallback(widget.arena.city),
              required: true),
          _field('State', _stateCtrl, _fallback(widget.arena.state),
              required: true),
          _field('Address', _addressCtrl, _fallback(widget.arena.address),
              required: true, maxLines: 2),
          Row(
            children: [
              Expanded(
                child: _field(
                  'Latitude',
                  _latitudeCtrl,
                  widget.arena.latitude?.toString() ?? 'Not set',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  'Longitude',
                  _longitudeCtrl,
                  widget.arena.longitude?.toString() ?? 'Not set',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                ),
              ),
            ],
          ),
        ]),
        const SizedBox(height: 16),
        _PhotoSection(
          photoUrls: _photoUrls,
          editing: _editing,
          uploading: _uploading,
          onAdd: _pickAndUploadPhotos,
          onRemove: (url) => setState(() {
            _photoUrls = _photoUrls.where((item) => item != url).toList();
          }),
        ),
        const SizedBox(height: 16),
        const _SectionLabel('FACILITIES'),
        _FeatureGrid(
          editing: _editing,
          items: [
            _EditableFeatureItem('Parking', _hasParking,
                (v) => setState(() => _hasParking = v)),
            _EditableFeatureItem('Lights', _hasLights,
                (v) => setState(() => _hasLights = v)),
            _EditableFeatureItem('Washrooms', _hasWashrooms,
                (v) => setState(() => _hasWashrooms = v)),
            _EditableFeatureItem('Canteen', _hasCanteen,
                (v) => setState(() => _hasCanteen = v)),
            _EditableFeatureItem('Food area', _hasFoodArea,
                (v) => setState(() => _hasFoodArea = v)),
            _EditableFeatureItem('Seating', _hasSeating,
                (v) => setState(() => _hasSeating = v)),
            _EditableFeatureItem('Changing room', _hasChangingRoom,
                (v) => setState(() => _hasChangingRoom = v)),
            _EditableFeatureItem('Drinking water', _hasDrinkingWater,
                (v) => setState(() => _hasDrinkingWater = v)),
            _EditableFeatureItem('First aid', _hasFirstAid,
                (v) => setState(() => _hasFirstAid = v)),
            _EditableFeatureItem('Equipment rental', _hasEquipmentRental,
                (v) => setState(() => _hasEquipmentRental = v)),
            _EditableFeatureItem(
                'CCTV', _hasCctv, (v) => setState(() => _hasCctv = v)),
            _EditableFeatureItem('Scorer', _hasScorer,
                (v) => setState(() => _hasScorer = v)),
          ],
        ),
      ],
    );
  }

  Widget _rulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('BOOKING RULES'),
        _Panel(children: [
          _field(
            'Advance booking days',
            _advanceBookingDaysCtrl,
            '${widget.arena.advanceBookingDays}',
            required: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _numberRequired,
          ),
          _field(
            'Buffer minutes',
            _bufferMinsCtrl,
            '${widget.arena.bufferMins}',
            required: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _numberRequired,
          ),
          _field(
            'Cancellation hours',
            _cancellationHoursCtrl,
            '${widget.arena.cancellationHours}',
            required: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _numberRequired,
          ),
        ]),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String viewValue, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    if (!_editing) return _readRow(label, viewValue);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator ??
            (required
                ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
                : null),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: _surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          border: _inputBorder(_line),
          enabledBorder: _inputBorder(_line),
          focusedBorder: _inputBorder(_accent),
          errorBorder: _inputBorder(const Color(0xFFD92D20)),
          focusedErrorBorder: _inputBorder(const Color(0xFFD92D20)),
        ),
      ),
    );
  }

  Widget _readRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.trim().isEmpty ? 'Not set' : value,
              style: const TextStyle(
                color: _text,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _numberRequired(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'Required';
    if (int.tryParse(raw) == null) return 'Enter a number';
    return null;
  }
}

// ─── Unit card ───────────────────────────────────────────────────────────────

class _UnitCard extends StatelessWidget {
  const _UnitCard({
    required this.unit,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final ArenaUnitOption unit;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title =
        _fallback(unit.unitTypeLabel).replaceAll('Not set', unit.unitType);
    final subtitle = _joinNonEmpty([
      title,
      unit.netType,
      '${unit.minSlotMins ~/ 60}h min',
    ]);
    final isGround = unit.unitType == 'FULL_GROUND' || unit.unitType == 'HALF_GROUND';
    final priceRows = [
      if (!isGround) _money(unit.pricePerHourPaise),
      if (unit.price4HrPaise != null)
        '4h ${_money(unit.price4HrPaise!)}'
      else if (isGround)
        '4h ${_money(unit.pricePerHourPaise * 4)}',
      if (unit.price8HrPaise != null) '8h ${_money(unit.price8HrPaise!)}',
      if (unit.priceFullDayPaise != null)
        'Day ${_money(unit.priceFullDayPaise!)}',
    ];
    final hasSchedule =
        unit.openTime != null && unit.closeTime != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: unit.photoUrls.isEmpty
                        ? Container(
                            color: _deep,
                            child: const Icon(
                              Icons.sports_cricket_rounded,
                              color: Colors.white70,
                              size: 22,
                            ),
                          )
                        : Image.network(
                            unit.photoUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: _deep,
                              child: const Icon(
                                Icons.sports_cricket_rounded,
                                color: Colors.white70,
                                size: 22,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: _muted),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Remove')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final row in priceRows) _SmallPill(row),
                if (hasSchedule)
                  _SmallPill('${unit.openTime} – ${unit.closeTime}'),
                if (unit.hasFloodlights)
                  const _SmallPill('Floodlights', highlight: true),
                if (unit.weekendMultiplier != 1)
                  _SmallPill(
                    isGround
                        ? 'Wknd ${_money(((unit.price4HrPaise ?? unit.pricePerHourPaise * 4) * unit.weekendMultiplier).round())}/4hr'
                        : 'Wknd ${_money((unit.pricePerHourPaise * unit.weekendMultiplier).round())}/hr',
                    highlight: true,
                  ),
                if (unit.addons.isNotEmpty)
                  _SmallPill('${unit.addons.length} add-ons'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill(this.label, {this.highlight = false});

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? _accent.withValues(alpha: 0.08) : _bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: highlight ? _accent.withValues(alpha: 0.3) : _line),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: highlight ? _accent : _text,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─── Unit editor sheet ───────────────────────────────────────────────────────

class UnitEditorSheet extends ConsumerStatefulWidget {
  const UnitEditorSheet({
    super.key,
    required this.arenaId,
    required this.onPickPhotos,
    this.unit,
  });

  final String arenaId;
  final ArenaUnitOption? unit;
  final Future<List<String>> Function(int currentCount) onPickPhotos;

  @override
  ConsumerState<UnitEditorSheet> createState() => UnitEditorSheetState();
}

class UnitEditorSheetState extends ConsumerState<UnitEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _priceHourCtrl = TextEditingController();
  final _price4Ctrl = TextEditingController();
  final _price8Ctrl = TextEditingController();
  final _priceDayCtrl = TextEditingController();
  final _minAdvanceCtrl = TextEditingController();
  final _openTimeCtrl = TextEditingController();
  final _closeTimeCtrl = TextEditingController();
  String _unitType = 'CRICKET_NET';
  String _netType = '';
  int _slotMins = 60;
  int _breatherMins = 0;
  double _weekendMultiplier = 1.0;
  int _quantity = 1;
  bool _showBulkPricing = false;
  bool _hasFloodlights = false;
  List<int> _scheduleOpDays = const [];
  int _step = 0;
  bool _saving = false;
  bool _uploading = false;
  late List<String> _photos;
  late List<_AddonDraft> _addons;

  static const _kStandardAddons = [
    ('BOWLING_MACHINE', 'Bowling machine'),
    ('ARM_THROWER', 'Arm thrower'),
    ('SCORER', 'Scorer'),
    ('COACHING', 'Coaching'),
  ];
  final Map<String, bool> _stdAddonEnabled = {};
  final Map<String, TextEditingController> _stdAddonPrice = {};
  final Map<String, String?> _stdAddonId = {};

  String? _parentUnitId;

  bool get _editing => widget.unit != null;
  bool get _isGround =>
      _unitType == 'FULL_GROUND' || _unitType == 'HALF_GROUND';
  bool get _canHaveParent =>
      _unitType == 'CENTER_WICKET' || _unitType == 'HALF_GROUND';

  @override
  void initState() {
    super.initState();
    final unit = widget.unit;
    _unitType = unit?.unitType ?? 'CRICKET_NET';
    _parentUnitId = unit?.parentUnitId;
    _labelCtrl.text = unit?.unitTypeLabel ?? _labelForType(_unitType);
    _netType = unit?.netType ?? '';
    _slotMins = unit?.minSlotMins ?? (_isGround ? 240 : 60);
    final increment = unit?.slotIncrementMins ?? _slotMins;
    _breatherMins = _isGround ? (increment - _slotMins).clamp(0, 60) : 0;
    _weekendMultiplier = unit?.weekendMultiplier ?? 1.0;
    _priceHourCtrl.text = _rupeesText(unit?.pricePerHourPaise);
    _price4Ctrl.text = _rupeesText(unit?.price4HrPaise);
    _price8Ctrl.text = _rupeesText(unit?.price8HrPaise);
    _priceDayCtrl.text = _rupeesText(unit?.priceFullDayPaise);
    _minAdvanceCtrl.text = unit?.minAdvancePaise != null && unit!.minAdvancePaise > 0
        ? (unit.minAdvancePaise / 100).toStringAsFixed(0)
        : '';
    _showBulkPricing = unit != null &&
        (unit.price4HrPaise != null ||
            unit.price8HrPaise != null ||
            unit.priceFullDayPaise != null);
    _openTimeCtrl.text = unit?.openTime ?? '';
    _closeTimeCtrl.text = unit?.closeTime ?? '';
    _hasFloodlights = unit?.hasFloodlights ?? false;
    _scheduleOpDays = unit?.operatingDays.isNotEmpty == true
        ? List<int>.from(unit!.operatingDays)
        : const [1, 2, 3, 4, 5, 6, 7];
    _photos = List<String>.from(unit?.photoUrls ?? const []);

    for (final (type, _) in _kStandardAddons) {
      _stdAddonEnabled[type] = false;
      _stdAddonPrice[type] = TextEditingController();
      _stdAddonId[type] = null;
    }

    final customAddons = <ArenaAddon>[];
    for (final addon in unit?.addons ?? const <ArenaAddon>[]) {
      final isStd = _kStandardAddons.any((e) => e.$1 == addon.addonType);
      if (isStd && addon.addonType != null) {
        _stdAddonEnabled[addon.addonType!] = true;
        _stdAddonPrice[addon.addonType!]!.text = _rupeesText(addon.pricePaise);
        _stdAddonId[addon.addonType!] = addon.id;
      } else {
        customAddons.add(addon);
      }
    }
    _addons = [for (final a in customAddons) _AddonDraft.fromAddon(a)];
    _priceHourCtrl.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _priceHourCtrl.removeListener(_rebuild);
    for (final ctrl in [
      _labelCtrl,
      _priceHourCtrl,
      _price4Ctrl,
      _price8Ctrl,
      _priceDayCtrl,
      _minAdvanceCtrl,
      _openTimeCtrl,
      _closeTimeCtrl,
      ..._stdAddonPrice.values,
    ]) {
      ctrl.dispose();
    }
    for (final addon in _addons) {
      addon.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    if (_photos.length >= 3) return;
    setState(() => _uploading = true);
    try {
      final uploads = await widget.onPickPhotos(_photos.length);
      if (!mounted || uploads.isEmpty) return;
      setState(() => _photos = [..._photos, ...uploads].take(3).toList());
    } catch (error) {
      if (!mounted) return;
      String msg = error.toString();
      if (error is DioException) {
        msg = error.response?.data?['message'] ?? error.message ?? msg;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo upload failed: $msg')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  bool _validateStep() {
    if (_step == 0) return true;
    if (_step == 1) {
      // schedule step: validate time format if provided
      final open = _openTimeCtrl.text.trim();
      final close = _closeTimeCtrl.text.trim();
      if (open.isNotEmpty && !RegExp(r'^\d{2}:\d{2}$').hasMatch(open)) {
        return false;
      }
      if (close.isNotEmpty && !RegExp(r'^\d{2}:\d{2}$').hasMatch(close)) {
        return false;
      }
      return true;
    }
    if (_step == 2) {
      if (_isGround) {
        return _price4Ctrl.text.trim().isNotEmpty &&
            _rupeesToPaise(_price4Ctrl.text) > 0;
      }
      return _priceHourCtrl.text.trim().isNotEmpty &&
          _rupeesToPaise(_priceHourCtrl.text) > 0;
    }
    return true;
  }

  void _next() {
    if (!_validateStep()) {
      final msg = _step == 1
          ? 'Use HH:MM format for open/close times'
          : _isGround
              ? 'Set a 4 hr price to continue'
              : 'Set a price per hour to continue';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    if (_step < 3) setState(() => _step += 1);
  }

  void _back() {
    if (_step > 0) setState(() => _step -= 1);
  }

  String get _baseUnitName {
    final label = _labelCtrl.text.trim();
    if (label.isNotEmpty) return label;
    return _labelForType(_unitType);
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || !_validateStep()) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(hostArenaBookingRepositoryProvider);
      final quantity = _editing ? 1 : _quantity;
      final createdNames = <String>[];
      for (var index = 0; index < quantity; index++) {
        final unitName =
            quantity == 1 ? _baseUnitName : '$_baseUnitName ${index + 1}';
        final input = {
          'name': _editing ? widget.unit!.name : unitName,
          'unitType': _unitType,
          'unitTypeLabel': _emptyToNull(_labelCtrl.text),
          'netType': _netType.isEmpty ? null : _netType,
          'sport': 'CRICKET',
          'photoUrls': _photos,
          'pricePerHourPaise': _isGround
              ? (_rupeesToPaise(_price4Ctrl.text) ~/ 4)
              : _rupeesToPaise(_priceHourCtrl.text),
          'price4HrPaise': _isGround
              ? _rupeesToPaise(_price4Ctrl.text)
              : _optionalRupeesToPaise(_price4Ctrl.text),
          'price8HrPaise': _optionalRupeesToPaise(_price8Ctrl.text),
          'priceFullDayPaise': _optionalRupeesToPaise(_priceDayCtrl.text),
          'weekendMultiplier': _weekendMultiplier,
          'minSlotMins': _slotMins,
          'maxSlotMins': _slotMins,
          'slotIncrementMins': _slotMins + _breatherMins,
          'turnaroundMins': _breatherMins,
          'minAdvancePaise': _rupeesToPaise(_minAdvanceCtrl.text),
          'parentUnitId': _canHaveParent ? _parentUnitId : null,
          if (_openTimeCtrl.text.trim().isNotEmpty)
            'openTime': _openTimeCtrl.text.trim(),
          if (_closeTimeCtrl.text.trim().isNotEmpty)
            'closeTime': _closeTimeCtrl.text.trim(),
          'operatingDays': _scheduleOpDays,
          'hasFloodlights': _hasFloodlights,
        };
        input.removeWhere((_, v) => v == null);
        final savedUnit = _editing
            ? await repo.updateArenaUnit(widget.unit!.id, input)
            : await repo.createArenaUnit(widget.arenaId, input);
        createdNames.add(savedUnit.name);

        final keptAddonIds = <String>{};

        for (final (type, name) in _kStandardAddons) {
          final enabled = _stdAddonEnabled[type] ?? false;
          final existingId = _stdAddonId[type];
          if (enabled) {
            final addonInput = {
              'unitId': savedUnit.id,
              'name': name,
              'addonType': type,
              'pricePaise': _rupeesToPaise(_stdAddonPrice[type]?.text ?? ''),
              'unit': 'per_session',
              'isAvailable': true,
            };
            if (existingId != null) {
              keptAddonIds.add(existingId);
              await repo.updateArenaAddon(existingId, addonInput);
            } else {
              await repo.createArenaAddon(widget.arenaId, addonInput);
            }
          }
        }

        for (final draft in _addons) {
          if (draft.name.text.trim().isEmpty) continue;
          final addonInput = {
            'unitId': savedUnit.id,
            'name': draft.name.text.trim(),
            'addonType': _emptyToNull(draft.addonType.text),
            'description': _emptyToNull(draft.description.text),
            'pricePaise': _rupeesToPaise(draft.price.text),
            'unit': draft.unit.text.trim().isEmpty
                ? 'per_session'
                : draft.unit.text.trim(),
            'isAvailable': true,
          };
          addonInput.removeWhere((_, v) => v == null);
          if (_editing && draft.id != null) {
            keptAddonIds.add(draft.id!);
            await repo.updateArenaAddon(draft.id!, addonInput);
          } else {
            await repo.createArenaAddon(widget.arenaId, addonInput);
          }
        }

        if (_editing) {
          for (final old in widget.unit?.addons ?? const <ArenaAddon>[]) {
            if (!keptAddonIds.contains(old.id)) {
              await repo.deleteArenaAddon(old.id);
            }
          }
        }
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editing ? 'Unit updated' : '${createdNames.length} unit added',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final isLastStep = _step == 3;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        minChildSize: 0.72,
        maxChildSize: 0.96,
        builder: (context, controller) => Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _editing ? 'Edit unit' : 'Add units',
                        style: const TextStyle(
                          color: _text,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: _StepDots(count: 4, activeIndex: _step),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [_stepBody()],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: const BoxDecoration(
                    color: _bg,
                    border: Border(top: BorderSide(color: _line)),
                  ),
                  child: Row(
                    children: [
                      if (_step > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving || _uploading ? null : _back,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _deep,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                      if (_step > 0) const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _saving || _uploading
                              ? null
                              : isLastStep
                                  ? _save
                                  : _next,
                          style: FilledButton.styleFrom(
                            backgroundColor: _deep,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : Text(isLastStep
                                  ? (_editing ? 'Save Unit' : 'Create Units')
                                  : 'Next'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepBody() {
    return switch (_step) {
      0 => _typeAndDetailsStep(),
      1 => _scheduleStep(),
      2 => _pricingStep(),
      _ => _photosAndAddonsStep(),
    };
  }

  Widget _typeAndDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LargeStepTitle('What are you adding?'),
        _SegmentedOptions(
          value: _unitType,
          options: const [
            ('FULL_GROUND', 'Full ground'),
            ('CRICKET_NET', 'Nets'),
            ('CENTER_WICKET', 'Center wicket'),
          ],
          onChanged: (value) {
            setState(() {
              _unitType = value;
              _labelCtrl.text = _labelForType(value);
              if (value != 'CRICKET_NET') _netType = '';
              _slotMins = value == 'FULL_GROUND' ? 240 : 60;
            });
          },
        ),
        if (_unitType == 'CRICKET_NET') ...[
          const SizedBox(height: 20),
          const Text(
            'Surface type',
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          _SegmentedOptions(
            value: _netType,
            options: const [
              ('Turf', 'Turf'),
              ('Mat', 'Mat'),
              ('Cement', 'Cement'),
            ],
            onChanged: (v) => setState(() => _netType = v),
          ),
        ],
        if (_canHaveParent) ...[
          const SizedBox(height: 20),
          const Text(
            'Part of ground',
            style: TextStyle(color: _text, fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 4),
          const Text(
            'If this unit shares the ground with a Full ground unit, link them so bookings block each other.',
            style: TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          _ParentUnitPicker(
            arenaId: widget.arenaId,
            currentUnitId: widget.unit?.id,
            selectedParentId: _parentUnitId,
            onChanged: (id) => setState(() => _parentUnitId = id),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Floodlights',
                    style: TextStyle(
                      color: _text,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Available for night play',
                    style: TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Switch(
              value: _hasFloodlights,
              onChanged: (v) => setState(() => _hasFloodlights = v),
              activeThumbColor: _accent,
            ),
          ],
        ),
        if (!_editing) ...[
          const SizedBox(height: 20),
          _QuantityStepper(
            value: _quantity,
            onChanged: (v) => setState(() => _quantity = v),
          ),
        ],
      ],
    );
  }

  Widget _scheduleStep() {
    const days = [
      (1, 'Mon'),
      (2, 'Tue'),
      (3, 'Wed'),
      (4, 'Thu'),
      (5, 'Fri'),
      (6, 'Sat'),
      (7, 'Sun'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LargeStepTitle('Schedule'),
        Row(
          children: [
            Expanded(
              child: _TimePickerField(
                label: 'Open time',
                controller: _openTimeCtrl,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TimePickerField(
                label: 'Close time',
                controller: _closeTimeCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Operating days',
          style: TextStyle(
            color: _text,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: days.map((d) {
            final selected = _scheduleOpDays.contains(d.$1);
            return FilterChip(
              selected: selected,
              onSelected: (_) {
                setState(() {
                  if (selected) {
                    if (_scheduleOpDays.length > 1) {
                      _scheduleOpDays =
                          _scheduleOpDays.where((x) => x != d.$1).toList();
                    }
                  } else {
                    _scheduleOpDays = [..._scheduleOpDays, d.$1]..sort();
                  }
                });
              },
              label: Text(d.$2),
              backgroundColor: _surface,
              selectedColor: _deep,
              checkmarkColor: _accent,
              labelStyle: TextStyle(
                color: selected ? Colors.white : _text,
                fontWeight: FontWeight.w800,
              ),
              side: BorderSide(color: selected ? _deep : _line),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text(
          'Min slot duration',
          style: TextStyle(
            color: _text,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        _SegmentedOptions(
          value: _slotMins.toString(),
          options: _isGround
              ? const [
                  ('240', '4 hr'),
                  ('480', '8 hr'),
                  ('600', 'Full day'),
                ]
              : const [
                  ('30', '30 min'),
                  ('60', '1 hr'),
                  ('90', '1.5 hr'),
                  ('120', '2 hr'),
                ],
          onChanged: (v) => setState(() {
            _slotMins = int.parse(v);
            // clamp breather so it fits in available window
          }),
        ),
        if (_isGround) ...[
          const SizedBox(height: 20),
          const Text(
            'Turnaround between sessions',
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Extra gap after each session before the next can start',
            style: TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          _SegmentedOptions(
            value: _breatherMins.toString(),
            options: const [
              ('0', 'None'),
              ('15', '15 min'),
              ('30', '30 min'),
              ('45', '45 min'),
              ('60', '1 hr'),
            ],
            onChanged: (v) => setState(() => _breatherMins = int.parse(v)),
          ),
          const SizedBox(height: 20),
          _SlotPreview(
            openCtrl: _openTimeCtrl,
            closeCtrl: _closeTimeCtrl,
            slotMins: _slotMins,
            breatherMins: _breatherMins,
          ),
        ],
      ],
    );
  }

  Widget _pricingStep() {
    List<(String, int)> weekendRows() {
      if (_weekendMultiplier == 1.0) return [];
      final rows = <(String, int)>[];
      void add(String label, String raw) {
        final v = double.tryParse(raw.trim()) ?? 0;
        if (v > 0) rows.add((label, (v * _weekendMultiplier * 100).round()));
      }
      if (_isGround) {
        add('4 hr', _price4Ctrl.text);
        add('8 hr', _price8Ctrl.text);
        add('Full day', _priceDayCtrl.text);
      } else {
        add('/hr', _priceHourCtrl.text);
        if (_showBulkPricing) {
          add('4 hr', _price4Ctrl.text);
          add('8 hr', _price8Ctrl.text);
          add('Full day', _priceDayCtrl.text);
        }
      }
      return rows;
    }

    final wkndRows = weekendRows();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LargeStepTitle('Pricing'),
        if (_isGround) ...[
          _SheetField(
            label: '4 hr (₹)',
            controller: _price4Ctrl,
            required: true,
            keyboardType: TextInputType.number,
          ),
          Row(
            children: [
              Expanded(
                child: _SheetField(
                  label: '8 hr (₹)',
                  controller: _price8Ctrl,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetField(
                  label: 'Full day (₹)',
                  controller: _priceDayCtrl,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ] else ...[
          _SheetField(
            label: 'Per hour (₹)',
            controller: _priceHourCtrl,
            required: true,
            keyboardType: TextInputType.number,
          ),
          GestureDetector(
            onTap: () => setState(() => _showBulkPricing = !_showBulkPricing),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(
                    'Bulk pricing',
                    style: TextStyle(
                      color: _showBulkPricing ? _accent : _muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showBulkPricing
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                    color: _muted,
                  ),
                ],
              ),
            ),
          ),
          if (_showBulkPricing) ...[
            Row(
              children: [
                Expanded(
                  child: _SheetField(
                    label: '4 hr (₹)',
                    controller: _price4Ctrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SheetField(
                    label: '8 hr (₹)',
                    controller: _price8Ctrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            _SheetField(
              label: 'Full day (₹)',
              controller: _priceDayCtrl,
              keyboardType: TextInputType.number,
            ),
          ],
        ],
        const SizedBox(height: 20),
        const Text(
          'Weekend pricing',
          style: TextStyle(
            color: _text,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        _SegmentedOptions(
          value: _weekendMultiplier == 1.0
              ? '1.0'
              : _weekendMultiplier.toString(),
          options: const [
            ('1.0', 'None'),
            ('1.25', '1.25×'),
            ('1.5', '1.5×'),
            ('2.0', '2×'),
          ],
          onChanged: (v) =>
              setState(() => _weekendMultiplier = double.parse(v)),
        ),
        if (wkndRows.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              for (final (label, paise) in wkndRows)
                Text(
                  'Weekend $label: ${_money(paise)}',
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        const Text(
          'Booking advance',
          style: TextStyle(
            color: _text,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Minimum amount customer must pay when booking',
          style: TextStyle(color: _muted, fontSize: 12),
        ),
        const SizedBox(height: 10),
        _SheetField(
          label: 'Min advance (₹)  ·  leave blank = no advance',
          controller: _minAdvanceCtrl,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _photosAndAddonsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LargeStepTitle('Photos'),
        _UnitPhotoPicker(
          photos: _photos,
          uploading: _uploading,
          onAdd: _pickPhotos,
          onRemove: (url) =>
              setState(() => _photos = _photos.where((u) => u != url).toList()),
        ),
        const SizedBox(height: 20),
        const _LargeStepTitle('Add-ons'),
        for (final (type, name) in _kStandardAddons)
          _AddonToggleTile(
            label: name,
            enabled: _stdAddonEnabled[type] ?? false,
            priceController: _stdAddonPrice[type]!,
            onToggle: (val) => setState(() => _stdAddonEnabled[type] = val),
          ),
        if (_addons.isNotEmpty) ...[
          const SizedBox(height: 4),
          for (var i = 0; i < _addons.length; i++)
            _AddonEditor(
              draft: _addons[i],
              onRemove: () {
                final removed = _addons.removeAt(i);
                removed.dispose();
                setState(() {});
              },
            ),
        ],
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: () => setState(() => _addons.add(_AddonDraft())),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Custom add-on'),
        ),
      ],
    );
  }
}

// ─── Slot preview widget ──────────────────────────────────────────────────────

class _SlotPreview extends StatefulWidget {
  const _SlotPreview({
    required this.openCtrl,
    required this.closeCtrl,
    required this.slotMins,
    required this.breatherMins,
  });

  final TextEditingController openCtrl;
  final TextEditingController closeCtrl;
  final int slotMins;
  final int breatherMins;

  @override
  State<_SlotPreview> createState() => _SlotPreviewState();
}

class _SlotPreviewState extends State<_SlotPreview> {
  @override
  void initState() {
    super.initState();
    widget.openCtrl.addListener(_rebuild);
    widget.closeCtrl.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.openCtrl.removeListener(_rebuild);
    widget.closeCtrl.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  List<String> _computeSlots() {
    final openTime = widget.openCtrl.text.trim();
    final closeTime = widget.closeCtrl.text.trim();
    if (openTime.isEmpty || closeTime.isEmpty) return const [];
    int parseTime(String t) {
      final parts = t.split(':');
      if (parts.length < 2) return -1;
      final h = int.tryParse(parts[0]) ?? -1;
      final m = int.tryParse(parts[1]) ?? -1;
      if (h < 0 || m < 0) return -1;
      return h * 60 + m;
    }
    final openMins = parseTime(openTime);
    final closeMins = parseTime(closeTime);
    if (openMins < 0 || closeMins < 0 || closeMins <= openMins) return const [];
    final step = widget.slotMins + widget.breatherMins;
    if (step <= 0) return const [];
    final slots = <String>[];
    var start = openMins;
    while (start + widget.slotMins <= closeMins) {
      String fmt(int total) {
        final h = total ~/ 60;
        final m = total % 60;
        final suffix = h < 12 ? 'am' : 'pm';
        final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
        return m == 0 ? '$h12$suffix' : '$h12:${m.toString().padLeft(2, '0')}$suffix';
      }
      slots.add('${fmt(start)} – ${fmt(start + widget.slotMins)}');
      start += step;
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final slots = _computeSlots();
    if (slots.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Slot preview · ${slots.length} session${slots.length == 1 ? '' : 's'}',
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _deep.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _deep.withOpacity(0.2)),
            ),
            child: Text(
              s,
              style: const TextStyle(
                color: _deep,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  const _StepDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (index) {
        final active = index <= activeIndex;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == count - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: active ? _deep : _line,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class _ParentUnitPicker extends ConsumerWidget {
  const _ParentUnitPicker({
    required this.arenaId,
    required this.selectedParentId,
    required this.onChanged,
    this.currentUnitId,
  });

  final String arenaId;
  final String? currentUnitId;
  final String? selectedParentId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arenasAsync = ref.watch(ownedArenasProvider);
    final arenas = arenasAsync.valueOrNull ?? [];
    final arena = arenas.cast<ArenaListing?>().firstWhere(
      (a) => a?.id == arenaId, orElse: () => null,
    );
    final grounds = (arena?.units ?? [])
        .where((u) => u.unitType == 'FULL_GROUND' && u.id != currentUnitId)
        .toList();

    if (grounds.isEmpty) {
      return const Text(
        'No Full ground units found. Add a Full ground unit first.',
        style: TextStyle(color: _muted, fontSize: 12),
      );
    }

    final options = <(String?, String)>[
      (null, 'None — standalone unit'),
      ...grounds.map((g) => (g.id, g.name)),
    ];

    return Column(
      children: options.map((opt) {
        final selected = selectedParentId == opt.$1;
        return GestureDetector(
          onTap: () => onChanged(opt.$1),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? _accent : _line,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(children: [
              Expanded(
                child: Text(
                  opt.$2,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? _accent : _text,
                  ),
                ),
              ),
              if (selected) Icon(Icons.check_circle_rounded, size: 18, color: _accent),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

class _LargeStepTitle extends StatelessWidget {
  const _LargeStepTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          color: _text,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SegmentedOptions extends StatelessWidget {
  const _SegmentedOptions({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<(String, String)> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final selected = option.$1 == value;
        return ChoiceChip(
          selected: selected,
          onSelected: (_) => onChanged(option.$1),
          label: Text(option.$2),
          backgroundColor: _surface,
          selectedColor: _deep,
          checkmarkColor: _accent,
          labelStyle: TextStyle(
            color: selected ? Colors.white : _text,
            fontWeight: FontWeight.w800,
          ),
          side: BorderSide(color: selected ? _deep : _line),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
      }).toList(),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: required
            ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: _surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          border: _inputBorder(_line),
          enabledBorder: _inputBorder(_line),
          focusedBorder: _inputBorder(_accent),
          errorBorder: _inputBorder(const Color(0xFFD92D20)),
          focusedErrorBorder: _inputBorder(const Color(0xFFD92D20)),
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  Future<void> _pick(BuildContext context) async {
    final parts = controller.text.trim().split(':');
    final initHour =
        (parts.length == 2 ? (int.tryParse(parts[0]) ?? 9) : 9).clamp(0, 23);
    final initMin =
        (parts.length == 2 ? (int.tryParse(parts[1]) ?? 0) : 0).clamp(0, 59);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TimeWheelSheet(
        initialHour: initHour,
        initialMinute: initMin,
        onPicked: (h, m) {
          controller.text =
              '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, val, _) {
        final hasValue = val.text.isNotEmpty;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => _pick(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: hasValue ? _deep : _line),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 16,
                      color: hasValue ? _deep : _muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(label,
                        style: const TextStyle(
                            color: _muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                  Text(
                    hasValue ? val.text : '--:--',
                    style: TextStyle(
                      color: hasValue ? _text : _muted,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.expand_more_rounded,
                      size: 18,
                      color: hasValue ? _deep : _muted),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Time wheel bottom sheet ──────────────────────────────────────────────────

class _TimeWheelSheet extends StatefulWidget {
  const _TimeWheelSheet({
    required this.initialHour,
    required this.initialMinute,
    required this.onPicked,
  });

  final int initialHour;
  final int initialMinute;
  final void Function(int hour, int minute) onPicked;

  @override
  State<_TimeWheelSheet> createState() => _TimeWheelSheetState();
}

class _TimeWheelSheetState extends State<_TimeWheelSheet> {
  late int _hour;
  late int _minute;
  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minCtrl;

  static final _mins = List.generate(12, (i) => i * 5);

  int _nearestMinute(int raw) =>
      _mins.reduce((a, b) => (a - raw).abs() <= (b - raw).abs() ? a : b);

  @override
  void initState() {
    super.initState();
    _hour = widget.initialHour;
    _minute = _nearestMinute(widget.initialMinute);
    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minCtrl =
        FixedExtentScrollController(initialItem: _mins.indexOf(_minute));
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: _line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 8, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Select time',
                      style: TextStyle(
                          color: _text,
                          fontSize: 18,
                          fontWeight: FontWeight.w900)),
                ),
                TextButton(
                  onPressed: () {
                    widget.onPicked(_hour, _minute);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _accent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Done',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: _hourCtrl,
                        itemExtent: 52,
                        perspective: 0.002,
                        diameterRatio: 2.0,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) =>
                            setState(() => _hour = i),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 24,
                          builder: (_, i) {
                            final sel = _hour == i;
                            return Center(
                              child: Text(
                                i.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  color: sel ? _text : _muted,
                                  fontSize: sel ? 28 : 22,
                                  fontWeight: sel
                                      ? FontWeight.w900
                                      : FontWeight.w400,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const Text(':',
                        style: TextStyle(
                            color: _text,
                            fontSize: 28,
                            fontWeight: FontWeight.w900)),
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: _minCtrl,
                        itemExtent: 52,
                        perspective: 0.002,
                        diameterRatio: 2.0,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) =>
                            setState(() => _minute = _mins[i]),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: _mins.length,
                          builder: (_, i) {
                            final sel = _minute == _mins[i];
                            return Center(
                              child: Text(
                                _mins[i].toString().padLeft(2, '0'),
                                style: TextStyle(
                                  color: sel ? _text : _muted,
                                  fontSize: sel ? 28 : 22,
                                  fontWeight: sel
                                      ? FontWeight.w900
                                      : FontWeight.w400,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SafeArea(
            top: false,
            child: SizedBox(height: 12),
          ),
        ],
      ),
    );
  }
}

class _UnitPhotoPicker extends StatelessWidget {
  const _UnitPhotoPicker({
    required this.photos,
    required this.uploading,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> photos;
  final bool uploading;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      children: [
        Row(
          children: [
            Expanded(child: _SectionLabel('Photos (${photos.length}/3)')),
            TextButton.icon(
              onPressed: uploading || photos.length >= 3 ? null : onAdd,
              icon: uploading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_rounded),
              label: const Text('Upload'),
            ),
          ],
        ),
        if (photos.isEmpty)
          const _StaticText('Add up to 3 photos for this unit.')
        else
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final url = photos[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 120,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 120,
                          height: 96,
                          color: _line,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: InkWell(
                        onTap: () => onRemove(url),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'How many?',
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        IconButton(
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_rounded),
          color: _text,
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _text,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ),
        IconButton(
          onPressed: value < 20 ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_rounded),
          color: _text,
        ),
      ],
    );
  }
}

class _AddonToggleTile extends StatelessWidget {
  const _AddonToggleTile({
    required this.label,
    required this.enabled,
    required this.priceController,
    required this.onToggle,
  });

  final String label;
  final bool enabled;
  final TextEditingController priceController;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeThumbColor: _accent,
              ),
            ],
          ),
          if (enabled)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _SheetField(
                label: 'Price (₹)',
                controller: priceController,
                keyboardType: TextInputType.number,
              ),
            ),
        ],
      ),
    );
  }
}

class _AddonEditor extends StatelessWidget {
  const _AddonEditor({required this.draft, required this.onRemove});

  final _AddonDraft draft;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _Panel(
        children: [
          Row(
            children: [
              const Expanded(child: _SectionLabel('Addon')),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          _SheetField(label: 'Name', controller: draft.name, required: true),
          Row(
            children: [
              Expanded(
                child: _SheetField(label: 'Type', controller: draft.addonType),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SheetField(
                  label: 'Charge',
                  controller: draft.price,
                  required: true,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          _SheetField(label: 'Unit', controller: draft.unit),
          _SheetField(
            label: 'Description',
            controller: draft.description,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _AddonDraft {
  _AddonDraft({
    this.id,
    String name = '',
    String addonType = '',
    String description = '',
    String price = '',
    String unit = 'per_session',
  })  : name = TextEditingController(text: name),
        addonType = TextEditingController(text: addonType),
        description = TextEditingController(text: description),
        price = TextEditingController(text: price),
        unit = TextEditingController(text: unit);

  factory _AddonDraft.fromAddon(ArenaAddon addon) {
    return _AddonDraft(
      id: addon.id,
      name: addon.name,
      addonType: addon.addonType ?? '',
      description: addon.description,
      price: _rupeesText(addon.pricePaise),
      unit: addon.unit,
    );
  }

  final String? id;
  final TextEditingController name;
  final TextEditingController addonType;
  final TextEditingController description;
  final TextEditingController price;
  final TextEditingController unit;

  void dispose() {
    name.dispose();
    addonType.dispose();
    description.dispose();
    price.dispose();
    unit.dispose();
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.photoUrls,
    required this.editing,
    required this.uploading,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> photoUrls;
  final bool editing;
  final bool uploading;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      children: [
        Row(
          children: [
            const Expanded(child: _SectionLabel('Photos')),
            if (editing)
              TextButton.icon(
                onPressed: uploading ? null : onAdd,
                icon: uploading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_rounded),
                label: const Text('Upload'),
              ),
          ],
        ),
        if (photoUrls.isEmpty)
          const _StaticText('No arena photos yet.')
        else
          SizedBox(
            height: 116,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photoUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final url = photoUrls[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 140,
                        height: 116,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 140,
                          height: 116,
                          color: _line,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                    if (editing)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () => onRemove(url),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.items, required this.editing});

  final List<_EditableFeatureItem> items;
  final bool editing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: editing ? () => item.onChanged(!item.enabled) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: item.enabled ? _deep : _surface,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: item.enabled ? _deep : _line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.enabled
                          ? Icons.check_circle_rounded
                          : Icons.remove_circle_outline_rounded,
                      size: 16,
                      color: item.enabled ? Colors.white70 : _muted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: item.enabled ? Colors.white : _text,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EditableFeatureItem {
  const _EditableFeatureItem(this.label, this.enabled, this.onChanged);

  final String label;
  final bool enabled;
  final ValueChanged<bool> onChanged;
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: _muted,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _StaticText extends StatelessWidget {
  const _StaticText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _muted,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.45,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Could not load arena.\n$message',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Arena details are not available yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted),
        ),
      ),
    );
  }
}

// ─── Helper functions ────────────────────────────────────────────────────────

OutlineInputBorder _inputBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );
}

String _fallback(String? value) {
  final safe = value?.trim() ?? '';
  return safe.isEmpty ? 'Not set' : safe;
}

String? _emptyToNull(String value) {
  final safe = value.trim();
  return safe.isEmpty ? null : safe;
}

int _intValue(String value) => int.tryParse(value.trim()) ?? 0;

double? _parseDouble(String value) {
  final safe = value.trim();
  if (safe.isEmpty) return null;
  return double.tryParse(safe);
}

String _joinNonEmpty(List<String?> values, {String separator = ' • '}) {
  return values
      .where((v) => v != null && v.trim().isNotEmpty)
      .map((v) => v!.trim())
      .join(separator);
}

String _labelForType(String type) {
  return switch (type) {
    'FULL_GROUND' => 'Full ground',
    'HALF_GROUND' => 'Half ground',
    'CRICKET_NET' => 'Net',
    'INDOOR_NET' => 'Indoor net',
    'CENTER_WICKET' => 'Center wicket',
    'TURF' => 'Turf',
    'MULTI_SPORT' => 'Multi sport',
    _ => 'Other',
  };
}

String _rupeesText(int? paise) {
  if (paise == null || paise == 0) return '';
  final rupees = paise / 100;
  if (rupees == rupees.roundToDouble()) return '${rupees.round()}';
  return rupees.toStringAsFixed(2);
}

int _rupeesToPaise(String value) {
  final amount = double.tryParse(value.trim()) ?? 0;
  return (amount * 100).round();
}

int? _optionalRupeesToPaise(String value) {
  final safe = value.trim();
  if (safe.isEmpty) return null;
  return _rupeesToPaise(safe);
}

String _money(int paise) {
  final rupees = paise / 100;
  if (rupees == rupees.roundToDouble()) return 'Rs ${rupees.round()}';
  return 'Rs ${rupees.toStringAsFixed(2)}';
}
