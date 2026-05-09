import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final value = Curves.easeOutCubic.transform(_controller.value);
          return SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 22 * (1 - value)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 190,
                              height: 190,
                              child: Image.asset(
                                'assets/logo/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 22),
                            const Text(
                              'Welcome to Arena',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF101828),
                                fontSize: 32,
                                height: 1,
                                letterSpacing: -0.8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'by ',
                                    style: TextStyle(
                                      color: Color(0xFF101828),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'swing',
                                    style: TextStyle(
                                      color: Color(0x66101828),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

