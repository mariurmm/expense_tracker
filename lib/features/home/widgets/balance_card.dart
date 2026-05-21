import 'package:expense_tracker/core/constants/currencies.dart';
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
    this.isLoading = false,
    this.balancePerCurrency = const {},
    this.hasLiveRates = false,
    super.key,
  });

  final double balance;
  final double income;
  final double expense;
  final DateTime month;
  final bool isLoading;
  final Map<String, double> balancePerCurrency;
  final bool hasLiveRates;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  Formatters.formatMonth(month),
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasLiveRates
                            ? Icons.wifi_rounded
                            : Icons.wifi_off_rounded,
                        size: 10,
                        color: hasLiveRates
                            ? Colors.greenAccent
                            : Colors.white38,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        hasLiveRates ? 'Live' : 'Offline',
                        style: TextStyle(
                          fontSize: 9,
                          color: hasLiveRates
                              ? Colors.greenAccent
                              : Colors.white38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.homeBalance,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 10),

            // Balance amount — spinner while rates load
            if (isLoading)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            else
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

            // Per-currency breakdown — only when multiple currencies used
            if (balancePerCurrency.length > 1) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: balancePerCurrency.entries.map((e) {
                    final info = currencyByCode(e.key);
                    final isPositive = e.value >= 0;
                    return Text(
                      '${isPositive ? '+' : ''}${e.value.toStringAsFixed(0)} ${info.symbol}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
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
