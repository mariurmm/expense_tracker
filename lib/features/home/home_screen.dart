import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/transaction_card.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import 'widgets/balance_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () async => provider.loadTransactions(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.cardBackground,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      20,
                      MediaQuery.of(context).padding.top + 16,
                      20,
                      28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.appTitle,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  if (settings.userName.isNotEmpty)
                                    Text(
                                      settings.userName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.12),
                              child: Text(
                                settings.userName.isNotEmpty
                                    ? settings.userName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        BalanceCard(
                          balance: provider.totalBalance,
                          income: provider.totalIncome,
                          expense: provider.totalExpense,
                          month: provider.selectedMonth,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(context).padding.bottom + 120),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.homeRecentTransactions,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (provider.recentTransactions.isEmpty)
                          EmptyStateWidget(
                            illustration: EmptyIllustration.transactions,
                            title: l10n.emptyTransactionsTitle,
                            subtitle: l10n.emptyTransactionsSubtitle,
                          )
                        else
                          ...provider.recentTransactions
                              .map((t) => TransactionCard(transaction: t)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
