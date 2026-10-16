import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../domain/models/currency.dart';
import '../../../../domain/models/spending_analytics.dart';
import '../../../../domain/models/transaction_item.dart';
import '../../../../domain/repositories/transaction_repository.dart';
import '../../../../domain/use_cases/calculate_monthly_analytics_use_case.dart';

enum FilterType { all, expenses, income }

/// ViewModel managing state and user interactions for the tracker and statistics views.
/// Delegates data persistence to [TransactionRepository] and complex domain
/// calculations to [CalculateMonthlyAnalyticsUseCase].
class ExpenseTrackerViewModel extends ChangeNotifier {
  final TransactionRepository repository;
  final CalculateMonthlyAnalyticsUseCase calculateAnalyticsUseCase;

  // Selected view month
  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  // Primary display currency for totals & statistics
  AppCurrency _primaryCurrency = AppCurrency.supportedCurrencies.first;

  // Filter criteria
  FilterType _filterType = FilterType.all;
  String? _selectedCategoryId;

  // Undo delete mechanism
  DeletedTransactionSnapshot? _lastDeleted;

  ExpenseTrackerViewModel({
    required this.repository,
    this.calculateAnalyticsUseCase = const CalculateMonthlyAnalyticsUseCase(),
  });

  // Getters
  DateTime get selectedMonth => _selectedMonth;
  AppCurrency get primaryCurrency => _primaryCurrency;
  FilterType get filterType => _filterType;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get hasUndoAvailable => _lastDeleted != null;

  List<TransactionCategory> get customCategories =>
      repository.getCustomCategories();

  List<TransactionCategory> get expenseCategories => [
    ...TransactionCategory.defaultExpenseCategories,
    ...repository.getCustomCategories(),
  ];

  void setPrimaryCurrency(AppCurrency currency) {
    _primaryCurrency = currency;
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month, 1);
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    notifyListeners();
  }

  void setFilterType(FilterType type) {
    _filterType = type;
    notifyListeners();
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  TransactionCategory addCustomCategory({
    required String name,
    IconData icon = Icons.label_rounded,
    Color color = const Color(0xFF3B82F6),
  }) {
    final created = repository.addCustomCategory(
      name: name,
      icon: icon,
      color: color,
    );
    notifyListeners();
    return created;
  }

  void deleteCustomCategory(String categoryId) {
    repository.deleteCustomCategory(categoryId);
    if (_selectedCategoryId == categoryId) {
      _selectedCategoryId = null;
    }
    notifyListeners();
  }

  /// All transactions occurring within the currently selected month
  List<TransactionItem> get currentMonthTransactions {
    return repository.getTransactions().where((t) {
      return t.date.year == _selectedMonth.year &&
          t.date.month == _selectedMonth.month;
    }).toList();
  }

  /// Transactions filtered by month, filterType, and selected category
  List<TransactionItem> get filteredTransactions {
    return currentMonthTransactions.where((t) {
      if (_filterType == FilterType.expenses &&
          t.type != TransactionType.expense) {
        return false;
      }
      if (_filterType == FilterType.income &&
          t.type != TransactionType.income) {
        return false;
      }
      if (_selectedCategoryId != null) {
        if (t.type == TransactionType.income ||
            t.category?.id != _selectedCategoryId) {
          return false;
        }
      }
      return true;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Computed monthly analytics via the Domain Use Case
  MonthlyAnalytics get currentMonthAnalytics =>
      calculateAnalyticsUseCase.execute(
        monthTransactions: currentMonthTransactions,
        primaryCurrency: _primaryCurrency,
      );

  /// Total Monthly Income in primary currency
  double get monthlyIncome => currentMonthAnalytics.totalIncome;

  /// Total Monthly Expense in primary currency
  double get monthlyExpense => currentMonthAnalytics.totalExpense;

  /// Net balance for the month (Income - Expense)
  double get monthlyNetBalance => currentMonthAnalytics.netBalance;

  /// Savings rate as a percentage
  double get monthlySavingsRate => currentMonthAnalytics.savingsRate;

  /// Categorized breakdown of expenses for the selected month
  List<CategorySpending> get categorySpendingBreakdown =>
      currentMonthAnalytics.categoryBreakdown;

  /// Top spending category this month
  CategorySpending? get topSpendingCategory =>
      currentMonthAnalytics.topSpendingCategory;

  // ================= CRUD Operations =================

  void addTransaction(TransactionItem transaction) {
    repository.addTransaction(transaction);
    notifyListeners();
  }

  /// Deletes a transaction and saves it for Undo
  TransactionItem? deleteTransaction(String id) {
    final transactions = repository.getTransactions();
    final index = transactions.indexWhere((t) => t.id == id);
    if (index == -1) return null;

    final removed = repository.deleteTransaction(id);
    if (removed != null) {
      _lastDeleted = DeletedTransactionSnapshot(
        item: removed,
        originalIndex: index,
      );
      notifyListeners();
    }
    return removed;
  }

  /// Undoes the last deletion
  bool undoDelete() {
    if (_lastDeleted == null) return false;

    final item = _lastDeleted!.item;
    final targetIndex = min(
      _lastDeleted!.originalIndex,
      repository.getTransactions().length,
    );
    repository.insertTransactionAt(targetIndex, item);
    _lastDeleted = null;
    notifyListeners();
    return true;
  }

  void clearUndo() {
    _lastDeleted = null;
  }
}
