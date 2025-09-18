import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 3)
enum TransactionType {
  @HiveField(0)
  buy,

  @HiveField(1)
  sell,
}

@HiveType(typeId: 2)
class Transaction extends HiveObject {
  @HiveField(0)
  final String transactionId;

  @HiveField(1)
  final String cryptoId;

  @HiveField(2)
  final TransactionType type;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime date;

  Transaction({
    required this.transactionId,
    required this.cryptoId,
    required this.type,
    required this.amount,
    required this.date,
  });
}
