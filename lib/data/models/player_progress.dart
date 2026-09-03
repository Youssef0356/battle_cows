import 'dart:convert';

class PlayerProgress {
  int coins;
  int totalXp;
  int level;
  int matchesPlayed;
  int matchesWon;
  int totalCaptures;
  int dailyStreak;
  String? lastLoginDate;
  List<String> ownedItems;
  List<QuestProgress> dailyQuests;
  String? lastQuestRefreshDate;

  PlayerProgress({
    this.coins = 0,
    this.totalXp = 0,
    this.level = 1,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.totalCaptures = 0,
    this.dailyStreak = 0,
    this.lastLoginDate,
    List<String>? ownedItems,
    List<QuestProgress>? dailyQuests,
    this.lastQuestRefreshDate,
  })  : ownedItems = ownedItems ?? [],
        dailyQuests = dailyQuests ?? [];

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
        'ownedItems': ownedItems,
        'dailyQuests': dailyQuests.map((q) => q.toJson()).toList(),
        'lastQuestRefreshDate': lastQuestRefreshDate,
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
      ownedItems: List<String>.from(json['ownedItems'] ?? []),
      dailyQuests: (json['dailyQuests'] as List?)
              ?.map((q) => QuestProgress.fromJson(q))
              .toList() ??
          [],
      lastQuestRefreshDate: json['lastQuestRefreshDate'],
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
