import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:injectable/injectable.dart';

import '../models/transaction_model.dart';

@lazySingleton
class TransactionLocalDatasource {
  static const String boxName = 'transactions';

  Box<Transaction> get _box => Hive.box<Transaction>(boxName);

  Future<void> put(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  List<Transaction> getAll() => _box.values.toList();
}
