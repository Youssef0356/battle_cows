import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

class PlayerProgress {
  int coins;
  int totalXp;
  int level;
  int matchesPlayed;
  int matchesWon;
  int totalCaptures;
  int dailyStreak;
  String? lastLoginDate;
  String? lastDailyRewardClaimed;
  List<String> ownedItems;
  List<QuestProgress> dailyQuests;
  String? lastQuestRefreshDate;
  bool tutorialCompleted;
  int ratePromptCount;
  bool isPremium;
  Map<String, int> campaignStars;

  PlayerProgress({
    this.coins = 0,
    this.totalXp = 0,
    this.level = 1,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.totalCaptures = 0,
    this.dailyStreak = 0,
    this.lastLoginDate,
    this.lastDailyRewardClaimed,
    List<String>? ownedItems,
    List<QuestProgress>? dailyQuests,
    this.lastQuestRefreshDate,
    this.tutorialCompleted = false,
    this.ratePromptCount = 0,
    this.equippedSkin = '',
    this.isPremium = false,
    this.equippedHat = '',
    this.equippedTheme = '',
    this.equippedEmoji = '',
    this.equippedBoard = '',
    Map<String, int>? campaignStars,
  })  : ownedItems = ownedItems ?? [],
        dailyQuests = dailyQuests ?? [],
        campaignStars = campaignStars ?? {};

  int getCampaignStars(int levelId) => campaignStars['level_$levelId'] ?? 0;

  void setCampaignStars(int levelId, int stars) {
    final current = getCampaignStars(levelId);
    if (stars > current) {
      campaignStars['level_$levelId'] = stars;
    }
  }

  bool isCampaignLevelUnlocked(int levelId) {
    if (levelId == 1) return true;
    return getCampaignStars(levelId - 1) > 0;
  }

  int get totalCampaignStars =>
      campaignStars.values.fold(0, (sum, stars) => sum + stars);

  String equippedSkin;
  String equippedHat;
  String equippedTheme;
  String equippedEmoji;
  String equippedBoard;

  int get xpForCurrentLevel => level * 100;
  int get xpForNextLevel => (level + 1) * 100;
  int get xpProgress => totalXp - xpForCurrentLevel;
  int get xpNeeded => xpForNextLevel - xpForCurrentLevel;
  double get xpPercent => xpNeeded > 0 ? (xpProgress / xpNeeded).clamp(0.0, 1.0) : 0.0;
  double get winRate => matchesPlayed > 0 ? matchesWon / matchesPlayed : 0.0;

  String get levelTitle {
    if (level >= 50) return 'Legendary Herder';
    if (level >= 40) return 'Master Cow';
    if (level >= 30) return 'Cow Commander';
    if (level >= 20) return 'Ranch Hero';
    if (level >= 15) return 'Field Marshal';
    if (level >= 10) return 'Cow Boss';
    if (level >= 5) return 'Ranch Hand';
    return 'Farmhand';
  }

  void addXp(int amount) {
    totalXp += amount;
    while (totalXp >= xpForNextLevel) {
      level++;
    }
  }

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'totalXp': totalXp,
        'level': level,
        'matchesPlayed': matchesPlayed,
        'matchesWon': matchesWon,
        'totalCaptures': totalCaptures,
        'dailyStreak': dailyStreak,
        'lastLoginDate': lastLoginDate,
        'lastDailyRewardClaimed': lastDailyRewardClaimed,
        'ownedItems': ownedItems,
        'dailyQuests': dailyQuests.map((q) => q.toJson()).toList(),
        'lastQuestRefreshDate': lastQuestRefreshDate,
        'tutorialCompleted': tutorialCompleted,
        'ratePromptCount': ratePromptCount,
        'equippedSkin': equippedSkin,
        'isPremium': isPremium,
        'equippedHat': equippedHat,
        'equippedTheme': equippedTheme,
        'equippedEmoji': equippedEmoji,
        'equippedBoard': equippedBoard,
        'campaignStars': campaignStars,
      };

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      coins: json['coins'] ?? 0,
      totalXp: json['totalXp'] ?? 0,
      level: json['level'] ?? 1,
      matchesPlayed: json['matchesPlayed'] ?? 0,
      matchesWon: json['matchesWon'] ?? 0,
      totalCaptures: json['totalCaptures'] ?? 0,
      dailyStreak: json['dailyStreak'] ?? 0,
      lastLoginDate: json['lastLoginDate'],
      lastDailyRewardClaimed: json['lastDailyRewardClaimed'] ?? json['lastRewardClaimDate'],
      ownedItems: List<String>.from(json['ownedItems'] ?? []),
      dailyQuests: (json['dailyQuests'] as List?)
              ?.map((q) => QuestProgress.fromJson(q))
              .toList() ??
          [],
      lastQuestRefreshDate: json['lastQuestRefreshDate'],
      tutorialCompleted: json['tutorialCompleted'] ?? false,
      ratePromptCount: json['ratePromptCount'] ?? 0,
      equippedSkin: json['equippedSkin'] ?? '',
      isPremium: json['isPremium'] ?? false,
      equippedHat: json['equippedHat'] ?? '',
      equippedTheme: json['equippedTheme'] ?? '',
      equippedEmoji: json['equippedEmoji'] ?? '',
      equippedBoard: json['equippedBoard'] ?? '',
      campaignStars: (json['campaignStars'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          ) ??
          {},
    );
  }

  String encode() => jsonEncode(toJson());
  factory PlayerProgress.decode(String source) =>
      PlayerProgress.fromJson(jsonDecode(source));
}

