import '../../../core/api/api_client.dart';
import 'models/account_transaction.dart';
import 'models/promotion_package.dart';

class WalletRepository {
  Future<void> topUp(double amount) async {
    await dioClient.post<Map<String, dynamic>>(
      '/payments/top-up',
      data: {
        'amount': amount,
        'payment_method': 'credit_card',
      },
    );
  }

  Future<List<PromotionPackage>> listPackages() async {
    final res = await dioClient.get<Map<String, dynamic>>('/promotions/packages');
    final raw = res.data!['items'] as List<dynamic>? ?? [];
    return raw
        .map((e) => PromotionPackage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> purchaseFeatured({
    required int packageId,
    int? listingId,
  }) async {
    await dioClient.post<Map<String, dynamic>>(
      '/promotions/purchase',
      data: {
        'package_id': packageId,
        if (listingId != null) 'listing_id': listingId,
      },
    );
  }

  Future<TransactionHistoryPage> getTransactionHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    final res = await dioClient.get<Map<String, dynamic>>(
      '/payments/history',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return TransactionHistoryPage.fromJson(res.data!);
  }
}
