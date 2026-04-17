import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,
}

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final TransactionType type;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? note;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });
}
