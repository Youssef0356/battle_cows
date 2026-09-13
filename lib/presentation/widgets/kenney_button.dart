import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum KenneyBtnStyle {
  primary,
  neutral,
  danger,
  round,
  roundDark,
  roundNeutral,
}

class KenneyButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final KenneyBtnStyle style;
  final bool isWide;
  final double? fontSize;
  final double? height;

  const KenneyButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.style = KenneyBtnStyle.primary,
    this.isWide = false,
    this.fontSize,
    this.height,
  });

  @override
  State<KenneyButton> createState() => _KenneyButtonState();
}

class _KenneyButtonState extends State<KenneyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _assetPath {
    switch (widget.style) {
      case KenneyBtnStyle.primary:
        return 'assets/images/ui/btn_primary.png';
      case KenneyBtnStyle.neutral:
        return 'assets/images/ui/btn_neutral.png';
      case KenneyBtnStyle.danger:
        return 'assets/images/ui/btn_danger.png';
      case KenneyBtnStyle.round:
        return 'assets/images/ui/btn_round.png';
      case KenneyBtnStyle.roundDark:
        return 'assets/images/ui/btn_round_dark.png';
      case KenneyBtnStyle.roundNeutral:
        return 'assets/images/ui/btn_round_neutral.png';
    }
  }

  bool get _isRound =>
      widget.style == KenneyBtnStyle.round ||
      widget.style == KenneyBtnStyle.roundDark ||
      widget.style == KenneyBtnStyle.roundNeutral;

  @override
  Widget build(BuildContext context) {
    final double btnHeight = widget.height ?? (_isRound ? 64 : 48);
    final double btnWidth = _isRound ? 64 : (widget.isWide ? 200 : 140);
    final double textSize = widget.fontSize ?? (_isRound ? 18 : 16);

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          _controller.forward();
        },
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed?.call();
        },
        onTapCancel: () {
          _controller.reverse();
        },
        child: SizedBox(
          width: btnWidth,
          height: btnHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 9-patch button background
              Image.asset(
                _assetPath,
                width: _isRound ? btnHeight : btnWidth,
                height: btnHeight,
                fit: _isRound ? BoxFit.contain : BoxFit.fill,
                gaplessPlayback: true,
              ),
              // Label + icon
              if (widget.label.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: textSize, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      widget.label,
                      style: GoogleFonts.bangers(
                        fontSize: textSize,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(1, 2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
