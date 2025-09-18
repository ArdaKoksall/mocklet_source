import 'dart:ui';

class AppConstants {
  static const String translationsPath = 'assets/translations';
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('it', 'IT'),
    Locale('tr', 'TR'),
    Locale('es', 'ES'),
    Locale('fr', 'FR'),
    Locale('de', 'DE'),
  ];
  static const Locale fallbackLocale = Locale('en', 'US');

  static const String welcomeVideo = 'assets/video/welcome.mp4';

  static const String appName = 'Mocklet';

  static const String testDeviceId = 'TEST_DEVICE_ID';

  static const String versionNumber = '1.0.0';

  static const int fetchInterval = 35;

  static const bool showInfoLogs = true;
  static const bool showDebugLogs = true;
  static const bool showErrorLogs = true;
  static const bool showWarningLogs = true;

  static const int maxLatestCryptos = 5;

  static const String baseUrl = 'https://api.coingecko.com/';
  static const String getDataUrl =
      'api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true';

  static const String githubUrl =
      'https://github.com/ArdaKoksall/mocklet_source';
}

extension ColorOpacity on Color {
  Color withOpacityValue(double opacity) => withAlpha((opacity * 255).round());
}
