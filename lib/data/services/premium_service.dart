import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../ads/ad_manager.dart';
import 'progress_service.dart';

/// Owns the "Remove Ads" premium entitlement.
///
/// Buys/restores the product through Google Play via [InAppPurchase],
/// persists the entitlement through [ProgressService], and tells [AdManager]
/// to stop serving ads while premium is active. The purchase is trusted from
/// the Play billing client (no server-side receipt verification); add
/// verification before treating the entitlement as tamper-proof.
class PremiumService extends ChangeNotifier {
  PremiumService._();

  static final PremiumService instance = PremiumService._();

  /// Non-consumable product id. Must match the product created in the
  /// Google Play Console (Monetize > Products > In-app products).
  static const String productId = 'battle_cows_remove_ads';

  /// Lazily resolved so constructing [PremiumService] never triggers platform
  /// registration (which opens a billing connection). Only store operations
  /// touch it.
  InAppPurchase get _iap => InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  ProductDetails? _product;
  bool _isPremium = false;
  bool _storeAvailable = false;
  bool _connected = false;
  bool _busy = false;
  String? _lastError;

  bool get isPremium => _isPremium;
  bool get storeAvailable => _storeAvailable;
  bool get busy => _busy;
  String? get lastError => _lastError;
  ProductDetails? get product => _product;

  /// Localized price from the store, e.g. "$1.99". Empty until the product
  /// details load.
  String get price => _product?.price ?? '';
  String get title => _product?.title ?? 'Remove Ads';

  /// True when the buy button should be actionable.
  bool get canBuy => _storeAvailable && _product != null && !_isPremium && !_busy;

  /// Loads the saved entitlement (fast, from local storage) and connects to
  /// the store. Safe to call more than once.
  Future<void> initialize() async {
    await loadEntitlement();
    await _connect();
  }

  /// Reads the persisted entitlement and applies it to [AdManager]. Call this
  /// before ads initialize so premium players never receive an ad request.
  Future<void> loadEntitlement() async {
    final progress = await ProgressService.getInstance();
    _applyPremium(progress.isPremium, notify: false);
    notifyListeners();
  }

  Future<void> _connect() async {
    if (_connected) return;
    try {
      _storeAvailable = await _iap.isAvailable();
    } catch (_) {
      _storeAvailable = false;
    }
    if (!_storeAvailable) {
      notifyListeners();
      return;
    }
    _purchaseSub ??= _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object error) {
        _lastError = error.toString();
        notifyListeners();
      },
    );
    _connected = true;
    await _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final response = await _iap.queryProductDetails({productId});
      if (response.productDetails.isNotEmpty) {
        _product = response.productDetails.first;
      } else {
        _product = null;
        _lastError = 'Premium product unavailable';
      }
    } catch (error) {
      _product = null;
      _lastError = error.toString();
    }
    notifyListeners();
  }

  /// Starts the Play Store purchase flow. The entitlement is granted only
  /// once the purchase stream reports success in [_onPurchaseUpdate].
  Future<void> buy() async {
    final details = _product;
    if (details == null) return;
    _setBusy(true);
    _lastError = null;
    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: details),
      );
    } catch (error) {
      _lastError = error.toString();
    } finally {
      _setBusy(false);
    }
  }

  /// Re-checks the store for an existing purchase (e.g. after reinstall or on
  /// a new device).
  Future<void> restore() async {
    if (!_storeAvailable) {
      _lastError = 'Store unavailable';
      notifyListeners();
      return;
    }
    _setBusy(true);
    _lastError = null;
    try {
      await _iap.restorePurchases();
    } catch (error) {
      _lastError = error.toString();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != productId) continue;

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grant();
        case PurchaseStatus.error:
          _lastError = purchase.error?.message ?? 'Purchase failed';
          notifyListeners();
        case PurchaseStatus.canceled:
        case PurchaseStatus.pending:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _grant() async {
    final progress = await ProgressService.getInstance();
    progress.unlockPremium();
    _applyPremium(true, notify: true);
  }

  void _applyPremium(bool premium, {required bool notify}) {
    _isPremium = premium;
    // Turning ads off disposes anything already cached, so a premium player
    // cannot be shown a stale banner/interstitial.
    AdManager().setAdsEnabled(!premium);
    if (notify) notifyListeners();
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  /// Test-only: forget cached store state so the next [initialize] reconnects.
  @visibleForTesting
  void resetForTesting() {
    _purchaseSub?.cancel();
    _purchaseSub = null;
    _product = null;
    _isPremium = false;
    _storeAvailable = false;
    _connected = false;
    _busy = false;
    _lastError = null;
    AdManager().setAdsEnabled(true);
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}
