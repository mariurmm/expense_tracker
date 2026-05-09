import 'dart:async';

import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/export_service.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/datasources/transaction_local_datasource.dart';
import '../../data/models/category_model.dart';
import '../../data/models/default_categories.dart';
import '../../data/models/transaction_model.dart';
import '../../di/injection.dart';
import '../../providers/category_provider.dart';
import '../../providers/reports_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';

// ---------------------------------------------------------------------------
// Supported currencies
// ---------------------------------------------------------------------------

class _CurrencyOption {
  const _CurrencyOption(
      {required this.symbol, required this.locale, required this.label});

  final String symbol;
  final String locale;
  final String label;
}

const _currencies = [
  _CurrencyOption(symbol: '₸', locale: 'ru_RU', label: '₸  Kazakhstani Tenge'),
  _CurrencyOption(symbol: '₽', locale: 'ru_RU', label: '₽  Russian Ruble'),
  _CurrencyOption(symbol: r'$', locale: 'en_US', label: r'$  US Dollar'),
  _CurrencyOption(symbol: '€', locale: 'de_DE', label: '€  Euro'),
  _CurrencyOption(symbol: '£', locale: 'en_GB', label: '£  British Pound'),
];

// ---------------------------------------------------------------------------
// SettingsScreen
// ---------------------------------------------------------------------------

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
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
              leading: const _IconBox(
                  icon: Icons.currency_exchange_outlined,
                  color: AppColors.primaryLight),
              title: Text(l10n.settingsCurrency),
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

          // ---- Language ----
          _SectionCard(children: [
            ListTile(
              leading: const _IconBox(
                  icon: Icons.language_outlined,
                  color: AppColors.primaryLight),
              title: Text(l10n.settingsLanguage),
              trailing: DropdownButton<Locale>(
                value: settings.locale,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(
                    value: const Locale('ru'),
                    child: Text(l10n.settingsLanguageRu),
                  ),
                  DropdownMenuItem(
                    value: const Locale('en'),
                    child: Text(l10n.settingsLanguageEn),
                  ),
                ],
                onChanged: (locale) {
                  if (locale != null) {
                    unawaited(context.read<SettingsProvider>().setLocale(locale));
                  }
                },
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // ---- Export ----
          _SectionCard(children: [
            ListTile(
              leading: const _IconBox(
                  icon: Icons.download_rounded,
                  color: AppColors.primary),
              title: Text(l10n.settingsExport),
              subtitle: Text(l10n.settingsExportSubtitle),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary),
              onTap: () => _exportCSV(context),
            ),
          ]),
          const SizedBox(height: 16),

          // ---- About ----
          _SectionCard(children: [
            ListTile(
              leading: const _IconBox(
                  icon: Icons.info_outline, color: Colors.blueGrey),
              title: Text(l10n.settingsAbout),
              subtitle: Text('${l10n.settingsVersion} 1.0.0'),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 MIT License',
              ),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const _IconBox(
                  icon: Icons.delete_forever_outlined,
                  color: AppColors.expense),
              title: Text(
                l10n.settingsClearData,
                style: const TextStyle(color: AppColors.expense),
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
    final l10n = AppLocalizations.of(context);
    final transactions = context.read<TransactionProvider>().allTransactions;
    final currency = context.read<SettingsProvider>().currencySymbol;

    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsExportEmpty)),
      );
      return;
    }

    unawaited(showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    ));

    try {
      final file = await getIt<ExportService>()
          .exportTransactionsToCSV(transactions.toList(), currency);

      if (!context.mounted) return;
      Navigator.pop(context);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: l10n.settingsExportShareSubject,
        text: l10n.settingsExportShareText,
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.settingsExportError}: $e')),
      );
    }
  }

  // ---- currency picker ----

  void _showCurrencyPicker(BuildContext context, SettingsProvider settings) {
    final l10n = AppLocalizations.of(context);
    unawaited(showModalBottomSheet<void>(
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
            Text(l10n.settingsSelectCurrency,
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
    ));
  }

  // ---- clear data ----

  Future<void> _confirmClearData(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsClearData),
        content: Text(l10n.settingsClearDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.buttonCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.buttonClear),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await Hive.box<Transaction>(TransactionLocalDatasource.boxName).clear();
    await Hive.box<Category>(CategoryLocalDatasource.boxName).clear();

    final catDs = CategoryLocalDatasource();
    for (final cat in buildDefaultCategories()) {
      await catDs.put(cat);
    }

    if (!context.mounted) return;
    context.read<TransactionProvider>().loadTransactions();
    context.read<CategoryProvider>().loadCategories();
    context.read<ReportsProvider>().load();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsClearDone)),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile tile
// ---------------------------------------------------------------------------

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.settings});

  final SettingsProvider settings;

  String get _initial =>
      settings.userName.isNotEmpty ? settings.userName[0].toUpperCase() : '?';

  Future<void> _editName(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: settings.userName);
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsYourName),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.settingsEnterName),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.buttonSave),
          ),
        ],
      ),
    );
    if (saved != null && saved.isNotEmpty && context.mounted) {
      await context.read<SettingsProvider>().setUserName(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        settings.userName.isEmpty ? l10n.settingsTapName : settings.userName,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: settings.userName.isEmpty ? Colors.grey.shade400 : null,
        ),
      ),
      subtitle: Text(l10n.settingsYourName),
      trailing: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
      onTap: () => _editName(context),
    );
  }
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

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
  const _IconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

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
