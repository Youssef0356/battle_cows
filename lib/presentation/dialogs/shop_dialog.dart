import 'package:flutter/material.dart';
import '../../core/localization/app_fonts.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/shop_item.dart';
import '../../data/services/premium_service.dart';
import '../../data/services/progress_service.dart';
import '../widgets/cartoon_dialog.dart';
import '../widgets/kenney_button.dart';
import 'premium_dialog.dart';

class ShopDialog extends StatefulWidget {
  final ProgressService progress;

  const ShopDialog({super.key, required this.progress});

  static Future<void> show({
    required BuildContext context,
    required ProgressService progress,
  }) {
    final l10n = AppLocalizations.of(context);
    return CartoonDialog.show(
      context: context,
      title: l10n.shopTitle,
      maxWidth: 380,
      child: ShopDialog(progress: progress),
    );
  }

  @override
  State<ShopDialog> createState() => _ShopDialogState();
}

class _ShopDialogState extends State<ShopDialog> {
  ShopCategory _selectedCategory = ShopCategory.skins;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                  style: AppFonts.bangers(
                    fontSize: 18,
                    color: const Color(0xFFFFD54F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildPremiumBanner(l10n),
          _buildCategoryTabs(),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
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
              return _buildShopTile(item, isOwned, canBuy, l10n);
            },
          ),
          const SizedBox(height: 8),
          KenneyButton(
            label: l10n.close,
            isWide: true,
            style: KenneyBtnStyle.neutral,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: PremiumService.instance,
      builder: (context, _) {
        if (PremiumService.instance.isPremium) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            key: const ValueKey('shop-premium-banner'),
            onTap: () => PremiumDialog.show(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFF3C4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFA000).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🚫📺', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.removeAdsGoPremium,
                      style: AppFonts.bangers(
                        fontSize: 15,
                        color: const Color(0xFF3E2723),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF3E2723)),
                ],
              ),
            ),
          ),
        );
      },
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
            ShopCategory.skins: '🐄',
            ShopCategory.hats: '🤠',
            ShopCategory.themes: '🎨',
            ShopCategory.emojis: '💬',
            ShopCategory.boards: '🪵',
          };
          return GestureDetector(
            key: ValueKey('shop-tab-${cat.name}'),
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
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(labels[cat]!, style: const TextStyle(fontSize: 20)),
                  if (widget.progress.equippedForCategory(cat).isNotEmpty)
                    const Positioned(
                      right: -5,
                      top: -5,
                      child: Icon(
                        Icons.check_circle,
                        size: 13,
                        color: Color(0xFF43A047),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShopTile(ShopItem item, bool isOwned, bool canBuy, AppLocalizations l10n) {
    final isEquipped = widget.progress.isEquipped(item.id);
    return GestureDetector(
      onTap: isOwned
          ? () => _toggleEquip(item, l10n)
          : canBuy
              ? () => _buyItem(item, l10n)
              : null,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isEquipped
              ? const Color(0xFFFFD54F).withValues(alpha: 0.18)
              : isOwned
                  ? const Color(0xFF689F38).withValues(alpha: 0.15)
                  : canBuy
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEquipped
                ? const Color(0xFFFFD54F)
                : isOwned
                    ? const Color(0xFF689F38)
                    : canBuy
                        ? const Color(0xFFFFD54F)
                        : Colors.white12,
            width: (isEquipped || isOwned) ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: item.imageAsset != null
                    ? Image.asset(item.imageAsset!, fit: BoxFit.contain)
                    : Text(item.icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.localizedName(context),
              style: AppFonts.bangers(
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
                isEquipped ? l10n.equippedCheck : l10n.tapToUse,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.bangers(
                  fontSize: 8,
                  color: isEquipped ? const Color(0xFF43A047) : const Color(0xFF689F38),
                ),
              )
            else
              Text(
                '💰 ${item.price}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.bangers(
                  fontSize: 9,
                  color: canBuy ? const Color(0xFFFFD54F) : Colors.white38,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _buyItem(ShopItem item, AppLocalizations l10n) {
    final success = widget.progress.buyItem(item.id, item.price);
    if (success) {
      widget.progress.equipItem(item.id);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.icon} ${l10n.itemPurchasedAndEquipped(item.localizedName(context))}',
            style: AppFonts.bangers(fontSize: 16),
          ),
          backgroundColor: const Color(0xFF689F38),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.cannotPurchase,
            style: AppFonts.bangers(fontSize: 14),
          ),
          backgroundColor: const Color(0xFFD32F2F),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleEquip(ShopItem item, AppLocalizations l10n) {
    final wasEquipped = widget.progress.isEquipped(item.id);
    widget.progress.equipItem(item.id);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasEquipped
              ? '${item.icon} ${l10n.itemUnequipped(item.localizedName(context))}'
              : '${item.icon} ${l10n.itemEquipped(item.localizedName(context))}',
          style: AppFonts.bangers(fontSize: 16),
        ),
        backgroundColor:
            wasEquipped ? const Color(0xFF6D4C41) : const Color(0xFF43A047),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
