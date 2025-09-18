import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocklet_source/app.dart';
import 'package:mocklet_source/app/service/pref_service.dart';

import 'app/data/app_constants.dart';
import 'app/service/hive_service.dart';
// import 'firebase_options.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Future.wait([
        MobileAds.instance.initialize(),
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
        EasyLocalization.ensureInitialized(),
        // Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
        HiveService.init(),
        PrefService.init(),
      ]);

      // if (kDebugMode) {
      //   MobileAds.instance.updateRequestConfiguration(
      //     RequestConfiguration(testDeviceIds: [AppConstants.testDeviceId]),
      //   );
      // }

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      runApp(
        EasyLocalization(
          supportedLocales: AppConstants.supportedLocales,
          fallbackLocale: AppConstants.fallbackLocale,
          saveLocale: true,
          path: AppConstants.translationsPath,
          child: const ProviderScope(child: App()),
        ),
      );
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}
