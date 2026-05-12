import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/auth/me_providers.dart';
import '../../arena/services/arena_profile_providers.dart';

const _kGooglePlacesKey = 'AIzaSyDpJ1S4JYO-jVA6BgzxM1LYjdSvrSrTkTo';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TabController _tab;

  final _businessName = TextEditingController();
  final _contactName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  final _gst = TextEditingController();
  final _pan = TextEditingController();
  final _beneficiaryName = TextEditingController();
  final _accountNumber = TextEditingController();
  final _ifsc = TextEditingController();
  final _upi = TextEditingController();

  bool _editMode = false;
  bool _saving = false;
  bool _fetchingPincode = false;
  String? _loadedAccountId;

  final _addressSearchCtrl = TextEditingController();
  Timer? _placesDebounce;
  bool _placesLoading = false;
  List<Map<String, dynamic>> _placeSuggestions = [];
  String _placesSession =
      DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _businessName.dispose();
    _contactName.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    _pincode.dispose();
    _gst.dispose();
    _pan.dispose();
    _beneficiaryName.dispose();
    _accountNumber.dispose();
    _ifsc.dispose();
    _upi.dispose();
    _addressSearchCtrl.dispose();
    _placesDebounce?.cancel();
    super.dispose();
  }

  void _onAddressSearchChanged(String v) {
    _placesDebounce?.cancel();
    if (v.trim().length < 2) {
      setState(() {
        _placeSuggestions = [];
        _placesLoading = false;
      });
      return;
    }
    setState(() => _placesLoading = true);
    _placesDebounce = Timer(
      const Duration(milliseconds: 450),
      () => _fetchPlacePredictions(v.trim()),
    );
  }

  Future<void> _fetchPlacePredictions(String query) async {
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {
          'input': query,
          'key': _kGooglePlacesKey,
          'components': 'country:in',
          'language': 'en',
          'types': 'geocode|establishment',
          'sessiontoken': _placesSession,
        },
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final preds = (body['predictions'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            [];
        setState(() {
          _placeSuggestions = preds;
          _placesLoading = false;
        });
      } else {
        setState(() {
          _placeSuggestions = [];
          _placesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _placeSuggestions = [];
          _placesLoading = false;
        });
      }
    }
  }

  Future<void> _selectPlace(Map<String, dynamic> pred) async {
    final placeId = pred['place_id'] as String? ?? '';
    final desc = pred['description'] as String? ?? '';
    setState(() {
      _addressSearchCtrl.text = desc;
      _placeSuggestions = [];
      _placesLoading = true;
    });
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {
          'place_id': placeId,
          'key': _kGooglePlacesKey,
          'fields': 'address_components',
          'language': 'en',
          'sessiontoken': _placesSession,
        },
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (res.statusCode == 200) {
        final result = ((jsonDecode(res.body) as Map<String, dynamic>)['result']
                as Map<String, dynamic>?) ??
            {};
        final components = (result['address_components'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            [];

        String pick(List<String> types) {
          for (final c in components) {
            final t = (c['types'] as List?)?.cast<String>() ?? const [];
            if (types.any(t.contains)) {
              return c['long_name'] as String? ?? '';
            }
          }
          return '';
        }

        final streetNum = pick(['street_number']);
        final route = pick(['route']);
        final sub = pick(['sublocality_level_1', 'sublocality']);
        final city = pick(['locality']);
        final state = pick(['administrative_area_level_1']);
        final pin = pick(['postal_code']);
        final parts = [
          if (streetNum.isNotEmpty) streetNum,
          if (route.isNotEmpty) route,
          if (sub.isNotEmpty) sub,
        ];
        final address =
            parts.isNotEmpty ? parts.join(', ') : desc.split(',').first;

        setState(() {
          _address.text = address;
          if (city.isNotEmpty) _city.text = city;
          if (state.isNotEmpty) _state.text = state;
          if (pin.isNotEmpty) _pincode.text = pin;
          _placesSession =
              DateTime.now().millisecondsSinceEpoch.toString();
          _placesLoading = false;
        });
      } else {
        if (mounted) setState(() => _placesLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _placesLoading = false);
    }
  }

  Future<void> _lookupPincode(String pincode) async {
    if (pincode.length != 6) return;
    setState(() => _fetchingPincode = true);
    try {
      final res = await http
          .get(Uri.parse('https://api.postalpincode.in/pincode/$pincode'))
          .timeout(const Duration(seconds: 6));
      if (!mounted) return;
      final data = jsonDecode(res.body) as List;
      if (data.isNotEmpty && data[0]['Status'] == 'Success') {
        final offices = data[0]['PostOffice'] as List;
        if (offices.isNotEmpty) {
          final office = offices[0] as Map<String, dynamic>;
          setState(() {
            _city.text = office['District'] as String? ?? _city.text;
            _state.text = office['State'] as String? ?? _state.text;
          });
        }
      }
    } catch (_) {
      // silently ignore — user can fill manually
    } finally {
      if (mounted) setState(() => _fetchingPincode = false);
    }
  }

  void _sync(BizMeResponse me) {
    final b = me.businessAccount;
    final key = b?.id ?? 'new:${me.user.id}';
    if (_loadedAccountId == key) return;
    _loadedAccountId = key;

    final arenas = ref.read(ownedArenasProvider).valueOrNull ?? [];
    final a = arenas.isNotEmpty ? arenas.first : null;

    _businessName.text = b?.businessName ?? a?.name ?? '';
    _contactName.text = b?.contactName ?? me.user.name ?? '';
    _phone.text = b?.phone ?? a?.phone ?? me.user.phone;
    _email.text = b?.email ?? me.user.email ?? '';
    _address.text =
        b?.address?.isNotEmpty == true ? b!.address! : (a?.address ?? '');
    _city.text = b?.city?.isNotEmpty == true ? b!.city! : (a?.city ?? '');
    _state.text = b?.state?.isNotEmpty == true ? b!.state! : (a?.state ?? '');
    _pincode.text =
        b?.pincode?.isNotEmpty == true ? b!.pincode! : (a?.pincode ?? '');
    _gst.text = b?.gstNumber ?? '';
    _pan.text = b?.panNumber ?? '';
    _beneficiaryName.text = b?.beneficiaryName ?? '';
    _accountNumber.text = b?.accountNumber ?? '';
    _ifsc.text = b?.ifscCode ?? '';
    _upi.text = b?.upiId ?? '';
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _optionalEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!text.contains('@')) return 'Enter a valid email';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(hostBizRepositoryProvider).upsertBusinessDetails(
            BusinessDetailsInput(
              businessName: _businessName.text.trim(),
              contactName: _contactName.text.trim(),
              phone: _phone.text.trim(),
              email: _email.text.trim(),
              address: _address.text.trim(),
              city: _city.text.trim(),
              state: _state.text.trim(),
              pincode: _pincode.text.trim(),
              gstNumber: _gst.text.trim(),
              panNumber: _pan.text.trim(),
              beneficiaryName: _beneficiaryName.text.trim(),
              accountNumber: _accountNumber.text.trim(),
              ifscCode: _ifsc.text.trim().toUpperCase(),
              upiId: _upi.text.trim(),
            ),
          );
      ref.invalidate(meProvider);
      if (!mounted) return;
      setState(() {
        _editMode = false;
        _saving = false;
        _loadedAccountId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meAsync = ref.watch(meProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_editMode)
            IconButton(
              tooltip: 'Edit',
              onPressed: () => setState(() => _editMode = true),
              icon: const Icon(Icons.edit_rounded),
            )
          else
            IconButton(
              tooltip: 'Cancel',
              onPressed:
                  _saving ? null : () => setState(() => _editMode = false),
              icon: const Icon(Icons.close_rounded),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: meAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (me) {
          if (me == null) return const SizedBox();
          _sync(me);
          final b = me.businessAccount;
          final title = b?.businessName ?? me.user.name ?? 'Business Profile';
          final initial = title.isNotEmpty ? title[0].toUpperCase() : 'B';
          return Form(
            key: _formKey,
            child: Column(
              children: [
                _ProfileHeader(
                  initial: initial,
                  title: title,
                  subtitle: me.user.phone,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TabBar(
                    controller: _tab,
                    tabs: const [
                      Tab(text: 'Account'),
                      Tab(text: 'Business'),
                      Tab(text: 'Banking'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _ProfileFieldList(children: [
                        _ProfileTextField(
                            controller: _contactName,
                            label: 'Contact name',
                            icon: Icons.person_outline_rounded,
                            enabled: _editMode),
                        _ProfileTextField(
                            controller: _phone,
                            label: 'Phone',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            enabled: _editMode),
                        _ProfileTextField(
                            controller: _email,
                            label: 'Email',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: _optionalEmail,
                            enabled: _editMode),
                      ]),
                      _ProfileFieldList(children: [
                        _ProfileTextField(
                            controller: _businessName,
                            label: 'Business name',
                            icon: Icons.business_outlined,
                            validator: _required,
                            enabled: _editMode),
                        if (_editMode)
                          _PlacesSearchField(
                            controller: _addressSearchCtrl,
                            loading: _placesLoading,
                            suggestions: _placeSuggestions,
                            onChanged: _onAddressSearchChanged,
                            onClear: () => setState(() {
                              _addressSearchCtrl.clear();
                              _placeSuggestions = [];
                            }),
                            onSelect: _selectPlace,
                          ),
                        _ProfileTextField(
                            controller: _address,
                            label: 'Address',
                            icon: Icons.location_on_outlined,
                            maxLines: 2,
                            enabled: _editMode),
                        Row(children: [
                          Expanded(
                              child: _ProfileTextField(
                                  controller: _city,
                                  label: 'City',
                                  icon: Icons.location_city_outlined,
                                  enabled: _editMode)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _ProfileTextField(
                                  controller: _state,
                                  label: 'State',
                                  icon: Icons.map_outlined,
                                  enabled: _editMode)),
                        ]),
                        _ProfileTextField(
                          controller: _pincode,
                          label: 'Pincode',
                          icon: Icons.pin_drop_outlined,
                          keyboardType: TextInputType.number,
                          enabled: _editMode,
                          onChanged: _editMode ? _lookupPincode : null,
                          suffixIcon: _fetchingPincode
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : null,
                        ),
                        _ProfileTextField(
                            controller: _gst,
                            label: 'GST',
                            icon: Icons.receipt_long_outlined,
                            enabled: _editMode),
                        _ProfileTextField(
                            controller: _pan,
                            label: 'PAN',
                            icon: Icons.credit_card_outlined,
                            enabled: _editMode),
                      ]),
                      _ProfileFieldList(children: [
                        _ProfileTextField(
                            controller: _beneficiaryName,
                            label: 'Beneficiary name',
                            icon: Icons.badge_outlined,
                            enabled: _editMode),
                        _ProfileTextField(
                            controller: _accountNumber,
                            label: 'Account number',
                            icon: Icons.account_balance_outlined,
                            keyboardType: TextInputType.number,
                            enabled: _editMode),
                        _ProfileTextField(
                            controller: _ifsc,
                            label: 'IFSC',
                            icon: Icons.domain_verification_outlined,
                            enabled: _editMode),
                        _ProfileTextField(
                            controller: _upi,
                            label: 'UPI',
                            icon: Icons.qr_code_2_rounded,
                            enabled: _editMode),
                      ]),
                    ],
                  ),
                ),
                if (_editMode)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.check_rounded),
                        label: Text(_saving ? 'Saving...' : 'Save profile'),
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initial,
    required this.title,
    required this.subtitle,
  });
  final String initial;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.primary.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                color: scheme.onPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFieldList extends StatelessWidget {
  const _ProfileFieldList({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        ...children.expand((child) => [child, const SizedBox(height: 12)]),
      ],
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.enabled,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.onChanged,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        color: scheme.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: 19,
          color: enabled
              ? scheme.primary
              : scheme.onSurface.withValues(alpha: 0.4),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _PlacesSearchField extends StatelessWidget {
  const _PlacesSearchField({
    required this.controller,
    required this.loading,
    required this.suggestions,
    required this.onChanged,
    required this.onClear,
    required this.onSelect,
  });

  final TextEditingController controller;
  final bool loading;
  final List<Map<String, dynamic>> suggestions;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<Map<String, dynamic>> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            labelText: 'Search address',
            prefixIcon: loading
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: scheme.primary,
                      ),
                    ),
                  )
                : Icon(Icons.search_rounded,
                    size: 19, color: scheme.primary),
            suffixIcon: controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: onClear,
                    child: Icon(Icons.close_rounded,
                        size: 18,
                        color: scheme.onSurface.withValues(alpha: 0.5)),
                  )
                : null,
          ),
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: suggestions.map((pred) {
                final main = (pred['structured_formatting']
                            as Map?)?['main_text'] as String? ??
                        pred['description'] as String? ??
                        '';
                final secondary = (pred['structured_formatting']
                        as Map?)?['secondary_text'] as String? ??
                    '';
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onSelect(pred),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(children: [
                      Icon(Icons.location_on_outlined,
                          size: 16,
                          color: scheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(main,
                                style: TextStyle(
                                    color: scheme.onSurface,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            if (secondary.isNotEmpty)
                              Text(secondary,
                                  style: TextStyle(
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.6),
                                      fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
