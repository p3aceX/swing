import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const SwingCoachApp());
}

class SwingCoachApp extends StatefulWidget {
  const SwingCoachApp({super.key});

  @override
  State<SwingCoachApp> createState() => _SwingCoachAppState();
}

class _SwingCoachAppState extends State<SwingCoachApp> {
  ThemeMode _themeMode = ThemeMode.light;
  AuthSession? _session;

  bool get _isDarkMode => _themeMode == ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _isDarkMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _completeLogin(AuthSession session) {
    setState(() {
      _session = session;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swing Coach',
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: _session == null
          ? CoachOtpLoginScreen(
              isDarkMode: _isDarkMode,
              onThemeToggle: _toggleTheme,
              onSignedIn: _completeLogin,
            )
          : _session!.needsCoachRegistration
          ? CoachRegistrationScreen(
              isDarkMode: _isDarkMode,
              onThemeToggle: _toggleTheme,
              session: _session!,
              onComplete: () {
                setState(() {
                  _session = _session!.copyWith(needsCoachRegistration: false);
                });
              },
            )
          : HelloWorldScreen(
              isDarkMode: _isDarkMode,
              onThemeToggle: _toggleTheme,
            ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? AppPalette.logoBlack : AppPalette.warmIvory;
    final foreground = isDark ? AppPalette.cleanWhite : AppPalette.logoBlack;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: foreground,
        brightness: brightness,
        primary: foreground,
        surface: background,
        onSurface: foreground,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF101010) : AppPalette.cleanWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFE5E1D6),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFE5E1D6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: foreground, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: foreground,
          foregroundColor: background,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class CoachOtpLoginScreen extends StatefulWidget {
  const CoachOtpLoginScreen({
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onSignedIn,
    super.key,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final ValueChanged<AuthSession> onSignedIn;

  @override
  State<CoachOtpLoginScreen> createState() => _CoachOtpLoginScreenState();
}

class _CoachOtpLoginScreenState extends State<CoachOtpLoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _auth = CoachAuthService();

  AuthStep _step = AuthStep.phone;
  String _phone = '';
  String _sessionId = '';
  String _otpForNameRetry = '';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _normalizeIndianPhone(_phoneCtrl.text);
    if (!RegExp(r'^\+91\d{10}$').hasMatch(phone)) {
      setState(() => _error = 'Enter a valid 10-digit phone number');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _phone = phone;
    });

    try {
      final sessionId = await _auth.sendOtp(phone);
      setState(() {
        _sessionId = sessionId;
        _step = AuthStep.otp;
      });
    } catch (e) {
      setState(() => _error = _humanize(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp({String? name}) async {
    final otp = _otpCtrl.text.trim();
    if (!RegExp(r'^\d{4,8}$').hasMatch(otp)) {
      setState(() => _error = 'Enter the OTP sent to your phone');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = await _auth.loginWithBackend(
        phone: _phone,
        sessionId: _sessionId,
        otp: otp,
        name: name,
      );
      widget.onSignedIn(session);
    } catch (e) {
      final message = e.toString();
      if (message.contains('NAME_REQUIRED')) {
        setState(() {
          _step = AuthStep.name;
          _otpForNameRetry = otp;
          _error = null;
        });
      } else {
        setState(() => _error = _humanize(e));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitName() async {
    final name = _nameCtrl.text.trim();
    if (name.length < 2) {
      setState(() => _error = 'Enter your full name');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = await _auth.loginWithBackend(
        phone: _phone,
        sessionId: _sessionId,
        otp: _otpForNameRetry,
        name: name,
      );
      widget.onSignedIn(session);
    } catch (e) {
      setState(() => _error = _humanize(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode
        ? AppPalette.cleanWhite
        : AppPalette.logoBlack;
    final mutedColor = textColor.withValues(alpha: 0.66);
    final logoAsset = widget.isDarkMode
        ? 'asset/logodark.png'
        : 'asset/logolight.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swing Coach'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: ThemeToggle(
              isDarkMode: widget.isDarkMode,
              onPressed: widget.onThemeToggle,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 280,
                        maxHeight: 220,
                      ),
                      child: Image.asset(logoAsset, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: mutedColor,
                      height: 1.4,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCurrentForm(textColor),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFC62828),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentForm(Color textColor) {
    return switch (_step) {
      AuthStep.phone => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: TextStyle(
              color: textColor,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
            decoration: const InputDecoration(
              labelText: 'Mobile number',
              hintText: '9876543210',
              prefixText: '+91 ',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _sendOtp,
            child: _buttonChild('Send OTP'),
          ),
        ],
      ),
      AuthStep.otp => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
            decoration: const InputDecoration(
              labelText: 'OTP',
              hintText: '000000',
            ),
            onSubmitted: (_) => _loading ? null : _verifyOtp(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _verifyOtp,
            child: _buttonChild('Verify OTP'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loading
                ? null
                : () {
                    setState(() {
                      _step = AuthStep.phone;
                      _otpCtrl.clear();
                      _error = null;
                    });
                  },
            child: const Text('Change number'),
          ),
        ],
      ),
      AuthStep.name => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              labelText: 'Full name',
              hintText: 'Coach name',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _submitName,
            child: _buttonChild('Continue'),
          ),
        ],
      ),
    };
  }

  Widget _buttonChild(String label) {
    if (!_loading) return Text(label);
    return const SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  String get _title {
    return switch (_step) {
      AuthStep.phone => 'Login with OTP',
      AuthStep.otp => 'Verify OTP',
      AuthStep.name => 'Complete account',
    };
  }

  String get _subtitle {
    return switch (_step) {
      AuthStep.phone => 'The Future of Cricket Training',
      AuthStep.otp => 'Enter the OTP sent to $_phone.',
      AuthStep.name => 'Add your name to finish the first login.',
    };
  }

  String _normalizeIndianPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '+91$digits';
    if (digits.startsWith('91') && digits.length == 12) return '+$digits';
    return raw.trim();
  }

  String _humanize(Object error) {
    final raw = error.toString();
    if (raw.contains('NAME_REQUIRED')) return 'Name required';
    if (raw.contains('OTP_INVALID')) return 'Invalid or expired OTP';
    if (raw.contains('ACCOUNT_BANNED')) return 'Account banned';
    if (raw.contains('ACCOUNT_BLOCKED')) return 'Account blocked';
    return 'Login failed. Please try again.';
  }
}

class HelloWorldScreen extends StatelessWidget {
  const HelloWorldScreen({
    required this.isDarkMode,
    required this.onThemeToggle,
    super.key,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swing Coach'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: ThemeToggle(
              isDarkMode: isDarkMode,
              onPressed: onThemeToggle,
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Hello World',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class CoachRegistrationScreen extends StatefulWidget {
  const CoachRegistrationScreen({
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.session,
    required this.onComplete,
    super.key,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final AuthSession session;
  final VoidCallback onComplete;

  @override
  State<CoachRegistrationScreen> createState() =>
      _CoachRegistrationScreenState();
}

class _CoachRegistrationScreenState extends State<CoachRegistrationScreen> {
  final _coachNameCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _auth = CoachAuthService();

  bool _loading = false;
  bool _lookingUpPincode = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _coachNameCtrl.text = widget.session.userName ?? '';
    _pincodeCtrl.addListener(_lookupPincodeWhenReady);
  }

  @override
  void dispose() {
    _coachNameCtrl.dispose();
    _pincodeCtrl.removeListener(_lookupPincodeWhenReady);
    _pincodeCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookupPincodeWhenReady() async {
    final pincode = _pincodeCtrl.text.trim();
    if (pincode.length != 6 || _lookingUpPincode) return;

    setState(() {
      _lookingUpPincode = true;
      _error = null;
    });

    try {
      final location = await _auth.lookupPincode(pincode);
      if (!mounted) return;
      setState(() {
        _cityCtrl.text = location.city;
        _stateCtrl.text = location.state;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cityCtrl.clear();
        _stateCtrl.clear();
        _error = 'Could not fetch city and state for this pincode';
      });
    } finally {
      if (mounted) setState(() => _lookingUpPincode = false);
    }
  }

  Future<void> _submit() async {
    final coachName = _coachNameCtrl.text.trim();
    final pincode = _pincodeCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final state = _stateCtrl.text.trim();
    if (coachName.length < 2) {
      setState(() => _error = 'Enter coach name');
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(pincode)) {
      setState(() => _error = 'Enter a valid 6-digit pincode');
      return;
    }
    if (city.length < 2 || state.length < 2) {
      setState(() => _error = 'Enter a valid pincode to fetch city and state');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _auth.registerCoachBusiness(
        accessToken: widget.session.accessToken,
        coachName: coachName,
        phone: widget.session.phone,
        pincode: pincode,
        city: city,
        state: state,
        address: _addressCtrl.text.trim(),
      );
      widget.onComplete();
    } catch (e) {
      setState(() => _error = _humanize(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode
        ? AppPalette.cleanWhite
        : AppPalette.logoBlack;
    final mutedColor = textColor.withValues(alpha: 0.66);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Registration'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: ThemeToggle(
              isDarkMode: widget.isDarkMode,
              onPressed: widget.onThemeToggle,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Coach registration',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your coach profile using the existing backend APIs.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: mutedColor, height: 1.4),
                  ),
                  const SizedBox(height: 22),
                  _field(_coachNameCtrl, 'Coach name', textColor),
                  const SizedBox(height: 12),
                  _field(
                    _pincodeCtrl,
                    'Pincode',
                    textColor,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          _cityCtrl,
                          'City',
                          textColor,
                          readOnly: true,
                          suffixIcon: _lookingUpPincode
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          _stateCtrl,
                          'State',
                          textColor,
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _field(_addressCtrl, 'Address', textColor, maxLines: 2),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Register coach'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFC62828),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    Color textColor, {
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
      decoration: InputDecoration(labelText: label, suffixIcon: suffixIcon),
    );
  }

  String _humanize(Object error) {
    final raw = error.toString();
    if (raw.contains('BUSINESS_DETAILS_REQUIRED')) {
      return 'Business details are required first';
    }
    if (raw.contains('401') || raw.contains('403')) {
      return 'Session expired. Please login again.';
    }
    return 'Coach registration failed. Please try again.';
  }
}

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({
    required this.isDarkMode,
    required this.onPressed,
    super.key,
  });

  final bool isDarkMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isDarkMode ? 'Switch to light theme' : 'Switch to dark theme',
      onPressed: onPressed,
      icon: Icon(
        isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: isDarkMode ? AppPalette.cleanWhite : AppPalette.logoBlack,
        size: 26,
      ),
    );
  }
}

class CoachAuthService {
  static const _twoFactorApiKey = 'c03bfecb-f75f-11f0-a6b2-0200cd936042';
  static const _backendBaseUrl =
      'https://swing-backend-1007730655118.asia-south1.run.app';
  static const _testPhone = '+919999999999';
  static const _testOtp = '123456';

  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 30);

  Future<String> sendOtp(String phone) async {
    final otpSegment = phone == _testPhone ? _testOtp : 'AUTOGEN2';
    final uri = Uri.parse(
      'https://2factor.in/API/V1/$_twoFactorApiKey/SMS/$phone/$otpSegment',
    );
    final data = await _getJson(uri);
    if (data['Status'] == 'Success' && data['Details'] is String) {
      return data['Details'] as String;
    }
    throw const AuthException('OTP_SEND_FAILED');
  }

  Future<AuthSession> loginWithBackend({
    required String phone,
    required String sessionId,
    required String otp,
    String? name,
  }) async {
    final uri = Uri.parse('$_backendBaseUrl/auth/biz/phone-login');
    final body = <String, dynamic>{
      'phone': phone,
      'sessionId': sessionId,
      'otp': otp,
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      'language': 'en',
    };
    final data = await _postJson(uri, body);
    final success = data['success'] == true;
    if (!success) throw const AuthException('LOGIN_FAILED');
    final payload = (data['data'] ?? data) as Map<String, dynamic>;
    final user = (payload['user'] as Map?)?.cast<String, dynamic>();
    final businessStatus = (payload['businessStatus'] as Map?)
        ?.cast<String, dynamic>();
    final needsCoachRegistration =
        (businessStatus?['hasBusinessAccount'] != true) ||
        (businessStatus?['coachProfileId'] == null);
    return AuthSession(
      accessToken: payload['accessToken'] as String,
      refreshToken: payload['refreshToken'] as String?,
      phone: (user?['phone'] as String?) ?? phone,
      userName: user?['name'] as String?,
      needsCoachRegistration: needsCoachRegistration,
    );
  }

  Future<void> registerCoachBusiness({
    required String accessToken,
    required String coachName,
    required String phone,
    required String pincode,
    required String city,
    required String state,
    String? contactName,
    String? address,
  }) async {
    await _putJson(Uri.parse('$_backendBaseUrl/biz/business-details'), {
      'businessName': coachName,
      'contactName': coachName,
      'phone': phone,
      'pincode': pincode,
      'city': city,
      'state': state,
      if (address != null && address.isNotEmpty) 'address': address,
    }, accessToken: accessToken);

    await _postJson(Uri.parse('$_backendBaseUrl/biz/coach'), {
      'city': city,
      'state': state,
    }, accessToken: accessToken);
  }

  Future<PincodeLocation> lookupPincode(String pincode) async {
    final uri = Uri.parse('https://api.postalpincode.in/pincode/$pincode');
    final request = await _client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close();
    final raw = await utf8.decoder.bind(response).join();
    final decoded = jsonDecode(raw);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded is! List ||
        decoded.isEmpty) {
      throw const AuthException('PINCODE_LOOKUP_FAILED');
    }

    final result = decoded.first as Map<String, dynamic>;
    if (result['Status'] != 'Success') {
      throw const AuthException('PINCODE_LOOKUP_FAILED');
    }

    final offices = result['PostOffice'];
    if (offices is! List || offices.isEmpty) {
      throw const AuthException('PINCODE_LOOKUP_FAILED');
    }

    final office = offices.first as Map<String, dynamic>;
    final city = (office['District'] ?? office['Block'] ?? office['Name'])
        ?.toString();
    final state = office['State']?.toString();
    if (city == null ||
        city.trim().isEmpty ||
        state == null ||
        state.trim().isEmpty) {
      throw const AuthException('PINCODE_LOOKUP_FAILED');
    }

    return PincodeLocation(city: city.trim(), state: state.trim());
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final request = await _client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close();
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _postJson(
    Uri uri,
    Map<String, dynamic> body, {
    String? accessToken,
  }) async {
    final request = await _client.postUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (accessToken != null) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
    }
    request.write(jsonEncode(body));
    final response = await request.close();
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _putJson(
    Uri uri,
    Map<String, dynamic> body, {
    required String accessToken,
  }) async {
    final request = await _client.putUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.write(jsonEncode(body));
    final response = await request.close();
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _decodeResponse(
    HttpClientResponse response,
  ) async {
    final raw = await utf8.decoder.bind(response).join();
    final decoded = raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw);
    final data = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final code = data['code'] ?? data['error'] ?? data['message'];
    throw AuthException(code?.toString() ?? 'HTTP_${response.statusCode}');
  }
}

class AuthException implements Exception {
  const AuthException(this.code);

  final String code;

  @override
  String toString() => code;
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.phone,
    required this.needsCoachRegistration,
    this.refreshToken,
    this.userName,
  });

  final String accessToken;
  final String phone;
  final bool needsCoachRegistration;
  final String? refreshToken;
  final String? userName;

  AuthSession copyWith({
    String? accessToken,
    String? phone,
    bool? needsCoachRegistration,
    String? refreshToken,
    String? userName,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      phone: phone ?? this.phone,
      needsCoachRegistration:
          needsCoachRegistration ?? this.needsCoachRegistration,
      refreshToken: refreshToken ?? this.refreshToken,
      userName: userName ?? this.userName,
    );
  }
}

class PincodeLocation {
  const PincodeLocation({required this.city, required this.state});

  final String city;
  final String state;
}

enum AuthStep { phone, otp, name }

abstract final class AppPalette {
  static const warmIvory = Color(0xFFF4F2EB);
  static const cleanWhite = Color(0xFFFFFFFF);
  static const logoBlack = Color(0xFF000000);
}
