import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

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

void _arenaUploadLog(String message, [Object? error, StackTrace? stackTrace]) {
  if (!kDebugMode) return;
  if (error != null) debugPrint('[arena-profile-upload] error=$error');
  if (stackTrace != null) {
    debugPrint('[arena-profile-upload] stack=$stackTrace');
  }
}

// ─── Page ────────────────────────────────────────────────────────────────────

class ArenaProfilePage extends ConsumerStatefulWidget {
  const ArenaProfilePage({super.key, this.arenaId, this.startEditing = false});

  final String? arenaId;
  final bool startEditing;

  @override
  ConsumerState<ArenaProfilePage> createState() => _ArenaProfilePageState();
}

class _ArenaProfilePageState extends ConsumerState<ArenaProfilePage> {
  Future<List<String>> _pickAndUploadUnitPhotos({
    required String folder,
    required int remainingSlots,
  }) async {
    _arenaUploadLog(
        'unit picker requested folder=$folder remainingSlots=$remainingSlots');
    if (remainingSlots <= 0) return const [];
    final files = await ImagePicker().pickMultiImage();
    _arenaUploadLog('unit picker returned ${files.length} file(s)');
    if (files.isEmpty) return const [];

    final uploads = <String>[];
    for (final file in files.take(remainingSlots)) {
      _arenaUploadLog(
          'unit compress start name=${file.name} path=${file.path}');
      final compressedFile = await ImageCompressor.compress(file.path);
      if (compressedFile == null) {
        _arenaUploadLog('unit compression returned null for ${file.name}');
        continue;
      }
      final compressedSize = await compressedFile.length();
      _arenaUploadLog(
          'unit compress done original=${file.path} compressed=${compressedFile.path} size=$compressedSize');

      final form = FormData.fromMap({
        'folder': folder,
        'file': await MultipartFile.fromFile(compressedFile.path,
            filename: '${p.basenameWithoutExtension(file.name)}.jpg'),
      });
      _arenaUploadLog(
        'unit upload request baseUrl=${ApiClient.instance.dio.options.baseUrl} folder=$folder filename=${p.basenameWithoutExtension(file.name)}.jpg size=$compressedSize',
      );
      final response = await ApiClient.instance.dio.post(
        '/media/upload',
        data: form,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
        onSendProgress: (sent, total) =>
            _arenaUploadLog('unit upload progress sent=$sent total=$total'),
      );
      _arenaUploadLog(
          'unit upload response status=${response.statusCode} data=${response.data}');
      final payload = response.data as Map<String, dynamic>;
      final data = (payload['data'] ?? payload) as Map<String, dynamic>;
      final url = (data['publicUrl'] ?? data['url'] ?? data['link']) as String?;
      _arenaUploadLog('unit upload extracted url=$url');
      if (url != null && url.isNotEmpty) uploads.add(url);
    }
    _arenaUploadLog('unit upload finished count=${uploads.length}');
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

  bool _didAutoOpenSheet = false;

  void _openArenaDetailSheet(ArenaListing arena, {bool startEditing = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _bg,
      builder: (_) =>
          _ArenaDetailSheet(arena: arena, startEditing: startEditing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arenaAsync = widget.arenaId == null
        ? ref.watch(arenaDetailProvider)
        : ref.watch(arenaDetailByIdProvider(widget.arenaId!));

    if (widget.startEditing && !_didAutoOpenSheet) {
      arenaAsync.whenData((arena) {
        if (arena != null) {
          _didAutoOpenSheet = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _openArenaDetailSheet(arena, startEditing: true);
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: _bg,
      body: arenaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(message: '$error'),
        data: (arena) {
          if (arena == null) return const _EmptyState();
          final loc = _joinNonEmpty([arena.city, arena.state]);
          return CustomScrollView(
            slivers: [
              // ── AppBar with arena name ──────────────────────────────────
              SliverAppBar(
                backgroundColor: _bg,
                foregroundColor: _text,
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 1,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: _text),
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.dashboard),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      arena.name,
                      style: const TextStyle(
                          color: _text,
                          fontSize: 17,
                          fontWeight: FontWeight.w900),
                    ),
                    if (loc.isNotEmpty)
                      Text(
                        loc,
                        style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
                actions: [
                  TextButton.icon(
                    onPressed: () => _openArenaDetailSheet(arena),
                    icon: const Icon(Icons.tune_rounded, size: 15),
                    label: const Text('Arena'),
                    style: TextButton.styleFrom(
                      foregroundColor: _muted,
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),

              // ── Arena quick-info strip ──────────────────────────────────
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () => _openArenaDetailSheet(arena),
                  child: Container(
                    color: _surface,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 14, color: _muted),
                        const SizedBox(width: 5),
                        Text('${arena.openTime} – ${arena.closeTime}',
                            style: const TextStyle(
                                color: _muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        if (arena.sports.isNotEmpty) ...[
                          const SizedBox(width: 14),
                          const Icon(Icons.sports_cricket_rounded,
                              size: 14, color: _muted),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              arena.sports
                                  .map((s) =>
                                      s[0].toUpperCase() +
                                      s.substring(1).toLowerCase())
                                  .join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: _muted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ] else
                          const Spacer(),
                        const Icon(Icons.chevron_right_rounded,
                            size: 16, color: _muted),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Section header ──────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Units',
                                style: TextStyle(
                                    color: _text,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900)),
                            SizedBox(height: 2),
                            Text('Courts, nets, or spaces inside this arena',
                                style: TextStyle(
                                    color: _muted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _openUnitSheet(arena),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Unit'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _deep,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Units list or empty state ───────────────────────────────
              if (arena.units.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_box_outlined,
                            size: 52, color: _muted),
                        const SizedBox(height: 16),
                        const Text('No units yet',
                            style: TextStyle(
                                color: _text,
                                fontSize: 18,
                                fontWeight: FontWeight.w800),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        const Text(
                          'Add your first unit — a cricket net, full ground, or any bookable space.',
                          style: TextStyle(
                              color: _muted, fontSize: 14, height: 1.6),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        FilledButton.icon(
                          onPressed: () => _openUnitSheet(arena),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Unit'),
                          style: FilledButton.styleFrom(
                            backgroundColor: _deep,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
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

// ─── Arena detail bottom sheet ───────────────────────────────────────────────

class _ArenaDetailSheet extends ConsumerStatefulWidget {
  const _ArenaDetailSheet({required this.arena, this.startEditing = false});

  final ArenaListing arena;
  final bool startEditing;

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
  List<int> _operatingDays = const [];
  List<String> _photoUrls = const [];
  List<String> _sports = const [];

  @override
  void initState() {
    super.initState();
    _editing = widget.startEditing;
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
    if (_photoUrls.length >= 3) return;
    _arenaUploadLog('arena picker requested arenaId=${widget.arena.id}');
    final files = await ImagePicker().pickMultiImage();
    _arenaUploadLog('arena picker returned ${files.length} file(s)');
    if (files.isEmpty) return;
    setState(() => _uploading = true);
    try {
      final uploads = <String>[];
      for (final file in files) {
        _arenaUploadLog(
            'arena compress start name=${file.name} path=${file.path}');
        final compressedFile = await ImageCompressor.compress(file.path);
        if (compressedFile == null) {
          _arenaUploadLog('arena compression returned null for ${file.name}');
          continue;
        }
        final compressedSize = await compressedFile.length();
        _arenaUploadLog(
            'arena compress done original=${file.path} compressed=${compressedFile.path} size=$compressedSize');

        final form = FormData.fromMap({
          'folder': 'arenas/${widget.arena.id}',
          'file': await MultipartFile.fromFile(compressedFile.path,
              filename: '${p.basenameWithoutExtension(file.name)}.jpg'),
        });
        _arenaUploadLog(
          'arena upload request baseUrl=${ApiClient.instance.dio.options.baseUrl} folder=arenas/${widget.arena.id} filename=${p.basenameWithoutExtension(file.name)}.jpg size=$compressedSize',
        );
        final response = await ApiClient.instance.dio.post(
          '/media/upload',
          data: form,
          options: Options(
            contentType: 'multipart/form-data',
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
          onSendProgress: (sent, total) =>
              _arenaUploadLog('arena upload progress sent=$sent total=$total'),
        );
        _arenaUploadLog(
            'arena upload response status=${response.statusCode} data=${response.data}');
        final payload = response.data as Map<String, dynamic>;
        final data = (payload['data'] ?? payload) as Map<String, dynamic>;
        final url =
            (data['publicUrl'] ?? data['url'] ?? data['link']) as String?;
        _arenaUploadLog('arena upload extracted url=$url');
        if (url != null && url.isNotEmpty) uploads.add(url);
      }
      _arenaUploadLog('arena upload finished count=${uploads.length}');
      if (!mounted || uploads.isEmpty) {
        _arenaUploadLog('arena upload produced no urls mounted=$mounted');
        return;
      }
      setState(() => _photoUrls = [..._photoUrls, ...uploads].take(3).toList());
      _arenaUploadLog('arena local photoUrls count=${_photoUrls.length}');
    } catch (error) {
      if (!mounted) return;
      String msg = error.toString();
      if (error is DioException) {
        msg = error.response?.data?['message'] ?? error.message ?? msg;
        _arenaUploadLog(
          'arena upload dio failure type=${error.type} status=${error.response?.statusCode} response=${error.response?.data}',
          error,
          error.stackTrace,
        );
      } else {
        _arenaUploadLog('arena upload failure', error);
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
      final input = {
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
      };
      _arenaUploadLog(
          'save arena request arenaId=${widget.arena.id} photoUrls=${_photoUrls.length} input=$input');
      final updated = await ref
          .read(hostArenaBookingRepositoryProvider)
          .updateArena(widget.arena.id, input);
      _arenaUploadLog(
          'save arena response photoUrls=${updated.photoUrls.length} first=${updated.photoUrls.isEmpty ? null : updated.photoUrls.first}');
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
    const tabs = ['Details', 'Location', 'Photos', 'Facilities', 'Share'];
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        minChildSize: 0.6,
        maxChildSize: 0.96,
        builder: (ctx, controller) => DefaultTabController(
          length: tabs.length,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Drag handle
                const SizedBox(height: 10),
                Center(
                    child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                            color: _line,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 14),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Arena Details',
                          style: TextStyle(
                              color: _text,
                              fontSize: 19,
                              fontWeight: FontWeight.w900),
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
                      const SizedBox(width: 4),
                      IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Tab bar
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: _deep,
                  unselectedLabelColor: _muted,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  indicatorColor: _deep,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: _line,
                  tabs: tabs.map((t) => Tab(text: t)).toList(),
                ),
                // Tab content
                Expanded(
                  child: TabBarView(
                    children: [
                      _DetailsTab(parent: this, scrollCtrl: controller),
                      _LocationTab(parent: this, scrollCtrl: controller),
                      _PhotosTab(parent: this, scrollCtrl: controller),
                      _FacilitiesTab(parent: this, scrollCtrl: controller),
                      _ShareTab(arena: widget.arena),
                    ],
                  ),
                ),
                // Save bar
                if (_editing)
                  SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      decoration: const BoxDecoration(
                          color: _bg,
                          border: Border(top: BorderSide(color: _line))),
                      child: FilledButton(
                        onPressed: _saving ? null : _saveArena,
                        style: FilledButton.styleFrom(
                          backgroundColor: _deep,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Save Arena'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
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

  void rebuild(VoidCallback fn) => setState(fn);
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
    final variantLabel = unit.hasVariants
        ? unit.netVariants.map((v) => v.label).join(' / ')
        : unit.netType;
    final subtitle = _joinNonEmpty([
      title,
      variantLabel,
      '${unit.minSlotMins ~/ 60}h min',
    ]);
    final isGround =
        unit.unitType == 'FULL_GROUND' || unit.unitType == 'HALF_GROUND';
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
    final hasSchedule = unit.openTime != null && unit.closeTime != null;
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
        border: Border.all(
            color: highlight ? _accent.withValues(alpha: 0.3) : _line),
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
    this.unit,
  });

  final String arenaId;
  final ArenaUnitOption? unit;

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
  final _advanceBookingDaysCtrl = TextEditingController();
  final _unitCancellationHoursCtrl = TextEditingController();
  String _unitType = 'CRICKET_NET';
  List<_NetVariantDraft> _netVariants = [];
  int _slotMins = 60;
  int _breatherMins = 0;
  double _weekendMultiplier = 1.0;
  int _quantity = 1;
  bool _showBulkPricing = false;
  bool _hasFloodlights = false;
  bool _bulkEnabled = false;
  int _minBulkDays = 3;
  final _bulkRateCtrl = TextEditingController();
  bool _monthlyPassEnabled = false;
  final _monthlyPassRateCtrl = TextEditingController();
  List<int> _scheduleOpDays = const [];
  int _step = 0;
  bool _saving = false;
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
  bool get _canHaveParent => _unitType == 'HALF_GROUND';

  @override
  void initState() {
    super.initState();
    final unit = widget.unit;
    _unitType = unit?.unitType ?? 'CRICKET_NET';
    _parentUnitId = unit?.parentUnitId;
    _labelCtrl.text = unit?.unitTypeLabel ?? _labelForType(_unitType);
    _netVariants = unit?.netVariants.isNotEmpty == true
        ? unit!.netVariants.map(_NetVariantDraft.fromVariant).toList()
        : (unit?.netType != null ? [_NetVariantDraft(type: unit!.netType!.toUpperCase(), label: unit.netType!)] : []);
    _slotMins = unit?.minSlotMins ?? (_isGround ? 240 : 60);
    final increment = unit?.slotIncrementMins ?? _slotMins;
    _breatherMins = _isGround ? (increment - _slotMins).clamp(0, 60) : 0;
    _weekendMultiplier = unit?.weekendMultiplier ?? 1.0;
    _priceHourCtrl.text = _rupeesText(unit?.pricePerHourPaise);
    _price4Ctrl.text = _rupeesText(unit?.price4HrPaise);
    _price8Ctrl.text = _rupeesText(unit?.price8HrPaise);
    _priceDayCtrl.text = _rupeesText(unit?.priceFullDayPaise);
    _minAdvanceCtrl.text =
        unit?.minAdvancePaise != null && unit!.minAdvancePaise > 0
            ? (unit.minAdvancePaise / 100).toStringAsFixed(0)
            : '';
    _showBulkPricing = unit != null &&
        (unit.price4HrPaise != null ||
            unit.price8HrPaise != null ||
            unit.priceFullDayPaise != null);
    _bulkEnabled = unit != null && (unit.minBulkDays ?? 0) > 0;
    _minBulkDays = unit?.minBulkDays ?? 3;
    _bulkRateCtrl.text = unit?.bulkDayRatePaise != null
        ? (unit!.bulkDayRatePaise! ~/ 100).toString()
        : '';
    _monthlyPassEnabled = unit?.monthlyPassEnabled ?? false;
    _monthlyPassRateCtrl.text = unit?.monthlyPassRatePaise != null
        ? (unit!.monthlyPassRatePaise! ~/ 100).toString()
        : '';
    _openTimeCtrl.text = unit?.openTime ?? '';
    _closeTimeCtrl.text = unit?.closeTime ?? '';
    _hasFloodlights = unit?.hasFloodlights ?? false;
    _advanceBookingDaysCtrl.text = unit?.advanceBookingDays?.toString() ?? '';
    _unitCancellationHoursCtrl.text = unit?.cancellationHours?.toString() ?? '';
    _scheduleOpDays = unit?.operatingDays.isNotEmpty == true
        ? List<int>.from(unit!.operatingDays)
        : const [1, 2, 3, 4, 5, 6, 7];

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
      _advanceBookingDaysCtrl,
      _unitCancellationHoursCtrl,
      _bulkRateCtrl,
      _monthlyPassRateCtrl,
      ..._stdAddonPrice.values,
    ]) {
      ctrl.dispose();
    }
    for (final addon in _addons) {
      addon.dispose();
    }
    for (final v in _netVariants) {
      v.dispose();
    }
    super.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    if (_step < 4) setState(() => _step += 1);
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
          'netVariants': _unitType == 'CRICKET_NET' && _netVariants.isNotEmpty
              ? _netVariants.map((v) => v.toJson()).toList()
              : null,
          'hasFloodlights': _unitType == 'CRICKET_NET' && _netVariants.isNotEmpty
              ? _netVariants.any((v) => v.hasFloodlights)
              : _hasFloodlights,
          'sport': 'CRICKET',
          'pricePerHourPaise': _isGround
              ? (_rupeesToPaise(_price4Ctrl.text) ~/ 4)
              : _rupeesToPaise(_priceHourCtrl.text),
          'price4HrPaise': _isGround
              ? _rupeesToPaise(_price4Ctrl.text)
              : _optionalRupeesToPaise(_price4Ctrl.text),
          'price8HrPaise': _optionalRupeesToPaise(_price8Ctrl.text),
          'priceFullDayPaise': _optionalRupeesToPaise(_priceDayCtrl.text),
          'minBulkDays': _bulkEnabled && _minBulkDays > 0 ? _minBulkDays : null,
          'bulkDayRatePaise':
              _bulkEnabled && _bulkRateCtrl.text.trim().isNotEmpty
                  ? (int.tryParse(_bulkRateCtrl.text.trim()) ?? 0) * 100
                  : null,
          'monthlyPassEnabled': _monthlyPassEnabled,
          'monthlyPassRatePaise':
              _monthlyPassEnabled && _monthlyPassRateCtrl.text.trim().isNotEmpty
                  ? (int.tryParse(_monthlyPassRateCtrl.text.trim()) ?? 0) * 100
                  : null,
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
          if (_advanceBookingDaysCtrl.text.trim().isNotEmpty)
            'advanceBookingDays':
                int.tryParse(_advanceBookingDaysCtrl.text.trim()),
          if (_unitCancellationHoursCtrl.text.trim().isNotEmpty)
            'cancellationHours':
                int.tryParse(_unitCancellationHoursCtrl.text.trim()),
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
    final isLastStep = _step == 4;
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
                child: _StepDots(count: 5, activeIndex: _step),
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
                            onPressed: _saving ? null : _back,
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
                          onPressed: _saving
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
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
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
      3 => _bookingRulesStep(),
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
          ],
          onChanged: (value) {
            setState(() {
              _unitType = value;
              _labelCtrl.text = _labelForType(value);
              if (value != 'CRICKET_NET') {
                for (final v in _netVariants) { v.dispose(); }
                _netVariants = [];
              }
              _slotMins = value == 'FULL_GROUND' ? 240 : 60;
            });
          },
        ),
        if (_unitType == 'CRICKET_NET') ...[
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Surface types',
                  style: TextStyle(color: _text, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
              if (_netVariants.length < _NetVariantDraft._surfaceOptions.length)
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (final (t, l) in _NetVariantDraft._surfaceOptions) {
                        if (!_netVariants.any((v) => v.type == t)) {
                          _netVariants.add(_NetVariantDraft(type: t, label: l));
                        }
                      }
                    });
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text('Add all', style: TextStyle(color: _accent, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Multi-select surface chips
          Row(
            children: [
              for (final (t, l) in _NetVariantDraft._surfaceOptions) ...[
                if (t != _NetVariantDraft._surfaceOptions.first.$1) const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        final idx = _netVariants.indexWhere((v) => v.type == t);
                        if (idx >= 0) {
                          _netVariants[idx].dispose();
                          _netVariants.removeAt(idx);
                        } else {
                          _netVariants.add(_NetVariantDraft(type: t, label: l));
                        }
                      });
                    },
                    child: Builder(builder: (ctx) {
                      final selected = _netVariants.any((v) => v.type == t);
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? _accent : _surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: selected ? _accent : _line),
                        ),
                        alignment: Alignment.center,
                        child: Text(l, style: TextStyle(color: selected ? Colors.white : _text, fontWeight: FontWeight.w700, fontSize: 14)),
                      );
                    }),
                  ),
                ),
              ],
            ],
          ),
          // Config rows for selected variants
          if (_netVariants.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (var i = 0; i < _netVariants.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _NetVariantRow(
                draft: _netVariants[i],
                onRemove: () => setState(() { _netVariants[i].dispose(); _netVariants.removeAt(i); }),
                onChanged: () => setState(() {}),
              ),
            ],
          ],
        ],
        if (_canHaveParent) ...[
          const SizedBox(height: 20),
          const Text(
            'Part of ground',
            style: TextStyle(
                color: _text, fontWeight: FontWeight.w800, fontSize: 15),
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
        // Global floodlights only shown for non-net units or nets with no variants
        if (_unitType != 'CRICKET_NET' || _netVariants.isEmpty) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Floodlights', style: TextStyle(color: _text, fontWeight: FontWeight.w800, fontSize: 15)),
                    Text('Available for night play', style: TextStyle(color: _muted, fontSize: 12)),
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
        ],
        // Quantity only shown for non-net units (net variants handle count per type)
        if (!_editing && (_unitType != 'CRICKET_NET' || _netVariants.isEmpty)) ...[
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
          value:
              _weekendMultiplier == 1.0 ? '1.0' : _weekendMultiplier.toString(),
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
        const _SectionLabel('Bulk / Multi-Day Booking'),
        const SizedBox(height: 4),
        const Text(
          'Offer a special daily rate when customers book multiple consecutive days.',
          style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.5),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Offer bulk rate',
                style: TextStyle(
                    color: _text, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            Switch(
              value: _bulkEnabled,
              onChanged: (v) => setState(() => _bulkEnabled = v),
              activeThumbColor: _accent,
            ),
          ],
        ),
        if (_bulkEnabled) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Min days to unlock',
                  style: TextStyle(
                      color: _text, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: _minBulkDays > 2
                    ? () => setState(() => _minBulkDays--)
                    : null,
                icon: const Icon(Icons.remove_rounded),
                color: _text,
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '$_minBulkDays',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: _text, fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                onPressed: _minBulkDays < 30
                    ? () => setState(() => _minBulkDays++)
                    : null,
                icon: const Icon(Icons.add_rounded),
                color: _text,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bulkRateCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Rate per day (₹)',
              prefixText: '₹ ',
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _line)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _line)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _deep, width: 1.4)),
            ),
          ),
          const SizedBox(height: 8),
          Builder(builder: (context) {
            final bulkRate = int.tryParse(_bulkRateCtrl.text.trim()) ?? 0;
            if (bulkRate <= 0) return const SizedBox.shrink();
            final normalDay = _isGround
                ? ((_rupeesToPaise(_price4Ctrl.text) > 0
                        ? _rupeesToPaise(_price4Ctrl.text)
                        : _rupeesToPaise(_priceHourCtrl.text) * 4) /
                    100)
                : (_rupeesToPaise(_priceHourCtrl.text) / 100) * 8;
            final saving = normalDay.round() - bulkRate;
            if (saving <= 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.trending_down_rounded,
                    size: 16, color: _accent),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                  'Customer saves ₹$saving/day vs normal rate. Good for events & tournaments.',
                  style: const TextStyle(
                      color: _accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.4),
                )),
              ]),
            );
          }),
        ],
        // Monthly pass — nets only
        if (!_isGround) ...[
          const SizedBox(height: 24),
          const _SectionLabel('Monthly Pass'),
          const SizedBox(height: 4),
          const Text(
            'Let customers lock a recurring time slot for the whole month.',
            style: TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Offer monthly pass',
                  style: TextStyle(
                      color: _text, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              Switch(
                value: _monthlyPassEnabled,
                onChanged: (v) => setState(() => _monthlyPassEnabled = v),
                activeThumbColor: _accent,
              ),
            ],
          ),
          if (_monthlyPassEnabled) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _monthlyPassRateCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Pass rate (₹ / month)',
                prefixText: '₹ ',
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _line)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _line)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _deep, width: 1.4)),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _bookingRulesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LargeStepTitle('Booking Rules'),
        const Text(
          'Override arena defaults for this unit. Leave blank to inherit arena settings.',
          style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 24),
        _RuleCard(
          icon: Icons.payments_outlined,
          title: 'Advance payment',
          subtitle: 'Minimum amount a customer must pay at booking time',
          child: _SheetField(
            label: 'Min advance (₹)  ·  leave blank = no advance',
            controller: _minAdvanceCtrl,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 12),
        _RuleCard(
          icon: Icons.event_available_outlined,
          title: 'Advance booking window',
          subtitle: 'How many days ahead customers can book this unit',
          child: _SheetField(
            label: 'Days  (e.g. 30)',
            controller: _advanceBookingDaysCtrl,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 12),
        _RuleCard(
          icon: Icons.cancel_outlined,
          title: 'Cancellation window',
          subtitle: 'Minimum hours notice required to cancel without penalty',
          child: _SheetField(
            label: 'Hours  (e.g. 24)',
            controller: _unitCancellationHoursCtrl,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _photosAndAddonsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        return m == 0
            ? '$h12$suffix'
            : '$h12:${m.toString().padLeft(2, '0')}$suffix';
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
          children: slots
              .map((s) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _deep.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _deep.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(
                        color: _deep,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ─── Rule card ────────────────────────────────────────────────────────────────

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: _deep),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: _text,
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: _muted, fontSize: 12, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
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
          (a) => a?.id == arenaId,
          orElse: () => null,
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
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    size: 18, color: _accent),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: hasValue ? _deep : _line),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 16, color: hasValue ? _deep : _muted),
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
                      size: 18, color: hasValue ? _deep : _muted),
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
    _minCtrl = FixedExtentScrollController(initialItem: _mins.indexOf(_minute));
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Done',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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
                        onSelectedItemChanged: (i) => setState(() => _hour = i),
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
                                  fontWeight:
                                      sel ? FontWeight.w900 : FontWeight.w400,
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
                                  fontWeight:
                                      sel ? FontWeight.w900 : FontWeight.w400,
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
            'Total Units',
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

class _NetVariantRow extends StatelessWidget {
  const _NetVariantRow({required this.draft, required this.onRemove, required this.onChanged});

  final _NetVariantDraft draft;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: surface label
          Text(draft.label, style: const TextStyle(color: _text, fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            children: [
              // Count stepper
              const Text('Count', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: draft.count > 1 ? () { draft.count--; onChanged(); } : null,
                child: Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: _line)),
                  child: Icon(Icons.remove, size: 14, color: draft.count > 1 ? _text : _muted),
                ),
              ),
              const SizedBox(width: 8),
              Text('${draft.count}', style: const TextStyle(color: _text, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () { draft.count++; onChanged(); },
                child: Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: _line)),
                  child: const Icon(Icons.add, size: 14, color: _text),
                ),
              ),
              const SizedBox(width: 12),
              // Price field
              Expanded(
                child: TextFormField(
                  controller: draft.priceCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: _text, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Price/hr (optional)',
                    hintStyle: TextStyle(color: _muted, fontSize: 12),
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(color: _muted, fontSize: 13),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Floodlights toggle
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, size: 16, color: _muted),
              const SizedBox(width: 6),
              const Expanded(child: Text('Floodlights', style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w600))),
              SizedBox(
                height: 24,
                child: Switch(
                  value: draft.hasFloodlights,
                  onChanged: (v) { draft.hasFloodlights = v; onChanged(); },
                  activeThumbColor: _accent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetVariantDraft {
  _NetVariantDraft({
    this.type = 'TURF',
    this.label = 'Turf',
    this.count = 1,
    this.hasFloodlights = false,
    String price = '',
  }) : priceCtrl = TextEditingController(text: price);

  String type;
  String label;
  int count;
  bool hasFloodlights;
  final TextEditingController priceCtrl;

  static const _surfaceOptions = [
    ('TURF', 'Turf'),
    ('CEMENT', 'Cement'),
    ('MAT', 'Mat'),
  ];

  Map<String, dynamic> toJson() => {
    'type': type,
    'label': label,
    'count': count,
    'hasFloodlights': hasFloodlights,
    if (priceCtrl.text.trim().isNotEmpty)
      'pricePaise': (int.tryParse(priceCtrl.text.trim()) ?? 0) * 100,
  };

  factory _NetVariantDraft.fromVariant(NetVariant v) => _NetVariantDraft(
    type: v.type,
    label: v.label,
    count: v.count,
    hasFloodlights: v.hasFloodlights,
    price: v.pricePaise != null ? (v.pricePaise! ~/ 100).toString() : '',
  );

  void dispose() => priceCtrl.dispose();
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

// ─── Arena detail tab widgets ─────────────────────────────────────────────────

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.parent, required this.scrollCtrl});

  final _ArenaDetailSheetState parent;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final p = parent;
    final dayLabels = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        p._field('Name', p._nameCtrl, p._nameCtrl.text, required: true),
        p._field('Description', p._descriptionCtrl, p._descriptionCtrl.text,
            maxLines: 3),
        p._field('Phone', p._phoneCtrl, p._phoneCtrl.text,
            keyboardType: TextInputType.phone),
        // Sports — fixed, not editable after creation
        const _TabSectionLabel('Sports'),
        p._readRow(
            'Sports',
            p._sports.isEmpty
                ? 'Not set'
                : p._sports.map(_sportLabel).join(', ')),
        // Operating days
        const _TabSectionLabel('Operating Days'),
        if (!p._editing)
          p._readRow(
              'Days',
              p._operatingDays.isEmpty
                  ? 'Not set'
                  : p._operatingDays.map((d) => dayLabels[d]).join(', '))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int day = 1; day <= 7; day++)
                FilterChip(
                  label: Text(dayLabels[day]),
                  selected: p._operatingDays.contains(day),
                  onSelected: (v) {
                    p.rebuild(() {
                      if (v) {
                        p._operatingDays = [...p._operatingDays, day]..sort();
                      } else {
                        p._operatingDays =
                            p._operatingDays.where((d) => d != day).toList();
                      }
                    });
                  },
                  selectedColor: _accent.withValues(alpha: 0.15),
                  checkmarkColor: _accent,
                  side: BorderSide(
                      color: p._operatingDays.contains(day) ? _accent : _line),
                  labelStyle: TextStyle(
                    color: p._operatingDays.contains(day) ? _accent : _text,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  backgroundColor: _surface,
                ),
            ],
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _LocationTab extends StatelessWidget {
  const _LocationTab({required this.parent, required this.scrollCtrl});

  final _ArenaDetailSheetState parent;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final p = parent;
    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        p._field('Address', p._addressCtrl, p._addressCtrl.text,
            required: true, maxLines: 2),
        p._field('City', p._cityCtrl, p._cityCtrl.text, required: true),
        p._field('State', p._stateCtrl, p._stateCtrl.text, required: true),
        p._field('Pincode', p._pincodeCtrl, p._pincodeCtrl.text,
            keyboardType: TextInputType.number),
        const _TabSectionLabel('Coordinates (optional)'),
        p._field('Latitude', p._latitudeCtrl, p._latitudeCtrl.text,
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: true)),
        p._field('Longitude', p._longitudeCtrl, p._longitudeCtrl.text,
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: true)),
      ],
    );
  }
}

