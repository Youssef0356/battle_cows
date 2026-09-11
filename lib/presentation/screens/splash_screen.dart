import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) Navigator.pushReplacementNamed(context, AppRouter.home);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final bob = sin(_controller.value * pi * 3) * 8;
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/Background/background.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF1B5E20), Color(0xFF102A18)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Container(color: const Color(0xFF102A18).withValues(alpha: 0.62)),
              Positioned(
                left: 24,
                right: 24,
                top: MediaQuery.sizeOf(context).height * 0.22,
                child: Column(
                  children: [
                    Transform.translate(
                      offset: Offset(0, bob),
                      child: Image.asset(
                        'assets/images/Background/Logo.png',
                        height: 190,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Text('BATTLE COWS', style: GoogleFonts.bangers(fontSize: 46, color: const Color(0xFFFFD54F))),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('ROUND UP. RAMPAGE. REPEAT.', style: GoogleFonts.bangers(color: Colors.white70, fontSize: 15, letterSpacing: 2)),
                    const SizedBox(height: 34),
                    SizedBox(
                      width: 180,
                      child: LinearProgressIndicator(
                        value: Curves.easeOut.transform(_controller.value),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD54F)),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(left: 28, bottom: 70 + bob, child: const Text('🐮', style: TextStyle(fontSize: 44))),
              Positioned(right: 30, bottom: 92 - bob, child: const Text('🐮', style: TextStyle(fontSize: 36))),
              Positioned(bottom: 26, left: 0, right: 0, child: Text('MADE FOR MUDDY MASTERS', textAlign: TextAlign.center, style: GoogleFonts.bangers(color: Colors.white54, fontSize: 11, letterSpacing: 2))),
            ],
          );
        },
      ),
    );
  }
}
