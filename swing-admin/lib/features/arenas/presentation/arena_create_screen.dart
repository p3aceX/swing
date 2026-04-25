import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/arenas_repository.dart';

class ArenaCreateScreen extends ConsumerStatefulWidget {
  const ArenaCreateScreen({super.key});

  @override
  ConsumerState<ArenaCreateScreen> createState() => _ArenaCreateScreenState();
}

class _ArenaCreateScreenState extends ConsumerState<ArenaCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessName = TextEditingController();
  final _gstNumber = TextEditingController();
  final _panNumber = TextEditingController();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _phone = TextEditingController();
  final List<String> _photoUrls = [];
  final ImagePicker _picker = ImagePicker();
  final Set<String> _sports = {'CRICKET'};
  bool _saving = false;
  bool _uploadingPhotos = false;

  static const _sportsOptions = <String>[
    'CRICKET',
    'FUTSAL',
    'PICKLEBALL',
    'BADMINTON',
    'FOOTBALL',
    'OTHER',
  ];

  @override
  void dispose() {
    _businessName.dispose();
    _gstNumber.dispose();
    _panNumber.dispose();
    _name.dispose();
    _description.dispose();
    _address.dispose();
    _city.dispose();
    _state.dispose();
    _pincode.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.go('/arenas'),
                icon: const Icon(Icons.arrow_back, size: 18),
                tooltip: 'Back',
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Arena',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Create the venue, owner profile, and photos in one pass.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(_saving ? 'Saving' : 'Create'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                _section(
                  title: 'Owner profile',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _businessName,
                              decoration: const InputDecoration(
                                labelText: 'Business name',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _gstNumber,
                              decoration: const InputDecoration(
                                labelText: 'GST number',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _panNumber,
                        decoration: const InputDecoration(
                          labelText: 'PAN number',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _section(
                  title: 'Arena details',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _name,
                        validator: (value) =>
                            value == null || value.trim().length < 2
                            ? 'Arena name is required'
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Arena name',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _description,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _address,
                        decoration: const InputDecoration(labelText: 'Address'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _city,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'City is required'
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'City',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _state,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'State is required'
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'State',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pincode,
                              decoration: const InputDecoration(
                                labelText: 'Pincode',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latitude,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _longitude,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _section(
                  title: 'Sports',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final sport in _sportsOptions)
                        FilterChip(
                          label: Text(sport),
                          selected: _sports.contains(sport),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _sports.add(sport);
                              } else {
                                _sports.remove(sport);
                              }
                              if (_sports.isEmpty) {
                                _sports.add('CRICKET');
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _section(
                  title: 'Pictures',
                  subtitle:
                      'Upload arena photos from the device. The backend stores them in Supabase and saves the public URLs.',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _uploadingPhotos
                                ? null
                                : _pickArenaPhotos,
                            icon: _uploadingPhotos
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload, size: 18),
                            label: Text(
                              _uploadingPhotos ? 'Uploading' : 'Upload photos',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${_photoUrls.length} uploaded',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_photoUrls.isEmpty)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'No photos uploaded yet.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (var i = 0; i < _photoUrls.length; i++)
                              _PhotoPreviewCard(
                                url: _photoUrls[i],
                                onRemove: () =>
                                    setState(() => _photoUrls.removeAt(i)),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final payload = <String, dynamic>{
        if (_businessName.text.trim().isNotEmpty)
          'businessName': _businessName.text.trim(),
        if (_gstNumber.text.trim().isNotEmpty)
          'gstNumber': _gstNumber.text.trim(),
        if (_panNumber.text.trim().isNotEmpty)
          'panNumber': _panNumber.text.trim(),
        'name': _name.text.trim(),
        if (_description.text.trim().isNotEmpty)
          'description': _description.text.trim(),
        if (_address.text.trim().isNotEmpty) 'address': _address.text.trim(),
        'city': _city.text.trim(),
        'state': _state.text.trim(),
        if (_pincode.text.trim().isNotEmpty) 'pincode': _pincode.text.trim(),
        if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
        if (_latitude.text.trim().isNotEmpty)
          'latitude': double.parse(_latitude.text.trim()),
        if (_longitude.text.trim().isNotEmpty)
          'longitude': double.parse(_longitude.text.trim()),
        'sports': _sports.toList(),
      };
      final created = await ref
          .read(arenasRepositoryProvider)
          .createArena(payload);
      if (_photoUrls.isNotEmpty) {
        await ref.read(arenasRepositoryProvider).updateArenaAdmin(created.id, {
          'photoUrls': _photoUrls,
        });
      }
      ref.invalidate(arenasListProvider);
      if (!mounted) return;
      context.go('/arenas/${created.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _section({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Future<void> _pickArenaPhotos() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() => _uploadingPhotos = true);
    try {
      final repo = ref.read(arenasRepositoryProvider);
      final uploaded = <String>[];
      for (final file in picked) {
        final bytes = await file.readAsBytes();
        final url = await repo.uploadMedia(
          folder: 'arenas/new/photos',
          bytes: bytes,
          filename: file.name,
        );
        if (url.isNotEmpty) uploaded.add(url);
      }
      if (mounted) {
        setState(() => _photoUrls.addAll(uploaded));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _uploadingPhotos = false);
    }
  }
}

class _PhotoPreviewCard extends StatelessWidget {
  const _PhotoPreviewCard({required this.url, required this.onRemove});

  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Uploaded',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  tooltip: 'Remove',
                  icon: const Icon(Icons.close, size: 16),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
