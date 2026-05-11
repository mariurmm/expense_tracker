import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/category_name_resolver.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/settings_provider.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({required this.transaction, super.key});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final catProvider = context.watch<CategoryProvider>();

    final isIncome = transaction.type == TransactionType.income;
    final sign = isIncome ? '+' : '-';

    final cat = catProvider.findByName(transaction.category);
    final catColor = cat != null ? Color(cat.color) : AppColors.textSecondary;
    final catIcon = cat != null
        ? IconData(cat.icon, fontFamily: 'MaterialIcons')
        : Icons.category_outlined;

    // Amount colour: income = green, expense = red (independent of category)
    final amountColor = isIncome ? AppColors.income : AppColors.expense;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(catIcon, color: catColor, size: 22),
        ),
        title: Text(
          cat != null ? resolveCategoryName(cat, l10n) : transaction.category,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          (transaction.note?.isNotEmpty ?? false)
              ? transaction.note!
              : Formatters.formatDate(transaction.date),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$sign${Formatters.formatCurrencyWith(
                transaction.amount,
                locale: settings.currencyLocale,
                symbol: settings.currencySymbol,
              )}',
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (transaction.note?.isNotEmpty ?? false) ...[
              const SizedBox(height: 2),
              Text(
                Formatters.formatDate(transaction.date),
                style:
                    TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
