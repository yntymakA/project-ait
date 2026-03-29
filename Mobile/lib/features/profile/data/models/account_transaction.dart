import 'package:intl/intl.dart';

/// Row from `GET /payments/history` (`TransactionResponse`).
class AccountTransaction {
  final int id;
  final String type;
  final double amount;
  final String? description;
  final DateTime createdAt;

  const AccountTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    required this.createdAt,
  });

  bool get isTopUp => type == 'top_up';
  bool get isSpend => type == 'spend';

  factory AccountTransaction.fromJson(Map<String, dynamic> json) {
    return AccountTransaction(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String? ?? '',
      amount: _parseMoney(json['amount']),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static double _parseMoney(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  String formattedTime() {
    final local = createdAt.toLocal();
    return DateFormat.yMMMd().add_Hm().format(local);
  }
}

class TransactionHistoryPage {
  final List<AccountTransaction> items;
  final int total;

  const TransactionHistoryPage({required this.items, required this.total});

  factory TransactionHistoryPage.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List<dynamic>? ?? [];
    return TransactionHistoryPage(
      items: raw
          .map((e) => AccountTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}
