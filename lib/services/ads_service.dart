import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdsService {
  static RewardedAd? _rewardedAd;
  static bool _isRewardedAdReady = false;
  static Function? _onRewardEarned;

  // Ad Unit IDs (replace with your actual IDs in production)
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    }
    return '';
  }

  // Initialize ads
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await loadRewardedAd();
  }

  // Load rewarded ad
  static Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              print('Rewarded ad showed full screen content.');
            },
            onAdDismissedFullScreenContent: (ad) {
              print('Rewarded ad dismissed.');
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('Rewarded ad failed to show: $error');
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Rewarded ad failed to load: $error');
          _isRewardedAdReady = false;
          // Retry after delay
          Future.delayed(const Duration(seconds: 10), () => loadRewardedAd());
        },
      ),
    );
  }

  // Show rewarded ad
  static Future<bool> showRewardedAd({
    required Function onRewardEarned,
    Function? onAdDismissed,
  }) async {
    if (!_isRewardedAdReady || _rewardedAd == null) {
      print('Rewarded ad is not ready yet.');
      await loadRewardedAd();
      return false;
    }

    _onRewardEarned = onRewardEarned;
    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('Rewarded ad showed.');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('Rewarded ad dismissed.');
        ad.dispose();
        _isRewardedAdReady = false;
        onAdDismissed?.call();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Rewarded ad failed to show: $error');
        ad.dispose();
        _isRewardedAdReady = false;
        loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
        print('User earned reward: ${reward.amount} ${reward.type}');
        _onRewardEarned?.call();
      },
    );

    return rewardEarned;
  }

  // Check if rewarded ad is ready
  static bool get isRewardedAdReady => _isRewardedAdReady;

  // Dispose
  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdReady = false;
  }
}
