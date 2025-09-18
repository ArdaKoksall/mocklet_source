import 'package:hive/hive.dart';
import 'package:mocklet_source/app_logger.dart';
import 'package:mocklet_source/models/cached/user/settings.dart';
import 'package:mocklet_source/models/cached/user/transaction.dart';
import 'package:mocklet_source/models/cached/user/user_crypto.dart';

part 'user_data.g.dart';

@HiveType(typeId: 4)
class UserData extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  List<Transaction> transactions;

  @HiveField(2)
  List<UserCrypto> userCryptos;

  @HiveField(3)
  double totalBalance;

  @HiveField(4)
  List<String> favoriteCryptos;

  @HiveField(5)
  double tetherBalance;

  @HiveField(6)
  List<String> latestCryptos;

  @HiveField(7)
  Settings settings;

  UserData({
    required this.userId,
    required this.transactions,
    required this.userCryptos,
    required this.totalBalance,
    required this.favoriteCryptos,
    required this.tetherBalance,
    this.latestCryptos = const [],
    required this.settings,
  });

  void logUserData() {
    AppLogger.info('User ID: $userId');
    AppLogger.info('Total Balance: $totalBalance');
    AppLogger.info('Tether Balance: $tetherBalance');
    AppLogger.info('Transactions:');
    for (var transaction in transactions) {
      AppLogger.info(
        '  - ${transaction.type}: ${transaction.amount} on ${transaction.date}',
      );
    }
    AppLogger.info('User Cryptos:');
    for (var userCrypto in userCryptos) {
      AppLogger.info(
        '  - Crypto ID: ${userCrypto.cryptoId}, Amount: ${userCrypto.amount}',
      );
    }
    AppLogger.info('Favorite Cryptos: ${favoriteCryptos.join(', ')}');
    AppLogger.info('Latest Cryptos: ${latestCryptos.join(', ')}');
    AppLogger.info('Settings:');
    AppLogger.info(
      '  - Show recent transactions: ${settings.showRecentTransactions}',
    );
    AppLogger.info('  - Show recent activity: ${settings.showRecentActivity}');
    AppLogger.info('  - Show top holdings: ${settings.showTopHoldings}');
  }
}
