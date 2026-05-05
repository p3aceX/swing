import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swing_coach/components/feedback/feedback_form.dart';
import 'package:swing_coach/modules/play/navigation/play_route_scope.dart';
import 'package:swing_coach/modules/play/screens/coach_create_match_screen.dart';
import 'package:swing_coach/modules/play/screens/coach_create_tournament_screen.dart';
import 'package:swing_coach/modules/play/screens/coach_play_entry_screen.dart';
import 'package:swing_coach/services/feedback_service.dart';

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
  final _sessionStore = LocalSessionStore();
  final _settingsStore = LocalSettingsStore();
  bool _booting = true;
  bool _appUnlocked = false;
  bool _onboardingReady = false;
  bool _isAuthenticated = false;
  bool _isOtpVerified = false;
  bool _hasCompletedUpiSetup = false;

  bool get _isDarkMode =>
      _themeMode == ThemeMode.dark ||
      (_themeMode == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final savedTheme = await _settingsStore.loadThemeMode();
    final storedSession = await _sessionStore.readSession();
    AuthSession? session = _hasUsableAccessToken(storedSession)
        ? storedSession
        : null;
    if (session != null && session.refreshToken?.isNotEmpty == true) {
      final refreshed = await CoachAuthService().refreshAuthSession(session);
      if (refreshed != null) {
        session = refreshed;
        await _sessionStore.saveSession(refreshed);
      } else {
        session = null;
      }
    }
    if (storedSession != null && session == null) {
      await _sessionStore.clearSession();
    }
    final lockEnabled = await _settingsStore.isAppLockEnabled();
    if (!mounted) return;
    setState(() {
      _themeMode = savedTheme;
      _session = session;
      _isAuthenticated = session != null;
      _isOtpVerified = session != null;
      _hasCompletedUpiSetup = session?.hasCompletedUpiSetup == true;
      _appUnlocked = session == null || !lockEnabled;
      _onboardingReady = session?.hasCompletedUpiSetup == true;
      _booting = false;
    });
  }

  void _toggleTheme() {
    final next = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : _themeMode == ThemeMode.dark
        ? ThemeMode.system
        : ThemeMode.light;
    _setThemeMode(next);
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    _settingsStore.saveThemeMode(mode);
  }

  void _completeLogin(AuthSession session) {
    _saveCompletedLogin(session);
  }

  Future<void> _saveCompletedLogin(AuthSession session) async {
    if (!_hasUsableAccessToken(session)) {
      await _logout();
      return;
    }
    await _sessionStore.saveSession(session);
    if (!mounted) return;
    setState(() {
      _session = session;
      _isAuthenticated = true;
      _isOtpVerified = true;
      _hasCompletedUpiSetup = session.hasCompletedUpiSetup;
      _appUnlocked = true;
      _onboardingReady = session.hasCompletedUpiSetup;
    });
  }

  Future<void> _completeOnboarding(AuthSession session) async {
    final updated = session.copyWith(
      needsCoachRegistration: false,
      hasCompletedUpiSetup: true,
    );
    if (!_hasUsableAccessToken(updated)) {
      await _logout();
      return;
    }
    await _sessionStore.saveSession(updated);
    if (!mounted) return;
    setState(() {
      _session = updated;
      _isAuthenticated = true;
      _isOtpVerified = true;
      _hasCompletedUpiSetup = true;
      _appUnlocked = true;
      _onboardingReady = true;
    });
  }

  Future<void> _logout() async {
    await _sessionStore.clearSession();
    await _settingsStore.clearUnlockPermission();
    if (!mounted) return;
    setState(() {
      _session = null;
      _isAuthenticated = false;
      _isOtpVerified = false;
      _hasCompletedUpiSetup = false;
      _appUnlocked = false;
      _onboardingReady = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = _buildTheme(Brightness.light);
    final darkTheme = _buildTheme(Brightness.dark);

    if (_booting) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Swing Coach',
        themeMode: _themeMode,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const LoadingView(label: 'Opening Swing Coach'),
      );
    }

    if (_isAuthenticated && _session != null && !_appUnlocked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Swing Coach',
        themeMode: _themeMode,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: AppLockScreen(
          settingsStore: _settingsStore,
          onUnlocked: () => setState(() => _appUnlocked = true),
          onSessionExpired: _logout,
        ),
      );
    }

    if (_isAuthenticated &&
        _session != null &&
        _appUnlocked &&
        (!_onboardingReady || !_hasCompletedUpiSetup)) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Swing Coach',
        themeMode: _themeMode,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: OnboardingGuard(
          session: _session!,
          isDarkMode: _isDarkMode,
          onThemeToggle: _toggleTheme,
          onSessionUpdated: (session) async {
            await _sessionStore.saveSession(session);
            if (!mounted) return;
            setState(() => _session = session);
          },
          onComplete: (session) => _completeOnboarding(session),
          onLogout: _logout,
        ),
      );
    }

    if (_isAuthenticated &&
        _session != null &&
        _onboardingReady &&
        _hasCompletedUpiSetup) {
      return ProviderScope(
        overrides: [
          initialAuthSessionProvider.overrideWithValue(_session!),
          settingsStoreProvider.overrideWithValue(_settingsStore),
        ],
        child: CoachRouterApp(
          session: _session!,
          isDarkMode: _isDarkMode,
          themeMode: _themeMode,
          lightTheme: lightTheme,
          darkTheme: darkTheme,
          onThemeToggle: _toggleTheme,
          onThemeModeChanged: _setThemeMode,
          onSessionChanged: (session) async {
            if (session == null) return;
            await _sessionStore.saveSession(session);
            if (mounted) setState(() => _session = session);
          },
          onLogout: _logout,
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swing Coach',
      themeMode: _themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: !_isAuthenticated || !_isOtpVerified || _session == null
          ? CoachOtpLoginScreen(
              isDarkMode: _isDarkMode,
              onThemeToggle: _toggleTheme,
              onSignedIn: _completeLogin,
            )
          : const LoadingView(label: 'Preparing onboarding'),
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
                  const SizedBox(height: 8),
                  Text(
                    _progressLabel,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: mutedColor,
                      fontWeight: FontWeight.w700,
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

  String get _progressLabel {
    return switch (_step) {
      AuthStep.phone => 'Login -> Verify -> Setup -> Done',
      AuthStep.otp => 'Login -> Verify -> Setup -> Done',
      AuthStep.name => 'Login -> Verify -> Setup -> Done',
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
    if (raw.contains('TOKEN_MISSING')) {
      return 'Login token missing. Please try again.';
    }
    if (raw.contains('ACCOUNT_BANNED')) return 'Account banned';
    if (raw.contains('ACCOUNT_BLOCKED')) return 'Account blocked';
    return 'Login failed. Please try again.';
  }
}

class LocalSessionStore {
  static const _storage = FlutterSecureStorage();
  static const _sessionKey = 'auth_session_json';

  Future<void> saveSession(AuthSession session) {
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
  }

  Future<AuthSession?> readSession() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final session = AuthSession.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (!_hasUsableAccessToken(session)) {
        await clearSession();
        return null;
      }
      return session;
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  Future<void> clearSession() {
    return _storage.delete(key: _sessionKey);
  }
}

class LocalSettingsStore {
  static const _themeKey = 'theme_mode';
  static const _appLockEnabledKey = 'app_lock_enabled';
  static const _pinKey = 'app_lock_pin';
  static const _biometricKey = 'biometric_enabled';
  static const _oneOnOneSetupKey = 'one_on_one_setup_completed';
  static const _oneOnOneSetupDataKey = 'one_on_one_setup_data';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<ThemeMode> loadThemeMode() async {
    final value = (await _prefs).getString(_themeKey);
    if (value == 'dark') return ThemeMode.dark;
    if (value == 'system') return ThemeMode.system;
    return ThemeMode.light;
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final modeValue = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    await (await _prefs).setString(_themeKey, modeValue);
  }

  Future<bool> isAppLockEnabled() async {
    return (await _prefs).getBool(_appLockEnabledKey) ?? false;
  }

  Future<bool> isBiometricEnabled() async {
    return (await _prefs).getBool(_biometricKey) ?? false;
  }

  Future<String?> readPin() async {
    return (await _prefs).getString(_pinKey);
  }

  Future<void> enableAppLock({required bool biometric, String? pin}) async {
    final prefs = await _prefs;
    await prefs.setBool(_appLockEnabledKey, true);
    await prefs.setBool(_biometricKey, biometric);
    if (pin != null && pin.isNotEmpty) await prefs.setString(_pinKey, pin);
  }

  Future<void> disableAppLock() async {
    final prefs = await _prefs;
    await prefs.setBool(_appLockEnabledKey, false);
    await prefs.setBool(_biometricKey, false);
  }

  Future<void> clearUnlockPermission() async {
    final prefs = await _prefs;
    await prefs.setBool(_appLockEnabledKey, false);
    await prefs.setBool(_biometricKey, false);
    await prefs.remove(_pinKey);
  }

  Future<bool> isOneOnOneSetupCompleted() async {
    return (await _prefs).getBool(_oneOnOneSetupKey) ?? false;
  }

  Future<Map<String, dynamic>> loadOneOnOneSetupData() async {
    final raw = (await _prefs).getString(_oneOnOneSetupDataKey);
    if (raw == null || raw.isEmpty) return const <String, dynamic>{};
    try {
      return (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  Future<void> saveOneOnOneSetupData(Map<String, dynamic> data) async {
    final prefs = await _prefs;
    await prefs.setBool(_oneOnOneSetupKey, true);
    await prefs.setString(_oneOnOneSetupDataKey, jsonEncode(data));
  }
}

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({
    required this.settingsStore,
    required this.onUnlocked,
    required this.onSessionExpired,
    super.key,
  });

  final LocalSettingsStore settingsStore;
  final VoidCallback onUnlocked;
  final VoidCallback onSessionExpired;

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final _localAuth = LocalAuthentication();
  final _pinCtrl = TextEditingController();
  bool _loading = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String? _savedPin;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final enabled = await widget.settingsStore.isBiometricEnabled();
    final pin = await widget.settingsStore.readPin();
    var available = false;
    try {
      available =
          await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (_) {
      available = false;
    }
    if (!mounted) return;
    setState(() {
      _biometricAvailable = available;
      _biometricEnabled = enabled;
      _savedPin = pin;
      _loading = false;
    });
    if (enabled && available) _unlockWithBiometric();
  }

  Future<void> _unlockWithBiometric() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: 'Unlock Swing Coach',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (!mounted) return;
      if (ok) {
        widget.onUnlocked();
      } else {
        setState(() => _message = 'Biometric cancelled. Use app lock PIN.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Biometric unavailable. Use app lock PIN.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _unlockWithPin() {
    if (_savedPin == null || _savedPin!.isEmpty) {
      setState(() => _message = 'No fallback PIN is set. Please login again.');
      return;
    }
    if (_pinCtrl.text.trim() == _savedPin) {
      widget.onUnlocked();
    } else {
      setState(() => _message = 'Incorrect app lock PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(label: 'Checking app lock');
    return Scaffold(
      appBar: AppBar(title: const Text('App Lock')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 48),
                  const SizedBox(height: 18),
                  Text(
                    'Unlock Swing Coach',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _biometricEnabled && _biometricAvailable
                        ? 'Use biometric unlock or your app lock PIN.'
                        : 'Use your app lock PIN to continue.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  if (_biometricEnabled && _biometricAvailable) ...[
                    FilledButton.icon(
                      onPressed: _unlockWithBiometric,
                      icon: const Icon(Icons.fingerprint_rounded),
                      label: const Text('Use Biometric'),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _pinCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'App lock PIN',
                    ),
                    onSubmitted: (_) => _unlockWithPin(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _unlockWithPin,
                    child: const Text('Unlock'),
                  ),
                  TextButton(
                    onPressed: widget.onSessionExpired,
                    child: const Text('Login with phone instead'),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _message!,
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
}

class OnboardingGuard extends StatefulWidget {
  const OnboardingGuard({
    required this.session,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onSessionUpdated,
    required this.onComplete,
    required this.onLogout,
    super.key,
  });

  final AuthSession session;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final ValueChanged<AuthSession> onSessionUpdated;
  final ValueChanged<AuthSession> onComplete;
  final VoidCallback onLogout;

  @override
  State<OnboardingGuard> createState() => _OnboardingGuardState();
}

class _OnboardingGuardState extends State<OnboardingGuard> {
  final _auth = CoachAuthService();
  OnboardingStep _step = OnboardingStep.loading;
  Map<String, dynamic> _bizMe = const {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() {
      _step = OnboardingStep.loading;
      _error = null;
    });
    try {
      final data = await _auth.getBizMe(widget.session.accessToken);
      final payload = ((data['data'] ?? data) as Map).cast<String, dynamic>();
      final status =
          (payload['businessStatus'] as Map?)?.cast<String, dynamic>() ??
          const {};
      final account =
          (payload['businessAccount'] as Map?)?.cast<String, dynamic>() ??
          const {};
      final hasCoach =
          status['coachProfileId'] != null ||
          widget.session.needsCoachRegistration == false;
      final hasUpi = _hasCompletedUpiSetupFromProfile(account, payload);
      if (!mounted) return;
      _bizMe = payload;
      if (!hasCoach) {
        setState(() => _step = OnboardingStep.coachDetails);
      } else if (!hasUpi) {
        setState(() => _step = OnboardingStep.upiDetails);
      } else {
        final updated = widget.session.copyWith(
          needsCoachRegistration: false,
          hasCompletedUpiSetup: true,
          userName:
              (payload['user'] as Map?)?['name']?.toString() ??
              widget.session.userName,
        );
        widget.onComplete(updated);
      }
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains('401') || e.toString().contains('403')) {
        widget.onLogout();
        return;
      }
      setState(() {
        _step = OnboardingStep.error;
        _error = _errorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      OnboardingStep.loading => const LoadingView(
        label: 'Checking coach setup',
      ),
      OnboardingStep.error => Scaffold(
        appBar: AppBar(title: const Text('Coach Setup')),
        body: ErrorState(
          message: _error ?? 'Could not load setup',
          onRetry: _check,
        ),
      ),
      OnboardingStep.coachDetails => CoachRegistrationScreen(
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
        session: widget.session,
        onComplete: () {
          final updated = widget.session.copyWith(
            needsCoachRegistration: false,
            hasCompletedUpiSetup: false,
          );
          widget.onSessionUpdated(updated);
          setState(() => _step = OnboardingStep.upiDetails);
        },
      ),
      OnboardingStep.upiDetails => UpiDetailsScreen(
        session: widget.session.copyWith(needsCoachRegistration: false),
        existingBizMe: _bizMe,
        onComplete: (session) => widget.onComplete(session),
      ),
    };
  }
}

class UpiDetailsScreen extends StatefulWidget {
  const UpiDetailsScreen({
    required this.session,
    required this.onComplete,
    this.existingBizMe = const {},
    super.key,
  });

  final AuthSession session;
  final Map<String, dynamic> existingBizMe;
  final ValueChanged<AuthSession> onComplete;

  @override
  State<UpiDetailsScreen> createState() => _UpiDetailsScreenState();
}

class _UpiDetailsScreenState extends State<UpiDetailsScreen> {
  final _upiCtrl = TextEditingController();
  final _beneficiaryCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _auth = CoachAuthService();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final account =
        (widget.existingBizMe['businessAccount'] as Map?)
            ?.cast<String, dynamic>() ??
        const {};
    _upiCtrl.text = account['upiId']?.toString() ?? '';
    _beneficiaryCtrl.text = account['beneficiaryName']?.toString() ?? '';
    _accountNumberCtrl.text = account['accountNumber']?.toString() ?? '';
    _ifscCtrl.text = account['ifscCode']?.toString() ?? '';
  }

  @override
  void dispose() {
    _upiCtrl.dispose();
    _beneficiaryCtrl.dispose();
    _accountNumberCtrl.dispose();
    _ifscCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final upi = _upiCtrl.text.trim();
    if (!_isValidUpi(upi)) {
      setState(() => _error = 'Enter a valid UPI ID, for example name@bank');
      return;
    }
    final accountNumber = _accountNumberCtrl.text.trim();
    final ifscCode = _ifscCtrl.text.trim().toUpperCase();
    if (accountNumber.isNotEmpty &&
        !RegExp(r'^\d{9,18}$').hasMatch(accountNumber)) {
      setState(() => _error = 'Enter a valid bank account number');
      return;
    }
    if (ifscCode.isNotEmpty &&
        !RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifscCode)) {
      setState(() => _error = 'Enter a valid IFSC code');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.updateBusinessDetails(
        accessToken: widget.session.accessToken,
        existingBusinessAccount:
            (widget.existingBizMe['businessAccount'] as Map?)
                ?.cast<String, dynamic>(),
        upiId: upi,
        beneficiaryName: _beneficiaryCtrl.text.trim(),
        accountNumber: accountNumber,
        ifscCode: ifscCode,
      );
      widget.onComplete(
        widget.session.copyWith(
          needsCoachRegistration: false,
          hasCompletedUpiSetup: true,
        ),
      );
    } catch (e) {
      setState(() => _error = _errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UPI Details')),
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
                    'Add payout UPI',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'UPI is required once to complete coach setup. Bank details are optional.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: _beneficiaryCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Beneficiary name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _upiCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'UPI ID'),
                  ),
                  const SizedBox(height: 20),
                  SectionTitle('Bank details'),
                  TextField(
                    controller: _accountNumberCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Account number',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ifscCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'IFSC code'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save UPI Details'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
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
}

enum OnboardingStep { loading, coachDetails, upiDetails, error }

final initialAuthSessionProvider = Provider<AuthSession>((ref) {
  throw StateError('Auth session has not been initialized');
});

final sessionStateProvider = StateProvider<AuthSession?>(
  (ref) => ref.watch(initialAuthSessionProvider),
);

final settingsStoreProvider = Provider<LocalSettingsStore>((ref) {
  throw StateError('Settings store has not been initialized');
});

final apiClientProvider = Provider<CoachApiClient>((ref) {
  return CoachApiClient(
    readSession: () => ref.read(sessionStateProvider),
    writeSession: (session) =>
        ref.read(sessionStateProvider.notifier).state = session,
  );
});

class CoachRouterApp extends ConsumerStatefulWidget {
  const CoachRouterApp({
    required this.session,
    required this.isDarkMode,
    required this.themeMode,
    required this.lightTheme,
    required this.darkTheme,
    required this.onThemeToggle,
    required this.onThemeModeChanged,
    required this.onSessionChanged,
    required this.onLogout,
    super.key,
  });

  final AuthSession session;
  final bool isDarkMode;
  final ThemeMode themeMode;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final VoidCallback onThemeToggle;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<AuthSession?> onSessionChanged;
  final VoidCallback onLogout;

  @override
  ConsumerState<CoachRouterApp> createState() => _CoachRouterAppState();
}

class _CoachRouterAppState extends ConsumerState<CoachRouterApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _buildRouter();
  }

  @override
  void didUpdateWidget(covariant CoachRouterApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.accessToken != widget.session.accessToken) {
      ref.read(sessionStateProvider.notifier).state = widget.session;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthSession?>(sessionStateProvider, (_, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (next == null) {
          widget.onLogout();
        } else {
          widget.onSessionChanged(next);
        }
      });
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Swing Coach',
      themeMode: widget.themeMode,
      theme: widget.lightTheme,
      darkTheme: widget.darkTheme,
      routerConfig: _router,
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => CoachShell(
            shell: shell,
            isDarkMode: widget.isDarkMode,
            onThemeToggle: widget.onThemeToggle,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/batch-tab',
                  builder: (context, state) => const BatchTabScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/play',
                  builder: (context, state) => Consumer(
                    builder: (context, ref, _) {
                      final session = ref.watch(sessionStateProvider);
                      return CoachPlayEntryScreen(
                        accessToken: session?.accessToken ?? '',
                        currentUserId: session?.phone,
                      );
                    },
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/one-on-one-tab',
                  builder: (context, state) => const OneToOneTabScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/payment-tab',
                  builder: (context, state) => const PaymentTabScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/sessions',
          builder: (context, state) => const SessionsScreen(),
          routes: [
            GoRoute(
              path: 'start',
              builder: (context, state) => const AutoSessionFlowScreen(),
            ),
            GoRoute(
              path: ':sessionId',
              builder: (context, state) => SessionDetailScreen(
                sessionId: state.pathParameters['sessionId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/schedules',
          builder: (context, state) => const SchedulesScreen(),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) => const ScheduleFormScreen(),
            ),
            GoRoute(
              path: ':scheduleId',
              builder: (context, state) => ScheduleDetailScreen(
                scheduleId: state.pathParameters['scheduleId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/drill-plans',
          builder: (context, state) => const DrillPlansScreen(),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) => const DrillPlanFormScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/batches',
          builder: (context, state) => const BatchesScreen(),
          routes: [
            GoRoute(
              path: ':batchId',
              builder: (context, state) =>
                  BatchDetailScreen(batchId: state.pathParameters['batchId']!),
            ),
          ],
        ),
        GoRoute(
          path: '/batch-setup',
          builder: (context, state) => const QuickBatchSetupScreen(),
        ),
        GoRoute(
          path: '/gigs',
          builder: (context, state) => const GigBookingsScreen(),
          routes: [
            GoRoute(
              path: ':bookingId',
              builder: (context, state) => GigBookingDetailScreen(
                bookingId: state.pathParameters['bookingId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/earnings',
          builder: (context, state) => const EarningsScreen(),
        ),
        GoRoute(
          path: '/one-on-one',
          builder: (context, state) => const OneOnOneSettingsScreen(),
        ),
        GoRoute(
          path: '/one-on-one/activate',
          builder: (context, state) => const ActivateOneOnOneSessionScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const CoachProfileScreen(),
          routes: [
            GoRoute(
              path: 'view',
              builder: (context, state) => const CoachProfileViewScreen(),
            ),
            GoRoute(
              path: 'banking',
              builder: (context, state) => const BankingDetailsScreen(),
            ),
            GoRoute(
              path: 'edit',
              builder: (context, state) => const EditCoachProfileScreen(),
            ),
            GoRoute(
              path: 'payout',
              builder: (context, state) => const PayoutDetailsEditScreen(),
            ),
            GoRoute(
              path: 'action/:actionId',
              builder: (context, state) => ProfileActionPlaceholderScreen(
                actionId: state.pathParameters['actionId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/support/help-center',
          builder: (context, state) => const HelpCenterScreen(),
        ),
        GoRoute(
          path: '/support/email',
          builder: (context, state) => const EmailSupportScreen(),
        ),
        GoRoute(
          path: '/support/report-bug',
          builder: (context, state) => const ReportBugScreen(),
        ),
        GoRoute(
          path: '/support/live-chat',
          builder: (context, state) => const LiveChatScreen(),
        ),
        GoRoute(
          path: '/report-cards',
          builder: (context, state) => const ReportCardsScreen(),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) => const ReportCardFormScreen(),
            ),
            GoRoute(
              path: ':reportCardId',
              builder: (context, state) => ReportCardDetailScreen(
                reportCardId: state.pathParameters['reportCardId']!,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CoachShell extends ConsumerWidget {
  const CoachShell({
    required this.shell,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onThemeModeChanged,
    super.key,
  });

  final StatefulNavigationShell shell;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Batch',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_tennis_outlined),
            selectedIcon: Icon(Icons.sports_tennis),
            label: 'Play',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_pin_circle_outlined),
            selectedIcon: Icon(Icons.person_pin_circle),
            label: '1-to-1',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Payment',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadHomeDashboard(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const HomeDashboardSkeleton();
          }
          if (snapshot.hasError) {
            return LoadingView(label: _errorMessage(snapshot.error));
          }
          final data = snapshot.data ?? const <String, dynamic>{};
          final coachName = data['coachName']?.toString() ?? 'Coach';
          final profileSummary =
              (data['profileSummary'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          final activeBatches = data['activeBatches'] as int? ?? 0;
          final monthlyOneOnOneBookings =
              data['monthlyOneOnOneBookings'] as int? ?? 0;
          final monthlyRevenuePaise = data['monthlyRevenuePaise'] as num? ?? 0;
          final revenueSeries =
              (data['revenueSeries'] as List?)?.cast<Map<String, dynamic>>() ??
              const <Map<String, dynamic>>[];
          final hasRevenueData = data['hasRevenueData'] == true;
          final todaySessions =
              (data['todaySessions'] as List?)?.cast<Map<String, dynamic>>() ??
              const [];
          final batchSetupComplete = data['batchSetupComplete'] == true;
          final oneOnOneSetupComplete = data['oneOnOneSetupComplete'] == true;
          final showSetupSection =
              !batchSetupComplete || !oneOnOneSetupComplete;
          final upcomingFromTimetable =
              (data['upcomingTimetable'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              const [];
          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => (context as Element).markNeedsBuild(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  GreetingHeader(
                    coachName: coachName,
                    onNotificationsTap: () => context.push('/notifications'),
                    onProfileTap: () =>
                        showCoachProfileDrawer(context, ref, profileSummary),
                  ),
                  const SizedBox(height: 16),
                  RevenueChartCard(
                    enabled: hasRevenueData,
                    monthlyRevenuePaise: monthlyRevenuePaise,
                    series: revenueSeries,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Active Batches',
                          value: '$activeBatches',
                          icon: Icons.groups_2_outlined,
                          subtext: 'Batches currently assigned to you',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: '1-to-1 Bookings',
                          value: '$monthlyOneOnOneBookings',
                          icon: Icons.person_pin_circle_outlined,
                          subtext: 'Booked sessions this month',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (showSetupSection) ...[
                    SectionTitle('Session Setup'),
                    if (!batchSetupComplete)
                      ActionRow(
                        leading: const Icon(Icons.grid_view_rounded),
                        title: 'Quick Batch Setup',
                        subtitle:
                            'Choose one session type per day for your week.',
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/batch-setup'),
                      ),
                    if (!oneOnOneSetupComplete)
                      ActionRow(
                        leading: const Icon(Icons.person_add_alt_rounded),
                        title: 'Activate 1-to-1 Session',
                        subtitle: 'Set up private coaching in about a minute.',
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/one-on-one/activate'),
                      ),
                  ] else ...[
                    UpcomingSessionsCard(items: upcomingFromTimetable),
                  ],
                  const SizedBox(height: 16),
                  SectionTitle('Quick Actions'),
                  QuickAction(
                    icon: Icons.play_arrow_rounded,
                    label: 'Start Session',
                    onTap: () => context.push('/sessions/start'),
                  ),
                  QuickAction(
                    icon: Icons.add_task_rounded,
                    label: 'Create Drill',
                    onTap: () => context.push('/drills/create'),
                  ),
                  QuickAction(
                    icon: Icons.rate_review_outlined,
                    label: 'Give Feedback',
                    onTap: () => showFeedbackSheet(context, ref),
                  ),
                  const SizedBox(height: 10),
                  SectionTitle('Sessions Overview'),
                  if (todaySessions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No session scheduled right now.'),
                    ),
                  ...todaySessions.map(
                    (item) => SessionRow(
                      item: item,
                      onTap: () => context.push('/sessions/${_idOf(item)}'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadHomeDashboard(WidgetRef ref) async {
    final api = ref.read(apiClientProvider);
    final data = await Future.wait([
      api.get('/coach/profile'),
      api.get('/coach/earnings'),
      api.getList('/coach/sessions', query: {'page': '1', 'limit': '50'}),
      api.getList('/coach/batches'),
      api.getList('/coach/schedules'),
      api.getList('/coach/gig-bookings', query: {'page': '1', 'limit': '50'}),
    ]);
    final profile = data[0] as Map<String, dynamic>;
    final earnings = data[1] as Map<String, dynamic>;
    final sessions = (data[2] as List).cast<Map<String, dynamic>>();
    final batches = (data[3] as List).cast<Map<String, dynamic>>();
    final schedules = (data[4] as List).cast<Map<String, dynamic>>();
    final oneOnOneBookings = (data[5] as List).cast<Map<String, dynamic>>();
    final revenueSeries = _revenueTrend(earnings);
    final monthlyRevenue = _extractMonthlyRevenuePaise(earnings);
    final oneOnOneSetupComplete = await ref
        .read(settingsStoreProvider)
        .isOneOnOneSetupCompleted();
    return {
      'coachName': _labelOf(profile, ['name', 'coachName', 'fullName']),
      'profileSummary': _profileSummary(profile),
      'activeBatches': batches
          .where((batch) => _read(batch, ['isActive']) != false)
          .length,
      'monthlyOneOnOneBookings': oneOnOneBookings
          .where(_isCurrentMonthBooking)
          .length,
      'monthlyRevenuePaise': monthlyRevenue,
      'revenueSeries': revenueSeries,
      'hasRevenueData':
          monthlyRevenue > 0 ||
          revenueSeries.any((item) => (item['amountPaise'] as num? ?? 0) > 0),
      'todaySessions': sessions.where(_isTodaySession).toList(),
      'batchSetupComplete': _isBatchSetupComplete(batches, schedules),
      'oneOnOneSetupComplete': oneOnOneSetupComplete,
      'upcomingTimetable': [
        ..._upcomingTimetableToday(schedules),
        ...oneOnOneBookings.where(_isTodaySession).map(_oneOnOneSessionCard),
      ],
    };
  }
}

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilteredListScreen(
      title: 'Sessions',
      tabs: const ['Upcoming', 'Live', 'Completed', 'Cancelled'],
      load: (tab) => ref
          .read(apiClientProvider)
          .getList('/coach/sessions', query: {'page': '1', 'limit': '20'}),
      filter: (item, tab, query) {
        final status = _read(item, ['status'])?.toString().toUpperCase();
        final tabStatus = switch (tab) {
          'Upcoming' => 'SCHEDULED',
          'Live' => 'LIVE',
          'Completed' => 'COMPLETED',
          _ => 'CANCELLED',
        };
        return status == tabStatus;
      },
      itemBuilder: (context, item) => SessionRow(
        item: item,
        onTap: () => context.push('/sessions/${_idOf(item)}'),
      ),
      fab: FloatingActionButton(
        onPressed: () => context.push('/sessions/start'),
        child: const Icon(Icons.play_arrow_rounded),
      ),
    );
  }
}

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DetailPage(
      title: 'Session Detail',
      load: () async {
        final all = await ref
            .read(apiClientProvider)
            .getList('/coach/sessions', query: {'page': '1', 'limit': '50'});
        return all.firstWhere(
          (e) => _idOf(e) == sessionId,
          orElse: () => {'id': sessionId},
        );
      },
      actionsBuilder: (item, reload) => [
        if (_statusOf(item) == 'SCHEDULED')
          ActionChip(
            label: const Text('Cancel'),
            onPressed: () async {
              await ref
                  .read(apiClientProvider)
                  .post('/coach/sessions/$sessionId/cancel', {});
              reload();
            },
          ),
        if (_statusOf(item) == 'LIVE') ...[
          ActionChip(
            label: const Text('Generate QR'),
            onPressed: () async {
              await ref
                  .read(apiClientProvider)
                  .post('/coach/sessions/$sessionId/generate-qr', {});
              reload();
            },
          ),
          ActionChip(
            label: const Text('Close QR'),
            onPressed: () async {
              await ref
                  .read(apiClientProvider)
                  .post('/coach/sessions/$sessionId/close-qr', {});
              reload();
            },
          ),
        ],
        if (_statusOf(item) == 'COMPLETED')
          ActionChip(
            label: const Text('Give Feedback'),
            onPressed: () => showFeedbackSheet(
              context,
              ref,
              sessionId: sessionId,
              sessionType:
                  _read(item, ['sessionType', 'sessionTypeName'])?.toString() ??
                  'drills',
              sessionItem: item,
            ),
          ),
      ],
      extraBuilder: (context, item, reload) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_read(item, ['qrCodeUrl', 'qrImageUrl']) != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Image.network(
                _read(item, ['qrCodeUrl', 'qrImageUrl']).toString(),
              ),
            ),
          SectionTitle('Attendance'),
          ..._listAt(item, ['attendance', 'students']).map(
            (student) => ActionRow(
              title: _studentName(student),
              subtitle: _read(student, ['status'])?.toString(),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () =>
                  showAttendanceSheet(context, ref, sessionId, student, reload),
            ),
          ),
          SectionTitle('Drill Plan'),
          ..._listAt(item, ['drillPlan', 'drills', 'items']).map(
            (drill) => ActionRow(
              title: _read(drill, ['name', 'drillName'])?.toString() ?? 'Drill',
              subtitle:
                  'Sets ${_read(drill, ['sets']) ?? '-'} · Reps ${_read(drill, ['reps']) ?? '-'}',
            ),
          ),
        ],
      ),
    );
  }
}

class SchedulesScreen extends ConsumerWidget {
  const SchedulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshableListPage(
      title: 'Schedules',
      load: () => ref.read(apiClientProvider).getList('/coach/schedules'),
      itemBuilder: (context, item) => ActionRow(
        title: _labelOf(item, ['sessionType', 'sessionTypeName']),
        subtitle:
            '${_daysLabel(item['daysOfWeek'])} · ${_read(item, ['startTime']) ?? ''}',
        leading: Switch(
          value: _read(item, ['isActive']) != false,
          onChanged: (value) => ref.read(apiClientProvider).patch(
            '/coach/schedules/${_idOf(item)}',
            {'isActive': value},
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push('/schedules/${_idOf(item)}'),
      ),
      emptyLabel: 'No recurring schedules.',
      fab: FloatingActionButton(
        onPressed: () => context.push('/schedules/create'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class ScheduleFormScreen extends ConsumerWidget {
  const ScheduleFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicFormScreen(
      title: 'Create Schedule',
      fields: const [
        FormFieldSpec('sessionType', 'Session type', options: sessionTypes),
        FormFieldSpec('daysOfWeek', 'Days of week (0,1,3)'),
        FormFieldSpec('startTime', 'Start time HH:mm'),
        FormFieldSpec('durationMins', 'Duration mins', number: true),
        FormFieldSpec('academyId', 'Academy ID'),
        FormFieldSpec('batchId', 'Batch ID'),
      ],
      normalize: (body) {
        final days =
            body['daysOfWeek']?.toString().split(',') ?? const <String>[];
        body['daysOfWeek'] = days
            .map((e) => int.tryParse(e.trim()))
            .whereType<int>()
            .toList();
        return body;
      },
      onSubmit: (body) =>
          ref.read(apiClientProvider).post('/coach/schedules', body),
    );
  }
}

class ScheduleDetailScreen extends ConsumerWidget {
  const ScheduleDetailScreen({required this.scheduleId, super.key});

  final String scheduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DetailPage(
      title: 'Schedule Detail',
      load: () async {
        final items = await ref
            .read(apiClientProvider)
            .getList('/coach/schedules');
        return items.firstWhere(
          (e) => _idOf(e) == scheduleId,
          orElse: () => {'id': scheduleId},
        );
      },
      actionsBuilder: (item, reload) => [
        ActionChip(
          label: const Text('Generate Sessions'),
          onPressed: () => showGenerateSessionsSheet(context, ref, scheduleId),
        ),
      ],
    );
  }
}

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchListScreen(
      title: 'Students',
      load: () => ref.read(apiClientProvider).getList('/coach/students'),
      matches: (item, query) =>
          _studentName(item).toLowerCase().contains(query.toLowerCase()),
      itemBuilder: (context, item) => ActionRow(
        title: _studentName(item),
        subtitle:
            '${_labelOf(item, ['batchName', 'batch.name'])} · ${_percent(_read(item, ['attendanceRate', 'attendancePercent']))}',
        trailing: SignalBadge(
          _read(item, ['overallSignal', 'signal'])?.toString(),
        ),
        onTap: () => context.push('/students/${_idOf(item)}'),
      ),
      emptyLabel: 'No students found.',
      fab: FloatingActionButton.extended(
        onPressed: () => context.push('/profile/action/add-student'),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Add Student'),
      ),
    );
  }
}

class StudentDetailScreen extends ConsumerWidget {
  const StudentDetailScreen({required this.playerProfileId, super.key});

  final String playerProfileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DetailPage(
      title: 'Student Detail',
      load: () async {
        final students = await ref
            .read(apiClientProvider)
            .getList('/coach/students');
        return students.firstWhere(
          (e) => _idOf(e) == playerProfileId,
          orElse: () => {'id': playerProfileId},
        );
      },
      actionsBuilder: (item, reload) => [
        ActionChip(
          label: const Text('Give Feedback'),
          onPressed: () => showFeedbackSheet(
            context,
            ref,
            playerProfileId: playerProfileId,
            sessionType: 'drills',
            sessionItem: item,
          ),
        ),
        ActionChip(
          label: const Text('Create Report Card'),
          onPressed: () => context.push('/report-cards/create'),
        ),
      ],
      extraBuilder: (context, item, reload) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle('Feedback'),
          ..._listAt(item, ['feedback', 'feedbacks']).map(
            (feedback) => ActionRow(
              title:
                  _read(feedback, ['feedbackText', 'text'])?.toString() ??
                  'Feedback',
              subtitle: _formatDate(_read(feedback, ['createdAt'])?.toString()),
            ),
          ),
          SectionTitle('Report Cards'),
          ..._listAt(item, ['reportCards']).map(
            (card) => ActionRow(
              title:
                  '${_read(card, ['periodMonth'])}/${_read(card, ['periodYear'])}',
              subtitle:
                  'Swing ${_read(card, ['swingIndexStart'])}-${_read(card, ['swingIndexEnd'])} · ${_percent(_read(card, ['attendanceRate']))}',
            ),
          ),
        ],
      ),
    );
  }
}

class DrillsScreen extends ConsumerWidget {
  const DrillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchListScreen(
      title: 'Drills',
      load: () => ref.read(apiClientProvider).getList('/coach/drills'),
      matches: (item, query) =>
          _labelOf(item, ['name']).toLowerCase().contains(query.toLowerCase()),
      itemBuilder: (context, item) => ActionRow(
        title: _labelOf(item, ['name']),
        subtitle:
            '${_read(item, ['category']) ?? 'Technique'} · ${_read(item, ['difficulty']) ?? '-'} · ${_read(item, ['durationMins']) ?? '-'} mins',
        trailing: Text('${_read(item, ['usageCount']) ?? 0} uses'),
        onTap: () => context.push('/drills/${_idOf(item)}'),
      ),
      emptyLabel: 'No drills in library.',
      fab: FloatingActionButton(
        onPressed: () => context.push('/drills/create'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class DrillFormScreen extends ConsumerWidget {
  const DrillFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicFormScreen(
      title: 'Create Drill',
      fields: const [
        FormFieldSpec('name', 'Name', required: true),
        FormFieldSpec('description', 'Description', multiline: true),
        FormFieldSpec('roleTags', 'Role tags comma separated'),
        FormFieldSpec(
          'category',
          'Category',
          options: ['TECHNIQUE', 'FITNESS', 'MENTAL', 'MATCH_SIMULATION'],
        ),
        FormFieldSpec(
          'difficulty',
          'Difficulty',
          options: ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'],
        ),
        FormFieldSpec('durationMins', 'Duration mins', number: true),
        FormFieldSpec(
          'targetUnit',
          'Target unit',
          options: ['BALLS', 'OVERS', 'MINUTES', 'REPS', 'SESSIONS'],
        ),
        FormFieldSpec('skillArea', 'Skill area'),
        FormFieldSpec('subSkill', 'Sub skill'),
        FormFieldSpec('videoUrl', 'Video URL'),
        FormFieldSpec('isActive', 'Active', boolean: true, initial: 'true'),
        FormFieldSpec('isPublic', 'Public', boolean: true),
      ],
      normalize: _normalizeCommaFields(['roleTags']),
      onSubmit: (body) =>
          ref.read(apiClientProvider).post('/coach/drills', body),
    );
  }
}

class DrillDetailScreen extends ConsumerWidget {
  const DrillDetailScreen({required this.drillId, super.key});

  final String drillId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DetailPage(
      title: 'Drill Detail',
      load: () => ref.read(apiClientProvider).get('/coach/drills/$drillId'),
    );
  }
}

class DrillPlansScreen extends ConsumerWidget {
  const DrillPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshableListPage(
      title: 'Drill Plans',
      load: () => ref.read(apiClientProvider).getList('/coach/drill-plans'),
      itemBuilder: (context, item) => ActionRow(
        title: _labelOf(item, ['name']),
        subtitle:
            '${_listAt(item, ['items', 'drills']).length} items · ${_read(item, ['description']) ?? ''}',
      ),
      emptyLabel: 'No drill plans.',
      fab: FloatingActionButton(
        onPressed: () => context.push('/drill-plans/create'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class DrillPlanFormScreen extends ConsumerWidget {
  const DrillPlanFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicFormScreen(
      title: 'Create Drill Plan',
      fields: const [
        FormFieldSpec('name', 'Name', required: true),
        FormFieldSpec('description', 'Description', multiline: true),
        FormFieldSpec('items', 'Items JSON array', multiline: true),
      ],
      normalize: (body) {
        if ((body['items'] ?? '').toString().trim().isEmpty) {
          body['items'] = <Map<String, dynamic>>[];
        } else {
          body['items'] = jsonDecode(body['items'].toString());
        }
        return body;
      },
      onSubmit: (body) =>
          ref.read(apiClientProvider).post('/coach/drill-plans', body),
    );
  }
}

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      ('Sessions', '/sessions', Icons.event_available_outlined),
      ('Schedules', '/schedules', Icons.repeat_rounded),
      ('Batches', '/batches', Icons.groups_outlined),
      ('Quick Batch Setup', '/batch-setup', Icons.grid_view_rounded),
      ('Gigs', '/gigs', Icons.work_outline_rounded),
      ('Earnings', '/earnings', Icons.currency_rupee_rounded),
      ('Report Cards', '/report-cards', Icons.assignment_outlined),
      ('1-on-1 Settings', '/one-on-one', Icons.person_pin_circle_outlined),
      ('Profile & Settings', '/profile', Icons.settings_outlined),
    ];
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ActionRow(
          leading: Icon(item.$3),
          title: item.$1,
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(item.$2),
        );
      },
    );
  }
}

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshableListPage(
      title: 'Batches',
      load: () => ref.read(apiClientProvider).getList('/coach/batches'),
      itemBuilder: (context, item) => ActionRow(
        title: _labelOf(item, ['name', 'batchName']),
        subtitle:
            '${_labelOf(item, ['academyName', 'academy.name'])} · ${_listAt(item, ['students']).length} students',
        trailing: _read(item, ['isHeadCoach']) == true
            ? const StatusBadge('HEAD')
            : const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push('/batches/${_idOf(item)}'),
      ),
      emptyLabel: 'No assigned batches.',
    );
  }
}

class BatchDetailScreen extends ConsumerWidget {
  const BatchDetailScreen({required this.batchId, super.key});

  final String batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DetailPage(
      title: 'Batch Detail',
      load: () async {
        final batches = await ref
            .read(apiClientProvider)
            .getList('/coach/batches');
        return batches.firstWhere(
          (e) => _idOf(e) == batchId,
          orElse: () => {'id': batchId},
        );
      },
      actionsBuilder: (item, reload) => [
        ActionChip(
          label: const Text('Start Session'),
          onPressed: () => context.push('/sessions/start'),
        ),
      ],
    );
  }
}

class BatchTabScreen extends ConsumerWidget {
  const BatchTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Batch')),
      body: RefreshableListPage(
        title: '',
        load: () async {
          final data = await Future.wait([
            ref.read(apiClientProvider).getList('/coach/batches'),
            ref.read(apiClientProvider).getList('/coach/schedules'),
          ]);
          final batches = (data[0] as List).cast<Map<String, dynamic>>();
          final schedules = (data[1] as List).cast<Map<String, dynamic>>();
          return batches.map((batch) {
            final batchId = _idOf(batch);
            final batchSchedules = schedules
                .where((s) => _read(s, ['batchId'])?.toString() == batchId)
                .toList();
            final byDay = <String, String>{};
            for (final s in batchSchedules) {
              final type = _titleCase(
                (_read(s, ['sessionType'])?.toString().toLowerCase() ?? ''),
              );
              for (final d in _listAt(s, ['daysOfWeek'])) {
                final dayIndex = int.tryParse('$d');
                if (dayIndex != null &&
                    dayIndex >= 0 &&
                    dayIndex < _days.length) {
                  byDay[_days[dayIndex]] = type;
                }
              }
            }
            return {
              ...batch,
              '_days': byDay.entries
                  .map((e) => '${e.key}:${e.value}')
                  .join('  '),
            };
          }).toList();
        },
        itemBuilder: (context, item) => Card(
          margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: ListTile(
            title: Text(
              _labelOf(item, ['name', 'batchName']),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${_labelOf(item, ['academyName', 'academy.name'])}\n${_read(item, ['_days'])?.toString() ?? ''}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/batches/${_idOf(item)}'),
          ),
        ),
        emptyLabel: 'No assigned batches.',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/batch-setup'),
        label: const Text('Create Batch'),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class PlayTabScreen extends ConsumerStatefulWidget {
  const PlayTabScreen({super.key});

  @override
  ConsumerState<PlayTabScreen> createState() => _PlayTabScreenState();
}

class _PlayTabScreenState extends ConsumerState<PlayTabScreen> {
  int _step = 0;
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _arenas = const [];
  List<Map<String, dynamic>> _slots = const [];
  Map<String, dynamic>? _selectedArena;
  String? _selectedSport;
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _loadArenas();
  }

  Future<void> _loadArenas() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      List<Map<String, dynamic>> arenas = const [];
      for (final path in ['/arenas', '/public/arenas', '/coach/arenas']) {
        arenas = await api.getList(path, query: {'page': '1', 'limit': '50'});
        if (arenas.isNotEmpty) break;
      }
      if (!mounted) return;
      setState(() {
        _arenas = arenas;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _errorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _loadSlots() async {
    if (_selectedArena == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final arenaId = _idOf(_selectedArena!);
      List<Map<String, dynamic>> slots = const [];
      for (final path in [
        '/arena/$arenaId/slots',
        '/arena/$arenaId/availability',
        '/bookings/availability',
      ]) {
        slots = await api.getList(
          path,
          query: {'date': _selectedDate.toIso8601String()},
        );
        if (slots.isNotEmpty) break;
      }
      if (!mounted) return;
      setState(() {
        _slots = slots;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _errorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _confirmBooking() async {
    final arena = _selectedArena;
    if (arena == null || _selectedSlot == null || _selectedSport == null)
      return;
    final api = ref.read(apiClientProvider);
    await api.post('/bookings', {
      'arenaId': _idOf(arena),
      'sport': _selectedSport,
      'date': _selectedDate.toIso8601String(),
      'slot': _selectedSlot,
    });
    if (!mounted) return;
    setState(() => _step = 6);
  }

  @override
  Widget build(BuildContext context) {
    final sports = const ['Cricket', 'Football', 'Badminton', 'Fitness'];
    return Scaffold(
      appBar: AppBar(title: const Text('Play')),
      body: _loading
          ? const LoadingView(label: 'Loading')
          : _error != null
          ? InlineError(
              message: _error!,
              onRetry: _step <= 1 ? _loadArenas : _loadSlots,
            )
          : Stepper(
              currentStep: _step.clamp(0, 5),
              onStepContinue: () async {
                if (_step == 0 && _selectedArena != null)
                  setState(() => _step = 1);
                else if (_step == 1 && _selectedSport != null) {
                  setState(() => _step = 2);
                  await _loadSlots();
                } else if (_step == 2 && _selectedSlot != null)
                  setState(() => _step = 3);
                else if (_step == 3)
                  setState(() => _step = 4);
                else if (_step == 4)
                  setState(() => _step = 5);
                else if (_step == 5)
                  await _confirmBooking();
              },
              onStepCancel: () {
                if (_step > 0) setState(() => _step--);
              },
              steps: [
                Step(
                  title: const Text('Select Arena / Ground'),
                  isActive: _step >= 0,
                  content: _arenas.isEmpty
                      ? const Text('No arenas found.')
                      : Column(
                          children: _arenas
                              .map(
                                (a) => RadioListTile<String>(
                                  value: _idOf(a),
                                  groupValue: _selectedArena == null
                                      ? null
                                      : _idOf(_selectedArena!),
                                  title: Text(
                                    _labelOf(a, ['name', 'arenaName']),
                                  ),
                                  subtitle: Text(
                                    _labelOf(a, [
                                      'address',
                                      'location',
                                      'city',
                                    ]),
                                  ),
                                  onChanged: (_) =>
                                      setState(() => _selectedArena = a),
                                ),
                              )
                              .toList(),
                        ),
                ),
                Step(
                  title: const Text('Select Sport / Activity'),
                  isActive: _step >= 1,
                  content: Wrap(
                    spacing: 8,
                    children: sports
                        .map(
                          (s) => ChoiceChip(
                            label: Text(s),
                            selected: _selectedSport == s,
                            onSelected: (_) =>
                                setState(() => _selectedSport = s),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Step(
                  title: const Text('Select Date & Time Slot'),
                  isActive: _step >= 2,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          final next = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                            initialDate: _selectedDate,
                          );
                          if (next != null) {
                            setState(() => _selectedDate = next);
                            await _loadSlots();
                          }
                        },
                        child: Text(
                          'Date: ${_selectedDate.toLocal().toString().split(' ').first}',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._slots.map((s) {
                        final label = _labelOf(s, [
                          'label',
                          'slot',
                          'time',
                          'startTime',
                        ]);
                        return RadioListTile<String>(
                          value: label,
                          groupValue: _selectedSlot,
                          title: Text(label),
                          onChanged: (v) => setState(() => _selectedSlot = v),
                        );
                      }),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Availability Check'),
                  isActive: _step >= 3,
                  content: const Text('Selected slot is available.'),
                ),
                Step(
                  title: const Text('Booking Summary'),
                  isActive: _step >= 4,
                  content: Text(
                    '${_labelOf(_selectedArena ?? const {}, ['name', 'arenaName'])}\n${_selectedSport ?? '-'}\n${_selectedDate.toLocal().toString().split(' ').first} • ${_selectedSlot ?? '-'}',
                  ),
                ),
                Step(
                  title: const Text('Confirm Booking'),
                  isActive: _step >= 5,
                  content: const Text('Tap continue to confirm booking.'),
                ),
              ],
            ),
      bottomNavigationBar: _step >= 6
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Success Screen',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const Text('Booking confirmed successfully.'),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: () => setState(() => _step = 0),
                      child: const Text('Book Another'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class OneToOneTabScreen extends ConsumerWidget {
  const OneToOneTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilteredListScreen(
      title: '1-to-1 Sessions',
      tabs: const ['Upcoming', 'Completed'],
      load: (tab) => ref
          .read(apiClientProvider)
          .getList('/coach/gig-bookings', query: {'page': '1', 'limit': '30'}),
      filter: (item, tab, query) {
        final status = _statusOf(item);
        return tab == 'Upcoming' ? status == 'UPCOMING' : status == 'COMPLETED';
      },
      itemBuilder: (context, item) => ActionRow(
        title: _studentName(item),
        subtitle:
            '${_formatDate(_read(item, ['scheduledAt'])?.toString())} • ${_labelOf(item, ['status'])}',
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => context.push('/gigs/${_idOf(item)}'),
      ),
      fab: FloatingActionButton.extended(
        onPressed: () => showBookOneToOneSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book Session'),
      ),
    );
  }
}

class PaymentTabScreen extends ConsumerWidget {
  const PaymentTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadPaymentTab(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(label: 'Loading payments');
          }
          if (snapshot.hasError) {
            return InlineError(
              message: _errorMessage(snapshot.error),
              onRetry: () => (context as Element).markNeedsBuild(),
            );
          }
          final data = snapshot.data ?? const {};
          final txns =
              (data['transactions'] as List?)?.cast<Map<String, dynamic>>() ??
              const [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total',
                      value: _rupees(data['total']),
                      icon: Icons.payments_outlined,
                      subtext: 'Earnings',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: 'This Month',
                      value: _rupees(data['month']),
                      icon: Icons.calendar_month_rounded,
                      subtext: 'Current month',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              StatCard(
                title: 'Pending',
                value: _rupees(data['pending']),
                icon: Icons.timelapse_rounded,
                subtext: 'Pending payouts',
              ),
              const SizedBox(height: 16),
              const SectionTitle('Transactions'),
              if (txns.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('No payments found.'),
                ),
              ...txns.map(
                (t) => ActionRow(
                  title: _studentName(t),
                  subtitle:
                      '${_formatDate(_read(t, ['scheduledAt'])?.toString())} • ${_statusOf(t)}',
                  trailing: Text(_rupees(_read(t, ['amountPaise', 'amount']))),
                  onTap: () => context.push('/gigs/${_idOf(t)}'),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: () => context.push('/profile/payout'),
                icon: const Icon(Icons.account_balance_outlined),
                label: const Text('Payout Settings'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AutoSessionFlowScreen extends ConsumerStatefulWidget {
  const AutoSessionFlowScreen({super.key});

  @override
  ConsumerState<AutoSessionFlowScreen> createState() =>
      _AutoSessionFlowScreenState();
}

class _AutoSessionFlowScreenState extends ConsumerState<AutoSessionFlowScreen> {
  bool _loading = true;
  String? _error;
  _LiveSessionContext? _ctx;
  final Map<String, bool> _attendance = {};
  bool _savingAttendance = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final loaded = await _detectOrCreateLiveSession(ref);
      _ctx = loaded;
      _attendance
        ..clear()
        ..addEntries(loaded.players.map((p) => MapEntry(_idOf(p), true)));
    } catch (e) {
      _error = _errorMessage(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveAttendanceAndContinue() async {
    if (_ctx == null || _savingAttendance) return;
    setState(() => _savingAttendance = true);
    try {
      final api = ref.read(apiClientProvider);
      for (final player in _ctx!.players) {
        await api.post('/coach/sessions/${_ctx!.sessionId}/attendance', {
          'playerProfileId': _idOf(player),
          'status': _attendance[_idOf(player)] == true ? 'PRESENT' : 'ABSENT',
        });
      }
      if (!mounted) return;
      final present = _ctx!.players
          .where((p) => _attendance[_idOf(p)] == true)
          .toList();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CoachFeedbackFlowScreen(
            sessionId: _ctx!.sessionId,
            sessionType: _toFeedbackTemplateType(_ctx!.sessionType),
            players: present
                .map(
                  (p) => FeedbackPlayer(
                    playerId: _idOf(p),
                    playerName: _studentName(p),
                  ),
                )
                .toList(),
            submitRows: (rows) async {
              final auth = ref.read(sessionStateProvider);
              await submitFeedback(
                SessionFeedbackPayload(
                  sessionId: _ctx!.sessionId,
                  sessionType: _toFeedbackTemplateType(_ctx!.sessionType),
                  coachId: auth?.phone ?? auth?.userName ?? 'coach',
                  players: rows,
                ),
                apiSubmit: (data) => api.post('/feedback', data),
              );
            },
            onSubmitted: () async {
              try {
                await api.post(
                  '/coach/sessions/${_ctx!.sessionId}/complete',
                  {},
                );
              } catch (_) {}
            },
          ),
        ),
      );
      if (mounted) context.go('/home');
    } finally {
      if (mounted) setState(() => _savingAttendance = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: LoadingView(label: 'Detecting session'));
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Start Session')),
        body: InlineError(message: _error!, onRetry: _load),
      );
    }
    if (_ctx == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Start Session')),
        body: const EmptyState(
          icon: Icons.event_busy_outlined,
          title: 'No Session Scheduled',
          subtitle: 'No active batch session found for this time.',
        ),
      );
    }
    if (_ctx!.players.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Start Session')),
        body: const EmptyState(
          icon: Icons.group_off_outlined,
          title: 'No Players Assigned',
          subtitle: 'This batch has no players yet.',
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Start Session')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _ctx!.batchName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_titleCase(_ctx!.sessionType)} • ${_ctx!.timeLabel}',
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Start Session'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
              itemCount: _ctx!.players.length,
              itemBuilder: (context, i) {
                final player = _ctx!.players[i];
                final id = _idOf(player);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(_avatarLetter(_studentName(player))),
                    ),
                    title: Text(
                      _studentName(player),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: Switch(
                      value: _attendance[id] ?? true,
                      onChanged: (v) => setState(() => _attendance[id] = v),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: FilledButton(
            onPressed: _savingAttendance ? null : _saveAttendanceAndContinue,
            child: Text(_savingAttendance ? 'Saving...' : 'Save & Continue'),
          ),
        ),
      ),
    );
  }
}

class GigBookingsScreen extends ConsumerWidget {
  const GigBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilteredListScreen(
      title: 'Gig Bookings',
      tabs: const ['Upcoming', 'Completed', 'Cancelled'],
      load: (tab) => ref
          .read(apiClientProvider)
          .getList('/coach/gig-bookings', query: {'page': '1', 'limit': '20'}),
      filter: (item, tab, query) =>
          _statusOf(item) ==
          (tab == 'Upcoming' ? 'UPCOMING' : tab.toUpperCase()),
      itemBuilder: (context, item) => ActionRow(
        title: _studentName(item),
        subtitle:
            '${_labelOf(item, ['gigTitle', 'title'])} · ${_formatDate(_read(item, ['scheduledAt'])?.toString())}',
        trailing: Text(_rupees(_read(item, ['amountPaise']))),
        onTap: () => context.push('/gigs/${_idOf(item)}'),
      ),
    );
  }
}

class GigBookingDetailScreen extends ConsumerWidget {
  const GigBookingDetailScreen({required this.bookingId, super.key});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DetailPage(
      title: 'Booking Detail',
      load: () async {
        final bookings = await ref
            .read(apiClientProvider)
            .getList(
              '/coach/gig-bookings',
              query: {'page': '1', 'limit': '50'},
            );
        return bookings.firstWhere(
          (e) => _idOf(e) == bookingId,
          orElse: () => {'id': bookingId},
        );
      },
    );
  }
}

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DetailPage(
      title: 'Earnings',
      load: () => ref.read(apiClientProvider).get('/coach/earnings'),
      extraBuilder: (context, item, reload) => Column(
        children: _listAt(item, ['monthlyBreakdown', 'months']).map((month) {
          return ActionRow(
            title: _read(month, ['monthName', 'month'])?.toString() ?? 'Month',
            subtitle: '${_read(month, ['sessions']) ?? 0} sessions',
            trailing: Text(_rupees(_read(month, ['amountPaise', 'amount']))),
          );
        }).toList(),
      ),
    );
  }
}

class OneOnOneSettingsScreen extends ConsumerWidget {
  const OneOnOneSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicFormScreen(
      title: '1-on-1 Settings',
      loadInitial: () => ref.read(apiClientProvider).get('/coach/profile'),
      fields: const [
        FormFieldSpec('oneOnOneEnabled', 'Enabled', boolean: true),
        FormFieldSpec('hourlyRate', 'Hourly rate ₹', number: true),
        FormFieldSpec('locationTypes', 'Location types comma separated'),
        FormFieldSpec('maxPerWeek', 'Max per week', number: true),
        FormFieldSpec('expertiseTags', 'Expertise tags comma separated'),
        FormFieldSpec('bio', 'Bio', multiline: true),
        FormFieldSpec(
          'publicProfileVisible',
          'Public profile visible',
          boolean: true,
        ),
      ],
      normalize: (body) {
        if (body['hourlyRate'] != null) {
          body['hourlyRate'] =
              (int.tryParse(body['hourlyRate'].toString()) ?? 0) * 100;
        }
        return _normalizeCommaFields(['locationTypes', 'expertiseTags'])(body);
      },
      onSubmit: (body) =>
          ref.read(apiClientProvider).put('/coach/profile', body),
    );
  }
}

class ActivateOneOnOneSessionScreen extends ConsumerStatefulWidget {
  const ActivateOneOnOneSessionScreen({super.key});

  @override
  ConsumerState<ActivateOneOnOneSessionScreen> createState() =>
      _ActivateOneOnOneSessionScreenState();
}

class _ActivateOneOnOneSessionScreenState
    extends ConsumerState<ActivateOneOnOneSessionScreen> {
  final _specializations = <String>{};
  final _coachLevels = <String>{};
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _experience;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    if (_specializations.isEmpty) {
      setState(() => _error = 'Select at least one coaching area.');
      return;
    }
    if (_experience == null) {
      setState(() => _error = 'Select your coaching experience.');
      return;
    }
    if (_coachLevels.isEmpty) {
      setState(() => _error = 'Select at least one coaching level.');
      return;
    }

    final setupData = <String, dynamic>{
      'specializations': _specializations.toList(),
      'coachingExperience': _experience,
      'coachLevels': _coachLevels.toList(),
      if (_emailCtrl.text.trim().isNotEmpty) 'email': _emailCtrl.text.trim(),
      if (_addressCtrl.text.trim().isNotEmpty)
        'address': _addressCtrl.text.trim(),
      'oneOnOneEnabled': true,
    };

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      try {
        await ref.read(apiClientProvider).put('/coach/profile', {
          'oneOnOneEnabled': true,
          'specializations': _specializations.toList(),
          'expertiseTags': _specializations.toList(),
          'coachingExperience': _experience,
          'coachLevels': _coachLevels.toList(),
          if (_emailCtrl.text.trim().isNotEmpty)
            'email': _emailCtrl.text.trim(),
          if (_addressCtrl.text.trim().isNotEmpty)
            'address': _addressCtrl.text.trim(),
        });
      } catch (_) {
        // TODO: Confirm the exact backend persistence keys for the 1-to-1 setup payload.
      }
      await ref.read(settingsStoreProvider).saveOneOnOneSetupData(setupData);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      setState(() => _error = _errorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activate 1-to-1 Session')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const PageHeader(
              title: 'Activate 1-to-1 Session',
              subtitle:
                  'Fast setup using simple taps. No typing required unless you want to add contact details.',
            ),
            ActivationStepCard(
              step: '1',
              title: 'What do you coach?',
              child: OptionChipWrap(
                options: _oneOnOneSpecializationOptions,
                selected: _specializations,
                multiSelect: true,
                onChanged: (next) => setState(() {
                  _specializations
                    ..clear()
                    ..addAll(next);
                }),
              ),
            ),
            ActivationStepCard(
              step: '2',
              title: 'How much coaching experience do you have?',
              child: OptionChipWrap(
                options: _experienceOptions,
                selected: {if (_experience != null) _experience!},
                multiSelect: false,
                onChanged: (next) => setState(
                  () => _experience = next.isEmpty ? null : next.first,
                ),
              ),
            ),
            ActivationStepCard(
              step: '3',
              title: 'What is your coaching level?',
              child: OptionChipWrap(
                options: _activationCoachLevelOptions,
                selected: _coachLevels,
                multiSelect: true,
                onChanged: (next) => setState(() {
                  _coachLevels
                    ..clear()
                    ..addAll(next);
                }),
              ),
            ),
            ActivationStepCard(
              step: '4',
              title: 'Optional details',
              child: Column(
                children: [
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _saving ? null : _activate,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Activate 1-to-1 Sessions'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
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
    );
  }
}

class CoachProfileScreen extends ConsumerWidget {
  const CoachProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadProfileDashboard(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ProfileSettingsSkeleton();
          }
          if (snapshot.hasError) {
            return ErrorState(
              message: _errorMessage(snapshot.error),
              onRetry: () => (context as Element).markNeedsBuild(),
            );
          }
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                const PageHeader(title: 'Profile & Settings'),
                ProfileListItem(
                  icon: Icons.person_outline_rounded,
                  title: 'View Profile',
                  onTap: () => context.push('/profile/view'),
                ),
                const Divider(height: 1),
                ProfileListItem(
                  icon: Icons.account_balance_outlined,
                  title: 'Banking',
                  onTap: () => context.push('/profile/banking'),
                ),
                const Divider(height: 1),
                ProfileListItem(
                  icon: Icons.support_agent_rounded,
                  title: 'Support',
                  onTap: () => showSupportBottomSheet(context),
                ),
                const Divider(height: 1),
                ProfileThemeListItem(
                  icon: Icons.light_mode_rounded,
                  title: 'Light Theme',
                  selected: _currentThemeMode(context) == ThemeMode.light,
                  onTap: () => _setThemeFromContext(context, ThemeMode.light),
                ),
                const Divider(height: 1),
                ProfileThemeListItem(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Theme',
                  selected: _currentThemeMode(context) == ThemeMode.dark,
                  onTap: () => _setThemeFromContext(context, ThemeMode.dark),
                ),
                const Divider(height: 1),
                ProfileListItem(
                  icon: Icons.lock_outline_rounded,
                  title: 'App Lock / Biometrics',
                  onTap: () => showAppLockSettingsSheet(context, ref),
                ),
                const Divider(height: 1),
                ProfileListItem(
                  icon: Icons.logout_rounded,
                  title: 'Sign Out',
                  onTap: () => _confirmSignOut(context, ref),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadProfileDashboard(WidgetRef ref) async {
    final data = await Future.wait([
      ref.read(apiClientProvider).get('/coach/profile'),
      ref.read(apiClientProvider).get('/biz/me'),
      ref.read(apiClientProvider).getList('/coach/batches'),
      ref.read(apiClientProvider).getList('/coach/students'),
    ]);
    final bizResponse = data[1] as Map<String, dynamic>;
    return {
      'profile': data[0],
      'biz': ((bizResponse['data'] ?? bizResponse) as Map)
          .cast<String, dynamic>(),
      'batches': data[2],
      'students': data[3],
    };
  }
}

class CoachProfileViewScreen extends ConsumerWidget {
  const CoachProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Profile')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadCoachProfileDetails(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(label: 'Loading profile');
          }
          if (snapshot.hasError) {
            return InlineError(
              message: _errorMessage(snapshot.error),
              onRetry: () => (context as Element).markNeedsBuild(),
            );
          }
          final details = snapshot.data ?? const <String, dynamic>{};
          final levels = _coachLevelLabels(details);
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                CoachDetailHero(details: details),
                const SizedBox(height: 16),
                DetailInfoCard(
                  title: 'Coach Details',
                  rows: [
                    ('Name', _safeDisplayValue(details['name'])),
                    ('Phone number', _safeDisplayValue(details['phone'])),
                    (
                      'Specialization',
                      _listDisplayValue(_profileSpecializations(details)),
                    ),
                    ('Coaching experience', _experienceLabel(details)),
                    if (_hasDisplayValue(details['email']))
                      ('Email', _safeDisplayValue(details['email'])),
                    if (_hasDisplayValue(details['address']))
                      ('Address', _safeDisplayValue(details['address'])),
                  ],
                ),
                const SizedBox(height: 14),
                DetailInfoCard(
                  title: 'Coach Level',
                  child: levels.isEmpty
                      ? Text(
                          'No coach level added yet.',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: levels
                              .map((level) => CoachLevelChip(label: level))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => context.push('/profile/edit'),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadCoachProfileDetails(WidgetRef ref) async {
    final data = await Future.wait([
      ref.read(apiClientProvider).get('/coach/profile'),
      ref.read(apiClientProvider).get('/biz/me'),
      ref.read(settingsStoreProvider).loadOneOnOneSetupData(),
    ]);
    final profile = data[0];
    final bizResponse = data[1];
    final oneOnOneSetup = (data[2] as Map).cast<String, dynamic>();
    final biz = ((bizResponse['data'] ?? bizResponse) as Map)
        .cast<String, dynamic>();
    final user = (biz['user'] as Map?)?.cast<String, dynamic>() ?? const {};
    final business =
        (biz['businessAccount'] as Map?)?.cast<String, dynamic>() ?? const {};
    return {
      ...profile,
      'name': _coachDisplayName(profile, biz),
      if (user['phone'] != null) 'phone': user['phone'],
      if (user['email'] != null) 'email': user['email'],
      'address': _read(profile, ['address']) ?? business['address'],
      ...oneOnOneSetup,
    };
  }
}

class BankingDetailsScreen extends ConsumerWidget {
  const BankingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banking')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ref.read(apiClientProvider).get('/biz/me'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(label: 'Loading banking details');
          }
          if (snapshot.hasError) {
            return InlineError(
              message: _errorMessage(snapshot.error),
              onRetry: () => (context as Element).markNeedsBuild(),
            );
          }
          final payload =
              ((snapshot.data?['data'] ?? snapshot.data ?? {}) as Map)
                  .cast<String, dynamic>();
          final account =
              (payload['businessAccount'] as Map?)?.cast<String, dynamic>() ??
              const {};
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const PageHeader(
                  title: 'Banking Details',
                  subtitle:
                      'Payout and UPI information used for coach payments.',
                ),
                DetailInfoCard(
                  title: 'Payout Account',
                  rows: [
                    ('UPI ID', _safeDisplayValue(account['upiId'])),
                    (
                      'Account holder name',
                      _safeDisplayValue(account['beneficiaryName']),
                    ),
                    ('Bank name', _safeDisplayValue(account['bankName'])),
                    (
                      'Account number',
                      _safeDisplayValue(account['accountNumber']),
                    ),
                    ('IFSC code', _safeDisplayValue(account['ifscCode'])),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'TODO: Bank name is displayed when returned by the existing business details API.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => context.push('/profile/payout'),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Banking Details'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class QuickBatchSetupScreen extends ConsumerStatefulWidget {
  const QuickBatchSetupScreen({super.key});

  @override
  ConsumerState<QuickBatchSetupScreen> createState() =>
      _QuickBatchSetupScreenState();
}

class _QuickBatchSetupScreenState extends ConsumerState<QuickBatchSetupScreen> {
  final Map<String, _BatchCardState> _states = {};
  bool _loading = true;
  bool _savingSetup = false;
  bool _showSummary = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final state in _states.values) {
      state.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final data = await Future.wait([
        api.getList('/coach/batches'),
        api.getList('/coach/schedules'),
      ]);
      final batches = (data[0] as List).cast<Map<String, dynamic>>();
      final schedules = (data[1] as List).cast<Map<String, dynamic>>();
      for (final old in _states.values) {
        old.dispose();
      }
      _states.clear();
      for (final batch in batches) {
        final batchId = _idOf(batch);
        final batchSchedules = schedules
            .where((s) => _read(s, ['batchId'])?.toString() == batchId)
            .toList();
        _states[batchId] = _BatchCardState.fromApi(
          batchId,
          batch,
          batchSchedules,
        );
      }
    } catch (e) {
      _error = _errorMessage(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _saveBatch(String batchId) async {
    final state = _states[batchId];
    if (state == null) return false;
    final api = ref.read(apiClientProvider);
    final desired = _toSchedulePayloads(batchId, state, state.rawSchedules);
    final existingByKey = <String, Map<String, dynamic>>{
      for (final s in state.rawSchedules) _scheduleKey(s): s,
    };
    final desiredKeys = desired.map(_scheduleKey).toSet();
    setState(() => state.saving = true);
    try {
      for (final payload in desired) {
        final key = _scheduleKey(payload);
        final existing = existingByKey[key];
        if (existing == null) {
          await api.post('/coach/schedules', payload);
          continue;
        }
        final scheduleId = _idOf(existing);
        await api.patch('/coach/schedules/$scheduleId', {
          'daysOfWeek': payload['daysOfWeek'],
          'sessionType': payload['sessionType'],
          'startTime': payload['startTime'],
          'durationMins': payload['durationMins'],
          'isActive': true,
        });
      }
      for (final schedule in state.rawSchedules) {
        final key = _scheduleKey(schedule);
        if (!desiredKeys.contains(key) &&
            _read(schedule, ['isActive']) != false) {
          await api.patch('/coach/schedules/${_idOf(schedule)}', {
            'isActive': false,
          });
        }
      }
      state.dirty = false;
      state.completed = _isCardCompleted(state);
      return true;
    } catch (_) {
      return false;
    } finally {
      if (mounted) setState(() => state.saving = false);
    }
  }

  Future<void> _saveAllBatchSetups() async {
    if (_savingSetup) return;
    final validationMessage = _validateBatchSetupStates(_states.values);
    if (validationMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }
    setState(() => _savingSetup = true);
    var ok = true;
    for (final entry in _states.entries) {
      entry.value.debounce?.cancel();
      if (_hasAnySelectedDay(entry.value)) {
        ok = await _saveBatch(entry.key) && ok;
      }
    }
    if (!mounted) return;
    setState(() {
      _savingSetup = false;
      _showSummary = ok;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Batch setup saved successfully.'
              : 'Unable to save batch setup. Please try again.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSave = !_savingSetup && _states.values.any(_hasAnySelectedDay);
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Batch Setup')),
      body: _loading
          ? const LoadingView(label: 'Loading batches')
          : _error != null
          ? InlineError(message: _error!, onRetry: _load)
          : _states.isEmpty
          ? const EmptyState(
              icon: Icons.groups_2_outlined,
              title: 'No active batches found',
              subtitle:
                  'Create or assign a batch first, then return here to set up its weekly sessions.',
            )
          : _showSummary
          ? _QuickBatchSetupSummaryView(
              states: _states.values.where(_hasAnySelectedDay).toList(),
              onEdit: () => setState(() => _showSummary = false),
              onConfirm: () => Navigator.maybePop(context),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
              children:
                  _states.entries.map<Widget>((entry) {
                    final state = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: BatchCard(
                        batchName: state.batchName,
                        completed: state.completed,
                        dirty: state.dirty,
                        saving: state.saving,
                        sameForAllDays: state.sameForAllDays,
                        onSameForAllChanged: (value) =>
                            setState(() => state.sameForAllDays = value),
                        schedule: state.schedule,
                        onCellTap: (sessionType, day) async {
                          setState(() {
                            final targetDays = state.sameForAllDays
                                ? _days
                                : <String>[day];
                            if (state.sameForAllDays) {
                              for (final d in _days) {
                                _toggleQuickSetupCell(
                                  state.schedule,
                                  sessionType,
                                  d,
                                );
                              }
                            } else {
                              for (final d in targetDays) {
                                _toggleQuickSetupCell(
                                  state.schedule,
                                  sessionType,
                                  d,
                                );
                              }
                            }
                            state.completed = _isCardCompleted(state);
                            state.dirty = true;
                            _error = null;
                          });
                        },
                      ),
                    );
                  }).toList()..addAll([
                    const SizedBox(height: 8),
                    SafeArea(
                      top: false,
                      child: FilledButton(
                        onPressed: canSave ? _saveAllBatchSetups : null,
                        child: _savingSetup
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Batch Setup'),
                      ),
                    ),
                  ]),
            ),
    );
  }
}

class _BatchCardState {
  _BatchCardState({
    required this.batchId,
    required this.batchName,
    required this.rawSchedules,
    required this.schedule,
    required this.completed,
  });

  final String batchId;
  final String batchName;
  final List<Map<String, dynamic>> rawSchedules;
  final Map<String, Set<String>> schedule;
  bool completed;
  bool dirty = false;
  bool saving = false;
  bool sameForAllDays = false;
  Timer? debounce;

  void dispose() => debounce?.cancel();

  factory _BatchCardState.fromApi(
    String batchId,
    Map<String, dynamic> batch,
    List<Map<String, dynamic>> schedules,
  ) {
    final map = _emptyBatchSchedule();
    for (final item in schedules) {
      if (_read(item, ['isActive']) == false) continue;
      final dayIndexes = _listAt(item, [
        'daysOfWeek',
      ]).map((e) => int.tryParse(e.toString())).whereType<int>().toList();
      final type =
          (_read(item, ['sessionType'])?.toString().toLowerCase() ?? '');
      for (final d in dayIndexes) {
        if (d < 0 || d > 6) continue;
        final day = _days[d];
        if (type == 'holiday') {
          map[day] = {'holiday'};
        } else if (_sessionRows.contains(type)) {
          map[day]!
            ..clear()
            ..add(type);
        }
      }
    }
    final state = _BatchCardState(
      batchId: batchId,
      batchName: _labelOf(batch, ['name', 'batchName']),
      rawSchedules: schedules,
      schedule: map,
      completed: false,
    );
    state.completed = _isCardCompleted(state);
    return state;
  }
}

class PayoutDetailsEditScreen extends ConsumerWidget {
  const PayoutDetailsEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicFormScreen(
      title: 'Update Bank / UPI',
      loadInitial: () async {
        final data = await Future.wait([
          ref.read(apiClientProvider).get('/biz/me'),
        ]);
        final biz = ((data.first['data'] ?? data.first) as Map)
            .cast<String, dynamic>();
        final account =
            (biz['businessAccount'] as Map?)?.cast<String, dynamic>() ??
            const {};
        return {
          'beneficiaryName': account['beneficiaryName'],
          'upiId': account['upiId'],
          'bankName': account['bankName'],
          'accountNumber': account['accountNumber'],
          'ifscCode': account['ifscCode'],
        };
      },
      fields: const [
        FormFieldSpec('beneficiaryName', 'Beneficiary name'),
        FormFieldSpec('upiId', 'UPI ID', required: true),
        FormFieldSpec('bankName', 'Bank name'),
        FormFieldSpec('accountNumber', 'Account number'),
        FormFieldSpec('ifscCode', 'IFSC code'),
      ],
      onSubmit: (body) async {
        final upiId = body['upiId']?.toString() ?? '';
        // TODO: Persist bankName when the existing business-details API supports it.
        body.remove('bankName');
        final accountNumber = body['accountNumber']?.toString() ?? '';
        final ifscCode = body['ifscCode']?.toString().toUpperCase() ?? '';
        if (!_isValidUpi(upiId)) {
          throw const ApiException('Enter a valid UPI ID');
        }
        if (accountNumber.isNotEmpty &&
            !RegExp(r'^\d{9,18}$').hasMatch(accountNumber)) {
          throw const ApiException('Enter a valid bank account number');
        }
        if (ifscCode.isNotEmpty &&
            !RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifscCode)) {
          throw const ApiException('Enter a valid IFSC code');
        }
        final biz = await ref.read(apiClientProvider).get('/biz/me');
        final payload = ((biz['data'] ?? biz) as Map).cast<String, dynamic>();
        final existing = (payload['businessAccount'] as Map?)
            ?.cast<String, dynamic>();
        await ref.read(apiClientProvider).put('/biz/business-details', {
          ..._businessDetailsPayload(existing ?? const {}),
          'upiId': upiId,
          if ((body['beneficiaryName']?.toString() ?? '').isNotEmpty)
            'beneficiaryName': body['beneficiaryName'].toString(),
          if (accountNumber.isNotEmpty) 'accountNumber': accountNumber,
          if (ifscCode.isNotEmpty) 'ifscCode': ifscCode,
        });
        return null;
      },
    );
  }
}

class ProfileActionPlaceholderScreen extends StatelessWidget {
  const ProfileActionPlaceholderScreen({required this.actionId, super.key});

  final String actionId;

  @override
  Widget build(BuildContext context) {
    if (actionId == 'add-student') {
      return const AddStudentActionScreen();
    }
    final title = _profileActionTitle(actionId);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(
        icon: Icons.add_circle_outline_rounded,
        title: '$title API required',
        subtitle:
            'The UI entry point is ready. This action needs an existing backend API before it can save changes.',
      ),
    );
  }
}

class AddStudentActionScreen extends ConsumerStatefulWidget {
  const AddStudentActionScreen({super.key});

  @override
  ConsumerState<AddStudentActionScreen> createState() =>
      _AddStudentActionScreenState();
}

class _AddStudentActionScreenState
    extends ConsumerState<AddStudentActionScreen> {
  final _queryCtrl = TextEditingController();
  bool _loading = false;
  bool _adding = false;
  List<Map<String, dynamic>> _results = const [];

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchPlayers() async {
    final query = _queryCtrl.text.trim();
    if (query.length < 2) return;
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      List<Map<String, dynamic>> items = const [];
      final tries = [
        {'phone': query, 'name': query},
        {'query': query},
        {'search': query},
      ];
      for (final params in tries) {
        try {
          items = await api.getList('/coach/players', query: params);
          if (items.isNotEmpty) break;
        } catch (_) {}
      }
      if (items.isEmpty) {
        try {
          items = await api.getList('/players', query: {'search': query});
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() => _results = items);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addStudent(Map<String, dynamic> player) async {
    final playerId = _idOf(player);
    if (playerId.isEmpty) return;
    setState(() => _adding = true);
    try {
      await ref.read(apiClientProvider).post('/coach/students', {
        'playerProfileId': playerId,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Student added')));
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          TextField(
            controller: _queryCtrl,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Player phone or name',
              hintText: 'Enter phone number or player name',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                onPressed: _loading ? null : _searchPlayers,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ),
            onSubmitted: (_) => _searchPlayers(),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _loading ? null : _searchPlayers,
            icon: _loading
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search_rounded),
            label: Text(_loading ? 'Searching...' : 'Search Player'),
          ),
          const SizedBox(height: 14),
          if (_results.isEmpty && !_loading)
            const EmptyState(
              icon: Icons.person_search_outlined,
              title: 'Search players to add',
              subtitle:
                  'Use player phone number or name to fetch results from backend.',
            ),
          ..._results.map(
            (player) => ActionRow(
              title: _studentName(player),
              subtitle:
                  '${_read(player, ['phone', 'mobile', 'phoneNumber']) ?? '-'}',
              trailing: FilledButton(
                onPressed: _adding ? null : () => _addStudent(player),
                child: const Text('Add'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditCoachProfileScreen extends ConsumerWidget {
  const EditCoachProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicFormScreen(
      title: 'Edit Profile',
      loadInitial: () async {
        final data = await Future.wait([
          ref.read(apiClientProvider).get('/coach/profile'),
          ref.read(apiClientProvider).get('/biz/me'),
        ]);
        final profile = data.first;
        final biz = ((data.last['data'] ?? data.last) as Map)
            .cast<String, dynamic>();
        return {
          ...profile,
          'upiId': (biz['businessAccount'] as Map?)?['upiId'],
          'beneficiaryName':
              (biz['businessAccount'] as Map?)?['beneficiaryName'],
        };
      },
      fields: const [
        FormFieldSpec('bio', 'Bio', multiline: true),
        FormFieldSpec('city', 'City'),
        FormFieldSpec('state', 'State'),
        FormFieldSpec('experienceYears', 'Experience years', number: true),
        FormFieldSpec('coachLevels', 'Coach levels comma separated'),
        FormFieldSpec('specializations', 'Specializations comma separated'),
        FormFieldSpec('certifications', 'Certifications comma separated'),
        FormFieldSpec(
          'publicProfileVisible',
          'Public profile visible',
          boolean: true,
        ),
        FormFieldSpec('beneficiaryName', 'Beneficiary name'),
        FormFieldSpec('upiId', 'UPI ID'),
        FormFieldSpec('accountNumber', 'Account number'),
        FormFieldSpec('ifscCode', 'IFSC code'),
      ],
      normalize: _normalizeCommaFields([
        'coachLevels',
        'specializations',
        'certifications',
      ]),
      onSubmit: (body) async {
        final profileUpdate = Map<String, dynamic>.from(body);
        final upiId = body.remove('upiId')?.toString();
        final beneficiary = body.remove('beneficiaryName')?.toString();
        final accountNumber = body.remove('accountNumber')?.toString();
        final ifscCode = body.remove('ifscCode')?.toString().toUpperCase();
        if (upiId != null && upiId.isNotEmpty && !_isValidUpi(upiId)) {
          throw const ApiException('Enter a valid UPI ID');
        }
        if (accountNumber != null &&
            accountNumber.isNotEmpty &&
            !RegExp(r'^\d{9,18}$').hasMatch(accountNumber)) {
          throw const ApiException('Enter a valid bank account number');
        }
        if (ifscCode != null &&
            ifscCode.isNotEmpty &&
            !RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifscCode)) {
          throw const ApiException('Enter a valid IFSC code');
        }
        final api = ref.read(apiClientProvider);
        final bizMe = await api.get('/biz/me');
        final bizPayload = ((bizMe['data'] ?? bizMe) as Map)
            .cast<String, dynamic>();
        final existingAccount = (bizPayload['businessAccount'] as Map?)
            ?.cast<String, dynamic>();

        profileUpdate.remove('upiId');
        profileUpdate.remove('beneficiaryName');
        profileUpdate.remove('accountNumber');
        profileUpdate.remove('ifscCode');

        final city = profileUpdate['city']?.toString();
        final state = profileUpdate['state']?.toString();
        final businessDetailsBody = {
          ..._businessDetailsPayload(existingAccount ?? const {}),
          if (city != null && city.isNotEmpty) 'city': city,
          if (state != null && state.isNotEmpty) 'state': state,
          if (upiId != null && upiId.isNotEmpty) 'upiId': upiId,
          if (beneficiary != null && beneficiary.isNotEmpty)
            'beneficiaryName': beneficiary,
          if (accountNumber != null && accountNumber.isNotEmpty)
            'accountNumber': accountNumber,
          if (ifscCode != null && ifscCode.isNotEmpty) 'ifscCode': ifscCode,
        };
        await api.put('/biz/business-details', businessDetailsBody);

        final coachPayload = <String, dynamic>{
          if (city != null && city.isNotEmpty) 'city': city,
          if (state != null && state.isNotEmpty) 'state': state,
          if (profileUpdate['bio'] != null) 'bio': profileUpdate['bio'],
          if (profileUpdate['experienceYears'] != null)
            'experienceYears': profileUpdate['experienceYears'],
          // TODO: Confirm backend persistence key for multi-select coach levels.
          if (profileUpdate['coachLevels'] != null)
            'coachLevels': profileUpdate['coachLevels'],
          if (profileUpdate['specializations'] != null)
            'specializations': profileUpdate['specializations'],
          if (profileUpdate['certifications'] != null)
            'certifications': profileUpdate['certifications'],
          if (profileUpdate['publicProfileVisible'] != null)
            'publicProfileVisible': profileUpdate['publicProfileVisible'],
        };
        try {
          await api.post('/biz/coach', coachPayload);
        } catch (_) {
          // Fallback for older backend behavior.
          try {
            await api.patch('/coach/profile', profileUpdate);
          } catch (_) {
            await api.put('/coach/profile', profileUpdate);
          }
        }
        final savedProfile = await api.get('/coach/profile');
        if (!_profileUpdatePersisted(savedProfile, profileUpdate)) {
          throw const ApiException(
            'Profile changes were not persisted. Please retry.',
          );
        }
        return null;
      },
    );
  }
}

class ReportCardsScreen extends ConsumerWidget {
  const ReportCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchListScreen(
      title: 'Report Cards',
      load: () => ref.read(apiClientProvider).getList('/coach/report-cards'),
      matches: (item, query) =>
          _studentName(item).toLowerCase().contains(query.toLowerCase()),
      itemBuilder: (context, item) => ActionRow(
        title: _studentName(item),
        subtitle:
            '${_read(item, ['periodMonth'])}/${_read(item, ['periodYear'])} · Swing ${_read(item, ['swingIndexStart'])}-${_read(item, ['swingIndexEnd'])}',
        trailing: StatusBadge(
          _read(item, ['isPublished']) == true ? 'PUBLISHED' : 'DRAFT',
        ),
        onTap: () => context.push('/report-cards/${_idOf(item)}'),
      ),
      emptyLabel: 'No report cards.',
      fab: FloatingActionButton(
        onPressed: () => context.push('/report-cards/create'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class ReportCardFormScreen extends ConsumerWidget {
  const ReportCardFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicFormScreen(
      title: 'Create Report Card',
      fields: const [
        FormFieldSpec('playerProfileId', 'Student ID', required: true),
        FormFieldSpec('periodMonth', 'Month', number: true),
        FormFieldSpec('periodYear', 'Year', number: true),
        FormFieldSpec('swingIndexStart', 'Swing index start', number: true),
        FormFieldSpec('swingIndexEnd', 'Swing index end', number: true),
        FormFieldSpec(
          'attendanceRate',
          'Attendance rate 0.0-1.0',
          number: true,
        ),
        FormFieldSpec(
          'drillCompletion',
          'Drill completion 0.0-1.0',
          number: true,
        ),
        FormFieldSpec('coachNarrative', 'Overall summary', multiline: true),
        FormFieldSpec('strengthsNote', 'Strengths', multiline: true),
        FormFieldSpec('focusAreasNote', 'Focus areas', multiline: true),
        FormFieldSpec('goalsNextMonth', 'Goals next month', multiline: true),
      ],
      onSubmit: (body) =>
          ref.read(apiClientProvider).post('/coach/report-cards', body),
    );
  }
}

class ReportCardDetailScreen extends ConsumerWidget {
  const ReportCardDetailScreen({required this.reportCardId, super.key});

  final String reportCardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DetailPage(
      title: 'Report Card',
      load: () async {
        final cards = await ref
            .read(apiClientProvider)
            .getList('/coach/report-cards');
        return cards.firstWhere(
          (e) => _idOf(e) == reportCardId,
          orElse: () => {'id': reportCardId},
        );
      },
      actionsBuilder: (item, reload) => [
        if (_read(item, ['isPublished']) != true)
          ActionChip(
            label: const Text('Publish'),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Publish report card?'),
                  content: const Text(
                    "This will send the report card to the student's parent. Continue?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Publish'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref
                    .read(apiClientProvider)
                    .post('/coach/report-cards/$reportCardId/publish', {});
                reload();
              }
            },
          ),
      ],
    );
  }
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshableListPage(
      title: 'Notifications',
      load: () => ref.read(apiClientProvider).getList('/notifications'),
      itemBuilder: (context, item) {
        final read =
            _read(item, ['readAt', 'isRead']) != null &&
            _read(item, ['isRead']) != false;
        return ActionRow(
          leading: Icon(
            read
                ? Icons.notifications_none_rounded
                : Icons.notifications_active_rounded,
            color: read ? null : const Color(0xFF087F5B),
          ),
          title: _labelOf(item, ['title', 'heading']),
          subtitle:
              '${_read(item, ['body', 'message']) ?? ''}\n${_formatDate(_read(item, ['createdAt'])?.toString())}',
          trailing: read ? null : const StatusBadge('NEW'),
          onTap: () async {
            final id = _idOf(item);
            if (id.isNotEmpty && !read) {
              await ref
                  .read(apiClientProvider)
                  .post('/notifications/$id/read', {});
            }
            final route = _read(item, [
              'route',
              'data.route',
              'deepLink',
            ])?.toString();
            if (route != null && route.startsWith('/') && context.mounted) {
              context.push(route);
            }
          },
        );
      },
      emptyLabel: 'No notifications yet.',
    );
  }
}

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      (
        'How do I mark attendance?',
        'Open a live session and use QR or manual override.',
      ),
      (
        'How do payouts work?',
        'Your saved UPI ID is used for coach payout processing.',
      ),
      (
        'Can I edit report cards?',
        'Draft report cards can be edited before publishing when the API supports updates. API required.',
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) =>
            ActionRow(title: faqs[index].$1, subtitle: faqs[index].$2),
      ),
    );
  }
}

class EmailSupportScreen extends StatelessWidget {
  const EmailSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Us')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'support@swing.app',
              subtitle:
                  'Email intent API required for direct mail composer. Use this support address for now.',
            ),
          ],
        ),
      ),
    );
  }
}

class ReportBugScreen extends StatefulWidget {
  const ReportBugScreen({super.key});

  @override
  State<ReportBugScreen> createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends State<ReportBugScreen> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty ||
        _descriptionCtrl.text.trim().isEmpty) {
      setState(() => _message = 'Title and description are required');
      return;
    }
    setState(() {
      _message =
          'Bug report API required. Your report is ready to send when the endpoint exists.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Bug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionCtrl,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          const ActionRow(
            leading: Icon(Icons.attach_file_rounded),
            title: 'Screenshot attachment',
            subtitle: 'Attachment picker API required',
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _submit, child: const Text('Submit')),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

class LiveChatScreen extends StatelessWidget {
  const LiveChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Chat')),
      body: const EmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Live chat API required',
        subtitle: 'This screen is ready for a chat backend when available.',
      ),
    );
  }
}

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    required this.coachName,
    required this.onNotificationsTap,
    required this.onProfileTap,
    super.key,
  });

  final String coachName;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greetingTitle()},',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                coachName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNotificationsTap,
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notifications',
        ),
        IconButton(
          onPressed: onProfileTap,
          icon: const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person_outline_rounded, size: 18),
          ),
          tooltip: 'Profile',
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.subtext,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;
  final String subtext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surface,
            colorScheme.primary.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 12),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(subtext),
        ],
      ),
    );
  }
}

class RevenueChartCard extends StatelessWidget {
  const RevenueChartCard({
    required this.enabled,
    required this.monthlyRevenuePaise,
    required this.series,
    super.key,
  });

  final bool enabled;
  final num monthlyRevenuePaise;
  final List<Map<String, dynamic>> series;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surface,
            colorScheme.primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Monthly Revenue',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _rupees(monthlyRevenuePaise),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Text(
            'Revenue Comparison',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (enabled)
            SizedBox(height: 132, child: RevenueBarChart(series: series))
          else
            Text(
              'Revenue chart will appear after your batches or 1-to-1 sessions start generating revenue.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

class RevenueBarChart extends StatelessWidget {
  const RevenueBarChart({required this.series, super.key});

  final List<Map<String, dynamic>> series;

  @override
  Widget build(BuildContext context) {
    final values = series.isEmpty
        ? const <num>[0, 0, 0, 0, 0, 0]
        : series.map((item) => item['amountPaise'] as num? ?? 0).toList();
    final maxValue = values.fold<num>(
      0,
      (max, value) => value > max ? value : max,
    );
    final items = series.isEmpty ? _fallbackRevenueSeries() : series;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: items.map((item) {
        final amount = item['amountPaise'] as num? ?? 0;
        final heightFactor = maxValue <= 0
            ? 0.12
            : (amount / maxValue).clamp(0.12, 1.0);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: heightFactor.toDouble(),
                      widthFactor: 0.72,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['label']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class RevenueBreakdownPill extends StatelessWidget {
  const RevenueBreakdownPill({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class HomeDashboardSkeleton extends StatelessWidget {
  const HomeDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final shade = Theme.of(context).colorScheme.surfaceContainerHighest;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(height: 72, color: shade),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Container(height: 120, color: shade)),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 120, color: shade)),
            ],
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < 4; i++) ...[
            Container(height: 52, color: shade),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class ProfileListItem extends StatelessWidget {
  const ProfileListItem({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: 52,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class ProfileThemeListItem extends StatelessWidget {
  const ProfileThemeListItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: 52,
      leading: Icon(icon, color: selected ? colorScheme.primary : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: selected ? colorScheme.primary : null,
        ),
      ),
      trailing: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: selected
            ? const Icon(Icons.check_circle_rounded, key: ValueKey('selected'))
            : const SizedBox(width: 24, key: ValueKey('empty')),
      ),
      selected: selected,
      selectedTileColor: colorScheme.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: onTap,
    );
  }
}

class CoachDetailHero extends StatelessWidget {
  const CoachDetailHero({required this.details, super.key});

  final Map<String, dynamic> details;

  @override
  Widget build(BuildContext context) {
    final name = _safeDisplayValue(details['name'], fallback: 'Coach');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Text(
              _avatarLetter(name),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _safeDisplayValue(
                    details['email'] ?? details['phone'],
                    fallback: 'Coach profile',
                  ),
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivationStepCard extends StatelessWidget {
  const ActivationStepCard({
    required this.step,
    required this.title,
    required this.child,
    super.key,
  });

  final String step;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                child: Text(
                  step,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class OptionChipWrap extends StatelessWidget {
  const OptionChipWrap({
    required this.options,
    required this.selected,
    required this.multiSelect,
    required this.onChanged,
    super.key,
  });

  final List<String> options;
  final Set<String> selected;
  final bool multiSelect;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          showCheckmark: true,
          onSelected: (_) {
            final next = <String>{};
            if (multiSelect) next.addAll(selected);
            if (isSelected) {
              next.remove(option);
            } else {
              if (!multiSelect) next.clear();
              next.add(option);
            }
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}

class DetailInfoCard extends StatelessWidget {
  const DetailInfoCard({
    required this.title,
    this.rows = const [],
    this.child,
    super.key,
  });

  final String title;
  final List<(String, String)> rows;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (child != null)
            child!
          else
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 122,
                      child: Text(
                        row.$1,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row.$2,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CoachLevelChip extends StatelessWidget {
  const CoachLevelChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      avatar: const Icon(Icons.verified_outlined, size: 17),
      labelStyle: const TextStyle(fontWeight: FontWeight.w800),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}

class ProfileSettingsSkeleton extends StatelessWidget {
  const ProfileSettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final shade = Theme.of(context).colorScheme.surfaceContainerHighest;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(height: 56, color: shade),
          const SizedBox(height: 16),
          for (var i = 0; i < 5; i++) ...[
            Container(height: 52, color: shade),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _QuickBatchSetupSummaryView extends StatelessWidget {
  const _QuickBatchSetupSummaryView({
    required this.states,
    required this.onEdit,
    required this.onConfirm,
  });

  final List<_BatchCardState> states;
  final VoidCallback onEdit;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const PageHeader(
          title: 'Your weekly batch setup is saved',
          subtitle:
              'Review the weekly plan below. You can edit it before moving to the next workflow.',
        ),
        ...states.map(
          (state) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: DetailInfoCard(
              title: state.batchName,
              rows: _batchSetupSummaryRows(state),
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit Setup'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: onConfirm,
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Confirm Setup'),
        ),
      ],
    );
  }
}

class BatchCard extends StatelessWidget {
  const BatchCard({
    required this.batchName,
    required this.completed,
    required this.dirty,
    required this.saving,
    required this.sameForAllDays,
    required this.onSameForAllChanged,
    required this.schedule,
    required this.onCellTap,
    super.key,
  });

  final String batchName;
  final bool completed;
  final bool dirty;
  final bool saving;
  final bool sameForAllDays;
  final ValueChanged<bool> onSameForAllChanged;
  final Map<String, Set<String>> schedule;
  final Future<void> Function(String sessionType, String day) onCellTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  batchName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              StatusBadge(completed ? 'COMPLETED' : 'INCOMPLETE'),
              if (saving)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              if (!saving && dirty)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.circle, size: 8),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ToggleSwitch(
            value: sameForAllDays,
            label: 'Same for all days',
            onChanged: onSameForAllChanged,
          ),
          const SizedBox(height: 10),
          ScheduleGrid(schedule: schedule, onCellTap: onCellTap),
        ],
      ),
    );
  }
}

class ScheduleGrid extends StatelessWidget {
  const ScheduleGrid({
    required this.schedule,
    required this.onCellTap,
    super.key,
  });

  final Map<String, Set<String>> schedule;
  final Future<void> Function(String sessionType, String day) onCellTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 86),
              ..._days.map(
                (day) => SizedBox(
                  width: 54,
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._quickSetupRows.map(
            (sessionType) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 86,
                    child: Text(
                      _titleCase(sessionType),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  ..._days.map((day) {
                    final selections = schedule[day] ?? <String>{};
                    final holidaySelected = selections.contains('holiday');
                    final selected = selections.contains(sessionType);
                    final disabled =
                        holidaySelected && sessionType != 'holiday';
                    return SizedBox(
                      width: 54,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: QuickSetupCell(
                          selected: selected,
                          disabled: disabled,
                          isHoliday: sessionType == 'holiday',
                          onTap: () => onCellTap(sessionType, day),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickSetupCell extends StatelessWidget {
  const QuickSetupCell({
    required this.selected,
    required this.disabled,
    required this.isHoliday,
    required this.onTap,
    super.key,
  });

  final bool selected;
  final bool disabled;
  final bool isHoliday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = disabled
        ? colorScheme.surfaceContainerHighest
        : selected
        ? (isHoliday ? const Color(0xFFFFE2C6) : colorScheme.primary)
        : colorScheme.surface;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 42,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.8),
          ),
        ),
        child: Center(
          child: selected
              ? Icon(
                  isHoliday ? Icons.beach_access_rounded : Icons.check_rounded,
                  size: 18,
                  color: isHoliday ? Colors.black87 : colorScheme.onPrimary,
                )
              : disabled
              ? Icon(
                  Icons.block_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class GridCell extends StatelessWidget {
  const GridCell({
    required this.value,
    required this.disabled,
    required this.onTap,
    super.key,
  });

  final String? value;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = value != null;
    final bg = disabled
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : active
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surface;
    final label = value == null
        ? ''
        : value == 'holiday'
        ? 'Holiday'
        : _displayCompactRange(value!);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: disabled ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            height: 46,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ToggleSwitch extends StatelessWidget {
  const ToggleSwitch({
    required this.value,
    required this.label,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}

class TimePickerModal extends StatefulWidget {
  const TimePickerModal({super.key});

  @override
  State<TimePickerModal> createState() => _TimePickerModalState();
}

class _TimePickerModalState extends State<TimePickerModal> {
  TimeOfDay? _start;
  TimeOfDay? _end;

  Future<void> _pickStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _start ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          _end ??
          (_start ?? TimeOfDay.now()).replacing(
            hour: ((_start ?? TimeOfDay.now()).hour + 1) % 24,
          ),
    );
    if (picked != null && mounted) setState(() => _end = picked);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(title: 'Select Time'),
            OutlinedButton(
              onPressed: _pickStart,
              child: Text(
                _start == null
                    ? 'Start Time'
                    : 'Start: ${_start!.format(context)}',
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _pickEnd,
              child: Text(
                _end == null ? 'End Time' : 'End: ${_end!.format(context)}',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _start == null || _end == null
                  ? null
                  : () {
                      final s =
                          '${_start!.hour.toString().padLeft(2, '0')}:${_start!.minute.toString().padLeft(2, '0')}';
                      final e =
                          '${_end!.hour.toString().padLeft(2, '0')}:${_end!.minute.toString().padLeft(2, '0')}';
                      Navigator.pop(context, '$s-$e');
                    },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

class UpcomingSessionsCard extends StatelessWidget {
  const UpcomingSessionsCard({required this.items, super.key});

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Upcoming Sessions",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text('No upcoming session today.')
          else
            ...items
                .take(3)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final sessionId = _idOf(item);
                        if (sessionId.isNotEmpty && sessionId != '-') {
                          context.push('/sessions/$sessionId');
                        } else {
                          context.push('/sessions/start');
                        }
                      },
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.play_circle_outline_rounded),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${item['batch']} - ${item['type']} - ${item['time']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
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

class ProfileGreetingBar extends StatelessWidget {
  const ProfileGreetingBar({
    required this.coachName,
    required this.onAdd,
    super.key,
  });

  final String coachName;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF111111), Color(0xFF2B2B2B)]
              : const [Color(0xFF101010), Color(0xFF3C3A34)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greetingTitle(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  coachName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ready to improve your players today?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            tooltip: 'Add',
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    required this.name,
    required this.role,
    this.phone,
    this.email,
    super.key,
  });

  final String name;
  final String role;
  final String? phone;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            child: Text(
              name.isEmpty ? 'C' : name[0].toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(role),
                if (phone != null && phone!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(phone!),
                ],
                if (email != null && email!.isNotEmpty) Text(email!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMetric extends StatelessWidget {
  const ProfileMetric({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

void showProfileAddSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        children: [
          const PageHeader(
            title: '+ Add',
            subtitle: 'Centralized coach actions',
          ),
          SectionTitle('Core Actions'),
          ProfileActionTile(
            icon: Icons.apartment_rounded,
            label: 'Add Academy',
            route: '/profile/action/add-academy',
          ),
          ProfileActionTile(
            icon: Icons.groups_2_outlined,
            label: 'Add Batch',
            route: '/profile/action/add-batch',
          ),
          ProfileActionTile(
            icon: Icons.person_add_alt_1_outlined,
            label: 'Add Student',
            route: '/profile/action/add-student',
          ),
          ProfileActionTile(
            icon: Icons.sports_cricket_outlined,
            label: 'Start Session',
            route: '/sessions/start',
          ),
          ProfileActionTile(
            icon: Icons.event_available_outlined,
            label: 'Add Availability',
            route: '/one-on-one',
          ),
          SectionTitle('Secondary'),
          ProfileActionTile(
            icon: Icons.edit_outlined,
            label: 'Edit Profile',
            route: '/profile/edit',
          ),
          ProfileActionTile(
            icon: Icons.account_balance_outlined,
            label: 'Update Bank / UPI',
            route: '/profile/payout',
          ),
          ProfileActionTile(
            icon: Icons.folder_outlined,
            label: 'Manage Documents',
            route: '/profile/action/manage-documents',
          ),
          SectionTitle('Danger Zone'),
          ProfileActionTile(
            icon: Icons.remove_circle_outline_rounded,
            label: 'Remove Academy',
            route: '/profile/action/remove-academy',
            danger: true,
          ),
          ProfileActionTile(
            icon: Icons.exit_to_app_rounded,
            label: 'Leave Batch',
            route: '/profile/action/leave-batch',
            danger: true,
          ),
        ],
      ),
    ),
  );
}

class ProfileActionTile extends StatelessWidget {
  const ProfileActionTile({
    required this.icon,
    required this.label,
    required this.route,
    this.danger = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final String route;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFC62828) : null;
    return ActionRow(
      leading: Icon(icon, color: color),
      title: label,
      trailing: Icon(Icons.chevron_right_rounded, color: color),
      onTap: () {
        Navigator.pop(context);
        context.push(route);
      },
    );
  }
}

Future<void> showCoachProfileDrawer(
  BuildContext context,
  WidgetRef ref,
  Map<String, dynamic> summary,
) {
  final selectedTheme = _currentThemeMode(context);
  final changeTheme = _themeSetterFromContext(context);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close profile drawer',
    barrierColor: Colors.black.withValues(alpha: 0.28),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: CoachProfileSideDrawer(
          summary: summary,
          ref: ref,
          selectedTheme: selectedTheme,
          onThemeChanged: changeTheme,
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}

class CoachProfileSideDrawer extends StatelessWidget {
  const CoachProfileSideDrawer({
    required this.summary,
    required this.ref,
    required this.selectedTheme,
    required this.onThemeChanged,
    super.key,
  });

  final Map<String, dynamic> summary;
  final WidgetRef ref;
  final ThemeMode selectedTheme;
  final ValueChanged<ThemeMode>? onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width < 420 ? size.width * 0.86 : 360.0;
    final name = _safeDisplayValue(summary['name'], fallback: 'Coach');
    final contact = _safeDisplayValue(
      summary['email'] ?? summary['phone'],
      fallback: 'Profile details',
    );
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(28)),
      child: SizedBox(
        width: width,
        height: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ),
                const SizedBox(height: 8),
                CircleAvatar(
                  radius: 42,
                  child: Text(
                    _avatarLetter(name),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  contact,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),
                ProfileDrawerTile(
                  icon: Icons.person_outline_rounded,
                  label: 'View Profile',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile/view');
                  },
                ),
                ProfileDrawerTile(
                  icon: Icons.account_balance_outlined,
                  label: 'Banking',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile/banking');
                  },
                ),
                ProfileDrawerTile(
                  icon: Icons.light_mode_rounded,
                  label: 'Light Theme',
                  selected: selectedTheme == ThemeMode.light,
                  onTap: () => onThemeChanged?.call(ThemeMode.light),
                ),
                ProfileDrawerTile(
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark Theme',
                  selected: selectedTheme == ThemeMode.dark,
                  onTap: () => onThemeChanged?.call(ThemeMode.dark),
                ),
                ProfileDrawerTile(
                  icon: Icons.support_agent_rounded,
                  label: 'Support',
                  onTap: () {
                    Navigator.pop(context);
                    showSupportBottomSheet(context);
                  },
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _confirmSignOut(context, ref);
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileDrawerTile extends StatelessWidget {
  const ProfileDrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.10)
                : Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? Theme.of(context).colorScheme.primary : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({
    required this.onThemeToggle,
    required this.onThemeModeChanged,
    required this.onLogout,
    super.key,
  });

  final VoidCallback onThemeToggle;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Profile',
      icon: const CircleAvatar(
        radius: 16,
        child: Icon(Icons.person_outline_rounded, size: 18),
      ),
      onSelected: (value) {
        switch (value) {
          case 'profile':
            context.push('/profile');
            break;
          case 'support':
            showSupportBottomSheet(context);
            break;
          case 'light':
            onThemeModeChanged(ThemeMode.light);
            break;
          case 'dark':
            onThemeModeChanged(ThemeMode.dark);
            break;
          case 'logout':
            onLogout();
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'profile', child: Text('View Profile')),
        PopupMenuItem(value: 'support', child: Text('Support')),
        PopupMenuItem(value: 'light', child: Text('Light Theme')),
        PopupMenuItem(value: 'dark', child: Text('Dark Theme')),
        PopupMenuItem(value: 'logout', child: Text('Sign Out')),
      ],
    );
  }
}

void showSupportBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        children: [
          const PageHeader(title: 'Support'),
          ActionRow(
            leading: const Icon(Icons.help_outline_rounded),
            title: 'Help Center',
            onTap: () {
              Navigator.pop(context);
              context.push('/support/help-center');
            },
          ),
          ActionRow(
            leading: const Icon(Icons.email_outlined),
            title: 'Email Us',
            onTap: () {
              Navigator.pop(context);
              context.push('/support/email');
            },
          ),
          ActionRow(
            leading: const Icon(Icons.bug_report_outlined),
            title: 'Report Bug',
            onTap: () {
              Navigator.pop(context);
              context.push('/support/report-bug');
            },
          ),
          ActionRow(
            leading: const Icon(Icons.chat_outlined),
            title: 'Live Chat',
            onTap: () {
              Navigator.pop(context);
              context.push('/support/live-chat');
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sign out?'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Sign Out'),
        ),
      ],
    ),
  );
  if (ok != true) return;
  try {
    await ref.read(apiClientProvider).post('/auth/logout', {});
  } catch (_) {}
  ref.read(sessionStateProvider.notifier).state = null;
}

Future<void> showAppLockSettingsSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => AppLockSettingsSheet(ref: ref),
  );
}

class AppLockSettingsSheet extends StatefulWidget {
  const AppLockSettingsSheet({required this.ref, super.key});

  final WidgetRef ref;

  @override
  State<AppLockSettingsSheet> createState() => _AppLockSettingsSheetState();
}

class _AppLockSettingsSheetState extends State<AppLockSettingsSheet> {
  final _localAuth = LocalAuthentication();
  final _pinCtrl = TextEditingController();
  bool _loading = true;
  bool _enabled = false;
  bool _biometricAvailable = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final store = widget.ref.read(settingsStoreProvider);
    var available = false;
    try {
      available =
          await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (_) {
      available = false;
    }
    final enabled = await store.isAppLockEnabled();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _biometricAvailable = available;
      _loading = false;
    });
  }

  Future<void> _enable() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable app lock?'),
        content: const Text(
          'Swing Coach will require biometric or PIN unlock on next app open.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
    if (confirm != true) {
      setState(() => _message = 'App lock setup cancelled');
      return;
    }
    if (_pinCtrl.text.trim().length < 4) {
      setState(() => _message = 'Set a 4-6 digit fallback PIN');
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      var biometric = false;
      if (_biometricAvailable) {
        biometric = await _localAuth.authenticate(
          localizedReason: 'Confirm biometric unlock for Swing Coach',
          options: const AuthenticationOptions(biometricOnly: true),
        );
      }
      await widget.ref
          .read(settingsStoreProvider)
          .enableAppLock(biometric: biometric, pin: _pinCtrl.text.trim());
      setState(() {
        _enabled = true;
        _message = biometric
            ? 'Biometric app lock enabled'
            : 'PIN app lock enabled. Biometric unavailable or cancelled.';
      });
    } catch (e) {
      setState(
        () => _message = 'Could not enable app lock: ${_errorMessage(e)}',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _disable() async {
    await widget.ref.read(settingsStoreProvider).disableAppLock();
    setState(() {
      _enabled = false;
      _message = 'App lock disabled';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          18 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _loading
            ? const LoadingView(label: 'Checking app lock')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PageHeader(
                    title: 'App Lock',
                    subtitle: 'Use biometrics with device PIN fallback.',
                  ),
                  AppLockToggle(
                    enabled: _enabled,
                    onChanged: (enabled) => enabled ? _enable() : _disable(),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _pinCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Fallback PIN',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _biometricAvailable
                        ? 'Biometric is available on this device.'
                        : 'Biometric unavailable. Device PIN fallback will be used.',
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Text(_message!, textAlign: TextAlign.center),
                  ],
                ],
              ),
      ),
    );
  }
}

class AppLockToggle extends StatelessWidget {
  const AppLockToggle({
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Enable App Lock'),
      subtitle: const Text('Require biometric or PIN when app opens.'),
      value: enabled,
      onChanged: onChanged,
    );
  }
}

class CoachApiClient {
  CoachApiClient({required this.readSession, required this.writeSession});

  static const backendBaseUrl =
      'https://swing-backend-1007730655118.asia-south1.run.app';

  final AuthSession? Function() readSession;
  final ValueChanged<AuthSession?> writeSession;
  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 30);

  Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, String>? query,
  }) async {
    final data = await get(path, query: query);
    final source = data['data'] ?? data['items'] ?? data['results'] ?? data;
    if (source is List) {
      return source
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    if (source is Map) {
      for (final key in [
        'items',
        'sessions',
        'students',
        'batches',
        'drills',
        'schedules',
        'reportCards',
        'bookings',
        'notifications',
      ]) {
        final value = source[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList();
        }
      }
    }
    return const [];
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) {
    return _request('GET', path, query: query);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) {
    return _request('POST', path, body: body);
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) {
    return _request('PATCH', path, body: body);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) {
    return _request('PUT', path, body: body);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
    bool retried = false,
  }) async {
    final session = readSession();
    if (!_hasUsableAccessToken(session)) {
      writeSession(null);
      throw const AuthException('SESSION_EXPIRED');
    }
    final activeSession = session!;
    final uri = Uri.parse(
      '$backendBaseUrl$path',
    ).replace(queryParameters: query);
    final request = await _client.openUrl(method, uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(
      HttpHeaders.authorizationHeader,
      'Bearer ${activeSession.accessToken}',
    );
    if (body != null) {
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(jsonEncode(body));
    }
    final response = await request.close();
    final raw = await utf8.decoder.bind(response).join();
    final decoded = raw.isEmpty ? <String, dynamic>{} : jsonDecode(raw);
    final data = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'data': decoded};

    if (response.statusCode == 401 && !retried) {
      final refreshed = await _refresh(activeSession);
      if (refreshed != null) {
        writeSession(refreshed);
        return _request(method, path, query: query, body: body, retried: true);
      }
      writeSession(null);
      throw const AuthException('SESSION_EXPIRED');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) return data;
    throw ApiException(data['message']?.toString() ?? 'Request failed');
  }

  Future<AuthSession?> _refresh(AuthSession session) async {
    return CoachAuthService().refreshAuthSession(session);
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

typedef ItemLoader = Future<List<Map<String, dynamic>>> Function();
typedef ItemWidgetBuilder = Widget Function(BuildContext, Map<String, dynamic>);

class RefreshableListPage extends StatefulWidget {
  const RefreshableListPage({
    required this.title,
    required this.load,
    required this.itemBuilder,
    required this.emptyLabel,
    this.subtitle,
    this.actions = const [],
    this.fab,
    super.key,
  });

  final String title;
  final String? subtitle;
  final ItemLoader load;
  final ItemWidgetBuilder itemBuilder;
  final String emptyLabel;
  final List<Widget> actions;
  final Widget? fab;

  @override
  State<RefreshableListPage> createState() => _RefreshableListPageState();
}

class _RefreshableListPageState extends State<RefreshableListPage> {
  late Future<List<Map<String, dynamic>>> _future = widget.load();

  Future<void> _reload() async {
    setState(() => _future = widget.load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.fab,
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <Map<String, dynamic>>[];
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: items.isEmpty
                  ? 2 + widget.actions.length
                  : 1 + widget.actions.length + items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return PageHeader(
                    title: widget.title,
                    subtitle: widget.subtitle,
                  );
                }
                final actionIndex = index - 1;
                if (actionIndex < widget.actions.length) {
                  return widget.actions[actionIndex];
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  if (snapshot.error is AuthException) {
                    return const SessionRedirectView();
                  }
                  return InlineError(
                    message: _errorMessage(snapshot.error),
                    onRetry: _reload,
                  );
                }
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(widget.emptyLabel),
                  );
                }
                return widget.itemBuilder(
                  context,
                  items[index - 1 - widget.actions.length],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class FilteredListScreen extends StatefulWidget {
  const FilteredListScreen({
    required this.title,
    required this.tabs,
    required this.load,
    required this.filter,
    required this.itemBuilder,
    this.fab,
    super.key,
  });

  final String title;
  final List<String> tabs;
  final Future<List<Map<String, dynamic>>> Function(String tab) load;
  final bool Function(Map<String, dynamic> item, String tab, String query)
  filter;
  final ItemWidgetBuilder itemBuilder;
  final Widget? fab;

  @override
  State<FilteredListScreen> createState() => _FilteredListScreenState();
}

class _FilteredListScreenState extends State<FilteredListScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final selectedTab = widget.tabs[_tab];
    return DefaultTabController(
      length: widget.tabs.length,
      initialIndex: _tab,
      child: Scaffold(
        floatingActionButton: widget.fab,
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            isScrollable: true,
            onTap: (value) => setState(() => _tab = value),
            tabs: widget.tabs.map((e) => Tab(text: e)).toList(),
          ),
        ),
        body: RefreshableListPage(
          title: selectedTab,
          load: () async {
            final items = await widget.load(selectedTab);
            return items
                .where((item) => widget.filter(item, selectedTab, ''))
                .toList();
          },
          itemBuilder: widget.itemBuilder,
          emptyLabel: 'No ${selectedTab.toLowerCase()} items.',
        ),
      ),
    );
  }
}

class SearchListScreen extends StatefulWidget {
  const SearchListScreen({
    required this.title,
    required this.load,
    required this.matches,
    required this.itemBuilder,
    required this.emptyLabel,
    this.fab,
    super.key,
  });

  final String title;
  final ItemLoader load;
  final bool Function(Map<String, dynamic>, String) matches;
  final ItemWidgetBuilder itemBuilder;
  final String emptyLabel;
  final Widget? fab;

  @override
  State<SearchListScreen> createState() => _SearchListScreenState();
}

class _SearchListScreenState extends State<SearchListScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshableListPage(
      title: widget.title,
      load: () async {
        final items = await widget.load();
        final query = _query.text.trim();
        return query.isEmpty
            ? items
            : items.where((item) => widget.matches(item, query)).toList();
      },
      itemBuilder: widget.itemBuilder,
      emptyLabel: widget.emptyLabel,
      fab: widget.fab,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextField(
            controller: _query,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              labelText: 'Search',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }
}

class DetailPage extends StatefulWidget {
  const DetailPage({
    required this.title,
    required this.load,
    this.actionsBuilder,
    this.extraBuilder,
    super.key,
  });

  final String title;
  final Future<Map<String, dynamic>> Function() load;
  final List<Widget> Function(Map<String, dynamic>, VoidCallback)?
  actionsBuilder;
  final Widget Function(BuildContext, Map<String, dynamic>, VoidCallback)?
  extraBuilder;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Map<String, dynamic>> _future = widget.load();

  void _reload() => setState(() => _future = widget.load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            if (snapshot.error is AuthException) {
              return const SessionRedirectView();
            }
            return InlineError(
              message: _errorMessage(snapshot.error),
              onRetry: _reload,
            );
          }
          final item = snapshot.data ?? const <String, dynamic>{};
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              PageHeader(
                title: _labelOf(item, [
                  'name',
                  'sessionType',
                  'title',
                  'studentName',
                ]),
                subtitle: _statusOf(item),
              ),
              if (widget.actionsBuilder != null)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.actionsBuilder!(item, _reload),
                ),
              const SizedBox(height: 8),
              ..._detailRows(item),
              if (widget.extraBuilder != null)
                widget.extraBuilder!(context, item, _reload),
            ],
          );
        },
      ),
    );
  }
}

class DynamicFormScreen extends StatefulWidget {
  const DynamicFormScreen({
    required this.title,
    required this.fields,
    required this.onSubmit,
    this.loadInitial,
    this.normalize,
    this.footer,
    super.key,
  });

  final String title;
  final List<FormFieldSpec> fields;
  final Future<Map<String, dynamic>> Function()? loadInitial;
  final Map<String, dynamic> Function(Map<String, dynamic>)? normalize;
  final Future<Object?> Function(Map<String, dynamic>) onSubmit;
  final Widget? footer;

  @override
  State<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _bools = {};
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      _controllers[field.key] = TextEditingController(text: field.initial);
      if (field.boolean) _bools[field.key] = field.initial == 'true';
    }
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    if (widget.loadInitial == null) return;
    try {
      final data = await widget.loadInitial!();
      for (final field in widget.fields) {
        final value = data[field.key];
        if (value == null) continue;
        if (field.boolean) {
          _bools[field.key] = value == true;
        } else if (field.key == 'hourlyRate' && value is num) {
          _controllers[field.key]?.text = (value / 100).round().toString();
        } else if (value is List) {
          _controllers[field.key]?.text = value.join(', ');
        } else {
          _controllers[field.key]?.text = value.toString();
        }
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    var body = <String, dynamic>{};
    for (final field in widget.fields) {
      if (field.boolean) {
        body[field.key] = _bools[field.key] ?? false;
        continue;
      }
      final raw = _controllers[field.key]!.text.trim();
      if (raw.isEmpty) continue;
      body[field.key] = field.number ? (num.tryParse(raw) ?? raw) : raw;
    }
    body = widget.normalize?.call(body) ?? body;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onSubmit(body);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved')));
      if (Navigator.canPop(context)) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = _errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              for (final field in widget.fields) ...[
                if (field.boolean)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(field.label),
                    value: _bools[field.key] ?? false,
                    onChanged: (value) =>
                        setState(() => _bools[field.key] = value),
                  )
                else if (field.options != null)
                  DropdownButtonFormField<String>(
                    initialValue:
                        field.options!.contains(_controllers[field.key]!.text)
                        ? _controllers[field.key]!.text
                        : null,
                    decoration: InputDecoration(labelText: field.label),
                    items: field.options!
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) =>
                        _controllers[field.key]!.text = value ?? '',
                    validator: field.required
                        ? (v) => v == null || v.isEmpty ? 'Required' : null
                        : null,
                  )
                else
                  TextFormField(
                    controller: _controllers[field.key],
                    maxLines: field.multiline ? 4 : 1,
                    keyboardType: field.number
                        ? TextInputType.number
                        : TextInputType.text,
                    decoration: InputDecoration(labelText: field.label),
                    validator: field.required
                        ? (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null
                        : null,
                  ),
                const SizedBox(height: 12),
              ],
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFC62828),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              if (widget.footer != null) ...[
                const Divider(height: 32),
                widget.footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FormFieldSpec {
  const FormFieldSpec(
    this.key,
    this.label, {
    this.options,
    this.number = false,
    this.multiline = false,
    this.boolean = false,
    this.required = false,
    this.initial = '',
  });

  final String key;
  final String label;
  final List<String>? options;
  final bool number;
  final bool multiline;
  final bool boolean;
  final bool required;
  final String initial;
}

class PageHeader extends StatelessWidget {
  const PageHeader({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.66),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ActionRow extends StatelessWidget {
  const ActionRow({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 14,
      leading: leading,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: subtitle == null || subtitle!.isEmpty ? null : Text(subtitle!),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class SessionRow extends StatelessWidget {
  const SessionRow({required this.item, required this.onTap, super.key});

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _statusOf(item);
    final live = status == 'LIVE';
    final color = live
        ? const Color(0xFF087F5B)
        : Theme.of(context).colorScheme.onSurface;
    return ActionRow(
      title: _labelOf(item, ['sessionTypeName', 'sessionType', 'type']),
      subtitle:
          '${_formatDate(_read(item, ['scheduledAt', 'date'])?.toString())} · ${_labelOf(item, ['batchName', 'batch.name'])} · ${_labelOf(item, ['academyName', 'academy.name'])}',
      trailing: live ? const Text('Open Attendance') : StatusBadge(status),
      leading: Icon(Icons.event_available_rounded, color: color),
      onTap: onTap,
    );
  }
}

class QuickAction extends StatelessWidget {
  const QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionRow(
      leading: Icon(icon),
      title: label,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: _statusColor(label),
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class SignalBadge extends StatelessWidget {
  const SignalBadge(this.label, {super.key});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return StatusBadge(label ?? 'ON_TRACK');
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class InlineError extends StatelessWidget {
  const InlineError({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFFC62828),
              fontWeight: FontWeight.w800,
            ),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class SessionRedirectView extends StatelessWidget {
  const SessionRedirectView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({this.label = 'Loading', super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 44),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showFeedbackSheet(
  BuildContext context,
  WidgetRef ref, {
  String? playerProfileId,
  String? sessionId,
  String sessionType = 'drills',
  Map<String, dynamic>? sessionItem,
}) {
  final roster = sessionItem == null
      ? <Map<String, dynamic>>[]
      : _listAt(sessionItem, ['attendance', 'students']);
  final players = <FeedbackPlayer>[
    ...roster.map(
      (student) => FeedbackPlayer(
        playerId: _idOf(student),
        playerName: _studentName(student),
      ),
    ),
  ];
  if (players.isEmpty && playerProfileId != null) {
    final fallbackSession = sessionItem ?? const <String, dynamic>{};
    players.add(
      FeedbackPlayer(
        playerId: playerProfileId,
        playerName:
            _read(fallbackSession, ['name', 'playerName'])?.toString() ??
            'Player',
      ),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.86,
        child: FeedbackForm(
          sessionType: sessionType,
          players: players,
          draftKey: '${sessionId ?? 'standalone'}|$sessionType',
          onSkip: () async {},
          onSubmit: (playerRows) async {
            final auth = ref.read(sessionStateProvider);
            final payload = SessionFeedbackPayload(
              sessionId: sessionId ?? '',
              sessionType: sessionType,
              coachId: auth?.phone ?? auth?.userName ?? 'unknown_coach',
              players: playerRows,
            );
            await submitFeedback(
              payload,
              apiSubmit: (data) =>
                  ref.read(apiClientProvider).post('/feedback', data),
            );
          },
        ),
      ),
    ),
  );
}

Future<void> showAttendanceSheet(
  BuildContext context,
  WidgetRef ref,
  String sessionId,
  Map<String, dynamic> student,
  VoidCallback reload,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: DynamicFormScreen(
          title: _studentName(student),
          fields: [
            FormFieldSpec(
              'playerProfileId',
              'Student ID',
              initial: _idOf(student),
              required: true,
            ),
            const FormFieldSpec(
              'status',
              'Status',
              options: [
                'PRESENT',
                'LATE',
                'ABSENT',
                'EXCUSED',
                'WALK_IN',
                'EARLY_EXIT',
              ],
            ),
            const FormFieldSpec('notes', 'Notes', multiline: true),
          ],
          onSubmit: (body) async {
            await ref
                .read(apiClientProvider)
                .post('/coach/sessions/$sessionId/attendance', body);
            reload();
            return null;
          },
        ),
      ),
    ),
  );
}

Future<void> showGenerateSessionsSheet(
  BuildContext context,
  WidgetRef ref,
  String scheduleId,
) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DynamicFormScreen(
        title: 'Generate Sessions',
        fields: const [
          FormFieldSpec(
            'weeksAhead',
            'Weeks ahead',
            number: true,
            initial: '2',
          ),
        ],
        onSubmit: (body) async {
          final result = await ref
              .read(apiClientProvider)
              .post('/coach/schedules/$scheduleId/generate', body);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Created ${_read(result, ['count', 'createdCount']) ?? 'sessions'}',
                ),
              ),
            );
          }
          return result;
        },
      ),
    ),
  );
}

const sessionTypes = [
  'PACE_NETS',
  'SPIN_NETS',
  'THROWDOWN',
  'POWER_HITTING',
  'FITNESS',
  'FIELDING',
  'MATCH_PRACTICE',
  'VIDEO_REVIEW',
  'CUSTOM',
];

Map<String, dynamic> Function(Map<String, dynamic>) _normalizeCommaFields(
  List<String> keys,
) {
  return (body) {
    for (final key in keys) {
      final value = body[key];
      if (value is String) {
        body[key] = value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
    return body;
  };
}

Map<String, dynamic> _businessDetailsPayload(Map<String, dynamic> existing) {
  String? value(String key) {
    final raw = existing[key]?.toString().trim();
    return raw == null || raw.isEmpty ? null : raw;
  }

  final businessName =
      value('businessName') ??
      value('contactName') ??
      value('name') ??
      'Swing Coach';
  return {
    'businessName': businessName,
    'contactName': value('contactName') ?? businessName,
    if (value('phone') != null) 'phone': value('phone'),
    if (value('email') != null) 'email': value('email'),
    if (value('address') != null) 'address': value('address'),
    if (value('city') != null) 'city': value('city'),
    if (value('state') != null) 'state': value('state'),
    if (value('pincode') != null) 'pincode': value('pincode'),
    if (value('gstNumber') != null) 'gstNumber': value('gstNumber'),
    if (value('panNumber') != null) 'panNumber': value('panNumber'),
    if (value('beneficiaryName') != null)
      'beneficiaryName': value('beneficiaryName'),
    if (value('accountNumber') != null) 'accountNumber': value('accountNumber'),
    if (value('ifscCode') != null) 'ifscCode': value('ifscCode'),
    if (value('upiId') != null) 'upiId': value('upiId'),
  };
}

List<Widget> _detailRows(Map<String, dynamic> item) {
  final rows = <Widget>[];
  for (final entry in item.entries) {
    if (entry.value is Map || entry.value is List) continue;
    rows.add(
      ActionRow(
        title: _titleCase(entry.key),
        subtitle: _detailDisplayValue(entry.key, entry.value),
      ),
    );
  }
  return rows;
}

dynamic _read(Map<String, dynamic> item, List<String> keys) {
  for (final key in keys) {
    dynamic value = item;
    for (final part in key.split('.')) {
      if (value is Map && value.containsKey(part)) {
        value = value[part];
      } else {
        value = null;
        break;
      }
    }
    if (value != null) return value;
  }
  return null;
}

List<Map<String, dynamic>> _listAt(
  Map<String, dynamic> item,
  List<String> keys,
) {
  for (final key in keys) {
    final value = _read(item, [key]);
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
  }
  return const [];
}

String _idOf(Map<String, dynamic> item) {
  return (_read(item, [
            'id',
            '_id',
            'sessionId',
            'playerProfileId',
            'drillId',
            'batchId',
            'notificationId',
          ]) ??
          '')
      .toString();
}

String _statusOf(Map<String, dynamic> item) {
  return (_read(item, ['status', 'sessionStatus']) ?? '')
      .toString()
      .toUpperCase();
}

String _labelOf(Map<String, dynamic> item, List<String> keys) {
  return (_read(item, keys) ?? 'Untitled').toString();
}

String _studentName(Map<String, dynamic> item) {
  return (_read(item, [
            'studentName',
            'playerName',
            'name',
            'player.name',
            'playerProfile.name',
          ]) ??
          'Student')
      .toString();
}

String _coachDisplayName(
  Map<String, dynamic> profile,
  Map<String, dynamic> biz,
) {
  final user = (biz['user'] as Map?)?.cast<String, dynamic>() ?? const {};
  final account =
      (biz['businessAccount'] as Map?)?.cast<String, dynamic>() ?? const {};
  return (_read(profile, ['name', 'coachName', 'fullName']) ??
          user['name'] ??
          account['contactName'] ??
          account['businessName'] ??
          'Coach')
      .toString();
}

String _coachRole(Map<String, dynamic> profile) {
  final level = _read(profile, ['coachLevel', 'level', 'role'])?.toString();
  if (level != null && level.isNotEmpty) return level;
  final years = _read(profile, ['experienceYears']);
  if (years != null) return 'Coach · $years years experience';
  return 'Coach';
}

int _academyCount(List<dynamic> batches) {
  final ids = <String>{};
  for (final item in batches.whereType<Map>()) {
    final academy = _read(item.cast<String, dynamic>(), [
      'academyId',
      'academy.id',
      'academyName',
      'academy.name',
    ])?.toString();
    if (academy != null && academy.isNotEmpty) ids.add(academy);
  }
  return ids.length;
}

String _profileActionTitle(String actionId) {
  return switch (actionId) {
    'add-academy' => 'Add Academy',
    'add-batch' => 'Add Batch',
    'add-student' => 'Add Student',
    'manage-documents' => 'Manage Documents',
    'remove-academy' => 'Remove Academy',
    'leave-batch' => 'Leave Batch',
    _ => _titleCase(actionId.replaceAll('-', ' ')),
  };
}

bool _isTodaySession(Map<String, dynamic> item) {
  final raw = _read(item, ['scheduledAt', 'date'])?.toString();
  if (raw == null) return false;
  final date = DateTime.tryParse(raw)?.toLocal();
  if (date == null) return false;
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

String _formatDate(String? raw) {
  final date = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
  if (date == null) return '';
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day}/${date.month}/${date.year} $hour:$minute';
}

String _formatLongDate(DateTime date) {
  const months = _monthNames;
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _sessionRows = ['nets', 'fielding', 'fitness', 'drills'];
const _quickSetupRows = ['nets', 'drills', 'fitness', 'fielding', 'holiday'];
const _oneOnOneSpecializationOptions = [
  'Batting',
  'Bowling',
  'Fielding',
  'Wicket Keeping',
  'All Rounder',
  'Fitness',
  'Conditioning',
  'Match Strategy',
  'Mental Training',
  'Other',
];
const _experienceOptions = ['0-2 years', '2-5 years', '5+ years'];
const _activationCoachLevelOptions = [
  'BCCI Level',
  'State Level',
  'District Level',
  'Division Level',
  'Club Level',
  'Academy Level',
  'School/College Level',
  'Private Coach',
];

Map<String, Set<String>> _emptyBatchSchedule() => {
  for (final day in _days) day: <String>{},
};

bool _hasAnySelectedDay(_BatchCardState state) {
  return state.schedule.values.any((selected) => selected.isNotEmpty);
}

String? _validateBatchSetupStates(Iterable<_BatchCardState> states) {
  final list = states.toList();
  if (list.isEmpty || !list.any(_hasAnySelectedDay)) {
    return 'Please complete required batch details before saving.';
  }
  for (final state in list) {
    for (final entry in state.schedule.entries) {
      if (entry.value.length > 1) {
        return 'Only one session type can be selected for ${entry.key}.';
      }
      final invalid = entry.value.where(
        (type) => !_quickSetupRows.contains(type),
      );
      if (invalid.isNotEmpty) {
        return 'Unable to save batch setup. Please try again.';
      }
    }
  }
  return null;
}

List<(String, String)> _batchSetupSummaryRows(_BatchCardState state) {
  return _days
      .where((day) => state.schedule[day]?.isNotEmpty == true)
      .map((day) => (day, _titleCase(state.schedule[day]!.single)))
      .toList();
}

void _toggleQuickSetupCell(
  Map<String, Set<String>> schedule,
  String sessionType,
  String day,
) {
  final selections = schedule.putIfAbsent(day, () => <String>{});
  if (sessionType == 'holiday') {
    if (selections.contains('holiday')) {
      selections.clear();
    } else {
      selections
        ..clear()
        ..add('holiday');
    }
    return;
  }
  if (selections.contains(sessionType)) {
    selections.clear();
  } else {
    selections
      ..clear()
      ..add(sessionType);
  }
}

String _shortDay(String day) => day.length > 3 ? day.substring(0, 3) : day;

String _displayCompactRange(String raw) {
  final parts = raw.split('-');
  if (parts.length != 2) return raw;
  return '${_to12h(parts[0])}\n${_to12h(parts[1])}';
}

String _to12h(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return hhmm;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = parts[1];
  final hour = h % 12 == 0 ? 12 : h % 12;
  final meridian = h >= 12 ? 'PM' : 'AM';
  return '$hour:$m $meridian';
}

String? _addMinutesToTime(String? start, int minutes) {
  if (start == null) return null;
  final parts = start.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  final total = hour * 60 + minute + minutes;
  final h = (total ~/ 60) % 24;
  final m = total % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

int _minutesDiff(String start, String end) {
  final s = start.split(':');
  final e = end.split(':');
  final sm = (int.parse(s[0]) * 60) + int.parse(s[1]);
  final em = (int.parse(e[0]) * 60) + int.parse(e[1]);
  return em > sm ? em - sm : 60;
}

Future<void> showBookOneToOneSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.82,
        child: DynamicFormScreen(
          title: 'Book Session',
          fields: const [
            FormFieldSpec('playerProfileId', 'Player ID', required: true),
            FormFieldSpec('scheduledAt', 'Date Time ISO', required: true),
            FormFieldSpec('notes', 'Notes', multiline: true),
          ],
          onSubmit: (body) async {
            await ref.read(apiClientProvider).post('/coach/gig-bookings', body);
            return null;
          },
        ),
      ),
    ),
  );
}

Future<Map<String, dynamic>> _loadPaymentTab(WidgetRef ref) async {
  final api = ref.read(apiClientProvider);
  final data = await Future.wait([
    api.get('/coach/earnings'),
    api.getList('/coach/gig-bookings', query: {'page': '1', 'limit': '50'}),
  ]);
  final earnings = data[0] as Map<String, dynamic>;
  final txns = (data[1] as List).cast<Map<String, dynamic>>();
  final total = _read(earnings, ['totalAmountPaise', 'amountPaise']) ?? 0;
  final month = _extractMonthlyRevenuePaise(earnings);
  final pending = txns
      .where((t) => _statusOf(t) == 'PENDING')
      .fold<num>(
        0,
        (sum, t) =>
            sum +
            (num.tryParse('${_read(t, ['amountPaise', 'amount']) ?? 0}') ?? 0),
      );
  return {
    'total': total,
    'month': month,
    'pending': pending,
    'transactions': txns,
  };
}

class _LiveSessionContext {
  const _LiveSessionContext({
    required this.sessionId,
    required this.sessionType,
    required this.batchName,
    required this.timeLabel,
    required this.players,
  });
  final String sessionId;
  final String sessionType;
  final String batchName;
  final String timeLabel;
  final List<Map<String, dynamic>> players;
}

Future<_LiveSessionContext> _detectOrCreateLiveSession(WidgetRef ref) async {
  final api = ref.read(apiClientProvider);
  final data = await Future.wait([
    api.getList('/coach/batches'),
    api.getList('/coach/schedules'),
    api.getList('/coach/sessions', query: {'page': '1', 'limit': '50'}),
  ]);
  final batches = (data[0] as List).cast<Map<String, dynamic>>();
  final schedules = (data[1] as List).cast<Map<String, dynamic>>();
  final sessions = (data[2] as List).cast<Map<String, dynamic>>();
  if (batches.isEmpty) throw const ApiException('No batch assigned yet.');
  final now = DateTime.now();
  final dayIndex = now.weekday % 7;
  final nowMinutes = now.hour * 60 + now.minute;
  Map<String, dynamic>? active;
  for (final s in schedules) {
    if (_read(s, ['isActive']) == false) continue;
    final days = _listAt(s, [
      'daysOfWeek',
    ]).map((e) => int.tryParse('$e')).whereType<int>();
    if (!days.contains(dayIndex)) continue;
    final type = (_read(s, ['sessionType'])?.toString().toLowerCase() ?? '');
    if (type == 'holiday') continue;
    final start = _read(s, ['startTime'])?.toString() ?? '00:00';
    final p = start.split(':');
    if (p.length != 2) continue;
    final startMins =
        (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
    final duration =
        int.tryParse(_read(s, ['durationMins'])?.toString() ?? '60') ?? 60;
    if (nowMinutes >= startMins && nowMinutes <= startMins + duration + 30) {
      active = s;
      break;
    }
  }
  if (active == null)
    throw const ApiException('No session scheduled for this time.');
  final batchId = _read(active, ['batchId'])?.toString() ?? '';
  final sessionType =
      (_read(active, ['sessionType'])?.toString().toLowerCase() ?? 'drills');
  final batch = batches.firstWhere(
    (b) => _idOf(b) == batchId,
    orElse: () => {'id': batchId, 'name': 'Batch'},
  );
  final existing = sessions.where((s) {
    final sameBatch = _read(s, ['batchId'])?.toString() == batchId;
    final sameType =
        (_read(s, ['sessionType'])?.toString().toLowerCase() ?? '') ==
        sessionType;
    final liveOrUpcoming = [
      'SCHEDULED',
      'LIVE',
      'UPCOMING',
    ].contains(_statusOf(s));
    return sameBatch && sameType && liveOrUpcoming && _isTodaySession(s);
  }).toList();
  Map<String, dynamic> session;
  if (existing.isNotEmpty) {
    session = existing.first;
  } else {
    session = await api.post('/coach/sessions', {
      'sessionType': sessionType.toUpperCase(),
      'batchId': batchId,
      'academyId': _read(batch, ['academyId', 'academy.id'])?.toString(),
      'durationMins': _read(active, ['durationMins']) ?? 60,
      'scheduledAt': DateTime.now().toIso8601String(),
    });
  }
  final start = _read(active, ['startTime'])?.toString() ?? '00:00';
  final end =
      _addMinutesToTime(
        start,
        int.tryParse(_read(active, ['durationMins'])?.toString() ?? '60') ?? 60,
      ) ??
      start;
  return _LiveSessionContext(
    sessionId: _idOf(session),
    sessionType: sessionType,
    batchName: _labelOf(batch, ['name', 'batchName']),
    timeLabel: '${_to12h(start)} - ${_to12h(end)}',
    players: _listAt(batch, ['students']).cast<Map<String, dynamic>>(),
  );
}

class CoachFeedbackFlowScreen extends StatefulWidget {
  const CoachFeedbackFlowScreen({
    required this.sessionId,
    required this.sessionType,
    required this.players,
    required this.submitRows,
    required this.onSubmitted,
    super.key,
  });
  final String sessionId;
  final String sessionType;
  final List<FeedbackPlayer> players;
  final Future<void> Function(List<PlayerFeedbackPayload> rows) submitRows;
  final Future<void> Function() onSubmitted;
  @override
  State<CoachFeedbackFlowScreen> createState() =>
      _CoachFeedbackFlowScreenState();
}

class _CoachFeedbackFlowScreenState extends State<CoachFeedbackFlowScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player Feedback')),
      body: FeedbackForm(
        sessionType: widget.sessionType,
        players: widget.players,
        draftKey: '${widget.sessionId}|${widget.sessionType}|coach_flow',
        onSkip: () async {},
        onSubmit: (playerRows) async {
          await widget.submitRows(playerRows);
          await widget.onSubmitted();
        },
      ),
    );
  }
}

List<Map<String, dynamic>> _toSchedulePayloads(
  String batchId,
  _BatchCardState state,
  List<Map<String, dynamic>> preserveFrom,
) {
  final byType = <String, Map<String, dynamic>>{};
  final defaults = _defaultTimingByType(preserveFrom);
  for (var d = 0; d < _days.length; d++) {
    final day = _days[d];
    final dayTypes = state.schedule[day] ?? const <String>{};
    if (dayTypes.isEmpty) continue;
    if (dayTypes.contains('holiday')) {
      byType.putIfAbsent(
        'holiday|holiday',
        () => {
          'sessionType': 'HOLIDAY',
          'daysOfWeek': <int>[],
          'startTime': '00:00',
          'durationMins': 60,
          'batchId': batchId,
        },
      );
      (byType['holiday|holiday']!['daysOfWeek'] as List<int>).add(d);
      continue;
    }
    for (final dayType in dayTypes) {
      final timing =
          defaults[dayType] ??
          const _ScheduleTiming(startTime: '06:00', durationMins: 60);
      final key = '$dayType|${timing.startTime}|${timing.durationMins}';
      byType.putIfAbsent(
        key,
        () => {
          'sessionType': dayType.toUpperCase(),
          'daysOfWeek': <int>[],
          'startTime': timing.startTime,
          'durationMins': timing.durationMins,
          'batchId': batchId,
        },
      );
      (byType[key]!['daysOfWeek'] as List<int>).add(d);
    }
  }
  return byType.values.toList();
}

class _ScheduleTiming {
  const _ScheduleTiming({required this.startTime, required this.durationMins});
  final String startTime;
  final int durationMins;
}

Map<String, _ScheduleTiming> _defaultTimingByType(
  List<Map<String, dynamic>> schedules,
) {
  final timing = <String, _ScheduleTiming>{};
  for (final schedule in schedules) {
    final type =
        (_read(schedule, ['sessionType'])?.toString().toLowerCase() ?? '');
    if (!_sessionRows.contains(type)) continue;
    final start = _read(schedule, ['startTime'])?.toString();
    final duration = int.tryParse(
      _read(schedule, ['durationMins'])?.toString() ?? '',
    );
    if (start == null || duration == null || duration <= 0) continue;
    timing[type] = _ScheduleTiming(startTime: start, durationMins: duration);
  }
  return timing;
}

String _scheduleKey(Map<String, dynamic> schedule) {
  final type = (_read(schedule, ['sessionType'])?.toString() ?? '')
      .toUpperCase();
  final days =
      _listAt(schedule, ['daysOfWeek'])
          .map((e) => int.tryParse(e.toString()) ?? -1)
          .where((e) => e >= 0)
          .toList()
        ..sort();
  return '$type|${_read(schedule, ['startTime'])}|${_read(schedule, ['durationMins'])}|${days.join(',')}';
}

bool _isCardCompleted(_BatchCardState state) {
  for (final day in _days) {
    if (state.schedule[day]?.isNotEmpty != true) return false;
  }
  return true;
}

bool _isBatchSetupComplete(
  List<Map<String, dynamic>> batches,
  List<Map<String, dynamic>> schedules,
) {
  if (batches.isEmpty) return false;
  for (final batch in batches) {
    final batchId = _idOf(batch);
    final state = _BatchCardState.fromApi(
      batchId,
      batch,
      schedules
          .where((s) => _read(s, ['batchId'])?.toString() == batchId)
          .toList(),
    );
    if (!state.completed) return false;
  }
  return true;
}

List<Map<String, dynamic>> _upcomingTimetableToday(
  List<Map<String, dynamic>> schedules,
) {
  final now = DateTime.now();
  final todayIndex = (now.weekday % 7);
  final nowMinutes = now.hour * 60 + now.minute;
  final today = schedules.where((s) {
    if (_read(s, ['isActive']) == false) return false;
    final days = _listAt(s, [
      'daysOfWeek',
    ]).map((e) => int.tryParse(e.toString())).whereType<int>();
    if (!days.contains(todayIndex)) return false;
    final time = _read(s, ['startTime'])?.toString() ?? '00:00';
    final p = time.split(':');
    if (p.length != 2) return false;
    final mins = (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
    return mins > nowMinutes &&
        (_read(s, ['sessionType'])?.toString().toUpperCase() != 'HOLIDAY');
  }).toList();
  today.sort(
    (a, b) => (_read(a, ['startTime'])?.toString() ?? '').compareTo(
      _read(b, ['startTime'])?.toString() ?? '',
    ),
  );
  return today.map((s) {
    final start = _read(s, ['startTime'])?.toString() ?? '00:00';
    final end =
        _addMinutesToTime(
          start,
          int.tryParse(_read(s, ['durationMins'])?.toString() ?? '60') ?? 60,
        ) ??
        start;
    return {
      'batch': _labelOf(s, ['batchName', 'batch.name', 'batchId']),
      'type': _titleCase(
        (_read(s, ['sessionType'])?.toString().toLowerCase() ?? 'session'),
      ),
      'time': '${_to12h(start)} - ${_to12h(end)}',
    };
  }).toList();
}

String _greetingTitle() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return 'Good Morning';
  if (hour >= 12 && hour < 17) return 'Good Afternoon';
  if (hour >= 17 && hour < 21) return 'Good Evening';
  return 'Good Night';
}

String _toFeedbackTemplateType(String sessionType) {
  final normalized = sessionType.trim().toLowerCase();
  if (normalized == 'nets') return 'nets_batting';
  return normalized;
}

String _avatarLetter(String name) {
  final cleaned = name.trim();
  if (cleaned.isEmpty) return 'P';
  return cleaned[0].toUpperCase();
}

Map<String, dynamic> _profileSummary(Map<String, dynamic> profile) {
  return {
    'name': _labelOf(profile, ['name', 'coachName', 'fullName']),
    'phone': _read(profile, ['phone', 'mobile', 'phoneNumber']),
    'email': _read(profile, ['email']),
  };
}

String _safeDisplayValue(Object? value, {String fallback = '-'}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text == 'null' ? fallback : text;
}

bool _hasDisplayValue(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isNotEmpty && text != 'null';
}

String _listDisplayValue(List<String> values) {
  return values.isEmpty ? 'Not added' : values.join(', ');
}

List<String> _profileSpecializations(Map<String, dynamic> details) {
  final raw = _read(details, [
    'specializations',
    'expertiseTags',
    'specialization',
  ]);
  if (raw is List) {
    return raw
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  final text = raw?.toString() ?? '';
  return text
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

String _experienceLabel(Map<String, dynamic> details) {
  final raw = _read(details, [
    'coachingExperience',
    'experience',
    'experienceYears',
  ]);
  final text = raw?.toString().trim() ?? '';
  if (text.isEmpty) return 'Not added';
  if (RegExp(r'^\d+$').hasMatch(text)) return '$text years';
  return text;
}

List<String> _coachLevelLabels(Map<String, dynamic> details) {
  const supported = [
    'BCCI Level',
    'State Level',
    'District Level',
    'Division Level',
    'Academy Level',
    'School Level',
    'Private Coach',
    'Fitness Coach',
    'Other',
  ];
  final raw = _read(details, ['coachLevels', 'coachLevel', 'levels']);
  final values = raw is List
      ? raw.map((e) => e.toString()).toList()
      : raw == null
      ? const <String>[]
      : raw.toString().split(',');
  final normalized = values.map((e) => e.trim()).where((e) => e.isNotEmpty).map(
    (e) {
      return supported.firstWhere(
        (level) => level.toLowerCase() == e.toLowerCase(),
        orElse: () => e,
      );
    },
  ).toList();
  return normalized.isEmpty ? const <String>[] : normalized;
}

ThemeMode _currentThemeMode(BuildContext context) {
  return context
          .findAncestorStateOfType<_CoachRouterAppState>()
          ?.widget
          .themeMode ??
      ThemeMode.light;
}

void _setThemeFromContext(BuildContext context, ThemeMode mode) {
  context
      .findAncestorStateOfType<_CoachRouterAppState>()
      ?.widget
      .onThemeModeChanged(mode);
}

bool _isCurrentMonthBooking(Map<String, dynamic> item) {
  final status = _statusOf(item);
  if (status == 'CANCELLED' || status == 'REJECTED') return false;
  final raw = _read(item, ['scheduledAt', 'startTime', 'date', 'createdAt']);
  final date = raw == null
      ? null
      : DateTime.tryParse(raw.toString())?.toLocal();
  if (date == null) return false;
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month;
}

Map<String, dynamic> _oneOnOneSessionCard(Map<String, dynamic> item) {
  final start = _read(item, ['scheduledAt', 'startTime', 'date'])?.toString();
  return {
    ...item,
    'id': '',
    'batch': '1-to-1',
    'type': _labelOf(item, ['sessionType', 'title', 'playerProfile.name']),
    'time': start == null ? 'Today' : _formatDate(start),
  };
}

ValueChanged<ThemeMode>? _themeSetterFromContext(BuildContext context) {
  return context
      .findAncestorStateOfType<_CoachRouterAppState>()
      ?.widget
      .onThemeModeChanged;
}

num _extractMonthlyRevenuePaise(Map<String, dynamic> earnings) {
  final months = _listAt(earnings, ['monthlyBreakdown', 'months']);
  final now = DateTime.now();
  final currentMonthName = _monthNames[now.month - 1];
  final current = months.cast<Map<String, dynamic>>().firstWhere(
    (month) =>
        (_read(month, ['monthName', 'month'])?.toString().toLowerCase() ?? '')
            .contains(currentMonthName.toLowerCase()),
    orElse: () => const <String, dynamic>{},
  );
  final fromMonth = _read(current, ['amountPaise']);
  if (fromMonth is num) return fromMonth;
  final fallback = _read(earnings, ['totalAmountPaise', 'amountPaise']);
  if (fallback is num) return fallback;
  final parsed = num.tryParse(fallback?.toString() ?? '');
  return parsed ?? 0;
}

List<Map<String, dynamic>> _revenueTrend(Map<String, dynamic> earnings) {
  final months = _listAt(earnings, [
    'monthlyBreakdown',
    'months',
  ]).cast<Map<String, dynamic>>();
  if (months.isNotEmpty) {
    final recent = months.length > 6
        ? months.sublist(months.length - 6)
        : months;
    return recent.map((month) {
      final label = _read(month, ['monthName', 'month'])?.toString() ?? '';
      final amount = _read(month, ['amountPaise', 'totalAmountPaise']) ?? 0;
      return {
        'label': label.length > 3 ? label.substring(0, 3) : label,
        'amountPaise': amount is num ? amount : num.tryParse('$amount') ?? 0,
      };
    }).toList();
  }
  final current = _extractMonthlyRevenuePaise(earnings);
  if (current > 0) {
    final fallback = _fallbackRevenueSeries();
    fallback[fallback.length - 1] = {
      'label': _monthNames[DateTime.now().month - 1],
      'amountPaise': current,
    };
    return fallback;
  }
  return const <Map<String, dynamic>>[];
}

List<Map<String, dynamic>> _fallbackRevenueSeries() {
  final now = DateTime.now();
  return List.generate(6, (index) {
    final monthIndex = (now.month - 6 + index) % 12;
    return {'label': _monthNames[monthIndex], 'amountPaise': 0};
  });
}

bool _isValidUpi(String value) {
  return RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$').hasMatch(value);
}

bool _hasCompletedUpiSetupFromProfile(
  Map<String, dynamic> account,
  Map<String, dynamic> payload,
) {
  final upiId = account['upiId'] ?? account['upi_id'] ?? payload['upi_id'];
  final paymentDetails =
      payload['payment_details'] ?? payload['paymentDetails'];
  final hasUpiId = upiId?.toString().trim().isNotEmpty == true;
  final hasPaymentDetails = paymentDetails is Map && paymentDetails.isNotEmpty;
  return hasUpiId || hasPaymentDetails;
}

bool _hasUsableAccessToken(AuthSession? session) {
  final token = session?.accessToken.trim();
  return token != null &&
      token.isNotEmpty &&
      token.toLowerCase() != 'null' &&
      token.toLowerCase() != 'undefined';
}

String? _tokenFrom(Map<String, dynamic> payload, List<String> keys) {
  for (final key in keys) {
    final value = payload[key]?.toString().trim();
    if (value != null &&
        value.isNotEmpty &&
        value.toLowerCase() != 'null' &&
        value.toLowerCase() != 'undefined') {
      return value;
    }
  }
  return null;
}

String _daysLabel(dynamic days) {
  const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  if (days is! List) return '';
  return days
      .map((e) => int.tryParse(e.toString()))
      .whereType<int>()
      .where((e) => e >= 0 && e < 7)
      .map((e) => names[e])
      .join(', ');
}

String _rupees(dynamic paise) {
  final value = paise is num ? paise : num.tryParse(paise?.toString() ?? '');
  if (value == null) return '₹0';
  return '₹${(value / 100).toStringAsFixed(0)}';
}

String _percent(dynamic value) {
  final numValue = value is num ? value : num.tryParse(value?.toString() ?? '');
  if (numValue == null) return '0%';
  return '${(numValue <= 1 ? numValue * 100 : numValue).round()}%';
}

bool _profileUpdatePersisted(
  Map<String, dynamic> saved,
  Map<String, dynamic> updates,
) {
  for (final entry in updates.entries) {
    final key = entry.key;
    final next = entry.value;
    if (next == null) continue;
    final current = saved[key];
    if (next is List) {
      final currentList = current is List ? current : const [];
      final nextNorm = next.map((e) => e.toString().trim()).toList()..sort();
      final curNorm = currentList.map((e) => e.toString().trim()).toList()
        ..sort();
      if (nextNorm.length != curNorm.length) return false;
      for (var i = 0; i < nextNorm.length; i++) {
        if (nextNorm[i] != curNorm[i]) return false;
      }
      continue;
    }
    if (current?.toString().trim() != next.toString().trim()) return false;
  }
  return true;
}

String _detailDisplayValue(String key, dynamic value) {
  if (value == null) return '';
  if (key.toLowerCase().contains('paise')) return _rupees(value);
  if (key.toLowerCase().contains('rate') ||
      key.toLowerCase().contains('completion')) {
    return _percent(value);
  }
  if (key.toLowerCase().contains('at')) return _formatDate(value.toString());
  return value.toString();
}

String _titleCase(String key) {
  final withSpaces = key
      .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
      .replaceAll('_', ' ');
  return withSpaces
      .trim()
      .split(' ')
      .where((e) => e.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

Color _statusColor(String value) {
  final upper = value.toUpperCase();
  if (upper.contains('PRESENT') ||
      upper.contains('LIVE') ||
      upper.contains('PUBLISHED') ||
      upper.contains('EXCELLING')) {
    return const Color(0xFF087F5B);
  }
  if (upper.contains('LATE') ||
      upper.contains('SCHEDULED') ||
      upper.contains('DRAFT') ||
      upper.contains('ATTENTION')) {
    return const Color(0xFFB7791F);
  }
  if (upper.contains('ABSENT') ||
      upper.contains('CANCEL') ||
      upper.contains('CRITICAL')) {
    return const Color(0xFFC62828);
  }
  return const Color(0xFF3A3A3A);
}

String _errorMessage(Object? error) {
  if (error is AuthException) return 'Session expired. Please login again.';
  if (error is ApiException) return error.message;
  final raw = error.toString();
  if (raw.contains('SocketException')) return 'Network error. Please retry.';
  return raw.replaceFirst('Exception: ', '');
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
    final accessToken = _tokenFrom(payload, ['accessToken', 'token']);
    if (accessToken == null) throw const AuthException('TOKEN_MISSING');
    final needsCoachRegistration =
        (businessStatus?['hasBusinessAccount'] != true) ||
        (businessStatus?['coachProfileId'] == null);
    return AuthSession(
      accessToken: accessToken,
      refreshToken: _tokenFrom(payload, ['refreshToken']),
      phone: (user?['phone'] as String?) ?? phone,
      userName: user?['name'] as String?,
      needsCoachRegistration: needsCoachRegistration,
    );
  }

  Future<AuthSession?> refreshAuthSession(AuthSession session) async {
    final refreshToken = session.refreshToken?.trim();
    if (refreshToken == null || refreshToken.isEmpty) return null;
    try {
      final data = await _postJson(Uri.parse('$_backendBaseUrl/auth/refresh'), {
        'refreshToken': refreshToken,
      });
      final payload = ((data['data'] ?? data) as Map).cast<String, dynamic>();
      final accessToken = _tokenFrom(payload, ['accessToken', 'token']);
      if (accessToken == null) return null;
      return session.copyWith(
        accessToken: accessToken,
        refreshToken: _tokenFrom(payload, ['refreshToken']) ?? refreshToken,
      );
    } catch (_) {
      return null;
    }
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

  Future<Map<String, dynamic>> getBizMe(String accessToken) {
    return _getJson(
      Uri.parse('$_backendBaseUrl/biz/me'),
      accessToken: accessToken,
    );
  }

  Future<void> updateBusinessDetails({
    required String accessToken,
    Map<String, dynamic>? existingBusinessAccount,
    String? upiId,
    String? beneficiaryName,
    String? accountNumber,
    String? ifscCode,
  }) async {
    Map<String, dynamic>? account = existingBusinessAccount;
    if (account == null) {
      final data = await getBizMe(accessToken);
      final payload = ((data['data'] ?? data) as Map).cast<String, dynamic>();
      account = (payload['businessAccount'] as Map?)?.cast<String, dynamic>();
    }
    final existing = (account ?? const {}).cast<String, dynamic>();
    final payload = _businessDetailsPayload(existing);
    payload.addAll({
      if (upiId != null && upiId.isNotEmpty) 'upiId': upiId,
      if (beneficiaryName != null && beneficiaryName.isNotEmpty)
        'beneficiaryName': beneficiaryName,
      if (accountNumber != null && accountNumber.isNotEmpty)
        'accountNumber': accountNumber,
      if (ifscCode != null && ifscCode.isNotEmpty) 'ifscCode': ifscCode,
    });
    await _putJson(
      Uri.parse('$_backendBaseUrl/biz/business-details'),
      payload,
      accessToken: accessToken,
    );
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

  Future<Map<String, dynamic>> _getJson(Uri uri, {String? accessToken}) async {
    final request = await _client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (accessToken != null) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
    }
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
    this.hasCompletedUpiSetup = false,
    this.refreshToken,
    this.userName,
  });

  final String accessToken;
  final String phone;
  final bool needsCoachRegistration;
  final bool hasCompletedUpiSetup;
  final String? refreshToken;
  final String? userName;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString(),
      phone: json['phone']?.toString() ?? '',
      userName: json['userName']?.toString(),
      needsCoachRegistration: json['needsCoachRegistration'] == true,
      hasCompletedUpiSetup: json['hasCompletedUpiSetup'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'phone': phone,
      'userName': userName,
      'needsCoachRegistration': needsCoachRegistration,
      'hasCompletedUpiSetup': hasCompletedUpiSetup,
    };
  }

  AuthSession copyWith({
    String? accessToken,
    String? phone,
    bool? needsCoachRegistration,
    bool? hasCompletedUpiSetup,
    String? refreshToken,
    String? userName,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      phone: phone ?? this.phone,
      needsCoachRegistration:
          needsCoachRegistration ?? this.needsCoachRegistration,
      hasCompletedUpiSetup: hasCompletedUpiSetup ?? this.hasCompletedUpiSetup,
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
