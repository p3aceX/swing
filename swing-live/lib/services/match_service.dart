import '../models/match.dart';

class MatchService {
  // Mock API call to /player/matches
  Future<List<MatchModel>> fetchMatches() async {
    // In a real app, this would use Dio/Http to call your backend
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      MatchModel(
        id: "cmox8z8zy006210lqt9rahmqr",
        title: "Swing vs AKCT - 11",
        lifecycle: MatchLifecycle.live,
        swingId: "SW-001",
        swingPass: "PASS123",
        startTime: DateTime.now(),
      ),
      MatchModel(
        id: "cmoycfyhj000qit3y7mmp27e2",
        title: "Upcoming 1-2 Booking",
        lifecycle: MatchLifecycle.upcoming,
        swingId: "SW-002",
        swingPass: "PASS456",
        startTime: DateTime.now().add(const Duration(hours: 2)),
      ),
    ];
  }
}
