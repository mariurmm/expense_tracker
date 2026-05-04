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
