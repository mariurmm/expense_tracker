import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/enums/period_filter.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/period_selector.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../home/widgets/transaction_list_tile.dart';
import 'add_transaction_sheet.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  Map<String, List<Transaction>> _groupByDate(
      List<Transaction> transactions) {
    final map = <String, List<Transaction>>{};
    for (final t in transactions) {
      map.putIfAbsent(Formatters.formatDate(t.date), () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _FilterBar(provider: provider),
              Expanded(
                child: provider.filteredTransactions.isEmpty
                    ? EmptyStateWidget(
                        illustration: EmptyIllustration.transactions,
                        title: AppStrings.noTransactions,
                        subtitle: AppStrings.noTransactionsHint,
                        buttonLabel: 'Добавить',
                        onButtonPressed: () =>
                            AddTransactionSheet.show(context),
                      )
                    : _GroupedList(
                        transactions: provider.filteredTransactions,
                        groupByDate: _groupByDate,
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddTransactionSheet.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bar — PeriodSelector + month navigation (shown for month mode only)
// ---------------------------------------------------------------------------

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.provider});

  final TransactionProvider provider;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              PeriodSelector(
                current: provider.periodFilter,
                onChanged: provider.setPeriodFilter,
              ),
              if (provider.periodFilter == PeriodFilter.month) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: provider.previousMonth,
                      icon: const Icon(Icons.chevron_left,
                          color: Colors.white, size: 28),
                    ),
                    Text(
                      Formatters.formatMonth(provider.selectedMonth),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: provider.nextMonth,
                      icon: const Icon(Icons.chevron_right,
                          color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grouped list with staggered entry animations
// ---------------------------------------------------------------------------

class _GroupedList extends StatelessWidget {
  const _GroupedList(
      {required this.transactions, required this.groupByDate});

  final List<Transaction> transactions;
  final Map<String, List<Transaction>> Function(List<Transaction>)
      groupByDate;

  @override
  Widget build(BuildContext context) {
    final grouped = groupByDate(transactions);
    final dates = grouped.keys.toList();

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: dates.length,
        itemBuilder: (context, i) {
          final date = dates[i];
          final items = grouped[date]!;

          return AnimationConfiguration.staggeredList(
            position: i,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        date,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    ...items.map((t) => _DismissibleTile(transaction: t)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Swipe-to-delete tile
// ---------------------------------------------------------------------------

class _DismissibleTile extends StatelessWidget {
  const _DismissibleTile({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child:
            const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(AppStrings.confirmDelete),
          content: const Text(AppStrings.confirmDeleteMsg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.expense),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(AppStrings.delete),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        final messenger = ScaffoldMessenger.of(context);
        context
            .read<TransactionProvider>()
            .deleteTransaction(transaction.id)
            .catchError((_) {
          messenger.showSnackBar(
            const SnackBar(content: Text(AppStrings.deleteError)),
          );
        });
        messenger.showSnackBar(
          const SnackBar(content: Text(AppStrings.deleteSuccess)),
        );
      },
      child: TransactionListTile(transaction: transaction),
    );
  }
}