class _PhotosTab extends StatelessWidget {
  const _PhotosTab({required this.parent, required this.scrollCtrl});

  final _ArenaDetailSheetState parent;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final p = parent;
    final urls = p._photoUrls;
    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          'Photos (${urls.length}/3)',
          style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            for (int i = 0; i < urls.length; i++)
              Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(urls[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: _line)),
                  ),
                  if (p._editing)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => p.rebuild(() => p._photoUrls =
                            List<String>.from(urls)..removeAt(i)),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                ],
              ),
            if (p._editing && urls.length < 3)
              GestureDetector(
                onTap: p._uploading ? null : p._pickAndUploadPhotos,
                child: Container(
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _line, style: BorderStyle.solid),
                  ),
                  child: p._uploading
                      ? const Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)))
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_rounded,
                                color: _muted, size: 26),
                            SizedBox(height: 4),
                            Text('Add',
                                style: TextStyle(
                                    color: _muted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
              ),
          ],
        ),
        if (!p._editing && urls.isEmpty)
          Container(
            height: 100,
            decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _line)),
            child: const Center(
                child: Text('No photos added',
                    style: TextStyle(color: _muted, fontSize: 13))),
          ),
      ],
    );
  }
}

class _FacilitiesTab extends StatelessWidget {
  const _FacilitiesTab({required this.parent, required this.scrollCtrl});

