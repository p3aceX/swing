import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/host_colors.dart';
import '../data/host_arena_review_repository.dart';
import '../domain/host_arena_review_models.dart';

/// Bottom-sheet that captures the captain's review of an arena after a
/// matchmaking match. Submit hits POST /matchmaking/matches/:matchId/review;
/// on success, [onSubmitted] fires and the caller pops the route.
///
/// The sheet is intentionally minimal — flat list of stars + tag chips +
/// optional comment. No card decorations, no shadows. Per the project's
/// edge-to-edge UI preference.
class HostArenaReviewSheet extends ConsumerStatefulWidget {
  const HostArenaReviewSheet({
    super.key,
    required this.matchId,
    required this.teamId,
    required this.arenaName,
    this.onSubmitted,
  });

  final String matchId;
  final String teamId;
  final String arenaName;

  /// Fired with the server's response after a successful submit. Caller
  /// typically pops the route + invalidates any rating-aware providers.
  final void Function(HostArenaReviewResult result)? onSubmitted;

  @override
  ConsumerState<HostArenaReviewSheet> createState() =>
      _HostArenaReviewSheetState();
}

// 6 positive + 6 negative tag slugs, in the order shown to the captain.
// Slugs match what the backend expects in Review.tags[].
const List<({String slug, String label, bool positive})> _tagOptions = [
  (slug: 'surface_good', label: 'Good surface', positive: true),
  (slug: 'parking_easy', label: 'Easy parking', positive: true),
  (slug: 'lights_bright', label: 'Bright lights', positive: true),
  (slug: 'washroom_clean', label: 'Clean washroom', positive: true),
  (slug: 'well_run', label: 'Well run', positive: true),
  (slug: 'good_pricing', label: 'Good pricing', positive: true),
  (slug: 'surface_bumpy', label: 'Bumpy surface', positive: false),
  (slug: 'parking_hard', label: 'Hard to park', positive: false),
  (slug: 'lights_dim', label: 'Dim lights', positive: false),
  (slug: 'washroom_dirty', label: 'Dirty washroom', positive: false),
  (slug: 'poor_facilities', label: 'Poor facilities', positive: false),
  (slug: 'overpriced', label: 'Overpriced', positive: false),
];

class _HostArenaReviewSheetState extends ConsumerState<HostArenaReviewSheet> {
  int _stars = 0;
  final Set<String> _tags = <String>{};
  final TextEditingController _comment = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars < 1) {
      setState(() => _error = 'Tap a star to rate the ground.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(hostArenaReviewRepositoryProvider);
      final result = await repo.submitReview(
        matchId: widget.matchId,
        teamId: widget.teamId,
        draft: HostArenaReviewDraft(
          stars: _stars,
          tags: _tags.toList(),
          comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
        ),
      );
      if (!mounted) return;
      widget.onSubmitted?.call(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not submit review. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: media.viewInsets.bottom,
        ),
        child: Container(
          width: double.infinity,
          color: context.bg,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: context.fgSub.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.center,
              ),
              Text(
                'Rate ${widget.arenaName}',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your captain review helps quieter, well-rated grounds get more matches.',
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 1; i <= 5; i++)
                    GestureDetector(
                      onTap: _busy ? null : () => setState(() => _stars = i),
                      child: Icon(
                        i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: i <= _stars ? context.gold : context.fgSub.withValues(alpha: 0.5),
                        size: 44,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'What stood out? (optional)',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final opt in _tagOptions)
                    _TagChip(
                      label: opt.label,
                      positive: opt.positive,
                      selected: _tags.contains(opt.slug),
                      onTap: _busy
                          ? null
                          : () => setState(() {
                                if (_tags.contains(opt.slug)) {
                                  _tags.remove(opt.slug);
                                } else {
                                  _tags.add(opt.slug);
                                }
                              }),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _comment,
                enabled: !_busy,
                maxLength: 500,
                maxLines: 3,
                minLines: 2,
                style: TextStyle(color: context.fg, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Anything else worth flagging? (optional)',
                  hintStyle: TextStyle(color: context.fgSub.withValues(alpha: 0.7)),
                  filled: true,
                  fillColor: context.panel,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  counterStyle: TextStyle(color: context.fgSub, fontSize: 11),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: context.danger, fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _busy ? null : () => Navigator.of(context).maybePop(),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _busy ? null : _submit,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _busy ? context.fgSub.withValues(alpha: 0.4) : context.ctaBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _busy
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation<Color>(context.ctaFg),
                                ),
                              )
                            : Text(
                                'Submit review',
                                style: TextStyle(
                                  color: context.ctaFg,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                    ),
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

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.positive,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool positive;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final base = positive ? context.success : context.danger;
    final bg = selected ? base.withValues(alpha: 0.18) : context.panel;
    final fg = selected ? base : context.fgSub;
    final stroke = selected ? base.withValues(alpha: 0.5) : Colors.transparent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: stroke, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
