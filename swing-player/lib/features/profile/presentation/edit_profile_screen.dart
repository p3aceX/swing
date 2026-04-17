import "package:cached_network_image/cached_network_image.dart";
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/storage/supabase_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/profile_controller.dart';
import '../data/profile_repository.dart';
import '../domain/profile_field_mappings.dart';
import '../domain/profile_models.dart';
import 'widgets/profile_section_card.dart';

enum _EditSection {
  identity,
  cricket,
  availability,
  privacy,
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.data,
  });

  final PlayerProfilePageData data;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static const _dayOptions = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  static const _timeOptions = [
    'EARLY_MORNING',
    'MORNING',
    'AFTERNOON',
    'EVENING',
    'NIGHT',
  ];

  static final _roleOptions =
      ProfileFieldMappings.dropdownItems(ProfileFieldKey.role);

  static final _battingOptions =
      ProfileFieldMappings.dropdownItems(ProfileFieldKey.battingStyle);

  static const _genderOptions = {
    'MALE': 'Male',
    'FEMALE': 'Female',
    'OTHER': 'Other',
  };

  static final _bowlingOptions =
      ProfileFieldMappings.dropdownItems(ProfileFieldKey.bowlingStyle);

  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _dobController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _jerseyController;
  late final TextEditingController _bioController;

  late String? _gender;
  late String? _playerRole;
  late String? _battingStyle;
  late String? _bowlingStyle;
  late String? _level;
  late List<String> _availableDays;
  late List<String> _preferredTimes;
  late double _locationRadius;
  late bool _isPublic;
  late bool _showStats;
  late bool _showLocation;
  late bool _scoutingOptIn;

  final _imagePicker = ImagePicker();
  final _storage = SupabaseStorageService();

  _EditSection? _savingSection;
  Timer? _citySearchDebounce;
  List<CitySuggestion> _citySuggestions = const [];
  CitySuggestion? _selectedCity;
  bool _isSearchingCities = false;
  String? _citySearchError;
  bool _isApplyingCitySelection = false;
  bool _isUpdatingAvatar = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final editable = widget.data.editableProfile;
    _nameController = TextEditingController(text: editable.name ?? '');
    _usernameController = TextEditingController(text: editable.username ?? '');
    _dobController = TextEditingController(text: editable.dateOfBirth ?? '');
    _cityController = TextEditingController(text: editable.city);
    _stateController = TextEditingController(text: editable.state);
    _jerseyController = TextEditingController(
      text: editable.jerseyNumber?.toString() ?? '',
    );
    _bioController = TextEditingController(text: editable.bio);
    _gender = editable.gender;
    _playerRole = editable.playerRole;
    _battingStyle = editable.battingStyle;
    _bowlingStyle = editable.bowlingStyle;
    _level = editable.level;
    _availableDays = [...?editable.availableDays];
    _preferredTimes = [...?editable.preferredTimes];
    _locationRadius = (editable.locationRadius ?? 10).toDouble();
    _isPublic = editable.isPublic ?? true;
    _showStats = editable.showStats ?? true;
    _showLocation = editable.showLocation ?? false;
    _scoutingOptIn = editable.scoutingOptIn ?? false;
    _avatarUrl = widget.data.identity.avatarUrl;
    final editableCity = editable.city?.trim() ?? '';
    final editableState = editable.state?.trim() ?? '';
    if (editableCity.isNotEmpty && editableState.isNotEmpty) {
      _selectedCity = CitySuggestion(
        city: editableCity,
        state: editableState,
      );
    }
    _cityController.addListener(_onCityChanged);
  }

  @override
  void dispose() {
    _citySearchDebounce?.cancel();
    _cityController.removeListener(_onCityChanged);
    _nameController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _jerseyController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final identity = widget.data.identity;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          title: const Text('Profile Studio'),
          backgroundColor: context.bg,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeroEditorCard(
                  fullName: identity.fullName,
                  swingId: identity.swingId,
                  avatarUrl: _avatarUrl,
                  isUpdatingAvatar: _isUpdatingAvatar,
                  onUpdateAvatar: _pickAndUploadAvatar,
                ),
                const SizedBox(height: 16),
                const _EditTabs(),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildIdentityTab(),
                      _buildCricketTab(),
                      _buildAvailabilityTab(),
                      _buildPrivacyTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityTab() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        ProfileSectionCard(
          title: 'Identity',
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  hintText: 'Enter your full name',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Choose a username',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Date of birth',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
              ),
              const SizedBox(height: 14),
              _DropdownField(
                label: 'Gender',
                value: _gender,
                items: _genderOptions,
                onChanged: (value) => setState(() => _gender = value),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _jerseyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jersey Number',
                  hintText: 'Enter your jersey number',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _cityController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'City',
                  hintText: 'Search and select your city',
                  suffixIcon: _isSearchingCities
                      ? Padding(
                          padding: const EdgeInsets.all(14),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.fgSub,
                            ),
                          ),
                        )
                      : (_cityController.text.trim().isNotEmpty
                          ? IconButton(
                              onPressed: _clearCitySelection,
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null),
                ),
              ),
              if (_citySearchError != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _citySearchError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (_citySuggestions.isNotEmpty) ...[
                const SizedBox(height: 10),
                _CitySuggestionsList(
                  suggestions: _citySuggestions,
                  onSelected: _selectCitySuggestion,
                ),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: _stateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'State',
                  hintText: 'Filled automatically after city selection',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionSaveButton(
          label: 'Save',
          saving: _savingSection == _EditSection.identity,
          onPressed: () => _saveSection(_EditSection.identity),
        ),
      ],
    );
  }

  Widget _buildCricketTab() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        ProfileSectionCard(
          title: 'Cricket Profile',
          child: Column(
            children: [
              if (widget.data.academy.isLinked) ...[
                _StaticField(
                  icon: Icons.school_outlined,
                  label: 'Academy',
                  value: widget.data.academy.academyName ?? 'Academy linked',
                ),
                const SizedBox(height: 14),
              ],
              _DropdownField(
                label: 'Primary role',
                value: _playerRole,
                items: _roleOptions,
                onChanged: (value) => setState(() => _playerRole = value),
              ),
              const SizedBox(height: 14),
              _DropdownField(
                label: 'Batting style',
                value: _battingStyle,
                items: _battingOptions,
                onChanged: (value) => setState(() => _battingStyle = value),
              ),
              const SizedBox(height: 14),
              _DropdownField(
                label: 'Bowling style',
                value: _bowlingStyle,
                items: _bowlingOptions,
                onChanged: (value) => setState(() => _bowlingStyle = value),
              ),
              const SizedBox(height: 14),
              _DropdownField(
                label: 'Playing circuit',
                value: _level,
                items: _levelOptions(),
                onChanged: (value) => setState(() => _level = value),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Short player identity or cricket summary',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionSaveButton(
          label: 'Save',
          saving: _savingSection == _EditSection.cricket,
          onPressed: () => _saveSection(_EditSection.cricket),
        ),
      ],
    );
  }

  Widget _buildAvailabilityTab() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        ProfileSectionCard(
          title: 'Availability',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChipGroup(
                label: 'Available days',
                options: _mergedOptions(_dayOptions, _availableDays),
                selected: _availableDays,
                onToggle: (value) => _toggleValue(_availableDays, value),
              ),
              const SizedBox(height: 18),
              _ChipGroup(
                label: 'Preferred times',
                options: _mergedOptions(_timeOptions, _preferredTimes),
                selected: _preferredTimes,
                onToggle: (value) => _toggleValue(_preferredTimes, value),
                labelBuilder: _displayTimeOption,
              ),
              const SizedBox(height: 18),
              Text(
                'Match radius',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _locationRadius,
                      min: 1,
                      max: 100,
                      divisions: 99,
                      label: '${_locationRadius.round()} km',
                      onChanged: (value) =>
                          setState(() => _locationRadius = value),
                    ),
                  ),
                  Text(
                    '${_locationRadius.round()} km',
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionSaveButton(
          label: 'Save',
          saving: _savingSection == _EditSection.availability,
          onPressed: () => _saveSection(_EditSection.availability),
        ),
      ],
    );
  }

  Widget _buildPrivacyTab() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        ProfileSectionCard(
          title: 'Privacy & Visibility',
          child: Column(
            children: [
              _SwitchRow(
                icon: Icons.public_rounded,
                title: 'Public profile',
                subtitle: 'Allow your profile card to be publicly visible.',
                value: _isPublic,
                onChanged: (value) => setState(() => _isPublic = value),
              ),
              _SwitchRow(
                icon: Icons.bar_chart_rounded,
                title: 'Show stats',
                subtitle: 'Share batting, bowling, and fielding numbers.',
                value: _showStats,
                onChanged: (value) => setState(() => _showStats = value),
              ),
              _SwitchRow(
                icon: Icons.location_on_outlined,
                title: 'Show location',
                subtitle: 'Surface your city/state in your public profile.',
                value: _showLocation,
                onChanged: (value) => setState(() => _showLocation = value),
              ),
              _SwitchRow(
                icon: Icons.visibility_outlined,
                title: 'Scouting opt-in',
                subtitle: 'Let selectors discover your profile.',
                value: _scoutingOptIn,
                onChanged: (value) => setState(() => _scoutingOptIn = value),
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionSaveButton(
          label: 'Save',
          saving: _savingSection == _EditSection.privacy,
          onPressed: () => _saveSection(_EditSection.privacy),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_dobController.text) ??
        DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    _dobController.text = '${picked.year}-$month-$day';
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (pickedFile == null) return;

      final uploadFile = await _resolveAvatarUploadFile(pickedFile);
      if (uploadFile == null) return;

      if (!mounted) return;
      setState(() => _isUpdatingAvatar = true);

      final storageUrl = await _storage.uploadUserProfileImage(
        userId: widget.data.identity.id,
        file: uploadFile,
      );
      final savedUrl =
          await ref.read(profileRepositoryProvider).updateAvatar(storageUrl);
      if ((_avatarUrl ?? '').trim().isNotEmpty) {
        await CachedNetworkImageProvider(_avatarUrl!).evict();
      }
      await CachedNetworkImageProvider(savedUrl).evict();
      ref.read(profileControllerProvider.notifier).patchAvatar(savedUrl);

      if (!mounted) return;
      setState(() {
        _avatarUrl = savedUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingAvatar = false);
      }
    }
  }

  Future<XFile?> _resolveAvatarUploadFile(XFile pickedFile) async {
    if (Platform.isAndroid) {
      // Native cropper is unstable in this Android app setup right now.
      // Keep uploads working instead of crashing the profile flow.
      return pickedFile;
    }

    final primaryColor = Theme.of(context).colorScheme.primary;
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 92,
      uiSettings: [
        IOSUiSettings(
          title: 'Crop Profile Picture',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          rotateButtonsHidden: false,
          rotateClockwiseButtonHidden: false,
        ),
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Picture',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: primaryColor,
          statusBarLight: false,
          backgroundColor: Colors.black,
          cropFrameColor: Colors.white,
          cropGridColor: Colors.white24,
          lockAspectRatio: true,
          hideBottomControls: false,
          initAspectRatio: CropAspectRatioPreset.square,
        ),
      ],
    );
    if (croppedFile == null) return null;
    return XFile(croppedFile.path);
  }

  void _onCityChanged() {
    if (_isApplyingCitySelection) return;

    final query = _cityController.text.trim();
    final selected = _selectedCity;
    if (selected != null &&
        query.toLowerCase() == selected.city.trim().toLowerCase()) {
      return;
    }

    _selectedCity = null;
    if (_stateController.text.isNotEmpty) {
      _stateController.clear();
    }

    _citySearchDebounce?.cancel();
    if (query.length < 2) {
      if (_citySuggestions.isNotEmpty ||
          _isSearchingCities ||
          _citySearchError != null) {
        setState(() {
          _citySuggestions = const [];
          _isSearchingCities = false;
          _citySearchError = null;
        });
      }
      return;
    }

    setState(() {
      _isSearchingCities = true;
      _citySearchError = null;
    });

    _citySearchDebounce = Timer(
      const Duration(milliseconds: 250),
      () => _searchCities(query),
    );
  }

  Future<void> _searchCities(String query) async {
    try {
      final suggestions =
          await ref.read(profileRepositoryProvider).searchCities(query);
      if (!mounted || _cityController.text.trim() != query.trim()) return;
      setState(() {
        _citySuggestions = suggestions;
        _isSearchingCities = false;
        _citySearchError =
            suggestions.isEmpty ? 'No matching cities found.' : null;
      });
    } catch (_) {
      if (!mounted || _cityController.text.trim() != query.trim()) return;
      setState(() {
        _citySuggestions = const [];
        _isSearchingCities = false;
        _citySearchError = 'Could not load cities right now.';
      });
    }
  }

  void _selectCitySuggestion(CitySuggestion suggestion) {
    _citySearchDebounce?.cancel();
    _isApplyingCitySelection = true;
    _selectedCity = suggestion;
    _cityController.text = suggestion.city;
    _stateController.text = suggestion.state;
    _cityController.selection = TextSelection.collapsed(
      offset: _cityController.text.length,
    );
    _isApplyingCitySelection = false;
    FocusScope.of(context).unfocus();
    setState(() {
      _citySuggestions = const [];
      _isSearchingCities = false;
      _citySearchError = null;
    });
  }

  void _clearCitySelection() {
    _citySearchDebounce?.cancel();
    _selectedCity = null;
    _cityController.clear();
    _stateController.clear();
    setState(() {
      _citySuggestions = const [];
      _isSearchingCities = false;
      _citySearchError = null;
    });
  }

  void _toggleValue(List<String> current, String value) {
    setState(() {
      if (current.contains(value)) {
        current.remove(value);
      } else {
        current.add(value);
      }
    });
  }

  List<String> _mergedOptions(List<String> base, List<String> selected) {
    final merged = [...base];
    for (final item in selected) {
      if (!merged.contains(item)) {
        merged.add(item);
      }
    }
    return merged;
  }

  String _displayTimeOption(String value) {
    return switch (value) {
      'EARLY_MORNING' => 'Early Morning',
      'MORNING' => 'Morning',
      'AFTERNOON' => 'Afternoon',
      'EVENING' => 'Evening',
      'NIGHT' => 'Night',
      _ => value.replaceAll('_', ' '),
    };
  }

  Future<void> _saveSection(_EditSection section) async {
    setState(() {
      _savingSection = section;
    });

    late final PlayerProfileUpdateRequest request;
    switch (section) {
      case _EditSection.identity:
        final name = _nameController.text.trim();
        final jerseyText = _jerseyController.text.trim();
        final jerseyNumber = jerseyText.isEmpty ? null : int.tryParse(jerseyText);
        if (name.isEmpty) throw Exception('Name cannot be empty.');
        if (jerseyText.isNotEmpty && jerseyNumber == null) {
          throw Exception('Jersey number must be a whole number between 0 and 999.');
        }
        if (jerseyNumber != null && (jerseyNumber < 0 || jerseyNumber > 999)) {
          throw Exception('Jersey number must be between 0 and 999.');
        }
        request = PlayerProfileUpdateRequest(
          name: name,
          username: _usernameController.text.trim().isEmpty
              ? null
              : _usernameController.text.trim(),
          dateOfBirth: _dobController.text.trim().isEmpty
              ? null
              : _dobController.text.trim(),
          gender: _gender,
          city: _cityController.text,
          state: _stateController.text,
          jerseyNumber: jerseyNumber,
          includeJerseyNumber: true,
          avatarUrl: _avatarUrl,
        );
      case _EditSection.cricket:
        request = PlayerProfileUpdateRequest(
          avatarUrl: _avatarUrl,
          playerRole: _playerRole,
          battingStyle: _battingStyle,
          bowlingStyle: _bowlingStyle,
          level: _level,
          bio: _bioController.text,
        );
      case _EditSection.availability:
        request = PlayerProfileUpdateRequest(
          avatarUrl: _avatarUrl,
          availableDays: _availableDays,
          preferredTimes: _preferredTimes,
          locationRadius: _locationRadius.round(),
        );
      case _EditSection.privacy:
        request = PlayerProfileUpdateRequest(
          avatarUrl: _avatarUrl,
          isPublic: _isPublic,
          showStats: _showStats,
          showLocation: _showLocation,
          scoutingOptIn: _scoutingOptIn,
        );
    }

    try {
      if (section == _EditSection.identity) {
        final city = _cityController.text.trim();
        final state = _stateController.text.trim();
        if (city.isNotEmpty && state.isEmpty) {
          throw Exception('Select a city suggestion so state can be filled.');
        }
      }
      await ref.read(profileRepositoryProvider).updateProfile(request);
      await ref.read(profileControllerProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_labelForSection(section)} saved')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _savingSection = null);
      }
    }
  }

  String _labelForSection(_EditSection section) {
    return switch (section) {
      _EditSection.identity => 'Identity',
      _EditSection.cricket => 'Cricket profile',
      _EditSection.availability => 'Availability',
      _EditSection.privacy => 'Visibility settings',
    };
  }

  Map<String, String> _levelOptions() {
    return ProfileFieldMappings.dropdownItems(ProfileFieldKey.level);
  }
}

