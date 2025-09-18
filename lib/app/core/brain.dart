import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocklet_source/api/api_service.dart';
import 'package:mocklet_source/app/service/hive_service.dart';
import 'package:mocklet_source/app_logger.dart';
import 'package:mocklet_source/models/cached/user/settings.dart';
import 'package:mocklet_source/models/cached/user/user_data.dart';

import '../../models/cached/crypto/crypto.dart';
import '../../models/cached/user/transaction.dart';
import '../../models/cached/user/user_crypto.dart';
import '../../models/runtime/crypto_preview.dart';
import '../data/app_constants.dart';

class Brain extends ChangeNotifier {
  List<Crypto>? cryptoList;
  final ApiService _apiService = ApiService();
  UserData? userData;
  late String? _uid;
  Timer? _fetchTimer;

  Future<void> init() async {
    try {
      cryptoList = await _initData();
      _uid = FirebaseAuth.instance.currentUser?.uid;
      if (_uid == null) {
        throw ('No user is currently logged in.');
      }
      final userDataFromHive = HiveService.getUserData(_uid!);
      if (userDataFromHive == null) {
        userData = await createUserData();
        if (userData == null) {
          throw ('Failed to create user data');
        }
      } else {
        userData = userDataFromHive;
        AppLogger.info("User data loaded from Hive");
      }
      final totalValue = calculateTotalValue();
      if (totalValue != null && (totalValue != userData!.totalBalance)) {
        await HiveService.updateUser(
          updater: (userData) async {
            userData.totalBalance = totalValue;
          },
          uid: userData!.userId,
        );
      }
      startFetching();
    } catch (e, s) {
      AppLogger.error(error: e, stack: s, reason: 'Error initializing Brain');
    }
    notifyListeners();
  }

  void cleanUp() {
    stopFetching();
    _uid = null;
    cryptoList = null;
    userData = null;
    _fetchTimer = null;
    AppLogger.info("Brain cleaned up");
  }

  void startFetching() {
    stopFetching();
    _fetchTimer = Timer.periodic(
      const Duration(seconds: AppConstants.fetchInterval),
      (timer) => fetchData(),
    );
  }

  Future<void> fetchData() async {
    try {
      if (cryptoList == null) {
        AppLogger.warning('Crypto list is null, skipping fetch', 'brain');
        return;
      }
      if (userData == null) {
        AppLogger.warning(
          'User data is null, cannot fetch crypto data',
          'brain',
        );
        return;
      }
      final newData = await _apiService.getData();
      if (newData != null) {
        cryptoList = newData;
        await HiveService.saveCryptos(newData);
        final totalValue = calculateTotalValue();
        if (totalValue != null && (totalValue != userData!.totalBalance)) {
          await HiveService.updateUser(
            updater: (userData) async {
              userData.totalBalance = totalValue;
            },
            uid: userData!.userId,
          );
        }
        notifyListeners();
      } else {
        AppLogger.warning('Failed to fetch data from API', 'brain');
      }
    } catch (e, s) {
      AppLogger.error(error: e, stack: s, reason: 'Error fetching data');
    }
  }

  void stopFetching() {
    _fetchTimer?.cancel();
  }

  double? calculateTotalValue() {
    if (userData == null || cryptoList == null) return null;

    double totalValue = 0.0;
    for (final userCrypto in userData!.userCryptos) {
      final crypto = cryptoList!.firstWhere((c) => c.id == userCrypto.cryptoId);
      totalValue += userCrypto.amount * crypto.currentPrice;
    }
    return totalValue + userData!.tetherBalance;
  }

  Future<UserData?> createUserData() async {
    try {
      if (_uid == null) {
        throw ('No user ID available for creating user data');
      }

      final user = UserData(
        userId: _uid!,
        transactions: [],
        userCryptos: [],
        totalBalance: 10000.0,
        favoriteCryptos: [],
        tetherBalance: 10000.0,
        settings: Settings(),
      );
      await HiveService.createUserData(user);
      return user;
    } catch (e, s) {
      AppLogger.error(error: e, stack: s, reason: 'Error creating user data');
      return null;
    }
  }

  Future<List<Crypto>?> _initData() async {
    try {
      final fallbackData = HiveService.getCryptos();
      if (fallbackData == null) {
        final newData = await _apiService.getData();
        if (newData == null) {
          AppLogger.warning('Failed to fetch data from API', 'brain');
          return null;
        } else {
          await HiveService.saveCryptos(newData);
          return newData;
        }
      } else {
        final newData = await _apiService.getData();
        if (newData == null) {
          AppLogger.warning(
            'Failed to fetch data from API, using fallback data',
            'brain',
          );
          return fallbackData;
        } else {
          await HiveService.saveCryptos(newData);
          return newData;
        }
      }
    } catch (e, s) {
      AppLogger.error(
        error: e,
        stack: s,
        reason: 'Error initializing crypto data',
      );
      return null;
    }
  }

