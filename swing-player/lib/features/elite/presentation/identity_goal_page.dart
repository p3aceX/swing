import "package:cached_network_image/cached_network_image.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/presentation/edit_profile_screen.dart';
import '../../../core/storage/goal_storage.dart';
import '../controller/elite_controller.dart';
import '../domain/elite_models.dart';

class IdentityAndGoalDefinitionPage extends ConsumerStatefulWidget {
  const IdentityAndGoalDefinitionPage({super.key});

  @override
  ConsumerState<IdentityAndGoalDefinitionPage> createState() =>
      _IdentityAndGoalDefinitionPageState();
}

class _IdentityAndGoalDefinitionPageState
    extends ConsumerState<IdentityAndGoalDefinitionPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Goal State
  String? _targetRole;
  String? _targetFormat;
  String? _targetLevel;
  String? _timeline;
  String _styleIdentity = '';
  final List<String> _selectedFocusAreas = [];
  String _commitmentStatement = '';

  final TextEditingController _styleCtrl = TextEditingController();
  final TextEditingController _commitmentCtrl = TextEditingController();

  final List<String> _roles = ['Batsman', 'Bowler', 'All-rounder', 'Wicket-keeper'];
  final List<String> _formats = ['T20', 'ODI', 'Test', 'All formats'];
  final List<String> _levels = ['Corporate', 'Club', 'District', 'State', 'National'];
  final List<String> _timelines = ['3 months', '6 months', '12 months', '2+ years'];
  final List<String> _focusOptions = ['Batting avg', 'Strike rate', 'Bowling economy', 'Fitness', 'Mental strength', 'Fielding'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Prefer memory cache, then network profile.
      final goal = ref.read(goalCacheProvider) ??
          ref.read(eliteProfileProvider).value?.goal ??
          ref.read(goalPersistedProvider).value;
      if (goal != null) {
        setState(() {
          _targetRole = goal.targetRole;
          _targetFormat = goal.targetFormat;
          _targetLevel = goal.targetLevel;
          _timeline = goal.timeline;
          _styleIdentity = goal.styleIdentity;
          _styleCtrl.text = _styleIdentity;
          _selectedFocusAreas.addAll(goal.focusAreas);
          _commitmentStatement = goal.commitmentStatement;
          _commitmentCtrl.text = _commitmentStatement;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _styleCtrl.dispose();
    _commitmentCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < 7) {
      _pageController.nextPage(duration: 300.ms, curve: Curves.easeOut);
    } else {
      _save();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: 300.ms, curve: Curves.easeOut);
    }
  }

  Future<void> _save() async {
    final goal = ApexGoal(
      targetRole: _targetRole ?? '',
      targetFormat: _targetFormat ?? '',
      styleIdentity: _styleCtrl.text,
      targetLevel: _targetLevel ?? '',
      timeline: _timeline ?? '',
      focusAreas: _selectedFocusAreas,
      selfAssessment: {},
      commitmentStatement: _commitmentCtrl.text,
    );

    await ref.read(apexGoalControllerProvider.notifier).save(goal);
    if (mounted) {
      final state = ref.read(apexGoalControllerProvider);
      if (!state.hasError) {
        // Persist to memory (tab switches) and disk (app restarts).
        ref.read(goalCacheProvider.notifier).state = goal;
        await GoalStorage.save(goal);
        ref.invalidate(eliteProfileProvider);
        if (mounted) context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileData = ref.watch(profileControllerProvider).data;
    if (profileData == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: _ProgressDots(current: _currentStep, total: 8),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (idx) => setState(() => _currentStep = idx),
        children: [
          _buildStep(
            title: 'Your Identity',
            subtitle: 'Start with who you are today.',
            child: _IdentitySnapshot(
              identity: profileData.identity,
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EditProfileScreen(data: profileData)),
              ),
            ),
          ),
          _buildStep(
            title: 'Primary Role',
            subtitle: 'What do you want to be?',
            child: _OptionGrid(
              options: _roles,
              selected: _targetRole,
              onSelect: (v) => setState(() => _targetRole = v),
            ),
          ),
          _buildStep(
            title: 'Target Format',
            subtitle: 'Which format are you aiming for?',
            child: _OptionGrid(
              options: _formats,
              selected: _targetFormat,
              onSelect: (v) => setState(() => _targetFormat = v),
            ),
          ),
          _buildStep(
            title: 'Dream Level',
            subtitle: 'How high do you want to go?',
            child: _OptionGrid(
              options: _levels,
              selected: _targetLevel,
              onSelect: (v) => setState(() => _targetLevel = v),
            ),
          ),
          _buildStep(
            title: 'Timeline',
            subtitle: 'When do you expect to reach this?',
            child: _OptionGrid(
              options: _timelines,
              selected: _timeline,
              onSelect: (v) => setState(() => _timeline = v),
            ),
          ),
          _buildStep(
            title: 'Style Identity',
            subtitle: 'Describe your professional style',
            child: _TextFieldStep(
              controller: _styleCtrl,
              hint: 'e.g. Aggressive opener who dominates powerplay',
            ),
          ),
          _buildStep(
            title: 'Focus Areas',
            subtitle: 'What are your top priorities?',
            child: _MultiSelectGrid(
              options: _focusOptions,
              selected: _selectedFocusAreas,
              onToggle: (v) {
                setState(() {
                  if (_selectedFocusAreas.contains(v)) _selectedFocusAreas.remove(v);
                  else _selectedFocusAreas.add(v);
                });
              },
            ),
          ),
          _buildStep(
            title: 'Commitment',
            subtitle: "Let's be honest... write your statement",
            child: _TextFieldStep(
              controller: _commitmentCtrl,
              hint: 'I am committed to...',
              maxLines: 5,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              if (_currentStep > 0)
                _NavButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: _back,
                  isPrimary: false,
                ),
              if (_currentStep > 0) const SizedBox(width: 16),
              Expanded(
                child: _NavButton(
                  label: _currentStep == 6 ? 'SECURE MY PATH' : 'CONTINUE',
                  onTap: _next,
                  isPrimary: true,
                  isLoading: ref.watch(apexGoalControllerProvider).isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({required String title, required String subtitle, required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: context.fgSub, fontSize: 16, fontWeight: FontWeight.w500)).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 48),
          child.animate().fadeIn(delay: 200.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _IdentitySnapshot extends StatelessWidget {
  final dynamic identity; // Using dynamic to avoid strict type error if import is slow
  final VoidCallback onEdit;
  const _IdentitySnapshot({required this.identity, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: context.cardBg, borderRadius: BorderRadius.circular(32), border: Border.all(color: context.stroke)),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 24, backgroundImage: identity.avatarUrl != null ? CachedNetworkImageProvider(identity.avatarUrl!) : null, backgroundColor: context.bg),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(identity.fullName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    Text(identity.primaryRole.replaceAll('_', ' '), style: TextStyle(color: context.fgSub, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              TextButton(
                onPressed: onEdit, 
                style: TextButton.styleFrom(backgroundColor: context.accent.withValues(alpha: 0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('EDIT', style: TextStyle(color: context.accent, fontWeight: FontWeight.w900, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionGrid extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _OptionGrid({required this.options, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((o) {
        final isSel = selected == o;
        return GestureDetector(
          onTap: () => onSelect(o),
          child: AnimatedContainer(
            duration: 200.ms,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isSel ? context.accent : context.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isSel ? context.accent : context.stroke, width: 1.5),
            ),
            child: Row(
              children: [
                Text(o, style: TextStyle(color: isSel ? Colors.white : context.fg, fontWeight: FontWeight.w900, fontSize: 16)),
                const Spacer(),
                if (isSel) const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 24),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MultiSelectGrid extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  const _MultiSelectGrid({required this.options, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((o) {
        final isSel = selected.contains(o);
        return GestureDetector(
          onTap: () => onToggle(o),
          child: AnimatedContainer(
            duration: 200.ms,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isSel ? context.accent : context.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSel ? context.accent : context.stroke),
            ),
            child: Text(o, style: TextStyle(color: isSel ? Colors.white : context.fg, fontWeight: FontWeight.w800, fontSize: 14)),
          ),
        );
      }).toList(),
    );
  }
}

class _TextFieldStep extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _TextFieldStep({required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.fgSub.withValues(alpha: 0.3)),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isLoading;
  const _NavButton({this.label, this.icon, required this.onTap, this.isPrimary = true, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (!isPrimary) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: context.cardBg, shape: BoxShape.circle, border: Border.all(color: context.stroke)),
          child: Icon(icon, size: 20, color: context.fg),
        ),
      );
    }
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      child: isLoading 
        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
        : Text(label!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressDots({required this.current, required this.total});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) => Container(
        width: i == current ? 20 : 6,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(color: i <= current ? context.accent : context.stroke, borderRadius: BorderRadius.circular(2)),
      )),
    );
  }
}
