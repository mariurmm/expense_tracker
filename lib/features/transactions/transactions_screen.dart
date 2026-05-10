import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/enums/period_filter.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/period_selector.dart';
import '../../core/widgets/transaction_card.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
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
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _Header(provider: provider, isDark: isDark),
              Expanded(
                child: provider.filteredTransactions.isEmpty
                    ? EmptyStateWidget(
                        illustration: EmptyIllustration.transactions,
                        title: l10n.emptyTransactionsTitle,
                        subtitle: l10n.emptyTransactionsSubtitle,
                        buttonLabel: l10n.homeAddTransaction,
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

class _Header extends StatelessWidget {
  const _Header({required this.provider, required this.isDark});

  final TransactionProvider provider;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.navTransactions,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          PeriodSelector(
            current: provider.periodFilter,
            onChanged: provider.setPeriodFilter,
          ),
          if (provider.periodFilter == PeriodFilter.month) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: provider.previousMonth,
                  icon: Icon(
                    Icons.chevron_left,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    size: 28,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.cardBackgroundDark
                        : AppColors.background,
                  ),
                ),
                Text(
                  Formatters.formatMonth(provider.selectedMonth),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: provider.nextMonth,
                  icon: Icon(
                    Icons.chevron_right,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    size: 28,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.cardBackgroundDark
                        : AppColors.background,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
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
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          letterSpacing: 0.5,
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

class _DismissibleTile extends StatelessWidget {
  const _DismissibleTile({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child:
            const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.transactionDeleteTitle),
          content: Text(l10n.transactionDeleteMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.buttonCancel),
            ),
            TextButton(
              style:
                  TextButton.styleFrom(foregroundColor: AppColors.expense),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.buttonDelete),
            ),
          ],
        ),
      ),
      onDismissed: (_) async {
        final messenger = ScaffoldMessenger.of(context);
        try {
          await context
              .read<TransactionProvider>()
              .deleteTransaction(transaction.id);
        } on Exception catch (_) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.errorDeleteTransaction)),
          );
          return;
        }
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.transactionDeleteConfirm)),
        );
      },
      child: TransactionCard(transaction: transaction),
    );
  }
}
