import 'package:flutter/material.dart';
import '../../assets/asset_paths.dart';
import '../../core/localization/app_localizations.dart';

class ShopItem {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String? imageAsset;
  final int price;
  final ShopCategory category;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.imageAsset,
    required this.price,
    required this.category,
  });
}

enum ShopCategory { skins, hats, themes, emojis, boards }

const List<ShopItem> shopItems = [
  ShopItem(
    id: 'skin_cowboy',
    name: 'Cowboy Cow',
    description: 'A sharpshooting western cow',
    icon: '🤠',
    imageAsset: 'assets/images/Cows/cow_cowboy.png',
    price: 300,
    category: ShopCategory.skins,
  ),
  ShopItem(
    id: 'skin_viking',
    name: 'Viking Cow',
    description: 'A horned raider from the north',
    icon: '⚔️',
    imageAsset: 'assets/images/Cows/cow_viking.png',
    price: 450,
    category: ShopCategory.skins,
  ),
  ShopItem(
    id: 'skin_farmer',
    name: 'Farmer Cow',
    description: 'Ready for a hard day in the pasture',
    icon: '🌾',
    imageAsset: 'assets/images/Cows/cow_farmer.png',
    price: 350,
    category: ShopCategory.skins,
  ),
  ShopItem(
    id: 'skin_disco',
    name: 'Disco Cow',
    description: 'The grooviest cow on the board',
    icon: '🪩',
    imageAsset: 'assets/images/Cows/cow_disco.png',
    price: 500,
    category: ShopCategory.skins,
  ),
  ShopItem(
    id: 'hat_cowboy',
    name: 'Cowboy Hat',
    description: 'A classic western hat for your herd',
    icon: '🤠',
    price: 200,
    category: ShopCategory.hats,
  ),
  ShopItem(
    id: 'hat_crown',
    name: 'Royal Crown',
    description: 'Rule the pasture with honor',
    icon: '👑',
    price: 500,
    category: ShopCategory.hats,
  ),
  ShopItem(
    id: 'hat_party',
    name: 'Party Hat',
    description: 'Every day is a celebration',
    icon: '🎉',
    price: 150,
    category: ShopCategory.hats,
  ),
  ShopItem(
    id: 'hat_superhero',
    name: 'Super Mask',
    description: 'Hero of the herd',
    icon: '🦸',
    price: 350,
    category: ShopCategory.hats,
  ),
  ShopItem(
    id: 'theme_valley',
    name: 'Green Valley',
    description: 'Sunny cartoon farm valley backdrop',
    icon: '🏞️',
    imageAsset: AssetPaths.backgroundValley,
    price: 400,
    category: ShopCategory.themes,
  ),
  ShopItem(
    id: 'theme_field',
    name: 'Flower Field',
    description: 'Blooming meadow pasture backdrop',
    icon: '🌻',
    imageAsset: AssetPaths.backgroundFarmField,
    price: 450,
    category: ShopCategory.themes,
  ),
  ShopItem(
    id: 'theme_wood',
    name: 'Rustic Wood',
    description: 'Cozy wooden tabletop backdrop',
    icon: '🪵',
    imageAsset: AssetPaths.backgroundWood,
    price: 500,
    category: ShopCategory.themes,
  ),
  ShopItem(
    id: 'emoji_fire',
    name: 'Fire Emoji',
    description: 'Flex with a fire reaction',
    icon: '🔥',
    price: 100,
    category: ShopCategory.emojis,
  ),
  ShopItem(
    id: 'emoji_lightning',
    name: 'Lightning',
    description: 'Strike with speed',
    icon: '⚡',
    price: 100,
    category: ShopCategory.emojis,
  ),
  ShopItem(
    id: 'emoji_star',
    name: 'Gold Star',
    description: 'Shine bright on the board',
    icon: '⭐',
    price: 100,
    category: ShopCategory.emojis,
  ),
  ShopItem(
    id: 'board_wood',
    name: 'Wooden Tiles',
    description: 'Warm carved wood hex tiles',
    icon: '🪵',
    imageAsset: AssetPaths.boardTextureWood,
    price: 300,
    category: ShopCategory.boards,
  ),
  ShopItem(
    id: 'board_meadow',
    name: 'Meadow Tiles',
    description: 'Soft sunlit grass hex tiles',
    icon: '🌿',
    imageAsset: AssetPaths.boardTextureMeadow,
    price: 500,
    category: ShopCategory.boards,
  ),
  ShopItem(
    id: 'board_flowers',
    name: 'Flower Grass',
    description: 'Lush grass dotted with wildflowers',
    icon: '🌼',
    imageAsset: AssetPaths.boardTextureFlowers,
    price: 700,
    category: ShopCategory.boards,
  ),
];

