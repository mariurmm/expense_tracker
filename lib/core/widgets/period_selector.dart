import 'package:flutter/material.dart';
import '../enums/period_filter.dart';

/// Reusable SegmentedButton for Week / Month / Year filtering.
/// Used in both ReportsScreen and TransactionsScreen.
class PeriodSelector extends StatelessWidget {
  final PeriodFilter current;
  final ValueChanged<PeriodFilter> onChanged;

  const PeriodSelector({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PeriodFilter>(
      segments: PeriodFilter.values
          .map((f) => ButtonSegment<PeriodFilter>(
                value: f,
                label: Text(f.label),
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
