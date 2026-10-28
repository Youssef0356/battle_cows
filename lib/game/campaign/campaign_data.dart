import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../ai/ai_player.dart';
import '../models/challenge_mode.dart';

class CampaignLevel {
  final int id;
  final String title;
  final String subtitle;
  final String opponentName;
  final String opponentSkin;
  final Difficulty difficulty;
  final ChallengeMode mode;
  final int tilesPerPlayer;
  final int herdSize;
  final String description;
  final String objective;
  final int rewardCoins;
  final int rewardXp;
  final String badgeIcon;

  const CampaignLevel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.opponentName,
    required this.opponentSkin,
    required this.difficulty,
    required this.mode,
    required this.tilesPerPlayer,
    required this.herdSize,
    required this.description,
    required this.objective,
    required this.rewardCoins,
    required this.rewardXp,
    required this.badgeIcon,
  });
}

class CampaignData {
  static const List<CampaignLevel> levels = [
    CampaignLevel(
      id: 1,
      title: 'Meadow Crossing',
      subtitle: 'Barnyard Basics',
      opponentName: 'Farmer Bob',
      opponentSkin: 'skin_farmer',
      difficulty: Difficulty.easy,
      mode: ChallengeMode.standard,
      tilesPerPlayer: 4,
      herdSize: 16,
      description: 'Farmer Bob is waking up from a nap. Spread your herd and claim the open pastures!',
      objective: 'Claim more territory than Farmer Bob to earn up to 3 stars.',
      rewardCoins: 100,
      rewardXp: 50,
      badgeIcon: '🌾',
    ),
    CampaignLevel(
      id: 2,
      title: 'Muddy Creek',
      subtitle: 'Treading Through Mud',
      opponentName: 'Daisy Dirt',
      opponentSkin: 'skin_farmer',
      difficulty: Difficulty.easy,
      mode: ChallengeMode.standard,
      tilesPerPlayer: 4,
      herdSize: 16,
      description: 'Mud slows your cows down! Plan your splits carefully to bypass the bog.',
      objective: 'Navigate past the mud and capture the green pastures.',
      rewardCoins: 150,
      rewardXp: 75,
      badgeIcon: '🪵',
    ),
    CampaignLevel(
      id: 3,
      title: 'Golden Pasture Duel',
      subtitle: 'The Crown Clover',
      opponentName: 'Cowboy Tex',
      opponentSkin: 'skin_cowboy',
      difficulty: Difficulty.medium,
      mode: ChallengeMode.goldenPasture,
      tilesPerPlayer: 4,
      herdSize: 16,
      description: 'The legendary Golden Clover sits right in the center! Hold it to gain +1 bonus cow and 3x territory points.',
      objective: 'Occupy the Golden Pasture and outmaneuver Cowboy Tex.',
      rewardCoins: 200,
      rewardXp: 100,
      badgeIcon: '🍀',
    ),
    CampaignLevel(
      id: 4,
      title: 'Tick-Tock Pasture',
      subtitle: 'Beat the Clock',
      opponentName: 'Speedy Angus',
      opponentSkin: 'skin_cowboy',
      difficulty: Difficulty.medium,
      mode: ChallengeMode.timed,
      tilesPerPlayer: 4,
      herdSize: 16,
      description: 'Speedy Angus moves without hesitation. Make your split before the turn timer runs out!',
      objective: 'Win the match without losing all your hearts to the clock.',
      rewardCoins: 250,
      rewardXp: 125,
      badgeIcon: '⏱️',
    ),
    CampaignLevel(
      id: 5,
      title: 'Fence Ambush',
      subtitle: 'Master the Barriers',
      opponentName: 'Woody Wrangler',
      opponentSkin: 'skin_cowboy',
      difficulty: Difficulty.medium,
      mode: ChallengeMode.fenceChallenge,
      tilesPerPlayer: 4,
      herdSize: 16,
      description: 'Drop wooden fences to barricade Woody in his own corner while your cows roam free.',
      objective: 'Use fences to trap Woody and claim dominant pasture.',
      rewardCoins: 300,
      rewardXp: 150,
      badgeIcon: '🚪',
    ),
    CampaignLevel(
      id: 6,
      title: 'Frenzy Canyon',
      subtitle: 'Dynamic Sprouting Meadow',
      opponentName: 'Buster the Bull',
      opponentSkin: 'skin_viking',
      difficulty: Difficulty.hard,
      mode: ChallengeMode.stampedeRush,
      tilesPerPlayer: 5,
      herdSize: 16,
      description: 'Bonus tiles sprout across the meadow after every turn! Eat hay to expand.',
      objective: 'Claim more tiles than Buster the Bull to conquer the canyon.',
      rewardCoins: 350,
      rewardXp: 175,
      badgeIcon: '🌱',
    ),
    CampaignLevel(
      id: 7,
      title: 'The Narrow Gorge',
      subtitle: 'Tight Quarters',
      opponentName: 'Viking Olaf',
      opponentSkin: 'skin_viking',
      difficulty: Difficulty.hard,
      mode: ChallengeMode.standard,
      tilesPerPlayer: 3,
      herdSize: 16,
      description: 'A claustrophobic board where one wrong move completely cuts off your herd.',
      objective: 'Trap Viking Olaf before he walls off the exit gorge.',
      rewardCoins: 400,
      rewardXp: 200,
      badgeIcon: '🛡️',
    ),
    CampaignLevel(
      id: 8,
      title: 'Clover Crown Arena',
      subtitle: 'King of the Hill',
      opponentName: 'Queen Moochelle',
      opponentSkin: 'skin_disco',
      difficulty: Difficulty.hard,
      mode: ChallengeMode.goldenPasture,
      tilesPerPlayer: 5,
      herdSize: 16,
      description: 'Queen Moochelle will stop at nothing to crown herself ruler of the Golden Pasture.',
      objective: 'Storm the center and strip the crown from Queen Moochelle.',
      rewardCoins: 450,
      rewardXp: 225,
      badgeIcon: '👑',
    ),
    CampaignLevel(
      id: 9,
      title: 'The Great Corral',
      subtitle: 'Ultimate Fence Battle',
      opponentName: 'Iron Horn Hank',
      opponentSkin: 'skin_viking',
      difficulty: Difficulty.hard,
      mode: ChallengeMode.fenceChallenge,
      tilesPerPlayer: 5,
      herdSize: 16,
      description: 'Hank knows every trick with fences. You must out-anticipate his blockades.',
      objective: 'Outwit Hank in a master-class fence duel.',
      rewardCoins: 500,
      rewardXp: 250,
      badgeIcon: '🏆',
    ),
    CampaignLevel(
      id: 10,
      title: 'Alien Abduction Arena',
      subtitle: 'Boss Bovine Overlord',
      opponentName: 'Overcow X',
      opponentSkin: 'skin_disco',
      difficulty: Difficulty.hard,
      mode: ChallengeMode.stampedeRush,
      tilesPerPlayer: 5,
      herdSize: 20,
      description: 'The cosmic bovine overlord has landed with an expanded herd! Prove earth cows reign supreme.',
      objective: 'Conquer the final arena and claim the Grand Barnyard Trophy!',
      rewardCoins: 1000,
      rewardXp: 500,
      badgeIcon: '🛸',
    ),
  ];

  static CampaignLevel getLevel(int id) {
    return levels.firstWhere(
      (l) => l.id == id,
      orElse: () => levels.first,
    );
  }
}

extension CampaignLevelLocalization on CampaignLevel {
  String localizedTitle([BuildContext? context]) {
    final l10n = context != null ? AppLocalizations.of(context) : AppLocalizations.current;
    return l10n.campaignLevelTitle(id);
  }

  String localizedSubtitle([BuildContext? context]) {
    final l10n = context != null ? AppLocalizations.of(context) : AppLocalizations.current;
    return l10n.campaignLevelSubtitle(id);
  }

  String localizedOpponentName([BuildContext? context]) {
    final l10n = context != null ? AppLocalizations.of(context) : AppLocalizations.current;
    return l10n.campaignLevelOpponent(id);
  }

  String localizedDescription([BuildContext? context]) {
    final l10n = context != null ? AppLocalizations.of(context) : AppLocalizations.current;
    return l10n.campaignLevelDescription(id);
  }

  String localizedObjective([BuildContext? context]) {
    final l10n = context != null ? AppLocalizations.of(context) : AppLocalizations.current;
    return l10n.campaignLevelObjective(id);
  }
}
