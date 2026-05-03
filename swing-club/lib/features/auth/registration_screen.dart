import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final String phone;
  const RegistrationScreen({super.key, required this.phone});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dio = Dio();

  String? _city;
  String? _state;
  List<dynamic> _suggestions = [];
  Timer? _debounce;
  bool _isSearching = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onAddressChanged(String v) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _fetchSuggestions(v));
  }

  Future<void> _fetchSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final res = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': input,
          'key': kGooglePlacesKey,
          'components': 'country:in',
          'types': 'geocode|establishment',
        },
      );
      if (res.data['status'] == 'OK') {
        setState(() => _suggestions = res.data['predictions'] as List);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _selectPlace(Map<String, dynamic> suggestion) async {
    final placeId = suggestion['place_id'] as String;
    setState(() {
      _addressController.text = suggestion['description'] as String;
      _suggestions = [];
    });
    try {
      final res = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': kGooglePlacesKey,
          'fields': 'address_components',
        },
      );
      if (res.data['status'] == 'OK') {
        final components = res.data['result']['address_components'] as List;
        for (final c in components) {
          final types = c['types'] as List;
          if (types.contains('locality')) _city = c['long_name'] as String;
          if (types.contains('administrative_area_level_1')) _state = c['long_name'] as String;
        }
      }
    } catch (_) {}
  }

  Future<String?> _sendOtp(String phone) async {
    try {
      final res = await _dio.get(
        'https://2factor.in/API/V1/$kTwoFactorKey/SMS/$phone/AUTOGEN',
      );
      if (res.data['Status'] == 'Success') return res.data['Details'] as String;
    } catch (_) {}
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final sessionId = await _sendOtp(widget.phone);
    if (mounted) setState(() => _isLoading = false);

    if (sessionId == null) {
      if (mounted) showSnack(context, 'Failed to send OTP. Try again.');
      return;
    }
    if (!mounted) return;
    context.push('/otp', extra: {
      'phone': widget.phone,
      'sessionId': sessionId,
      'isNewUser': true,
      'name': _nameController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _city ?? '',
      'state': _state ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academy Onboarding')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Set up your academy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Provide details to register.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Owner Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                onChanged: _onAddressChanged,
                decoration: InputDecoration(
                  labelText: 'Academy Address',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              if (_suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE0DED6)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final s = _suggestions[i] as Map<String, dynamic>;
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.place_outlined, size: 18),
                        title: Text(s['description'] as String,
                            style: const TextStyle(fontSize: 13)),
                        onTap: () => _selectPlace(s),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Continue to Verify',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
