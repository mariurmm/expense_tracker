import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/settings_provider.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
    required this.month,
    super.key,
  });

  final double balance;
  final double income;
  final double expense;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              Formatters.formatMonth(month),
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.homeBalance,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 10),
            TweenAnimationBuilder<double>(
              key: ValueKey(balance),
              tween: Tween<double>(begin: 0, end: balance),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                final formatted = NumberFormat.currency(
                  locale: settings.currencyLocale,
                  symbol: settings.currencySymbol,
                ).format(value);
                return Text(
                  formatted,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SummaryChip(
                    label: l10n.homeIncome,
                    amount: income,
                    icon: Icons.arrow_downward_rounded,
                    color: AppColors.income,
                    settings: settings,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryChip(
                    label: l10n.homeExpense,
                    amount: expense,
                    icon: Icons.arrow_upward_rounded,
                    color: AppColors.expense,
                    settings: settings,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.settings,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.formatCurrencyWith(
                    amount,
                    locale: settings.currencyLocale,
                    symbol: settings.currencySymbol,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
