import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_client.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/image_compressor.dart';
import '../services/arena_profile_providers.dart';

// ─── Color palette (theme-driven) ────────────────────────────────────────────
class _C {
  const _C({
    required this.bg,
    required this.surface,
    required this.line,
    required this.text,
    required this.muted,
    required this.accent,
    required this.deep,
    required this.onAccent,
  });

  final Color bg;
  final Color surface;
  final Color line;
  final Color text;
  final Color muted;
  final Color accent;
  final Color deep;
  final Color onAccent;

  factory _C.of(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return _C(
      bg: s.surface,
      surface: s.surfaceContainerHighest,
      line: s.outline,
      text: s.onSurface,
      muted: s.onSurface.withValues(alpha: 0.6),
      accent: s.primary,
      deep: s.secondary,
      onAccent: s.onPrimary,
    );
  }
}

late _C _c;

// ─── Page ────────────────────────────────────────────────────────────────────

class ArenaProfilePage extends ConsumerWidget {
  const ArenaProfilePage({super.key, this.arenaId, this.startEditing = false});

  final String? arenaId;
  final bool startEditing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _c = _C.of(context);
    final arenaAsync = arenaId == null
        ? ref.watch(arenaDetailProvider)
        : ref.watch(arenaDetailByIdProvider(arenaId!));
    return arenaAsync.when(
      loading: () => Scaffold(
        backgroundColor: _c.bg,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: _c.bg,
        body: _ErrorState(message: '$e'),
      ),
      data: (arena) {
        if (arena == null) {
          return Scaffold(
            backgroundColor: _c.bg,
            body: const _EmptyState(),
          );
        }
        return ArenaDetailPage(
          arena: arena,
          startEditing: startEditing,
          initialTabIndex: startEditing ? 0 : 4,
        );
      },
    );
  }
}

// ─── Arena detail page ───────────────────────────────────────────────────────

class ArenaDetailPage extends ConsumerStatefulWidget {
  const ArenaDetailPage({
    super.key,
    required this.arena,
    this.startEditing = false,
    this.initialTabIndex = 0,
  });

  final ArenaListing arena;
  final bool startEditing;
  final int initialTabIndex;

  @override
  ConsumerState<ArenaDetailPage> createState() => _ArenaDetailPageState();
}

