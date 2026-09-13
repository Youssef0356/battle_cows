import 'package:flutter/material.dart';

enum KenneyPanelStyle {
  dialogue,
  settings,
  exit,
  container,
}

class KenneyPanel extends StatelessWidget {
  final Widget child;
  final KenneyPanelStyle style;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  const KenneyPanel({
    super.key,
    required this.child,
    this.style = KenneyPanelStyle.dialogue,
    this.width,
    this.height,
    this.padding,
  });

  String get _assetPath {
    switch (style) {
      case KenneyPanelStyle.dialogue:
        return 'assets/images/ui/dialog_bg.png';
      case KenneyPanelStyle.settings:
        return 'assets/images/ui/dialog_settings.png';
      case KenneyPanelStyle.exit:
        return 'assets/images/ui/dialog_exit.png';
      case KenneyPanelStyle.container:
        return 'assets/images/ui/dialog_container.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_assetPath),
          fit: BoxFit.fill,
          filterQuality: FilterQuality.none,
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
