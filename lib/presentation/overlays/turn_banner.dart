import 'package:flutter/material.dart';
import '../../assets/asset_paths.dart';
import '../../core/localization/app_fonts.dart';
import '../../core/localization/app_localizations.dart';

class TurnBanner extends StatefulWidget {
  final String playerName;
  final Color playerColor;
  final bool isAi;
  final String? cowAsset;
  final VoidCallback? onComplete;

  const TurnBanner({
    super.key,
    required this.playerName,
    required this.playerColor,
    this.isAi = false,
    this.cowAsset,
    this.onComplete,
  });

  @override
  State<TurnBanner> createState() => _TurnBannerState();
}

class _TurnBannerState extends State<TurnBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _slideAnim = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bannerBg = _getBannerGradient(widget.playerColor);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnim.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, _slideAnim.value * -35),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: bannerBg,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFFFD54F),
                    width: 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.playerColor.withValues(alpha: 0.45),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      widget.cowAsset ?? _getCowAsset(widget.playerColor),
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isAi ? l10n.cpuTurn.toUpperCase() : l10n.playerTurn.toUpperCase(),
                          style: AppFonts.bangers(
                            fontSize: 10.5,
                            color: const Color(0xFFFFD54F),
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          widget.playerName.toUpperCase(),
                          style: AppFonts.bangers(
                            fontSize: 17,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            shadows: const [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(1, 1),
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
        },
      ),
    );
  }

  List<Color> _getBannerGradient(Color color) {
    final hex = color.toARGB32() & 0x00FFFFFF;
    if (hex == 0x2E86DE || hex == 0x1E88E5 || hex == 0x2196F3) {
      return const [Color(0xFF2E86DE), Color(0xFF1B4F72), Color(0xFF0E3048)];
    } else if (hex == 0xE74C3C || hex == 0xE53935 || hex == 0xF44336) {
      return const [Color(0xFFE74C3C), Color(0xFFC0392B), Color(0xFF78281F)];
    } else if (hex == 0xF5B400 || hex == 0xFDD835 || hex == 0xFFFFEB3B || hex == 0xFFB300) {
      return const [Color(0xFFF5B400), Color(0xFFD68910), Color(0xFF7E5109)];
    } else if (hex == 0x8E44AD || hex == 0x8E24AA || hex == 0x9C27B0) {
      return const [Color(0xFF8E44AD), Color(0xFF6C3483), Color(0xFF4A235A)];
    }
    return [color, _darken(color, 0.2), _darken(color, 0.4)];
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0, 1)).toColor();
  }

  String _getCowAsset(Color color) {
    final hex = color.toARGB32() & 0x00FFFFFF;
    if (hex == 0x2E86DE || hex == 0x1E88E5 || hex == 0x2196F3) {
      return AssetPaths.cowP1HolsteinIdle;
    } else if (hex == 0xE74C3C || hex == 0xE53935 || hex == 0xF44336) {
      return AssetPaths.cowP2HighlandIdle;
    } else if (hex == 0xF5B400 || hex == 0xFDD835 || hex == 0xFFFFEB3B || hex == 0xFFB300) {
      return 'assets/images/Cows/cow_farmer.png';
    } else if (hex == 0x8E44AD || hex == 0x8E24AA || hex == 0x9C27B0) {
      return 'assets/images/Cows/cow_disco.png';
    }
    return AssetPaths.cowP1HolsteinIdle;
  }
}
