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

class MonthlyAnalytics {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final double savingsRate;
  final List<CategorySpending> categoryBreakdown;
  final CategorySpending? topSpendingCategory;

  const MonthlyAnalytics({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.savingsRate,
    required this.categoryBreakdown,
    this.topSpendingCategory,
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
