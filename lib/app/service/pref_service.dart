import 'package:mocklet_source/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefService {
  static late SharedPreferences _prefs;

  static late bool _isFirstRun;
  static bool get isFirstRun => _isFirstRun;

  static late String _themeString;
  static String get themeString => _themeString;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadValues();
  }

  static void _loadValues() {
    _isFirstRun = _prefs.getBool('isFirstRun') ?? true;
    _themeString = _prefs.getString('theme') ?? '';
    AppLogger.info(
      'Preferences loaded: isFirstRun=$_isFirstRun, themeString=$_themeString',
    );
  }

  static Future<void> setFirstRun(bool value) async {
    _isFirstRun = value;
    await _prefs.setBool('isFirstRun', value);
  }

  static Future<void> setThemeMode(String value) async {
    _themeString = value;
    await _prefs.setString('theme', value);
  }
}
