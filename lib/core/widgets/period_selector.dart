import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

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
    return SegmentedButton<PeriodFilter>(
      segments: PeriodFilter.values
          .map((f) => ButtonSegment<PeriodFilter>(
                value: f,
                label: Text(_label(f, l10n)),
              ))
          .toList(),
      selected: {current},
      onSelectionChanged: (value) => onChanged(value.first),
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
