import 'package:flutter/material.dart';

/// Chevrons along the four screen edges hinting that the board can be
/// dragged ("hold and move").
///
/// While [emphasized] is true the badges pulse brightly; after the first
/// drag they settle into a faint static hint so they never clutter the board.
class PanIndicators extends StatefulWidget {
  final bool emphasized;

  /// Distance from the top where the up chevron starts (keeps it clear of
  /// the HUD row / ad banner).
  final double topInset;

  /// Distance from the bottom where the down chevron ends (keeps it clear
  /// of the move-cows bar and, when present, the fence action bar).
  final double bottomInset;

  const PanIndicators({
    super.key,
    this.emphasized = true,
    this.topInset = 62,
    this.bottomInset = 124,
  });

  @override
  State<PanIndicators> createState() => _PanIndicatorsState();
}

class _PanIndicatorsState extends State<PanIndicators>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(PanIndicators oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.emphasized != widget.emphasized) _syncPulse();
  }

  void _syncPulse() {
    if (widget.emphasized) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  double get _opacity {
    if (!widget.emphasized) return 0.22;
    return 0.30 + 0.45 * _pulse.value;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) => Opacity(
          opacity: _opacity,
          child: Stack(
            children: [
              Positioned(
                left: 6,
                top: 0,
                bottom: 0,
                child: Center(child: _badge(Icons.chevron_left)),
              ),
              Positioned(
                right: 6,
                top: 0,
                bottom: 0,
                child: Center(child: _badge(Icons.chevron_right)),
              ),
              Positioned(
                top: widget.topInset,
                left: 0,
                right: 0,
                child: Center(child: _badge(Icons.expand_less)),
              ),
              Positioned(
                bottom: widget.bottomInset,
                left: 0,
                right: 0,
                child: Center(child: _badge(Icons.expand_more)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Icon(icon, size: 30, color: Colors.white),
    );
  }
}
