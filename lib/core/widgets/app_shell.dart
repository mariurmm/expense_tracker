import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../features/home/home_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/transactions/add_transaction_sheet.dart';
import '../../features/transactions/transactions_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    TransactionsScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      extendBody: true,
      floatingActionButton: _index < 2
          ? FloatingActionButton.extended(
              onPressed: () => AddTransactionSheet.show(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.homeAddTransaction),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              height: 64,
              backgroundColor: isDark
                  ? AppColors.cardBackgroundDark
                  : AppColors.cardBackground,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: l10n.navHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.list_alt_outlined),
                  selectedIcon: const Icon(Icons.list_alt),
                  label: l10n.navTransactions,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.bar_chart_outlined),
                  selectedIcon: const Icon(Icons.bar_chart),
                  label: l10n.navReports,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: l10n.navSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
