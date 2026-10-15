import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../domain/models/currency.dart';
import '../../../../domain/models/spending_analytics.dart';
import '../../../../domain/models/transaction_item.dart';
import '../../../../domain/repositories/transaction_repository.dart';

enum FilterType { all, expenses, income }

class ExpenseTrackerViewModel extends ChangeNotifier {
  final TransactionRepository repository;

  // Selected view month
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  // Primary display currency for totals & statistics
  AppCurrency _primaryCurrency = AppCurrency.supportedCurrencies.first;

  // Filter criteria
  FilterType _filterType = FilterType.all;
  String? _selectedCategoryId;

  // Undo delete mechanism
  DeletedTransactionSnapshot? _lastDeleted;

  ExpenseTrackerViewModel({required this.repository});

  // Getters
  DateTime get selectedMonth => _selectedMonth;
  AppCurrency get primaryCurrency => _primaryCurrency;
  FilterType get filterType => _filterType;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get hasUndoAvailable => _lastDeleted != null;

  List<TransactionCategory> get customCategories => repository.getCustomCategories();

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
      return t.date.year == _selectedMonth.year && t.date.month == _selectedMonth.month;
    }).toList();
  }

  /// Transactions filtered by month, filterType, and selected category
  List<TransactionItem> get filteredTransactions {
    return currentMonthTransactions.where((t) {
      if (_filterType == FilterType.expenses && t.type != TransactionType.expense) {
        return false;
      }
      if (_filterType == FilterType.income && t.type != TransactionType.income) {
        return false;
      }
      if (_selectedCategoryId != null) {
        if (t.type == TransactionType.income || t.category?.id != _selectedCategoryId) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Total Monthly Income in primary currency
  double get monthlyIncome {
    final incomes = currentMonthTransactions.where((t) => t.type == TransactionType.income);
    double totalUsd = 0.0;
    for (final t in incomes) {
      totalUsd += t.amountInUsd;
    }
    return totalUsd / _primaryCurrency.rateToUsd;
  }

  /// Total Monthly Expense in primary currency
  double get monthlyExpense {
    final expenses = currentMonthTransactions.where((t) => t.type == TransactionType.expense);
    double totalUsd = 0.0;
    for (final t in expenses) {
      totalUsd += t.amountInUsd;
    }
    return totalUsd / _primaryCurrency.rateToUsd;
  }

  /// Net balance for the month (Income - Expense)
  double get monthlyNetBalance => monthlyIncome - monthlyExpense;

  /// Savings rate as a percentage
  double get monthlySavingsRate {
    if (monthlyIncome <= 0) return 0.0;
    final rate = (monthlyNetBalance / monthlyIncome) * 100;
    return rate.clamp(-100.0, 100.0);
  }

  /// Categorized breakdown of expenses for the selected month
  List<CategorySpending> get categorySpendingBreakdown {
    final expenses = currentMonthTransactions.where((t) => t.type == TransactionType.expense);
    if (expenses.isEmpty) return [];

    final Map<String, List<TransactionItem>> grouped = {};
    for (final exp in expenses) {
      final catId = exp.category?.id ?? 'other_expense';
      grouped.putIfAbsent(catId, () => []).add(exp);
    }

    final totalExpUsd = expenses.fold<double>(0.0, (sum, t) => sum + t.amountInUsd);

    final List<CategorySpending> result = [];
    grouped.forEach((catId, items) {
      final category = items.first.category ?? TransactionCategory.defaultExpenseCategories.last;
      final catUsd = items.fold<double>(0.0, (sum, t) => sum + t.amountInUsd);
      final catConverted = catUsd / _primaryCurrency.rateToUsd;
      final percentage = totalExpUsd > 0 ? (catUsd / totalExpUsd) * 100 : 0.0;

      result.add(CategorySpending(
        category: category,
        totalAmount: catConverted,
        percentage: percentage,
        count: items.length,
      ));
    });

    result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return result;
  }

  /// Top spending category this month (answers: "what did he spend the most money on this month?")
  CategorySpending? get topSpendingCategory {
    final breakdown = categorySpendingBreakdown;
    if (breakdown.isEmpty) return null;
    return breakdown.first;
  }

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
    final targetIndex = min(_lastDeleted!.originalIndex, repository.getTransactions().length);
    repository.insertTransactionAt(targetIndex, item);
    _lastDeleted = null;
    notifyListeners();
    return true;
  }

  void clearUndo() {
    _lastDeleted = null;
  }
}
