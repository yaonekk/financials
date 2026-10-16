import '../../domain/models/currency.dart';
import '../../domain/models/transaction_item.dart';

/// Data layer DTO representing a serialized transaction in local storage.
class TransactionStorageModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String? categoryId;
  final String currencyCode;
  final int dateMs;
  final String? note;

  const TransactionStorageModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.categoryId,
    required this.currencyCode,
    required this.dateMs,
    this.note,
  });

  factory TransactionStorageModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final String id,
        'title': final String title,
        'amount': final num amount,
        'type': final String type,
        'currencyCode': final String currencyCode,
        'dateMs': final int dateMs,
      } =>
        TransactionStorageModel(
          id: id,
          title: title,
          amount: amount.toDouble(),
          type: type,
          categoryId: json['categoryId'] as String?,
          currencyCode: currencyCode,
          dateMs: dateMs,
          note: json['note'] as String?,
        ),
      _ => throw const FormatException('Invalid TransactionStorageModel JSON format.'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'currencyCode': currencyCode,
      'dateMs': dateMs,
      'note': note,
    };
  }

  factory TransactionStorageModel.fromDomain(TransactionItem item) {
    return TransactionStorageModel(
      id: item.id,
      title: item.title,
      amount: item.amount,
      type: item.type.name,
      categoryId: item.category?.id,
      currencyCode: item.currency.code,
      dateMs: item.date.millisecondsSinceEpoch,
      note: item.note,
    );
  }

  TransactionItem toDomain(List<TransactionCategory> availableCategories) {
    final TransactionCategory? resolvedCategory = categoryId != null
        ? availableCategories.firstWhere(
            (c) => c.id == categoryId,
            orElse: () => TransactionCategory.defaultExpenseCategories.last,
          )
        : null;

    return TransactionItem(
      id: id,
      title: title,
      amount: amount,
      type: TransactionType.values.firstWhere(
        (t) => t.name == type,
        orElse: () => TransactionType.expense,
      ),
      category: resolvedCategory,
      currency: AppCurrency.fromCode(currencyCode),
      date: DateTime.fromMillisecondsSinceEpoch(dateMs),
      note: note,
    );
  }
}

