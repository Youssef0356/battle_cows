import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../game/tutorial/tutorial_data.dart';

class TutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onComplete;
  final void Function(int stepIndex, TutorialStep step)? onStepChanged;

  const TutorialOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
    this.onStepChanged,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  TutorialStep get _step => widget.steps[_currentStep];

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() => _currentStep++);
      widget.onStepChanged?.call(_currentStep, _step);
    } else {
      widget.onComplete();
    }
  }

  void _skip() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final spotlight = _getSpotlightRect(size);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, _) {
        return Stack(
          children: [
            CustomPaint(
              size: size,
              painter: _SpotlightPainter(
                spotlight: spotlight,
                pulseValue: _pulseAnimation.value,
                accentColor: _step.accentColor,
              ),
            ),
            _buildSkipButton(),
            _buildStepIndicator(),
            _buildTooltip(spotlight, size),
          ],
        );
      },
    );
  }

  Rect _getSpotlightRect(Size size) {
    final w = size.width;
    final h = size.height;
    const padding = 16.0;

    switch (_step.target) {
      case TutorialTarget.rotateButton:
        return Rect.fromCenter(
          center: Offset(w * 0.30, h - 120),
          width: 100,
          height: 52,
        );
      case TutorialTarget.placeButton:
        return Rect.fromCenter(
          center: Offset(w * 0.70, h - 120),
          width: 100,
          height: 52,
        );
      case TutorialTarget.boardHex:
        return Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.45),
          width: 120,
          height: 120,
        );
      case TutorialTarget.playerHerd:
        return Rect.fromCenter(
          center: Offset(w * 0.35, h * 0.4),
          width: 100,
          height: 100,
        );
      case TutorialTarget.splitSlider:
        return Rect.fromLTRB(
          w - 90,
          h * 0.35,
          w - padding,
          h * 0.65,
        );
      case TutorialTarget.destinationHex:
        return Rect.fromCenter(
          center: Offset(w * 0.6, h * 0.35),
          width: 100,
          height: 100,
        );
      case TutorialTarget.scoreboard:
        return Rect.fromCenter(
          center: Offset(w * 0.5, h - 50),
          width: w * 0.8,
          height: 60,
        );
      case TutorialTarget.enemyHerd:
        return Rect.fromCenter(
          center: Offset(w * 0.65, h * 0.5),
          width: 100,
          height: 100,
        );
      case TutorialTarget.none:
        return Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.5),
          width: 1,
          height: 1,
        );
    }
  }

  Widget _buildSkipButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      right: 16,
      child: GestureDetector(
        onTap: _skip,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Text(
            'SKIP',
            style: GoogleFonts.bangers(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final total = widget.steps.length;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Text(
            '${_currentStep + 1} / $total',
            style: GoogleFonts.bangers(
              color: Colors.white,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip(Rect spotlight, Size screenSize) {
    final tooltipWidth = min(screenSize.width - 48, 340.0);
    const tooltipHeight = 180.0;

    double left = (screenSize.width - tooltipWidth) / 2;
    double top;

    if (spotlight.center.dy > screenSize.height * 0.6) {
      top = spotlight.top - tooltipHeight - 24;
    } else {
      top = spotlight.bottom + 24;
    }

    top = top.clamp(MediaQuery.of(context).padding.top + 50, screenSize.height - tooltipHeight - 20);

    return Positioned(
      left: left,
      top: top,
      width: tooltipWidth,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _step.accentColor.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _step.accentColor.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _step.title,
                style: GoogleFonts.bangers(
                  fontSize: 20,
                  color: _step.accentColor,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _step.description,
                style: GoogleFonts.bangers(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.5,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _nextStep,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _step.accentColor,
                        _step.accentColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _step.accentColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _currentStep == widget.steps.length - 1 ? "LET'S GO!" : 'NEXT',
                    style: GoogleFonts.bangers(
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect spotlight;
  final double pulseValue;
  final Color accentColor;

  _SpotlightPainter({
    required this.spotlight,
    required this.pulseValue,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dimPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final spotlightPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(spotlight, const Radius.circular(16)),
      );

    final combined = Path.combine(PathOperation.difference, path, spotlightPath);
    canvas.drawPath(combined, dimPaint);

    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.15 + pulseValue * 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 + pulseValue * 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawRRect(
      RRect.fromRectAndRadius(spotlight, const Radius.circular(16)),
      glowPaint,
    );

    final borderPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6 + pulseValue * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(spotlight, const Radius.circular(16)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      oldDelegate.spotlight != spotlight ||
      oldDelegate.pulseValue != pulseValue ||
      oldDelegate.accentColor != accentColor;
}
