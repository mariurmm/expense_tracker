import 'package:injectable/injectable.dart';

import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

@lazySingleton
class TransactionRepository {
  const TransactionRepository({required TransactionLocalDatasource datasource})
      : _datasource = datasource;

  final TransactionLocalDatasource _datasource;

  Future<void> addTransaction(Transaction transaction) async {
    await _datasource.put(transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _datasource.put(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _datasource.delete(id);
  }

  List<Transaction> getAllTransactions() {
    return _datasource.getAll()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Transaction> getTransactionsByMonth(int month, int year) {
    return _datasource
        .getAll()
        .where((t) => t.date.month == month && t.date.year == year)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
