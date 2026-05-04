import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../core/enums/period_filter.dart';
import '../data/models/category_model.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/transaction_repository.dart';

// ---------------------------------------------------------------------------
// Data class for pie chart slices (no Widget code)
// ---------------------------------------------------------------------------

class PieSliceData {
  const PieSliceData({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  final String categoryName;
  final double amount;
  final double percentage;
  final Color color;
}

// ---------------------------------------------------------------------------
// ReportsProvider
// ---------------------------------------------------------------------------

class ReportsProvider extends ChangeNotifier {
  ReportsProvider(this._txRepo, this._catRepo);

  final TransactionRepository _txRepo;
  final CategoryRepository _catRepo;

  PeriodFilter _periodFilter = PeriodFilter.month;
  List<Transaction> _allTransactions = [];
  List<Category> _categories = [];

  List<PieSliceData> _pieSlices = [];
  List<BarChartGroupData> _barGroups = [];
  List<String> _barLabels = [];
  double _totalExpense = 0;
  double _maxBarValue = 0;

  // ---- public getters ----

  PeriodFilter get periodFilter => _periodFilter;
  List<PieSliceData> get pieSlices => List.unmodifiable(_pieSlices);
  List<BarChartGroupData> get barGroups => List.unmodifiable(_barGroups);
  List<String> get barLabels => List.unmodifiable(_barLabels);
  double get totalExpense => _totalExpense;
  bool get hasExpenses => _pieSlices.isNotEmpty;

  /// Upper bound for the bar chart Y axis (with 25 % head-room).
  double get maxY => _maxBarValue > 0 ? _maxBarValue * 1.25 : 1000;

  // ---- public methods ----

  void load() {
    _allTransactions = _txRepo.getAllTransactions();
    _categories = _catRepo.getAllCategories();
    _recompute();
    notifyListeners();
  }

  void setPeriodFilter(PeriodFilter filter) {
    if (_periodFilter == filter) return;
    _periodFilter = filter;
    _recompute();
    notifyListeners();
  }

  // ---- private helpers ----

  void _recompute() {
    final filtered = _filterTransactions();
    _totalExpense = filtered
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (s, t) => s + t.amount);
    _pieSlices = _buildPieSlices(filtered);
    _barLabels = _buildBarLabels();
    _barGroups = _buildBarGroups(filtered);
    _maxBarValue = _barGroups.isEmpty
        ? 0
        : _barGroups
            .expand((g) => g.barRods)
            .map((r) => r.toY)
            .fold<double>(0, (m, v) => v > m ? v : m);
  }

  List<Transaction> _filterTransactions() {
    final now = DateTime.now();
    switch (_periodFilter) {
      case PeriodFilter.week:
        final start = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 6));
        return _allTransactions.where((t) {
          final d = DateTime(t.date.year, t.date.month, t.date.day);
          return !d.isBefore(start);
        }).toList();
      case PeriodFilter.month:
        return _allTransactions
            .where((t) =>
                t.date.year == now.year && t.date.month == now.month)
            .toList();
      case PeriodFilter.year:
        return _allTransactions
            .where((t) => t.date.year == now.year)
            .toList();
    }
  }

  // ---- pie chart ----

  List<PieSliceData> _buildPieSlices(List<Transaction> txns) {
    final totals = <String, double>{};
    for (final t in txns.where((t) => t.type == TransactionType.expense)) {
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }
    if (totals.isEmpty) return [];

    final total = totals.values.fold<double>(0, (s, v) => s + v);

    return totals.entries.map((e) {
      final cat = _categories.firstWhere(
        (c) => c.name == e.key,
        orElse: () => Category(
          id: '',
          name: e.key,
          icon: Icons.category.codePoint,
          color: 0xFF78909C,
          isCustom: false,
        ),
      );
      return PieSliceData(
        categoryName: e.key,
        amount: e.value,
        percentage: e.value / total * 100,
        color: Color(cat.color),
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  // ---- bar chart labels ----

  List<String> _buildBarLabels() {
    final now = DateTime.now();
    switch (_periodFilter) {
      case PeriodFilter.week:
        return List.generate(7, (i) {
          final day = now.subtract(Duration(days: 6 - i));
          return DateFormat('E').format(day).substring(0, 2);
        });
      case PeriodFilter.month:
        return List.generate(
          _weeksInMonth(now.year, now.month),
          (i) => 'W${i + 1}',
        );
      case PeriodFilter.year:
        return List.generate(
          12,
          (i) => DateFormat('MMM').format(DateTime(2024, i + 1)),
        );
    }
  }

  // ---- bar chart groups ----

  List<BarChartGroupData> _buildBarGroups(List<Transaction> txns) {
    final now = DateTime.now();
    switch (_periodFilter) {
      case PeriodFilter.week:
        return _buildWeekBars(txns, now);
      case PeriodFilter.month:
        return _buildMonthBars(txns, now);
      case PeriodFilter.year:
        return _buildYearBars(txns, now);
    }
  }

  List<BarChartGroupData> _buildWeekBars(
      List<Transaction> txns, DateTime now) {
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      final day7 = txns.where(
          (t) => !t.date.isBefore(start) && t.date.isBefore(end));
      return _makeGroup(i, day7.toList(), wide: true);
    });
  }

  List<BarChartGroupData> _buildMonthBars(
      List<Transaction> txns, DateTime now) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final weeks = _weeksInMonth(now.year, now.month);
    return List.generate(weeks, (wi) {
      final dayFrom = wi * 7 + 1;
      final dayTo = ((wi + 1) * 7).clamp(1, daysInMonth);
      final daysInChunk = dayTo - dayFrom + 1;
      final week = txns.where((t) =>
          t.date.year == now.year &&
          t.date.month == now.month &&
          t.date.day >= dayFrom &&
          t.date.day <= dayTo);
      return _makeGroup(wi, week.toList(), wide: true,
          normalize: daysInChunk);
    });
  }

  List<BarChartGroupData> _buildYearBars(
      List<Transaction> txns, DateTime now) {
    return List.generate(12, (mi) {
      final month = mi + 1;
      final monthTxns = txns.where(
          (t) => t.date.year == now.year && t.date.month == month);
      return _makeGroup(mi, monthTxns.toList(), wide: false);
    });
  }

  BarChartGroupData _makeGroup(int x, List<Transaction> txns,
      {required bool wide, int normalize = 1}) {
    final divisor = normalize.toDouble();
    final income = txns
            .where((t) => t.type == TransactionType.income)
            .fold<double>(0, (s, t) => s + t.amount) /
        divisor;
    final expense = txns
            .where((t) => t.type == TransactionType.expense)
            .fold<double>(0, (s, t) => s + t.amount) /
        divisor;
    final w = wide ? 10.0 : 7.0;
    return BarChartGroupData(
      x: x,
      barsSpace: 3,
      barRods: [
        BarChartRodData(
          toY: income,
          color: AppColors.income,
          width: w,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: expense,
          color: AppColors.expense,
          width: w,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  int _weeksInMonth(int year, int month) {
    final days = DateTime(year, month + 1, 0).day; // last day of month
    return (days / 7).ceil();
  }
}
