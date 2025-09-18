import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mocklet_source/app/data/app_constants.dart';

import '../../../models/cached/crypto/crypto.dart';
import '../../../models/cached/user/user_crypto.dart';

class AllHoldingsPage extends StatelessWidget {
  final List<Map<String, dynamic>> allHoldings;

  const AllHoldingsPage({super.key, required this.allHoldings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'all_holdings'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacityValue(0.1),
                    theme.colorScheme.secondary.withOpacityValue(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacityValue(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'total_holdings'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacityValue(
                            0.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'total_assets'.plural(allHoldings.length),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacityValue(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.pie_chart,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: allHoldings.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = allHoldings[index];
                  final userCrypto = item['userCrypto'] as UserCrypto;
                  final crypto = item['crypto'] as Crypto;
                  final value = item['value'] as double;
                  final priceChange = crypto.priceChangePercentage24h;

                  return Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.dividerColor.withOpacityValue(0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacityValue(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: crypto.image.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: crypto.image,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) {
                                    return Container(
                                      color: theme.colorScheme.primary
                                          .withOpacityValue(0.1),
                                      alignment: Alignment.center,
                                      child: Text(
                                        crypto.symbol.toUpperCase().substring(
                                          0,
                                          2,
                                        ),
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: theme.colorScheme.primary
                                      .withOpacityValue(0.1),
                                  alignment: Alignment.center,
                                  child: Text(
                                    crypto.symbol.toUpperCase().substring(0, 2),
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      title: Text(
                        crypto.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${userCrypto.amount.toStringAsFixed(6)} ${crypto.symbol.toUpperCase()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacityValue(0.6),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            crypto.currentPrice.toStringAsFixed(2),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacityValue(0.6),
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            value.toStringAsFixed(2),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
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
                                  (priceChange >= 0 ? Colors.green : Colors.red)
                                      .withOpacityValue(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${priceChange >= 0 ? '+' : ''}${priceChange.toStringAsFixed(2)}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: priceChange >= 0
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
