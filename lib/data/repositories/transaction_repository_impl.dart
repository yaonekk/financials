import 'package:flutter/material.dart';
import '../../domain/models/transaction_item.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/category_storage_model.dart';
import '../models/transaction_storage_model.dart';
import '../services/transaction_local_service.dart';

/// Concrete implementation of [TransactionRepository] that maps between
/// Data layer storage DTOs and Domain layer models.
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalService localService;

  TransactionRepositoryImpl({required this.localService});

  List<TransactionCategory> _allAvailableCategories() {
    return [
      ...TransactionCategory.defaultExpenseCategories,
      ...getCustomCategories(),
    ];
  }

  @override
  List<TransactionItem> getTransactions() {
    final categories = _allAvailableCategories();
    return localService
        .getAllTransactionRecords()
        .map((dto) => dto.toDomain(categories))
        .toList();
  }

  @override
  void addTransaction(TransactionItem transaction) {
    final dto = TransactionStorageModel.fromDomain(transaction);
    localService.addTransactionRecord(dto);
  }

  @override
  TransactionItem? deleteTransaction(String id) {
    final categories = _allAvailableCategories();
    final removedDto = localService.removeTransactionRecord(id);
    return removedDto?.toDomain(categories);
  }

  @override
  void insertTransactionAt(int index, TransactionItem transaction) {
    final dto = TransactionStorageModel.fromDomain(transaction);
    localService.insertTransactionRecord(index, dto);
  }

  @override
  List<TransactionCategory> getCustomCategories() {
    return localService
        .getCustomCategoryRecords()
        .map((dto) => dto.toDomain())
        .toList();
  }

  @override
  TransactionCategory addCustomCategory({
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
    final dto = CategoryStorageModel.fromDomain(newCategory);
    localService.addCustomCategoryRecord(dto);
    return newCategory;
  }

  @override
  void deleteCustomCategory(String categoryId) {
    final fallbackId = TransactionCategory.defaultExpenseCategories.last.id;
    localService.removeCustomCategoryRecord(
      categoryId,
      fallbackCategoryId: fallbackId,
    );
  }
}
