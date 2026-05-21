import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  income,

  @HiveField(1)
  expense,
}

@freezed
@HiveType(typeId: 0)
abstract class Transaction with _$Transaction {
  const factory Transaction({
    @HiveField(0) required String id,
    @HiveField(1) required double amount,
    @HiveField(2) required TransactionType type,
    @HiveField(3) required String category,
    @HiveField(4) required DateTime date,
    @HiveField(5) String? note,
    @HiveField(6) @Default('KZT') String currencyCode,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
