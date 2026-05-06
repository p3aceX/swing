import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/me_providers.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/image_compressor.dart';
import '../../arena/screens/arena_profile_page.dart';
import '../../arena/services/arena_profile_providers.dart';

const _googlePlacesKey = 'AIzaSyDpJ1S4JYO-jVA6BgzxM1LYjdSvrSrTkTo';

const _bg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF6F7F9);
const _line = Color(0xFFEDEEF2);
const _text = Color(0xFF0B0B0F);
const _muted = Color(0xFF6B7280);
const _accent = Color(0xFFF43F5E);
const _deep = Color(0xFF9F1239);

class CreateArenaScreen extends ConsumerStatefulWidget {
  const CreateArenaScreen({super.key});

  @override
  ConsumerState<CreateArenaScreen> createState() => _CreateArenaScreenState();
}

class _CreateArenaScreenState extends ConsumerState<CreateArenaScreen> {
  final _page = PageController();
  final _basicKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _description = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();

  int _step = 0;
  bool _saving = false;
  bool _uploading = false;
  bool _locationPicked = false;
  String _arenaType = 'CRICKET';
  final List<String> _photoUrls = [];

  // Facilities step
  bool _hasParking = false;
  bool _hasLights = false;
  bool _hasWashrooms = false;
  bool _hasCanteen = false;
  bool _hasCCTV = false;
  bool _hasScorer = false;
  String _openTime = '06:00';
  String _closeTime = '22:00';

  // Address search
  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  bool _searchLoading = false;
  List<Map<String, dynamic>> _suggestions = [];
  // Session token groups all autocomplete keystrokes + 1 details call = 1 billed session
  String _placesSession = _newSessionToken();
  // Cache: query → predictions (avoids re-fetching identical searches)
  final Map<String, List<Map<String, dynamic>>> _suggestionsCache = {};

  static const _steps = [
    _SetupStep('Type', Icons.category_rounded),
    _SetupStep('Basics', Icons.edit_note_rounded),
    _SetupStep('Location', Icons.location_on_rounded),
    _SetupStep('Facilities', Icons.local_parking_rounded),
    _SetupStep('Photos', Icons.add_a_photo_rounded),
  ];

  void _log(String msg) => debugPrint('[CreateArena] $msg');

