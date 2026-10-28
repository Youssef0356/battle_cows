import 'package:flutter/material.dart';
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
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 8 + widget.topInset, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Align(alignment: Alignment.centerLeft, child: _buildPhaseBox(l10n))),
                Expanded(child: Center(child: _buildTilesLeftBox(tilesLeft))),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: HudOverlay(game: widget.game, players: players).buildSettingsButton(context),
                  ),
                ),
              ],
            ),
            _buildTilePlayerChipsBar(currentPlayerIndex, players, tilesRemaining),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseBox(AppLocalizations l10n) {
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
            '🌾 PHASE',
            style: AppFonts.bangers(
              fontSize: 9,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          Text(
            'PASTURE',
            style: AppFonts.bangers(
              fontSize: 10,
              color: const Color(0xFFFFD54F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTilesLeftBox(int tiles) {
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
            'TILES LEFT',
            style: AppFonts.bangers(
              fontSize: 9,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          Text(
            '$tiles',
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

  Widget _buildTilePlayerChipsBar(int currentPlayerIndex, List<Player> players, List<int> tilesRemaining) {
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD54F), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Rotate button
          _buildControlButton(
            label: l10n.rotate.toUpperCase(),
            icon: Icons.rotate_right_rounded,
            color: const Color(0xFF8D6E63),
            borderColor: const Color(0xFFFFD54F),
            onTap: () => widget.game.rotateCurrentTile(),
          ),
          // Place button
          _buildControlButton(
            label: l10n.place.toUpperCase(),
            icon: Icons.add_circle_outline,
            color: canPlace ? const Color(0xFF66BB6A) : Colors.grey.shade700,
            borderColor: canPlace ? const Color(0xFFFFD54F) : Colors.white24,
            onTap: canPlace ? () => widget.game.placeCurrentTile() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String label,
    required IconData icon,
    Color color = const Color(0xFF5D4037),
    Color borderColor = const Color(0xFF8D6E63),
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.8),
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
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppFonts.bangers(
                fontSize: 14,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
