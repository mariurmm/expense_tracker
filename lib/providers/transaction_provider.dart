import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';

import '../core/enums/period_filter.dart';
import '../core/services/exchange_rate_service.dart';
import '../core/utils/exchange_rates.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_repository.dart';
import '../providers/settings_provider.dart';
import 'reports_provider.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider(this._repository);

  final TransactionRepository _repository;
  ReportsProvider? _reportsProvider;
  ExchangeRateService? _exchangeRateService;
  SettingsProvider? _settingsProvider;

  ReportsProvider? get reportsProvider => _reportsProvider;
  set reportsProvider(ReportsProvider value) => _reportsProvider = value;

  ExchangeRateService? get exchangeRateService => _exchangeRateService;
  set exchangeRateService(ExchangeRateService svc) =>
      _exchangeRateService = svc;

  SettingsProvider? get settingsProvider => _settingsProvider;
  set settingsProvider(SettingsProvider p) => _settingsProvider = p;

  String get _activeCurrency => _settingsProvider?.currencyCode ?? 'KZT';

  // ── Data ──────────────────────────────────────────────────────────────────

  List<Transaction> _allTransactions = [];
  List<Transaction> _monthTransactions = [];
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedWeekStart = _currentWeekStart();
  int _selectedYear = DateTime.now().year;
  PeriodFilter _periodFilter = PeriodFilter.month;

  // ── Cached converted totals (updated async) ───────────────────────────────

  double _convertedBalance = 0;
  double _convertedIncome = 0;
  double _convertedExpense = 0;
  bool _ratesLoading = false;

  bool get ratesLoading => _ratesLoading;
  double get totalBalance => _convertedBalance;
  double get totalIncome => _convertedIncome;
  double get totalExpense => _convertedExpense;

  // ── Public read-only lists ────────────────────────────────────────────────

  List<Transaction> get allTransactions =>
      List.unmodifiable(_allTransactions);
  List<Transaction> get monthTransactions =>
      List.unmodifiable(_monthTransactions);
  DateTime get selectedMonth => _selectedMonth;
  DateTime get selectedWeekStart => _selectedWeekStart;
  int get selectedYear => _selectedYear;
  PeriodFilter get periodFilter => _periodFilter;

  static DateTime _currentWeekStart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  List<Transaction> get recentTransactions =>
      _allTransactions.take(5).toList();

  /// Net balance per original currency (sync, no conversion needed).
  Map<String, double> get balancePerCurrency {
    final map = <String, double>{};
    for (final t in _allTransactions) {
      final delta =
          t.type == TransactionType.income ? t.amount : -t.amount;
      map[t.currencyCode] = (map[t.currencyCode] ?? 0) + delta;
    }
    map.removeWhere((_, v) => v.abs() < 0.001);
    return map;
  }

  List<Transaction> get filteredTransactions {
    switch (_periodFilter) {
      case PeriodFilter.week:
        final weekEnd = _selectedWeekStart.add(const Duration(days: 6));
        final endOfDay =
            DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);
        return _allTransactions
            .where((t) =>
                !t.date.isBefore(_selectedWeekStart) &&
                !t.date.isAfter(endOfDay))
            .toList();
      case PeriodFilter.month:
        return _monthTransactions;
      case PeriodFilter.year:
        return _allTransactions
            .where((t) => t.date.year == _selectedYear)
            .toList();
    }
  }

  // ── Async rate recalculation ──────────────────────────────────────────────

  Future<void> recalculateConvertedTotals() async {
    _ratesLoading = true;
    notifyListeners();

    final target = _activeCurrency;
    final svc = _exchangeRateService;

    // Preload rates for every currency present in transactions.
    if (svc != null) {
      final codes = _allTransactions.map((t) => t.currencyCode).toSet();
      for (final code in codes) {
        await svc.preload(code);
      }
    }

    double allIncome = 0;
    double allExpense = 0;

    for (final t in _allTransactions) {
      final converted = svc != null
          ? await svc.convert(t.amount, t.currencyCode, target)
          : convertCurrencySync(t.amount, t.currencyCode, target);
      if (t.type == TransactionType.income) {
        allIncome += converted;
      } else {
        allExpense += converted;
      }
    }

    double monthIncome = 0;
    double monthExpense = 0;

    for (final t in _monthTransactions) {
      final converted = svc != null
          ? await svc.convert(t.amount, t.currencyCode, target)
          : convertCurrencySync(t.amount, t.currencyCode, target);
      if (t.type == TransactionType.income) {
        monthIncome += converted;
      } else {
        monthExpense += converted;
      }
    }

    _convertedBalance = allIncome - allExpense;
    _convertedIncome = monthIncome;
    _convertedExpense = monthExpense;
    _ratesLoading = false;
    notifyListeners();
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  void loadTransactions() {
    _allTransactions = _repository.getAllTransactions();
    _monthTransactions = _repository.getTransactionsByMonth(
      _selectedMonth.month,
      _selectedMonth.year,
    );
    unawaited(recalculateConvertedTotals());
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _repository.addTransaction(transaction);
    loadTransactions();
    _reportsProvider?.load();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _repository.updateTransaction(transaction);
    loadTransactions();
    _reportsProvider?.load();
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    loadTransactions();
    _reportsProvider?.load();
  }

  // ── Period filter ─────────────────────────────────────────────────────────

  void setPeriodFilter(PeriodFilter filter) {
    if (_periodFilter == filter) return;
    _periodFilter = filter;
    if (filter == PeriodFilter.week) {
      _selectedWeekStart = _currentWeekStart();
    } else if (filter == PeriodFilter.year) {
      _selectedYear = DateTime.now().year;
    }
    notifyListeners();
  }

  void previousWeek() {
    _selectedWeekStart =
        _selectedWeekStart.subtract(const Duration(days: 7));
    notifyListeners();
  }

  void nextWeek() {
    _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
    notifyListeners();
  }

  void previousYear() {
    _selectedYear -= 1;
    notifyListeners();
  }

  void nextYear() {
    _selectedYear += 1;
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    _monthTransactions = _repository.getTransactionsByMonth(
      _selectedMonth.month,
      _selectedMonth.year,
    );
    unawaited(recalculateConvertedTotals());
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    _monthTransactions = _repository.getTransactionsByMonth(
      _selectedMonth.month,
      _selectedMonth.year,
    );
    unawaited(recalculateConvertedTotals());
    notifyListeners();
  }
}
