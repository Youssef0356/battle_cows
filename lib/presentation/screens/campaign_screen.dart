import 'package:flutter/material.dart';
import '../../assets/asset_paths.dart';
import '../../core/localization/app_fonts.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/progress_service.dart';
import '../../game/campaign/campaign_data.dart';
import '../../game/models/challenge_mode.dart';
import '../../game/models/player.dart';
import '../../game/models/player_color.dart';
import '../router/app_router.dart';
import '../widgets/bouncy_pressable.dart';
import '../widgets/cartoon_dialog.dart';
import '../widgets/wood_button.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  ProgressService? _progressService;

  @override
  void initState() {
    super.initState();
    _initProgress();
  }

  Future<void> _initProgress() async {
    _progressService = await ProgressService.getInstance();
    if (mounted) setState(() {});
  }

  void _showLevelBriefing(CampaignLevel level) {
    final progress = _progressService?.progress;
    final stars = progress?.getCampaignStars(level.id) ?? 0;
    final l10n = AppLocalizations.of(context);

    CartoonDialog.show(
      context: context,
      title: l10n.levelBriefing(level.id),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF5D4037),
                      border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                    ),
                    child: Center(
                      child: Text(level.badgeIcon, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.localizedTitle(context).toUpperCase(),
                          style: AppFonts.bangers(
                            fontSize: 18,
                            color: const Color(0xFFFFD54F),
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          l10n.vsOpponent(level.localizedOpponentName(context).toUpperCase()),
                          style: AppFonts.bangers(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(3, (i) {
                            return Icon(
                              i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: i < stars ? const Color(0xFFFFD700) : Colors.white30,
                              size: 20,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              level.localizedDescription(context),
              textAlign: TextAlign.center,
              style: AppFonts.bangers(
                fontSize: 13,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF66BB6A).withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎯 ', style: TextStyle(fontSize: 14)),
                  Flexible(
                    child: Text(
                      level.localizedObjective(context),
                      style: AppFonts.bangers(fontSize: 11, color: const Color(0xFFA5D6A7)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🪙 ', style: TextStyle(fontSize: 14)),
                Text(
                  l10n.rewardCoinsBadge(level.rewardCoins),
                  style: AppFonts.bangers(fontSize: 13, color: const Color(0xFFFFD54F)),
                ),
                const SizedBox(width: 14),
                const Text('⭐ ', style: TextStyle(fontSize: 14)),
                Text(
                  l10n.rewardXpBadge(level.rewardXp),
                  style: AppFonts.bangers(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 18),
            WoodButton.gold(
              label: l10n.startBattle,
              icon: Icons.sports_kabaddi_rounded,
              width: 220,
              height: 52,
              fontSize: 22,
              onPressed: () {
                Navigator.pop(context);
                _launchCampaignLevel(level);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _launchCampaignLevel(CampaignLevel level) {
    final l10n = AppLocalizations.of(context);
    final players = [
      Player(id: 0, name: l10n.defaultPlayerName(1), color: PlayerColor.blue),
      Player(
        id: 1,
        name: level.localizedOpponentName(context),
        color: PlayerColor.red,
        isAi: true,
        difficulty: level.difficulty,
      ),
    ];

    Navigator.pushNamed(
      context,
      AppRouter.game,
      arguments: {
        'players': players,
        'herdSize': level.herdSize,
        'tilesPerPlayer': level.tilesPerPlayer,
        'boardSize': 7 + (5 - level.tilesPerPlayer) * 2,
        'challengeMode': level.mode,
        'campaignLevelId': level.id,
      },
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progressService?.progress;
    final totalStars = progress?.totalCampaignStars ?? 0;
    final maxStars = CampaignData.levels.length * 3;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AssetPaths.background,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1B5E20)),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(totalStars, maxStars),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: CampaignData.levels.length,
                    itemBuilder: (context, index) {
                      final level = CampaignData.levels[index];
                      final isUnlocked = progress?.isCampaignLevelUnlocked(level.id) ?? (level.id == 1);
                      final stars = progress?.getCampaignStars(level.id) ?? 0;
                      return _buildLevelCard(level, isUnlocked, stars);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int totalStars, int maxStars) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          BouncyPressable(
            scaleDown: 0.88,
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF4E342E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.barnyardConquest,
                  style: AppFonts.bangers(
                    fontSize: 22,
                    color: const Color(0xFFFFD54F),
                    letterSpacing: 2,
                    shadows: [
                      const Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
                    ],
                  ),
                ),
                Text(
                  l10n.campaignPuzzlesBattles,
                  style: AppFonts.bangers(
                    fontSize: 11,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 4),
                Text(
                  '$totalStars/$maxStars',
                  style: AppFonts.bangers(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(CampaignLevel level, bool isUnlocked, int stars) {
    final l10n = AppLocalizations.of(context);
    return BouncyPressable(
      scaleDown: isUnlocked ? 0.96 : 1.0,
      onTap: isUnlocked ? () => _showLevelBriefing(level) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUnlocked
                ? [const Color(0xFF4E342E), const Color(0xFF2E1C0C)]
                : [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnlocked
                ? (stars == 3 ? const Color(0xFFFFD700) : const Color(0xFF8D6E63))
                : Colors.white12,
            width: isUnlocked ? (stars == 3 ? 2.5 : 1.5) : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isUnlocked
                    ? const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFA000)])
                    : const LinearGradient(colors: [Color(0xFF555555), Color(0xFF333333)]),
                border: Border.all(
                  color: isUnlocked ? const Color(0xFFFFF3C4) : Colors.white24,
                  width: 2,
                ),
              ),
              child: Center(
                child: isUnlocked
                    ? Text(
                        '${level.id}',
                        style: AppFonts.bangers(
                          fontSize: 22,
                          color: const Color(0xFF3E2723),
                        ),
                      )
                    : const Icon(Icons.lock_rounded, color: Colors.white54, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          level.localizedTitle(context).toUpperCase(),
                          style: AppFonts.bangers(
                            fontSize: 16,
                            color: isUnlocked ? Colors.white : Colors.white38,
                            letterSpacing: 1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        level.mode.icon,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.vsOpponent(level.localizedOpponentName(context))} • ${level.mode.localizedTitle(context)}',
                    style: AppFonts.bangers(
                      fontSize: 11,
                      color: isUnlocked ? const Color(0xFFFFD54F) : Colors.white24,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnlocked)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return Icon(
                    i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: i < stars ? const Color(0xFFFFD700) : Colors.white24,
                    size: 22,
                  );
                }),
              )
            else
              const Icon(Icons.lock_outline_rounded, color: Colors.white24, size: 22),
          ],
        ),
      ),
    );
  }
}
