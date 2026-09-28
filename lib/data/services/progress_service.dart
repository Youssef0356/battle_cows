import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_progress.dart';
import '../models/shop_item.dart';

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

  /// The already-loaded instance, or null before [getInstance] resolves.
  /// Lets synchronous UI read progress once the app has booted.
  static ProgressService? get instanceOrNull => _instance;

  PlayerProgress get progress => _progress ?? PlayerProgress();

  bool get tutorialCompleted => progress.tutorialCompleted;

  void markTutorialCompleted() {
    progress.tutorialCompleted = true;
    _save();
  }

  /// Whether the player owns the "Remove Ads" premium entitlement.
  bool get isPremium => progress.isPremium;

  /// Grants the premium entitlement locally and persists it. The Play Store
  /// purchase is verified by [PremiumService] before this is called.
  void unlockPremium() {
    if (progress.isPremium) return;
    progress.isPremium = true;
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

    // Theme/board remap: the old placeholder Sunset/Night/Ocean themes and
    // the Marble board had no art. Map any purchased/equipped copies onto
    // the replacement items that render real assets.
    const legacyCosmetics = {
      'theme_sunset': 'theme_field',
      'theme_night': 'theme_wood',
      'theme_ocean': 'theme_valley',
      'board_marble': 'board_meadow',
    };
    legacyCosmetics.forEach((legacyId, newId) {
      if (owned.contains(legacyId)) {
        owned.remove(legacyId);
        if (!owned.contains(newId)) owned.add(newId);
        changed = true;
      }
      if (_progress!.equippedTheme == legacyId) {
        _progress!.equippedTheme = newId;
        changed = true;
      }
      if (_progress!.equippedBoard == legacyId) {
        _progress!.equippedBoard = newId;
        changed = true;
      }
    });

    // Clear any equipped slot pointing at an item the player no longer owns.
    if (_pruneEquippedSlots(owned)) changed = true;

    if (changed) _save();
  }

  /// Blanks any equipped hat/theme/emoji/board that isn't owned. Returns true
  /// when something changed.
  bool _pruneEquippedSlots(List<String> owned) {
    var changed = false;
    void prune(String Function() get, void Function(String) set) {
      final id = get();
      if (id.isNotEmpty && !owned.contains(id)) {
        set('');
        changed = true;
      }
    }

    prune(() => _progress!.equippedHat, (v) => _progress!.equippedHat = v);
    prune(() => _progress!.equippedTheme, (v) => _progress!.equippedTheme = v);
    prune(() => _progress!.equippedEmoji, (v) => _progress!.equippedEmoji = v);
    prune(() => _progress!.equippedBoard, (v) => _progress!.equippedBoard = v);
    return changed;
  }

  void _save() {
    _prefs.setString(_key, _progress!.encode());
  }

  /// Coins granted the first time the game is opened each day, scaled by the
  /// login streak and capped so long streaks stay reasonable.
  static const int dailyLoginBaseCoins = 50;
  static const int dailyLoginStreakBonusCoins = 25;
  static const int dailyLoginMaxCoins = 250;

  void checkDailyLogin() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastLogin = progress.lastLoginDate;

    if (lastLogin == today) return;

    if (lastLogin == null) {
      progress.dailyStreak = 1;
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

    progress.coins += dailyLoginReward(progress.dailyStreak);
    progress.lastLoginDate = today;
    _save();
  }

  /// Coin reward for a given login streak.
  int dailyLoginReward(int streak) {
    final reward =
        dailyLoginBaseCoins + (streak - 1) * dailyLoginStreakBonusCoins;
    return min(reward, dailyLoginMaxCoins);
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

  /// Equips an owned cosmetic into its category slot. Tapping an already
  /// equipped item toggles it back off (unequips it).
  void equipItem(String itemId) {
    if (!progress.ownedItems.contains(itemId)) return;
    final prefix = _slotPrefixFor(itemId);
    if (prefix == null) return;
    _setEquipped(prefix, _equippedId(prefix) == itemId ? '' : itemId);
    _save();
  }

  /// Whether [itemId] is currently equipped in its category slot.
  bool isEquipped(String itemId) {
    final prefix = _slotPrefixFor(itemId);
    return prefix != null && _equippedId(prefix) == itemId;
  }

  /// Equipped item id for a shop category, or '' when nothing is equipped.
  String equippedForCategory(ShopCategory category) =>
      _equippedId(_prefixForCategory(category));

  /// Clears the equipped item for a category (e.g. the "default" option).
  void clearEquipped(ShopCategory category) {
    _setEquipped(_prefixForCategory(category), '');
    _save();
  }

  /// Resolved background image for the equipped theme (null = default).
  String? get equippedThemeAsset =>
      shopItemById(progress.equippedTheme)?.imageAsset;

  /// Resolved tile texture for the equipped board skin (null = default).
  String? get equippedBoardAsset =>
      shopItemById(progress.equippedBoard)?.imageAsset;

  static String _prefixForCategory(ShopCategory category) {
    switch (category) {
      case ShopCategory.skins:
        return 'skin_';
      case ShopCategory.hats:
        return 'hat_';
      case ShopCategory.themes:
        return 'theme_';
      case ShopCategory.emojis:
        return 'emoji_';
      case ShopCategory.boards:
        return 'board_';
    }
  }

  static String? _slotPrefixFor(String itemId) {
    for (final prefix in const ['skin_', 'hat_', 'theme_', 'emoji_', 'board_']) {
      if (itemId.startsWith(prefix)) return prefix;
    }
    return null;
  }

  String _equippedId(String prefix) {
    switch (prefix) {
      case 'skin_':
        return progress.equippedSkin;
      case 'hat_':
        return progress.equippedHat;
      case 'theme_':
        return progress.equippedTheme;
      case 'emoji_':
        return progress.equippedEmoji;
      case 'board_':
        return progress.equippedBoard;
      default:
        return '';
    }
  }

  void _setEquipped(String prefix, String itemId) {
    switch (prefix) {
      case 'skin_':
        progress.equippedSkin = itemId;
      case 'hat_':
        progress.equippedHat = itemId;
      case 'theme_':
        progress.equippedTheme = itemId;
      case 'emoji_':
        progress.equippedEmoji = itemId;
      case 'board_':
        progress.equippedBoard = itemId;
    }
  }

  /// Coins granted for playing, winning and capturing in a single match.
  static const int coinsPerMatchPlayed = 25;
  static const int coinsPerMatchWon = 75;
  static const int coinsPerCapture = 5;

  /// Records the result of a match and returns the coins earned.
  int recordMatch({required bool won, required int captures}) {
    progress.matchesPlayed++;
    if (won) progress.matchesWon++;
    progress.totalCaptures += captures;

    final earned = coinsPerMatchPlayed +
        (won ? coinsPerMatchWon : 0) +
        captures * coinsPerCapture;
    progress.coins += earned;

    progress.addXp(won ? 50 : 20);
    progress.addXp(captures * 5);

    updateQuestProgress(QuestType.playMatches, 1);
    if (won) updateQuestProgress(QuestType.winMatches, 1);
    updateQuestProgress(QuestType.captureTiles, captures);
    updateQuestProgress(QuestType.moveCows, captures);
    if (won) updateQuestProgress(QuestType.winStreak, 1);

    _save();
    return earned;
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
