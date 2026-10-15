import 'transaction_item.dart';

class CategorySpending {
  final TransactionCategory category;
  final double totalAmount;
  final double percentage; // 0 to 100
  final int count;

  const CategorySpending({
    required this.category,
    required this.totalAmount,
    required this.percentage,
    required this.count,
  });
}

class DeletedTransactionSnapshot {
  final TransactionItem item;
  final int originalIndex;

  const DeletedTransactionSnapshot({
    required this.item,
    required this.originalIndex,
  });
}

