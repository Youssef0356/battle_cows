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

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 8 + topInset, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: Align(alignment: Alignment.centerLeft, child: _buildTimerBox())),
                    Expanded(child: Center(child: _buildTurnCounterBox(turnCount))),
                    Expanded(child: Align(alignment: Alignment.centerRight, child: buildSettingsButton(context))),
                  ],
                ),
                _buildLiveScoreBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerBox() {
    final timeRemaining = game.timeRemaining;
    final hasTimer = game.challengeMode.hasTimer;
    final isLowTime = hasTimer && timeRemaining <= 10;
    final isFenceBattle = game.challengeMode == ChallengeMode.fenceChallenge;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLowTime
              ? [const Color(0xFF8B0000), const Color(0xFF4E0000)]
              : [const Color(0xFF4E342E), const Color(0xFF2E1C0C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLowTime ? const Color(0xFFFF5252) : const Color(0xFF8D6E63),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isLowTime
                ? const Color(0xFFD32F2F).withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.4),
            offset: const Offset(0, 2),
            blurRadius: isLowTime ? 8 : 4,
          ),
        ],
      ),
      child: hasTimer
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 26,
                  height: 26,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: (timeRemaining / 60.0).clamp(0.0, 1.0),
                        strokeWidth: 3.0,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isLowTime ? const Color(0xFFFF5252) : const Color(0xFFFFD54F),
                        ),
                      ),
                      Text(
                        '',
                        style: AppFonts.bangers(
                          fontSize: 11,
                          color: isLowTime ? const Color(0xFFFF5252) : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⏱️ TIME',
                      style: AppFonts.bangers(
                        fontSize: 9,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      isLowTime ? 'HURRY!' : 'RUNNING',
                      style: AppFonts.bangers(
                        fontSize: 10,
                        color: isLowTime ? const Color(0xFFFF8A80) : const Color(0xFFFFD54F),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isFenceBattle ? '🪵 FENCES' : '🎮 FREE PLAY',
                  style: AppFonts.bangers(
                    fontSize: 10,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  isFenceBattle ? 'BATTLE' : '∞',
                  style: AppFonts.bangers(
                    fontSize: 18,
                    color: const Color(0xFFFFD54F),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTurnCounterBox(int turn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4E342E), Color(0xFF2E1C0C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF8D6E63), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TURN',
            style: AppFonts.bangers(
              fontSize: 10,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          Text(
            '$turn',
            style: AppFonts.bangers(
              fontSize: 16,
              color: const Color(0xFFFFD54F),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveScoreBar() {
    final territoryCounts = game.territoryCounts;
    final currentP = game.engine.players.isNotEmpty ? game.engine.currentPlayer : null;

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
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
                    ? [primary, primary.withValues(alpha: 0.75)]
                    : [Colors.black38, Colors.black45],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isTurn ? const Color(0xFFFFD54F) : primary.withValues(alpha: 0.4),
                width: isTurn ? 2.0 : 1.0,
              ),
              boxShadow: isTurn
                  ? [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.4),
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

  Widget buildSettingsButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF8D6E63), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 2),
              blurRadius: 3,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.settings, color: Colors.white, size: 18),
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
