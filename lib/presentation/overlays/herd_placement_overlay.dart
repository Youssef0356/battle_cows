import 'package:flutter/material.dart';
import '../../core/localization/app_fonts.dart';
import '../../core/localization/app_localizations.dart';
import '../../flame/battle_cows_game.dart';
import '../../game/models/player.dart';
import '../../core/constants/colors.dart';
import 'hud_overlay.dart';

class HerdPlacementOverlay extends StatefulWidget {
  final BattleCowsGame game;

  /// Extra top spacing (the ad banner height) so the top bar sits below the
  /// banner instead of being covered by it.
  final double topInset;

  const HerdPlacementOverlay({
    super.key,
    required this.game,
    this.topInset = 0,
  });

  @override
  State<HerdPlacementOverlay> createState() => _HerdPlacementOverlayState();
}

class _HerdPlacementOverlayState extends State<HerdPlacementOverlay> {
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
    final playerIndex = game.herdPlacementPlayerIndex;
    final players = game.players;

    if (playerIndex >= players.length) return const SizedBox.shrink();

    final currentPlayer = players[playerIndex];

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(playerIndex, players, l10n),
            const Expanded(child: IgnorePointer(child: SizedBox.expand())),
            _buildInstructions(currentPlayer, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(int currentPlayerIndex, List<Player> players, AppLocalizations l10n) {
    final herdsRemaining = players.length - currentPlayerIndex;
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 8 + widget.topInset, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Align(alignment: Alignment.centerLeft, child: _buildPhaseBox())),
                Expanded(child: Center(child: _buildHerdsRemainingBox(herdsRemaining))),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: HudOverlay(game: widget.game, players: players).buildSettingsButton(context),
                  ),
                ),
              ],
            ),
            _buildPlayerChipsBar(currentPlayerIndex, players),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD54F), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🐮 PHASE',
            style: AppFonts.bangers(
              fontSize: 9,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          Text(
            'HERD DROP',
            style: AppFonts.bangers(
              fontSize: 10,
              color: const Color(0xFFFFD54F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHerdsRemainingBox(int remaining) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD54F), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TO PLACE',
            style: AppFonts.bangers(
              fontSize: 9,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          Text(
            '$remaining',
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

  Widget _buildPlayerChipsBar(int currentPlayerIndex, List<Player> players) {
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
          final isPlaced = index < currentPlayerIndex;
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
                    isPlaced ? '✓' : '16',
                    style: AppFonts.bangers(
                      fontSize: 12,
                      color: isPlaced ? const Color(0xFF81C784) : const Color(0xFFFFD54F),
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

  Widget _buildInstructions(Player currentPlayer, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.getPlayerPrimary(currentPlayer.color),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.tapHighlightedHexToPlace(currentPlayer.name),
              style: AppFonts.bangers(
                fontSize: 13,
                color: const Color(0xFFFFD54F),
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
