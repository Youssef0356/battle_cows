import 'dart:math';

import 'package:flutter/foundation.dart';
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

  /// Test-only: forget the cached singleton so the next [getInstance]
  /// reloads progress from (mock) storage.
  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  PlayerProgress get progress => _progress ?? PlayerProgress();

  bool get tutorialCompleted => progress.tutorialCompleted;

  void markTutorialCompleted() {
    progress.tutorialCompleted = true;
    _save();
  }

  bool get shouldShowRatePrompt {
    return progress.matchesWon > 0 &&
        progress.matchesWon % 3 == 0 &&
        progress.ratePromptCount < progress.matchesWon ~/ 3;
  }

  void markRatePromptShown() {
    progress.ratePromptCount = progress.matchesWon ~/ 3;
    _save();
  }

  void _load() {
    final data = _prefs.getString(_key);
    if (data != null) {
      _progress = PlayerProgress.decode(data);
      _migrateLegacyShopEntries();
    } else {
      _progress = PlayerProgress();
    }
  }

  /// One-time save cleanup after the shop consolidation: the duplicate
  /// COWS tab was removed, so remap its cow ids onto the equivalent
  /// (identical art) skins ids, and clear any equipped skin that no
  /// longer exists as a purchasable skin item.
  void _migrateLegacyShopEntries() {
    const legacyToSkin = {
      'cow_cowboy': 'skin_cowboy',
      'cow_viking': 'skin_viking',
      'cow_disco': 'skin_disco',
      'cow_farmer': 'skin_farmer',
    };
    var changed = false;
    final owned = _progress!.ownedItems;
    for (final entry in legacyToSkin.entries) {
      if (owned.contains(entry.key)) {
        owned.remove(entry.key);
        if (!owned.contains(entry.value)) owned.add(entry.value);
        changed = true;
      }
    }
    // Remap a legacy equipped skin only when that cow was actually owned
    // (otherwise clear it — it was never purchasable).
    final equipped = _progress!.equippedSkin;
    if (equipped.startsWith('cow_')) {
      final mapped = legacyToSkin[equipped];
      if (mapped != null && owned.contains(mapped)) {
        _progress!.equippedSkin = mapped;
      } else {
        _progress!.equippedSkin = '';
      }
      changed = true;
    } else if (equipped.isNotEmpty && !owned.contains(equipped)) {
      _progress!.equippedSkin = '';
      changed = true;
    }
    // Drop any remaining legacy cow ids that have no replacement in the
    // consolidated catalog (e.g. cow_ninja / cow_robot — no art existed,
    // so they were never fulfillable). No new-catalog id uses cow_*.
    final countBefore = owned.length;
    owned.removeWhere((id) => id.startsWith('cow_'));
    if (owned.length != countBefore) changed = true;
    if (changed) _save();
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

  void refreshDailyQuests() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (progress.lastQuestRefreshDate == today) return;

    final rng = DateTime.now().millisecondsSinceEpoch;
    final random = Random(rng);

    final shuffledPool = List<_QuestDef>.from(_questPool)..shuffle(random);
    final allQuests = shuffledPool.take(3).toList();

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

  void equipItem(String itemId) {
    if (!progress.ownedItems.contains(itemId)) return;
    // Only skins can be equipped; the equipped skin drives the in-game cow art.
    if (!itemId.startsWith('skin_')) return;
    progress.equippedSkin = itemId;
    _save();
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
    updateQuestProgress(QuestType.moveCows, captures);
    if (won) updateQuestProgress(QuestType.winStreak, 1);

    _save();
  }

  static final _questPool = [
    _QuestDef('win1', 'Victory Lap', 'Win 1 match', '🏆', QuestType.winMatches, 1, 100, 30),
    _QuestDef('play2', 'Get Moving', 'Play 2 matches', '🎮', QuestType.playMatches, 2, 75, 20),
    _QuestDef('play3', 'Busy Day', 'Play 3 matches', '🐄', QuestType.playMatches, 3, 120, 35),
    _QuestDef('cap5', 'Land Grab', 'Capture 5 tiles', '🌾', QuestType.captureTiles, 5, 80, 25),
    _QuestDef('cap10', 'Conquest', 'Capture 10 tiles', '⚔️', QuestType.captureTiles, 10, 150, 40),
    _QuestDef('cap3', 'Quick Hooves', 'Capture 3 tiles in your matches', '💨', QuestType.captureTiles, 3, 60, 15),
    _QuestDef('play1', 'Warm Up', 'Play 1 match today', '🌞', QuestType.playMatches, 1, 40, 10),
    _QuestDef('move5', 'Herd Builder', 'Move 5 cows in matches', '🐮', QuestType.moveCows, 5, 70, 20),
    _QuestDef('winStreak2', 'On a Roll', 'Win 2 matches in a row', '🔥', QuestType.winStreak, 2, 90, 25),
  ];
}

class _QuestDef {
  final String id, title, description, icon;
  final QuestType type;
  final int target, coinReward, xpReward;

  const _QuestDef(this.id, this.title, this.description, this.icon, this.type,
      this.target, this.coinReward, this.xpReward);
}
