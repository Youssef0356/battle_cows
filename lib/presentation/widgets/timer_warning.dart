import 'package:flutter/material.dart';

class TimerWarningPulse extends StatefulWidget {
  final int timeRemaining;
  final Widget child;

  const TimerWarningPulse({
    super.key,
    required this.timeRemaining,
    required this.child,
  });

  @override
  State<TimerWarningPulse> createState() => _TimerWarningPulseState();
}

class _TimerWarningPulseState extends State<TimerWarningPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(TimerWarningPulse old) {
    super.didUpdateWidget(old);
    if (widget.timeRemaining <= 10 && widget.timeRemaining > 0) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWarning = widget.timeRemaining <= 10 && widget.timeRemaining > 0;
    final isCritical = widget.timeRemaining <= 5 && widget.timeRemaining > 0;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseAlpha = isWarning ? _pulseController.value * 0.4 : 0.0;
        final borderWidth = isWarning ? 3.0 + _pulseController.value * 3.0 : 0.0;
        final borderColor = isCritical
            ? Colors.red.withValues(alpha: pulseAlpha + 0.3)
            : Colors.orange.withValues(alpha: pulseAlpha + 0.2);

        return Container(
          decoration: isWarning
              ? BoxDecoration(
                  border: Border.all(
                    color: borderColor,
                    width: borderWidth,
                  ),
                  borderRadius: BorderRadius.circular(0),
                  boxShadow: [
                    BoxShadow(
                      color: (isCritical ? Colors.red : Colors.orange)
                          .withValues(alpha: pulseAlpha * 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                )
              : null,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
