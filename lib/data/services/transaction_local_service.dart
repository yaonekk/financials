import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_storage_model.dart';
import '../models/transaction_storage_model.dart';

/// Data layer service wrapping local device storage ([SharedPreferences]).
/// Operates exclusively on Data Layer DTOs ([TransactionStorageModel] and
/// [CategoryStorageModel]). Starts with an empty state on first launch.
class TransactionLocalService {
  static const String _transactionsKey = 'transactions_v1';
  static const String _customCategoriesKey = 'custom_categories_v1';

  final SharedPreferences _prefs;
  final List<TransactionStorageModel> _transactions = [];
  final List<CategoryStorageModel> _customCategories = [];

  TransactionLocalService._(this._prefs) {
    _loadFromStorage();
  }

  /// Factory async initializer — must be called before use.
  static Future<TransactionLocalService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TransactionLocalService._(prefs);
  }

  // ─── Read ────────────────────────────────────────────────────────────────

  List<TransactionStorageModel> getAllTransactionRecords() {
    return List.unmodifiable(_transactions);
  }

  List<CategoryStorageModel> getCustomCategoryRecords() {
    return List.unmodifiable(_customCategories);
  }

  // ─── Write ───────────────────────────────────────────────────────────────

  void addTransactionRecord(TransactionStorageModel record) {
    _transactions.insert(0, record);
    _saveTransactions();
  }

  void insertTransactionRecord(int index, TransactionStorageModel record) {
    if (index >= 0 && index <= _transactions.length) {
      _transactions.insert(index, record);
    } else {
      _transactions.add(record);
    }
    _saveTransactions();
  }

  TransactionStorageModel? removeTransactionRecord(String id) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return null;
    final removed = _transactions.removeAt(index);
    _saveTransactions();
    return removed;
  }

  void addCustomCategoryRecord(CategoryStorageModel record) {
    _customCategories.add(record);
    _saveCustomCategories();
  }

  void removeCustomCategoryRecord(
    String categoryId, {
    required String fallbackCategoryId,
  }) {
    _customCategories.removeWhere((c) => c.id == categoryId);
    for (int i = 0; i < _transactions.length; i++) {
      final current = _transactions[i];
      if (current.categoryId == categoryId) {
        _transactions[i] = TransactionStorageModel(
          id: current.id,
          title: current.title,
          amount: current.amount,
          type: current.type,
          categoryId: fallbackCategoryId,
          currencyCode: current.currencyCode,
          dateMs: current.dateMs,
          note: current.note,
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
        if (item is Map<String, dynamic>) {
          _customCategories.add(CategoryStorageModel.fromJson(item));
        }
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
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          _transactions.add(TransactionStorageModel.fromJson(item));
        }
      }
    } catch (_) {
      // Corrupt data — start fresh
    }
  }

  void _saveTransactions() {
    final list = _transactions.map((t) => t.toJson()).toList();
    _prefs.setString(_transactionsKey, jsonEncode(list));
  }

  void _saveCustomCategories() {
    final list = _customCategories.map((c) => c.toJson()).toList();
    _prefs.setString(_customCategoriesKey, jsonEncode(list));
  }
}
