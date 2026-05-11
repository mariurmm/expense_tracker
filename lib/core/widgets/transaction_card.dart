import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/transaction_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../constants/app_colors.dart';
import '../utils/category_name_resolver.dart';
import '../utils/formatters.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({required this.transaction, super.key});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final catProvider = context.watch<CategoryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isIncome = transaction.type == TransactionType.income;
    final cat = catProvider.findByName(transaction.category);
    final catColor =
        cat != null ? Color(cat.color) : AppColors.textSecondary;
    final catIcon = cat != null
        ? IconData(cat.icon, fontFamily: 'MaterialIcons')
        : Icons.category_outlined;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(catIcon, color: catColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat != null ? resolveCategoryName(cat, l10n) : transaction.category,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (transaction.note?.isNotEmpty ?? false)
                      ? transaction.note!
                      : Formatters.formatDate(transaction.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${Formatters.formatCurrencyWith(
                  transaction.amount,
                  locale: settings.currencyLocale,
                  symbol: settings.currencySymbol,
                )}',
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              if (transaction.note?.isNotEmpty ?? false) ...[
                const SizedBox(height: 2),
                Text(
                  Formatters.formatDate(transaction.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
