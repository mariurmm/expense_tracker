enum PeriodFilter { week, month, year }

extension PeriodFilterLabel on PeriodFilter {
  String get label {
    switch (this) {
      case PeriodFilter.week:
        return 'Week';
      case PeriodFilter.month:
        return 'Month';
      case PeriodFilter.year:
        return 'Year';
    }
  }
}
