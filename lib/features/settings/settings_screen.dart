import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/export_service.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/datasources/transaction_local_datasource.dart';
import '../../data/models/category_model.dart';
import '../../data/models/default_categories.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/reports_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';

// ---------------------------------------------------------------------------
// Supported currencies
// ---------------------------------------------------------------------------

class _CurrencyOption {
  final String symbol;
  final String locale;
  final String label;

  const _CurrencyOption(
      {required this.symbol, required this.locale, required this.label});
}

const _currencies = [
  _CurrencyOption(symbol: '₸', locale: 'ru_RU', label: '₸  Kazakhstani Tenge'),
  _CurrencyOption(symbol: '₽', locale: 'ru_RU', label: '₽  Russian Ruble'),
  _CurrencyOption(symbol: '\$', locale: 'en_US', label: '\$  US Dollar'),
  _CurrencyOption(symbol: '€', locale: 'eu', label: '€  Euro'),
  _CurrencyOption(symbol: '£', locale: 'en_GB', label: '£  British Pound'),
];

// ---------------------------------------------------------------------------
// SettingsScreen
// ---------------------------------------------------------------------------

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Profile ----
          _SectionCard(children: [
            _ProfileTile(settings: settings),
          ]),
          const SizedBox(height: 16),

          // ---- Currency ----
          _SectionCard(children: [
            ListTile(
              leading: _IconBox(
                  icon: Icons.currency_exchange_outlined,
                  color: AppColors.primaryLight),
              title: const Text('Currency'),
              subtitle: Text(
                '${settings.currencySymbol}  '
                '${_currencies.firstWhere((c) => c.locale == settings.currencyLocale && c.symbol == settings.currencySymbol, orElse: () => _currencies.first).label.split('  ').last}',
              ),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary),
              onTap: () => _showCurrencyPicker(context, settings),
            ),
          ]),
          const SizedBox(height: 16),

          // ---- Export ----
          _SectionCard(children: [
            ListTile(
              leading: _IconBox(
                  icon: Icons.download_rounded,
                  color: AppColors.primary),
              title: const Text('Экспорт в CSV'),
              subtitle: const Text('Скачать все транзакции'),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary),
              onTap: () => _exportCSV(context),
            ),
          ]),
          const SizedBox(height: 16),

          // ---- About ----
          _SectionCard(children: [
            ListTile(
              leading: _IconBox(
                  icon: Icons.info_outline, color: Colors.blueGrey),
              title: const Text('About'),
              subtitle: const Text('Version 1.0.0'),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: _IconBox(
                  icon: Icons.delete_forever_outlined,
                  color: AppColors.expense),
              title: const Text(
                'Clear all data',
                style: TextStyle(color: AppColors.expense),
              ),
              onTap: () => _confirmClearData(context),
            ),
          ]),
        ],
      ),
    );
  }

  // ---- CSV export ----

  Future<void> _exportCSV(BuildContext context) async {
    final transactions =
        context.read<TransactionProvider>().allTransactions;
    final currency =
        context.read<SettingsProvider>().currencySymbol;

    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет данных для экспорта')),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      final file = await ExportService()
          .exportTransactionsToCSV(transactions.toList(), currency);

      if (!context.mounted) return;
      Navigator.pop(context); // close loading

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Мои финансы — экспорт',
        text: 'Экспорт транзакций из приложения Finance Tracker',
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка экспорта: $e')),
      );
    }
  }

  // ---- currency picker ----

  void _showCurrencyPicker(
      BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Currency',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._currencies.map((c) {
              final selected = settings.currencySymbol == c.symbol &&
                  settings.currencyLocale == c.locale;
              return ListTile(
                title: Text(c.label),
                trailing: selected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  settings.setCurrency(
                      symbol: c.symbol, locale: c.locale);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // ---- clear data ----

  Future<void> _confirmClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
            'This will permanently delete all transactions and custom '
            'categories. Default categories will be restored.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style:
                TextButton.styleFrom(foregroundColor: AppColors.expense),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    // Clear Hive boxes
    await Hive.box<Transaction>(TransactionLocalDatasource.boxName).clear();
    await Hive.box<Category>(CategoryLocalDatasource.boxName).clear();

    // Re-seed default categories
    final catDs = CategoryLocalDatasource();
    for (final cat in buildDefaultCategories()) {
      await catDs.put(cat);
    }

    if (!context.mounted) return;
    context.read<TransactionProvider>().loadTransactions();
    context.read<CategoryProvider>().loadCategories();
    context.read<ReportsProvider>().load();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data cleared')),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile tile (stateful for the edit dialog)
// ---------------------------------------------------------------------------

class _ProfileTile extends StatelessWidget {
  final SettingsProvider settings;
  const _ProfileTile({required this.settings});

  String get _initial =>
      settings.userName.isNotEmpty ? settings.userName[0].toUpperCase() : '?';

  Future<void> _editName(BuildContext context) async {
    final controller =
        TextEditingController(text: settings.userName);
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter your name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != null && saved.isNotEmpty && context.mounted) {
      context.read<SettingsProvider>().setUserName(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primary,
        child: Text(
          _initial,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      title: Text(
        settings.userName.isEmpty ? 'Tap to set your name' : settings.userName,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color:
              settings.userName.isEmpty ? Colors.grey.shade400 : null,
        ),
      ),
      subtitle: const Text('Your name'),
      trailing: const Icon(Icons.edit_outlined,
          color: AppColors.textSecondary),
      onTap: () => _editName(context),
    );
  }
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: 1, indent: 56),
          ],
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
