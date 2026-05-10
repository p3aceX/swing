import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

class WebDashboardServer {
  HttpServer? _server;
  final Function(String command, dynamic data) onCommandReceived;
  final List<WebSocketChannel> _connectedClients = [];

  WebDashboardServer({required this.onCommandReceived});

  Future<String> start() async {
    // 1. WebSocket Handler for real-time commands
    var wsHandler = webSocketHandler((WebSocketChannel webSocket) {
      _connectedClients.add(webSocket);
      webSocket.stream.listen((message) {
        final data = jsonDecode(message);
        onCommandReceived(data['command'], data['data']);
      }, onDone: () {
        _connectedClients.remove(webSocket);
      });
    });

    // 2. Main Request Handler (Serves the HTML Dashboard)
    var handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler((Request request) {
      if (request.url.path == 'ws') {
        return wsHandler(request);
      }
      
      if (request.url.path == 'join') {
        return Response.ok(_buildJoinPageHtml(), headers: {'content-type': 'text/html'});
      }

      return Response.ok(_buildDashboardHtml(), headers: {'content-type': 'text/html'});
    });

    try {
      _server = await io.serve(handler, InternetAddress.anyIPv4, 9090, shared: true);
    } catch (e) {
      debugPrint("[WEB_DASHBOARD] Port 9090 busy, trying random port...");
      _server = await io.serve(handler, InternetAddress.anyIPv4, 0, shared: true);
    }
    
    final ip = await _getLocalIp();
    final url = "http://$ip:${_server!.port}";
    debugPrint("[WEB_DASHBOARD] Running at $url");
    return url;
  }

  Future<String> _getLocalIp() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          return addr.address;
        }
      }
    }
    return "localhost";
  }

  void broadcastStatus(Map<String, dynamic> status) {
    final message = jsonEncode(status);
    for (var client in _connectedClients) {
      client.sink.add(message);
    }
  }

  String _buildDashboardHtml() {
    return """
    <!DOCTYPE html>
    <html>
    <head>
      <title>Swing Live | Pro Dashboard</title>
      <style>
        body { font-family: 'Inter', sans-serif; background: #0f0f0f; color: white; display: flex; flex-direction: column; align-items: center; padding: 40px; }
        .header { display: flex; justify-content: space-between; width: 100%; max-width: 900px; margin-bottom: 40px; }
        .status-pill { background: #ff4444; padding: 5px 15px; borderRadius: 20px; font-weight: bold; font-size: 12px; }
        .grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; width: 100%; max-width: 900px; }
        .cam-card { background: #1a1a1a; border: 2px solid #333; padding: 20px; border-radius: 12px; cursor: pointer; text-align: center; transition: 0.3s; }
        .cam-card:hover { border-color: #ff4444; transform: translateY(-5px); }
        .cam-card.active { border-color: #00ff88; box-shadow: 0 0 20px rgba(0,255,136,0.2); }
        .controls { margin-top: 40px; background: #1a1a1a; padding: 20px; border-radius: 12px; width: 100%; max-width: 900px; }
        button { background: #ff4444; border: none; color: white; padding: 12px 24px; border-radius: 8px; font-weight: bold; cursor: pointer; }
        h1 { margin: 0; letter-spacing: 2px; }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>SWING LIVE STUDIO</h1>
        <div class="status-pill">MASTER CONTROL</div>
      </div>

      <div class="grid" id="camGrid">
        <!-- Sources will be injected here dynamically -->
      </div>

      <div class="controls">
        <h3>MASTER PRODUCTION CONTROLS</h3>
        <div style="display: flex; gap: 10px;">
          <button onclick="sendCommand('overlay', 'scorebug')">TOGGLE SCOREBOARD</button>
          <button onclick="sendCommand('overlay', 'lowerThird')">SHOW NAME PLATE</button>
          <button style="background: #555;" onclick="addRtspSource()">+ ADD IP CAMERA (RTSP)</button>
        </div>
      </div>

      <script>
        const ws = new WebSocket('ws://' + window.location.host + '/ws');
        let currentStatus = {};
        
        function sendCommand(cmd, data) {
          ws.send(JSON.stringify({command: cmd, data: data}));
        }

        function addRtspSource() {
          const url = prompt("Enter RTSP URL (e.g. rtsp://192.168.1.100:554/live)");
          if (url) sendCommand('add_rtsp', url);
        }

        ws.onmessage = (event) => {
          const status = JSON.parse(event.data);
          currentStatus = status;
          updateUI();
        };

        function updateUI() {
          const grid = document.getElementById('camGrid');
          grid.innerHTML = '';
          
          if (!currentStatus.sources) return;

          currentStatus.sources.forEach(source => {
            const isActive = source.id === currentStatus.activeSource;
            const card = document.createElement('div');
            card.className = `cam-card \${isActive ? 'active' : ''}`;
            card.onclick = () => sendCommand('switch_camera', source.id);
            card.innerHTML = `
              <div style="font-size: 10px; color: \${source.isConnected ? '#00ff88' : '#ff4444'}">\${source.protocol.toUpperCase()}</div>
              <h3>\${source.name}</h3>
              <p>\${isActive ? '● ON AIR' : 'PREVIEW'}</p>
            `;
            grid.appendChild(card);
          });
        }
      </script>
    </body>
    </html>
    """;
  }

  String _buildJoinPageHtml() {
    return """
    <!DOCTYPE html>
    <html>
    <head>
      <title>Swing Live | Join as Camera</title>
      <style>
        body { font-family: sans-serif; background: #000; color: #fff; text-align: center; padding: 50px; }
        video { width: 80%; max-width: 600px; border: 2px solid #ff4444; border-radius: 12px; background: #111; }
        .btn { background: #ff4444; color: white; border: none; padding: 15px 30px; border-radius: 30px; font-size: 18px; cursor: pointer; margin-top: 20px; }
      </style>
    </head>
    <body>
      <h1>CAMERA INJECTOR</h1>
      <video id="preview" autoplay muted playsinline></video>
      <br/>
      <button class="btn" id="startBtn">START STREAMING TO PHONE</button>

      <script>
        const preview = document.getElementById('preview');
        const startBtn = document.getElementById('startBtn');
        let localStream;

        async function start() {
          const pass = prompt("Enter Studio Password");
          localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
          preview.srcObject = localStream;
          
          const ws = new WebSocket('ws://' + window.location.host + '/ws');
          ws.onopen = () => {
             // Send join command with password
             ws.send(JSON.stringify({ 
               command: 'join_camera', 
               data: { name: 'PC Camera', password: pass } 
             }));
          };
        }

        startBtn.onclick = start;
      </script>
    </body>
    </html>
    """;
  }

  Future<void> stop() async {
    await _server?.close();
  }
}
