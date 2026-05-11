import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/category_name_resolver.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';

const _presetColors = <int>[
  0xFFEF5350,
  0xFFFF7043,
  0xFFFFCA28,
  0xFF66BB6A,
  0xFF42A5F5,
  0xFFAB47BC,
];

const _pickerIcons = <IconData>[
  Icons.restaurant,
  Icons.directions_car,
  Icons.account_balance_wallet,
  Icons.shopping_bag,
  Icons.favorite,
  Icons.category,
  Icons.home,
  Icons.fitness_center,
  Icons.school,
  Icons.flight,
  Icons.local_hospital,
  Icons.sports_esports,
];

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    );
  }

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Color get _activeColor =>
      _type == TransactionType.income ? AppColors.income : AppColors.expense;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorCategoryEmpty)),
      );
      return;
    }

    setState(() => _isSaving = true);

    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: double.parse(_amountController.text.replaceAll(',', '.')),
      type: _type,
      category: _selectedCategory!,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    try {
      await context.read<TransactionProvider>().addTransaction(transaction);
      if (mounted) Navigator.pop(context);
    } on Exception catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context).errorSaveTransaction)),
        );
      }
    }
  }

  Future<void> _showNewCategoryDialog() async {
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController();
    var selectedColor = _presetColors[0];
    var selectedIconCodePoint = Icons.category.codePoint;
    var selectedCategoryType = _type == TransactionType.income ? 'income' : 'expense';

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: Text(l10n.categoryAddTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'expense',
                      label: Text(l10n.categoryTypeExpense),
                    ),
                    ButtonSegment(
                      value: 'income',
                      label: Text(l10n.categoryTypeIncome),
                    ),
                  ],
                  selected: {selectedCategoryType},
                  onSelectionChanged: (s) =>
                      setDlg(() => selectedCategoryType = s.first),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.categoryName,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),
                Text(l10n.categoryColor,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _presetColors.map((c) {
                    final selected = selectedColor == c;
                    return GestureDetector(
                      onTap: () => setDlg(() => selectedColor = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(color: Colors.black87, width: 2.5)
                              : null,
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: Color(c).withValues(alpha: 0.4),
                                    blurRadius: 6,
                                  )
                                ]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(l10n.categoryIcon,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _pickerIcons.map((ic) {
                    final selected = selectedIconCodePoint == ic.codePoint;
                    return GestureDetector(
                      onTap: () =>
                          setDlg(() => selectedIconCodePoint = ic.codePoint),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: selected
                              ? Border.all(
                                  color: AppColors.primary, width: 1.5)
                              : null,
                        ),
                        child: Icon(
                          ic,
                          color: selected
                              ? AppColors.primary
                              : Colors.grey.shade600,
                          size: 22,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.buttonCancel),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final cat = Category(
                  id: const Uuid().v4(),
                  name: name,
                  icon: selectedIconCodePoint,
                  color: selectedColor,
                  isCustom: true,
                  categoryType: selectedCategoryType,
                );
                await context.read<CategoryProvider>().addCategory(cat);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) setState(() => _selectedCategory = name);
              },
              child: Text(l10n.buttonSave),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = _type == TransactionType.expense
        ? categoryProvider.expenseCategories
        : categoryProvider.incomeCategories;
    final bgColor =
        isDark ? AppColors.cardBackgroundDark : AppColors.cardBackground;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.dividerDark
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Income / Expense toggle — custom pill style
            Center(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : const Color(0xFFF0F1F5),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: TransactionType.values.map((type) {
                    final isSelected = _type == type;
                    final color = type == TransactionType.income
                        ? AppColors.income
                        : AppColors.expense;
                    final label = type == TransactionType.income
                        ? l10n.transactionIncome
                        : l10n.transactionExpense;
                    final icon = type == TransactionType.income
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _type = type;
                        _selectedCategory = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Large centered amount display
            Center(
              child: TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                ],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _activeColor,
                  letterSpacing: -0.5,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary)
                        .withValues(alpha: 0.4),
                    letterSpacing: -0.5,
                  ),
                  prefixText: '${settings.currencySymbol} ',
                  prefixStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: _activeColor,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  errorStyle: const TextStyle(fontSize: 11),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.errorAmountEmpty;
                  final p = double.tryParse(v.replaceAll(',', '.'));
                  if (p == null || p <= 0) return l10n.errorAmountZero;
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),

            // Category label
            Text(
              l10n.transactionCategory,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),

            // Category chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  if (i == categories.length) {
                    return ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: Text(l10n.categoryNew),
                      onPressed: _showNewCategoryDialog,
                    );
                  }
                  final cat = categories[i];
                  final selected = _selectedCategory == cat.name;
                  final catColor = Color(cat.color);
                  return FilterChip(
                    avatar: Icon(
                      IconData(cat.icon, fontFamily: 'MaterialIcons'),
                      size: 16,
                      color:
                          selected ? catColor : Colors.grey.shade500,
                    ),
                    label: Text(resolveCategoryName(cat, l10n)),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat.name),
                    selectedColor: catColor.withValues(alpha: 0.15),
                    checkmarkColor: catColor,
                    labelStyle: TextStyle(
                      color: selected ? catColor : null,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: selected
                          ? catColor
                          : (isDark
                              ? AppColors.dividerDark
                              : Colors.grey.shade300),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Date row
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? AppColors.dividerDark
                        : const Color(0xFFDEE2E6),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isDark
                      ? AppColors.surfaceDark
                      : const Color(0xFFF8F9FA),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(_selectedDate),
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Note
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.transactionNote,
                hintText: l10n.transactionNoteHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _activeColor,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.buttonSave),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
