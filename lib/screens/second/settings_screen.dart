import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:country_flags/country_flags.dart';
import 'package:mocklet_source/app/core/core.dart';
import 'package:mocklet_source/app/service/hive_service.dart';
import 'package:mocklet_source/screens/second/about_screen.dart';
import 'package:mocklet_source/screens/second/crypto_detail/banner_ad_widget.dart';

import '../../app/core/brain.dart';
import '../../app/data/ad_constants.dart';
import '../../app/service/theme_service.dart';
import '../../models/runtime/language_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('select_language'.tr()),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: LanguageModel.supportedLanguages.length,
              itemBuilder: (context, index) {
                final lang = LanguageModel.supportedLanguages[index];
                final bool isSelected =
                    context.locale.languageCode == lang.code;

                return ListTile(
                  leading: CountryFlag.fromCountryCode(
                    lang.flagCode,
                    height: 36,
                    width: 54,
                  ),
                  title: Text(lang.translatedName),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () async {
                    await context.setLocale(lang.locale);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _onThemeChanged(bool isDarkMode) async {
    final themeService = ref.read(themeServiceProvider);
    await themeService.setThemeMode(
      isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('logout'.tr()),
          content: Text('logout_confirmation'.tr()),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('cancel'.tr()),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _performLogout();
                  },
                  child: Text('logout'.tr()),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDataConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('delete_all_data'.tr()),
          content: Text('delete_all_data_confirmation'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performDeleteAllData();
              },
              child: Text(
                'delete'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('delete_account'.tr()),
          content: Text('delete_account_confirmation'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performDeleteAccount();
              },
              child: Text(
                'delete_account'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    await ref.read(coreProvider).logout();
    ref.read(brainProvider).cleanUp();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil("/login", (route) => false);
  }

  Future<void> _performDeleteAllData() async {
    await HiveService.clearEverything();
    ref.read(brainProvider).cleanUp();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil("/login", (route) => false);
  }

  Future<void> _performDeleteAccount() async {
    await ref.read(coreProvider).deleteAccount();
    ref.read(brainProvider).cleanUp();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil("/login", (route) => false);
  }

  Widget _getCurrentLanguageFlag() {
    final currentLanguageCode = context.locale.languageCode;
    final currentLanguage = LanguageModel.supportedLanguages.firstWhere(
      (lang) => lang.code == currentLanguageCode,
      orElse: () => LanguageModel.supportedLanguages.first,
    );

    return CountryFlag.fromCountryCode(
      currentLanguage.flagCode,
      height: 24,
      width: 36,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr())),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: BannerAdWidget(adId: AdConstants.settingsScreenBannerAd),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: _getCurrentLanguageFlag(),
                      title: Text('language'.tr()),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        _showLanguageSelector(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      ),
                      title: Text('theme'.tr()),
                      subtitle: Text(
                        isDarkMode ? 'theme_dark'.tr() : 'theme_light'.tr(),
                      ),
                      trailing: Switch(
                        value: isDarkMode,
                        onChanged: _onThemeChanged,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.info),
                      title: Text('about'.tr()),
                      subtitle: Text('about_subtitle'.tr()),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AboutScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.logout),
                      title: Text('logout'.tr()),
                      subtitle: Text('logout_subtitle'.tr()),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: _showLogoutConfirmation,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.orange,
                      ),
                      title: Text(
                        'delete_account'.tr(),
                        style: const TextStyle(color: Colors.orange),
                      ),
                      subtitle: Text('delete_account_subtitle'.tr()),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.orange,
                      ),
                      onTap: _showDeleteAccountConfirmation,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.delete_sweep,
                        color: Colors.red,
                      ),
                      title: Text(
                        'delete_all_data'.tr(),
                        style: const TextStyle(color: Colors.red),
                      ),
                      subtitle: Text('delete_all_data_subtitle'.tr()),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.red,
                      ),
                      onTap: _showDeleteDataConfirmation,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