  @override
  void dispose() {
    for (final c in [_name, _description, _phone, _address, _city, _state, _pincode, _latitude, _longitude, _searchCtrl]) {
      c.dispose();
    }
    _searchDebounce?.cancel();
    _page.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final files = await ImagePicker().pickMultiImage();
    _log('pickPhotos: selected ${files.length} file(s)');
    if (files.isEmpty) return;
    setState(() => _uploading = true);
    try {
      final uploads = <String>[];
      for (final file in files) {
        final compressedFile = await ImageCompressor.compress(file.path);
        if (compressedFile == null) continue;
        final form = FormData.fromMap({
          'folder': 'temp/arena_onboarding',
          'file': await MultipartFile.fromFile(compressedFile.path, filename: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg'),
        });
        _log('pickPhotos: uploading ${file.path}');
        final response = await ApiClient.instance.dio.post('/media/upload', data: form, options: Options(contentType: 'multipart/form-data'));
        final payload = response.data as Map<String, dynamic>;
        final data = (payload['data'] ?? payload) as Map<String, dynamic>;
        final url = (data['publicUrl'] ?? data['url'] ?? data['link']) as String?;
        _log('pickPhotos: upload result url=$url');
        if (url != null && url.isNotEmpty) uploads.add(url);
      }
      _log('pickPhotos: total uploaded=${uploads.length} photoUrls=${_photoUrls.length + uploads.length}');
      setState(() => _photoUrls.addAll(uploads));
    } catch (e) {
      _log('pickPhotos: error $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Photo upload failed: $e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _next() async {
    _log('next: step=$_step');
    if (_step == 2 && !_locationPicked) {
      _log('next: blocked — location not picked');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please search and select your arena location')),
      );
      return;
    }
    final form = switch (_step) {
      1 => _basicKey,
      _ => null,
    };
    if (form != null && !form.currentState!.validate()) {
      _log('next: form validation failed at step=$_step');
      return;
    }
    if (_step == _steps.length - 1) return _submit();
    setState(() => _step++);
    _log('next: moved to step=$_step');
    await _page.nextPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  Future<void> _back() async {
    if (_step == 0) { context.pop(); return; }
    setState(() => _step--);
    await _page.previousPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    if (value.trim().length < 2) {
      setState(() { _suggestions = []; _searchLoading = false; });
      return;
    }
    setState(() => _searchLoading = true);
    _searchDebounce = Timer(const Duration(milliseconds: 450), () => _fetchSuggestions(value.trim()));
  }

  /// Returns lat/lng bias from the user's first existing arena, or null if none.
  ({double lat, double lng})? _locationBias() {
    final arenas = ref.read(ownedArenasProvider).valueOrNull ?? [];
    for (final a in arenas) {
      final lat = a.latitude;
      final lng = a.longitude;
      if (lat != null && lng != null) return (lat: lat, lng: lng);
    }
    return null;
  }

  Future<void> _fetchSuggestions(String query) async {
    // Return cached result — zero API cost
    if (_suggestionsCache.containsKey(query)) {
      _log('fetchSuggestions: cache hit for "$query" (${_suggestionsCache[query]!.length} results)');
      if (mounted) setState(() { _suggestions = _suggestionsCache[query]!; _searchLoading = false; });
      return;
    }
    _log('fetchSuggestions: querying Places API for "$query"');
    try {
      final bias = _locationBias();
      final uri = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
        'input': query,
        'key': _googlePlacesKey,
        'components': 'country:in',
        'language': 'en',
        'types': 'geocode|establishment',
        'sessiontoken': _placesSession,
        if (bias != null) 'location': '${bias.lat},${bias.lng}',
        if (bias != null) 'radius': '50000',
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      _log('fetchSuggestions: HTTP ${res.statusCode} body=${res.body.substring(0, res.body.length.clamp(0, 200))}');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final status = body['status'] as String? ?? '';
        final predictions = (body['predictions'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? [];
        _log('fetchSuggestions: status=$status predictions=${predictions.length}');
        _suggestionsCache[query] = predictions;
        if (mounted) setState(() { _suggestions = predictions; _searchLoading = false; });
      } else {
        _log('fetchSuggestions: non-200 response');
        if (mounted) setState(() { _suggestions = []; _searchLoading = false; });
      }
    } catch (e) {
      _log('fetchSuggestions: error $e');
      if (mounted) setState(() { _suggestions = []; _searchLoading = false; });
    }
  }

  Future<void> _selectSuggestion(Map<String, dynamic> prediction) async {
    final placeId = prediction['place_id'] as String? ?? '';
    final description = prediction['description'] as String? ?? '';
    _log('selectSuggestion: placeId=$placeId description="$description"');
    setState(() { _searchCtrl.text = description; _suggestions = []; _searchLoading = true; });

    try {
      final uri = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
        'place_id': placeId,
        'key': _googlePlacesKey,
        'fields': 'geometry,formatted_address,address_components',
        'language': 'en',
        'sessiontoken': _placesSession,
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      _log('selectSuggestion: HTTP ${res.statusCode}');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final status = body['status'] as String? ?? '';
        _log('selectSuggestion: status=$status');
        final result = body['result'] as Map<String, dynamic>? ?? {};
        final location = (result['geometry'] as Map<String, dynamic>?)?['location'] as Map<String, dynamic>?;
        final lat = location?['lat'] as double?;
        final lng = location?['lng'] as double?;
        final components = (result['address_components'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? [];

        String getComponent(List<String> types) {
          for (final c in components) {
            final t = (c['types'] as List?)?.cast<String>() ?? [];
            if (types.any((type) => t.contains(type))) return c['long_name'] as String? ?? '';
          }
          return '';
        }

        final streetNum = getComponent(['street_number']);
        final route = getComponent(['route']);
        final sublocality = getComponent(['sublocality_level_1', 'sublocality']);
        final city = getComponent(['locality']);
        final state = getComponent(['administrative_area_level_1']);
        final postcode = getComponent(['postal_code']);

        final addressParts = [if (streetNum.isNotEmpty) streetNum, if (route.isNotEmpty) route, if (sublocality.isNotEmpty) sublocality];
        final addressLine = addressParts.isNotEmpty ? addressParts.join(', ') : description.split(',').first;
        _log('selectSuggestion: lat=$lat lng=$lng city=$city state=$state postcode=$postcode address="$addressLine"');

        if (mounted) {
          setState(() {
            _address.text = addressLine;
            _city.text = city;
            _state.text = state;
            _pincode.text = postcode;
            if (lat != null) _latitude.text = lat.toStringAsFixed(6);
            if (lng != null) _longitude.text = lng.toStringAsFixed(6);
            _locationPicked = true;
            _searchLoading = false;
            _placesSession = _newSessionToken();
          });
        }
      }
    } catch (e) {
      _log('selectSuggestion: error $e');
      if (mounted) setState(() { _searchLoading = false; });
    }
  }

  Future<void> _submit() async {
    _log('submit: starting — name="${_name.text.trim()}" city="${_city.text.trim()}" state="${_state.text.trim()}" lat="${_latitude.text}" lng="${_longitude.text}" phone="${_phone.text.trim()}" sport=$_arenaType photos=${_photoUrls.length} openTime=$_openTime closeTime=$_closeTime parking=$_hasParking lights=$_hasLights washrooms=$_hasWashrooms canteen=$_hasCanteen cctv=$_hasCCTV scorer=$_hasScorer');
    setState(() => _saving = true);
    try {
      final arenaData = await ref.read(hostBizRepositoryProvider).createArena(ArenaProfileInput(
        name: _name.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        pincode: _pincode.text.trim().isEmpty ? '000000' : _pincode.text.trim(),
        description: _emptyToNull(_description.text),
        phone: _emptyToNull(_phone.text),
        sports: [_arenaType],
        latitude: _parseDouble(_latitude.text),
        longitude: _parseDouble(_longitude.text),
        photoUrls: _photoUrls,
        hasParking: _hasParking,
        hasLights: _hasLights,
        hasWashrooms: _hasWashrooms,
        hasCanteen: _hasCanteen,
        hasCCTV: _hasCCTV,
        hasScorer: _hasScorer,
        openTime: _openTime,
        closeTime: _closeTime,
      ));
      final arenaId = arenaData['id'] as String? ??
          (arenaData['data'] as Map<String, dynamic>?)?['id'] as String?;
      _log('submit: arena created id=$arenaId');
      await ref.read(sessionControllerProvider.notifier).setActiveProfile(BizProfileType.arena);
      ref.invalidate(meProvider);
      ref.invalidate(ownedArenasProvider);
      if (mounted && arenaId != null) {
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: _bg,
          builder: (_) => UnitEditorSheet(arenaId: arenaId),
        );
      }
      _log('submit: navigating to dashboard');
      if (mounted) context.go(AppRoutes.dashboard);
    } on DioException catch (e) {
      _log('submit: error $e');
      if (!mounted) return;
      final body = e.response?.data as Map?;
      final code = (body?['code'] ?? (body?['error'] as Map?)?['code']) as String?;
      final message = (body?['message'] ?? (body?['error'] as Map?)?['message'] ?? 'Could not create arena') as String;
      if (code == 'BUSINESS_DETAILS_REQUIRED') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete business details first')));
        context.go(AppRoutes.businessDetails);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (error) {
      _log('submit: error $error');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not create arena: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Add Arena'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _saving ? null : _back,
        ),
      ),
      body: SafeArea(
        child: Column(children: [
          _ProgressHeader(step: _step, steps: _steps),
          Expanded(child: PageView(controller: _page, physics: const NeverScrollableScrollPhysics(), children: [
            _ArenaTypeStep(selectedType: _arenaType, onChanged: (value) => setState(() => _arenaType = value)),
            _StepShell(title: 'Basic arena details', subtitle: 'Name, description and booking phone.', child: Form(key: _basicKey, child: ListView(padding: const EdgeInsets.all(20), children: [_Field(_name, 'Arena name', required: true), _Field(_description, 'Description', maxLines: 3), _Field(_phone, 'Booking confirmation phone number', required: true, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)], validator: (v) { final s = v?.trim() ?? ''; if (s.isEmpty) return 'Required'; if (s.length != 10) return 'Enter a valid 10-digit mobile number'; return null; })]))),
            _StepShell(
              title: 'Location',
              subtitle: 'Search your arena address to auto-fill all location details.',
              child: ListView(padding: const EdgeInsets.all(20), children: [
                // Search box
                TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: _inputDecoration(
                    'Search arena address...',
                    suffixIcon: _searchLoading
                        ? const Padding(padding: EdgeInsets.all(13), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                        : _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18, color: _muted),
                                onPressed: () => setState(() {
                                  _searchCtrl.clear();
                                  _suggestions = [];
                                  _searchLoading = false;
                                  _locationPicked = false;
                                  _searchDebounce?.cancel();
                                }),
                              )
                            : const Padding(padding: EdgeInsets.all(13), child: Icon(Icons.search_rounded, color: _muted, size: 20)),
                  ),
                ),
                // Suggestions dropdown
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _line),
                      boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 12, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      children: _suggestions.map((f) {
                        final sf = f['structured_formatting'] as Map<String, dynamic>? ?? {};
                        final title = sf['main_text'] as String? ?? f['description'] as String? ?? '';
                        final subtitle = sf['secondary_text'] as String? ?? '';
                        return InkWell(
                          onTap: () => _selectSuggestion(f),  // async, fire-and-forget
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(children: [
                              const Icon(Icons.location_on_outlined, size: 18, color: _accent),
                              const SizedBox(width: 10),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(title.isNotEmpty ? title : subtitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _text)),
                                if (subtitle.isNotEmpty && title.isNotEmpty)
                                  Text(subtitle, style: const TextStyle(fontSize: 12, color: _muted)),
                              ])),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                // Filled details (shown after selection)
                if (_locationPicked) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFBCFE8))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Location details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _accent)),
                      const SizedBox(height: 10),
                      _DetailRow('Address', _address.text),
                      _DetailRow('City', _city.text),
                      _DetailRow('State', _state.text),
                      if (_pincode.text.isNotEmpty) _DetailRow('Pincode', _pincode.text),
                      _DetailRow('Lat / Long', '${_latitude.text},  ${_longitude.text}'),
                    ]),
                  ),
                ],
              ]),
            ),
            _FacilitiesStep(
              openTime: _openTime,
              closeTime: _closeTime,
              hasParking: _hasParking,
              hasLights: _hasLights,
              hasWashrooms: _hasWashrooms,
              hasCanteen: _hasCanteen,
              hasCCTV: _hasCCTV,
              hasScorer: _hasScorer,
              onOpenTimePicked: (t) => setState(() => _openTime = t),
              onCloseTimePicked: (t) => setState(() => _closeTime = t),
              onToggle: (field, v) => setState(() {
                switch (field) {
                  case 'parking':   _hasParking = v;
                  case 'lights':    _hasLights = v;
                  case 'washrooms': _hasWashrooms = v;
                  case 'canteen':   _hasCanteen = v;
                  case 'cctv':      _hasCCTV = v;
                  case 'scorer':    _hasScorer = v;
                }
              }),
            ),
            _StepShell(title: 'Arena Photos', subtitle: 'Add up to 3 photos of your arena.', child: ListView(padding: const EdgeInsets.all(20), children: [
              if (_photoUrls.isNotEmpty) GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _photoUrls.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10), itemBuilder: (_, i) => Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_photoUrls[i], fit: BoxFit.cover, width: double.infinity, height: double.infinity)), Positioned(right: 4, top: 4, child: GestureDetector(onTap: () => setState(() => _photoUrls.removeAt(i)), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white))))])),
              const SizedBox(height: 20),
              if (_photoUrls.length < 3) OutlinedButton.icon(onPressed: _uploading ? null : _pickPhotos, icon: _uploading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add_a_photo_rounded), label: Text(_uploading ? 'Uploading...' : 'Add Photo'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))
            ])),
          ])),
          _BottomBar(step: _step, total: _steps.length, saving: _saving, onBack: _back, onNext: _next),
        ]),
      ),
    );
  }
}

