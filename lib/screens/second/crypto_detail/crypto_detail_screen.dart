import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mocklet_source/app/data/app_constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../app/core/brain.dart';
import '../../../app/data/ad_constants.dart';
import '../../../app_logger.dart';
import '../../../models/cached/crypto/crypto.dart';
import '../coingecko_ref.dart';
import 'banner_ad_widget.dart';
import 'buy_sell_widget.dart';
import 'chart_data_point.dart';

class CryptoDetailScreen extends ConsumerStatefulWidget {
  final String cryptoId;
  const CryptoDetailScreen({super.key, required this.cryptoId});

  @override
  ConsumerState<CryptoDetailScreen> createState() => _CryptoDetailScreenState();
}

class _CryptoDetailScreenState extends ConsumerState<CryptoDetailScreen> {
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _maybeLoadInterstitialAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(brainProvider).addLatestCrypto(widget.cryptoId);
    });
  }

  void _maybeLoadInterstitialAd() {
    if (Random().nextDouble() < AdConstants.adChance) {
      _loadInterstitialAd();
    }
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _setupAdCallbacks();
          _interstitialAd?.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          AppLogger.warning(
            'Interstitial ad failed to load: ${error.message}',
            'crypto_detail_screen',
          );
        },
      ),
    );
  }

  void _setupAdCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.warning(
          'InterstitialAd failed to show: $error',
          'crypto_detail_screen',
        );
        ad.dispose();
        _interstitialAd = null;
      },
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    if (price >= 1) {
      return NumberFormat('#,##0.00').format(price);
    } else if (price >= 0.01) {
      return NumberFormat('#,##0.0000').format(price);
    } else {
      return NumberFormat('#,##0.000000').format(price);
    }
  }

  void _showBuySellSheet(
    BuildContext context,
    Crypto crypto, {
    required bool isBuy,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: BuySellWidget(isBuy: isBuy, cryptoId: crypto.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final brain = ref.watch(brainProvider);
    final userData = brain.userData;
    final crypto = brain.getCryptoFromId(widget.cryptoId);

    final theme = Theme.of(context);

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('loading'.tr())),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
              const SizedBox(height: 20),
              Text(
                'fetching_crypto_data'.tr(),
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    final isFavorite = userData.favoriteCryptos.contains(crypto.id);

    return Scaffold(
      appBar: _buildAppBar(context, crypto, theme, isFavorite),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceOverviewSection(context, crypto, theme),
            const SizedBox(height: 24),
            _buildPriceChartSection(context, crypto, theme),
            const SizedBox(height: 24),
            _buildActionButtons(context, crypto),
            const SizedBox(height: 32),
            _buildInfoCard(
              context: context,
              title: 'market_statistics'.tr(),
              children: [
                _buildStatRow(
                  context,
                  'market_cap_rank'.tr(),
                  '#${crypto.marketCapRank}',
                ),
                _buildStatRow(
                  context,
                  'market_cap'.tr(),
                  '\$${NumberFormat.compact().format(crypto.marketCap)}',
                ),
                _buildStatRow(
                  context,
                  'volume_24h'.tr(),
                  '\$${NumberFormat.compact().format(crypto.totalVolume)}',
                ),
                _buildStatRow(
                  context,
                  'circulating_supply'.tr(),
                  NumberFormat.compact().format(crypto.circulatingSupply),
                ),
                if (crypto.maxSupply != null)
                  _buildStatRow(
                    context,
                    'max_supply'.tr(),
                    NumberFormat.compact().format(crypto.maxSupply!),
                  ),
                _buildStatRow(
                  context,
                  'total_supply'.tr(),
                  NumberFormat.compact().format(crypto.totalSupply),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              context: context,
              title: 'performance_24h'.tr(),
              children: [
                _buildStatRow(
                  context,
                  'high_24h'.tr(),
                  '\$${_formatPrice(crypto.high24h)}',
                ),
                _buildStatRow(
                  context,
                  'low_24h'.tr(),
                  '\$${_formatPrice(crypto.low24h)}',
                ),
                _buildStatRow(
                  context,
                  'market_cap_change_24h'.tr(),
                  '${crypto.marketCapChangePercentage24h >= 0 ? '+' : ''}${crypto.marketCapChangePercentage24h.toStringAsFixed(2)}%',
                  valueColor: crypto.marketCapChangePercentage24h >= 0
                      ? Colors.green.shade600
                      : Colors.red.shade600,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              context: context,
              title: 'all_time_records'.tr(),
              children: [
                _buildStatRow(
                  context,
                  'ath'.tr(),
                  '\$${_formatPrice(crypto.ath)}',
                ),
                _buildStatRow(
                  context,
                  'ath_date'.tr(),
                  DateFormat('MMM dd, yyyy').format(crypto.athDate),
                ),
                _buildStatRow(
                  context,
                  'from_ath'.tr(),
                  '${crypto.athChangePercentage.toStringAsFixed(2)}%',
                  valueColor: Colors.red.shade600,
                ),
                _buildStatRow(
                  context,
                  'atl'.tr(),
                  '\$${_formatPrice(crypto.atl)}',
                ),
                _buildStatRow(
                  context,
                  'atl_date'.tr(),
                  DateFormat('MMM dd, yyyy').format(crypto.atlDate),
                ),
                _buildStatRow(
                  context,
                  'from_atl'.tr(),
                  '+${crypto.atlChangePercentage.toStringAsFixed(2)}%',
                  valueColor: Colors.green.shade600,
                ),
              ],
            ),
            if (crypto.roi != null) ...[
              const SizedBox(height: 24),
              _buildInfoCard(
                context: context,
                title: 'roi_title'.tr(),
                children: [
                  _buildStatRow(
                    context,
                    'roi_times'.tr(),
                    '${crypto.roi!.times.toStringAsFixed(2)}x',
                  ),
                  _buildStatRow(
                    context,
                    'roi_percentage'.tr(),
                    '${crypto.roi!.percentage >= 0 ? '+' : ''}${crypto.roi!.percentage.toStringAsFixed(2)}%',
                    valueColor: crypto.roi!.percentage >= 0
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                  ),
                  _buildStatRow(
                    context,
                    'roi_currency'.tr(),
                    crypto.roi!.currency.toUpperCase(),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    Crypto crypto,
    ThemeData theme,
    bool isFavorite,
  ) {
    return AppBar(
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: CachedNetworkImage(
              imageUrl: crypto.image,
              width: 36,
              height: 36,
              placeholder: (context, url) => Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacityValue(0.05),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.currency_bitcoin,
                  size: 20,
                  color: theme.primaryColor,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacityValue(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.currency_bitcoin,
                  size: 20,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  crypto.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  crypto.symbol.toUpperCase(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacityValue(
                      0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.amber : theme.iconTheme.color,
            ),
            onPressed: () async {
              await ref
                  .read(brainProvider)
                  .addCryptoToFavoritesToggle(crypto.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceOverviewSection(
    BuildContext context,
    Crypto crypto,
    ThemeData theme,
  ) {
    final bool isPositive = crypto.priceChangePercentage24h >= 0;
    final Color priceColor = isPositive
        ? Colors.green.shade600
        : Colors.red.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${_formatPrice(crypto.currentPrice)}',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: priceColor.withOpacityValue(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: priceColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isPositive ? '+' : ''}${crypto.priceChangePercentage24h.toStringAsFixed(2)}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: priceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'past_24_hours'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacityValue(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceChartSection(
    BuildContext context,
    Crypto crypto,
    ThemeData theme,
  ) {
    final chartData = <ChartDataPoint>[];
    for (final dataPoint in crypto.sparklineIn7d) {
      dataPoint.forEach((dateTime, price) {
        chartData.add(ChartDataPoint(dateTime, price));
      });
    }
    chartData.sort((a, b) => a.x.compareTo(b.x));

    final bool isPositive = crypto.priceChangePercentage24h >= 0;
    final Color seriesColor = isPositive ? Colors.green : Colors.red;

    return Column(
      children: [
        Center(
          child: BannerAdWidget(adId: AdConstants.cryptoDetailScreenBannerAd),
        ),
        const SizedBox(height: 8),
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withOpacityValue(0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                isVisible: true,
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                dateFormat: DateFormat('d MMM HH:mm'),
                labelIntersectAction: AxisLabelIntersectAction.rotate45,
                labelStyle: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacityValue(
                    0.6,
                  ),
                ),
              ),
              primaryYAxis: NumericAxis(
                isVisible: false,
                majorGridLines: const MajorGridLines(width: 0),
              ),
              plotAreaBorderWidth: 0,
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                lineWidth: 1.5,
                lineType: TrackballLineType.vertical,
                tooltipSettings: InteractiveTooltip(
                  format: '${'price'.tr()}: \${point.y}\n{point.x}',
                  textStyle: theme.textTheme.bodySmall,
                  color: theme.scaffoldBackgroundColor,
                  borderColor: theme.dividerColor,
                ),
              ),
              series: <CartesianSeries>[
                SplineAreaSeries<ChartDataPoint, DateTime>(
                  animationDuration: 0,
                  dataSource: chartData,
                  xValueMapper: (ChartDataPoint data, _) => data.x,
                  yValueMapper: (ChartDataPoint data, _) => data.y,
                  color: seriesColor.withOpacityValue(0.8),
                  borderWidth: 2.5,
                  borderColor: seriesColor,
                  gradient: LinearGradient(
                    colors: [
                      seriesColor.withOpacityValue(0.4),
                      seriesColor.withOpacityValue(0.1),
                      theme.scaffoldBackgroundColor.withOpacityValue(0.1),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        buildPoweredBy(context),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Crypto crypto) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showBuySellSheet(context, crypto, isBuy: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: Colors.green.shade600.withOpacityValue(0.3),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 20),
                const SizedBox(width: 8),
                Text('buy'.tr()),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showBuySellSheet(context, crypto, isBuy: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: Colors.red.shade600.withOpacityValue(0.3),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.remove, size: 20),
                const SizedBox(width: 8),
                Text('sell'.tr()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacityValue(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacityValue(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacityValue(0.7),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? theme.textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
