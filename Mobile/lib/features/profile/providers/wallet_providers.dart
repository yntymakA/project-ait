import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/account_transaction.dart';
import '../data/models/promotion_package.dart';
import '../data/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

final promotionPackagesProvider =
    FutureProvider.autoDispose<List<PromotionPackage>>((ref) async {
  return ref.read(walletRepositoryProvider).listPackages();
});

final transactionHistoryProvider =
    FutureProvider.autoDispose<List<AccountTransaction>>((ref) async {
  final page = await ref.read(walletRepositoryProvider).getTransactionHistory(
        limit: 80,
        offset: 0,
      );
  return page.items;
});
