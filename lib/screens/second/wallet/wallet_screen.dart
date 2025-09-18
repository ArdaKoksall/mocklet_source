import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocklet_source/app/data/ad_constants.dart';
import 'package:mocklet_source/app/data/app_constants.dart';
import 'package:mocklet_source/screens/second/crypto_detail/banner_ad_widget.dart';

import '../../../app/core/brain.dart';
import '../../../models/cached/crypto/crypto.dart';
import '../../../models/cached/user/settings.dart';
import '../../../models/cached/user/transaction.dart';
import '../../../models/cached/user/user_crypto.dart';
import '../../../models/cached/user/user_data.dart';
import '../crypto_detail/crypto_detail_screen.dart';
import 'all_holdings_screen.dart';
import 'all_transactions_screen.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brain = ref.watch(brainProvider);
    final userData = brain.userData;

    final theme = Theme.of(context);

    if (userData == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'loading_your_wallet'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacityValue(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacityValue(0.1),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Text(
          'my_wallet'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEnhancedBalanceCard(userData, theme),

              const SizedBox(height: 8),
              BannerAdWidget(
                adId: AdConstants.walletScreenBannerAd,
                shouldShrink: false,
              ),
              const SizedBox(height: 8),

              _buildTopCryptosSection(userData, theme, brain),
              const SizedBox(height: 32),

              _buildLatestSeenCryptosSection(theme, brain),
              const SizedBox(height: 32),

              _buildTransactionsSection(userData, theme, brain),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedBalanceCard(UserData userData, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacityValue(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacityValue(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'total_portfolio_value'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacityValue(0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData.totalBalance.toStringAsFixed(2),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 36,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacityValue(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.trending_up, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacityValue(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacityValue(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacityValue(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'available_balance'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacityValue(0.8),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${userData.tetherBalance.toStringAsFixed(2)} USDT',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCryptosSection(
    UserData userData,
    ThemeData theme,
    Brain brain,
  ) {
    final topCryptos =
        userData.userCryptos.map((userCrypto) {
          final crypto = brain.getCryptoFromId(userCrypto.cryptoId);
          return {
            'userCrypto': userCrypto,
            'crypto': crypto,
            'value': userCrypto.amount * crypto.currentPrice,
          };
        }).toList()..sort(
          (a, b) => (b['value'] as double).compareTo(a['value'] as double),
        );

    final top5 = topCryptos.take(5).toList();
    final show = brain.userData?.settings.showTopHoldings ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'top_holdings'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (top5.isNotEmpty && show)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AllHoldingsPage(allHoldings: topCryptos),
                        ),
                      );
                    },
                    icon: Icon(Icons.arrow_forward_ios, size: 14),
                    label: Text(
                      'view_all'.tr(),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    show ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () async {
                    await brain.toggleSetting(SettingField.showTopHoldings);
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (show) _buildCryptoContainer(top5, theme, true),
      ],
    );
  }

  Widget _buildLatestSeenCryptosSection(ThemeData theme, Brain brain) {
    final latestCryptos = brain.getLatestCryptos();
    bool recentlyViewed = brain.userData?.settings.showRecentActivity ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'recently_viewed'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            IconButton(
              icon: Icon(
                recentlyViewed ? Icons.visibility : Icons.visibility_off,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              onPressed: () async {
                await brain.toggleSetting(SettingField.showRecentActivity);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentlyViewed) _buildLatestCryptosContainer(latestCryptos, theme),
      ],
    );
  }

  Widget _buildLatestCryptosContainer(
    List<dynamic> latestCryptos,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacityValue(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacityValue(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: latestCryptos.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacityValue(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.visibility_outlined,
                        size: 32,
                        color: theme.colorScheme.primary.withOpacityValue(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'no_recently_viewed_cryptos'.tr(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacityValue(
                          0.6,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'explore_cryptocurrencies_to_see_them_here'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacityValue(
                          0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: List.generate(latestCryptos.length, (index) {
                final crypto = latestCryptos[index];
                final priceChange = crypto.priceChangePercentage24h;

                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  CryptoDetailScreen(cryptoId: crypto.id),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.vertical(
                          top: index == 0 ? Radius.circular(16) : Radius.zero,
                          bottom: index == latestCryptos.length - 1
                              ? Radius.circular(16)
                              : Radius.zero,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withOpacityValue(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: crypto.image.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: crypto.image,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) {
                                            return Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                crypto.symbol
                                                    .toUpperCase()
                                                    .substring(0, 2),
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            crypto.symbol
                                                .toUpperCase()
                                                .substring(0, 2),
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      crypto.name,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          crypto.symbol.toUpperCase(),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacityValue(0.6),
                                                fontSize: 13,
                                              ),
                                        ),
                                        if (crypto.marketCapRank != null) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary
                                                  .withOpacityValue(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '#${crypto.marketCapRank}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    crypto.currentPrice.toStringAsFixed(2),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (priceChange >= 0
                                                  ? Colors.green
                                                  : Colors.red)
                                              .withOpacityValue(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${priceChange >= 0 ? '+' : ''}${priceChange.toStringAsFixed(2)}%',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: priceChange >= 0
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (index < latestCryptos.length - 1)
                      Divider(
                        height: 1,
                        color: theme.dividerColor.withOpacityValue(0.1),
                        indent: 72,
                      ),
                  ],
                );
              }),
            ),
    );
  }

  Widget _buildCryptoContainer(
    List<Map<String, dynamic>> items,
    ThemeData theme,
    bool isHoldings,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacityValue(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacityValue(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: items.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacityValue(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.pie_chart_outline,
                        size: 32,
                        color: theme.colorScheme.primary.withOpacityValue(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'no_holdings_yet'.tr(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacityValue(
                          0.6,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'start_investing_to_see_your_portfolio_here'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacityValue(
                          0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final userCrypto = item['userCrypto'] as UserCrypto;
                final crypto = item['crypto'] as Crypto;
                final value = item['value'] as double;
                final priceChange = crypto.priceChangePercentage24h;

                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  CryptoDetailScreen(cryptoId: crypto.id),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.vertical(
                          top: index == 0 ? Radius.circular(16) : Radius.zero,
                          bottom: index == items.length - 1
                              ? Radius.circular(16)
                              : Radius.zero,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withOpacityValue(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: crypto.image.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: crypto.image,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) {
                                            return Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                crypto.symbol
                                                    .toUpperCase()
                                                    .substring(0, 2),
                                                style: TextStyle(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            crypto.symbol
                                                .toUpperCase()
                                                .substring(0, 2),
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      crypto.name,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${userCrypto.amount.toStringAsFixed(6)} ${crypto.symbol.toUpperCase()}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacityValue(0.6),
                                            fontSize: 13,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    value.toStringAsFixed(2),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (priceChange >= 0
                                                  ? Colors.green
                                                  : Colors.red)
                                              .withOpacityValue(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${priceChange >= 0 ? '+' : ''}${priceChange.toStringAsFixed(2)}%',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: priceChange >= 0
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (index < items.length - 1)
                      Divider(
                        height: 1,
                        color: theme.dividerColor.withOpacityValue(0.1),
                        indent: 72,
                      ),
                  ],
                );
              }),
            ),
    );
  }

  Widget _buildTransactionsSection(
    UserData userData,
    ThemeData theme,
    Brain brain,
  ) {
    final recentTransactions =
        userData.transactions
            .where(
              (t) => t.date.isAfter(
                DateTime.now().subtract(const Duration(days: 30)),
              ),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final latest5 = recentTransactions.take(5).toList();
    final show = brain.userData?.settings.showRecentTransactions ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'transactions'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            Row(
              children: [
                if (show && latest5.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AllTransactionsPage(
                            allTransactions: recentTransactions,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.arrow_forward_ios, size: 14),
                    label: Text(
                      'view_all'.tr(),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    show ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () async {
                    await brain.toggleSetting(
                      SettingField.showRecentTransactions,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (show) _buildTransactionContainer(latest5, brain, theme),
      ],
    );
  }

  Widget _buildTransactionContainer(
    List<dynamic> transactions,
    Brain brainData,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacityValue(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacityValue(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: transactions.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacityValue(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 32,
                        color: theme.colorScheme.primary.withOpacityValue(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'no_recent_transactions'.tr(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacityValue(
                          0.6,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'your_transaction_history_will_appear_here'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacityValue(
                          0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: List.generate(transactions.length, (index) {
                final transaction = transactions[index];
                final crypto = brainData.getCryptoFromId(transaction.cryptoId);
                final isBuy = transaction.type == TransactionType.buy;
                final totalValue = transaction.amount * crypto.currentPrice;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: (isBuy ? Colors.green : Colors.red)
                                  .withOpacityValue(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: crypto.image.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: crypto.image,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                    child: SizedBox(
                                                      width: 12,
                                                      height: 12,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 1.5,
                                                          ),
                                                    ),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) {
                                                    return Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        crypto.symbol
                                                            .toUpperCase()
                                                            .substring(0, 2),
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: theme
                                                              .colorScheme
                                                              .onSurface,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            )
                                          : Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                crypto.symbol
                                                    .toUpperCase()
                                                    .substring(0, 2),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: isBuy ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: theme.colorScheme.surface,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      isBuy ? Icons.add : Icons.remove,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${isBuy ? 'bought'.tr() : 'sold'.tr()} ${crypto.name}',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(transaction.date),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacityValue(0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isBuy ? '+' : '-'}${transaction.amount.toStringAsFixed(4)} ${crypto.symbol.toUpperCase()}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isBuy ? Colors.green : Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                totalValue.toStringAsFixed(2),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacityValue(0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (index < transactions.length - 1)
                      Divider(
                        height: 1,
                        color: theme.dividerColor.withOpacityValue(0.1),
                        indent: 72,
                      ),
                  ],
                );
              }),
            ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}${'days_ago_short'.tr()}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${'hours_ago_short'.tr()}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${'minutes_ago_short'.tr()}';
    } else {
      return 'just_now'.tr();
    }
  }
}