class _ProfileHeroEditorCard extends StatelessWidget {
  const _ProfileHeroEditorCard({
    required this.fullName,
    required this.swingId,
    required this.avatarUrl,
    required this.isUpdatingAvatar,
    required this.onUpdateAvatar,
  });

  final String fullName;
  final String swingId;
  final String? avatarUrl;
  final bool isUpdatingAvatar;
  final VoidCallback onUpdateAvatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: context.panel,
                backgroundImage:
                    avatarUrl != null && avatarUrl!.trim().isNotEmpty
                        ? CachedNetworkImageProvider(avatarUrl!)
                        : null,
                child: avatarUrl == null || avatarUrl!.trim().isEmpty
                    ? Icon(Icons.person_rounded, color: context.fgSub, size: 30)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@$swingId',
                      style: TextStyle(
                        color: context.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: isUpdatingAvatar ? null : onUpdateAvatar,
            icon: isUpdatingAvatar
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.accent,
                    ),
                  )
                : const Icon(Icons.camera_alt_outlined),
            label:
                Text(isUpdatingAvatar ? 'Uploading...' : 'Change Profile Photo'),
          ),
        ],
      ),
    );
  }
}

class _EditTabs extends StatelessWidget {
  const _EditTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.stroke),
      ),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: context.accentBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.accent.withValues(alpha: 0.25)),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        tabs: const [
          Tab(
              icon: Icon(Icons.person_outline_rounded, size: 18),
              text: 'Identity'),
          Tab(
              icon: Icon(Icons.sports_cricket_rounded, size: 18),
              text: 'Cricket'),
          Tab(
              icon: Icon(Icons.schedule_rounded, size: 18),
              text: 'Availability'),
          Tab(icon: Icon(Icons.visibility_outlined, size: 18), text: 'Privacy'),
        ],
      ),
    );
  }
}

