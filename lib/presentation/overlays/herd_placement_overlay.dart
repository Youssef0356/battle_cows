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

    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(playerIndex, players, l10n),
          const Expanded(child: IgnorePointer(child: SizedBox.expand())),
          _buildInstructions(currentPlayer, l10n),
        ],
      ),
    );
  }

  Widget _buildTopBar(int currentPlayerIndex, List<Player> players, AppLocalizations l10n) {
    return Container(
      margin: EdgeInsets.fromLTRB(12, 8 + widget.topInset, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1C0C).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8D6E63), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          HudOverlay(game: widget.game, players: players).buildSettingsButton(context),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              l10n.placeHerd.toUpperCase(),
              style: AppFonts.bangers(
                fontSize: 15,
                color: const Color(0xFFFFD54F),
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Spacer(),
          ...List.generate(players.length, (index) {
            final player = players[index];
            final isCurrent = index == currentPlayerIndex;
            final isPlaced = index < currentPlayerIndex;

            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _buildPlayerCard(player, isCurrent, isPlaced, l10n),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(Player player, bool isCurrent, bool isPlaced, AppLocalizations l10n) {
    final color = AppColors.getPlayerPrimary(player.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent ? color.withValues(alpha: 0.3) : Colors.black26,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: isCurrent ? color : Colors.white24, width: isCurrent ? 1.5 : 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(_cowAsset(player), width: 30, height: 30, fit: BoxFit.contain),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(player.isAi ? 'AI' : player.name.toUpperCase(), style: AppFonts.bangers(fontSize: 10, color: Colors.white)),
              Text(
                isPlaced ? l10n.ready.toUpperCase() : (isCurrent ? l10n.place.toUpperCase() : l10n.wait.toUpperCase()),
                style: AppFonts.bangers(fontSize: 8, color: isCurrent ? const Color(0xFFFFD54F) : Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _cowAsset(Player player) {
    switch (player.color) {
      case PlayerColor.blue:
        return 'assets/images/Cows/cow_viking.png';
      case PlayerColor.red:
        return 'assets/images/Cows/cow_cowboy.png';
      case PlayerColor.yellow:
        return 'assets/images/Cows/cow_farmer.png';
      case PlayerColor.purple:
        return 'assets/images/Cows/cow_disco.png';
    }
  }

  Widget _buildInstructions(Player currentPlayer, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1C0C).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8D6E63), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.getPlayerPrimary(currentPlayer.color),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              l10n.tapHighlightedHexToPlace(currentPlayer.name),
              style: AppFonts.bangers(
                fontSize: 12,
                color: Colors.white,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
