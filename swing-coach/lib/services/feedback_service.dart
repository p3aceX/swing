import 'package:flutter/foundation.dart';

@immutable
class PlayerFeedbackPayload {
  const PlayerFeedbackPayload({
    required this.playerId,
    required this.mistakes,
    required this.strengths,
    required this.performance,
  });

  final String playerId;
  final List<String> mistakes;
  final List<String> strengths;
  final String performance;

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'mistakes': mistakes,
    'strengths': strengths,
    'performance': performance,
  };
}

@immutable
class SessionFeedbackPayload {
  const SessionFeedbackPayload({
    required this.sessionId,
    required this.sessionType,
    required this.coachId,
    required this.players,
  });

  final String sessionId;
  final String sessionType;
  final String coachId;
  final List<PlayerFeedbackPayload> players;

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'sessionType': sessionType,
    'coachId': coachId,
    'players': players.map((entry) => entry.toJson()).toList(),
  };
}

Future<Map<String, dynamic>> submitFeedback(
  SessionFeedbackPayload payload, {
  Future<Map<String, dynamic>> Function(Map<String, dynamic> data)? apiSubmit,
}) async {
  final body = payload.toJson();
  if (apiSubmit != null) {
    try {
      return await apiSubmit(body);
    } catch (_) {
      // Keep frontend flow non-blocking until backend contract is stable.
    }
  }
  debugPrint('Mock Submit: $body');
  return Future.value({'success': true, 'mock': true});
}