class _ArenaDetailPageState extends ConsumerState<ArenaDetailPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TabController _tabController;
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
    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 5),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
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
    _tabController.dispose();
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
    final files = await ImagePicker().pickMultiImage();
    if (files.isEmpty) return;
    setState(() => _uploading = true);
    try {
      final uploads = <String>[];
      for (final file in files) {
        final compressedFile = await ImageCompressor.compress(file.path);
        if (compressedFile == null) {
          continue;
        }

        final form = FormData.fromMap({
          'folder': 'arenas/${widget.arena.id}',
          'file': await MultipartFile.fromFile(compressedFile.path,
              filename: '${p.basenameWithoutExtension(file.name)}.jpg'),
        });
        final response = await ApiClient.instance.dio.post(
          '/media/upload',
          data: form,
          options: Options(
            contentType: 'multipart/form-data',
            sendTimeout: Duration(seconds: 30),
            receiveTimeout: Duration(seconds: 30),
          ),
        );
        final payload = response.data as Map<String, dynamic>;
        final data = (payload['data'] ?? payload) as Map<String, dynamic>;
        final url =
            (data['publicUrl'] ?? data['url'] ?? data['link']) as String?;
        if (url != null && url.isNotEmpty) uploads.add(url);
      }
      if (!mounted || uploads.isEmpty) {
        return;
      }
      setState(() => _photoUrls = [..._photoUrls, ...uploads].take(3).toList());
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
      final input = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'pincode': _pincodeCtrl.text.trim(),
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
      // Only include optional fields when they have a value — Zod rejects explicit null
      final desc = _emptyToNull(_descriptionCtrl.text);
      if (desc != null) input['description'] = desc;
      final phone = _emptyToNull(_phoneCtrl.text);
      if (phone != null) input['phone'] = phone;
      final lat = _parseDouble(_latitudeCtrl.text);
      if (lat != null) input['latitude'] = lat;
      final lng = _parseDouble(_longitudeCtrl.text);
      if (lng != null) input['longitude'] = lng;
      await ref
          .read(hostArenaBookingRepositoryProvider)
          .updateArena(widget.arena.id, input);
      ref.invalidate(arenaDetailProvider);
      ref.invalidate(arenaDetailByIdProvider);
      ref.invalidate(ownedArenasProvider);
      if (!mounted) return;
      setState(() => _editing = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Arena updated')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Update failed: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _arenaSubtitle {
    final a = widget.arena;
    final loc = [a.city, a.state].where((s) => s.trim().isNotEmpty).join(', ');
    final sports = a.sports
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
        .take(2)
        .join(', ');
    return [loc, sports].where((s) => s.isNotEmpty).join(' · ');
  }

  Future<void> _openUnitSheet(ArenaListing arena,
      [ArenaUnitOption? unit]) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _c.bg,
      builder: (context) =>
          UnitEditorSheet(arenaId: arena.id, unit: unit),
    );
    if (changed == true) {
      ref.invalidate(arenaDetailProvider);
      ref.invalidate(arenaDetailByIdProvider);
      ref.invalidate(ownedArenasProvider);
    }
  }

  Future<void> _deleteUnitOnDetail(ArenaUnitOption unit) async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded,
            color: scheme.error, size: 36),
        title: Text('Delete ${unit.name}?'),
        content: Text(
          'This unit will be permanently deleted. Existing bookings stay, but no new bookings can be made for it. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            child: Text('Delete'),
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
          .showSnackBar(SnackBar(content: Text('Unit removed')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Remove failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    const tabs = ['Details', 'Location', 'Photos', 'Facilities', 'Units', 'Site'];
    final onUnitsTab = _tabController.index == 4;
    return Scaffold(
      backgroundColor: _c.bg,
      appBar: AppBar(
        backgroundColor: _c.bg,
        surfaceTintColor: _c.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _c.text),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.arena.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _c.text,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            if (_arenaSubtitle.isNotEmpty)
              Text(
                _arenaSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _c.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        actions: [
          if (_editing)
            TextButton(
              onPressed: _saving
                  ? null
                  : () => setState(() {
                        _reset();
                        _editing = false;
                      }),
              child: Text('Cancel',
                  style: TextStyle(
                      color: _c.muted, fontWeight: FontWeight.w700)),
            )
          else if (!onUnitsTab)
            IconButton(
              tooltip: 'Edit',
              icon: Icon(Icons.edit_rounded, color: _c.text),
              onPressed: () => setState(() => _editing = true),
            ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            labelColor: _c.text,
            unselectedLabelColor: _c.muted,
            labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            unselectedLabelStyle:
                TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: _c.text, width: 2),
              insets: const EdgeInsets.symmetric(horizontal: 4),
            ),
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: _c.line,
            dividerHeight: 0.5,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            splashFactory: NoSplash.splashFactory,
            tabs: tabs.map((t) => Tab(height: 42, text: t)).toList(),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _DetailsTab(parent: this),
            _LocationTab(parent: this),
            _PhotosTab(parent: this),
            _FacilitiesTab(parent: this),
            _UnitsTab(parent: this),
            _ShareTab(arena: widget.arena),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(onUnitsTab: onUnitsTab),
    );
  }

  Widget? _buildBottomBar({required bool onUnitsTab}) {
    if (onUnitsTab) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () => _openUnitSheet(widget.arena),
              style: FilledButton.styleFrom(
                backgroundColor: _c.accent,
                foregroundColor: _c.onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 22),
              label: const Text(
                'Add Unit',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      );
    }
    if (!_editing) return null;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
            color: _c.bg, border: Border(top: BorderSide(color: _c.line))),
        child: FilledButton(
          onPressed: _saving ? null : _saveArena,
          style: FilledButton.styleFrom(
            backgroundColor: _c.accent,
            foregroundColor: _c.onAccent,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _saving
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _c.onAccent))
              : Text('Save Arena'),
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
          fillColor: _c.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          border: _inputBorder(_c.line),
          enabledBorder: _inputBorder(_c.line),
          focusedBorder: _inputBorder(_c.accent),
          errorBorder: _inputBorder(Theme.of(context).colorScheme.error),
          focusedErrorBorder: _inputBorder(Theme.of(context).colorScheme.error),
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
              style: TextStyle(
                color: _c.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              value.trim().isEmpty ? 'Not set' : value,
              style: TextStyle(
                color: _c.text,
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
    _c = _C.of(context);
    final typeLabel =
        _fallback(unit.unitTypeLabel).replaceAll('Not set', unit.unitType);
    final showTypeLabel =
        typeLabel.trim().toLowerCase() != unit.name.trim().toLowerCase();
    final hasSchedule = unit.openTime != null && unit.closeTime != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _c.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info section ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── name + type ────────────────────────────────────────
                  Text(
                    unit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _c.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (showTypeLabel) ...[
                    SizedBox(height: 3),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        color: _c.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  SizedBox(height: 12),
                  // ── icon info grid ─────────────────────────────────────
                  Wrap(
                    spacing: 14,
                    runSpacing: 8,
                    children: [
                      if (hasSchedule)
                        _UnitInfo(
                          icon: Icons.schedule_rounded,
                          label: '${unit.openTime}–${unit.closeTime}',
                        ),
                      if (unit.operatingDays.isNotEmpty)
                        _UnitInfo(
                          icon: Icons.calendar_today_rounded,
                          label: _formatDays(unit.operatingDays),
                        ),
                      if (unit.weekendMultiplier != 1)
                        _UnitInfo(
                          icon: Icons.trending_up_rounded,
                          label:
                              'Weekend ${_trimMultiplier(unit.weekendMultiplier)}×',
                        ),
                      if (unit.minAdvancePaise > 0)
                        _UnitInfo(
                          icon: Icons.payments_outlined,
                          label: '${_money(unit.minAdvancePaise)} advance',
                        ),
                      if (unit.advanceBookingDays != null &&
                          unit.advanceBookingDays! > 0)
                        _UnitInfo(
                          icon: Icons.event_rounded,
                          label:
                              '${unit.advanceBookingDays}d booking window',
                        ),
                      if (unit.cancellationHours != null &&
                          unit.cancellationHours! > 0)
                        _UnitInfo(
                          icon: Icons.cancel_outlined,
                          label: '${unit.cancellationHours}h cancel',
                        ),
                      if (unit.hasFloodlights)
                        const _UnitInfo(
                          icon: Icons.flare_rounded,
                          label: 'Floodlights',
                        ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onEdit,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _c.accent,
                            side: BorderSide(
                                color: _c.accent.withValues(alpha: 0.4)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _c.accent,
                            side: BorderSide(
                                color: _c.accent.withValues(alpha: 0.4)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Manage',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDelete,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                            side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .error
                                    .withValues(alpha: 0.4)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
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

String _formatDays(List<int> days) {
  if (days.isEmpty) return '';
  final sorted = [...days]..sort();
  if (sorted.length == 7) return 'Daily';
  const labels = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final isWeekdays = sorted.length == 5 &&
      sorted[0] == 1 &&
      sorted[1] == 2 &&
      sorted[2] == 3 &&
      sorted[3] == 4 &&
      sorted[4] == 5;
  if (isWeekdays) return 'Weekdays';
  final isWeekends =
      sorted.length == 2 && sorted[0] == 6 && sorted[1] == 7;
  if (isWeekends) return 'Weekends';
  return sorted.map((d) => (d >= 1 && d <= 7) ? labels[d] : '').join(', ');
}

String _trimMultiplier(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toStringAsFixed(1);
}

class _UnitInfo extends StatelessWidget {
  const _UnitInfo({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _c.muted),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: _c.text,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill(this.label, {this.highlight = false});

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? _c.accent.withValues(alpha: 0.08) : _c.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: highlight ? _c.accent.withValues(alpha: 0.3) : _c.line),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: highlight ? _c.accent : _c.text,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─── Unit editor sheet ───────────────────────────────────────────────────────

class UnitEditorSheet extends ConsumerStatefulWidget {
  UnitEditorSheet({
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
  bool _allDay = false;
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
  bool get _isNetsWithVariants => _unitType == 'CRICKET_NET' && _netVariants.isNotEmpty;
  int get _maxStep => 4;

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
    _allDay = unit?.openTime == '00:00' && (unit?.closeTime == '24:00' || unit?.closeTime == '23:59');
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

  String? _stepError() {
    if (_step == 0) return null;
    if (_step == 1) {
      if (_allDay) return null;
      final open = _openTimeCtrl.text.trim();
      final close = _closeTimeCtrl.text.trim();
      if (open.isEmpty || close.isEmpty) {
        return 'Pick both open and close times';
      }
      final reTime = RegExp(r'^\d{2}:\d{2}$');
      if (!reTime.hasMatch(open) || !reTime.hasMatch(close)) {
        return 'Use HH:MM format for open/close times';
      }
      int parse(String t) {
        final p = t.split(':');
        return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
      }

      final openMins = parse(open);
      var closeMins = parse(close);
      if (openMins == closeMins) {
        return 'Open and close cannot be the same';
      }
      if (closeMins < openMins) closeMins += 24 * 60; // overnight
      final step = _slotMins + (_isGround ? _breatherMins : 0);
      if (step <= 0) return null;
      if (closeMins - openMins < _slotMins) {
        return 'Window must be at least one slot long';
      }
      return null;
    }
    if (!_isNetsWithVariants && _step == 2) {
      if (_isGround) {
        if (_price4Ctrl.text.trim().isEmpty ||
            _rupeesToPaise(_price4Ctrl.text) <= 0) {
          return 'Set a 4 hr price to continue';
        }
        return null;
      }
      if (_priceHourCtrl.text.trim().isEmpty ||
          _rupeesToPaise(_priceHourCtrl.text) <= 0) {
        return 'Set a price per hour to continue';
      }
      return null;
    }
    return null;
  }

  bool _validateStep() => _stepError() == null;

  void _next() {
    final err = _stepError();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    if (_step < _maxStep) setState(() => _step += 1);
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
              : _isNetsWithVariants
                  ? (_netVariants.map((v) => (int.tryParse(v.priceCtrl.text.trim()) ?? 0) * 100).where((p) => p > 0).fold(0, (a, b) => a + b) ~/
                      (_netVariants.where((v) => v.priceCtrl.text.trim().isNotEmpty).length.clamp(1, 99)))
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
          // For nets: monthly pass is enabled if any variant has a rate set
          'monthlyPassEnabled': _isNetsWithVariants
              ? _netVariants.any((v) => v.monthlyPassRateCtrl.text.trim().isNotEmpty)
              : _monthlyPassEnabled,
          'monthlyPassRatePaise': _isNetsWithVariants
              ? null  // per-variant rates live inside netVariants JSON
              : (_monthlyPassEnabled && _monthlyPassRateCtrl.text.trim().isNotEmpty
                  ? (int.tryParse(_monthlyPassRateCtrl.text.trim()) ?? 0) * 100
                  : null),
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
    _c = _C.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final isLastStep = _step == _maxStep;
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
                        style: TextStyle(
                          color: _c.text,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context, false),
                      icon: Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: _StepDots(count: _maxStep + 1, activeIndex: _step),
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
                  decoration: BoxDecoration(
                    color: _c.bg,
                    border: Border(top: BorderSide(color: _c.line)),
                  ),
                  child: Row(
                    children: [
                      if (_step > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : _back,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _c.deep,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Back'),
                          ),
                        ),
                      if (_step > 0) SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _saving
                              ? null
                              : isLastStep
                                  ? _save
                                  : _next,
                          style: FilledButton.styleFrom(
                            backgroundColor: _c.accent,
                            foregroundColor: _c.onAccent,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _saving
                              ? SizedBox(
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
      2 => _isNetsWithVariants ? _netsPricingStep() : _pricingStep(),
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
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Surface types',
                  style: TextStyle(color: _c.text, fontWeight: FontWeight.w800, fontSize: 15),
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
                  child: Text('Add all', style: TextStyle(color: _c.accent, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          SizedBox(height: 10),
          // Multi-select surface chips
          Row(
            children: [
              for (final (t, l) in _NetVariantDraft._surfaceOptions) ...[
                if (t != _NetVariantDraft._surfaceOptions.first.$1) SizedBox(width: 8),
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
                          color: selected ? _c.accent : _c.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: selected ? _c.accent : _c.line),
                        ),
                        alignment: Alignment.center,
                        child: Text(l, style: TextStyle(color: selected ? _c.onAccent : _c.text, fontWeight: FontWeight.w700, fontSize: 14)),
                      );
                    }),
                  ),
                ),
              ],
            ],
          ),
          // Config rows for selected variants
          if (_netVariants.isNotEmpty) ...[
            SizedBox(height: 12),
            for (var i = 0; i < _netVariants.length; i++) ...[
              if (i > 0) SizedBox(height: 8),
              _NetVariantRow(
                draft: _netVariants[i],
                onRemove: () => setState(() { _netVariants[i].dispose(); _netVariants.removeAt(i); }),
                onChanged: () => setState(() {}),
              ),
            ],
          ],
        ],
        if (_canHaveParent) ...[
          SizedBox(height: 20),
          Text(
            'Part of ground',
            style: TextStyle(
                color: _c.text, fontWeight: FontWeight.w800, fontSize: 15),
          ),
          SizedBox(height: 4),
          Text(
            'If this unit shares the ground with a Full ground unit, link them so bookings block each other.',
            style: TextStyle(color: _c.muted, fontSize: 12),
          ),
          SizedBox(height: 10),
          _ParentUnitPicker(
            arenaId: widget.arenaId,
            currentUnitId: widget.unit?.id,
            selectedParentId: _parentUnitId,
            onChanged: (id) => setState(() => _parentUnitId = id),
          ),
        ],
        // Global floodlights only shown for non-net units or nets with no variants
        if (_unitType != 'CRICKET_NET' || _netVariants.isEmpty) ...[
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Floodlights', style: TextStyle(color: _c.text, fontWeight: FontWeight.w800, fontSize: 15)),
                    Text('Available for night play', style: TextStyle(color: _c.muted, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: _hasFloodlights,
                onChanged: (v) => setState(() => _hasFloodlights = v),
                activeThumbColor: _c.accent,
              ),
            ],
          ),
        ],
        // Quantity only shown for non-net units (net variants handle count per type)
        if (!_editing && !_isNetsWithVariants) ...[
          SizedBox(height: 20),
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
            Text('All day (24 hrs)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _c.text)),
            Spacer(),
            Switch.adaptive(
              value: _allDay,
              activeColor: _c.accent,
              onChanged: (v) => setState(() {
                _allDay = v;
                if (v) {
                  _openTimeCtrl.text = '00:00';
                  _closeTimeCtrl.text = '24:00';
                } else {
                  _openTimeCtrl.text = '';
                  _closeTimeCtrl.text = '';
                }
              }),
            ),
          ],
        ),
        if (!_allDay)
        Row(
          children: [
            Expanded(
              child: _TimePickerField(
                label: 'Open time',
                controller: _openTimeCtrl,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _TimePickerField(
                label: 'Close time',
                controller: _closeTimeCtrl,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Text(
          'Operating days',
          style: TextStyle(
            color: _c.text,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 10),
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
              backgroundColor: _c.surface,
              selectedColor: _c.deep,
              checkmarkColor: _c.accent,
              labelStyle: TextStyle(
                color: selected ? _c.onAccent : _c.text,
                fontWeight: FontWeight.w800,
              ),
              side: BorderSide(color: selected ? _c.deep : _c.line),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
        SizedBox(height: 20),
        Text(
          'Min slot duration',
          style: TextStyle(
            color: _c.text,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 10),
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
          SizedBox(height: 20),
          Text(
            'Turnaround between sessions',
            style: TextStyle(
              color: _c.text,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Extra gap after each session before the next can start',
            style: TextStyle(color: _c.muted, fontSize: 12),
          ),
          SizedBox(height: 10),
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
        ],
        SizedBox(height: 20),
        _SlotPreview(
          openCtrl: _openTimeCtrl,
          closeCtrl: _closeTimeCtrl,
          slotMins: _slotMins,
          breatherMins: _isGround ? _breatherMins : 0,
        ),
      ],
    );
  }

  Widget _netsPricingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LargeStepTitle('Pricing'),
        const _SectionLabel('Weekend Pricing'),
        SizedBox(height: 4),
        Text(
          'Apply a premium rate on Saturdays and Sundays.',
          style: TextStyle(color: _c.muted, fontSize: 12, fontWeight: FontWeight.w500, height: 1.5),
        ),
        SizedBox(height: 12),
        _SegmentedOptions(
          value: _weekendMultiplier == 1.0 ? '1.0' : _weekendMultiplier.toString(),
          options: const [
            ('1.0', 'None'),
            ('1.25', '1.25×'),
            ('1.5', '1.5×'),
            ('2.0', '2×'),
          ],
          onChanged: (v) => setState(() => _weekendMultiplier = double.parse(v)),
        ),
        if (_weekendMultiplier != 1.0) ...[
          SizedBox(height: 8),
          Text(
            'Weekend rate: ${(_weekendMultiplier * 100 - 100).toStringAsFixed(0)}% premium on all variants',
            style: TextStyle(color: _c.accent, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
        SizedBox(height: 28),
        const _SectionLabel('Monthly Pass'),
        SizedBox(height: 4),
        Text(
          'Set a monthly pass rate per net type. Leave blank to disable for that type.',
          style: TextStyle(color: _c.muted, fontSize: 12, fontWeight: FontWeight.w500, height: 1.5),
        ),
        SizedBox(height: 12),
        for (final v in _netVariants) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              controller: v.monthlyPassRateCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${v.label} pass rate (₹ / month)',
                prefixText: '₹ ',
                filled: true,
                fillColor: _c.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _c.line)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _c.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _c.deep, width: 1.4)),
              ),
            ),
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
              SizedBox(width: 10),
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
                      color: _showBulkPricing ? _c.accent : _c.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    _showBulkPricing
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                    color: _c.muted,
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
                SizedBox(width: 10),
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
        SizedBox(height: 20),
        Text(
          'Weekend pricing',
          style: TextStyle(
            color: _c.text,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 10),
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
          SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              for (final (label, paise) in wkndRows)
                Text(
                  'Weekend $label: ${_money(paise)}',
                  style: TextStyle(
                    color: _c.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
        SizedBox(height: 24),
        const _SectionLabel('Bulk / Multi-Day Booking'),
        SizedBox(height: 4),
        Text(
          'Offer a special daily rate when customers book multiple consecutive days.',
          style: TextStyle(
              color: _c.muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.5),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                'Offer bulk rate',
                style: TextStyle(
                    color: _c.text, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            Switch(
              value: _bulkEnabled,
              onChanged: (v) => setState(() => _bulkEnabled = v),
              activeThumbColor: _c.accent,
            ),
          ],
        ),
        if (_bulkEnabled) ...[
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Min days to unlock',
                  style: TextStyle(
                      color: _c.text, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: _minBulkDays > 2
                    ? () => setState(() => _minBulkDays--)
                    : null,
                icon: Icon(Icons.remove_rounded),
                color: _c.text,
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '$_minBulkDays',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _c.text, fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                onPressed: _minBulkDays < 30
                    ? () => setState(() => _minBulkDays++)
                    : null,
                icon: Icon(Icons.add_rounded),
                color: _c.text,
              ),
            ],
          ),
          SizedBox(height: 8),
          TextField(
            controller: _bulkRateCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Rate per day (₹)',
              prefixText: '₹ ',
              filled: true,
              fillColor: _c.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _c.line)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _c.line)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _c.deep, width: 1.4)),
            ),
          ),
          SizedBox(height: 8),
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
                color: _c.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Icon(Icons.trending_down_rounded,
                    size: 16, color: _c.accent),
                SizedBox(width: 8),
                Expanded(
                    child: Text(
                  'Customer saves ₹$saving/day vs normal rate. Good for events & tournaments.',
                  style: TextStyle(
                      color: _c.accent,
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
          SizedBox(height: 24),
          const _SectionLabel('Monthly Pass'),
          SizedBox(height: 4),
          Text(
            'Let customers lock a recurring time slot for the whole month.',
            style: TextStyle(
                color: _c.muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.5),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Offer monthly pass',
                  style: TextStyle(
                      color: _c.text, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              Switch(
                value: _monthlyPassEnabled,
                onChanged: (v) => setState(() => _monthlyPassEnabled = v),
                activeThumbColor: _c.accent,
              ),
            ],
          ),
          if (_monthlyPassEnabled) ...[
            SizedBox(height: 10),
            TextField(
              controller: _monthlyPassRateCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Pass rate (₹ / month)',
                prefixText: '₹ ',
                filled: true,
                fillColor: _c.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _c.line)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _c.line)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: _c.deep, width: 1.4)),
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
        Text(
          'Override arena defaults for this unit. Leave blank to inherit arena settings.',
          style: TextStyle(color: _c.muted, fontSize: 13, height: 1.5),
        ),
        SizedBox(height: 24),
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
        SizedBox(height: 12),
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
        SizedBox(height: 12),
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
        SizedBox(height: 8),
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
          SizedBox(height: 4),
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
        SizedBox(height: 4),
        TextButton.icon(
          onPressed: () => setState(() => _addons.add(_AddonDraft())),
          icon: Icon(Icons.add_rounded),
          label: Text('Custom add-on'),
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

  ({List<String> slots, bool overnight}) _computeSlots() {
    final openTime = widget.openCtrl.text.trim();
    final closeTime = widget.closeCtrl.text.trim();
    if (openTime.isEmpty || closeTime.isEmpty) {
      return (slots: const [], overnight: false);
    }
    int parseTime(String t) {
      final parts = t.split(':');
      if (parts.length < 2) return -1;
      final h = int.tryParse(parts[0]) ?? -1;
      final m = int.tryParse(parts[1]) ?? -1;
      if (h < 0 || m < 0) return -1;
      return h * 60 + m;
    }

    final openMins = parseTime(openTime);
    var closeMins = parseTime(closeTime);
    if (openMins < 0 || closeMins < 0) {
      return (slots: const [], overnight: false);
    }
    // Same time = no slots; everything else wraps overnight as needed.
    if (closeMins == openMins) {
      return (slots: const [], overnight: false);
    }
    final overnight = closeMins < openMins;
    if (overnight) closeMins += 24 * 60;

    final step = widget.slotMins + widget.breatherMins;
    if (step <= 0) return (slots: const [], overnight: overnight);

    final slots = <String>[];
    var start = openMins;
    while (start + widget.slotMins <= closeMins) {
      slots.add('${_fmt(start)} – ${_fmt(start + widget.slotMins)}');
      start += step;
    }
    return (slots: slots, overnight: overnight);
  }

  String _fmt(int totalMins) {
    final wrapped = totalMins % (24 * 60);
    final h = wrapped ~/ 60;
    final m = wrapped % 60;
    final suffix = h < 12 ? 'am' : 'pm';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return m == 0
        ? '$h12$suffix'
        : '$h12:${m.toString().padLeft(2, '0')}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final result = _computeSlots();
    if (result.slots.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Slot preview · ${result.slots.length} session${result.slots.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: _c.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (result.overnight) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _c.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'OVERNIGHT',
                  style: TextStyle(
                    color: _c.accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: result.slots
              .map((s) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _c.deep.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _c.deep.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        color: _c.deep,
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
    _c = _C.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _c.line),
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
                  color: _c.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: _c.deep),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: _c.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            color: _c.muted, fontSize: 12, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
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
    _c = _C.of(context);
    return Row(
      children: List.generate(count, (index) {
        final active = index <= activeIndex;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == count - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: active ? _c.deep : _c.line,
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
    _c = _C.of(context);
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
      return Text(
        'No Full ground units found. Add a Full ground unit first.',
        style: TextStyle(color: _c.muted, fontSize: 12),
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
              color: selected ? Color(0xFFF0FDF4) : _c.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? _c.accent : _c.line,
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
                    color: selected ? _c.accent : _c.text,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded,
                    size: 18, color: _c.accent),
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
    _c = _C.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: TextStyle(
          color: _c.text,
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
    _c = _C.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final selected = option.$1 == value;
        return ChoiceChip(
          selected: selected,
          onSelected: (_) => onChanged(option.$1),
          label: Text(option.$2),
          backgroundColor: _c.surface,
          selectedColor: _c.deep,
          checkmarkColor: _c.accent,
          labelStyle: TextStyle(
            color: selected ? _c.onAccent : _c.text,
            fontWeight: FontWeight.w800,
          ),
          side: BorderSide(color: selected ? _c.deep : _c.line),
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
    _c = _C.of(context);
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
          fillColor: _c.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          border: _inputBorder(_c.line),
          enabledBorder: _inputBorder(_c.line),
          focusedBorder: _inputBorder(_c.accent),
          errorBorder: _inputBorder(Theme.of(context).colorScheme.error),
          focusedErrorBorder: _inputBorder(Theme.of(context).colorScheme.error),
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
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AmPmTimeSheet(
        title: '$label?',
        initialHour: initHour,
        initialMinute: initMin,
      ),
    );
    if (result != null) controller.text = result;
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
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
                color: _c.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: hasValue ? _c.deep : _c.line),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 16, color: hasValue ? _c.deep : _c.muted),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(label,
                        style: TextStyle(
                            color: _c.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                  Text(
                    hasValue ? val.text : '--:--',
                    style: TextStyle(
                      color: hasValue ? _c.text : _c.muted,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.expand_more_rounded,
                      size: 18, color: hasValue ? _c.deep : _c.muted),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── AM/PM time bottom sheet ──────────────────────────────────────────────────

/// Picks a time using 12-hour format with explicit AM/PM toggle. Reduces the
/// 4 AM vs 4 PM confusion that the 24-hour wheel caused for owners typing
/// "4 PM" but landing on "04:00" (= 4 AM).
///
/// Returns a "HH:mm" 24-hour string (or null on cancel) so callers stay
/// compatible with existing storage.
class _AmPmTimeSheet extends StatefulWidget {
  const _AmPmTimeSheet({
    required this.title,
    required this.initialHour,
    required this.initialMinute,
  });

  final String title;
  final int initialHour; // 0–23
  final int initialMinute; // 0–59

  @override
  State<_AmPmTimeSheet> createState() => _AmPmTimeSheetState();
}

class _AmPmTimeSheetState extends State<_AmPmTimeSheet> {
  late int _hour12; // 1–12
  late int _minute; // 0–55 in 5-min steps
  late bool _isPm;
  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minCtrl;

  static final _mins = List.generate(12, (i) => i * 5);
  static const _hours = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  @override
  void initState() {
    super.initState();
    final h = widget.initialHour;
    _isPm = h >= 12;
    final h12 = h % 12 == 0 ? 12 : h % 12;
    _hour12 = h12;
    _minute = _mins.reduce(
        (a, b) => (a - widget.initialMinute).abs() <= (b - widget.initialMinute).abs() ? a : b);
    _hourCtrl = FixedExtentScrollController(initialItem: _hours.indexOf(_hour12));
    _minCtrl = FixedExtentScrollController(initialItem: _mins.indexOf(_minute));
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  int get _hour24 {
    if (_hour12 == 12) return _isPm ? 12 : 0;
    return _isPm ? _hour12 + 12 : _hour12;
  }

  String get _result =>
      '${_hour24.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

  String get _readable {
    final mm = _minute.toString().padLeft(2, '0');
    return '$_hour12:$mm ${_isPm ? 'PM' : 'AM'}';
  }

  String get _periodHint {
    // Helps owners sanity-check that the AM/PM matches their intent.
    final h = _hour24;
    if (h < 5) return 'Late night';
    if (h < 12) return 'Morning';
    if (h == 12) return 'Noon';
    if (h < 17) return 'Afternoon';
    if (h < 21) return 'Evening';
    return 'Night';
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Container(
      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _c.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title + Done row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: _c.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, _result),
                    style: TextButton.styleFrom(
                      foregroundColor: _c.accent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Done',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            // Readable preview
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _readable,
                    style: TextStyle(
                      color: _c.accent,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _periodHint,
                    style: TextStyle(
                      color: _c.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // AM / PM segmented
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _ampmTile(label: 'AM', selected: !_isPm)),
                  const SizedBox(width: 10),
                  Expanded(child: _ampmTile(label: 'PM', selected: _isPm)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Hour & minute wheels
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 60),
                    decoration: BoxDecoration(
                      color: _c.deep.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _hourCtrl,
                          itemExtent: 50,
                          perspective: 0.002,
                          diameterRatio: 2.0,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (i) =>
                              setState(() => _hour12 = _hours[i]),
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: _hours.length,
                            builder: (_, i) {
                              final sel = _hour12 == _hours[i];
                              return Center(
                                child: Text(
                                  _hours[i].toString(),
                                  style: TextStyle(
                                    color: sel ? _c.text : _c.muted,
                                    fontSize: sel ? 26 : 20,
                                    fontWeight:
                                        sel ? FontWeight.w900 : FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Text(':',
                          style: TextStyle(
                              color: _c.text,
                              fontSize: 26,
                              fontWeight: FontWeight.w900)),
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _minCtrl,
                          itemExtent: 50,
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
                                    color: sel ? _c.text : _c.muted,
                                    fontSize: sel ? 26 : 20,
                                    fontWeight:
                                        sel ? FontWeight.w900 : FontWeight.w500,
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
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _ampmTile({required String label, required bool selected}) {
    return GestureDetector(
      onTap: () => setState(() => _isPm = label == 'PM'),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _c.accent : _c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _c.accent : _c.line, width: 1.4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _c.onAccent : _c.text,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ),
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
    _c = _C.of(context);
    return Container(
      decoration: BoxDecoration(
        color: _c.surface,
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
              color: _c.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Select time',
                      style: TextStyle(
                          color: _c.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w900)),
                ),
                TextButton(
                  onPressed: () {
                    widget.onPicked(_hour, _minute);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _c.accent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text('Done',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: _c.surface,
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
                        physics: FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (i) => setState(() => _hour = i),
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 24,
                          builder: (_, i) {
                            final sel = _hour == i;
                            return Center(
                              child: Text(
                                i.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  color: sel ? _c.text : _c.muted,
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
                    Text(':',
                        style: TextStyle(
                            color: _c.text,
                            fontSize: 28,
                            fontWeight: FontWeight.w900)),
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: _minCtrl,
                        itemExtent: 52,
                        perspective: 0.002,
                        diameterRatio: 2.0,
                        physics: FixedExtentScrollPhysics(),
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
                                  color: sel ? _c.text : _c.muted,
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
          SafeArea(
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
    _c = _C.of(context);
    return _Panel(
      children: [
        Row(
          children: [
            Expanded(child: _SectionLabel('Photos (${photos.length}/3)')),
            TextButton.icon(
              onPressed: uploading || photos.length >= 3 ? null : onAdd,
              icon: uploading
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.upload_rounded),
              label: Text('Upload'),
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
              separatorBuilder: (_, __) => SizedBox(width: 10),
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
                          color: _c.line,
                          child: Icon(Icons.broken_image_outlined),
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
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: _c.surface,
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
    _c = _C.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            'Total Units',
            style: TextStyle(
              color: _c.text,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        IconButton(
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: Icon(Icons.remove_rounded),
          color: _c.text,
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _c.text,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ),
        IconButton(
          onPressed: value < 20 ? () => onChanged(value + 1) : null,
          icon: Icon(Icons.add_rounded),
          color: _c.text,
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
    _c = _C.of(context);
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
                      style: TextStyle(
                        color: _c.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeThumbColor: _c.accent,
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
    _c = _C.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _Panel(
        children: [
          Row(
            children: [
              Expanded(child: _SectionLabel('Addon')),
              IconButton(
                onPressed: onRemove,
                icon: Icon(Icons.close_rounded),
              ),
            ],
          ),
          _SheetField(label: 'Name', controller: draft.name, required: true),
          Row(
            children: [
              Expanded(
                child: _SheetField(label: 'Type', controller: draft.addonType),
              ),
              SizedBox(width: 10),
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
    _c = _C.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _c.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: surface label
          Text(draft.label, style: TextStyle(color: _c.text, fontWeight: FontWeight.w800, fontSize: 14)),
          SizedBox(height: 10),
          Row(
            children: [
              // Count stepper
              Text('Count', style: TextStyle(color: _c.muted, fontSize: 12, fontWeight: FontWeight.w600)),
              SizedBox(width: 8),
              GestureDetector(
                onTap: draft.count > 1 ? () { draft.count--; onChanged(); } : null,
                child: Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(color: _c.surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: _c.line)),
                  child: Icon(Icons.remove, size: 14, color: draft.count > 1 ? _c.text : _c.muted),
                ),
              ),
              SizedBox(width: 8),
              Text('${draft.count}', style: TextStyle(color: _c.text, fontWeight: FontWeight.w700, fontSize: 15)),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () { draft.count++; onChanged(); },
                child: Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(color: _c.surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: _c.line)),
                  child: Icon(Icons.add, size: 14, color: _c.text),
                ),
              ),
              SizedBox(width: 12),
              // Price field
              Expanded(
                child: TextFormField(
                  controller: draft.priceCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: _c.text, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Price/hr',
                    hintStyle: TextStyle(color: _c.muted, fontSize: 12),
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(color: _c.muted, fontSize: 13),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Floodlights toggle
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, size: 16, color: _c.muted),
              SizedBox(width: 6),
              Expanded(child: Text('Floodlights', style: TextStyle(color: _c.muted, fontSize: 13, fontWeight: FontWeight.w600))),
              SizedBox(
                height: 24,
                child: Switch(
                  value: draft.hasFloodlights,
                  onChanged: (v) { draft.hasFloodlights = v; onChanged(); },
                  activeThumbColor: _c.accent,
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
    String monthlyPassRate = '',
  }) : priceCtrl = TextEditingController(text: price),
       monthlyPassRateCtrl = TextEditingController(text: monthlyPassRate);

  String type;
  String label;
  int count;
  bool hasFloodlights;
  final TextEditingController priceCtrl;
  final TextEditingController monthlyPassRateCtrl;

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
    if (monthlyPassRateCtrl.text.trim().isNotEmpty)
      'monthlyPassRatePaise': (int.tryParse(monthlyPassRateCtrl.text.trim()) ?? 0) * 100,
  };

  factory _NetVariantDraft.fromVariant(NetVariant v) => _NetVariantDraft(
    type: v.type,
    label: v.label,
    count: v.count,
    hasFloodlights: v.hasFloodlights,
    price: v.pricePaise != null ? (v.pricePaise! ~/ 100).toString() : '',
    monthlyPassRate: v.monthlyPassRatePaise != null ? (v.monthlyPassRatePaise! ~/ 100).toString() : '',
  );

  void dispose() {
    priceCtrl.dispose();
    monthlyPassRateCtrl.dispose();
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _c.line),
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
    _c = _C.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: _c.muted,
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
    _c = _C.of(context);
    return Text(
      text,
      style: TextStyle(
        color: _c.muted,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.45,
      ),
    );
  }
}

// ─── Help sheet ───────────────────────────────────────────────────────────────

class _ArenaHelpSheet extends StatelessWidget {
  const _ArenaHelpSheet();

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: _c.line, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'How it works',
            style: TextStyle(
                color: _c.text, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 20),
          _HelpItem(
            icon: Icons.stadium_rounded,
            iconColor: _c.deep,
            iconBg: Color(0xFFD1FAE5),
            title: 'Arena',
            body:
                'Your venue on Swing. Set up the name, location, sports, and operating hours. Players search and discover your arena to make bookings.',
          ),
          SizedBox(height: 16),
          _HelpItem(
            icon: Icons.grid_view_rounded,
            iconColor: Color(0xFF0EA5E9),
            iconBg: Color(0xFFE0F2FE),
            title: 'Unit',
            body:
                'A bookable court or space inside your arena — e.g. "Court 1", "Turf A", "Net 2". Each unit has its own slot timings, pricing, and photos. Players pick a unit when they book.',
          ),
          SizedBox(height: 16),
          _HelpItem(
            icon: Icons.calendar_month_rounded,
            iconColor: Color(0xFF7C3AED),
            iconBg: Color(0xFFEDE9FE),
            title: 'Booking',
            body:
                'A confirmed time slot reservation by a player for one of your units. You can view upcoming and past bookings, check payment status, and manage check-ins from the Bookings tab.',
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  const _HelpItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration:
              BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: _c.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text(body,
                  style: TextStyle(
                      color: _c.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.45)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Could not load arena.\n$message',
          textAlign: TextAlign.center,
          style: TextStyle(color: _c.muted),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Arena details are not available yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _c.muted),
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
  const _DetailsTab({required this.parent});

  final _ArenaDetailPageState parent;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final p = parent;
    final dayLabels = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return ListView(
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
                  selectedColor: _c.accent.withValues(alpha: 0.15),
                  checkmarkColor: _c.accent,
                  side: BorderSide(
                      color: p._operatingDays.contains(day) ? _c.accent : _c.line),
                  labelStyle: TextStyle(
                    color: p._operatingDays.contains(day) ? _c.accent : _c.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  backgroundColor: _c.surface,
                ),
            ],
          ),
        SizedBox(height: 4),
      ],
    );
  }
}

const _kGooglePlacesKey = 'AIzaSyDpJ1S4JYO-jVA6BgzxM1LYjdSvrSrTkTo';

class _LocationTab extends StatefulWidget {
  const _LocationTab({required this.parent});
  final _ArenaDetailPageState parent;
  @override
  State<_LocationTab> createState() => _LocationTabState();
}

class _LocationTabState extends State<_LocationTab> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  List<Map<String, dynamic>> _suggestions = [];
  String _session = _newPlacesSession();

  static String _newPlacesSession() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    if (v.trim().length < 2) {
      setState(() { _suggestions = []; _loading = false; });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 450), () => _fetch(v.trim()));
  }

  Future<void> _fetch(String query) async {
    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
        'input': query,
        'key': _kGooglePlacesKey,
        'components': 'country:in',
        'language': 'en',
        'types': 'geocode|establishment',
        'sessiontoken': _session,
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final preds = (body['predictions'] as List?)
                ?.whereType<Map<String, dynamic>>().toList() ?? [];
        setState(() { _suggestions = preds; _loading = false; });
      } else {
        setState(() { _suggestions = []; _loading = false; });
      }
    } catch (_) {
      if (mounted) setState(() { _suggestions = []; _loading = false; });
    }
  }

  Future<void> _select(Map<String, dynamic> pred) async {
    final placeId = pred['place_id'] as String? ?? '';
    final desc = pred['description'] as String? ?? '';
    setState(() { _searchCtrl.text = desc; _suggestions = []; _loading = true; });
    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
        'place_id': placeId,
        'key': _kGooglePlacesKey,
        'fields': 'geometry,address_components',
        'language': 'en',
        'sessiontoken': _session,
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final result = ((jsonDecode(res.body) as Map<String, dynamic>)['result'] as Map<String, dynamic>?) ?? {};
        final location = (result['geometry'] as Map?)?['location'] as Map<String, dynamic>?;
        final components = (result['address_components'] as List?)
                ?.whereType<Map<String, dynamic>>().toList() ?? [];

        String get(List<String> types) {
          for (final c in components) {
            final t = (c['types'] as List?)?.cast<String>() ?? [];
            if (types.any(t.contains)) return c['long_name'] as String? ?? '';
          }
          return '';
        }

        final streetNum = get(['street_number']);
        final route     = get(['route']);
        final sub       = get(['sublocality_level_1', 'sublocality']);
        final city      = get(['locality']);
        final state     = get(['administrative_area_level_1']);
        final pin       = get(['postal_code']);
        final addressParts = [if (streetNum.isNotEmpty) streetNum, if (route.isNotEmpty) route, if (sub.isNotEmpty) sub];
        final address = addressParts.isNotEmpty ? addressParts.join(', ') : desc.split(',').first;

        final p = widget.parent;
        p._addressCtrl.text = address;
        p._cityCtrl.text    = city;
        p._stateCtrl.text   = state;
        p._pincodeCtrl.text = pin;
        if (location?['lat'] != null) p._latitudeCtrl.text  = (location!['lat'] as double).toStringAsFixed(6);
        if (location?['lng'] != null) p._longitudeCtrl.text = (location!['lng'] as double).toStringAsFixed(6);
        setState(() { _session = _newPlacesSession(); _loading = false; });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final scheme = Theme.of(context).colorScheme;
    final p = widget.parent;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // ── Places search ──────────────────────────────────────────────
        TextFormField(
          controller: _searchCtrl,
          onChanged: _onSearchChanged,
          style: TextStyle(color: _c.text, fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Search address…',
            labelStyle: TextStyle(color: _c.muted),
            prefixIcon: _loading
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: _c.accent),
                    ),
                  )
                : Icon(Icons.search_rounded, color: _c.muted, size: 20),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? GestureDetector(
                    onTap: () => setState(() { _searchCtrl.clear(); _suggestions = []; }),
                    child: Icon(Icons.close_rounded, color: _c.muted, size: 18),
                  )
                : null,
            filled: true,
            fillColor: scheme.surfaceContainerHighest,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _c.accent, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: _suggestions.map((pred) {
                final main = (pred['structured_formatting'] as Map?)?['main_text'] as String? ?? pred['description'] as String? ?? '';
                final secondary = (pred['structured_formatting'] as Map?)?['secondary_text'] as String? ?? '';
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _select(pred),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(children: [
                      Icon(Icons.location_on_outlined, size: 16, color: _c.muted),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(main, style: TextStyle(color: _c.text, fontSize: 13, fontWeight: FontWeight.w600)),
                        if (secondary.isNotEmpty)
                          Text(secondary, style: TextStyle(color: _c.muted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ])),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 16),
        // ── Manual fields (pre-filled, still editable) ─────────────────
        p._field('Address', p._addressCtrl, p._addressCtrl.text, required: true, maxLines: 2),
        p._field('City', p._cityCtrl, p._cityCtrl.text, required: true),
        p._field('State', p._stateCtrl, p._stateCtrl.text, required: true),
        p._field('Pincode', p._pincodeCtrl, p._pincodeCtrl.text, keyboardType: TextInputType.number),
        const _TabSectionLabel('Coordinates (optional)'),
        p._field('Latitude', p._latitudeCtrl, p._latitudeCtrl.text,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true)),
        p._field('Longitude', p._longitudeCtrl, p._longitudeCtrl.text,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true)),
      ],
    );
  }
}

class _PhotosTab extends StatelessWidget {
  const _PhotosTab({required this.parent});

  final _ArenaDetailPageState parent;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final p = parent;
    final urls = p._photoUrls;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          'Photos (${urls.length}/3)',
          style: TextStyle(
              color: _c.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5),
        ),
        SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
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
                        errorBuilder: (_, __, ___) => Container(color: _c.line)),
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
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(6)),
                          child: Icon(Icons.close_rounded,
                              color: _c.surface, size: 14),
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
                    color: _c.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _c.line, style: BorderStyle.solid),
                  ),
                  child: p._uploading
                      ? Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_rounded,
                                color: _c.muted, size: 26),
                            SizedBox(height: 4),
                            Text('Add',
                                style: TextStyle(
                                    color: _c.muted,
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
                color: _c.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _c.line)),
            child: Center(
                child: Text('No photos added',
                    style: TextStyle(color: _c.muted, fontSize: 13))),
          ),
      ],
    );
  }
}

class _FacilitiesTab extends StatelessWidget {
  const _FacilitiesTab({required this.parent});

  final _ArenaDetailPageState parent;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: amenities.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: _c.line),
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
              color: enabled ? _c.accent.withValues(alpha: 0.1) : _c.bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: enabled ? _c.accent : _c.muted),
          ),
          title: Text(label,
              style: TextStyle(
                  color: enabled ? _c.text : _c.muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          trailing: p._editing
              ? Switch(
                  value: enabled,
                  onChanged: setter,
                  activeThumbColor: _c.accent,
                )
              : Icon(
                  enabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: enabled ? _c.accent : _c.line,
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
    _c = _C.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
            color: _c.muted,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8),
      ),
    );
  }
}

class _UnitsTab extends ConsumerWidget {
  const _UnitsTab({required this.parent});
  final _ArenaDetailPageState parent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _c = _C.of(context);
    final arenaAsync = ref.watch(arenaDetailByIdProvider(parent.widget.arena.id));
    final fallback = parent.widget.arena;
    final arena = arenaAsync.maybeWhen(
      data: (a) => a ?? fallback,
      orElse: () => fallback,
    );
    if (arena.units.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_box_outlined, size: 52, color: _c.muted),
            SizedBox(height: 16),
            Text(
              'No units yet',
              style: TextStyle(
                  color: _c.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Add your first unit — a cricket net, full ground, or any bookable space.',
              style: TextStyle(color: _c.muted, fontSize: 14, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
      itemCount: arena.units.length,
      separatorBuilder: (_, __) => SizedBox(height: 10),
      itemBuilder: (context, index) {
        final unit = arena.units[index];
        return _UnitCard(
          unit: unit,
          onTap: () => context.push(
              '${AppRoutes.arenaUnitDetail}/${arena.id}/${unit.id}'),
          onEdit: () => parent._openUnitSheet(arena, unit),
          onDelete: () => parent._deleteUnitOnDetail(unit),
        );
      },
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

  // Microsite state
  final _taglineCtrl = TextEditingController();
  final _brandColorCtrl = TextEditingController();
  String? _logoUrl;
  String? _brandColor;
  int _coverPhotoIndex = 0;
  List<MicrositeLink> _links = const [];
  List<String> _linkIds = const [];
  int _linkIdSeq = 0;
  bool _logoUploading = false;
  bool _savingMicrosite = false;
  bool _micrositeSaved = false;

  String _nextLinkId() => 'link-${_linkIdSeq++}-${DateTime.now().microsecondsSinceEpoch}';

  static const _brandColorPresets = <(String, String)>[
    ('Forest',   '#2BA84A'),
    ('Electric', '#C8FF3E'),
    ('Royal',    '#3E63FF'),
    ('Crimson',  '#E11D48'),
    ('Amber',    '#F59E0B'),
    ('Violet',   '#7C3AED'),
    ('Teal',     '#14B8A6'),
    ('Charcoal', '#1A1A1A'),
  ];

  static const _linkKinds = [
    ('instagram', Icons.camera_alt_outlined, 'Instagram'),
    ('youtube', Icons.smart_display_outlined, 'YouTube'),
    ('whatsapp', Icons.chat_bubble_outline_rounded, 'WhatsApp'),
    ('website', Icons.language_rounded, 'Website'),
    ('menu', Icons.restaurant_menu_rounded, 'Menu'),
    ('custom', Icons.link_rounded, 'Custom'),
  ];

  static final _hexRegex = RegExp(r'^#[0-9a-fA-F]{6}$');
  static final _urlRegex = RegExp(
      r'^(https?://|mailto:|tel:|wa\.me/)',
      caseSensitive: false);

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
    _logoUrl = widget.arena.logoUrl;
    _brandColor = widget.arena.brandColor;
    _brandColorCtrl.text = _brandColor ?? '';
    _taglineCtrl.text = widget.arena.tagline ?? '';
    _coverPhotoIndex = widget.arena.coverPhotoIndex;
    _links = List<MicrositeLink>.from(widget.arena.micrositeLinks);
    _linkIds = [for (final _ in _links) _nextLinkId()];
  }

  @override
  void dispose() {
    _slugCtrl.dispose();
    _taglineCtrl.dispose();
    _brandColorCtrl.dispose();
    super.dispose();
  }

  Future<void> _openPublicPage() async {
    final slug = _customSlug?.trim().isNotEmpty == true
        ? _customSlug!.trim()
        : _arenaSlug?.trim();
    if (slug == null || slug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set a custom link first')),
      );
      return;
    }
    final uri = Uri.parse('https://www.swingcricketapp.com/arena/$slug');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _logoUploading = true);
    try {
      final compressed = await ImageCompressor.compress(file.path);
      if (compressed == null) return;
      final form = FormData.fromMap({
        'folder': 'arenas/${widget.arena.id}/branding',
        'file': await MultipartFile.fromFile(compressed.path,
            filename: '${p.basenameWithoutExtension(file.name)}.jpg'),
      });
      final response = await ApiClient.instance.dio.post(
        '/media/upload',
        data: form,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      final payload = response.data as Map<String, dynamic>;
      final data = (payload['data'] ?? payload) as Map<String, dynamic>;
      final url = (data['publicUrl'] ?? data['url'] ?? data['link']) as String?;
      if (url != null && url.isNotEmpty && mounted) {
        setState(() {
          _logoUrl = url;
          _micrositeSaved = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logo upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _logoUploading = false);
    }
  }

  void _setBrandColor(String hex) {
    setState(() {
      _brandColor = hex;
      _brandColorCtrl.text = hex;
      _micrositeSaved = false;
    });
  }

  void _addLink() {
    if (_links.length >= 20) return;
    setState(() {
      _links = [
        ..._links,
        const MicrositeLink(kind: 'instagram', label: 'Instagram', url: ''),
      ];
      _linkIds = [..._linkIds, _nextLinkId()];
      _micrositeSaved = false;
    });
  }

  void _updateLink(int index, MicrositeLink updated) {
    setState(() {
      _links = [
        for (int i = 0; i < _links.length; i++)
          if (i == index) updated else _links[i],
      ];
      _micrositeSaved = false;
    });
  }

  void _removeLink(int index) {
    setState(() {
      _links = [
        for (int i = 0; i < _links.length; i++)
          if (i != index) _links[i],
      ];
      _linkIds = [
        for (int i = 0; i < _linkIds.length; i++)
          if (i != index) _linkIds[i],
      ];
      _micrositeSaved = false;
    });
  }

  void _reorderLinks(int oldIndex, int newIndex) {
    setState(() {
      final list = [..._links];
      final ids = [..._linkIds];
      if (newIndex > oldIndex) newIndex -= 1;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      final id = ids.removeAt(oldIndex);
      ids.insert(newIndex, id);
      _links = list;
      _linkIds = ids;
      _micrositeSaved = false;
    });
  }

  String? _validateMicrosite() {
    if (_brandColor != null &&
        _brandColor!.isNotEmpty &&
        !_hexRegex.hasMatch(_brandColor!)) {
      return 'Brand color must be #RRGGBB (e.g. #16A34A)';
    }
    if ((_taglineCtrl.text).length > 120) {
      return 'Tagline must be 120 characters or fewer';
    }
    for (final link in _links) {
      if (link.url.trim().isEmpty) {
        return 'All links need a URL';
      }
      if (link.kind == 'custom' && link.label.trim().isEmpty) {
        return 'Custom links need a label';
      }
      if (!_urlRegex.hasMatch(link.url.trim())) {
        return 'Link URL must start with http://, https://, mailto:, tel:, or wa.me/';
      }
    }
    return null;
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: 'https://$_publicUrl'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Link copied!'), duration: Duration(seconds: 2)),
    );
  }

  void _shareLink() {
    Share.share('https://$_publicUrl', subject: widget.arena.name);
  }

  Future<void> _saveAll() async {
    final rawSlug = _slugCtrl.text.trim();
    final slug = _normaliseSlug(rawSlug);
    if (rawSlug.isNotEmpty && slug.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Custom link must be at least 3 letters or numbers')),
      );
      return;
    }
    final err = _validateMicrosite();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    setState(() {
      _savingMicrosite = true;
      _micrositeSaved = false;
      _saving = true;
      _saved = false;
    });

    final photoMax = widget.arena.photoUrls.length - 1;
    final clampedCover =
        photoMax < 0 ? 0 : _coverPhotoIndex.clamp(0, photoMax);
    final payload = <String, dynamic>{
      'customSlug': slug.isEmpty ? null : slug,
      'coverPhotoIndex': clampedCover,
    };
    final brand = _brandColor?.trim();
    if (brand != null && brand.isNotEmpty) payload['brandColor'] = brand;
    if (_logoUrl != null && _logoUrl!.isNotEmpty) payload['logoUrl'] = _logoUrl;
    final tagline = _taglineCtrl.text.trim();
    if (tagline.isNotEmpty) payload['tagline'] = tagline;
    if (_links.isNotEmpty) {
      payload['micrositeLinks'] = [
        for (int i = 0; i < _links.length; i++)
          _links[i].copyWith(order: i).toJson(),
      ];
    }
    try {
      final updated = await ref
          .read(hostArenaBookingRepositoryProvider)
          .updateArena(widget.arena.id, payload);
      ref.invalidate(arenaDetailProvider);
      ref.invalidate(arenaDetailByIdProvider(widget.arena.id));
      ref.invalidate(ownedArenasProvider);
      if (!mounted) return;
      setState(() {
        _customSlug = updated.customSlug;
        _citySlug = updated.citySlug;
        _arenaSlug = updated.arenaSlug;
        _slugCtrl.text = updated.customSlug ?? '';
        _saving = false;
        _saved = true;
        _savingMicrosite = false;
        _micrositeSaved = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _saved = false;
          _micrositeSaved = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _savingMicrosite = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final arena = widget.arena;
    final hasPhotos = arena.photoUrls.isNotEmpty;
    final isSaving = _saving || _savingMicrosite;
    final justSaved = _saved || _micrositeSaved;

    Widget divider() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Container(height: 1, color: _c.line),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
Row(
          children: [
            Icon(Icons.link_rounded, size: 16, color: _c.muted),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                _publicUrl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _c.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            IconButton(
              tooltip: 'Open',
              onPressed: _openPublicPage,
              icon: Icon(Icons.open_in_new_rounded, size: 18, color: _c.muted),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              tooltip: 'Copy',
              onPressed: _copyLink,
              icon: Icon(Icons.copy_rounded, size: 18, color: _c.muted),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              tooltip: 'Share',
              onPressed: _shareLink,
              icon: Icon(Icons.share_rounded, size: 18, color: _c.muted),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        SizedBox(height: 14),
        Row(
          children: [
            Text(
              'swingcricketapp.com/',
              style: TextStyle(
                color: _c.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
            Expanded(
              child: TextField(
                controller: _slugCtrl,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _c.text,
                    fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'your-arena-name',
                  hintStyle: TextStyle(color: _c.muted, fontSize: 13),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (value) => setState(() {
                  _saved = false;
                  _customSlug = _normaliseSlug(value);
                }),
              ),
            ),
          ],
        ),

        divider(),

Row(
          children: [
            GestureDetector(
              onTap: _logoUploading ? null : _pickLogo,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: _c.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: _logoUploading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _c.accent),
                      )
                    : _logoUrl != null && _logoUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(_logoUrl!, fit: BoxFit.cover),
                          )
                        : Icon(Icons.add_a_photo_outlined,
                            size: 26, color: _c.muted),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _logoUrl != null && _logoUrl!.isNotEmpty
                        ? 'Square logo set'
                        : 'Tap to add a square logo',
                    style: TextStyle(
                        color: _c.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Shown next to your arena name on the public page.',
                    style: TextStyle(
                        color: _c.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.4),
                  ),
                  if (_logoUrl != null && _logoUrl!.isNotEmpty) ...[
                    SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => setState(() {
                        _logoUrl = null;
                        _micrositeSaved = false;
                      }),
                      child: Text(
                        'Remove',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        divider(),

Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final (_, hex) in _brandColorPresets)
              _BrandSwatch(
                hex: hex,
                selected: _brandColor?.toLowerCase() == hex.toLowerCase(),
                onTap: () => _setBrandColor(hex),
              ),
          ],
        ),
        SizedBox(height: 12),
        TextField(
          controller: _brandColorCtrl,
          style: TextStyle(
              color: _c.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace'),
          decoration: InputDecoration(
            hintText: '#RRGGBB',
            hintStyle: TextStyle(color: _c.muted, fontSize: 13),
            filled: true,
            fillColor: _c.surface,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (v) => setState(() {
            _brandColor = v.trim();
            _micrositeSaved = false;
          }),
        ),

        divider(),

TextField(
          controller: _taglineCtrl,
          maxLength: 120,
          style: TextStyle(color: _c.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g. Premium turf, fair pricing, family vibe',
            hintStyle: TextStyle(color: _c.muted, fontSize: 13),
            filled: true,
            fillColor: _c.surface,
            isDense: true,
            counterStyle: TextStyle(color: _c.muted, fontSize: 10),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (_) => setState(() => _micrositeSaved = false),
        ),
        SizedBox(height: 4),
        Text(
          'Short subhead shown under your arena name.',
          style: TextStyle(
              color: _c.muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.4),
        ),

        divider(),

if (!hasPhotos)
          Text(
            'Add photos in the Photos tab first.',
            style: TextStyle(
                color: _c.muted, fontSize: 12, fontWeight: FontWeight.w600),
          )
        else
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: arena.photoUrls.length,
              separatorBuilder: (_, __) => SizedBox(width: 10),
              itemBuilder: (_, i) {
                final isCover = i == _coverPhotoIndex;
                return GestureDetector(
                  onTap: () => setState(() {
                    _coverPhotoIndex = i;
                    _micrositeSaved = false;
                  }),
                  child: Stack(
                    children: [
                      Container(
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCover ? _c.text : Colors.transparent,
                            width: isCover ? 2 : 0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.network(arena.photoUrls[i],
                              fit: BoxFit.cover),
                        ),
                      ),
                      if (isCover)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: _c.text,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(Icons.star_rounded,
                                size: 12, color: _c.bg),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

        divider(),

Text(
          'Book, Call, and Directions are added automatically from your phone, address, and units.',
          style: TextStyle(
              color: _c.muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.4),
        ),
        SizedBox(height: 12),
        if (_links.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _links.length,
            onReorder: _reorderLinks,
            itemBuilder: (context, i) => Padding(
              key: ValueKey(_linkIds[i]),
              padding: const EdgeInsets.only(bottom: 10),
              child: _MicrositeLinkRow(
                link: _links[i],
                index: i,
                kinds: _linkKinds,
                onChanged: (updated) => _updateLink(i, updated),
                onDelete: () => _removeLink(i),
              ),
            ),
          ),
        TextButton.icon(
          onPressed: _links.length >= 20 ? null : _addLink,
          icon: Icon(Icons.add_rounded, size: 16, color: _c.accent),
          label: Text(
            'Add link',
            style: TextStyle(
                color: _c.accent, fontWeight: FontWeight.w800, fontSize: 13),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            minimumSize: Size.zero,
            alignment: Alignment.centerLeft,
          ),
        ),

        SizedBox(height: 28),

        FilledButton(
          onPressed: isSaving ? null : _saveAll,
          style: FilledButton.styleFrom(
            backgroundColor:
                justSaved ? const Color(0xFF059669) : _c.accent,
            foregroundColor: _c.onAccent,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: isSaving
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _c.onAccent),
                )
              : Text(justSaved ? 'Saved!' : 'Save',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
        ),
      ],
    );
  }
}

class _SiteLabel extends StatelessWidget {
  const _SiteLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: _c.muted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );
  }
}

Color _parseHex(String hex) {
  final clean = hex.replaceFirst('#', '');
  final value = int.tryParse(clean, radix: 16) ?? 0;
  return Color(0xFF000000 | value);
}

class _BrandSwatch extends StatelessWidget {
  const _BrandSwatch({
    required this.hex,
    required this.selected,
    required this.onTap,
  });
  final String hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final color = _parseHex(hex);
    final isLight = hex.toUpperCase() == '#FFFFFF';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? _c.text
                : (isLight ? _c.line : Colors.transparent),
            width: selected ? 2.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: selected
            ? Icon(Icons.check_rounded,
                size: 18, color: isLight ? Colors.black : Colors.white)
            : null,
      ),
    );
  }
}

class _MicrositeLinkRow extends StatelessWidget {
  const _MicrositeLinkRow({
    required this.link,
    required this.index,
    required this.kinds,
    required this.onChanged,
    required this.onDelete,
  });
  final MicrositeLink link;
  final int index;
  final List<(String, IconData, String)> kinds;
  final ValueChanged<MicrositeLink> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    _c = _C.of(context);
    final currentKind = kinds.firstWhere(
      (k) => k.$1 == link.kind,
      orElse: () => kinds.last,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _c.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kind picker — dropdown
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentKind.$1,
              isExpanded: true,
              isDense: true,
              icon: Icon(Icons.expand_more_rounded,
                  size: 18, color: _c.muted),
              style: TextStyle(
                color: _c.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              dropdownColor: _c.surface,
              borderRadius: BorderRadius.circular(8),
              onChanged: (v) {
                if (v == null) return;
                final picked = kinds.firstWhere((k) => k.$1 == v,
                    orElse: () => kinds.last);
                final newLabel = v == 'custom' ? link.label : picked.$3;
                onChanged(link.copyWith(kind: v, label: newLabel));
              },
              items: [
                for (final (kind, icon, label) in kinds)
                  DropdownMenuItem(
                    value: kind,
                    child: Row(
                      children: [
                        Icon(icon, size: 16, color: _c.muted),
                        SizedBox(width: 10),
                        Text(label),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (link.kind == 'custom') ...[
            SizedBox(height: 10),
            TextFormField(
              initialValue: link.label,
              maxLength: 40,
              style: TextStyle(color: _c.text, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Label (e.g. Book a coach)',
                hintStyle: TextStyle(color: _c.muted, fontSize: 13),
                counterText: '',
                isDense: true,
                filled: true,
                fillColor: _c.bg,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (v) => onChanged(link.copyWith(label: v)),
            ),
          ],
          SizedBox(height: 8),
          // URL
          TextFormField(
            initialValue: link.url,
            keyboardType: TextInputType.url,
            style: TextStyle(
                color: _c.text, fontSize: 13, fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: 'https://… or wa.me/91…',
              hintStyle: TextStyle(color: _c.muted, fontSize: 12),
              isDense: true,
              filled: true,
              fillColor: _c.bg,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            onChanged: (v) => onChanged(link.copyWith(url: v)),
          ),
          SizedBox(height: 10),
          // Footer: drag handle + enabled + delete
          Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(Icons.drag_indicator_rounded,
                      size: 18, color: _c.muted),
                ),
              ),
              SizedBox(width: 4),
              Text(
                link.enabled ? 'Visible on site' : 'Hidden',
                style: TextStyle(
                  color: _c.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: link.enabled,
                  onChanged: (v) => onChanged(link.copyWith(enabled: v)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ],
      ),
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
