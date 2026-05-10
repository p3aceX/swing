import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../framework/swing_camera_preview.dart';
import '../../providers/streaming_provider.dart';
import '../../core/studio/p2p_studio_manager.dart';
import '../../core/node/studio_node.dart';

class TransmitterPage extends StatefulWidget {
  const TransmitterPage({super.key});

  @override
  State<TransmitterPage> createState() => _TransmitterPageState();
}

class _TransmitterPageState extends State<TransmitterPage> {
  bool _isConnected = false;
  String _status = "DISCONNECTED";
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    context.read<P2PStudioManager>().discoverStudios();
  }

  @override
  void dispose() {
    _idController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _startTransmitting() async {
    if (_idController.text.isEmpty) return;

    setState(() {
      _isConnecting = true;
      _status = "CONNECTING...";
    });

    final studio = context.read<P2PStudioManager>();
    final node = studio.availableNodes.firstWhere(
      (n) => n.id.toUpperCase() == _idController.text.toUpperCase(),
      orElse: () => StudioNode(id: 'manual', name: 'Manual', type: NodeType.studio, lastSeen: DateTime.now(), ipAddress: _idController.text, port: 9090),
    );

    await studio.connectToStudio(node, password: _passController.text);
    await context.read<StreamingProvider>().startHardware();

    setState(() {
      _isConnecting = false;
      _isConnected = true;
      _status = "LIVE";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18), onPressed: () => Navigator.pop(context)),
        title: const Text("ENTERPRISE CAMERA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      body: _isConnected ? _buildCameraView() : _buildEntryForm(),
    );
  }

  Widget _buildEntryForm() {
    final studio = context.watch<P2PStudioManager>();

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sensors, color: Colors.redAccent, size: 64)
              .animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 32),
          const Text("JOIN STUDIO HUB", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Enter the unique ID and password provided by your production manager.", 
              textAlign: TextAlign.center, 
              style: TextStyle(color: Colors.white38, fontSize: 13)),
          
          const SizedBox(height: 48),
          _buildTextField(_idController, "Studio ID / IP Address", Icons.hub),
          const SizedBox(height: 16),
          _buildTextField(_passController, "Security Password", Icons.lock, isPassword: true),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _isConnecting ? null : _startTransmitting,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isConnecting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text("CONNECT AS FEED", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),

          if (studio.availableNodes.isNotEmpty) ...[
            const SizedBox(height: 40),
            const Text("DISCOVERED LOCAL HUBS", style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),
            ...studio.availableNodes.map((n) => ListTile(
              onTap: () => setState(() => _idController.text = n.id),
              title: Text(n.name, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              subtitle: Text(n.id, style: const TextStyle(color: Colors.white24, fontSize: 10)),
              trailing: const Icon(Icons.add_circle_outline, color: Colors.redAccent, size: 20),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        const Positioned.fill(child: SwingCameraPreview()),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: _status == "LIVE" ? Colors.redAccent : Colors.white10, width: 8),
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const Icon(Icons.circle, color: Colors.red, size: 8),
                const SizedBox(width: 8),
                Text(_status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.white24, size: 20),
        filled: true,
        fillColor: Colors.white.withAlpha(5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