class _SectionSaveButton extends StatelessWidget {
  const _SectionSaveButton({
    required this.label,
    required this.saving,
    required this.onPressed,
  });

  final String label;
  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: saving ? null : onPressed,
        icon: saving
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : const Icon(Icons.check_rounded),
        label: Text(saving ? 'Saving' : label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _CitySuggestionsList extends StatelessWidget {
  const _CitySuggestionsList({
    required this.suggestions,
    required this.onSelected,
  });

  final List<CitySuggestion> suggestions;
  final ValueChanged<CitySuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        children: [
          for (var index = 0; index < suggestions.length; index++) ...[
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onSelected(suggestions[index]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_city_rounded, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestions[index].city,
                              style: TextStyle(
                                color: context.fg,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              suggestions[index].state,
                              style: TextStyle(
                                color: context.fgSub,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (index != suggestions.length - 1)
              Divider(height: 1, color: context.stroke),
          ],
        ],
      ),
    );
  }
}

class _StaticField extends StatelessWidget {
  const _StaticField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: items.containsKey(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items.entries
          .map(
            (entry) => DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.label,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.labelBuilder,
  });

  final String label;
  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final String Function(String value)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.fg,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              selected: isSelected,
              label: Text(labelBuilder?.call(option) ?? option),
              onSelected: (_) => onToggle(option),
              showCheckmark: false,
              selectedColor: context.accentBg,
              backgroundColor: context.panel,
              side: BorderSide(
                color: isSelected
                    ? context.accent.withValues(alpha: 0.35)
                    : context.stroke,
              ),
              labelStyle: TextStyle(
                color: isSelected ? context.accent : context.fg,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
      decoration: BoxDecoration(
        border:
            isLast ? null : Border(bottom: BorderSide(color: context.stroke)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.panel,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 18, color: context.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
