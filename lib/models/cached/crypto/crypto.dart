import 'package:mocklet_source/models/runtime/crypto_preview.dart';
import 'package:mocklet_source/models/cached/crypto/roi.dart';
import 'package:hive/hive.dart';

part 'crypto.g.dart';

@HiveType(typeId: 0)
class Crypto extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String symbol;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String image;

  @HiveField(4)
  final double currentPrice;

  @HiveField(5)
  final double marketCap;

  @HiveField(6)
  final int marketCapRank;

  @HiveField(7)
  final double fullyDilutedValuation;

  @HiveField(8)
  final double totalVolume;

  @HiveField(9)
  final double high24h;

  @HiveField(10)
  final double low24h;

  @HiveField(11)
  final double priceChange24h;

  @HiveField(12)
  final double priceChangePercentage24h;

  @HiveField(13)
  final double marketCapChange24h;

  @HiveField(14)
  final double marketCapChangePercentage24h;

  @HiveField(15)
  final double circulatingSupply;

  @HiveField(16)
  final double totalSupply;

  @HiveField(17)
  final double? maxSupply;

  @HiveField(18)
  final double ath;

  @HiveField(19)
  final double athChangePercentage;

  @HiveField(20)
  final DateTime athDate;

  @HiveField(21)
  final double atl;

  @HiveField(22)
  final double atlChangePercentage;

  @HiveField(23)
  final DateTime atlDate;

  @HiveField(24)
  final Roi? roi;

  @HiveField(25)
  final DateTime lastUpdated;

  @HiveField(26)
  final List<Map<DateTime, double>> sparklineIn7d;

  Crypto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.fullyDilutedValuation,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.marketCapChange24h,
    required this.marketCapChangePercentage24h,
    required this.circulatingSupply,
    required this.totalSupply,
    this.maxSupply,
    required this.ath,
    required this.athChangePercentage,
    required this.athDate,
    required this.atl,
    required this.atlChangePercentage,
    required this.atlDate,
    this.roi,
    required this.lastUpdated,
    required this.sparklineIn7d,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    List<double> sparkLineDataNumbers =
        (json['sparkline_in_7d']['price'] as List)
            .map((e) => (e as num).toDouble())
            .toList();

    DateTime now = DateTime.now().toUtc();
    now = DateTime.utc(now.year, now.month, now.day, now.hour);
    List<DateTime> hours = [];
    for (int i = 0; i < sparkLineDataNumbers.length; i++) {
      hours.add(now.subtract(Duration(hours: i)));
    }
    hours = hours.reversed.toList();

    List<Map<DateTime, double>> sparklineIn7d = [];
    for (int i = 0; i < sparkLineDataNumbers.length; i++) {
      sparklineIn7d.add({hours[i]: sparkLineDataNumbers[i]});
    }

    return Crypto(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      marketCap: (json['market_cap'] as num).toDouble(),
      marketCapRank: json['market_cap_rank'],
      fullyDilutedValuation: (json['fully_diluted_valuation'] as num)
          .toDouble(),
      totalVolume: (json['total_volume'] as num).toDouble(),
      high24h: (json['high_24h'] as num).toDouble(),
      low24h: (json['low_24h'] as num).toDouble(),
      priceChange24h: (json['price_change_24h'] as num).toDouble(),
      priceChangePercentage24h: (json['price_change_percentage_24h'] as num)
          .toDouble(),
      marketCapChange24h: (json['market_cap_change_24h'] as num).toDouble(),
      marketCapChangePercentage24h:
          (json['market_cap_change_percentage_24h'] as num).toDouble(),
      circulatingSupply: (json['circulating_supply'] as num).toDouble(),
      totalSupply: (json['total_supply'] as num).toDouble(),
      maxSupply: json['max_supply'] != null
          ? (json['max_supply'] as num).toDouble()
          : null,
      ath: (json['ath'] as num).toDouble(),
      athChangePercentage: (json['ath_change_percentage'] as num).toDouble(),
      athDate: DateTime.parse(json['ath_date'] as String),
      atl: (json['atl'] as num).toDouble(),
      atlChangePercentage: (json['atl_change_percentage'] as num).toDouble(),
      atlDate: DateTime.parse(json['atl_date'] as String),
      roi: json['roi'] != null
          ? Roi.fromJson(json['roi'] as Map<String, dynamic>)
          : null,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      sparklineIn7d: sparklineIn7d,
    );
  }

  CryptoPreview getPreview() {
    return CryptoPreview(
      id: id,
      symbol: symbol,
      name: name,
      image: image,
      currentPrice: currentPrice,
      marketCapRank: marketCapRank,
      priceChangePercentage24h: priceChangePercentage24h,
    );
  }
}
