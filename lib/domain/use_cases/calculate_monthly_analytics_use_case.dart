import '../models/currency.dart';
import '../models/spending_analytics.dart';
import '../models/transaction_item.dart';

/// Domain layer Use Case that computes monthly financial analytics
/// (multi-currency normalization, income/expense totals, savings rate,
/// and category spending breakdown).
class CalculateMonthlyAnalyticsUseCase {
  const CalculateMonthlyAnalyticsUseCase();

  MonthlyAnalytics execute({
    required List<TransactionItem> monthTransactions,
    required AppCurrency primaryCurrency,
  }) {
    final incomes = monthTransactions.where(
      (t) => t.type == TransactionType.income,
    );
    final expenses = monthTransactions.where(
      (t) => t.type == TransactionType.expense,
    );

    final totalIncomeUsd = incomes.fold<double>(
      0.0,
      (sum, t) => sum + t.amountInUsd,
    );
    final totalExpenseUsd = expenses.fold<double>(
      0.0,
      (sum, t) => sum + t.amountInUsd,
    );

    final totalIncome = totalIncomeUsd / primaryCurrency.rateToUsd;
    final totalExpense = totalExpenseUsd / primaryCurrency.rateToUsd;
    final netBalance = totalIncome - totalExpense;

    final double savingsRate = totalIncome <= 0
        ? 0.0
        : ((netBalance / totalIncome) * 100).clamp(-100.0, 100.0);

    if (expenses.isEmpty) {
      return MonthlyAnalytics(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        netBalance: netBalance,
        savingsRate: savingsRate,
        categoryBreakdown: const [],
        topSpendingCategory: null,
      );
    }

    final Map<String, List<TransactionItem>> grouped = {};
    for (final exp in expenses) {
      final catId = exp.category?.id ?? 'other_expense';
      grouped.putIfAbsent(catId, () => []).add(exp);
    }

    final List<CategorySpending> breakdown = [];
    grouped.forEach((catId, items) {
      final category =
          items.first.category ??
          TransactionCategory.defaultExpenseCategories.last;
      final catUsd = items.fold<double>(0.0, (sum, t) => sum + t.amountInUsd);
      final catConverted = catUsd / primaryCurrency.rateToUsd;
      final percentage = totalExpenseUsd > 0
          ? (catUsd / totalExpenseUsd) * 100
          : 0.0;

      breakdown.add(
        CategorySpending(
          category: category,
          totalAmount: catConverted,
          percentage: percentage,
          count: items.length,
        ),
      );
    });

    breakdown.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return MonthlyAnalytics(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netBalance: netBalance,
      savingsRate: savingsRate,
      categoryBreakdown: breakdown,
      topSpendingCategory: breakdown.isNotEmpty ? breakdown.first : null,
    );
  }
}

