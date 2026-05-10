import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/material.dart';
import '../p2p/p2p_signaling.dart';
import '../node/studio_node.dart';
import 'package:uuid/uuid.dart';
import 'package:nsd/nsd.dart';
import 'web_dashboard_server.dart';

class P2PStudioManager extends ChangeNotifier {
  final Map<String, RTCPeerConnection> _connections = {};
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  final List<StudioNode> _availableNodes = [];
  
  P2PSignaling? _signaling;
  WebDashboardServer? _webServer;
  String? _dashboardUrl;
  String? _localId;
  bool _isStudio = false;
  Registration? _registration;

  String? _password;

  List<StudioNode> get availableNodes => _availableNodes;
  Map<String, RTCVideoRenderer> get remoteRenderers => _remoteRenderers;
  bool get isStudio => _isStudio;
  String? get dashboardUrl => _dashboardUrl;

  P2PStudioManager() {
    _localId = const Uuid().v4();
  }

  // Start as the Master Studio
  Future<void> startStudio(String name, {String? password}) async {
    // Shutdown existing if any
    await _webServer?.stop();
    await _signaling?.dispose();
    
    _isStudio = true;
    _password = password;
    
    // 1. Start Signaling for P2P
    _signaling = P2PSignaling(onMessage: _handleSignalingMessage);
    int port = await _signaling!.host();
    
    // 2. Start Web Dashboard for Chrome control
    _webServer = WebDashboardServer(onCommandReceived: (cmd, data) {
      debugPrint("[WEB_COMMAND] $cmd : $data");
      // Handle commands like 'switch' or 'overlay' here
    });
    _dashboardUrl = await _webServer!.start();
    
    // 3. Register service for local discovery
    _registration = await register(
      Service(
        name: name,
        type: '_swing-live._tcp',
        port: port,
      ),
    );
    
    notifyListeners();
  }

  // Discover and Connect to a Studio
  Future<void> discoverStudios() async {
    final discovery = await startDiscovery('_swing-live._tcp');
    discovery.addListener(() {
      for (final service in discovery.services) {
        _addNodeFromService(service);
      }
    });
  }

  // Connect to a Studio as a Camera Node
  Future<void> connectToStudio(StudioNode node, {String? password}) async {
    if (node.ipAddress == null || node.port == null) return;
    
    _signaling = P2PSignaling(onMessage: _handleSignalingMessage);
    _signaling!.connect(node.ipAddress!, node.port!);
    
    // Create connection and send offer
    final pc = await createPeerConnection({
      'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}]
    });
    
    _connections[node.id] = pc;
    
    // Add local stream
    final stream = await navigator.mediaDevices.getUserMedia({'video': true, 'audio': true});
    stream.getTracks().forEach((track) => pc.addTrack(track, stream));

    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    _signaling!.send({
      'type': 'offer',
      'fromId': _localId,
      'name': 'Remote Phone',
      'password': password,
      'sdp': offer.sdp,
    });
  }

  void _addNodeFromService(Service service) {
    final node = StudioNode(
      id: service.name ?? 'unknown',
      name: service.name ?? 'Camera',
      type: NodeType.studio,
      ipAddress: service.host,
      port: service.port,
      lastSeen: DateTime.now(),
    );
    
    if (!_availableNodes.any((n) => n.id == node.id)) {
      _availableNodes.add(node);
      notifyListeners();
    }
  }

  void _handleSignalingMessage(dynamic message) async {
    final type = message['type'];
    final fromId = message['fromId'];

    switch (type) {
      case 'offer':
        if (_password != null && message['password'] != _password) {
          _signaling?.send({
            'type': 'error',
            'toId': fromId,
            'message': 'Invalid Studio Password',
          });
          return;
        }
        await _handleOffer(fromId, message['sdp']);
        break;
      case 'candidate':
        await _handleCandidate(fromId, message['candidate']);
        break;
    }
  }

  Future<void> _handleOffer(String fromId, String sdp) async {
    final pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    });
    
    _connections[fromId] = pc;
    
    pc.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video') {
        _setupRemoteRenderer(fromId, event.streams[0]);
      }
    };

    await pc.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));
    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);

    _signaling?.send({
      'type': 'answer',
      'toId': fromId,
      'sdp': answer.sdp,
    });
  }

  Future<void> _handleCandidate(String fromId, dynamic candidate) async {
    final pc = _connections[fromId];
    if (pc != null) {
      await pc.addCandidate(RTCIceCandidate(
        candidate['candidate'],
        candidate['sdpMid'],
        candidate['sdpMLineIndex'],
      ));
    }
  }

  void _setupRemoteRenderer(String id, MediaStream stream) async {
    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    renderer.srcObject = stream;
    _remoteRenderers[id] = renderer;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_registration != null) {
      unregister(_registration!);
    }
    _signaling?.dispose();
    for (var renderer in _remoteRenderers.values) {
      renderer.dispose();
    }
    for (var conn in _connections.values) {
      conn.dispose();
    }
    super.dispose();
  }
}
