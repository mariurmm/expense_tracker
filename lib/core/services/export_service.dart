import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/transaction_model.dart';

class ExportService {
  /// Exports [transactions] to a UTF-8 CSV file and returns the [File].
  ///
  /// The file is written to the app's documents directory so it can be
  /// picked up by [share_plus] and shared to any target.
  Future<File> exportTransactionsToCSV(
    List<Transaction> transactions,
    String currencySymbol,
  ) async {
    // ── Header row ─────────────────────────────────────────────────────────
    final List<List<dynamic>> rows = [
      ['Дата', 'Тип', 'Категория', 'Сумма', 'Валюта', 'Заметка'],
    ];

    // ── Data rows ──────────────────────────────────────────────────────────
    for (final t in transactions) {
      rows.add([
        DateFormat('dd.MM.yyyy').format(t.date),
        t.type == TransactionType.income ? 'Доход' : 'Расход',
        t.category,
        t.amount.toStringAsFixed(2),
        currencySymbol,
        t.note ?? '',
      ]);
    }

    // ── Summary rows ───────────────────────────────────────────────────────
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    rows.addAll([
      [],
      [
        'Итого доходов',
        '',
        '',
        totalIncome.toStringAsFixed(2),
        currencySymbol,
        ''
      ],
      [
        'Итого расходов',
        '',
        '',
        totalExpense.toStringAsFixed(2),
        currencySymbol,
        ''
      ],
      [
        'Баланс',
        '',
        '',
        (totalIncome - totalExpense).toStringAsFixed(2),
        currencySymbol,
        ''
      ],
    ]);

    // ── Write to file ──────────────────────────────────────────────────────
    final String csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final String fileName =
        'finance_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
    final File file = File('${directory.path}/$fileName');
    await file.writeAsString(csv, encoding: utf8);
    return file;
  }
}
