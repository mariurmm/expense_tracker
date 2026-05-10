import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/transaction_model.dart';

@lazySingleton
class ExportService {
  const ExportService();

  Future<File> exportTransactionsToCSV(
    List<Transaction> transactions,
    String currencySymbol,
  ) async {
    final rows = <List<dynamic>>[
      ['Дата', 'Тип', 'Категория', 'Сумма', 'Валюта', 'Заметка'],
    ];

    for (final t in transactions) {
      rows.add([
        DateFormat('dd.MM.yyyy').format(t.date),
        if (t.type == TransactionType.income) 'Доход' else 'Расход',
        t.category,
        t.amount.toStringAsFixed(2),
        currencySymbol,
        t.note ?? '',
      ]);
    }

    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    rows.addAll([
      [],
      ['Итого доходов', '', '', totalIncome.toStringAsFixed(2), currencySymbol, ''],
      ['Итого расходов', '', '', totalExpense.toStringAsFixed(2), currencySymbol, ''],
      ['Баланс', '', '', (totalIncome - totalExpense).toStringAsFixed(2), currencySymbol, ''],
    ]);

    final csv = rows
        .map(
          (row) => row
              .map((cell) => '"${cell.toString().replaceAll('"', '""')}"')
              .join(','),
        )
        .join('\n');

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'finance_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
    final file = File('${directory.path}/$fileName');
    // UTF-8 BOM prefix so Excel on Windows renders Cyrillic correctly.
    await file.writeAsString('﻿$csv');
    return file;
  }
}
