import 'package:hive/hive.dart';

part 'user_crypto.g.dart';

@HiveType(typeId: 5)
class UserCrypto extends HiveObject {
  @HiveField(0)
  final String cryptoId;

  @HiveField(1)
  final double amount;

  UserCrypto({required this.cryptoId, required this.amount});
}
