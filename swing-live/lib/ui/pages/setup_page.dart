import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/streaming_provider.dart';
import '../../models/streaming_quality.dart';
import 'studio_page.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  late TextEditingController _urlController;
  late TextEditingController _keyController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<StreamingProvider>();
    _urlController = TextEditingController(text: provider.rtmpUrl);
    _keyController = TextEditingController(text: provider.streamKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.initProvider();
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StreamingProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("SWING LIVE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Studio Setup", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
                .animate().fadeIn(delay: 200.ms).slideX(),
            const SizedBox(height: 8),
            const Text("Choose a connection method and set quality.", style: TextStyle(color: Colors.white54, fontSize: 14))
                .animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            
            // Toggle between YouTube and Manual
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildModeTab("YouTube", !provider.isManualMode, () => provider.setManualMode(false)),
                  _buildModeTab("Custom RTMP", provider.isManualMode, () => provider.setManualMode(true)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!provider.isManualMode)
              _buildYouTubeCard(provider).animate().fadeIn().scale(begin: const Offset(0.98, 0.98))
            else
              _buildManualInputs().animate().fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 32),
            _buildSectionTitle("QUALITY"),
            const SizedBox(height: 12),
            _buildQualitySelector(provider),
            
            const SizedBox(height: 32),
            _buildSectionTitle("HARDWARE"),
            const SizedBox(height: 12),
            _buildPreferenceToggle(
              "Eco Mode", 
              "Lower hardware strain (720p 30fps max)", 
              provider.isEcoMode, 
              (v) => provider.setEcoMode(v),
              Icons.battery_saver
            ),

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => _navigateToStudio(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ),
                child: const Text("ENTER STUDIO", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.redAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: isActive ? Colors.white : Colors.white38, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYouTubeCard(StreamingProvider provider) {
    final bool isConnected = provider.socialAccountName.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isConnected ? Colors.redAccent.withAlpha(100) : Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle_fill, color: Colors.red, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("YouTube Live", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      isConnected ? provider.socialAccountName : "One-tap secure connection",
                      style: TextStyle(color: isConnected ? Colors.redAccent : Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (provider.isConnectingSocial)
            const SizedBox(
              width: double.infinity,
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent))),
            )
          else if (isConnected) ...[
            // Connected: show stream key status + refresh / logout
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    provider.streamKey.isNotEmpty ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                    color: provider.streamKey.isNotEmpty ? Colors.greenAccent : Colors.orangeAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.streamKey.isNotEmpty ? "Stream key cached — ready to go" : "No stream key — tap Refresh",
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.refreshYouTubeStream,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text("NEW STREAM", style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: provider.disconnectYouTube,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white38,
                      side: const BorderSide(color: Colors.white10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("LOGOUT", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: provider.connectYouTube,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("CONNECT ACCOUNT"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildManualInputs() {
    return Column(
      children: [
        _buildTextField(_urlController, "RTMP URL (e.g., rtmp://a.rtmp.youtube.com/live2)", Icons.link),
        const SizedBox(height: 12),
        _buildTextField(_keyController, "Stream Key", Icons.vpn_key, isPassword: true),
      ],
    );
  }

  void _navigateToStudio(BuildContext context, StreamingProvider provider) {
    if (provider.isManualMode) {
       if (_urlController.text.isEmpty || _keyController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter URL and Key")));
          return;
       }
       provider.setConfig(_urlController.text, _keyController.text);
    } else {
      if (provider.streamKey.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please connect YouTube first")));
         return;
      }
    }
    
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudioPage()),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5));
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      onChanged: (v) => context.read<StreamingProvider>().setConfig(_urlController.text, _keyController.text),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: Colors.white.withAlpha(10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildQualitySelector(StreamingProvider provider) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withAlpha(10), borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: StreamingQuality.values.length,
        separatorBuilder: (_, __) => Divider(color: Colors.white.withAlpha(5), height: 1),
        itemBuilder: (context, index) {
          final q = StreamingQuality.values[index];
          final isSelected = provider.quality == q;
          return ListTile(
            dense: true,
            onTap: () => provider.setQuality(q),
            title: Text(q.label, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 14)),
            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.redAccent, size: 20) : null,
          );
        },
      ),
    );
  }

  Widget _buildPreferenceToggle(String title, String sub, bool value, Function(bool) onChanged, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withAlpha(10), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeTrackColor: Colors.redAccent),
        ],
      ),
    );
  }
}
