import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocklet_source/app/core/brain.dart';
import 'package:mocklet_source/app/data/app_constants.dart';

import '../../../models/cached/user/transaction.dart';

class AllTransactionsPage extends ConsumerStatefulWidget {
  final List<Transaction> allTransactions;

  const AllTransactionsPage({super.key, required this.allTransactions});

  @override
  ConsumerState<AllTransactionsPage> createState() =>
      _AllTransactionsPageState();
}

class _AllTransactionsPageState extends ConsumerState<AllTransactionsPage> {
  String selectedFilter = 'filter_all';
  final List<String> filters = ['filter_all', 'filter_buy', 'filter_sell'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredTransactions = selectedFilter == 'filter_all'
        ? widget.allTransactions
        : widget.allTransactions
              .where(
                (t) =>
                    (selectedFilter == 'filter_buy' &&
                        t.type == TransactionType.buy) ||
                    (selectedFilter == 'filter_sell' &&
                        t.type == TransactionType.sell),
              )
              .toList();

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
          'transaction_history'.tr(),
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
              height: 50,
              margin: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: filters.map((filterKey) {
                  final isSelected = selectedFilter == filterKey;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedFilter = filterKey),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.dividerColor.withOpacityValue(0.1),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            filterKey.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'summary_total'.tr(),
                    '${filteredTransactions.length}',
                    theme,
                  ),
                  _buildSummaryItem(
                    'summary_this_month'.tr(),
                    '${_getThisMonthCount(filteredTransactions)}',
                    theme,
                  ),
                  _buildSummaryItem(
                    'summary_today'.tr(),
                    '${_getTodayCount(filteredTransactions)}',
                    theme,
                  ),
                ],
              ),
            ),

            Expanded(
              child: filteredTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacityValue(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              size: 40,
                              color: theme.colorScheme.primary.withOpacityValue(
                                0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'no_transactions_found_title'.tr(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface
                                  .withOpacityValue(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'no_transactions_found_subtitle'.tr(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacityValue(0.4),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredTransactions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        final preview = ref
                            .read(brainProvider)
                            .getCryptoFromId(transaction.cryptoId)
                            .getPreview();

                        final isBuy = transaction.type == TransactionType.buy;

                        return Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.dividerColor.withOpacityValue(0.1),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: (isBuy ? Colors.green : Colors.red)
                                    .withOpacityValue(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: preview.image,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error, color: Colors.red),
                                fit: BoxFit.cover,
                                width: 48,
                                height: 48,
                              ),
                            ),
                            title: Text(
                              '${isBuy ? 'list_item_buy'.tr() : 'list_item_sell'.tr()} ${preview.name}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              _formatDate(transaction.date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacityValue(0.6),
                              ),
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${isBuy ? '+' : '-'}${transaction.amount.toStringAsFixed(4)}',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isBuy ? Colors.green : Colors.red,
                                  ),
                                ),
                                Text(
                                  '${'transaction_id_prefix'.tr()}${transaction.transactionId}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacityValue(0.5),
                                    fontSize: 11,
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

  Widget _buildSummaryItem(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacityValue(0.6),
          ),
        ),
      ],
    );
  }

  int _getThisMonthCount(List<Transaction> transactions) {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    return transactions.where((t) => t.date.isAfter(thisMonthStart)).length;
  }

  int _getTodayCount(List<Transaction> transactions) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return transactions.where((t) => t.date.isAfter(todayStart)).length;
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