class _SetupStep { const _SetupStep(this.label, this.icon); final String label; final IconData icon; }

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.step, required this.steps}); final int step; final List<_SetupStep> steps;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 12), child: Column(children: [Row(children: [Text('Step ${step + 1} of ${steps.length}', style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w800)), const Spacer(), Icon(steps[step].icon, size: 18, color: _muted), const SizedBox(width: 6), Text(steps[step].label, style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w900))]), const SizedBox(height: 10), Row(children: List.generate(steps.length, (i) => Expanded(child: Container(margin: EdgeInsets.only(right: i == steps.length - 1 ? 0 : 6), height: 5, decoration: BoxDecoration(color: i <= step ? _deep : _line, borderRadius: BorderRadius.circular(99))))))]));
}

class _StepShell extends StatelessWidget {
  const _StepShell({required this.title, required this.subtitle, required this.child}); final String title, subtitle; final Widget child;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _text, fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(subtitle, style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w600))])), Expanded(child: child)]);
}

class _SportEntry {
  const _SportEntry(this.key, this.label, this.icon, {this.locked = false});
  final String key;
  final String label;
  final IconData icon;
  final bool locked;
}

class _ArenaTypeStep extends StatelessWidget {
  const _ArenaTypeStep({required this.selectedType, required this.onChanged});
  final String selectedType;
  final ValueChanged<String> onChanged;

