import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';

// ── Progress bar (step 1 or 2 of onboarding) ─────────────────────────────────
class OnboardingProgressBar extends StatelessWidget {
  final int step; // 1 or 2
  const OnboardingProgressBar({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(2, (i) {
        final active = i < step;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
            height: 4,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF071B3D) : const Color(0xFFE0DED6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class OnboardingSectionLabel extends StatelessWidget {
  final String label;
  final bool required;
  const OnboardingSectionLabel({super.key, required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF071B3D)),
        ),
        if (required) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0057C8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Required',
              style: TextStyle(fontSize: 11, color: Color(0xFF0057C8), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Reusable form field ────────────────────────────────────────────────────────
class OnboardingField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool uppercase;

  const OnboardingField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.uppercase = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: [
          ...?inputFormatters,
          if (uppercase) _UpperCaseFormatter(),
        ],
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xFF071B3D),
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0DED6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0DED6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF071B3D), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) =>
      next.copyWith(text: next.text.toUpperCase());
}

// ── Google Places address search ───────────────────────────────────────────────
class PlacesSearchField extends StatefulWidget {
  final void Function({
    required String address,
    required String city,
    required String state,
    required String pincode,
    double? lat,
    double? lng,
  }) onPlaceSelected;

  const PlacesSearchField({super.key, required this.onPlaceSelected});

  @override
  State<PlacesSearchField> createState() => _PlacesSearchFieldState();
}

class _PlacesSearchFieldState extends State<PlacesSearchField> {
  final _ctrl = TextEditingController();
  final _dio  = Dio();
  List<Map<String, dynamic>> _suggestions = [];
  bool _searching = false;
  Timer? _debounce;

  void _onChanged(String val) {
    _debounce?.cancel();
    if (val.trim().length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () => _fetchSuggestions(val.trim()));
  }

  Future<void> _fetchSuggestions(String input) async {
    if (!mounted) return;
    setState(() => _searching = true);
    try {
      final res = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': input,
          'key': kGooglePlacesKey,
          'components': 'country:in',
          'language': 'en',
        },
      );
      if (mounted) {
        if (res.data['status'] == 'OK') {
          setState(() => _suggestions = List<Map<String, dynamic>>.from(res.data['predictions']));
        } else {
          setState(() => _suggestions = []);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _searching = false);
  }

  Future<void> _selectPlace(String placeId, String description) async {
    _ctrl.text = description;
    setState(() => _suggestions = []);
    try {
      final res = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': kGooglePlacesKey,
          'fields': 'address_components,geometry,formatted_address',
        },
      );
      if (res.data['status'] != 'OK') return;
      final result     = res.data['result'] as Map<String, dynamic>;
      final components = List<Map<String, dynamic>>.from(result['address_components'] as List);
      final geo        = result['geometry']?['location'];

      String city = '', state = '', pincode = '';
      double? lat, lng;

      if (geo != null) {
        lat = (geo['lat'] as num).toDouble();
        lng = (geo['lng'] as num).toDouble();
      }

      for (final c in components) {
        final types = List<String>.from(c['types'] as List);
        final name  = c['long_name'] as String;
        if (types.contains('locality')) city = name;
        if (types.contains('sublocality_level_1') && city.isEmpty) city = name;
        if (types.contains('administrative_area_level_1')) state = name;
        if (types.contains('postal_code')) pincode = name;
      }

      widget.onPlaceSelected(
        address: result['formatted_address'] as String? ?? description,
        city: city,
        state: state,
        pincode: pincode,
        lat: lat,
        lng: lng,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: _ctrl,
            onChanged: _onChanged,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF071B3D)),
            decoration: InputDecoration(
              labelText: 'Search address',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0DED6))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0DED6))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF071B3D), width: 1.5)),
            ),
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0DED6)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFE0DED6)),
              itemBuilder: (_, i) {
                final s         = _suggestions[i];
                final mainText  = s['structured_formatting']?['main_text'] as String? ?? s['description'] as String;
                final subText   = s['structured_formatting']?['secondary_text'] as String? ?? '';
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _selectPlace(s['place_id'] as String, s['description'] as String),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 18, color: Color(0xFF0057C8)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mainText, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF071B3D))),
                              if (subText.isNotEmpty)
                                Text(subText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ── Pincode → city/state auto-lookup ─────────────────────────────────────────
class PincodeLocationField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String city, String state) onResolved;

  const PincodeLocationField({
    super.key,
    required this.controller,
    required this.onResolved,
  });

  @override
  State<PincodeLocationField> createState() => _PincodeLocationFieldState();
}

class _PincodeLocationFieldState extends State<PincodeLocationField> {
  final _dio = Dio();
  bool _loading = false;
  String? _info;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    if (widget.controller.text.trim().length == 6) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _lookup(widget.controller.text.trim()));
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _dio.close();
    super.dispose();
  }

  void _onChanged() {
    final val = widget.controller.text.trim();
    if (val.length == 6) {
      _lookup(val);
    } else if (_info != null) {
      setState(() { _info = null; _success = false; });
    }
  }

  Future<void> _lookup(String pincode) async {
    if (!mounted) return;
    setState(() { _loading = true; _info = null; _success = false; });
    try {
      final res = await _dio.get('https://api.postalpincode.in/pincode/$pincode');
      if (!mounted) return;
      final list = res.data as List;
      if (list.isNotEmpty && list[0]['Status'] == 'Success') {
        final offices = list[0]['PostOffice'] as List? ?? [];
        if (offices.isNotEmpty) {
          final o     = offices[0] as Map;
          final city  = o['District'] as String? ?? '';
          final state = o['State']    as String? ?? '';
          setState(() { _info = '$city, $state'; _success = true; });
          widget.onResolved(city, state);
          return;
        }
      }
      setState(() => _info = 'Pincode not found');
    } catch (_) {
      if (mounted) setState(() => _info = 'Lookup failed');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: widget.controller,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF071B3D)),
            decoration: InputDecoration(
              labelText: 'Pincode',
              prefixIcon: const Icon(Icons.pin_drop_outlined, size: 20),
              suffixIcon: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : _success
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 20)
                      : null,
              fillColor: Colors.white,
              filled: true,
              counterText: '',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0DED6))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE0DED6))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF071B3D), width: 1.5)),
            ),
          ),
          if (_info != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 2, bottom: 4),
              child: Text(
                _info!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _success ? const Color(0xFF22C55E) : Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
