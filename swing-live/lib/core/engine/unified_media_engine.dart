import 'package:flutter/foundation.dart';
import 'media_source.dart';
import '../studio/web_dashboard_server.dart';

class UnifiedMediaEngine extends ChangeNotifier {
  final Map<String, MediaSource> _sources = {};
  String? _activeSourceId;
  WebDashboardServer? _controlServer;
  String? _dashboardUrl;

  List<MediaSource> get sources => _sources.values.toList();
  String? get activeSourceId => _activeSourceId;
  String? get dashboardUrl => _dashboardUrl;
  MediaSource? get activeSource => _activeSourceId != null ? _sources[_activeSourceId] : null;

  UnifiedMediaEngine() {
    _initControlServer();
  }

  Future<void> _initControlServer() async {
    _controlServer = WebDashboardServer(onCommandReceived: _handleWebCommand);
    _dashboardUrl = await _controlServer!.start();
    notifyListeners();
  }

  void _handleWebCommand(String command, dynamic data) {
    debugPrint("[ENGINE] Web Command: $command ($data)");
    switch (command) {
      case 'switch_camera':
        switchSource(data.toString());
        break;
      case 'mute_source':
        // Implement muting logic
        break;
      // Add more enterprise control commands here
    }
  }

  void addSource(MediaSource source) {
    _sources[source.id] = source;
    if (_activeSourceId == null) {
      _activeSourceId = source.id;
    }
    _broadcastStatus();
    notifyListeners();
  }

  void removeSource(String id) {
    _sources[id]?.disconnect();
    _sources.remove(id);
    if (_activeSourceId == id) {
      _activeSourceId = _sources.keys.firstOrNull;
    }
    _broadcastStatus();
    notifyListeners();
  }

  void switchSource(String id) {
    if (_sources.containsKey(id)) {
      _activeSourceId = id;
      _broadcastStatus();
      notifyListeners();
    }
  }

  void _broadcastStatus() {
    final status = {
      'activeSource': _activeSourceId,
      'sources': _sources.values.map((s) => s.getStatus()).toList(),
    };
    _controlServer?.broadcastStatus(status);
  }

  Future<void> shutdown() async {
    for (var source in _sources.values) {
      await source.disconnect();
    }
    await _controlServer?.stop();
  }
}
