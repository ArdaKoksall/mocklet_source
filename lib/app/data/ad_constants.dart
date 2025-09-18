import 'package:flutter/foundation.dart';

class AdConstants {
  static const String _nativeAdvanced = '';

  static const String _cryptoDetailScreenBannerAd = '';

  static const String _testBannerAd = '';

  static const String _walletScreenBannerAd = '';

  static const String _searchScreenBannerAd = '';

  static const String _settingsScreenBannerAd = '';

  static const String _testNativeAdvanced = '';

  static String get cryptoDetailScreenBannerAd =>
      kDebugMode ? _testBannerAd : _cryptoDetailScreenBannerAd;

  static String get walletScreenBannerAd =>
      kDebugMode ? _testBannerAd : _walletScreenBannerAd;

  static String get searchScreenBannerAd =>
      kDebugMode ? _testBannerAd : _searchScreenBannerAd;

  static String get settingsScreenBannerAd =>
      kDebugMode ? _testBannerAd : _settingsScreenBannerAd;

  static String get nativeAdvancedId =>
      kDebugMode ? _testNativeAdvanced : _nativeAdvanced;

  static const double adChance = 0.20;

  static const String _interstitialAd = '';
  static const String _testInterstitialAd = '';

  static String get interstitialAdId =>
      kDebugMode ? _testInterstitialAd : _interstitialAd;

  static const int maxAds = 4;
  static const int adInterval = 8;
}
