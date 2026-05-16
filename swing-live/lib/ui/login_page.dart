import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../streaming/stream_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<StreamController>();
    final isBusy = ctrl.phase == StreamPhase.connecting;
    final err = ctrl.errorMessage;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        // Centered, fixed-width content column. The app is locked to
        // landscape app-wide, so the available height is short — we lay
        // the brand/subtitle inline with the button instead of stacking
        // them with Spacers (which overflow on short viewports).
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Brand block, left half.
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SWING LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Stream cricket to YouTube',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        if (err != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            err,
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // CTA, right half.
                  SizedBox(
                    width: 220,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isBusy ? null : () => ctrl.signIn(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.white24,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'SIGN IN WITH GOOGLE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.6,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
