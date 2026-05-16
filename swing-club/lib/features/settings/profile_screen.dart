import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/academy_provider.dart';
import '../../shared/onboarding_widgets.dart';
import '../../shared/widgets.dart';
import 'settings_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bizState = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                ref.read(settingsProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
      body: bizState.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(settingsProvider)),
        data: (data) {
          final user = (data['user'] as Map?)?.cast<String, dynamic>() ?? {};
          final biz  = (data['businessAccount'] as Map?)?.cast<String, dynamic>() ?? {};
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UserHeader(user: user, biz: biz),
              TabBar(
                controller: _tabs,
                tabs: const [Tab(text: 'Business'), Tab(text: 'Academy')],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _BusinessTab(biz: biz, user: user),
                    const _AcademyTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── User header ───────────────────────────────────────────────────────────────

class _UserHeader extends StatelessWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> biz;

  const _UserHeader({required this.user, required this.biz});

  @override
  Widget build(BuildContext context) {
    final name    = user['name']        as String? ?? '';
    final phone   = user['phone']       as String? ?? '';
    final bizName = biz['businessName'] as String? ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF071B3D),
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'User',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF071B3D)),
                ),
                if (phone.isNotEmpty)
                  Text(phone, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                if (bizName.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0057C8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      bizName,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF0057C8), fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Business tab ──────────────────────────────────────────────────────────────

class _BusinessTab extends ConsumerStatefulWidget {
  final Map<String, dynamic> biz;
  final Map<String, dynamic> user;
  const _BusinessTab({required this.biz, required this.user});

  @override
  ConsumerState<_BusinessTab> createState() => _BusinessTabState();
}

class _BusinessTabState extends ConsumerState<_BusinessTab> {
  int _subTab = 0;

  // Details
  late TextEditingController _bizName;
  late TextEditingController _pincode;
  late TextEditingController _city;
  late TextEditingController _state;
  late TextEditingController _address;

  // Contact
  late TextEditingController _contactName;
  late TextEditingController _phone;
  late TextEditingController _email;

  // Banking
  late TextEditingController _gst;
  late TextEditingController _pan;
  late TextEditingController _accNum;
  late TextEditingController _accNumConfirm;
  late TextEditingController _ifsc;

  bool _saving = false;

  String _b(String key) => widget.biz[key]  as String? ?? '';
  String _u(String key) => widget.user[key] as String? ?? '';

  void _initFromData() {
    _bizName     = TextEditingController(text: _b('businessName'));
    _pincode     = TextEditingController(text: _b('pincode'));
    _city        = TextEditingController(text: _b('city'));
    _state       = TextEditingController(text: _b('state'));
    _address     = TextEditingController(text: _b('address'));
    // Contact: fall back to registered user info if biz fields are blank
    _contactName = TextEditingController(text: _b('contactName').isNotEmpty ? _b('contactName') : _u('name'));
    _phone       = TextEditingController(text: _b('phone').isNotEmpty       ? _b('phone')       : _u('phone'));
    _email       = TextEditingController(text: _b('email').isNotEmpty       ? _b('email')       : _u('email'));
    _gst           = TextEditingController(text: _b('gstNumber'));
    _pan           = TextEditingController(text: _b('panNumber'));
    _accNum        = TextEditingController(text: _b('accountNumber'));
    _accNumConfirm = TextEditingController(text: _b('accountNumber'));
    _ifsc          = TextEditingController(text: _b('ifscCode'));
  }

  void _disposeControllers() {
    for (final c in [_bizName, _pincode, _city, _state, _address,
        _contactName, _phone, _email, _gst, _pan, _accNum, _accNumConfirm, _ifsc]) {
      c.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    _initFromData();
  }

  @override
  void didUpdateWidget(_BusinessTab old) {
    super.didUpdateWidget(old);
    if (old.biz != widget.biz) {
      _disposeControllers();
      _initFromData();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  Future<void> _save() async {
    if (_subTab == 2) {
      // Banking tab: only validate account number match
      if (_accNum.text.trim().isNotEmpty &&
          _accNum.text.trim() != _accNumConfirm.text.trim()) {
        showSnack(context, 'Account numbers do not match');
        return;
      }
    } else {
      final name = _bizName.text.trim();
      if (name.length < 2) { showSnack(context, 'Business name required'); return; }
      if (_city.text.trim().length < 2 || _state.text.trim().length < 2) {
        showSnack(context, 'City and state are required');
        return;
      }
    }

    // Backend requires businessName + city + state — fall back to saved values when on Banking tab.
    final bizName = _bizName.text.trim().isNotEmpty
        ? _bizName.text.trim()
        : (widget.biz['businessName'] as String? ?? '');
    final city  = _city.text.trim().isNotEmpty  ? _city.text.trim()  : (widget.biz['city']  as String? ?? '');
    final state = _state.text.trim().isNotEmpty ? _state.text.trim() : (widget.biz['state'] as String? ?? '');

    if (bizName.length < 2 || city.length < 2 || state.length < 2) {
      showSnack(context, 'Complete business details first (Details tab)');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(settingsProvider.notifier).updateBusinessDetails({
        'businessName': bizName,
        'city':  city,
        'state': state,
        if (_pincode.text.trim().isNotEmpty)      'pincode':     _pincode.text.trim(),
        if (_address.text.trim().isNotEmpty)      'address':     _address.text.trim(),
        if (_contactName.text.trim().isNotEmpty)  'contactName': _contactName.text.trim(),
        if (_phone.text.trim().isNotEmpty)        'phone':       _phone.text.trim(),
        if (_email.text.trim().isNotEmpty)        'email':       _email.text.trim(),
        if (_gst.text.trim().isNotEmpty)    'gstNumber':     _gst.text.trim(),
        if (_pan.text.trim().isNotEmpty)    'panNumber':     _pan.text.trim(),
        if (_accNum.text.trim().isNotEmpty) 'accountNumber': _accNum.text.trim(),
        if (_ifsc.text.trim().isNotEmpty)   'ifscCode':      _ifsc.text.trim(),
      });
      if (mounted) showSnack(context, 'Saved');
    } catch (e, st) {
      debugPrint('=== profile save error ===');
      debugPrint(e.toString());
      if (e is DioException) {
        debugPrint('status: ${e.response?.statusCode}');
        debugPrint('body: ${e.response?.data}');
      }
      debugPrint(st.toString());
      if (mounted) showSnack(context, 'Failed to save. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _subTabs(
          active: _subTab,
          labels: const ['Details', 'Contact', 'Banking'],
          onTap: (i) => setState(() => _subTab = i),
        ),

        // Content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            children: [
              if (_subTab == 0) ..._detailsFields(),
              if (_subTab == 1) ..._contactFields(),
              if (_subTab == 2) ..._bankingFields(),
            ],
          ),
        ),

        // Save button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _detailsFields() => [
    _label('Business'),
    _field(_bizName, 'Business Name *'),
    _label('Location'),
    PincodeLocationField(
      controller: _pincode,
      onResolved: (city, state) => setState(() {
        _city.text  = city;
        _state.text = state;
      }),
    ),
    Row(children: [
      Expanded(child: _field(_city,  'City *')),
      const SizedBox(width: 12),
      Expanded(child: _field(_state, 'State *')),
    ]),
    _field(_address, 'Address', maxLines: 2),
  ];

  List<Widget> _contactFields() => [
    Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0057C8).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF0057C8)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pre-filled from your registered account. Edit to set a different business contact.',
              style: TextStyle(fontSize: 12, color: Color(0xFF0057C8), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ),
    _field(_contactName, 'Contact Person'),
    _field(_phone,       'Contact Phone',   type: TextInputType.phone),
    _field(_email,       'Contact Email',   type: TextInputType.emailAddress),
  ];

  List<Widget> _bankingFields() {
    final isVerified    = widget.biz['routeEnabled'] == true;
    final verifiedName  = widget.biz['beneficiaryName'] as String? ?? '';
    final savedAccount  = widget.biz['accountNumber']   as String? ?? '';
    final savedIfsc     = widget.biz['ifscCode']        as String? ?? '';
    final hasSaved      = savedAccount.isNotEmpty;
    final masked        = hasSaved && savedAccount.length >= 4
        ? '•••• •••• ${savedAccount.substring(savedAccount.length - 4)}'
        : savedAccount;

    return [
      // ── Bank card ─────────────────────────────────────────
      if (hasSaved)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: BoxDecoration(
            color: const Color(0xFF071B3D),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.account_balance_rounded, color: Colors.white38, size: 16),
              const SizedBox(width: 6),
              Text(
                savedIfsc.isNotEmpty ? savedIfsc : 'Bank Account',
                style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isVerified
                      ? const Color(0xFF16A34A).withValues(alpha: 0.18)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    isVerified ? Icons.verified_rounded : Icons.schedule_rounded,
                    size: 11,
                    color: isVerified ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isVerified ? 'Verified' : 'Pending',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: isVerified ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
                    ),
                  ),
                ]),
              ),
            ]),
            const SizedBox(height: 18),
            Text(
              masked,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            if (verifiedName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                verifiedName,
                style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ]),
        )
      else
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(children: [
            Icon(Icons.account_balance_outlined, size: 18, color: Color(0xFFF59E0B)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Add your bank account to start receiving payments.',
                style: TextStyle(fontSize: 12, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ),

      _label('Bank Account'),
      _field(_accNum,        'Account Number',         type: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly]),
      _field(_accNumConfirm, 'Confirm Account Number', type: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly]),
      _field(_ifsc, 'IFSC Code', uppercase: true),

      _label('Tax'),
      _field(_gst, 'GST Number', uppercase: true),
      _field(_pan, 'PAN Number', uppercase: true),
    ];
  }
}

