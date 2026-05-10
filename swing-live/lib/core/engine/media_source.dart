import 'package:flutter_webrtc/flutter_webrtc.dart';

enum SourceProtocol {
  webrtc,
  rtsp,
  srt,
  local
}

abstract class MediaSource {
  final String id;
  final String name;
  final SourceProtocol protocol;
  
  bool isConnected = false;
  MediaStream? stream;

  MediaSource({
    required this.id,
    required this.name,
    required this.protocol,
  });

  Future<void> connect();
  Future<void> disconnect();
  
  Map<String, dynamic> getStatus() {
    return {
      'id': id,
      'name': name,
      'protocol': protocol.name,
      'isConnected': isConnected,
    };
  }
}
