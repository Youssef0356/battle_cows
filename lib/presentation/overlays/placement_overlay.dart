import 'dart:math';
import 'package:flutter/material.dart';
import '../../assets/asset_paths.dart';
import '../../core/localization/app_fonts.dart';
import '../../core/localization/app_localizations.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/player.dart';
import '../../core/constants/colors.dart';
import 'hud_overlay.dart';

class PlacementOverlay extends StatefulWidget {
  final BattleCowsGame game;

  /// Extra top spacing (the ad banner height) so the top bar sits below the
  /// banner instead of being covered by it.
  final double topInset;

  const PlacementOverlay({
    super.key,
    required this.game,
    this.topInset = 0,
  });

  @override
  State<PlacementOverlay> createState() => _PlacementOverlayState();
}

class _PlacementOverlayState extends State<PlacementOverlay> {
  late final void Function() _stateListener;

  @override
  void initState() {
    super.initState();
    _stateListener = () {
      if (mounted) setState(() {});
    };
    widget.game.addStateListener(_stateListener);
  }

  @override
  void dispose() {
    widget.game.removeStateListener(_stateListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final game = widget.game;
    final currentPlayerIndex = game.currentPlayerIndex;
    final players = game.players;
    final tilesRemaining = game.tilesRemaining;
    final currentTile = game.currentTile;
    final canPlace = game.canPlaceCurrentTile;
    final isAi = currentPlayerIndex < players.length && players[currentPlayerIndex].isAi;

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(currentPlayerIndex, players, tilesRemaining, l10n),
            const Expanded(child: IgnorePointer(child: SizedBox.expand())),
            if (!isAi && currentTile != null)
              _buildBottomControls(canPlace, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(int currentPlayerIndex, List<Player> players, List<int> tilesRemaining, AppLocalizations l10n) {
    final tilesLeft = currentPlayerIndex < tilesRemaining.length ? tilesRemaining[currentPlayerIndex] : 0;
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final isTablet = media.size.shortestSide >= 600;
    final sidePadding = isTablet ? 32.0 : (screenWidth < 360 ? 10.0 : 16.0);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(sidePadding, 8 + widget.topInset, sidePadding, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Align(alignment: Alignment.centerLeft, child: _buildPhaseBox(l10n, isTablet: isTablet, screenWidth: screenWidth))),
                Expanded(child: Center(child: _buildTilesLeftBox(tilesLeft, isTablet: isTablet, screenWidth: screenWidth))),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: HudOverlay(game: widget.game, players: players).buildSettingsButton(context, isTablet: isTablet),
                  ),
                ),
              ],
            ),
            _buildTilePlayerChipsBar(currentPlayerIndex, players, tilesRemaining, isTablet: isTablet, screenWidth: screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseBox(AppLocalizations l10n, {bool isTablet = false, double screenWidth = 400}) {
    final width = isTablet ? 112.0 : (screenWidth < 360 ? 76.0 : 88.0);
    final height = isTablet ? 78.0 : (screenWidth < 360 ? 54.0 : 64.0);
    final fontScale = (width / 88.0).clamp(0.85, 1.3).toDouble();

    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetPaths.uiHudCounterPlaque),
          fit: BoxFit.fill,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6 * fontScale, vertical: 4 * fontScale),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🌾 PHASE',
              style: AppFonts.bangers(
                fontSize: (8.5 * fontScale).clamp(7.5, 12.0).toDouble(),
                color: Colors.white70,
                letterSpacing: 0.6,
              ),
            ),
            Text(
              'PASTURE',
              style: AppFonts.bangers(
                fontSize: (12.5 * fontScale).clamp(11.0, 18.0).toDouble(),
                color: const Color(0xFFFFD54F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTilesLeftBox(int tiles, {bool isTablet = false, double screenWidth = 400}) {
    final width = isTablet ? 108.0 : (screenWidth < 360 ? 74.0 : 88.0);
    final height = isTablet ? 78.0 : (screenWidth < 360 ? 54.0 : 64.0);
    final fontScale = (width / 88.0).clamp(0.85, 1.3).toDouble();

    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetPaths.uiHudCounterPlaque),
          fit: BoxFit.fill,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 6 * fontScale, vertical: 4 * fontScale),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'TILES LEFT',
              style: AppFonts.bangers(
                fontSize: (8.5 * fontScale).clamp(7.5, 12.0).toDouble(),
                color: Colors.white70,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '$tiles',
              style: AppFonts.bangers(
                fontSize: (15.5 * fontScale).clamp(13.5, 22.0).toDouble(),
                color: const Color(0xFFFFD54F),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTilePlayerChipsBar(int currentPlayerIndex, List<Player> players, List<int> tilesRemaining, {bool isTablet = false, double screenWidth = 400}) {
    if (players.length == 2) {
      final p1 = players[0];
      final p2 = players[1];
      final p1Turn = 0 == currentPlayerIndex;
      final p2Turn = 1 == currentPlayerIndex;
      final p1Tiles = tilesRemaining.isNotEmpty ? tilesRemaining[0] : 0;
      final p2Tiles = tilesRemaining.length > 1 ? tilesRemaining[1] : 0;

      final maxAllowed = screenWidth - (isTablet ? 64.0 : 20.0);
      final targetW = isTablet ? 450.0 : 330.0;
      final barWidth = min(maxAllowed, targetW);
      final barHeight = (barWidth * (173.0 / 897.0)).clamp(48.0, 88.0).toDouble();
      final scale = (barWidth / 330.0).clamp(0.8, 1.35).toDouble();

      return Container(
        margin: const EdgeInsets.only(top: 6),
        width: barWidth,
        height: barHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.uiScoreboardRibbonsBar),
            fit: BoxFit.fill,
          ),
        ),
        child: Row(
          children: [
            // Left Blue Ribbon: Player 1 (Blue)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16 * scale, right: 4 * scale, bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      p1.isAi ? '🤖' : '🐮',
                      style: TextStyle(fontSize: (11 * scale).clamp(9.5, 16.0).toDouble()),
                    ),
                    SizedBox(width: 3 * scale),
                    Flexible(
                      child: Text(
                        p1.name.length > 7 ? p1.name.substring(0, 7) : p1.name,
                        style: AppFonts.bangers(
                          fontSize: (10.5 * scale).clamp(9.0, 15.0).toDouble(),
                          color: p1Turn ? Colors.white : Colors.white70,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4 * scale),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5 * scale, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(5 * scale),
                      ),
                      child: Text(
                        '$p1Tiles',
                        style: AppFonts.bangers(
                          fontSize: (11.5 * scale).clamp(10.0, 17.0).toDouble(),
                          color: const Color(0xFFFFD54F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right Red Ribbon: Player 2 / AI (Red)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 4 * scale, right: 16 * scale, bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      p2.isAi ? '🤖' : '🐮',
                      style: TextStyle(fontSize: (11 * scale).clamp(9.5, 16.0).toDouble()),
                    ),
                    SizedBox(width: 3 * scale),
                    Flexible(
                      child: Text(
                        p2.name.length > 7 ? p2.name.substring(0, 7) : p2.name,
                        style: AppFonts.bangers(
                          fontSize: (10.5 * scale).clamp(9.0, 15.0).toDouble(),
                          color: p2Turn ? Colors.white : Colors.white70,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4 * scale),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5 * scale, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(5 * scale),
                      ),
                      child: Text(
                        '$p2Tiles',
                        style: AppFonts.bangers(
                          fontSize: (11.5 * scale).clamp(10.0, 17.0).toDouble(),
                          color: const Color(0xFFFFD54F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3E2723).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(players.length, (index) {
          final player = players[index];
          final isTurn = index == currentPlayerIndex;
          final tilesLeft = index < tilesRemaining.length ? tilesRemaining[index] : 0;
          final primary = AppColors.getPlayerPrimary(player.color);

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isTurn
                    ? [primary, primary.withValues(alpha: 0.8)]
                    : [const Color(0xFF2E1C0C).withValues(alpha: 0.8), const Color(0xFF1B0E06).withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isTurn ? const Color(0xFFFFD54F) : primary.withValues(alpha: 0.5),
                width: isTurn ? 2.0 : 1.2,
              ),
              boxShadow: isTurn
                  ? [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  player.isAi ? '🤖' : '🐮',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  player.name.length > 8 ? player.name.substring(0, 8) : player.name,
                  style: AppFonts.bangers(
                    fontSize: 11,
                    color: isTurn ? Colors.white : Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$tilesLeft',
                    style: AppFonts.bangers(
                      fontSize: 12,
                      color: const Color(0xFFFFD54F),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomControls(bool canPlace, AppLocalizations l10n) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final isTablet = media.size.shortestSide >= 600;

    final bannerWidth = min(screenWidth - (isTablet ? 64.0 : 20.0), isTablet ? 520.0 : 410.0);
    final bannerHeight = (bannerWidth * (225.0 / 1273.0)).clamp(56.0, 90.0).toDouble();

    final btnWidth = (bannerWidth * 0.43).clamp(110.0, 195.0).toDouble();
    final btnHeight = (btnWidth * (140.0 / 415.0)).clamp(36.0, 58.0).toDouble();
    final fontScale = (btnWidth / 140.0).clamp(0.85, 1.35).toDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      width: bannerWidth,
      height: bannerHeight,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetPaths.uiBottomInstructionBanner),
          fit: BoxFit.fill,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14 * fontScale, vertical: 6 * fontScale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Rotate button (Brown action button)
          GestureDetector(
            onTap: () => widget.game.rotateCurrentTile(),
            child: Container(
              width: btnWidth,
              height: btnHeight,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AssetPaths.uiBtnActionBrown),
                  fit: BoxFit.fill,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.rotate_right_rounded, color: Colors.white, size: 18 * fontScale),
                    SizedBox(width: 5 * fontScale),
                    Text(
                      l10n.rotate.toUpperCase(),
                      style: AppFonts.bangers(
                        fontSize: (14.0 * fontScale).clamp(11.5, 20.0).toDouble(),
                        color: Colors.white,
                        letterSpacing: 1,
                        shadows: const [
                          Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Place button (Green action button)
          Opacity(
            opacity: canPlace ? 1.0 : 0.45,
            child: GestureDetector(
              onTap: canPlace ? () => widget.game.placeCurrentTile() : null,
              child: Container(
                width: btnWidth,
                height: btnHeight,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetPaths.uiBtnActionGreen),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.white, size: 18 * fontScale),
                      SizedBox(width: 5 * fontScale),
                      Text(
                        l10n.place.toUpperCase(),
                        style: AppFonts.bangers(
                          fontSize: (14.0 * fontScale).clamp(11.5, 20.0).toDouble(),
                          color: Colors.white,
                          letterSpacing: 1,
                          shadows: const [
                            Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
