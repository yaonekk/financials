import 'package:flutter/material.dart';
import 'currency.dart';

enum TransactionType {
  expense,
  income;

  String get label => this == TransactionType.expense ? 'Expense' : 'Income';
}

class TransactionCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isCustom;

  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isCustom = false,
  });

  static const List<TransactionCategory> defaultExpenseCategories = [
    TransactionCategory(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFF97316),
    ),
    TransactionCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFEC4899),
    ),
    TransactionCategory(
      id: 'housing',
      name: 'Housing & Rent',
      icon: Icons.home_rounded,
      color: Color(0xFF8B5CF6),
    ),
    TransactionCategory(
      id: 'transport',
      name: 'Transportation',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF3B82F6),
    ),
    TransactionCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_creation_rounded,
      color: Color(0xFF06B6D4),
    ),
    TransactionCategory(
      id: 'bills',
      name: 'Bills & Utilities',
      icon: Icons.bolt_rounded,
      color: Color(0xFFEAB308),
    ),
    TransactionCategory(
      id: 'health',
      name: 'Health & Medical',
      icon: Icons.favorite_rounded,
      color: Color(0xFF10B981),
    ),
    TransactionCategory(
      id: 'travel',
      name: 'Travel & Trips',
      icon: Icons.flight_rounded,
      color: Color(0xFF6366F1),
    ),
    TransactionCategory(
      id: 'other_expense',
      name: 'Other Expense',
      icon: Icons.category_rounded,
      color: Color(0xFF64748B),
    ),
  ];

  static TransactionCategory findById(String id, [List<TransactionCategory>? customCategories]) {
    final combined = [
      ...defaultExpenseCategories,
      ...?customCategories,
    ];
    return combined.firstWhere(
      (c) => c.id == id,
      orElse: () => defaultExpenseCategories.last,
    );
  }
}

class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  /// Category is only applicable to expenses; null for income
  final TransactionCategory? category;
  final AppCurrency currency;
  final DateTime date;
  final String? note;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.category,
    required this.currency,
    required this.date,
    this.note,
  });

  /// Normalized value in USD for cross-currency totals
  double get amountInUsd => amount * currency.rateToUsd;

  String get formattedAmount {
    return '${currency.symbol}${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
  }

  TransactionItem copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    AppCurrency? currency,
    DateTime? date,
    String? note,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}

