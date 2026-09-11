import 'package:flutter/material.dart';

class RusticPlank extends StatelessWidget {
  final Widget child;
  final Color color;
  final int seed;
  final EdgeInsetsGeometry padding;

  const RusticPlank({
    super.key,
    required this.child,
    this.color = const Color(0xFF4E342E),
    this.seed = 0,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF8D6E63)),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 5, offset: Offset(0, 2))],
        ),
        child: child,
      );
}

class RopeStrap extends StatelessWidget {
  final Alignment alignment;
  final double width;
  final double height;

  const RopeStrap({super.key, required this.alignment, required this.width, required this.height});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        alignment: alignment,
        decoration: BoxDecoration(
          color: const Color(0xFF5D4037),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF8D6E63)),
        ),
      );
}
