import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pinput/pinput.dart';

void main() {
  runApp(const SwingClubApp());
}

// --- Constants ---
const String _googlePlacesKey = 'AIzaSyDpJ1S4JYO-jVA6BgzxM1LYjdSvrSrTkTo';

// --- Services ---

class AuthService {
  static const String _twoFactorApiKey = 'c03bfecb-f75f-11f0-a6b2-0200cd936042';
  static const String _backendBaseUrl = 'https://swing-backend-1007730655118.asia-south1.run.app';
  
  final _dio = Dio();

  /// Checks if a user exists in the backend by phone number.
  Future<bool?> checkUserExists(String phone) async {
    try {
      final url = '$_backendBaseUrl/auth/check-phone';
      debugPrint('[AuthService] Checking user existence (REAL API): $url');
      final response = await _dio.post(url, data: {'phone': phone});
      debugPrint('[AuthService] CheckPhone Response: ${response.data}');
      
      if (response.data['success'] == true) {
        return response.data['data']['exists'] == true;
      }
    } on DioException catch (e) {
      debugPrint('[AuthService] CheckPhone DioException: ${e.message}');
    } catch (e) {
      debugPrint('[AuthService] CheckPhone Unexpected Error: $e');
    }
    return null;
  }

  Future<String?> sendOtp(String phone) async {
    try {
      final url = 'https://2factor.in/API/V1/$_twoFactorApiKey/SMS/$phone/AUTOGEN';
      debugPrint('[AuthService] Sending REAL OTP request to: $url');
      
      final response = await _dio.get(url);
      debugPrint('[AuthService] 2Factor Response: ${response.data}');

      if (response.data['Status'] == 'Success') {
        return response.data['Details'];
      }
    } catch (e) {
      debugPrint('[AuthService] Error during sendOtp: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> verifyAndLogin({
    required String phone,
    required String sessionId,
    required String otp,
    String? name,
  }) async {
    try {
      final url = '$_backendBaseUrl/auth/biz/phone-login';
      final payload = {
        'phone': phone,
        'sessionId': sessionId,
        'otp': otp,
        'name': name ?? 'Swing Club User',
      };
      
      debugPrint('[AuthService] Verifying OTP at REAL BACKEND: $url');
      debugPrint('[AuthService] Payload: $payload');

      final response = await _dio.post(url, data: payload);
      debugPrint('[AuthService] Backend Response: ${response.data}');

      if (response.data['success'] == true) {
        return response.data['data'];
      }
    } on DioException catch (e) {
      debugPrint('[AuthService] DioException during verify: ${e.message}');
      debugPrint('[AuthService] Response data: ${e.response?.data}');
    } catch (e) {
      debugPrint('[AuthService] Unexpected error during verify: $e');
    }
    return null;
  }

  Future<bool> setupAcademyProfile({
    required String accessToken,
    required String name,
    required String address,
    required String city,
    required String state,
  }) async {
    try {
      final dio = Dio(BaseOptions(headers: {'Authorization': 'Bearer $accessToken'}));
      
      final detailsPayload = {
        'businessName': '$name Academy',
        'city': city,
        'state': state,
        'address': address,
      };

      debugPrint('[AuthService] PUT /biz/business-details: $detailsPayload');
      await dio.put('$_backendBaseUrl/biz/business-details', data: detailsPayload);

      final academyPayload = {
        'name': '$name Academy',
        'city': city,
        'state': state,
        'address': address,
      };

      debugPrint('[AuthService] POST /biz/academy: $academyPayload');
      await dio.post('$_backendBaseUrl/biz/academy', data: academyPayload);
      
      debugPrint('[AuthService] Academy profile successfully linked to backend.');
      return true;
    } catch (e) {
      debugPrint('[AuthService] setupAcademyProfile Error: $e');
      if (e is DioException) {
        debugPrint('[AuthService] setupAcademyProfile DioError: ${e.response?.data}');
      }
      return false;
    }
  }

  Future<Map<String, dynamic>?> getBusinessProfile(String accessToken) async {
    try {
      final dio = Dio(BaseOptions(headers: {'Authorization': 'Bearer $accessToken'}));
      final response = await dio.get('$_backendBaseUrl/biz/me');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
    } catch (e) {
      debugPrint('[AuthService] getBusinessProfile Error: $e');
    }
    return null;
  }
}

// --- App Root ---

class SwingClubApp extends StatefulWidget {
  const SwingClubApp({super.key});

  @override
  State<SwingClubApp> createState() => _SwingClubAppState();
}

class _SwingClubAppState extends State<SwingClubApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color deepBlue = Color(0xFF0057C8);
    const Color deepNavy = Color(0xFF071B3D);
    const Color cleanWhite = Color(0xFFFFFFFF);
    const Color ivory = Color(0xFFF4F2EB);

    return MaterialApp(
      title: 'Swing Club',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: ivory,
        colorScheme: ColorScheme.light(
          primary: deepBlue,
          onPrimary: cleanWhite,
          surface: ivory,
          onSurface: deepNavy,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(onToggleTheme: _toggleTheme, isDark: _themeMode == ThemeMode.dark),
      },
    );
  }
}