// ── Academy tab ───────────────────────────────────────────────────────────────

class _AcademyTab extends ConsumerStatefulWidget {
  const _AcademyTab();

  @override
  ConsumerState<_AcademyTab> createState() => _AcademyTabState();
}

class _AcademyTabState extends ConsumerState<_AcademyTab> {
  int _subTab = 0;

  TextEditingController? _name;
  TextEditingController? _tagline;
  TextEditingController? _desc;
  TextEditingController? _phone;
  TextEditingController? _email;
  TextEditingController? _website;
  TextEditingController? _address;
  TextEditingController? _city;
  TextEditingController? _state;
  TextEditingController? _pincode;

  String? _loadedAcademyId;
  bool _saving = false;
  double? _lat;
  double? _lng;

  void _onPlaceSelected({
    required String address,
    required String city,
    required String state,
    required String pincode,
    double? lat,
    double? lng,
  }) {
    setState(() {
      _address?.text = address;
      _city?.text    = city;
      _state?.text   = state;
      _pincode?.text = pincode;
      _lat = lat;
      _lng = lng;
    });
  }

  void _initControllers(AcademyState academy) {
    if (_loadedAcademyId == academy.academyId) return;
    _loadedAcademyId = academy.academyId;
    final a = academy.data;
    _disposeControllers();
    _name    = TextEditingController(text: a['name']        as String? ?? '');
    _tagline = TextEditingController(text: a['tagline']     as String? ?? '');
    _desc    = TextEditingController(text: a['description'] as String? ?? '');
    _phone   = TextEditingController(text: a['phone']       as String? ?? '');
    _email   = TextEditingController(text: a['email']       as String? ?? '');
    _website = TextEditingController(text: a['websiteUrl']  as String? ?? '');
    _address = TextEditingController(text: a['address']     as String? ?? '');
    _city    = TextEditingController(text: a['city']        as String? ?? '');
    _state   = TextEditingController(text: a['state']       as String? ?? '');
    _pincode = TextEditingController(text: a['pincode']     as String? ?? '');
  }

