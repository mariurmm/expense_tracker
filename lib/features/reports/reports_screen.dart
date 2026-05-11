import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/category_name_resolver.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/period_selector.dart';
import '../../providers/reports_provider.dart';
import '../../providers/settings_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final reports = context.watch<ReportsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : AppColors.cardBackground,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 16,
                20,
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.navReports,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: PeriodSelector(
                      current: reports.periodFilter,
                      onChanged: reports.setPeriodFilter,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Summary row
                if (reports.hasExpenses || reports.totalIncome > 0)
                  _SummaryRow(
                      reports: reports,
                      settings: settings,
                      isDark: isDark),
                if (reports.hasExpenses || reports.totalIncome > 0)
                  const SizedBox(height: 20),

                // Pie chart section
                _ChartCard(
                  title: l10n.reportsExpensesByCategory,
                  isDark: isDark,
                  child: reports.hasExpenses
                      ? _PieSection(reports: reports, settings: settings)
                      : EmptyStateWidget(
                          illustration: EmptyIllustration.reports,
                          title: l10n.reportsNoData,
                          subtitle: l10n.reportsNoDataSubtitle,
                        ),
                ),
                const SizedBox(height: 16),

                // Bar chart section
                _ChartCard(
                  title: l10n.reportsIncomeVsExpense,
                  isDark: isDark,
                  child: _BarSection(reports: reports, settings: settings),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary row — 3 cards: income, expense, balance
// ---------------------------------------------------------------------------

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
      {required this.reports, required this.settings, required this.isDark});

  final ReportsProvider reports;
  final SettingsProvider settings;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cardColor = isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground;
    final balance = reports.totalIncome - reports.totalExpense;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: l10n.homeIncome,
            amount: reports.totalIncome,
            color: AppColors.income,
            icon: Icons.arrow_downward_rounded,
            cardColor: cardColor,
            settings: settings,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            label: l10n.homeExpense,
            amount: reports.totalExpense,
            color: AppColors.expense,
            icon: Icons.arrow_upward_rounded,
            cardColor: cardColor,
            settings: settings,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            label: l10n.homeBalance,
            amount: balance,
            color: AppColors.primary,
            icon: Icons.account_balance_wallet_outlined,
            cardColor: cardColor,
            settings: settings,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.cardColor,
    required this.settings,
    required this.isDark,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final Color cardColor;
  final SettingsProvider settings;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            Formatters.formatCompact(amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chart card wrapper
// ---------------------------------------------------------------------------

class _ChartCard extends StatelessWidget {
  const _ChartCard(
      {required this.title, required this.child, required this.isDark});

  final String title;
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
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
    final l10n = AppLocalizations.of(context);
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
                          radius: 68,
                        ),
                      )
                      .toList(),
                  centerSpaceRadius: 56,
                  sectionsSpace: 3,
                  pieTouchData: PieTouchData(),
                ),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.reportsTotal,
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
                    fontSize: 15,
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
    final l10n = AppLocalizations.of(context);
    return Column(
      children: reports.pieSlices.map((s) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: s.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  resolveCategoryNameByKey(s.categoryNameKey, s.categoryName, l10n),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                Formatters.formatCurrencyWith(
                  s.amount,
                  locale: settings.currencyLocale,
                  symbol: settings.currencySymbol,
                ),
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                child: Text(
                  '${s.percentage.toStringAsFixed(1)}%',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
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
    final l10n = AppLocalizations.of(context);
    final labels = reports.barLabels;
    final maxY = reports.maxY;
    final interval = maxY > 0 ? (maxY / 4).roundToDouble() : 250.0;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.5,
          child: BarChart(
            BarChartData(
              barGroups: reports.barGroups,
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              groupsSpace: 12,
              gridData: const FlGridData(drawVerticalLine: false),
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
                  getTooltipColor: (_) => Colors.blueGrey.shade800,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final label = rodIndex == 0
                        ? l10n.transactionIncome
                        : l10n.transactionExpense;
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
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(
                color: AppColors.income, label: l10n.transactionIncome),
            const SizedBox(width: 20),
            _LegendDot(
                color: AppColors.expense, label: l10n.transactionExpense),
          ],
        ),
      ],
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
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}
