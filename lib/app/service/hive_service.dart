import 'package:hive_flutter/adapters.dart';
import 'package:mocklet_source/models/cached/user/settings.dart';
import 'package:mocklet_source/models/cached/user/user_crypto.dart';
import 'package:mocklet_source/models/cached/user/user_data.dart';
import '../../app_logger.dart';
import '../../models/cached/crypto/crypto.dart';
import '../../models/cached/crypto/roi.dart';
import '../../models/cached/user/transaction.dart';

class HiveService {
  static const String _appDataBoxName = 'app_data_box';
  static const String _userDataBoxName = 'user_data_box';
  static const String _cryptoListKey = 'cryptos';

  static late Box _appDataBox;
  static late Box _userDataBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CryptoAdapter());
    Hive.registerAdapter(RoiAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(UserDataAdapter());
    Hive.registerAdapter(UserCryptoAdapter());
    Hive.registerAdapter(SettingsAdapter());

    _appDataBox = await Hive.openBox(_appDataBoxName);
    _userDataBox = await Hive.openBox(_userDataBoxName);
  }

  static Future<void> saveCryptos(List<Crypto> cryptos) async {
    await _appDataBox.put(_cryptoListKey, cryptos);
  }

  static List<Crypto>? getCryptos() {
    final data = _appDataBox.get(_cryptoListKey);
    if (data is List && data.isNotEmpty) {
      return data.cast<Crypto>();
    }
    return null;
  }

  static Future<void> clearCryptos() async {
    await _appDataBox.delete(_cryptoListKey);
  }

  static UserData? getUserData(String userId) {
    final userData = _userDataBox.get(userId);
    if (userData is UserData) {
      return userData;
    }
    return null;
  }

  static Future<void> createUserData(UserData user) async {
    AppLogger.info("Creating user data...");
    await _userDataBox.put(user.userId, user);
    if (_userDataBox.length > 5) {
      final keys = _userDataBox.keys.toList();
      keys.sort(
        (a, b) => _userDataBox
            .get(a)
            .createdAt
            .compareTo(_userDataBox.get(b).createdAt),
      );
      final oldestKey = keys.first;
      await _userDataBox.delete(oldestKey);
      AppLogger.info("Deleted oldest user data: $oldestKey");
    }
  }

  static Future<void> updateUser({
    required Future<void> Function(UserData user) updater,
    required String uid,
  }) async {
    try {
      final currentUser = getUserData(uid);

      if (currentUser == null) {
        throw Exception('User data not found in Hive');
      }

      await updater(currentUser);
      await currentUser.save();
    } catch (e, s) {
      AppLogger.error(error: e, stack: s, reason: 'Error updating user data');
    }
  }

  static Future<void> deleteUserData(String userId) async {
    await _userDataBox.delete(userId);
  }

  static Future<void> clearEverything() async {
    await _appDataBox.clear();
    await _userDataBox.clear();
  }
}