  static const sports = [
    _SportEntry('CRICKET', 'Cricket', Icons.sports_cricket_rounded),
    _SportEntry('FOOTBALL', 'Football', Icons.sports_soccer_rounded, locked: true),
    _SportEntry('FUTSAL', 'Futsal', Icons.sports_soccer_rounded, locked: true),
    _SportEntry('BADMINTON', 'Badminton', Icons.sports_tennis_rounded, locked: true),
    _SportEntry('PICKLEBALL', 'Pickleball', Icons.sports_tennis_rounded, locked: true),
    _SportEntry('BASKETBALL', 'Basketball', Icons.sports_basketball_rounded, locked: true),
  ];

  @override
  Widget build(BuildContext context) => _StepShell(
    title: 'Type of arena',
    subtitle: 'Choose the primary sport for this arena.',
    child: GridView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sports.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.18),
      itemBuilder: (ctx, i) {
        final s = sports[i];
        return _ChoiceTile(
          title: s.label,
          icon: s.icon,
          selected: selectedType == s.key,
          locked: s.locked,
          onTap: s.locked
              ? () => ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('${s.label} arenas coming soon'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  )
              : () => onChanged(s.key),
        );
      },
    ),
  );
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.locked = false,
  });
  final String title;
  final IconData icon;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = locked ? const Color(0xFFF9FAFB) : (selected ? _deep : _surface);
    final borderColor = locked ? _line : (selected ? _deep : _line);
    final iconColor = locked ? const Color(0xFFC5C7CF) : (selected ? Colors.white : _deep);
    final labelColor = locked ? const Color(0xFF9CA3AF) : (selected ? Colors.white : _text);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 28),
                  const Spacer(),
                  if (locked)
                    const Icon(Icons.lock_rounded, size: 15, color: Color(0xFFC5C7CF)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(color: labelColor, fontSize: 15, fontWeight: FontWeight.w900)),
                        if (locked)
                          const Text('Coming soon', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  if (selected && !locked)
                    const Icon(Icons.check_circle_rounded, color: _accent, size: 19),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.controller, this.label, {this.required = false, this.maxLines = 1, this.keyboardType, this.inputFormatters, this.validator}); final TextEditingController controller; final String label; final bool required; final int maxLines; final TextInputType? keyboardType; final List<TextInputFormatter>? inputFormatters; final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(controller: controller, maxLines: maxLines, keyboardType: keyboardType, inputFormatters: inputFormatters, validator: validator ?? (required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null), decoration: _inputDecoration(label)));
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.step, required this.total, required this.saving, required this.onBack, required this.onNext}); final int step, total; final bool saving; final VoidCallback onBack, onNext;
  @override
  Widget build(BuildContext context) { final isLast = step == total - 1; return Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: _bg, border: Border(top: BorderSide(color: _line))), child: Row(children: [Expanded(child: OutlinedButton(onPressed: saving ? null : onBack, child: Text(step == 0 ? 'Cancel' : 'Back'))), const SizedBox(width: 12), Expanded(child: FilledButton(onPressed: saving ? null : onNext, style: FilledButton.styleFrom(backgroundColor: _deep, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(isLast ? 'Create Arena' : 'Next')))])); }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12, color: _muted, fontWeight: FontWeight.w700))),
      Expanded(child: Text(value.isEmpty ? '—' : value, style: const TextStyle(fontSize: 12, color: _text, fontWeight: FontWeight.w700))),
    ]),
  );
}

