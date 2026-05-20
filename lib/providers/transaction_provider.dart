import 'package:flutter/foundation.dart';
import '../core/enums/period_filter.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_repository.dart';
import 'reports_provider.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider(this._repository);

  final TransactionRepository _repository;
  ReportsProvider? _reportsProvider;

  ReportsProvider? get reportsProvider => _reportsProvider;
  set reportsProvider(ReportsProvider value) => _reportsProvider = value;

  List<Transaction> _allTransactions = [];
  List<Transaction> _monthTransactions = [];
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedWeekStart = _currentWeekStart();
  int _selectedYear = DateTime.now().year;
  PeriodFilter _periodFilter = PeriodFilter.month;

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

  /// Last 5 transactions across all time, newest first.
  List<Transaction> get recentTransactions =>
      _allTransactions.take(5).toList();

  /// All-time balance.
  double get totalBalance {
    final income = _allTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (s, t) => s + t.amount);
    final expense = _allTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (s, t) => s + t.amount);
    return income - expense;
  }

  /// Income for the currently selected month (used on HomeScreen).
  double get totalIncome => _monthTransactions
      .where((t) => t.type == TransactionType.income)
      .fold<double>(0, (s, t) => s + t.amount);

  /// Expense for the currently selected month (used on HomeScreen).
  double get totalExpense => _monthTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold<double>(0, (s, t) => s + t.amount);

  /// Transactions filtered by [_periodFilter] — used in TransactionsScreen.
  List<Transaction> get filteredTransactions {
    switch (_periodFilter) {
      case PeriodFilter.week:
        final weekEnd = _selectedWeekStart.add(const Duration(days: 6));
        final endOfDay = DateTime(
            weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);
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

  void loadTransactions() {
    _allTransactions = _repository.getAllTransactions();
    _monthTransactions = _repository.getTransactionsByMonth(
      _selectedMonth.month,
      _selectedMonth.year,
    );
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _repository.addTransaction(transaction);
    loadTransactions();
    _reportsProvider?.load();
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    loadTransactions();
    _reportsProvider?.load();
  }

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
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    _monthTransactions = _repository.getTransactionsByMonth(
      _selectedMonth.month,
      _selectedMonth.year,
    );
    notifyListeners();
  }
}
