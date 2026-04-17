import 'package:flutter/foundation.dart';
import '../core/enums/period_filter.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;

  TransactionProvider(this._repository);

  List<Transaction> _allTransactions = [];
  List<Transaction> _monthTransactions = [];
  DateTime _selectedMonth = DateTime.now();
  PeriodFilter _periodFilter = PeriodFilter.month;

  List<Transaction> get allTransactions =>
      List.unmodifiable(_allTransactions);
  List<Transaction> get monthTransactions =>
      List.unmodifiable(_monthTransactions);
  DateTime get selectedMonth => _selectedMonth;
  PeriodFilter get periodFilter => _periodFilter;

  /// Last 5 transactions across all time, newest first.
  List<Transaction> get recentTransactions =>
      _allTransactions.take(5).toList();

  /// All-time balance.
  double get totalBalance {
    final income = _allTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final expense = _allTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    return income - expense;
  }

  /// Income for the currently selected month (used on HomeScreen).
  double get totalIncome => _monthTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);

  /// Expense for the currently selected month (used on HomeScreen).
  double get totalExpense => _monthTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  /// Transactions filtered by [_periodFilter] — used in TransactionsScreen.
  List<Transaction> get filteredTransactions {
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
        return _monthTransactions;
      case PeriodFilter.year:
        return _allTransactions
            .where((t) => t.date.year == now.year)
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
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    loadTransactions();
  }

  void setPeriodFilter(PeriodFilter filter) {
    if (_periodFilter == filter) return;
    _periodFilter = filter;
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