/// Looks up a catalog item by id, or null when it is unknown.
ShopItem? shopItemById(String id) {
  for (final item in shopItems) {
    if (item.id == id) return item;
  }
  return null;
}

extension ShopItemLocalization on ShopItem {
  String localizedName([BuildContext? context]) {
    final l10n = context != null ? AppLocalizations.of(context) : AppLocalizations.current;
    switch (id) {
      case 'skin_cowboy': return l10n.shopItemCowboyName;
      case 'skin_viking': return l10n.shopItemVikingName;
      case 'skin_farmer': return l10n.shopItemFarmerName;
      case 'skin_disco': return l10n.shopItemDiscoName;
      case 'hat_cowboy': return l10n.shopItemHatCowboyName;
      case 'hat_crown': return l10n.shopItemHatCrownName;
      case 'hat_party': return l10n.shopItemHatPartyName;
      case 'hat_superhero': return l10n.shopItemHatSuperheroName;
      case 'theme_valley': return l10n.shopItemThemeValleyName;
      case 'theme_field': return l10n.shopItemThemeFieldName;
      case 'theme_wood': return l10n.shopItemThemeWoodName;
      case 'emoji_fire': return l10n.shopItemEmojiFireName;
      case 'emoji_lightning': return l10n.shopItemEmojiLightningName;
      case 'emoji_star': return l10n.shopItemEmojiStarName;
      case 'board_wood': return l10n.shopItemBoardWoodTilesName;
      case 'board_meadow': return l10n.shopItemBoardMeadowTilesName;
      case 'board_flowers': return l10n.shopItemBoardFlowerGrassName;
      default: return name;
    }
  }

  String localizedDescription([BuildContext? context]) {
    final l10n = context != null ? AppLocalizations.of(context) : AppLocalizations.current;
    switch (id) {
      case 'skin_cowboy': return l10n.shopItemCowboyDesc;
      case 'skin_viking': return l10n.shopItemVikingDesc;
      case 'skin_farmer': return l10n.shopItemFarmerDesc;
      case 'skin_disco': return l10n.shopItemDiscoDesc;
      case 'hat_cowboy': return l10n.shopItemHatCowboyDesc;
      case 'hat_crown': return l10n.shopItemHatCrownDesc;
      case 'hat_party': return l10n.shopItemHatPartyDesc;
      case 'hat_superhero': return l10n.shopItemHatSuperheroDesc;
      case 'theme_valley': return l10n.shopItemThemeValleyDesc;
      case 'theme_field': return l10n.shopItemThemeFieldDesc;
      case 'theme_wood': return l10n.shopItemThemeWoodDesc;
      case 'emoji_fire': return l10n.shopItemEmojiFireDesc;
      case 'emoji_lightning': return l10n.shopItemEmojiLightningDesc;
      case 'emoji_star': return l10n.shopItemEmojiStarDesc;
      case 'board_wood': return l10n.shopItemBoardWoodTilesDesc;
      case 'board_meadow': return l10n.shopItemBoardMeadowTilesDesc;
      case 'board_flowers': return l10n.shopItemBoardFlowerGrassDesc;
      default: return description;
    }
  }
}

extension ShopCategoryLocalization on ShopCategory {
  String localizedName([BuildContext? context]) {
    final l10n = context != null ? AppLocalizations.of(context) : AppLocalizations.current;
    switch (this) {
      case ShopCategory.skins: return l10n.categorySkins;
      case ShopCategory.hats: return l10n.categoryHats;
      case ShopCategory.themes: return l10n.categoryThemes;
      case ShopCategory.emojis: return l10n.categoryEmojis;
      case ShopCategory.boards: return l10n.categoryBoards;
    }
  }
}
