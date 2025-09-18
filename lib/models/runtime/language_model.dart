import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';

import '../../app/data/app_constants.dart';

class LanguageModel {
  final String code;
  final String nameKey;
  final String flagCode;

  LanguageModel({
    required this.code,
    required this.nameKey,
    required this.flagCode,
  });

  Locale get locale => Locale(code, flagCode);
  String get translatedName => nameKey.tr();

  static List<LanguageModel> supportedLanguages = [
    LanguageModel(code: 'en', nameKey: 'language_en', flagCode: 'US'),
    LanguageModel(code: 'it', nameKey: 'language_it', flagCode: 'IT'),
    LanguageModel(code: 'tr', nameKey: 'language_tr', flagCode: 'TR'),
    LanguageModel(code: 'es', nameKey: 'language_es', flagCode: 'ES'),
    LanguageModel(code: 'fr', nameKey: 'language_fr', flagCode: 'FR'),
    LanguageModel(code: 'de', nameKey: 'language_de', flagCode: 'DE'),
  ];

  static LanguageModel get defaultLanguage => supportedLanguages.firstWhere(
    (lang) => lang.locale == AppConstants.fallbackLocale,
  );
}