  final _ArenaDetailSheetState parent;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final p = parent;
    final amenities = [
      (
        Icons.local_parking_rounded,
        'Parking',
        () => p._hasParking,
        (bool v) => p.rebuild(() => p._hasParking = v)
      ),
      (
        Icons.lightbulb_rounded,
        'Floodlights',
        () => p._hasLights,
        (bool v) => p.rebuild(() => p._hasLights = v)
      ),
      (
        Icons.wc_rounded,
        'Washrooms',
        () => p._hasWashrooms,
        (bool v) => p.rebuild(() => p._hasWashrooms = v)
      ),
      (
        Icons.restaurant_rounded,
        'Canteen / Food',
        () => p._hasCanteen,
        (bool v) => p.rebuild(() => p._hasCanteen = v)
      ),
      (
        Icons.videocam_rounded,
        'CCTV',
        () => p._hasCctv,
        (bool v) => p.rebuild(() => p._hasCctv = v)
      ),
      (
        Icons.scoreboard_rounded,
        'Scorer',
        () => p._hasScorer,
        (bool v) => p.rebuild(() => p._hasScorer = v)
      ),
    ];
    return ListView.separated(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: amenities.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: _line),
      itemBuilder: (_, i) {
        final (icon, label, getter, setter) = amenities[i];
        final enabled = getter();
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: enabled ? _accent.withValues(alpha: 0.1) : _bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: enabled ? _accent : _muted),
          ),
          title: Text(label,
              style: TextStyle(
                  color: enabled ? _text : _muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          trailing: p._editing
              ? Switch(
                  value: enabled,
                  onChanged: setter,
                  activeThumbColor: _accent,
                )
              : Icon(
                  enabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: enabled ? _accent : _line,
                  size: 20,
                ),
        );
      },
    );
  }
}

