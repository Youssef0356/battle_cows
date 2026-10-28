import 'package:flutter/material.dart';
import '../../core/localization/app_fonts.dart';
import '../../core/localization/app_localizations.dart';
import '../../game/tutorial/tutorial_data.dart';
import '../widgets/bouncy_pressable.dart';

/// First-match tutorial coach. The parent owns the step index so game events
/// (tile placement done, first move, …) can auto-advance steps.
///
/// Two looks:
///  * [TutorialStep.blocking] — full cartoon bubble card that covers the board until
///    the player taps the button (intro & outro).
///  * otherwise — a compact coach banner near the bottom that never blocks
///    board input, so the player can perform the taught action immediately.
class TutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const TutorialOverlay({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.onNext,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
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

  TutorialStep get _step => widget.steps[widget.currentStep];

  bool get _isLast => widget.currentStep >= widget.steps.length - 1;

  String _buttonLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLast) return l10n.letsPlay;
    if (widget.currentStep == 0) return l10n.startExclamation;
    return l10n.doneBtn;
  }

  void _handleButton() {
    if (_isLast) {
      widget.onComplete();
    } else {
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        // Blocking scrim sits under the counter/SKIP so they stay tappable.
        if (_step.blocking)
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.65)),
            ),
          ),

        // Step counter chip centered at the top
        Positioned(
          top: topPadding + 10,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4E342E), Color(0xFF2E1C0C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  l10n.tutorialStepCounter(widget.currentStep + 1, widget.steps.length),
                  style: AppFonts.bangers(
                    color: const Color(0xFFFFD54F),
                    fontSize: 13,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),

        // High-contrast, vibrant, and obvious SKIP button in the top corner
        PositionedDirectional(
          top: topPadding + 8,
          end: 14,
          child: BouncyPressable(
            scaleDown: 0.90,
            onTap: widget.onSkip,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFCDD2), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fast_forward_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    l10n.skip,
                    style: AppFonts.bangers(
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (_step.blocking)
          _buildBlockingCard(topPadding, l10n)
        else
          _buildCoachBanner(topPadding, l10n),
      ],
    );
  }

  /// Full cartoon dialog card for intro/outro steps
  Widget _buildBlockingCard(double topPadding, AppLocalizations l10n) {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.only(top: topPadding + 64, left: 20, right: 20, bottom: 24),
        child: Center(
          child: SingleChildScrollView(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, _) {
                final glow = 0.5 + _pulseAnimation.value * 0.4;
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // Main Wood Dialog Box
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 45),
                      padding: const EdgeInsets.fromLTRB(22, 52, 22, 22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5D4037), Color(0xFF3E2723), Color(0xFF2E1C0C)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFFFD54F).withValues(alpha: glow),
                          width: 3.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD54F).withValues(alpha: glow * 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.7),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Step Title Banner
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8D6E63), Color(0xFF4E342E)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                            ),
                            child: Text(
                              _step.localizedTitle(widget.currentStep, context),
                              style: AppFonts.bangers(
                                fontSize: 22,
                                color: const Color(0xFFFFD54F),
                                letterSpacing: 1.5,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(1.5, 1.5),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Description
                          Text(
                            _step.localizedDescription(widget.currentStep, context),
                            style: AppFonts.bangers(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.95),
                              letterSpacing: 0.6,
                              height: 1.35,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Big Vibrant Main Action Button (Green punchy button)
                          BouncyPressable(
                            scaleDown: 0.94,
                            onTap: _handleButton,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF43A047), Color(0xFF2E7D32), Color(0xFF1B5E20)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFA5D6A7), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                _buttonLabel(context),
                                style: AppFonts.bangers(
                                  fontSize: 22,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(1.5, 1.5),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Farmer Cow Avatar Head protruding from the top
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF3E2723),
                          border: Border.all(color: const Color(0xFFFFD54F), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Image.asset(
                              'assets/images/Cows/cow_farmer.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Text('🐮', style: TextStyle(fontSize: 40))),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Compact coach banner for actionable steps: sits above the bottom
  /// controls (place/rotate bar, move slider) and never blocks board taps
  /// outside its own bounds.
  Widget _buildCoachBanner(double topPadding, AppLocalizations l10n) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 118,
      child: IgnorePointer(
        ignoring: false,
        child: BouncyPressable(
          scaleDown: 0.98,
          onTap: _handleButton,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              final glow = 0.4 + _pulseAnimation.value * 0.4;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4E342E), Color(0xFF2E1C0C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _step.accentColor.withValues(alpha: glow + 0.2),
                    width: 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _step.accentColor.withValues(alpha: glow * 0.35),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Farmer Cow Thumbnail Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF3E2723),
                        border: Border.all(color: _step.accentColor, width: 2),
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Image.asset(
                            'assets/images/Cows/cow_farmer.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Text('🐮', style: TextStyle(fontSize: 22))),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Title & Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _step.localizedTitle(widget.currentStep, context),
                            style: AppFonts.bangers(
                              fontSize: 16,
                              color: _step.accentColor,
                              letterSpacing: 1.2,
                              shadows: const [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _step.localizedDescription(widget.currentStep, context),
                            style: AppFonts.bangers(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.92),
                              letterSpacing: 0.4,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // "DONE ›" Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _step.accentColor,
                            _step.accentColor.withValues(alpha: 0.75),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white38, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${l10n.doneBtn} ›',
                        style: AppFonts.bangers(
                          fontSize: 13,
                          color: const Color(0xFF1B0000),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
