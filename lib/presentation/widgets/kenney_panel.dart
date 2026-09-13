import 'package:flutter/material.dart';

enum KenneyPanelStyle {
  wood,
  woodDark,
  fantasy0,
  fantasy1,
  fantasy2,
  fantasy3,
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
    this.style = KenneyPanelStyle.wood,
    this.width,
    this.height,
    this.padding,
  });

  String get _assetPath {
    switch (style) {
      case KenneyPanelStyle.wood:
        return 'assets/images/ui/panel.png';
      case KenneyPanelStyle.woodDark:
        return 'assets/images/ui/panel_dark.png';
      case KenneyPanelStyle.fantasy0:
        return 'assets/images/ui/panel_fantasy_0.png';
      case KenneyPanelStyle.fantasy1:
        return 'assets/images/ui/panel_fantasy_1.png';
      case KenneyPanelStyle.fantasy2:
        return 'assets/images/ui/panel_fantasy_2.png';
      case KenneyPanelStyle.fantasy3:
        return 'assets/images/ui/panel_fantasy_3.png';
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
          repeat: ImageRepeat.repeat,
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
