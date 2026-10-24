import 'package:flutter/material.dart';
import '../../core/localization/app_fonts.dart';
import '../../core/localization/app_localizations.dart';
import '../../game/tutorial/tutorial_data.dart';

/// First-match tutorial coach. The parent owns the step index so game events
/// (tile placement done, first move, …) can auto-advance steps.
///
/// Two looks:
///  * [TutorialStep.blocking] — full bubble card that covers the board until
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
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.55)),
            ),
          ),
        // Step counter chip.
        Positioned(
          top: topPadding + 8,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Text(
                  l10n.tutorialStepCounter(widget.currentStep + 1, widget.steps.length),
                  style: AppFonts.bangers(
                    color: _step.accentColor,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Skip button.
        Positioned(
          top: topPadding + 8,
          right: 16,
          child: GestureDetector(
            onTap: widget.onSkip,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Text(
                l10n.skip,
                style: AppFonts.bangers(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  letterSpacing: 1,
                ),
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

  /// Full card for intro/outro steps; the dim scrim is a separate layer under
  /// the counter/SKIP chips so they remain tappable.
  Widget _buildBlockingCard(double topPadding, AppLocalizations l10n) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding + 56, left: 16, right: 16, bottom: 16),
        child: Center(
          child: SingleChildScrollView(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, _) {
                final glow = 0.5 + _pulseAnimation.value * 0.35;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5D4037), Color(0xFF2E1C0C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _step.accentColor.withValues(alpha: glow),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _step.accentColor.withValues(alpha: glow * 0.35),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _step.localizedTitle(widget.currentStep, context),
                        style: AppFonts.bangers(
                          fontSize: 22,
                          color: _step.accentColor,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _step.localizedDescription(widget.currentStep, context),
                        style: AppFonts.bangers(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 0.5,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _handleButton,
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
                          ),
                          child: Text(
                            _buttonLabel(context),
                            style: AppFonts.bangers(
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
        child: GestureDetector(
          onTap: _handleButton,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              final glow = 0.35 + _pulseAnimation.value * 0.35;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4E342E), Color(0xFF2E1C0C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _step.accentColor.withValues(alpha: glow + 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _step.accentColor.withValues(alpha: glow * 0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _step.accentColor,
                            _step.accentColor.withValues(alpha: 0.65),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.currentStep + 1}',
                          style: AppFonts.bangers(
                            fontSize: 16,
                            color: const Color(0xFF1B0000),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _step.localizedTitle(widget.currentStep, context),
                            style: AppFonts.bangers(
                              fontSize: 15,
                              color: _step.accentColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _step.localizedDescription(widget.currentStep, context),
                            style: AppFonts.bangers(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.88),
                              letterSpacing: 0.4,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: _step.accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _step.accentColor.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(
                        '${l10n.doneBtn} ›',
                        style: AppFonts.bangers(
                          fontSize: 12,
                          color: _step.accentColor,
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
