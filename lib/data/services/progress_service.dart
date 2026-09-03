import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_progress.dart';

class ProgressService {
  static const _key = 'player_progress';
  static ProgressService? _instance;
  late SharedPreferences _prefs;
  PlayerProgress? _progress;

  ProgressService._();

  static Future<ProgressService> getInstance() async {
    if (_instance == null) {
      _instance = ProgressService._();
      _instance!._prefs = await SharedPreferences.getInstance();
      _instance!._load();
    }
    return _instance!;
  }

  PlayerProgress get progress => _progress ?? PlayerProgress();

  void _load() {
    final data = _prefs.getString(_key);
    if (data != null) {
      _progress = PlayerProgress.decode(data);
    } else {
      _progress = PlayerProgress();
    }
  }

  void _save() {
    _prefs.setString(_key, _progress!.encode());
  }

  void checkDailyLogin() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastLogin = progress.lastLoginDate;

    if (lastLogin == null) {
      progress.dailyStreak = 1;
    } else if (lastLogin == today) {
      return;
    } else {
      final lastDate = DateTime.parse(lastLogin);
      final todayDate = DateTime.parse(today);
      final diff = todayDate.difference(lastDate).inDays;
      if (diff == 1) {
        progress.dailyStreak++;
      } else if (diff > 1) {
        progress.dailyStreak = 1;
      }
    }

    progress.lastLoginDate = today;
    _save();
  }

  int claimDailyReward() {
    final streak = progress.dailyStreak;
    final baseReward = 50;
    final bonus = min(streak, 7) * 25;
    final total = baseReward + bonus;
    progress.coins += total;
    _save();
    return total;
  }

  void refreshDailyQuests() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (progress.lastQuestRefreshDate == today) return;

    final rng = DateTime.now().millisecondsSinceEpoch;
    final random = Random(rng);

    final allQuests = [
      _questPool[0],
      _questPool[1 + random.nextInt(2)],
      _questPool[3 + random.nextInt(2)],
    ];

    progress.dailyQuests = allQuests.map((q) {
      final quest = QuestProgress(
        id: '${q.id}_$today',
        title: q.title,
        description: q.description,
        icon: q.icon,
        type: q.type,
        target: q.target,
        coinReward: q.coinReward,
        xpReward: q.xpReward,
      );
      return quest;
    }).toList();

    progress.lastQuestRefreshDate = today;
    _save();
  }

  void updateQuestProgress(QuestType type, int amount) {
    bool changed = false;
    for (final quest in progress.dailyQuests) {
      if (quest.type == type && !quest.claimed) {
        quest.current = (quest.current + amount).clamp(0, quest.target);
        changed = true;
      }
    }
    if (changed) _save();
  }

  bool claimQuest(int index) {
    if (index >= progress.dailyQuests.length) return false;
    final quest = progress.dailyQuests[index];
    if (!quest.isComplete || quest.claimed) return false;

    quest.claimed = true;
    progress.coins += quest.coinReward;
    progress.addXp(quest.xpReward);
    _save();
    return true;
  }

  bool buyItem(String itemId, int cost) {
    if (progress.coins < cost) return false;
    if (progress.ownedItems.contains(itemId)) return false;
    progress.coins -= cost;
    progress.ownedItems.add(itemId);
    _save();
    return true;
  }

  void recordMatch({required bool won, required int captures}) {
    progress.matchesPlayed++;
    if (won) progress.matchesWon++;
    progress.totalCaptures += captures;

    progress.addXp(won ? 50 : 20);
    progress.addXp(captures * 5);

    updateQuestProgress(QuestType.playMatches, 1);
    if (won) updateQuestProgress(QuestType.winMatches, 1);
    updateQuestProgress(QuestType.captureTiles, captures);

    _save();
  }

  static final _questPool = [
    _QuestDef('win1', 'Victory Lap', 'Win 1 match', '🏆', QuestType.winMatches, 1, 100, 30),
    _QuestDef('play2', 'Get Moving', 'Play 2 matches', '🎮', QuestType.playMatches, 2, 75, 20),
    _QuestDef('play3', 'Busy Day', 'Play 3 matches', '🐄', QuestType.playMatches, 3, 120, 35),
    _QuestDef('cap5', 'Land Grab', 'Capture 5 tiles', '🌾', QuestType.captureTiles, 5, 80, 25),
    _QuestDef('cap10', 'Conquest', 'Capture 10 tiles', '⚔️', QuestType.captureTiles, 10, 150, 40),
  ];
}

class _QuestDef {
  final String id, title, description, icon;
  final QuestType type;
  final int target, coinReward, xpReward;

  const _QuestDef(this.id, this.title, this.description, this.icon, this.type,
      this.target, this.coinReward, this.xpReward);
}
