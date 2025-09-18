import 'package:hive/hive.dart';

part 'roi.g.dart';

@HiveType(typeId: 1)
class Roi extends HiveObject {
  @HiveField(0)
  final double times;

  @HiveField(1)
  final String currency;

  @HiveField(2)
  final double percentage;

  Roi({required this.times, required this.currency, required this.percentage});

  factory Roi.fromJson(Map<String, dynamic> json) {
    return Roi(
      times: (json['times'] as num).toDouble(),
      currency: json['currency'] as String,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}
