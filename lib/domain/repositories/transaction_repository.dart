import 'package:flutter/material.dart';
import '../models/transaction_item.dart';

abstract class TransactionRepository {
  List<TransactionItem> getTransactions();
  void addTransaction(TransactionItem transaction);
  TransactionItem? deleteTransaction(String id);
  void insertTransactionAt(int index, TransactionItem transaction);

  List<TransactionCategory> getCustomCategories();
  TransactionCategory addCustomCategory({
    required String name,
    required IconData icon,
    required Color color,
  });
  void deleteCustomCategory(String categoryId);
}

