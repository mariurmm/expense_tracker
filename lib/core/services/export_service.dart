import 'dart:io';

import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/transaction_model.dart';
import '../../data/repositories/category_repository.dart';
import '../utils/category_name_resolver.dart';

@lazySingleton
class ExportService {
  const ExportService(this._categoryRepo);

  final CategoryRepository _categoryRepo;

  Future<File> exportTransactionsToCSV(
    List<Transaction> transactions,
    String currencySymbol,
    AppLocalizations l10n,
  ) async {
    final rows = <List<dynamic>>[
      [
        l10n.csvHeaderDate,
        l10n.csvHeaderType,
        l10n.csvHeaderCategory,
        l10n.csvHeaderAmount,
        l10n.csvHeaderCurrency,
        l10n.csvHeaderNote,
      ],
    ];

    for (final t in transactions) {
      rows.add([
        DateFormat('dd.MM.yyyy').format(t.date),
        if (t.type == TransactionType.income) l10n.csvTypeIncome else l10n.csvTypeExpense,
        _resolveCategory(t.category, l10n),
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
      [l10n.csvTotalIncome, '', '', totalIncome.toStringAsFixed(2), currencySymbol, ''],
      [l10n.csvTotalExpense, '', '', totalExpense.toStringAsFixed(2), currencySymbol, ''],
      [l10n.csvBalance, '', '', (totalIncome - totalExpense).toStringAsFixed(2), currencySymbol, ''],
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
        '${l10n.csvExportFileName}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
    final file = File('${directory.path}/$fileName');
    // UTF-8 BOM prefix so Excel on Windows renders Cyrillic correctly.
    await file.writeAsString('﻿$csv');
    return file;
  }

  String _resolveCategory(String categoryId, AppLocalizations l10n) {
    final categories = _categoryRepo.getAllCategories();
    final cat = categories.where((c) => c.id == categoryId || c.name == categoryId).firstOrNull
        ?? categories.where((c) => c.name.toLowerCase() == categoryId.toLowerCase()).firstOrNull;
    if (cat == null) return categoryId;
    return resolveCategoryNameByKey(cat.nameKey, cat.name, l10n);
  }
}
