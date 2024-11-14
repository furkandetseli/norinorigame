import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;
  bool _isInitialized = false;
  DateTime? _lastAdShow;

  // Test ID'leri
  final String _interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'  // Android test ID
      : 'ca-app-pub-3940256099942544/4411468910'; // iOS test ID

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final status = await MobileAds.instance.initialize();
      _isInitialized = true;

      final adapterStatuses = status.adapterStatuses;
      adapterStatuses.forEach((key, value) {
        debugPrint('Adapter status for $key: ${value.description}');
      });

      await _loadInterstitialAd();
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
      _isInitialized = false;
    }
  }

  Future<void> _loadInterstitialAd() async {
    if (_isAdLoading || !_isInitialized) return;

    _isAdLoading = true;

    try {
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('Interstitial ad loaded successfully');
            _interstitialAd = ad;
            _isAdLoading = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial ad failed to load: ${error.message}');
            _isAdLoading = false;
            _interstitialAd = null;
            // Retry after delay
            Future.delayed(const Duration(minutes: 1), _loadInterstitialAd);
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading interstitial ad: $e');
      _isAdLoading = false;
      _interstitialAd = null;
      // Retry after delay
      Future.delayed(const Duration(minutes: 1), _loadInterstitialAd);
    }
  }

  Future<void> showInterstitialAd() async {
    // Minimum reklam gösterim aralığı kontrolü (30 saniye)
    if (_lastAdShow != null) {
      final difference = DateTime.now().difference(_lastAdShow!);
      if (difference.inSeconds < 30) {
        debugPrint('Skipping ad show: Too soon since last ad');
        return;
      }
    }

    if (!_isInitialized) {
      debugPrint('Warning: AdMob not initialized');
      await initialize();
      return;
    }

    if (_interstitialAd == null) {
      debugPrint('Warning: Interstitial ad not ready. Loading new ad...');
      await _loadInterstitialAd();
      return;
    }

    try {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Ad dismissed');
          ad.dispose();
          _lastAdShow = DateTime.now();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Ad failed to show: ${error.message}');
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Ad showed successfully');
        },
      );

      await _interstitialAd!.show();
      _interstitialAd = null;
      _lastAdShow = DateTime.now();
      await _loadInterstitialAd();
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
      _interstitialAd?.dispose();
      _interstitialAd = null;
      await _loadInterstitialAd();
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}