class _FacilitiesStep extends StatelessWidget {
  const _FacilitiesStep({
    required this.openTime,
    required this.closeTime,
    required this.hasParking,
    required this.hasLights,
    required this.hasWashrooms,
    required this.hasCanteen,
    required this.hasCCTV,
    required this.hasScorer,
    required this.onOpenTimePicked,
    required this.onCloseTimePicked,
    required this.onToggle,
  });

  final String openTime, closeTime;
  final bool hasParking, hasLights, hasWashrooms, hasCanteen, hasCCTV, hasScorer;
  final ValueChanged<String> onOpenTimePicked, onCloseTimePicked;
  final void Function(String field, bool value) onToggle;

  Future<void> _pickTime(BuildContext context, String current, ValueChanged<String> onPicked) async {
    final parts = current.split(':');
    final h = int.tryParse(parts[0]) ?? 6;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: h, minute: m),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    onPicked('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
  }

  @override
  Widget build(BuildContext context) {
    Widget timeChip(String label, String time, ValueChanged<String> onPicked) {
      return Expanded(
        child: GestureDetector(
          onTap: () => _pickTime(context, time, onPicked),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _deep),
          ),
          child: Row(children: [
              const Icon(Icons.schedule_rounded, size: 15, color: _accent),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: const TextStyle(fontSize: 10, color: _muted, fontWeight: FontWeight.w600)),
                Text(time, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _text)),
              ]),
            ]),
          ),
        ),
      );
    }

    Widget toggle(String field, String label, IconData icon, bool value) {
      return GestureDetector(
        onTap: () => onToggle(field, !value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: value ? _deep : _surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: value ? _deep : _line),
          ),
          child: Row(children: [
            Icon(icon, size: 18, color: value ? Colors.white : _muted),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: value ? Colors.white : _text))),
            Icon(value ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 18, color: value ? _accent : _line),
          ]),
        ),
      );
    }

    return _StepShell(
      title: 'Facilities',
      subtitle: 'Operating hours and amenities players will see on your arena page.',
      child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('OPERATING HOURS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _muted, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Row(children: [
          timeChip('Opens at', openTime, onOpenTimePicked),
          const SizedBox(width: 10),
          timeChip('Closes at', closeTime, onCloseTimePicked),
        ]),
        const SizedBox(height: 24),
        const Text('AMENITIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _muted, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        toggle('parking',   'Parking',        Icons.local_parking_rounded,     hasParking),
        const SizedBox(height: 8),
        toggle('lights',    'Floodlights',     Icons.wb_incandescent_rounded,   hasLights),
        const SizedBox(height: 8),
        toggle('washrooms', 'Washrooms',       Icons.wc_rounded,                hasWashrooms),
        const SizedBox(height: 8),
        toggle('canteen',   'Canteen / Food',  Icons.restaurant_rounded,        hasCanteen),
        const SizedBox(height: 8),
        toggle('cctv',      'CCTV',            Icons.videocam_rounded,          hasCCTV),
        const SizedBox(height: 8),
        toggle('scorer',    'Scorer',          Icons.scoreboard_rounded,        hasScorer),
      ]),
    );
  }
}

InputDecoration _inputDecoration(String label, {Widget? suffixIcon, String? helperText}) => InputDecoration(labelText: label, suffixIcon: suffixIcon, helperText: helperText, helperMaxLines: 2, filled: true, fillColor: _surface, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _line)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _line)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _deep, width: 1.4)));
String _newSessionToken() => DateTime.now().millisecondsSinceEpoch.toRadixString(36);
String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();
double? _parseDouble(String v) => v.trim().isEmpty ? null : double.tryParse(v.trim());
