import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/router/app_router.dart';

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
  bool _pincodeLoading = false;
  String _arenaType = 'CRICKET';
  String? _pincodeMessage;
  Timer? _pincodeDebounce;

  static const _steps = [
    _SetupStep('Type', Icons.category_rounded),
    _SetupStep('Basics', Icons.edit_note_rounded),
    _SetupStep('Location', Icons.location_on_rounded),
  ];

  @override
  void dispose() {
    for (final controller in [
      _name,
      _description,
      _phone,
      _address,
      _city,
      _state,
      _pincode,
      _latitude,
      _longitude,
    ]) {
      controller.dispose();
    }
    _pincodeDebounce?.cancel();
    _page.dispose();
    super.dispose();
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
    await _page.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _back() async {
    if (_step == 0) {
      context.pop();
      return;
    }
    setState(() => _step--);
    await _page.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await ref.read(hostBizRepositoryProvider).createArena(
            ArenaProfileInput(
              name: _name.text.trim(),
              address: _address.text.trim(),
              city: _city.text.trim(),
              state: _state.text.trim(),
              pincode: _pincode.text.trim().isEmpty
                  ? '000000'
                  : _pincode.text.trim(),
              description: _emptyToNull(_description.text),
              phone: _emptyToNull(_phone.text),
              sports: [_arenaType],
              latitude: _parseDouble(_latitude.text),
              longitude: _parseDouble(_longitude.text),
            ),
          );
      await ref
          .read(sessionControllerProvider.notifier)
          .setActiveProfile(BizProfileType.arena);
      ref.invalidate(meProvider);
      if (mounted) context.go(AppRoutes.dashboard);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create arena: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _onPincodeChanged(String value) {
    _pincodeDebounce?.cancel();
    final pincode = value.trim();
    if (pincode.length != 6) {
      setState(() {
        _pincodeLoading = false;
        _pincodeMessage = null;
      });
      return;
    }
    _pincodeDebounce = Timer(
      const Duration(milliseconds: 450),
      () => _lookupPincode(pincode),
    );
  }

  Future<void> _lookupPincode(String pincode) async {
    setState(() {
      _pincodeLoading = true;
      _pincodeMessage = null;
    });
    try {
      final response = await Dio().get<List<dynamic>>(
        'https://api.postalpincode.in/pincode/$pincode',
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );
      final payload = response.data;
      final first = payload?.isNotEmpty == true ? payload!.first : null;
      if (first is! Map || first['Status'] != 'Success') {
        if (!mounted) return;
        setState(() => _pincodeMessage = 'No location found for this pincode');
        return;
      }
      final postOffices = first['PostOffice'];
      final office = postOffices is List && postOffices.isNotEmpty
          ? postOffices.first
          : null;
      if (office is! Map) {
        if (!mounted) return;
        setState(() => _pincodeMessage = 'No location found for this pincode');
        return;
      }
      final district = '${office['District'] ?? ''}'.trim();
      final state = '${office['State'] ?? ''}'.trim();
      if (!mounted) return;
      setState(() {
        if (district.isNotEmpty) _city.text = _titleCase(district);
        if (state.isNotEmpty) _state.text = _titleCase(state);
        _pincodeMessage = district.isEmpty && state.isEmpty
            ? 'No location found for this pincode'
            : 'City and state filled from pincode';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _pincodeMessage = 'Could not fetch pincode details');
    } finally {
      if (mounted) setState(() => _pincodeLoading = false);
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
        child: Column(
          children: [
            _ProgressHeader(step: _step, steps: _steps),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ArenaTypeStep(
                    selectedType: _arenaType,
                    onChanged: (value) => setState(() => _arenaType = value),
                  ),
                  _StepShell(
                    title: 'Basic arena details',
                    subtitle: 'Name, description and booking phone.',
                    child: Form(
                      key: _basicKey,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          _Field(_name, 'Arena name', required: true),
                          _Field(_description, 'Description', maxLines: 3),
                          _Field(
                            _phone,
                            'Booking confirmation phone number',
                            required: true,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  _StepShell(
                    title: 'Location',
                    subtitle: 'Keep latitude and longitude for map accuracy.',
                    child: Form(
                      key: _locationKey,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          _Field(
                            _pincode,
                            'Pincode',
                            required: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            onChanged: _onPincodeChanged,
                            trailing: _pincodeLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : null,
                            helperText: _pincodeMessage,
                          ),
                          _Field(_city, 'City', required: true),
                          _Field(_state, 'State', required: true),
                          _Field(_address, 'Address', required: true),
                          Row(
                            children: [
                              Expanded(
                                child: _Field(
                                  _latitude,
                                  'Latitude',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _Field(
                                  _longitude,
                                  'Longitude',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
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
            ),
            _BottomBar(
              step: _step,
              total: _steps.length,
              saving: _saving,
              onBack: _back,
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupStep {
  const _SetupStep(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.step,
    required this.steps,
  });

  final int step;
  final List<_SetupStep> steps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step ${step + 1} of ${steps.length}',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Icon(steps[step].icon, size: 18, color: _muted),
              const SizedBox(width: 6),
              Text(
                steps[step].label,
                style: const TextStyle(
                  color: _text,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              steps.length,
              (index) => Expanded(
                child: Container(
                  margin:
                      EdgeInsets.only(right: index == steps.length - 1 ? 0 : 6),
                  height: 5,
                  decoration: BoxDecoration(
                    color: index <= step ? _deep : _line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepShell extends StatelessWidget {
  const _StepShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _ArenaTypeStep extends StatelessWidget {
  const _ArenaTypeStep({
    required this.selectedType,
    required this.onChanged,
  });

  final String selectedType;
  final ValueChanged<String> onChanged;

  static const sports = [
    ('CRICKET', 'Cricket', Icons.sports_cricket_rounded),
    ('FOOTBALL', 'Football', Icons.sports_soccer_rounded),
    ('FUTSAL', 'Futsal', Icons.sports_soccer_rounded),
    ('PICKLEBALL', 'Pickleball', Icons.sports_tennis_rounded),
    ('BADMINTON', 'Badminton', Icons.sports_tennis_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: 'Type of arena',
      subtitle: 'Choose the primary sport for this arena.',
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sports.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.18,
        ),
        itemBuilder: (context, index) {
          final item = sports[index];
          final selected = selectedType == item.$1;
          return _ChoiceTile(
            title: item.$2,
            icon: item.$3,
            selected: selected,
            onTap: () => onChanged(item.$1),
          );
        },
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _deep : _surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? _deep : _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: selected ? Colors.white : _deep, size: 28),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: selected ? Colors.white : _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: _accent,
                      size: 19,
                    ),
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
  const _Field(
    this.controller,
    this.label, {
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.trailing,
    this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final Widget? trailing;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        validator: required
            ? (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null
            : null,
        decoration: _inputDecoration(
          label,
          suffixIcon: trailing,
          helperText: helperText,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.step,
    required this.total,
    required this.saving,
    required this.onBack,
    required this.onNext,
  });

  final int step;
  final int total;
  final bool saving;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLast = step == total - 1;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: saving ? null : onBack,
              child: Text(step == 0 ? 'Cancel' : 'Back'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: saving ? null : onNext,
              style: FilledButton.styleFrom(
                backgroundColor: _deep,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isLast ? 'Create Arena' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(
  String label, {
  Widget? suffixIcon,
  String? helperText,
}) {
  return InputDecoration(
    labelText: label,
    suffixIcon: suffixIcon == null
        ? null
        : Padding(
            padding: const EdgeInsets.all(13),
            child: suffixIcon,
          ),
    helperText: helperText,
    helperMaxLines: 2,
    filled: true,
    fillColor: _surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _deep, width: 1.4),
    ),
  );
}

String? _emptyToNull(String value) {
  final safe = value.trim();
  return safe.isEmpty ? null : safe;
}

double? _parseDouble(String value) {
  final safe = value.trim();
  if (safe.isEmpty) return null;
  return double.tryParse(safe);
}

String _titleCase(String value) {
  return value
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
