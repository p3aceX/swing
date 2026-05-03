import 'package:flutter/foundation.dart';

@immutable
class SessionFeedbackTemplate {
  const SessionFeedbackTemplate({
    required this.mistakes,
    required this.strengths,
    required this.performance,
  });

  final List<String> mistakes;
  final List<String> strengths;
  final List<String> performance;
}

const Map<String, SessionFeedbackTemplate> sessionFeedbackConfig = {
  'nets_batting': SessionFeedbackTemplate(
    mistakes: ['footwork', 'late_shot', 'poor_defense', 'shot_selection', 'balance_issue'],
    strengths: ['timing', 'shot_selection', 'placement', 'confidence', 'power_hitting'],
    performance: ['poor', 'average', 'good', 'excellent'],
  ),
  'nets_bowling': SessionFeedbackTemplate(
    mistakes: ['line_length', 'no_ball', 'wide_ball', 'pace_control', 'variation_missing'],
    strengths: ['accuracy', 'swing', 'variation', 'consistency', 'speed'],
    performance: ['poor', 'average', 'good', 'excellent'],
  ),
  'fielding': SessionFeedbackTemplate(
    mistakes: ['slow_reaction', 'misfield', 'poor_throw', 'bad_positioning', 'drop_catch'],
    strengths: ['quick_reaction', 'safe_hands', 'strong_throw', 'good_positioning', 'agility'],
    performance: ['poor', 'average', 'good', 'excellent'],
  ),
  'fitness': SessionFeedbackTemplate(
    mistakes: ['low_stamina', 'poor_form', 'slow_speed', 'low_strength', 'fatigue'],
    strengths: ['endurance', 'strength', 'speed', 'flexibility', 'discipline'],
    performance: ['poor', 'average', 'good', 'excellent'],
  ),
  'drills': SessionFeedbackTemplate(
    mistakes: ['execution_error', 'lack_focus', 'wrong_technique', 'slow_response'],
    strengths: ['good_execution', 'focus', 'quick_learning', 'consistency'],
    performance: ['poor', 'average', 'good', 'excellent'],
  ),
};

SessionFeedbackTemplate resolveSessionFeedbackTemplate(
  String sessionType, {
  Map<String, SessionFeedbackTemplate>? academyOverride,
}) {
  final normalized = sessionType.trim().toLowerCase();
  final override = academyOverride?[normalized];
  if (override != null) return override;
  return sessionFeedbackConfig[normalized] ?? sessionFeedbackConfig['drills']!;
}
