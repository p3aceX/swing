import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'media_source.dart';

class WebRTCSource extends MediaSource {
  final RTCPeerConnection peerConnection;
  
  WebRTCSource({
    required String id,
    required String name,
    required this.peerConnection,
  }) : super(id: id, name: name, protocol: SourceProtocol.webrtc);

  @override
  Future<void> connect() async {
    // WebRTC connection is usually handled during handshake
    isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    await peerConnection.close();
    isConnected = false;
  }
}
