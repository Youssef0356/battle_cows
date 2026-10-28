import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../assets/asset_paths.dart';
import '../../core/localization/app_fonts.dart';
import '../router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _cowLeftSlide;
  late final Animation<Offset> _cowRightSlide;
  late final Animation<double> _progressAnimation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Punchy logo pop-in
    _logoScale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    // Cowboy cow enters from the left
    _cowLeftSlide = Tween<Offset>(
      begin: const Offset(-1.2, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.65, curve: Curves.easeOutBack),
      ),
    );

    // Viking cow enters from the right
    _cowRightSlide = Tween<Offset>(
      begin: const Offset(1.2, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Chunky progress bar filling smoothly
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.1, 0.95, curve: Curves.easeInOutCubic),
      ),
    );

    _mainController.forward();

    // Navigate to Home once loading finishes
    _navTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getLoadingText(double progress) {
    if (progress < 0.28) {
      return 'ROUNDING UP THE HERD...';
    } else if (progress < 0.58) {
      return 'SHARPENING THE HORNS...';
    } else if (progress < 0.88) {
      return 'SCOUTING THE PASTURE...';
    } else {
      return 'READY FOR BATTLE!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4D20),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. High-res barnyard backdrop
          Image.asset(
            AssetPaths.background,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox.expand(),
          ),

          // 2. Warm ambient sunlight gradient & vignette
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.15,
                colors: [
                  Color(0x30FFE082),
                  Color(0x751E3922),
                  Color(0xCC0E1F11),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // 3. Floating pollen / dust barnyard particles
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) => CustomPaint(
              painter: _DustParticlesPainter(_pulseController.value),
            ),
          ),

          // 4. Main responsive content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = constraints.maxWidth > constraints.maxHeight;
                final availableHeight = constraints.maxHeight;
                final availableWidth = constraints.maxWidth;

                return Column(
                  children: [
                    // Top / Center Area with Logo & Tagline
                    Expanded(
                      flex: isLandscape ? 4 : 5,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _mainController,
                          builder: (context, child) {
                            final idleBob = math.sin(_pulseController.value * math.pi) * 6;
                            return Transform.translate(
                              offset: Offset(0, idleBob),
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: Opacity(
                                  opacity: _logoFade.value,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Sunburst Glow behind logo
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, _) {
                                      final glowScale = 0.92 + (_pulseController.value * 0.16);
                                      return Transform.scale(
                                        scale: glowScale,
                                        child: Container(
                                          width: isLandscape ? 170 : 230,
                                          height: isLandscape ? 170 : 230,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
                                                blurRadius: 55,
                                                spreadRadius: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Logo Image
                                  Image.asset(
                                    AssetPaths.logo,
                                    height: isLandscape
                                        ? (availableHeight * 0.45).clamp(110.0, 160.0)
                                        : (availableHeight * 0.28).clamp(150.0, 240.0),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Text(
                                      'BATTLE COWS',
                                      style: AppFonts.bangers(
                                        fontSize: 44,
                                        color: const Color(0xFFFFD54F),
                                        shadows: const [
                                          Shadow(
                                            offset: Offset(3, 4),
                                            blurRadius: 2,
                                            color: Color(0xFF2E1C0C),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Comic Tagline Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x992B1911),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFFFCA28).withValues(alpha: 0.8),
                                    width: 1.8,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x66000000),
                                      offset: Offset(0, 3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'ROUND UP  •  RAMPAGE  •  REPEAT',
                                  style: AppFonts.bangers(
                                    color: const Color(0xFFFFF9C4),
                                    fontSize: isLandscape ? 13 : 15,
                                    letterSpacing: 2.2,
                                    shadows: const [
                                      Shadow(
                                        offset: Offset(1.5, 1.5),
                                        color: Colors.black87,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Middle / Bottom: Cow Champions Facing Off
                    Expanded(
                      flex: isLandscape ? 3 : 4,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Left Cow (Cowboy)
                          AnimatedBuilder(
                            animation: _mainController,
                            builder: (context, _) {
                              final bob = math.sin(_pulseController.value * math.pi) * 4;
                              return Positioned(
                                left: (availableWidth * 0.06).clamp(12.0, 70.0),
                                bottom: 10 + bob,
                                child: SlideTransition(
                                  position: _cowLeftSlide,
                                  child: _buildCowPortrait(
                                    imagePath: 'assets/images/Cows/cow_cowboy.png',
                                    isLeft: true,
                                    maxHeight: isLandscape ? 110 : 160,
                                  ),
                                ),
                              );
                            },
                          ),

                          // Right Cow (Viking)
                          AnimatedBuilder(
                            animation: _mainController,
                            builder: (context, _) {
                              final bob = math.cos(_pulseController.value * math.pi) * 4;
                              return Positioned(
                                right: (availableWidth * 0.06).clamp(12.0, 70.0),
                                bottom: 10 + bob,
                                child: SlideTransition(
                                  position: _cowRightSlide,
                                  child: _buildCowPortrait(
                                    imagePath: 'assets/images/Cows/cow_viking.png',
                                    isLeft: false,
                                    maxHeight: isLandscape ? 110 : 160,
                                  ),
                                ),
                              );
                            },
                          ),

                          // Center Stampede Dust overlay hint
                          Positioned(
                            bottom: 2,
                            child: Opacity(
                              opacity: 0.45,
                              child: Image.asset(
                                'assets/images/Effects/stampede_dust.png',
                                height: isLandscape ? 40 : 65,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Area: Cartoon Progress Bar & Dynamic Status
                    Padding(
                      padding: const EdgeInsets.only(bottom: 22, left: 24, right: 24),
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, _) {
                          final progress = _progressAnimation.value;
                          final barWidth = (availableWidth * 0.72).clamp(240.0, 420.0);

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Dynamic Loading Text
                              Text(
                                _getLoadingText(progress),
                                style: AppFonts.bangers(
                                  color: const Color(0xFFFFD54F),
                                  fontSize: 14,
                                  letterSpacing: 2,
                                  shadows: const [
                                    Shadow(
                                      offset: Offset(1.5, 1.5),
                                      blurRadius: 3,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Chunky Cartoon Loading Bar
                              Container(
                                width: barWidth,
                                height: 22,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2B170B),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF5D3A1A),
                                    width: 2.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x88000000),
                                      offset: Offset(0, 3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Track background
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B1007),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    // Animated Fill with Gradient
                                    FractionallySizedBox(
                                      widthFactor: progress.clamp(0.02, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFFEA00),
                                              Color(0xFFFF9100),
                                              Color(0xFFFF6D00),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Glossy reflection stripe on upper half of bar
                                    FractionallySizedBox(
                                      widthFactor: progress.clamp(0.02, 1.0),
                                      heightFactor: 0.45,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.35),
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Bottom Game Label
                              Text(
                                'THE ULTIMATE BARNYARD BATTLE',
                                style: AppFonts.bangers(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  letterSpacing: 2.5,
                                  shadows: const [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      color: Colors.black87,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCowPortrait({
    required String imagePath,
    required bool isLeft,
    required double maxHeight,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cow Character
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(isLeft ? 1.0 : -1.0, 1.0, 1.0)
            ..rotateZ(isLeft ? -0.05 : 0.05),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
              maxWidth: maxHeight * 1.1,
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
        ),
        // Soft ground shadow beneath cow
        Container(
          width: maxHeight * 0.75,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Gentle drifting pollen / sparkles for an alive cartoon environment
class _DustParticlesPainter extends CustomPainter {
  final double animationValue;

  _DustParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFF9C4).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    const particleCount = 18;
    for (int i = 0; i < particleCount; i++) {
      final seed = i * 137.5;
      final xBase = (seed % size.width);
      final yBase = ((seed * 2.3) % size.height);

      // Subtle float movement
      final dx = math.sin((animationValue * math.pi * 2) + i) * 12;
      final dy = math.cos((animationValue * math.pi * 2) + (i * 0.7)) * 14;

      final radius = 1.2 + (i % 3) * 0.9;
      canvas.drawCircle(
        Offset(
          (xBase + dx) % size.width,
          (yBase + dy) % size.height,
        ),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DustParticlesPainter oldDelegate) => true;
}
