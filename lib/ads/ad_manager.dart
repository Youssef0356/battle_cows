import 'dart:ui';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;
  bool _adsEnabled = true;

  // Production IDs
  static const String _rewardedAdUnitId = 'ca-app-pub-6774620515484669/6141831508';
  static const String _interstitialAdUnitId = 'ca-app-pub-6774620515484669/8062629287';
  static const String _bannerAdUnitId = 'ca-app-pub-6774620515484669/1564457516';

  bool get bannerLoaded => _bannerLoaded;
  BannerAd? get bannerAd => _bannerAd;

  /// False once the player owns the premium "Remove Ads" entitlement.
  bool get adsEnabled => _adsEnabled;

  /// Enables/disables all ad loading and display. Disabling disposes any
  /// cached ads immediately so premium players never see a stale one.
  void setAdsEnabled(bool enabled) {
    if (_adsEnabled == enabled) return;
    _adsEnabled = enabled;
    if (!enabled) {
      _rewardedAd?.dispose();
      _rewardedAd = null;
      _interstitialAd?.dispose();
      _interstitialAd = null;
      disposeBannerAd();
    }
  }

  void loadRewardedAd() {
    if (!_adsEnabled) return;
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
        },
      ),
    );
  }

  void loadInterstitialAd() {
    if (!_adsEnabled) return;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void loadBannerAd({VoidCallback? onLoaded}) {
    if (!_adsEnabled) return;
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerLoaded = true;
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          _bannerLoaded = false;
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  void showInterstitialAd({Function()? onAdDismissed}) {
    if (!_adsEnabled) {
      onAdDismissed?.call();
      return;
    }
    if (_interstitialAd == null) {
      loadInterstitialAd();
      onAdDismissed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onAdDismissed?.call();
      },
    );

    _interstitialAd!.show();
  }

  void showRewardedAd({
    required void Function(RewardItem reward) onUserEarnedReward,
    Function()? onAdDismissed,
  }) {
    if (!_adsEnabled) {
      onAdDismissed?.call();
      return;
    }
    if (_rewardedAd == null) {
      loadRewardedAd();
      onAdDismissed?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdDismissed?.call();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward);
      },
    );
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerLoaded = false;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    disposeBannerAd();
  }
}
