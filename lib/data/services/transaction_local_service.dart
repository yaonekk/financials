import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/currency.dart';
import '../../domain/models/transaction_item.dart';

/// Persists transactions and custom categories to device storage via SharedPreferences.
/// No seed data — starts fresh on first launch.
class TransactionLocalService {
  static const String _transactionsKey = 'transactions_v1';
  static const String _customCategoriesKey = 'custom_categories_v1';

  final SharedPreferences _prefs;
  final List<TransactionItem> _transactions = [];
  final List<TransactionCategory> _customCategories = [];

  TransactionLocalService._(this._prefs) {
    _loadFromStorage();
  }

  /// Factory async initializer — must be called before use.
  static Future<TransactionLocalService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TransactionLocalService._(prefs);
  }

  // ─── Read ────────────────────────────────────────────────────────────────

  List<TransactionItem> getAllTransactions() {
    return List.unmodifiable(_transactions);
  }

  List<TransactionCategory> getCustomCategories() {
    return List.unmodifiable(_customCategories);
  }

  // ─── Write ───────────────────────────────────────────────────────────────

  void addTransaction(TransactionItem transaction) {
    _transactions.insert(0, transaction);
    _saveTransactions();
  }

  void insertTransaction(int index, TransactionItem transaction) {
    if (index >= 0 && index <= _transactions.length) {
      _transactions.insert(index, transaction);
    } else {
      _transactions.add(transaction);
    }
    _saveTransactions();
  }

  TransactionItem? removeTransaction(String id) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return null;
    final removed = _transactions.removeAt(index);
    _saveTransactions();
    return removed;
  }

  TransactionCategory createCustomCategory({
    required String name,
    required IconData icon,
    required Color color,
  }) {
    final newCategory = TransactionCategory(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      icon: icon,
      color: color,
      isCustom: true,
    );
    _customCategories.add(newCategory);
    _saveCustomCategories();
    return newCategory;
  }

  void removeCustomCategory(String categoryId) {
    _customCategories.removeWhere((c) => c.id == categoryId);
    // Reassign transactions using this category to fallback
    for (int i = 0; i < _transactions.length; i++) {
      if (_transactions[i].category?.id == categoryId) {
        _transactions[i] = _transactions[i].copyWith(
          category: TransactionCategory.defaultExpenseCategories.last,
        );
      }
    }
    _saveCustomCategories();
    _saveTransactions();
  }

  // ─── Serialization ───────────────────────────────────────────────────────

  void _loadFromStorage() {
    _loadCustomCategories();
    _loadTransactions();
  }

  void _loadCustomCategories() {
    final raw = _prefs.getString(_customCategoriesKey);
    if (raw == null) return;
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        _customCategories.add(_categoryFromMap(map));
      }
    } catch (_) {
      // Corrupt data — start fresh
    }
  }

  void _loadTransactions() {
    final raw = _prefs.getString(_transactionsKey);
    if (raw == null) return;
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      final allCategories = [
        ...TransactionCategory.defaultExpenseCategories,
        ..._customCategories,
      ];
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        _transactions.add(_transactionFromMap(map, allCategories));
      }
    } catch (_) {
      // Corrupt data — start fresh
    }
  }

  void _saveTransactions() {
    final list = _transactions.map(_transactionToMap).toList();
    _prefs.setString(_transactionsKey, jsonEncode(list));
  }

  void _saveCustomCategories() {
    final list = _customCategories.map(_categoryToMap).toList();
    _prefs.setString(_customCategoriesKey, jsonEncode(list));
  }

  // ─── Map Helpers ─────────────────────────────────────────────────────────

  Map<String, dynamic> _transactionToMap(TransactionItem t) {
    return {
      'id': t.id,
      'title': t.title,
      'amount': t.amount,
      'type': t.type.name,
      'categoryId': t.category?.id,
      'currencyCode': t.currency.code,
      'dateMs': t.date.millisecondsSinceEpoch,
      'note': t.note,
    };
  }

  TransactionItem _transactionFromMap(
      Map<String, dynamic> map, List<TransactionCategory> categories) {
    final categoryId = map['categoryId'] as String?;
    final TransactionCategory? category = categoryId != null
        ? categories.firstWhere(
            (c) => c.id == categoryId,
            orElse: () => TransactionCategory.defaultExpenseCategories.last,
          )
        : null;

    return TransactionItem(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      category: category,
      currency: AppCurrency.fromCode(map['currencyCode'] as String),
      date: DateTime.fromMillisecondsSinceEpoch(map['dateMs'] as int),
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> _categoryToMap(TransactionCategory c) {
    return {
      'id': c.id,
      'name': c.name,
      'iconCodePoint': c.icon.codePoint,
      'iconFontFamily': c.icon.fontFamily,
      'colorValue': c.color.toARGB32(),
    };
  }

  static const List<IconData> _supportedCustomIcons = [
    Icons.label_rounded,
    Icons.local_cafe_rounded,
    Icons.sports_esports_rounded,
    Icons.school_rounded,
    Icons.pets_rounded,
    Icons.fitness_center_rounded,
    Icons.directions_bike_rounded,
    Icons.laptop_mac_rounded,
    Icons.music_note_rounded,
    Icons.local_gas_station_rounded,
    Icons.category_rounded,
  ];

  static IconData _resolveIcon(int codePoint) {
    for (final icon in _supportedCustomIcons) {
      if (icon.codePoint == codePoint) return icon;
    }
    return Icons.category_rounded;
  }

  TransactionCategory _categoryFromMap(Map<String, dynamic> map) {
    return TransactionCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: _resolveIcon(map['iconCodePoint'] as int? ?? 0),
      color: Color(map['colorValue'] as int),
      isCustom: true,
    );
  }
}