class _TabSectionLabel extends StatelessWidget {
  const _TabSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
            color: _muted,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8),
      ),
    );
  }
}

class _ShareTab extends ConsumerStatefulWidget {
  const _ShareTab({required this.arena});
  final ArenaListing arena;

  @override
  ConsumerState<_ShareTab> createState() => _ShareTabState();
}

class _ShareTabState extends ConsumerState<_ShareTab> {
  final _slugCtrl = TextEditingController();
  bool _saving = false;
  bool _saved = false;
  String? _customSlug;
  String? _citySlug;
  String? _arenaSlug;

  String get _publicUrl {
    final a = widget.arena;
    final customSlug = _customSlug?.trim();
    final citySlug = _citySlug?.trim();
    final arenaSlug = _arenaSlug?.trim();
    if (customSlug != null && customSlug.isNotEmpty) {
      return 'swingcricketapp.com/$customSlug';
    }
    if (citySlug != null &&
        citySlug.isNotEmpty &&
        arenaSlug != null &&
        arenaSlug.isNotEmpty) {
      return 'swingcricketapp.com/$citySlug/$arenaSlug';
    }
    return 'swingcricketapp.com/${_normaliseSlug(a.name)}';
  }

  String _normaliseSlug(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  @override
  void initState() {
    super.initState();
    _customSlug = widget.arena.customSlug;
    _citySlug = widget.arena.citySlug;
    _arenaSlug = widget.arena.arenaSlug;
    _slugCtrl.text = _customSlug ?? '';
  }

  @override
  void dispose() {
    _slugCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSlug() async {
    final rawSlug = _slugCtrl.text.trim();
    final slug = _normaliseSlug(rawSlug);
    if (rawSlug.isNotEmpty && slug.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Custom link must be at least 3 letters or numbers')),
      );
      return;
    }
    setState(() {
      _saving = true;
      _saved = false;
    });
    try {
      final updated =
          await ref.read(hostArenaBookingRepositoryProvider).updateArena(
        widget.arena.id,
        {'customSlug': slug.isEmpty ? null : slug},
      );
      ref.invalidate(arenaDetailProvider);
      ref.invalidate(arenaDetailByIdProvider(widget.arena.id));
      ref.invalidate(ownedArenasProvider);
      setState(() {
        _customSlug = updated.customSlug;
        _citySlug = updated.citySlug;
        _arenaSlug = updated.arenaSlug;
        _slugCtrl.text = updated.customSlug ?? '';
        _saved = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _saved = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: 'https://$_publicUrl'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Link copied!'), duration: Duration(seconds: 2)),
    );
  }

  void _shareLink() {
    Share.share('https://$_publicUrl', subject: widget.arena.name);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        // Public link display
        const _TabSectionLabel('Your Booking Link'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              const Icon(Icons.link_rounded, size: 16, color: _muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _publicUrl,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copyLink,
                icon: const Icon(Icons.copy_rounded, size: 15),
                label: const Text('Copy'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _text,
                  side: const BorderSide(color: _line),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: _shareLink,
                icon: const Icon(Icons.share_rounded, size: 15),
                label: const Text('Share'),
                style: FilledButton.styleFrom(
                  backgroundColor: _deep,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Custom slug
        const _TabSectionLabel('Custom Link'),
        const SizedBox(height: 4),
        const Text(
          'Set a short name so customers can remember your link easily.',
          style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.5),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Text(
                'swingcricketapp.com/',
                style: TextStyle(
                    color: _muted, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _slugCtrl,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: _text),
                decoration: InputDecoration(
                  hintText: 'your-arena-name',
                  hintStyle: const TextStyle(color: _muted, fontSize: 13),
                  filled: true,
                  fillColor: _surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _line)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _line)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _deep, width: 1.4)),
                ),
                onChanged: (value) => setState(() {
                  _saved = false;
                  _customSlug = _normaliseSlug(value);
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: _saving ? null : _saveSlug,
          style: FilledButton.styleFrom(
            backgroundColor: _saved ? Colors.green : _deep,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(_saved ? 'Saved!' : 'Save Custom Link',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

String _sportLabel(String sport) {
  return switch (sport) {
    'CRICKET' => 'Cricket',
    'FOOTBALL' => 'Football',
    'BADMINTON' => 'Badminton',
    'TENNIS' => 'Tennis',
    'BASKETBALL' => 'Basketball',
    'FUTSAL' => 'Futsal',
    'PICKLEBALL' => 'Pickleball',
    _ => 'Other',
  };
}

// ─────────────────────────────────────────────────────────────────────────────

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
