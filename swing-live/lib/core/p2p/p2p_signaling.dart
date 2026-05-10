import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

typedef OnMessageCallback = void Function(dynamic message);

class P2PSignaling {
  HttpServer? _server;
  final Map<String, WebSocketChannel> _clients = {};
  WebSocketChannel? _outboundChannel; // For Camera Nodes connecting to Studio
  final OnMessageCallback onMessage;
  
  P2PSignaling({required this.onMessage});

  // Host a signaling server (Used by the Master Studio)
  Future<int> host() async {
    var handler = webSocketHandler((WebSocketChannel webSocket) {
      String? clientId;
      webSocket.stream.listen((message) {
        final data = jsonDecode(message);
        if (data['type'] == 'join') {
          clientId = data['fromId'];
          if (clientId != null) _clients[clientId!] = webSocket;
        }
        onMessage(data);
      }, onDone: () {
        if (clientId != null) _clients.remove(clientId);
      });
    });

    _server = await io.serve(handler, InternetAddress.anyIPv4, 0);
    return _server!.port;
  }

  // Connect to a signaling server (Used by Camera Nodes)
  void connect(String ip, int port) {
    final url = 'ws://$ip:$port';
    _outboundChannel = WebSocketChannel.connect(Uri.parse(url));
    _outboundChannel!.stream.listen((message) {
      onMessage(jsonDecode(message));
    });
  }

  void send(Map<String, dynamic> message) {
    final toId = message['toId'];
    if (toId != null && _clients.containsKey(toId)) {
      _clients[toId]!.sink.add(jsonEncode(message));
    } else if (_outboundChannel != null) {
      _outboundChannel!.sink.add(jsonEncode(message));
    }
  }

  Future<void> dispose() async {
    await _server?.close();
    await _outboundChannel?.sink.close();
    for (var client in _clients.values) {
      client.sink.close();
    }
    _clients.clear();
  }
}
