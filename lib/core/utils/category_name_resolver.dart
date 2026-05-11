import '../../data/models/category_model.dart';
import '../../l10n/app_localizations.dart';

String resolveCategoryName(Category category, AppLocalizations l10n) {
  if (category.nameKey.isEmpty) return category.name;
  return _resolveByKey(category.nameKey, l10n) ?? category.name;
}

String resolveCategoryNameByKey(
  String nameKey,
  String fallback,
  AppLocalizations l10n,
) {
  if (nameKey.isEmpty) return fallback;
  return _resolveByKey(nameKey, l10n) ?? fallback;
}

String? _resolveByKey(String key, AppLocalizations l10n) => switch (key) {
  'catExpenseFood'          => l10n.catExpenseFood,
  'catExpenseTransport'     => l10n.catExpenseTransport,
  'catExpenseShopping'      => l10n.catExpenseShopping,
  'catExpenseHealth'        => l10n.catExpenseHealth,
  'catExpenseEntertainment' => l10n.catExpenseEntertainment,
  'catExpenseOther'         => l10n.catExpenseOther,
  'catIncomeSalary'         => l10n.catIncomeSalary,
  'catIncomeFreelance'      => l10n.catIncomeFreelance,
  'catIncomeGift'           => l10n.catIncomeGift,
  'catIncomeInvestments'    => l10n.catIncomeInvestments,
  'catIncomeOther'          => l10n.catIncomeOther,
  _                         => null,
};