class QuestProgress {
  final String id;
  final String title;
  final String description;
  final String icon;
  final QuestType type;
  final int target;
  int current;
  final int coinReward;
  final int xpReward;
  bool claimed;

  QuestProgress({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.target,
    this.current = 0,
    required this.coinReward,
    required this.xpReward,
    this.claimed = false,
  });

  bool get isComplete => current >= target;
  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'type': type.name,
        'target': target,
        'current': current,
        'coinReward': coinReward,
        'xpReward': xpReward,
        'claimed': claimed,
      };

  factory QuestProgress.fromJson(Map<String, dynamic> json) {
    return QuestProgress(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      type: QuestType.values.firstWhere((e) => e.name == json['type']),
      target: json['target'],
      current: json['current'] ?? 0,
      coinReward: json['coinReward'],
      xpReward: json['xpReward'],
      claimed: json['claimed'] ?? false,
    );
  }
}

enum QuestType {
  winMatches,
  playMatches,
  captureTiles,
  moveCows,
  winStreak,
}

extension QuestTypeExtension on QuestType {
  String get displayName {
    switch (this) {
      case QuestType.winMatches:
        return 'Win Matches';
      case QuestType.playMatches:
        return 'Play Matches';
      case QuestType.captureTiles:
        return 'Capture Tiles';
      case QuestType.moveCows:
        return 'Move Cows';
      case QuestType.winStreak:
        return 'Win Streak';
    }
  }
}

extension QuestProgressLocalization on QuestProgress {
  String localizedTitle([BuildContext? context]) {
    final l10n = context != null ? AppLocalizations.of(context) : AppLocalizations.current;
    switch (id) {
      case 'win1': return l10n.questVictoryLapTitle;
      case 'play2': return l10n.questGetMovingTitle;
      case 'play3': return l10n.questBusyDayTitle;
      case 'cap5': return l10n.questLandGrabTitle;
      case 'cap10': return l10n.questConquestTitle;
      case 'cap3': return l10n.questQuickHoovesTitle;
      case 'play1': return l10n.questWarmUpTitle;
      case 'move5': return l10n.questHerdBuilderTitle;
      case 'winStreak2': return l10n.questOnARollTitle;
      default: return title;
    }
  }

  String localizedDescription([BuildContext? context]) {
    final l10n = context != null ? AppLocalizations.of(context) : AppLocalizations.current;
    switch (id) {
      case 'win1': return l10n.questVictoryLapDesc;
      case 'play2': return l10n.questGetMovingDesc;
      case 'play3': return l10n.questBusyDayDesc;
      case 'cap5': return l10n.questLandGrabDesc;
      case 'cap10': return l10n.questConquestDesc;
      case 'cap3': return l10n.questQuickHoovesDesc;
      case 'play1': return l10n.questWarmUpDesc;
      case 'move5': return l10n.questHerdBuilderDesc;
      case 'winStreak2': return l10n.questOnARollDesc;
      default: return description;
    }
  }
}
