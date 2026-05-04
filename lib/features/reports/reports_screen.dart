import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/period_selector.dart';
import '../../providers/reports_provider.dart';
import '../../providers/settings_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final reports = context.watch<ReportsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: PeriodSelector(
                current: reports.periodFilter,
                onChanged: reports.setPeriodFilter,
              ),
            ),
            const SizedBox(height: 24),
            const _SectionLabel(label: 'Expenses by Category'),
            const SizedBox(height: 12),
            if (reports.hasExpenses)
              _PieSection(reports: reports, settings: settings)
            else
              const EmptyStateWidget(
                illustration: EmptyIllustration.reports,
                title: 'Нет данных',
                subtitle: 'За выбранный период транзакций не найдено',
              ),
            const SizedBox(height: 28),
            const _SectionLabel(label: 'Income vs Expenses'),
            const SizedBox(height: 12),
            _BarSection(reports: reports, settings: settings),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pie chart + legend
// ---------------------------------------------------------------------------

class _PieSection extends StatelessWidget {
  const _PieSection({required this.reports, required this.settings});

  final ReportsProvider reports;
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: PieChart(
                PieChartData(
                  sections: reports.pieSlices
                      .map(
                        (s) => PieChartSectionData(
                          value: s.amount,
                          color: s.color,
                          title: '',
                          radius: 72,
                        ),
                      )
                      .toList(),
                  centerSpaceRadius: 58,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(),
                ),
                // ── Built-in fl_chart swap animation ──────────────────────
                swapAnimationDuration:
                    const Duration(milliseconds: 600),
                swapAnimationCurve: Curves.easeInOutCubic,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatCurrencyWith(
                    reports.totalExpense,
                    locale: settings.currencyLocale,
                    symbol: settings.currencySymbol,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _PieLegend(reports: reports, settings: settings),
      ],
    );
  }
}

class _PieLegend extends StatelessWidget {
  const _PieLegend({required this.reports, required this.settings});

  final ReportsProvider reports;
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reports.pieSlices.map((s) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: s.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.categoryName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                Formatters.formatCurrencyWith(
                  s.amount,
                  locale: settings.currencyLocale,
                  symbol: settings.currencySymbol,
                ),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                child: Text(
                  '${s.percentage.toStringAsFixed(1)}%',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Bar chart
// ---------------------------------------------------------------------------

class _BarSection extends StatelessWidget {
  const _BarSection({required this.reports, required this.settings});

  final ReportsProvider reports;
  final SettingsProvider settings;

  @override
  Widget build(BuildContext context) {
    final labels = reports.barLabels;
    final maxY = reports.maxY;
    final interval =
        maxY > 0 ? (maxY / 4).roundToDouble() : 250.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  barGroups: reports.barGroups,
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  groupsSpace: 12,
                  gridData: const FlGridData(
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == meta.max) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              Formatters.formatCompact(value),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              labels[i],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) =>
                          Colors.blueGrey.shade800,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label =
                            rodIndex == 0 ? 'Income' : 'Expense';
                        final amount = Formatters.formatCurrencyWith(
                          rod.toY,
                          locale: settings.currencyLocale,
                          symbol: settings.currencySymbol,
                        );
                        return BarTooltipItem(
                          '$label\n$amount',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // ── Built-in fl_chart swap animation ──────────────────────
                swapAnimationDuration:
                    const Duration(milliseconds: 500),
                swapAnimationCurve: Curves.easeOut,
              ),
            ),
            const SizedBox(height: 8),
            // Legend row
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: AppColors.income, label: 'Income'),
                SizedBox(width: 20),
                _LegendDot(color: AppColors.expense, label: 'Expense'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style:
                TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}