// --- Screens ---

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const LoginScreen({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleContinue() async {
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final exists = await _authService.checkUserExists(phone);
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (exists == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error. Please try again.')),
      );
      return;
    }

    if (exists) {
      final sessionId = await _authService.sendOtp(phone);
      if (sessionId != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(phone: phone, sessionId: sessionId, isNewUser: false),
          ),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegistrationScreen(phone: phone)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Icon(Icons.sports_golf_rounded, size: 80, color: Color(0xFF0057C8)),
                const SizedBox(height: 24),
                Text('Swing Club', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                const Text('Academy Management Suite', style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 60),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Mobile Number', hintText: '9958955622', prefixIcon: Icon(Icons.phone_iphone)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isLoading ? null : _handleContinue,
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  final String phone;
  const RegistrationScreen({super.key, required this.phone});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  
  String? _capturedCity;
  String? _capturedState;
  
  final _authService = AuthService();
  final _dio = Dio();
  bool _isLoading = false;
  
  // Maps Autocomplete
  List<dynamic> _suggestions = [];
  Timer? _debounce;
  bool _isSearching = false;

  Future<void> _fetchSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': input,
          'key': _googlePlacesKey,
          'components': 'country:in',
          'types': 'geocode|establishment',
        },
      );
      
      if (response.data['status'] == 'OK') {
        setState(() => _suggestions = response.data['predictions']);
      }
    } catch (e) {
      debugPrint('Places Error: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _onAddressChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _fetchSuggestions(value));
  }

  Future<void> _selectPlace(dynamic suggestion) async {
    final placeId = suggestion['place_id'];
    final description = suggestion['description'];
    setState(() {
      _addressController.text = description;
      _suggestions = [];
    });

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': _googlePlacesKey,
          'fields': 'address_components,geometry',
        },
      );
      
      if (response.data['status'] == 'OK') {
        final components = response.data['result']['address_components'] as List;
        String? city;
        String? state;
        
        for (var c in components) {
          final types = c['types'] as List;
          if (types.contains('locality')) city = c['long_name'];
          if (types.contains('administrative_area_level_1')) state = c['long_name'];
        }
        
        setState(() {
          _capturedCity = city;
          _capturedState = state;
        });
        debugPrint('[Registration] Captured Location: City=$_capturedCity, State=$_capturedState');
      }
    } catch (e) {
      debugPrint('Place Details Error: $e');
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final sessionId = await _authService.sendOtp(widget.phone);
    setState(() => _isLoading = false);

    if (sessionId != null) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            phone: widget.phone,
            sessionId: sessionId,
            name: _nameController.text.trim(),
            address: _addressController.text.trim(),
            city: _capturedCity ?? 'Unknown City',
            state: _capturedState ?? 'Unknown State',
            isNewUser: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Academy Onboarding')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Academy Owner Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Provide details to register your academy business.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Owner Full Name', prefixIcon: Icon(Icons.person)),
                validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                onChanged: _onAddressChanged,
                decoration: InputDecoration(
                  labelText: 'Academy Address',
                  prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: _isSearching ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : null,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Address is required' : null,
              ),
              if (_suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final s = _suggestions[index];
                      return ListTile(
                        leading: const Icon(Icons.place_outlined, size: 20),
                        title: Text(s['description'], style: const TextStyle(fontSize: 14)),
                        onTap: () => _selectPlace(s),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Continue to Verify', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  final String phone;
  final String sessionId;
  final String? name;
  final String? address;
  final String? city;
  final String? state;
  final bool isNewUser;
  const OtpScreen({super.key, required this.phone, required this.sessionId, this.name, this.address, this.city, this.state, required this.isNewUser});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _authService = AuthService();
  bool _isVerifying = false;

  Future<void> _handleVerify(String otp) async {
    setState(() => _isVerifying = true);
    final data = await _authService.verifyAndLogin(phone: widget.phone, sessionId: widget.sessionId, otp: otp, name: widget.name);

    if (data != null) {
      if (widget.isNewUser && widget.name != null && widget.address != null) {
        await _authService.setupAcademyProfile(
          accessToken: data['accessToken'],
          name: widget.name!,
          address: widget.address!,
          city: widget.city ?? 'Unknown City',
          state: widget.state ?? 'Unknown State',
        );
      }
      
      setState(() => _isVerifying = false);
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(accessToken: data['accessToken']),
        ),
        (route) => false,
      );
    } else {
      setState(() => _isVerifying = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Verification')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text('We sent a code to ${widget.phone}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Enter the 6-digit code below', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 48),
            Pinput(
              length: 6,
              onCompleted: _handleVerify,
              defaultPinTheme: PinTheme(
                width: 56, height: 56,
                textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.primary), borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),
            if (_isVerifying) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String accessToken;
  const DashboardScreen({super.key, required this.accessToken});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _authService.getBusinessProfile(widget.accessToken);
    if (mounted) {
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _profileData?['user'];
    final biz = _profileData?['businessAccount'];
    final academy = (biz?['academyOwnerProfile']?['academies'] as List?)?.firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academy Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(color: theme.colorScheme.onPrimary.withOpacity(0.8), fontSize: 16),
                          ),
                          Text(
                            user?['name'] ?? 'Academy Owner',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Verified Academy',
                              style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Text('Business Profile', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                    _buildInfoCard(
                      theme,
                      title: 'Academy Details',
                      icon: Icons.business,
                      items: [
                        _InfoItem('Name', academy?['name'] ?? 'Not set'),
                        _InfoItem('City', academy?['city'] ?? 'Not set'),
                        _InfoItem('Address', academy?['address'] ?? 'Not set'),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildInfoCard(
                      theme,
                      title: 'Contact Information',
                      icon: Icons.contact_phone_outlined,
                      items: [
                        _InfoItem('Phone', user?['phone'] ?? 'Not set'),
                        _InfoItem('Email', academy?['email'] ?? 'Not set'),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Quick Action Placeholder
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_circle_outline, color: Colors.grey),
                          SizedBox(width: 12),
                          Text('More business features coming soon...', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, {required String title, required IconData icon, required List<_InfoItem> items}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(height: 32),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(item.label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ),
                  Expanded(
                    child: Text(item.value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  _InfoItem(this.label, this.value);
}
