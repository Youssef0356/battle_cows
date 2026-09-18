import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartoonDialog extends StatefulWidget {
  final String? title;
  final Widget child;
  final Color accentColor;
  final double maxWidth;
  final bool dismissible;

  const CartoonDialog({
    super.key,
    this.title,
    required this.child,
    this.accentColor = const Color(0xFFFFD54F),
    this.maxWidth = 340,
    this.dismissible = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    Color accentColor = const Color(0xFFFFD54F),
    double maxWidth = 340,
    bool dismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: 'CartoonDialog',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secondaryAnim, _) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: CartoonDialog(
              title: title,
              accentColor: accentColor,
              maxWidth: maxWidth,
              dismissible: dismissible,
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  State<CartoonDialog> createState() => _CartoonDialogState();
}

class _CartoonDialogState extends State<CartoonDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _bobController;
  late Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _bobAnimation = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bobAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bobAnimation.value),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.maxWidth),
              child: _buildBody(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3E2723), Color(0xFF1B0000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.accentColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.title != null) _buildTitle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.accentColor.withValues(alpha: 0.25),
            widget.accentColor.withValues(alpha: 0.08),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(
            color: widget.accentColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.title!,
            style: GoogleFonts.bangers(
              fontSize: 24,
              color: widget.accentColor,
              letterSpacing: 2,
              shadows: [
                const Shadow(
                  color: Colors.black54,
                  offset: Offset(1, 2),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartoonButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color baseColor;
  final Color borderColor;
  final bool isWide;
  final double height;
  final double fontSize;

  const CartoonButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.baseColor = const Color(0xFF5D4037),
    this.borderColor = const Color(0xFF8D6E63),
    this.isWide = false,
    this.height = 48,
    this.fontSize = 16,
  });

  @override
  State<CartoonButton> createState() => _CartoonButtonState();
}

class _CartoonButtonState extends State<CartoonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        transform: _isPressed
            ? (Matrix4.diagonal3Values(0.95, 0.95, 1))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        width: widget.isWide ? double.infinity : null,
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _lighten(widget.baseColor, 0.1),
              widget.baseColor,
              _darken(widget.baseColor, 0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isPressed ? 0.2 : 0.4),
              blurRadius: _isPressed ? 2 : 6,
              offset: Offset(0, _isPressed ? 1 : 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: widget.isWide ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: Colors.white, size: widget.fontSize + 2),
              const SizedBox(width: 6),
            ],
            Text(
              widget.label,
              style: GoogleFonts.bangers(
                fontSize: widget.fontSize,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: const [
                  Shadow(
                    color: Colors.black45,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightened = hsl.withLightness((hsl.lightness + amount).clamp(0, 1));
    return lightened.toColor();
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0, 1));
    return darkened.toColor();
  }
}
