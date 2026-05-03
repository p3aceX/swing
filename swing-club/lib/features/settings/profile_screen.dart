import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/academy_provider.dart';
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
      appBar: AppBar(title: const Text('Profile')),
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
                    _BusinessTab(biz: biz),
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
  const _BusinessTab({required this.biz});

  @override
  ConsumerState<_BusinessTab> createState() => _BusinessTabState();
}

class _BusinessTabState extends ConsumerState<_BusinessTab> {
  late final TextEditingController _bizName     = TextEditingController(text: _s('businessName'));
  late final TextEditingController _contactName = TextEditingController(text: _s('contactName'));
  late final TextEditingController _phone       = TextEditingController(text: _s('phone'));
  late final TextEditingController _email       = TextEditingController(text: _s('email'));
  late final TextEditingController _city        = TextEditingController(text: _s('city'));
  late final TextEditingController _state       = TextEditingController(text: _s('state'));
  late final TextEditingController _address     = TextEditingController(text: _s('address'));
  late final TextEditingController _pincode     = TextEditingController(text: _s('pincode'));
  late final TextEditingController _gst         = TextEditingController(text: _s('gstNumber'));
  late final TextEditingController _pan         = TextEditingController(text: _s('panNumber'));
  late final TextEditingController _beneName    = TextEditingController(text: _s('beneficiaryName'));
  late final TextEditingController _accNum      = TextEditingController(text: _s('accountNumber'));
  late final TextEditingController _ifsc        = TextEditingController(text: _s('ifscCode'));
  late final TextEditingController _upi         = TextEditingController(text: _s('upiId'));

  bool _saving = false;

  String _s(String key) => widget.biz[key] as String? ?? '';

  @override
  void dispose() {
    for (final c in [_bizName, _contactName, _phone, _email, _city, _state,
        _address, _pincode, _gst, _pan, _beneName, _accNum, _ifsc, _upi]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final name = _bizName.text.trim();
    if (name.length < 2) { showSnack(context, 'Business name required (min 2 chars)'); return; }
    setState(() => _saving = true);
    try {
      await ref.read(settingsProvider.notifier).updateBusinessDetails({
        'businessName': name,
        if (_contactName.text.trim().isNotEmpty) 'contactName': _contactName.text.trim(),
        if (_phone.text.trim().isNotEmpty)        'phone':       _phone.text.trim(),
        if (_email.text.trim().isNotEmpty)        'email':       _email.text.trim(),
        if (_city.text.trim().isNotEmpty)         'city':        _city.text.trim(),
        if (_state.text.trim().isNotEmpty)        'state':       _state.text.trim(),
        if (_address.text.trim().isNotEmpty)      'address':     _address.text.trim(),
        if (_pincode.text.trim().isNotEmpty)      'pincode':     _pincode.text.trim(),
        if (_gst.text.trim().isNotEmpty)          'gstNumber':   _gst.text.trim(),
        if (_pan.text.trim().isNotEmpty)          'panNumber':   _pan.text.trim(),
        if (_beneName.text.trim().isNotEmpty)     'beneficiaryName': _beneName.text.trim(),
        if (_accNum.text.trim().isNotEmpty)       'accountNumber':   _accNum.text.trim(),
        if (_ifsc.text.trim().isNotEmpty)         'ifscCode':        _ifsc.text.trim(),
        if (_upi.text.trim().isNotEmpty)          'upiId':           _upi.text.trim(),
      });
      if (mounted) showSnack(context, 'Saved');
    } catch (_) {
      if (mounted) showSnack(context, 'Failed to save. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        _label('Basic Info'),
        _field(_bizName,     'Business Name',   required: true),
        _field(_contactName, 'Contact Person'),
        _field(_phone,       'Contact Phone',   type: TextInputType.phone),
        _field(_email,       'Contact Email',   type: TextInputType.emailAddress),
        _label('Location'),
        Row(children: [
          Expanded(child: _field(_city,  'City')),
          const SizedBox(width: 12),
          Expanded(child: _field(_state, 'State')),
        ]),
        _field(_address, 'Address', maxLines: 2),
        _field(_pincode, 'Pincode', type: TextInputType.number,
               formatters: [FilteringTextInputFormatter.digitsOnly]),
        _label('Tax'),
        _field(_gst, 'GST Number', uppercase: true),
        _field(_pan, 'PAN Number', uppercase: true),
        _label('Banking'),
        _field(_beneName, 'Account Holder Name'),
        _field(_accNum,   'Account Number', type: TextInputType.number,
               formatters: [FilteringTextInputFormatter.digitsOnly]),
        _field(_ifsc, 'IFSC Code', uppercase: true),
        _field(_upi,  'UPI ID'),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Save Business Details'),
        ),
      ],
    );
  }
}

// ── Academy tab ───────────────────────────────────────────────────────────────

class _AcademyTab extends ConsumerStatefulWidget {
  const _AcademyTab();

  @override
  ConsumerState<_AcademyTab> createState() => _AcademyTabState();
}

class _AcademyTabState extends ConsumerState<_AcademyTab> {
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
      });
      if (mounted) showSnack(context, 'Saved');
    } catch (_) {
      if (mounted) showSnack(context, 'Failed to save. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            _label('Academy Info'),
            _field(_name!,    'Academy Name', required: true),
            _field(_tagline!, 'Tagline'),
            _field(_desc!,    'About Academy', maxLines: 3),
            _label('Contact'),
            _field(_phone!,   'Phone',   type: TextInputType.phone),
            _field(_email!,   'Email',   type: TextInputType.emailAddress),
            _field(_website!, 'Website', type: TextInputType.url),
            _label('Location'),
            _field(_address!, 'Address', maxLines: 2),
            Row(children: [
              Expanded(child: _field(_city!,  'City')),
              const SizedBox(width: 12),
              Expanded(child: _field(_state!, 'State')),
            ]),
            _field(_pincode!, 'Pincode',
                   type: TextInputType.number,
                   formatters: [FilteringTextInputFormatter.digitsOnly]),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _saving ? null : () => _save(academy.academyId),
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Academy'),
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

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue next) =>
      next.copyWith(text: next.text.toUpperCase());
}
