import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;
  final String imagePath;

  const BackgroundWidget({
    super.key,
    required this.child,
    this.imagePath = 'assets/images/Background/Background.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
        child,
      ],
    );
  }
}
