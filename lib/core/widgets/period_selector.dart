import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../enums/period_filter.dart';

/// Reusable SegmentedButton for Week / Month / Year filtering.
/// Used in both ReportsScreen and TransactionsScreen.
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    required this.current,
    required this.onChanged,
    super.key,
  });

  final PeriodFilter current;
  final ValueChanged<PeriodFilter> onChanged;

  String _label(PeriodFilter f, AppLocalizations l10n) {
    switch (f) {
      case PeriodFilter.week:
        return l10n.reportsPeriodWeek;
      case PeriodFilter.month:
        return l10n.reportsPeriodMonth;
      case PeriodFilter.year:
        return l10n.reportsPeriodYear;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const selectedColor = AppColors.primary;
    final unselectedBg = isDark
        ? AppColors.cardBackgroundDark
        : AppColors.cardBackground;
    final unselectedFg = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final borderColor = isDark
        ? AppColors.dividerDark
        : AppColors.divider;

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<PeriodFilter>(
        segments: PeriodFilter.values
            .map((f) => ButtonSegment<PeriodFilter>(
                  value: f,
                  label: Text(
                    _label(f, l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        selected: {current},
        onSelectionChanged: (value) => onChanged(value.first),
        expandedInsets: EdgeInsets.zero,
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return selectedColor;
            }
            return unselectedBg;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return unselectedFg;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: borderColor),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
