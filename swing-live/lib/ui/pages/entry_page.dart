import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/streaming_provider.dart';
import 'setup_page.dart';
import 'transmitter_page.dart';

class EntryPage extends StatelessWidget {
  const EntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset('assets/splash.png', height: 180),
              const SizedBox(height: 32),
              const Text(
                "SELECT BROADCAST MODE",
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 60),

              // 1. SOLO BROADCAST CARD
              _buildBigCard(
                title: "SOLO BROADCAST",
                subtitle: "Single camera match streaming",
                icon: Icons.videocam,
                color: Colors.redAccent,
                onTap: () => _handleSoloTap(context),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),

              const SizedBox(height: 24),

              // 2. MULTICAM CARD
              _buildBigCard(
                title: "MULTICAM",
                subtitle: "Enterprise multi-angle hub",
                icon: Icons.layers,
                color: const Color(0xFF1A1A1A),
                isEnterprise: true,
                onTap: () => _handleMultiCamTap(context),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBigCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isEnterprise = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: isEnterprise ? Border.all(color: Colors.white10) : null,
          boxShadow: !isEnterprise ? [BoxShadow(color: color.withAlpha(40), blurRadius: 20, offset: const Offset(0, 10))] : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      if (isEnterprise) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                          child: const Text("PRO", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ]
                    ],
                  ),
                  Text(subtitle, style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  void _handleSoloTap(BuildContext context) async {
    final provider = context.read<StreamingProvider>();
    
    if (provider.socialAccountName.isEmpty) {
      _showLoginPrompt(context, provider);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SetupPage(isSolo: true)));
      provider.estimateBandwidth();
    }
  }

  void _showLoginPrompt(BuildContext context, StreamingProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          bool isLoading = false;
          
          return Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 32),
                if (isLoading)
                  const Column(
                    children: [
                      CircularProgressIndicator(color: Colors.redAccent),
                      SizedBox(height: 24),
                      Text("SECURELY CONNECTING...", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      SizedBox(height: 8),
                      Text("Setting up your YouTube broadcast", style: TextStyle(color: Colors.white24, fontSize: 10)),
                    ],
                  )
                else ...[
                  const Icon(Icons.account_circle, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  const Text("YouTube Sign-In", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("A YouTube account is required for professional solo broadcasting.", 
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 13)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        setModalState(() => isLoading = true);
                        await provider.connectYouTube();
                        if (provider.socialAccountName.isNotEmpty) {
                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SetupPage(isSolo: true)));
                          }
                        } else {
                          setModalState(() => isLoading = false);
                        }
                      },
                      icon: const Icon(Icons.login),
                      label: const Text("CONTINUE WITH GOOGLE", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ],
            ),
          );
        }
      ),
    );
  }

  void _handleMultiCamTap(BuildContext context) {
    // Navigate to Transmitter with prompt
    Navigator.push(context, MaterialPageRoute(builder: (context) => const TransmitterPage()));
  }
}
