import 'media_source.dart';

class RTSPSource extends MediaSource {
  final String url;
  
  RTSPSource({
    required String id,
    required String name,
    required this.url,
  }) : super(id: id, name: name, protocol: SourceProtocol.rtsp);

  @override
  Future<void> connect() async {
    // In an enterprise setup, this would initialize an RTSP client (e.g., VLC or FFmpeg)
    // and pipe the frames into the engine.
    print("Connecting to Enterprise IP Camera: $url");
    isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    print("Disconnecting from IP Camera: $id");
    isConnected = false;
  }
}
