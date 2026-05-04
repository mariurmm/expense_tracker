import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';

// ---------------------------------------------------------------------------
// Preset options for the "New Category" dialog
// ---------------------------------------------------------------------------

const _presetColors = <int>[
  0xFFEF5350, // Red
  0xFFFF7043, // Deep Orange
  0xFFFFCA28, // Amber
  0xFF66BB6A, // Green
  0xFF42A5F5, // Blue
  0xFFAB47BC, // Purple
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

// ---------------------------------------------------------------------------
// AddTransactionSheet
// ---------------------------------------------------------------------------

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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.selectCategory)),
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
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.saveError)),
        );
      }
    }
  }

  Future<void> _showNewCategoryDialog() async {
    final nameCtrl = TextEditingController();
    var selectedColor = _presetColors[0];
    var selectedIconCodePoint = Icons.category.codePoint;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('New Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Category name',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),

                // Color picker
                const Text('Color',
                    style: TextStyle(
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
                              ? Border.all(
                                  color: Colors.black87, width: 2.5)
                              : null,
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: Color(c)
                                        .withValues(alpha: 0.4),
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

                // Icon picker
                const Text('Icon',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _pickerIcons.map((ic) {
                    final selected =
                        selectedIconCodePoint == ic.codePoint;
                    return GestureDetector(
                      onTap: () => setDlg(
                          () => selectedIconCodePoint = ic.codePoint),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                                  .withValues(alpha: 0.15)
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
              child: const Text('Cancel'),
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
                );
                await context
                    .read<CategoryProvider>()
                    .addCategory(cat);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) setState(() => _selectedCategory = name);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final activeColor =
        _type == TransactionType.income ? AppColors.income : AppColors.expense;
    final settings = context.watch<SettingsProvider>();
    final categories = context.watch<CategoryProvider>().categories;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.addTransaction,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Income / Expense toggle
            Center(
              child: SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_downward_rounded),
                  ),
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_upward_rounded),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (v) =>
                    setState(() => _type = v.first),
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return activeColor.withValues(alpha: 0.15);
                    }
                    return null;
                  }),
                  foregroundColor:
                      WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return activeColor;
                    }
                    return Colors.grey.shade600;
                  }),
                  iconColor:
                      WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return activeColor;
                    }
                    return Colors.grey.shade600;
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Amount field
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
              ],
              decoration: InputDecoration(
                labelText: AppStrings.amount,
                prefixText: '${settings.currencySymbol} ',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter an amount';
                final p = double.tryParse(v.replaceAll(',', '.'));
                if (p == null || p <= 0) {
                  return 'Enter a valid amount greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category label
            Text(
              AppStrings.category,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            // Dynamic category chips + "New" button
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                // +1 for the "New" chip
                itemCount: categories.length + 1,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  // Last item = "New category" chip
                  if (i == categories.length) {
                    return ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: const Text('New'),
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
                      color: selected ? catColor : Colors.grey.shade500,
                    ),
                    label: Text(cat.name),
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
                          : Colors.grey.shade300,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Date picker
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDEE2E6)),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF8F9FA),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      Formatters.formatDate(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Note
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: AppStrings.note,
                hintText: 'e.g. Lunch with colleagues',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(AppStrings.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
