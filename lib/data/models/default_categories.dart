import 'category_model.dart';

const List<Category> defaultExpenseCategories = [
  Category(
    id: 'cat_food',
    name: 'Food',
    nameKey: 'catExpenseFood',
    icon: 0xe56c, // Icons.restaurant.codePoint
    color: 0xFFFF6B6B,
    isCustom: false,
  ),
  Category(
    id: 'cat_transport',
    name: 'Transport',
    nameKey: 'catExpenseTransport',
    icon: 0xe1b0, // Icons.directions_car.codePoint
    color: 0xFF4ECDC4,
    isCustom: false,
  ),
  Category(
    id: 'cat_shopping',
    name: 'Shopping',
    nameKey: 'catExpenseShopping',
    icon: 0xf72f, // Icons.shopping_bag.codePoint
    color: 0xFFFFE66D,
    isCustom: false,
  ),
  Category(
    id: 'cat_health',
    name: 'Health',
    nameKey: 'catExpenseHealth',
    icon: 0xe87d, // Icons.favorite.codePoint
    color: 0xFFFF8B94,
    isCustom: false,
  ),
  Category(
    id: 'cat_entertainment',
    name: 'Entertainment',
    nameKey: 'catExpenseEntertainment',
    icon: 0xe623, // Icons.movie.codePoint
    color: 0xFFA8E6CF,
    isCustom: false,
  ),
  Category(
    id: 'cat_expense_other',
    name: 'Other',
    nameKey: 'catExpenseOther',
    icon: 0xe574, // Icons.category.codePoint
    color: 0xFFB0B0B0,
    isCustom: false,
  ),
];

const List<Category> defaultIncomeCategories = [
  Category(
    id: 'cat_salary',
    name: 'Salary',
    nameKey: 'catIncomeSalary',
    icon: 0xe943, // Icons.work.codePoint
    color: 0xFF34C759,
    isCustom: false,
    categoryType: 'income',
  ),
  Category(
    id: 'cat_freelance',
    name: 'Freelance',
    nameKey: 'catIncomeFreelance',
    icon: 0xe31f, // Icons.laptop.codePoint
    color: 0xFF5AC8FA,
    isCustom: false,
    categoryType: 'income',
  ),
  Category(
    id: 'cat_gift',
    name: 'Gift',
    nameKey: 'catIncomeGift',
    icon: 0xe8f6, // Icons.card_giftcard.codePoint
    color: 0xFFFF9500,
    isCustom: false,
    categoryType: 'income',
  ),
  Category(
    id: 'cat_investments',
    name: 'Investments',
    nameKey: 'catIncomeInvestments',
    icon: 0xe6e1, // Icons.trending_up.codePoint
    color: 0xFF30D158,
    isCustom: false,
    categoryType: 'income',
  ),
  Category(
    id: 'cat_income_other',
    name: 'Other income',
    nameKey: 'catIncomeOther',
    icon: 0xe227, // Icons.attach_money.codePoint
    color: 0xFF64D2FF,
    isCustom: false,
    categoryType: 'income',
  ),
];

/// All default categories — expense list first, income list second.
const List<Category> defaultCategories = [
  ...defaultExpenseCategories,
  ...defaultIncomeCategories,
];
