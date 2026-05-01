import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
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

const _bg = Color(0xFFF3F4F6);
const _surface = Color(0xFFFFFFFF);
const _line = Color(0xFFE1E5EA);
const _text = Color(0xFF0D1117);
const _muted = Color(0xFF6E7685);
const _accent = Color(0xFF059669);
const _deep = Color(0xFF064E3B);

class CreateArenaScreen extends ConsumerStatefulWidget {
  const CreateArenaScreen({super.key});

  @override
  ConsumerState<CreateArenaScreen> createState() => _CreateArenaScreenState();
}

class _CreateArenaScreenState extends ConsumerState<CreateArenaScreen> {
  final _page = PageController();
  final _basicKey = GlobalKey<FormState>();
  final _locationKey = GlobalKey<FormState>();

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
  bool _pincodeLoading = false;
  String _arenaType = 'CRICKET';
  String? _pincodeMessage;
  Timer? _pincodeDebounce;
  final List<String> _photoUrls = [];

  static const _steps = [
    _SetupStep('Type', Icons.category_rounded),
    _SetupStep('Basics', Icons.edit_note_rounded),
    _SetupStep('Location', Icons.location_on_rounded),
    _SetupStep('Photos', Icons.add_a_photo_rounded),
  ];

  @override
  void dispose() {
    for (final controller in [_name, _description, _phone, _address, _city, _state, _pincode, _latitude, _longitude]) {
      controller.dispose();
    }
    _pincodeDebounce?.cancel();
    _page.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final files = await ImagePicker().pickMultiImage();
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
        final response = await ApiClient.instance.dio.post('/media/upload', data: form, options: Options(contentType: 'multipart/form-data'));
        final payload = response.data as Map<String, dynamic>;
        final data = (payload['data'] ?? payload) as Map<String, dynamic>;
        final url = (data['publicUrl'] ?? data['url'] ?? data['link']) as String?;
        if (url != null && url.isNotEmpty) uploads.add(url);
      }
      setState(() => _photoUrls.addAll(uploads));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Photo upload failed: $e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _next() async {
    final form = switch (_step) {
      1 => _basicKey,
      2 => _locationKey,
      _ => null,
    };
    if (form != null && !form.currentState!.validate()) return;
    if (_step == _steps.length - 1) return _submit();
    setState(() => _step++);
    await _page.nextPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  Future<void> _back() async {
    if (_step == 0) { context.pop(); return; }
    setState(() => _step--);
    await _page.previousPage(duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  Future<void> _submit() async {
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
      ));
      final arenaId = arenaData['id'] as String? ??
          (arenaData['data'] as Map<String, dynamic>?)?['id'] as String?;
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
      if (mounted) context.go(AppRoutes.dashboard);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not create arena: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _onPincodeChanged(String value) {
    _pincodeDebounce?.cancel();
    final pincode = value.trim();
    if (pincode.length != 6) { setState(() { _pincodeLoading = false; _pincodeMessage = null; }); return; }
    _pincodeDebounce = Timer(const Duration(milliseconds: 450), () => _lookupPincode(pincode));
  }

  Future<void> _lookupPincode(String pincode) async {
    setState(() { _pincodeLoading = true; _pincodeMessage = null; });
    try {
      // Step 1: pincode → city + state
      final response = await Dio().get<List<dynamic>>('https://api.postalpincode.in/pincode/$pincode', options: Options(receiveTimeout: const Duration(seconds: 8), sendTimeout: const Duration(seconds: 8)));
      final payload = response.data;
      final first = payload?.isNotEmpty == true ? payload!.first : null;
      if (first is! Map || first['Status'] != 'Success') { if (mounted) setState(() => _pincodeMessage = 'No location found for this pincode'); return; }
      final postOffices = first['PostOffice'];
      final office = postOffices is List && postOffices.isNotEmpty ? postOffices.first : null;
      if (office is! Map) { if (mounted) setState(() => _pincodeMessage = 'No location found for this pincode'); return; }
      final district = '${office['District'] ?? ''}'.trim();
      final state = '${office['State'] ?? ''}'.trim();
      if (mounted) setState(() {
        if (district.isNotEmpty) _city.text = _titleCase(district);
        if (state.isNotEmpty) _state.text = _titleCase(state);
        _pincodeMessage = 'City and state filled — fetching coordinates...';
      });

      // Step 2: pincode → lat/long via Nominatim (OpenStreetMap)
      final geo = await Dio().get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {'postalcode': pincode, 'country': 'India', 'format': 'json', 'limit': '1'},
        options: Options(
          headers: {'User-Agent': 'SwingBizApp/1.0'},
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );
      final places = geo.data;
      if (places != null && places.isNotEmpty) {
        final place = places.first as Map<String, dynamic>;
        final lat = place['lat'] as String?;
        final lon = place['lon'] as String?;
        if (mounted && lat != null && lon != null) {
          setState(() {
            _latitude.text = double.parse(lat).toStringAsFixed(6);
            _longitude.text = double.parse(lon).toStringAsFixed(6);
            _pincodeMessage = 'Location auto-filled from pincode ✓';
          });
        }
      } else {
        if (mounted) setState(() => _pincodeMessage = 'City/state filled. Enter coordinates manually.');
      }
    } catch (_) {
      if (mounted) setState(() => _pincodeMessage = 'Could not fetch location details');
    } finally {
      if (mounted) setState(() => _pincodeLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(title: const Text('Add Arena'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: _saving ? null : _back)),
      body: SafeArea(
        child: Column(children: [
          _ProgressHeader(step: _step, steps: _steps),
          Expanded(child: PageView(controller: _page, physics: const NeverScrollableScrollPhysics(), children: [
            _ArenaTypeStep(selectedType: _arenaType, onChanged: (value) => setState(() => _arenaType = value)),
            _StepShell(title: 'Basic arena details', subtitle: 'Name, description and booking phone.', child: Form(key: _basicKey, child: ListView(padding: const EdgeInsets.all(20), children: [_Field(_name, 'Arena name', required: true), _Field(_description, 'Description', maxLines: 3), _Field(_phone, 'Booking confirmation phone number', required: true, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)])]))),
            _StepShell(title: 'Location', subtitle: 'Keep latitude and longitude for map accuracy.', child: Form(key: _locationKey, child: ListView(padding: const EdgeInsets.all(20), children: [_Field(_pincode, 'Pincode', required: true, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)], onChanged: _onPincodeChanged, trailing: _pincodeLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : null, helperText: _pincodeMessage), _Field(_city, 'City', required: true), _Field(_state, 'State', required: true), _Field(_address, 'Address', required: true), Row(children: [Expanded(child: _Field(_latitude, 'Latitude', keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true))), const SizedBox(width: 10), Expanded(child: _Field(_longitude, 'Longitude', keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true)))])]))),
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
    final iconColor = locked ? const Color(0xFFCBD5E0) : (selected ? Colors.white : _deep);
    final labelColor = locked ? const Color(0xFFB0B8C4) : (selected ? Colors.white : _text);

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
                    const Icon(Icons.lock_rounded, size: 15, color: Color(0xFFCBD5E0)),
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
                          const Text('Coming soon', style: TextStyle(color: Color(0xFFB0B8C4), fontSize: 11, fontWeight: FontWeight.w600)),
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
  const _Field(this.controller, this.label, {this.required = false, this.maxLines = 1, this.keyboardType, this.inputFormatters, this.onChanged, this.trailing, this.helperText}); final TextEditingController controller; final String label; final bool required; final int maxLines; final TextInputType? keyboardType; final List<TextInputFormatter>? inputFormatters; final ValueChanged<String>? onChanged; final Widget? trailing; final String? helperText;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(controller: controller, maxLines: maxLines, keyboardType: keyboardType, inputFormatters: inputFormatters, onChanged: onChanged, validator: required ? (v) => v == null || v.trim().isEmpty ? 'Required' : null : null, decoration: _inputDecoration(label, suffixIcon: trailing, helperText: helperText)));
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.step, required this.total, required this.saving, required this.onBack, required this.onNext}); final int step, total; final bool saving; final VoidCallback onBack, onNext;
  @override
  Widget build(BuildContext context) { final isLast = step == total - 1; return Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: _bg, border: Border(top: BorderSide(color: _line))), child: Row(children: [Expanded(child: OutlinedButton(onPressed: saving ? null : onBack, child: Text(step == 0 ? 'Cancel' : 'Back'))), const SizedBox(width: 12), Expanded(child: FilledButton(onPressed: saving ? null : onNext, style: FilledButton.styleFrom(backgroundColor: _deep, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(isLast ? 'Create Arena' : 'Next')))])); }
}

InputDecoration _inputDecoration(String label, {Widget? suffixIcon, String? helperText}) => InputDecoration(labelText: label, suffixIcon: suffixIcon == null ? null : Padding(padding: const EdgeInsets.all(13), child: suffixIcon), helperText: helperText, helperMaxLines: 2, filled: true, fillColor: _surface, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _line)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _line)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _deep, width: 1.4)));
String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();
double? _parseDouble(String v) => v.trim().isEmpty ? null : double.tryParse(v.trim());
String _titleCase(String v) => v.toLowerCase().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).map((p) => p[0].toUpperCase() + p.substring(1)).join(' ');
