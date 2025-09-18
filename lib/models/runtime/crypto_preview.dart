class CryptoPreview {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final int marketCapRank;
  final double priceChangePercentage24h;

  CryptoPreview({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCapRank,
    required this.priceChangePercentage24h,
  });
}
