import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/services/premium_service.dart';
import '../widgets/cartoon_dialog.dart';
import '../widgets/kenney_button.dart';

/// Purchase / restore UI for the "Remove Ads" premium entitlement.
class PremiumDialog extends StatefulWidget {
  const PremiumDialog({super.key});

  static Future<void> show(BuildContext context) {
    return CartoonDialog.show(
      context: context,
      title: 'GO PREMIUM',
      child: const PremiumDialog(),
    );
  }

  @override
  State<PremiumDialog> createState() => _PremiumDialogState();
}

class _PremiumDialogState extends State<PremiumDialog> {
  final PremiumService _premium = PremiumService.instance;

  Future<void> _buy() async {
    await _premium.buy();
    if (!mounted) return;
    final error = _premium.lastError;
    if (error != null) {
      _showMessage('Purchase failed: $error', const Color(0xFFD32F2F));
    }
  }

  Future<void> _restore() async {
    await _premium.restore();
    if (!mounted) return;
    final error = _premium.lastError;
    if (error != null) {
      _showMessage('Restore failed: $error', const Color(0xFFD32F2F));
      return;
    }
    if (_premium.isPremium) {
      _showMessage('Purchases restored!', const Color(0xFF43A047));
    } else {
      _showMessage('No previous purchase found', const Color(0xFFD32F2F));
    }
  }

  void _showMessage(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: GoogleFonts.bangers(fontSize: 15)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _premium,
      builder: (context, _) {
        if (_premium.isPremium) return _buildActive();
        return _buildOffer();
      },
    );
  }

  Widget _buildActive() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('👑', style: TextStyle(fontSize: 52)),
        const SizedBox(height: 8),
        Text(
          'PREMIUM ACTIVE',
          style: GoogleFonts.bangers(
            fontSize: 22,
            color: const Color(0xFFFFD54F),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ads are removed. Thanks for supporting Battle Cows!',
          textAlign: TextAlign.center,
          style: GoogleFonts.bangers(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 20),
        KenneyButton(
          label: 'CLOSE',
          isWide: true,
          style: KenneyBtnStyle.neutral,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildOffer() {
    final price = _premium.price;
    final available = _premium.storeAvailable && _premium.product != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🚫📺', style: TextStyle(fontSize: 44)),
        const SizedBox(height: 8),
        Text(
          'REMOVE ALL ADS',
          style: GoogleFonts.bangers(
            fontSize: 22,
            color: const Color(0xFFFFD54F),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        _buildBenefit('🚫 No banner ads'),
        _buildBenefit('⏭️ No full-screen ads between matches'),
        _buildBenefit('🐮 One-time purchase, yours forever'),
        const SizedBox(height: 18),
        if (_premium.busy)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(color: Color(0xFFFFD54F)),
          )
        else
          KenneyButton(
            label: available
                ? 'BUY ${price.isNotEmpty ? price : ''}'.trim()
                : 'UNLOCK',
            icon: Icons.workspace_premium_rounded,
            isWide: true,
            style: KenneyBtnStyle.primary,
            onPressed: _premium.canBuy ? _buy : null,
          ),
        if (!available && !_premium.busy) ...[
          const SizedBox(height: 8),
          Text(
            _premium.storeAvailable
                ? 'Premium is unavailable right now.'
                : 'Store not available on this device.',
            textAlign: TextAlign.center,
            style: GoogleFonts.bangers(fontSize: 12, color: Colors.white54),
          ),
        ],
        if (_premium.lastError != null && !_premium.busy) ...[
          const SizedBox(height: 8),
          Text(
            _premium.lastError!,
            textAlign: TextAlign.center,
            style: GoogleFonts.bangers(fontSize: 12, color: const Color(0xFFEF9A9A)),
          ),
        ],
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _premium.busy ? null : _restore,
          child: Text(
            'RESTORE PURCHASES',
            style: GoogleFonts.bangers(
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
          label: 'NOT NOW',
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
              style: GoogleFonts.bangers(fontSize: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
