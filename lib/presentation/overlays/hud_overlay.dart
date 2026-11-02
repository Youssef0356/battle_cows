import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/localization/app_fonts.dart';
import '../../core/localization/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../assets/asset_paths.dart';
import '../../data/models/shop_item.dart';
import '../../data/services/progress_service.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/player.dart';
import '../../game/models/challenge_mode.dart';
import '../../core/constants/colors.dart';
import '../widgets/cartoon_dialog.dart';
import '../widgets/kenney_button.dart';

class HudOverlay extends StatelessWidget {
  final BattleCowsGame game;
  final List<Player> players;

  /// Extra top spacing (the ad banner height) so the timer/settings row sits
  /// below the banner instead of being covered by it.
  final double topInset;

  const HudOverlay({
    super.key,
    required this.game,
    required this.players,
    this.topInset = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (game.engine.players.isEmpty) return const SizedBox.shrink();
    final turnCount = game.engine.turnCount + 1;
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final isTablet = media.size.shortestSide >= 600;
    final sidePadding = isTablet ? 32.0 : (screenWidth < 360 ? 10.0 : 16.0);

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.fromLTRB(sidePadding, 8 + topInset, sidePadding, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: Align(alignment: Alignment.centerLeft, child: _buildTimerBox(isTablet: isTablet, screenWidth: screenWidth))),
                    Expanded(child: Center(child: _buildTurnCounterBox(turnCount, isTablet: isTablet, screenWidth: screenWidth))),
                    Expanded(child: Align(alignment: Alignment.centerRight, child: buildSettingsButton(context, isTablet: isTablet))),
                  ],
                ),
                _buildLiveScoreBar(context, isTablet: isTablet, screenWidth: screenWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerBox({bool isTablet = false, double screenWidth = 400}) {
    final timeRemaining = game.timeRemaining;
    final hasTimer = game.challengeMode.hasTimer;
    final isLowTime = hasTimer && timeRemaining <= 10;
    final isFenceBattle = game.challengeMode == ChallengeMode.fenceChallenge;

    final width = isTablet ? 116.0 : (screenWidth < 360 ? 78.0 : 92.0);
    final height = isTablet ? 78.0 : (screenWidth < 360 ? 54.0 : 62.0);
    final fontScale = (width / 92.0).clamp(0.85, 1.3).toDouble();

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
        child: hasTimer
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22 * fontScale,
                    height: 22 * fontScale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: (timeRemaining / 60.0).clamp(0.0, 1.0).toDouble(),
                          strokeWidth: 2.6 * fontScale,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isLowTime ? const Color(0xFFFF5252) : const Color(0xFFFFD54F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4 * fontScale),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⏱️ TIME',
                        style: AppFonts.bangers(
                          fontSize: (8.5 * fontScale).clamp(7.5, 12.0).toDouble(),
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        isLowTime ? 'HURRY!' : '$timeRemaining s',
                        style: AppFonts.bangers(
                          fontSize: (9.5 * fontScale).clamp(8.5, 14.0).toDouble(),
                          color: isLowTime ? const Color(0xFFFF8A80) : const Color(0xFFFFD54F),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isFenceBattle ? 'WOOD' : 'FREE PLAY',
                    style: AppFonts.bangers(
                      fontSize: (9.0 * fontScale).clamp(8.0, 13.0).toDouble(),
                      color: Colors.white70,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    isFenceBattle ? 'FENCE' : '∞',
                    style: AppFonts.bangers(
                      fontSize: (15.0 * fontScale).clamp(13.0, 22.0).toDouble(),
                      color: const Color(0xFFFFD54F),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTurnCounterBox(int turn, {bool isTablet = false, double screenWidth = 400}) {
    final width = isTablet ? 108.0 : (screenWidth < 360 ? 74.0 : 86.0);
    final height = isTablet ? 78.0 : (screenWidth < 360 ? 54.0 : 62.0);
    final fontScale = (width / 86.0).clamp(0.85, 1.3).toDouble();

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
              'TURN',
              style: AppFonts.bangers(
                fontSize: (9.5 * fontScale).clamp(8.5, 14.0).toDouble(),
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
            Text(
              '$turn',
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

  Widget _buildLiveScoreBar(BuildContext context, {bool isTablet = false, double screenWidth = 400}) {
    final territoryCounts = game.territoryCounts;
    final currentP = game.engine.players.isNotEmpty ? game.engine.currentPlayer : null;

    if (players.length == 2) {
      final p1 = players[0];
      final p2 = players[1];
      final p1Turn = currentP?.color == p1.color;
      final p2Turn = currentP?.color == p2.color;
      final p1Score = territoryCounts[p1.color] ?? 0;
      final p2Score = territoryCounts[p2.color] ?? 0;

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
                        '$p1Score',
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
                        '$p2Score',
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
        children: players.map((p) {
          final isTurn = currentP != null && currentP.color == p.color;
          final count = territoryCounts[p.color] ?? 0;
          final primary = AppColors.getPlayerPrimary(p.color);
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
                  p.isAi ? '🤖' : '🐮',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  p.name.length > 8 ? p.name.substring(0, 8) : p.name,
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
                    '$count',
                    style: AppFonts.bangers(
                      fontSize: 12,
                      color: const Color(0xFFFFD54F),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildSettingsButton(BuildContext context, {bool isTablet = false}) {
    final l10n = AppLocalizations.of(context);
    final btnSize = isTablet ? 54.0 : 44.0;
    return GestureDetector(
      onTap: () {
        CartoonDialog.show(
          context: context,
          title: l10n.gamePaused,
          maxWidth: 340,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KenneyButton(
                label: l10n.restartMatch,
                icon: Icons.refresh_rounded,
                isWide: true,
                onPressed: () {
                  Navigator.pop(context);
                  game.rematch();
                },
              ),
              const SizedBox(height: 10),
              KenneyButton(
                label: l10n.resetBoard,
                icon: Icons.restart_alt_rounded,
                isWide: true,
                style: KenneyBtnStyle.neutral,
                onPressed: () {
                  Navigator.pop(context);
                  game.resetBoard();
                },
              ),
              const SizedBox(height: 10),
              KenneyButton(
                label: l10n.exitToMainMenu,
                icon: Icons.exit_to_app_rounded,
                isWide: true,
                style: KenneyBtnStyle.danger,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 14),
              Text(
                l10n.tableBackground,
                style: AppFonts.bangers(fontSize: 12, color: Colors.white70, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              _buildThemePicker(context),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: KenneyButton(
                      label: l10n.share,
                      icon: Icons.share_rounded,
                      style: KenneyBtnStyle.neutral,
                      fontSize: 13,
                      height: 42,
                      isWide: true,
                      onPressed: () {
                        Share.share(l10n.shareMessage);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: KenneyButton(
                      label: l10n.rate,
                      icon: Icons.star_rounded,
                      fontSize: 13,
                      height: 42,
                      isWide: true,
                      onPressed: () async {
                        final inAppReview = InAppReview.instance;
                        if (await inAppReview.isAvailable()) {
                          inAppReview.requestReview();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          ),
        );
      },
      child: Container(
        width: btnSize,
        height: btnSize,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetPaths.uiBtnSettingsGear),
            fit: BoxFit.contain,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  /// Lists the player's owned table themes (plus a default), so the in-game
  /// picker doubles as an inventory and persists the choice.
  Widget _buildThemePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = ProgressService.instanceOrNull;
    final owned = progress?.progress.ownedItems ?? const <String>[];
    final themes = shopItems
        .where((i) =>
            i.category == ShopCategory.themes && owned.contains(i.id))
        .toList();
    final equipped = progress?.progress.equippedTheme ?? '';

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildBackgroundButton(
              context,
              l10n.defaultTheme,
              AssetPaths.tableImage,
              themeId: '',
              isEquipped: equipped.isEmpty,
            ),
            ...themes.map(
              (t) => _buildBackgroundButton(
                context,
                t.localizedName(context).toUpperCase(),
                t.imageAsset ?? AssetPaths.tableImage,
                themeId: t.id,
                isEquipped: equipped == t.id,
              ),
            ),
          ],
        ),
        if (themes.isEmpty) ...[
          const SizedBox(height: 6),
          Text(
            l10n.buyThemesInShop,
            textAlign: TextAlign.center,
            style: AppFonts.bangers(fontSize: 11, color: Colors.white38),
          ),
        ],
      ],
    );
  }

  Widget _buildBackgroundButton(
    BuildContext context,
    String label,
    String asset, {
    required String themeId,
    required bool isEquipped,
  }) {
    return GestureDetector(
      onTap: () async {
        final progress = ProgressService.instanceOrNull;
        if (themeId.isEmpty) {
          progress?.clearEquipped(ShopCategory.themes);
        } else if (progress?.isEquipped(themeId) != true) {
          // Don't toggle off from here — the picker only ever selects.
          progress?.equipItem(themeId);
        }
        await game.setBackgroundAsset(asset);
        if (context.mounted) Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isEquipped
              ? const Color(0xFFFFD54F).withValues(alpha: 0.25)
              : const Color(0xFF5D4037),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEquipped ? const Color(0xFFFFD54F) : const Color(0xFF8D6E63),
            width: isEquipped ? 2 : 1,
          ),
        ),
        child: Text(
          isEquipped ? '$label ✅' : label,
          style: AppFonts.bangers(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }
}
