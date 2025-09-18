import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/core/brain.dart';
import '../../../models/cached/crypto/crypto.dart';
import '../../../models/cached/user/transaction.dart';
import '../../../models/cached/user/user_crypto.dart';

class BuySellWidget extends ConsumerStatefulWidget {
  final bool isBuy;
  final String cryptoId;

  const BuySellWidget({super.key, required this.isBuy, required this.cryptoId});

  @override
  ConsumerState<BuySellWidget> createState() => _BuySellWidgetState();
}

class _BuySellWidgetState extends ConsumerState<BuySellWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  bool _isUpdating = false;

  double _lastKnownPrice = 0.0;
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _amountController.addListener(_onAmountChanged);
    _totalController.addListener(_onTotalChanged);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _activeTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.removeListener(_onAmountChanged);
    _totalController.removeListener(_onTotalChanged);
    _amountController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Crypto? _getCurrentCrypto() {
    return ref
        .read(brainProvider)
        .cryptoList
        ?.firstWhere((c) => c.id == widget.cryptoId);
  }

  void _onAmountChanged() {
    if (_isUpdating) return;
    _isUpdating = true;

    final crypto = _getCurrentCrypto();
    if (crypto == null) {
      _isUpdating = false;
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    final total = amount * crypto.currentPrice;
    _totalController.text = total > 0 ? total.toStringAsFixed(2) : '';

    WidgetsBinding.instance.addPostFrameCallback((_) => _isUpdating = false);
  }

  void _onTotalChanged() {
    if (_isUpdating) return;
    _isUpdating = true;

    final crypto = _getCurrentCrypto();
    if (crypto == null) {
      _isUpdating = false;
      return;
    }

    final total = double.tryParse(_totalController.text) ?? 0;
    final amount = crypto.currentPrice > 0 ? total / crypto.currentPrice : 0;
    _amountController.text = amount > 0 ? amount.toStringAsFixed(8) : '';

    WidgetsBinding.instance.addPostFrameCallback((_) => _isUpdating = false);
  }

  void _onPercentagePressed(
    double percentage,
    double tetherBalance,
    double cryptoHolding,
  ) {
    if (widget.isBuy) {
      final totalToSpend = tetherBalance * (percentage / 100);
      _totalController.text = totalToSpend.toStringAsFixed(2);
      _onTotalChanged();
    } else {
      final amountToSell = cryptoHolding * (percentage / 100);
      _amountController.text = amountToSell.toStringAsFixed(8);
      _onAmountChanged();
    }
  }

  void _executeTransaction() async {
    FocusScope.of(context).unfocus();

    final brain = ref.read(brainProvider);
    final crypto = brain.cryptoList?.firstWhere((c) => c.id == widget.cryptoId);
    final userData = brain.userData;

    if (crypto == null || userData == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('error_latest_data'.tr())));
      return;
    }

    final userCrypto = userData.userCryptos.firstWhere(
      (c) => c.cryptoId == widget.cryptoId,
      orElse: () => UserCrypto(cryptoId: widget.cryptoId, amount: 0.0),
    );
    final cryptoHolding = userCrypto.amount;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final total = double.tryParse(_totalController.text) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('error_invalid_amount'.tr()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (widget.isBuy) {
      if (total > userData.tetherBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_insufficient_tether'.tr()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      if (amount > cryptoHolding) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'error_insufficient_crypto'.tr(
                namedArgs: {'symbol': crypto.symbol.toUpperCase()},
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final response = await ref
        .read(brainProvider.notifier)
        .executeTransaction(
          cryptoId: crypto.id,
          cryptoAmount: amount,
          transactionType: widget.isBuy
              ? TransactionType.buy
              : TransactionType.sell,
          pricePerCoin: crypto.currentPrice,
        );

    if (!mounted) return;
    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.red),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isBuy
              ? 'success_buy'.tr(namedArgs: {'name': crypto.name})
              : 'success_sell'.tr(namedArgs: {'name': crypto.name}),
        ),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final brain = ref.watch(brainProvider);
    final crypto = brain.getCryptoFromId(widget.cryptoId);
    final userData = brain.userData;

    if (userData == null) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final newPrice = crypto.currentPrice;
    if (_lastKnownPrice != 0.0 && _lastKnownPrice != newPrice) {
      _lastKnownPrice = newPrice;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_activeTabIndex == 0) {
          _onAmountChanged();
        } else {
          _onTotalChanged();
        }
      });
    } else if (_lastKnownPrice == 0.0) {
      _lastKnownPrice = newPrice;
    }

    final userCrypto = userData.userCryptos.firstWhere(
      (c) => c.cryptoId == widget.cryptoId,
      orElse: () => UserCrypto(cryptoId: widget.cryptoId, amount: 0.0),
    );
    final cryptoHolding = userCrypto.amount;

    final theme = Theme.of(context);
    final cryptoSymbol = crypto.symbol.toUpperCase();
    final availableBalance = widget.isBuy
        ? userData.tetherBalance
        : cryptoHolding;
    final availableBalanceSymbol = widget.isBuy ? 'USD' : cryptoSymbol;

    return DefaultTabController(
      length: 2,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isBuy
                  ? 'title_buy'.tr(namedArgs: {'name': crypto.name})
                  : 'title_sell'.tr(namedArgs: {'name': crypto.name}),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'tab_by_amount'.tr()),
                Tab(text: 'tab_by_total'.tr()),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 80,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInputRow(
                    context,
                    label: 'label_amount'.tr(),
                    controller: _amountController,
                    suffix: cryptoSymbol,
                  ),
                  _buildInputRow(
                    context,
                    label: 'label_total'.tr(),
                    controller: _totalController,
                    suffix: 'USD',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('label_available'.tr(), style: theme.textTheme.bodySmall),
                Text(
                  '${NumberFormat('#,##0.########').format(availableBalance)} $availableBalanceSymbol',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPercentageRow(userData.tetherBalance, cryptoHolding),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _executeTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isBuy
                      ? Colors.green.shade600
                      : Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(
                  widget.isBuy
                      ? 'button_buy'.tr(namedArgs: {'symbol': cryptoSymbol})
                      : 'button_sell'.tr(namedArgs: {'symbol': cryptoSymbol}),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String suffix,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixText: suffix,
              suffixStyle: TextStyle(
                color: theme.textTheme.bodySmall?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPercentageRow(double tetherBalance, double cryptoHolding) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [25, 50, 75, 100].map((p) {
        return Flexible(
          child: OutlinedButton(
            onPressed: () => _onPercentagePressed(
              p.toDouble(),
              tetherBalance,
              cryptoHolding,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('$p%'),
          ),
        );
      }).toList(),
    );
  }
}
