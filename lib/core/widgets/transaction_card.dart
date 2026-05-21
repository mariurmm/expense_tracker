import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/currencies.dart';
import '../../data/models/transaction_model.dart';
import '../../features/transactions/add_transaction_sheet.dart';
import '../../providers/category_provider.dart';
import '../constants/app_colors.dart';
import '../utils/category_name_resolver.dart';
import '../utils/formatters.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({required this.transaction, super.key});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
    final hasNote = transaction.note?.isNotEmpty ?? false;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final txCurrency = currencyByCode(transaction.currencyCode);
    final formattedAmount = Formatters.formatCurrencyWith(
      transaction.amount,
      locale: txCurrency.locale,
      symbol: txCurrency.symbol,
    );

    return InkWell(
      onTap: () => AddTransactionSheet.show(context, transaction: transaction),
      borderRadius: BorderRadius.circular(16),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardBackgroundDark
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Category icon
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

          // Left: category name + note (if any)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat != null
                      ? resolveCategoryName(cat, l10n)
                      : transaction.category,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                if (hasNote) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.note!,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right: amount + date always below
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}$formattedAmount',
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Formatters.formatDate(transaction.date),
                style: TextStyle(
                  fontSize: 11,
                  color: secondaryColor,
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
