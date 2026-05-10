import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/streaming_provider.dart';
import '../../models/streaming_quality.dart';
import '../../overlays/preview/overlay_pack_preview_page.dart';
import 'preflight_page.dart';

class SetupPage extends StatefulWidget {
  final bool isSolo;
  const SetupPage({super.key, this.isSolo = true});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isMatchValidated = false;
  bool _isValidating = false;
  String _validatedMatchTitle = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StreamingProvider>();
      provider.initProvider().then((_) {
        if (mounted) {
          final savedCode = provider.liveCode;
          final savedPin = provider.savedPin;
          if (savedCode != null && savedCode.contains('#')) {
            _idController.text = savedCode.split('#').last;
          }
          if (savedPin != null) {
            _passController.text = savedPin;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _validateMatch() async {
    if (_idController.text.length != 4 || _passController.text.length != 4) {
      debugPrint(
          '[OverlayDebug] setup: input length invalid · id=${_idController.text.length} pin=${_passController.text.length}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter 4-digit Match ID and Passcode")),
      );
      return;
    }

    setState(() => _isValidating = true);
    final provider = context.read<StreamingProvider>();
    // Backend liveCode format is "swing#NNNN" (see match.service.ts
    // generateUniqueMatchLiveCode). The host app shows users the same
    // string, so we just append the 4-digit input.
    final liveCode = "swing#${_idController.text}";
    debugPrint('[OverlayDebug] setup: tapping VALIDATE → "$liveCode"');
    final error = await provider.validateAndConnectMatch(
      liveCode: liveCode,
      pin: _passController.text,
    );
    if (!mounted) return;
    setState(() => _isValidating = false);

    if (error != null) {
      debugPrint('[OverlayDebug] setup: showing error snackbar → $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final b = provider.bootstrap;
    final teamA = b?.teamA.shortName ?? b?.teamA.name ?? 'TEAM A';
    final teamB = b?.teamB.shortName ?? b?.teamB.name ?? 'TEAM B';
    setState(() {
      _isMatchValidated = true;
      _validatedMatchTitle = '${teamA.toUpperCase()} VS ${teamB.toUpperCase()}';
    });
    provider.estimateBandwidth();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StreamingProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildProfileHeader(provider),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildMatchValidator(),
                    const SizedBox(height: 24),
                    _buildOverlayPackPreviewCard(),
                    if (_isMatchValidated) ...[
                      const SizedBox(height: 32),
                      _buildSmartCalibrationHUD(provider),
                      const SizedBox(height: 32),
                      _buildSectionTitle("BROADCAST CONFIGURATION"),
                      const SizedBox(height: 12),
                      _buildQualitySelector(provider),
                      const SizedBox(height: 32),
                      _buildSectionTitle("PRO HARDWARE"),
                      const SizedBox(height: 12),
                      _buildPreferenceToggle(
                        "Eco Mode",
                        "Lower hardware strain",
                        provider.isEcoMode,
                        (v) => provider.setEcoMode(v),
                        Icons.bolt
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            if (_isMatchValidated)
              _buildBottomAction(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchValidator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _isMatchValidated ? Colors.orangeAccent : Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MATCH CREDENTIALS", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: const BorderRadius.horizontal(left: Radius.circular(16))),
                child: const Text("swing#", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: TextField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: "0000",
                    hintStyle: TextStyle(color: Colors.white12),
                    counterText: "",
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(16)), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter 4-Digit Passcode",
              hintStyle: const TextStyle(color: Colors.white12, fontSize: 14),
              counterText: "",
              prefixIcon: const Icon(Icons.lock, color: Colors.white24, size: 20),
              filled: true,
              fillColor: Colors.white.withAlpha(10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          if (!_isMatchValidated) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isValidating ? null : _validateMatch,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _isValidating
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.black,
                        ),
                      )
                    : const Text("VALIDATE MATCH",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.orangeAccent.withAlpha(20), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("VALIDATED SESSION", style: TextStyle(color: Colors.orangeAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_validatedMatchTitle, style: const TextStyle(color: Colors.orangeAccent, fontSize: 14, fontWeight: FontWeight.w900)),
                ],
              ),
            ).animate().fadeIn().scale(),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileHeader(StreamingProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.redAccent.withAlpha(20),
            child: const Icon(Icons.person, color: Colors.redAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.socialAccountName.toUpperCase(), 
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const Text("BROADCAST ACCOUNT ACTIVE", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => provider.connectYouTube(),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                child: const Text("CHANGE", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () => provider.disconnectYouTube(),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                child: const Text("LOGOUT", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmartCalibrationHUD(StreamingProvider provider) {
    final bool isTesting = provider.networkStrength == 0.5 && provider.quality == StreamingQuality.auto;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.redAccent.withAlpha(10), borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("NETWORK CALIBRATION", style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(isTesting ? "Analyzing..." : "System Optimized", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.verified, color: Colors.greenAccent, size: 20),
        ],
      ),
    );
  }

  Widget _buildOverlayPackPreviewCard() {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const OverlayPackPreviewPage(),
        ),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('🦆', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OVERLAY PACK',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Preview Basic Pack',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Portrait + landscape · animated effects',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, StreamingProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 10, 32, 30),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PreflightPage())),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          child: const Text("PROCEED TO PRE-FLIGHT", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2));
  }

  Widget _buildQualitySelector(StreamingProvider provider) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withAlpha(10), borderRadius: BorderRadius.circular(16)),
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
      decoration: BoxDecoration(color: Colors.white.withAlpha(10), borderRadius: BorderRadius.circular(16)),
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