  void _disposeControllers() {
    for (final c in [_name, _tagline, _desc, _phone, _email, _website, _address, _city, _state, _pincode]) {
      c?.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }



  Future<void> _save(String academyId) async {
    final name = _name?.text.trim() ?? '';
    if (name.length < 2) { showSnack(context, 'Academy name required'); return; }
    setState(() => _saving = true);
    try {
      await ref.read(settingsProvider.notifier).updateAcademy(academyId, {
        'name':  name,
        'city':  _city?.text.trim() ?? '',
        'state': _state?.text.trim() ?? '',
        if ((_tagline?.text.trim() ?? '').isNotEmpty) 'tagline':     _tagline!.text.trim(),
        if ((_desc?.text.trim()    ?? '').isNotEmpty) 'description': _desc!.text.trim(),
        if ((_phone?.text.trim()   ?? '').isNotEmpty) 'phone':       _phone!.text.trim(),
        if ((_email?.text.trim()   ?? '').isNotEmpty) 'email':       _email!.text.trim(),
        if ((_website?.text.trim() ?? '').isNotEmpty) 'websiteUrl':  _website!.text.trim(),
        if ((_address?.text.trim() ?? '').isNotEmpty) 'address':     _address!.text.trim(),
        if ((_pincode?.text.trim() ?? '').isNotEmpty) 'pincode':     _pincode!.text.trim(),
        if (_lat != null) 'latitude':  _lat,
        if (_lng != null) 'longitude': _lng,
      });
      if (mounted) showSnack(context, 'Saved');
    } catch (_) {
      if (mounted) showSnack(context, 'Failed to save. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<Widget> _infoFields() => [
    _label('Academy'),
    _field(_name!,    'Academy Name', required: true),
    _field(_tagline!, 'Tagline'),
    _field(_desc!,    'About Academy', maxLines: 3),
  ];

  List<Widget> _contactFields() => [
    _field(_phone!,   'Phone',   type: TextInputType.phone),
    _field(_email!,   'Email',   type: TextInputType.emailAddress),
    _field(_website!, 'Website', type: TextInputType.url),
  ];

  List<Widget> _locationFields() => [
    PlacesSearchField(onPlaceSelected: _onPlaceSelected),
    _field(_address!, 'Address', maxLines: 2),
    Row(children: [
      Expanded(child: _field(_city!,  'City')),
      const SizedBox(width: 12),
      Expanded(child: _field(_state!, 'State')),
    ]),
    _field(_pincode!, 'Pincode',
           type: TextInputType.number,
           formatters: [FilteringTextInputFormatter.digitsOnly]),
  ];

  @override
  Widget build(BuildContext context) {
    final academyState = ref.watch(academyProvider);

    return academyState.when(
      loading: loadingBody,
      error: (e, _) {
        final isNoAcademy = e.toString().contains('NO_ACADEMY') ||
            (e is DioException && (e.response?.statusCode == 404 || e.response?.statusCode == 403));
        if (isNoAcademy) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.school_outlined, size: 36, color: Color(0xFF0057C8)),
                  const SizedBox(height: 16),
                  const Text('No Academy Yet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF071B3D))),
                  const SizedBox(height: 8),
                  const Text(
                    'Set up your academy to start managing students, batches, and sessions.',
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/academy-setup'),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create Academy'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return errorBody(e, () => ref.invalidate(academyProvider));
      },
      data: (academy) {
        _initControllers(academy);
        return Column(
          children: [
            _subTabs(
              active: _subTab,
              labels: const ['Info', 'Contact', 'Location'],
              onTap: (i) => setState(() => _subTab = i),
            ),
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  if (_subTab == 0) ..._infoFields(),
                  if (_subTab == 1) ..._contactFields(),
                  if (_subTab == 2) ..._locationFields(),
                ],
              ),
            ),
            // Save button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : () => _save(academy.academyId),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w700, letterSpacing: 0.8),
      ),
    );

Widget _field(
  TextEditingController ctrl,
  String label, {
  bool required = false,
  int maxLines = 1,
  TextInputType type = TextInputType.text,
  bool uppercase = false,
  List<TextInputFormatter>? formatters,
}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        inputFormatters: [
          ...?formatters,
          if (uppercase) _UpperCaseFormatter(),
        ],
        decoration: InputDecoration(labelText: required ? '$label *' : label),
      ),
    );

Widget _subTabs({
  required int active,
  required List<String> labels,
  required ValueChanged<int> onTap,
}) =>
    Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFE9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isActive = i == active;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF071B3D) : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF8A8A8A),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) =>
      next.copyWith(text: next.text.toUpperCase());
}
