// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Where\'s the money?';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeBalance => 'Current Balance';

  @override
  String get homeIncome => 'Income';

  @override
  String get homeExpense => 'Expenses';

  @override
  String get homeRecentTransactions => 'Recent Transactions';

  @override
  String get homeViewAll => 'View All';

  @override
  String get homeAddTransaction => 'Add';

  @override
  String get transactionIncome => 'Income';

  @override
  String get transactionExpense => 'Expense';

  @override
  String get transactionAmount => 'Amount';

  @override
  String get transactionCategory => 'Category';

  @override
  String get transactionDate => 'Date';

  @override
  String get transactionNote => 'Note (optional)';

  @override
  String get transactionNoteHint => 'e.g. Lunch with colleagues';

  @override
  String get transactionSave => 'Save';

  @override
  String get transactionDelete => 'Delete';

  @override
  String get transactionDeleteConfirm => 'Transaction deleted';

  @override
  String get transactionDeleteTitle => 'Delete Transaction';

  @override
  String get transactionDeleteMessage =>
      'Are you sure you want to delete this transaction?';

  @override
  String get transactionAddTitle => 'New Transaction';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categorySalary => 'Salary';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryOther => 'Other';

  @override
  String get categoryAddNew => '+ New Category';

  @override
  String get categoryAddTitle => 'New Category';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryColor => 'Color';

  @override
  String get categoryIcon => 'Icon';

  @override
  String get categoryNew => 'New';

  @override
  String get categoryTypeExpense => 'For expenses';

  @override
  String get categoryTypeIncome => 'For income';

  @override
  String get catExpenseFood => 'Food';

  @override
  String get catExpenseTransport => 'Transport';

  @override
  String get catExpenseShopping => 'Shopping';

  @override
  String get catExpenseHealth => 'Health';

  @override
  String get catExpenseEntertainment => 'Entertainment';

  @override
  String get catExpenseOther => 'Other';

  @override
  String get catIncomeSalary => 'Salary';

  @override
  String get catIncomeFreelance => 'Freelance';

  @override
  String get catIncomeGift => 'Gift';

  @override
  String get catIncomeInvestments => 'Investments';

  @override
  String get catIncomeOther => 'Other income';

  @override
  String get reportsPeriodWeek => 'Week';

  @override
  String get reportsPeriodMonth => 'Month';

  @override
  String get reportsPeriodYear => 'Year';

  @override
  String get reportsExpensesByCategory => 'Expenses by Category';

  @override
  String get reportsIncomeVsExpense => 'Income vs Expenses';

  @override
  String get reportsNoData => 'No data';

  @override
  String get reportsNoDataSubtitle =>
      'No transactions found for selected period';

  @override
  String get reportsTotal => 'Total';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsYourName => 'Your name';

  @override
  String get settingsEnterName => 'Enter your name';

  @override
  String get settingsTapName => 'Tap to set your name';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsSelectCurrency => 'Select Currency';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageRu => 'Русский';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsExport => 'Export to CSV';

  @override
  String get settingsExportSubtitle => 'Download all transactions';

  @override
  String get settingsExportEmpty => 'No data to export';

  @override
  String get settingsExportError => 'Export error';

  @override
  String get settingsExportShareSubject => 'My finances — export';

  @override
  String get settingsExportShareText =>
      'Where\'s the money? transaction export';

  @override
  String get settingsClearData => 'Clear all data';

  @override
  String get settingsClearDataSubtitle => 'This action cannot be undone';

  @override
  String get settingsClearDataConfirm =>
      'Are you sure you want to delete all data?';

  @override
  String get settingsClearDone => 'All data cleared';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get emptyTransactionsTitle => 'No transactions';

  @override
  String get emptyTransactionsSubtitle =>
      'Add your first income or expense\nby tapping the button below';

  @override
  String get emptyReportsTitle => 'No data';

  @override
  String get emptyReportsSubtitle =>
      'No transactions found for selected period';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonAdd => 'Add';

  @override
  String get buttonClear => 'Clear';

  @override
  String get errorAmountEmpty => 'Please enter an amount';

  @override
  String get errorAmountZero => 'Amount must be greater than 0';

  @override
  String get errorCategoryEmpty => 'Please select a category';

  @override
  String get errorSaveTransaction => 'Failed to save transaction';

  @override
  String get errorDeleteTransaction => 'Failed to delete transaction';

  @override
  String get errorGeneral => 'Something went wrong';
}
