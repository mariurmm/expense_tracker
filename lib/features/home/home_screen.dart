import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../providers/transaction_provider.dart';
import '../transactions/add_transaction_sheet.dart';
import 'widgets/balance_card.dart';
import 'widgets/transaction_list_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _fabExpanded = false;

  void _openSheet() {
    // Collapse FAB before opening sheet
    setState(() => _fabExpanded = false);
    AddTransactionSheet.show(context);
  }

  void _toggleFab() {
    setState(() => _fabExpanded = !_fabExpanded);
    // Auto-collapse after 3 seconds if user doesn't tap again
    if (_fabExpanded) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _fabExpanded) {
          setState(() => _fabExpanded = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () async => provider.loadTransactions(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BalanceCard(
                    balance: provider.totalBalance,
                    income: provider.totalIncome,
                    expense: provider.totalExpense,
                    month: provider.selectedMonth,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    AppStrings.recentTransactions,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (provider.recentTransactions.isEmpty)
                    EmptyStateWidget(
                      illustration: EmptyIllustration.transactions,
                      title: AppStrings.noTransactions,
                      subtitle: AppStrings.noTransactionsHint,
                      buttonLabel: 'Добавить',
                      onButtonPressed: () =>
                          AddTransactionSheet.show(context),
                    )
                  else
                    ...provider.recentTransactions
                        .map((t) => TransactionListTile(transaction: t)),
                ],
              ),
            ),
          );
        },
      ),
      // ── Animated expanding FAB ─────────────────────────────────────────────
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: _fabExpanded
            ? FloatingActionButton.extended(
                key: const ValueKey('extended'),
                onPressed: _openSheet,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Добавить'),
              )
            : FloatingActionButton(
                key: const ValueKey('collapsed'),
                onPressed: _toggleFab,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              ),
      ),
    );
  }
}
