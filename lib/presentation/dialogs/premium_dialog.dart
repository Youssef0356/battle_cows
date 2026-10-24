import 'package:flutter/material.dart';
import '../../core/localization/app_fonts.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/services/premium_service.dart';
import '../widgets/cartoon_dialog.dart';
import '../widgets/kenney_button.dart';

/// Purchase / restore UI for the "Remove Ads" premium entitlement.
class PremiumDialog extends StatefulWidget {
  const PremiumDialog({super.key});

  static Future<void> show(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CartoonDialog.show(
      context: context,
      title: l10n.goPremiumTitle,
      child: const PremiumDialog(),
    );
  }

  @override
  State<PremiumDialog> createState() => _PremiumDialogState();
}

class _PremiumDialogState extends State<PremiumDialog> {
  final PremiumService _premium = PremiumService.instance;

  Future<void> _buy(AppLocalizations l10n) async {
    await _premium.buy();
    if (!mounted) return;
    final error = _premium.lastError;
    if (error != null) {
      _showMessage(l10n.purchaseFailed(error), const Color(0xFFD32F2F));
    }
  }

  Future<void> _restore(AppLocalizations l10n) async {
    await _premium.restore();
    if (!mounted) return;
    final error = _premium.lastError;
    if (error != null) {
      _showMessage(l10n.restoreFailed(error), const Color(0xFFD32F2F));
      return;
    }
    if (_premium.isPremium) {
      _showMessage(l10n.purchasesRestored, const Color(0xFF43A047));
    } else {
      _showMessage(l10n.noPurchaseFound, const Color(0xFFD32F2F));
    }
  }

  void _showMessage(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: AppFonts.bangers(fontSize: 15)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: _premium,
      builder: (context, _) {
        if (_premium.isPremium) return _buildActive(l10n);
        return _buildOffer(l10n);
      },
    );
  }

  Widget _buildActive(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('👑', style: TextStyle(fontSize: 52)),
        const SizedBox(height: 8),
        Text(
          l10n.premiumActive,
          style: AppFonts.bangers(
            fontSize: 22,
            color: const Color(0xFFFFD54F),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.premiumActiveThanks,
          textAlign: TextAlign.center,
          style: AppFonts.bangers(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 20),
        KenneyButton(
          label: l10n.close,
          isWide: true,
          style: KenneyBtnStyle.neutral,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildOffer(AppLocalizations l10n) {
    final price = _premium.price;
    final available = _premium.storeAvailable && _premium.product != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🚫📺', style: TextStyle(fontSize: 44)),
        const SizedBox(height: 8),
        Text(
          l10n.removeAllAds,
          style: AppFonts.bangers(
            fontSize: 22,
            color: const Color(0xFFFFD54F),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        _buildBenefit(l10n.benefitNoBanner),
        _buildBenefit(l10n.benefitNoFullscreen),
        _buildBenefit(l10n.benefitForever),
        const SizedBox(height: 18),
        if (_premium.busy)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(color: Color(0xFFFFD54F)),
          )
        else
          KenneyButton(
            label: available
                ? l10n.buyWithPrice(price.isNotEmpty ? price : '').trim()
                : l10n.unlock,
            icon: Icons.workspace_premium_rounded,
            isWide: true,
            style: KenneyBtnStyle.primary,
            onPressed: _premium.canBuy ? () => _buy(l10n) : null,
          ),
        if (!available && !_premium.busy) ...[
          const SizedBox(height: 8),
          Text(
            l10n.storeUnavailable,
            textAlign: TextAlign.center,
            style: AppFonts.bangers(fontSize: 12, color: Colors.white54),
          ),
        ],
        if (_premium.lastError != null && !_premium.busy) ...[
          const SizedBox(height: 8),
          Text(
            _premium.lastError!,
            textAlign: TextAlign.center,
            style: AppFonts.bangers(fontSize: 12, color: const Color(0xFFEF9A9A)),
          ),
        ],
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _premium.busy ? null : () => _restore(l10n),
          child: Text(
            l10n.restorePurchases,
            style: AppFonts.bangers(
              fontSize: 13,
              color: Colors.white60,
              letterSpacing: 1.5,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white38,
            ),
          ),
        ),
        const SizedBox(height: 14),
        KenneyButton(
          label: l10n.notNow,
          isWide: true,
          style: KenneyBtnStyle.neutral,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: AppFonts.bangers(fontSize: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
