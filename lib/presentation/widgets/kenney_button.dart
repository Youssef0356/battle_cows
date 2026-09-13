import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum KenneyBtnStyle {
  primary,
  secondary,
  neutral,
  danger,
  close,
  iconGreen,
  iconRed,
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
  bool _isPressed = false;

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
    final suffix = _isPressed ? '_active' : '';
    switch (widget.style) {
      case KenneyBtnStyle.primary:
        return 'assets/images/ui/btn_primary$suffix.png';
      case KenneyBtnStyle.secondary:
        return 'assets/images/ui/btn_secondary$suffix.png';
      case KenneyBtnStyle.neutral:
        return 'assets/images/ui/btn_neutral$suffix.png';
      case KenneyBtnStyle.danger:
        return 'assets/images/ui/btn_danger$suffix.png';
      case KenneyBtnStyle.close:
        return 'assets/images/ui/btn_close$suffix.png';
      case KenneyBtnStyle.iconGreen:
        return 'assets/images/ui/icon_btn_green$suffix.png';
      case KenneyBtnStyle.iconRed:
        return 'assets/images/ui/icon_btn_red$suffix.png';
    }
  }

  bool get _isRound =>
      widget.style == KenneyBtnStyle.close ||
      widget.style == KenneyBtnStyle.iconGreen ||
      widget.style == KenneyBtnStyle.iconRed;

  bool get _isMedium =>
      widget.style == KenneyBtnStyle.secondary;

  @override
  Widget build(BuildContext context) {
    final double btnHeight = widget.height ?? (_isRound ? 60 : 56);
    final double btnWidth = _isRound
        ? 60
        : (_isMedium
            ? (widget.isWide ? 280 : 200)
            : (widget.isWide ? 400 : 300));
    final double textSize = widget.fontSize ?? (_isRound ? 18 : 22);

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
          setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          _controller.reverse();
          setState(() => _isPressed = false);
          widget.onPressed?.call();
        },
        onTapCancel: () {
          _controller.reverse();
          setState(() => _isPressed = false);
        },
        child: SizedBox(
          width: btnWidth,
          height: btnHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                _assetPath,
                width: btnWidth,
                height: btnHeight,
                fit: _isRound ? BoxFit.contain : BoxFit.fill,
                gaplessPlayback: true,
              ),
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
