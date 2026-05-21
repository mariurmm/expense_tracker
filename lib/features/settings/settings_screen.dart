import 'dart:async';

import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/currencies.dart';
import '../../core/services/export_service.dart';
import '../../data/datasources/transaction_local_datasource.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../di/injection.dart';
import '../../providers/category_provider.dart';
import '../../providers/reports_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: isDark ? AppColors.surfaceDark : AppColors.cardBackground,
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 16,
                20,
                20,
              ),
              child: Text(
                l10n.settingsTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ---- Profile ----
                _GroupLabel(label: l10n.settingsProfile, isDark: isDark),
                _SectionCard(isDark: isDark, children: [
                  _ProfileTile(settings: settings),
                ]),
                const SizedBox(height: 20),

                // ---- Appearance ----
                _GroupLabel(label: l10n.settingsTheme, isDark: isDark),
                _SectionCard(isDark: isDark, children: [
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text(l10n.settingsThemeLight),
                            icon: const Icon(Icons.light_mode_outlined,
                                size: 20),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text(l10n.settingsThemeDark),
                            icon: const Icon(Icons.dark_mode_outlined,
                                size: 20),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (v) => unawaited(
                            context
                                .read<SettingsProvider>()
                                .setThemeMode(v.first)),
                        expandedInsets: EdgeInsets.zero,
                        style: ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: const WidgetStatePropertyAll(
                            Size(0, 48),
                          ),
                          backgroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.primary;
                            }
                            return isDark
                                ? AppColors.cardBackgroundDark
                                : AppColors.cardBackground;
                          }),
                          foregroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.white;
                            }
                            return isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary;
                          }),
                          side: WidgetStatePropertyAll(
                            BorderSide(
                              color: isDark
                                  ? AppColors.dividerDark
                                  : AppColors.divider,
                            ),
                          ),
                          textStyle: const WidgetStatePropertyAll(
                            TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          shape: const WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                            ),
                          ),
                        ),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                // ---- Currency ----
                _GroupLabel(label: l10n.settingsCurrency, isDark: isDark),
                _SectionCard(isDark: isDark, children: [
                  ListTile(
                    leading: const _IconBox(
                        icon: Icons.currency_exchange_outlined,
                        color: AppColors.primary),
                    title: Text(l10n.settingsCurrency),
                    subtitle: Text(
                      '${settings.currencySymbol}  ${settings.currencyName}',
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                    onTap: () => _showCurrencyPicker(context),
                  ),
                ]),
                const SizedBox(height: 20),

                // ---- Language ----
                _GroupLabel(label: l10n.settingsLanguage, isDark: isDark),
                _SectionCard(isDark: isDark, children: [
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
                          unawaited(context
                              .read<SettingsProvider>()
                              .setLocale(locale));
                        }
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                // ---- Export ----
                _GroupLabel(label: l10n.settingsExport, isDark: isDark),
                _SectionCard(isDark: isDark, children: [
                  ListTile(
                    leading: const _IconBox(
                        icon: Icons.download_rounded,
                        color: AppColors.income),
                    title: Text(l10n.settingsExport),
                    subtitle: Text(l10n.settingsExportSubtitle),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                    onTap: () => _exportCSV(context),
                  ),
                ]),
                const SizedBox(height: 20),

                // ---- Danger ----
                _SectionCard(isDark: isDark, children: [
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
              ]),
            ),
          ),
        ],
      ),
    );
  }

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
          .exportTransactionsToCSV(transactions.toList(), currency, l10n);

      if (!context.mounted) return;
      Navigator.pop(context);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: l10n.settingsExportShareSubject,
          text: l10n.settingsExportShareText,
        ),
      );
    } on Exception catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.settingsExportError}: $e')),
      );
    }
  }

  void _showCurrencyPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    unawaited(showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final settings = ctx.read<SettingsProvider>();
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ...kSupportedCurrencies.map((c) {
                final isSelected = c.code == settings.currencyCode;
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        c.symbol,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                  title: Text(c.name),
                  subtitle: Text(c.code),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                          color: AppColors.primary)
                      : null,
                  onTap: () {
                    unawaited(
                      context.read<SettingsProvider>().setCurrency(c.code),
                    );
                    Navigator.pop(ctx);
                  },
                );
              }),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 16,
              ),
            ],
          ),
        );
      },
    ));
  }

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
            style:
                TextButton.styleFrom(foregroundColor: AppColors.expense),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.buttonClear),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await Hive.box<Transaction>(TransactionLocalDatasource.boxName).clear();
    await getIt<CategoryRepository>().clearAndReseed();

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
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        child: Text(
          _initial,
          style: const TextStyle(
              color: AppColors.primary,
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
// Helpers
// ---------------------------------------------------------------------------

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color:
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children, required this.isDark});

  final List<Widget> children;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) children[i],
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
