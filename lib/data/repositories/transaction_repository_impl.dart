import 'package:flutter/material.dart';
import 'package:financials/domain/models/transaction_item.dart';
import 'package:financials/domain/repositories/transaction_repository.dart';
import 'package:financials/data/services/transaction_local_service.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalService localService;

  TransactionRepositoryImpl({required this.localService});

  @override
  List<TransactionItem> getTransactions() {
    return localService.getAllTransactions();
  }

  @override
  void addTransaction(TransactionItem transaction) {
    localService.addTransaction(transaction);
  }

  @override
  TransactionItem? deleteTransaction(String id) {
    return localService.removeTransaction(id);
  }

  @override
  void insertTransactionAt(int index, TransactionItem transaction) {
    localService.insertTransaction(index, transaction);
  }

  @override
  List<TransactionCategory> getCustomCategories() {
    return localService.getCustomCategories();
  }

  @override
  TransactionCategory addCustomCategory({
    required String name,
    required IconData icon,
    required Color color,
  }) {
    return localService.createCustomCategory(
      name: name,
      icon: icon,
      color: color,
    );
  }

  @override
  void deleteCustomCategory(String categoryId) {
    localService.removeCustomCategory(categoryId);
  }
}

