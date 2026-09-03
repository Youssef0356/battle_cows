class ShopItem {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int price;
  final ShopCategory category;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.price,
    required this.category,
  });
}

enum ShopCategory { hats, themes, emojis, boards }

const List<ShopItem> shopItems = [
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
    id: 'theme_sunset',
    name: 'Sunset Theme',
    description: 'Warm orange board skin',
    icon: '🌅',
    price: 400,
    category: ShopCategory.themes,
  ),
  ShopItem(
    id: 'theme_night',
    name: 'Night Mode',
    description: 'Dark pasture for night owls',
    icon: '🌙',
    price: 600,
    category: ShopCategory.themes,
  ),
  ShopItem(
    id: 'theme_ocean',
    name: 'Ocean Blue',
    description: 'Cool blue waters of the sea',
    icon: '🌊',
    price: 450,
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
    name: 'Classic Wood',
    description: 'Rustic wooden board',
    icon: '🪵',
    price: 300,
    category: ShopCategory.boards,
  ),
  ShopItem(
    id: 'board_marble',
    name: 'Marble',
    description: 'Elegant stone surface',
    icon: '💎',
    price: 800,
    category: ShopCategory.boards,
  ),
];