  Future<TransactionResponse> executeTransaction({
    required String cryptoId,
    required double cryptoAmount,
    required TransactionType transactionType,
    required double pricePerCoin,
  }) async {
    if (userData == null) {
      return TransactionResponse(
        success: false,
        message: 'User data is not available',
      );
    }

    if (cryptoId == "tether") {
      return TransactionResponse(
        success: false,
        message: 'Cannot buy or sell Tether directly',
      );
    }
    final totalCost = cryptoAmount * pricePerCoin;

    await HiveService.updateUser(
      updater: (userData) async {
        if (transactionType == TransactionType.buy) {
          userData.tetherBalance -= totalCost;

          final cryptoIndex = userData.userCryptos.indexWhere(
            (c) => c.cryptoId == cryptoId,
          );
          if (cryptoIndex != -1) {
            final existingCrypto = userData.userCryptos[cryptoIndex];
            final newAmount = existingCrypto.amount + cryptoAmount;
            userData.userCryptos[cryptoIndex] = UserCrypto(
              cryptoId: cryptoId,
              amount: newAmount,
            );
          } else {
            userData.userCryptos.add(
              UserCrypto(cryptoId: cryptoId, amount: cryptoAmount),
            );
          }
        } else {
          userData.tetherBalance += totalCost;

          final cryptoIndex = userData.userCryptos.indexWhere(
            (c) => c.cryptoId == cryptoId,
          );
          if (cryptoIndex != -1) {
            final existingCrypto = userData.userCryptos[cryptoIndex];
            final newAmount = existingCrypto.amount - cryptoAmount;

            if (newAmount > 0.00000001) {
              userData.userCryptos[cryptoIndex] = UserCrypto(
                cryptoId: cryptoId,
                amount: newAmount,
              );
            } else {
              userData.userCryptos.removeAt(cryptoIndex);
            }
          }
        }
        final newTransaction = Transaction(
          transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
          cryptoId: cryptoId,
          type: transactionType,
          amount: cryptoAmount,
          date: DateTime.now().toUtc(),
        );
        userData.transactions.add(newTransaction);
      },
      uid: _uid!,
    );

    notifyListeners();
    return TransactionResponse(
      success: true,
      message: 'Transaction successful',
    );
  }

  Future<void> addCryptoToFavoritesToggle(String cryptoId) async {
    if (userData == null) return;

    await HiveService.updateUser(
      updater: (userData) async {
        if (userData.favoriteCryptos.contains(cryptoId)) {
          userData.favoriteCryptos.remove(cryptoId);
        } else {
          userData.favoriteCryptos.add(cryptoId);
        }
      },
      uid: _uid!,
    );

    notifyListeners();
  }

  Crypto getCryptoFromId(String cryptoId) {
    final crypto = cryptoList!.firstWhere((c) => c.id == cryptoId);
    return crypto;
  }

  List<CryptoPreview> getLatestCryptos() {
    if (userData == null || userData!.latestCryptos.isEmpty) {
      return [];
    }
    return userData!.latestCryptos
        .map((cryptoId) => getCryptoFromId(cryptoId).getPreview())
        .toList();
  }

  void addLatestCrypto(String cryptoId) {
    if (userData == null) return;

    HiveService.updateUser(
      updater: (userData) async {
        final latest = List<String>.from(userData.latestCryptos);
        latest.remove(cryptoId);
        latest.insert(0, cryptoId);
        if (latest.length > AppConstants.maxLatestCryptos) {
          latest.removeLast();
        }
        userData.latestCryptos = latest;
      },
      uid: _uid!,
    );

    notifyListeners();
  }

  Future<void> toggleSetting(SettingField field) async {
    if (userData == null) return;

    await HiveService.updateUser(
      updater: (userData) async {
        switch (field) {
          case SettingField.showRecentTransactions:
            userData.settings.showRecentTransactions =
                !userData.settings.showRecentTransactions;
            break;
          case SettingField.showTopHoldings:
            userData.settings.showTopHoldings =
                !userData.settings.showTopHoldings;
            break;
          case SettingField.showRecentActivity:
            userData.settings.showRecentActivity =
                !userData.settings.showRecentActivity;
            break;
        }
      },
      uid: _uid!,
    );

    notifyListeners();
  }
}

class TransactionResponse {
  final bool success;
  final String message;

  TransactionResponse({required this.success, required this.message});
}

final brainProvider = ChangeNotifierProvider<Brain>((ref) {
  return Brain();
});
