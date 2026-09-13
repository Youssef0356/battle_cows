import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/shop_item.dart';
import '../../data/services/progress_service.dart';
import '../widgets/cartoon_dialog.dart';

class ShopDialog extends StatefulWidget {
  final ProgressService progress;

  const ShopDialog({super.key, required this.progress});

  static Future<void> show({
    required BuildContext context,
    required ProgressService progress,
  }) {
    return CartoonDialog.show(
      context: context,
      title: 'COW BARN SHOP',
      maxWidth: 380,
      child: ShopDialog(progress: progress),
    );
  }

  @override
  State<ShopDialog> createState() => _ShopDialogState();
}

class _ShopDialogState extends State<ShopDialog> {
  ShopCategory _selectedCategory = ShopCategory.hats;

  @override
  Widget build(BuildContext context) {
    final coins = widget.progress.progress.coins;
    final owned = widget.progress.progress.ownedItems;
    final filtered = shopItems.where((i) => i.category == _selectedCategory).toList();

    return SizedBox(
      width: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💰', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '$coins',
                  style: GoogleFonts.bangers(
                    fontSize: 18,
                    color: const Color(0xFFFFD54F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildCategoryTabs(),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                final isOwned = owned.contains(item.id);
                final canBuy = coins >= item.price && !isOwned;
                return _buildShopTile(item, isOwned, canBuy);
              },
            ),
          ),
          const SizedBox(height: 8),
          CartoonButton(
            label: 'CLOSE',
            isWide: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ShopCategory.values.map((cat) {
        final isSelected = _selectedCategory == cat;
        final labels = {
          ShopCategory.hats: '🤠',
          ShopCategory.skins: '🐄',
          ShopCategory.themes: '🎨',
          ShopCategory.emojis: '💬',
          ShopCategory.boards: '🐮',
          ShopCategory.cows: '🐄',
        };
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFD54F).withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFFFFD54F) : Colors.white24,
              ),
            ),
            child: Text(labels[cat]!, style: const TextStyle(fontSize: 20)),
          ),
        );
        }).toList(),
      ),
    );
  }

  Widget _buildShopTile(ShopItem item, bool isOwned, bool canBuy) {
    return GestureDetector(
      onTap: canBuy ? () => _buyItem(item) : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isOwned
              ? const Color(0xFF689F38).withValues(alpha: 0.15)
              : canBuy
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOwned
                ? const Color(0xFF689F38)
                : canBuy
                    ? const Color(0xFFFFD54F)
                    : Colors.white12,
            width: isOwned ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             SizedBox(
               width: 54,
               height: 54,
               child: item.imageAsset != null
                   ? Image.asset(item.imageAsset!, fit: BoxFit.contain)
                   : Center(child: Text(item.icon, style: const TextStyle(fontSize: 22))),
             ),
            const SizedBox(height: 2),
            Text(
              item.name,
              style: GoogleFonts.bangers(
                fontSize: 9,
                color: isOwned ? const Color(0xFF689F38) : Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            if (isOwned)
              Text(
                'OWNED',
                style: GoogleFonts.bangers(fontSize: 8, color: const Color(0xFF689F38)),
              )
            else
              Text(
                '💰 ${item.price}',
                style: GoogleFonts.bangers(
                  fontSize: 9,
                  color: canBuy ? const Color(0xFFFFD54F) : Colors.white38,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _buyItem(ShopItem item) {
    final success = widget.progress.buyItem(item.id, item.price);
    if (success) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.icon} ${item.name} purchased!',
            style: GoogleFonts.bangers(fontSize: 16),
          ),
          backgroundColor: const Color(0xFF689F38),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
