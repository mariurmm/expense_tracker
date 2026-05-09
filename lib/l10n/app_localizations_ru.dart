// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Где деньги?';

  @override
  String get navHome => 'Главная';

  @override
  String get navTransactions => 'Транзакции';

  @override
  String get navReports => 'Отчёты';

  @override
  String get navSettings => 'Настройки';

  @override
  String get homeBalance => 'Текущий баланс';

  @override
  String get homeIncome => 'Доходы';

  @override
  String get homeExpense => 'Расходы';

  @override
  String get homeRecentTransactions => 'Последние транзакции';

  @override
  String get homeViewAll => 'Все';

  @override
  String get homeAddTransaction => 'Добавить';

  @override
  String get transactionIncome => 'Доход';

  @override
  String get transactionExpense => 'Расход';

  @override
  String get transactionAmount => 'Сумма';

  @override
  String get transactionCategory => 'Категория';

  @override
  String get transactionDate => 'Дата';

  @override
  String get transactionNote => 'Заметка (необязательно)';

  @override
  String get transactionNoteHint => 'Напр. Обед с коллегами';

  @override
  String get transactionSave => 'Сохранить';

  @override
  String get transactionDelete => 'Удалить';

  @override
  String get transactionDeleteConfirm => 'Транзакция удалена';

  @override
  String get transactionDeleteTitle => 'Удалить транзакцию';

  @override
  String get transactionDeleteMessage =>
      'Вы уверены, что хотите удалить эту транзакцию?';

  @override
  String get transactionAddTitle => 'Новая транзакция';

  @override
  String get categoryFood => 'Еда';

  @override
  String get categoryTransport => 'Транспорт';

  @override
  String get categorySalary => 'Зарплата';

  @override
  String get categoryShopping => 'Покупки';

  @override
  String get categoryHealth => 'Здоровье';

  @override
  String get categoryOther => 'Прочее';

  @override
  String get categoryAddNew => '+ Новая категория';

  @override
  String get categoryAddTitle => 'Новая категория';

  @override
  String get categoryName => 'Название категории';

  @override
  String get categoryColor => 'Цвет';

  @override
  String get categoryIcon => 'Иконка';

  @override
  String get categoryNew => 'Новая';

  @override
  String get reportsPeriodWeek => 'Неделя';

  @override
  String get reportsPeriodMonth => 'Месяц';

  @override
  String get reportsPeriodYear => 'Год';

  @override
  String get reportsExpensesByCategory => 'Расходы по категориям';

  @override
  String get reportsIncomeVsExpense => 'Доходы и расходы';

  @override
  String get reportsNoData => 'Нет данных';

  @override
  String get reportsNoDataSubtitle =>
      'За выбранный период транзакций не найдено';

  @override
  String get reportsTotal => 'Итого';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsProfile => 'Профиль';

  @override
  String get settingsYourName => 'Ваше имя';

  @override
  String get settingsEnterName => 'Введите ваше имя';

  @override
  String get settingsTapName => 'Нажмите, чтобы указать имя';

  @override
  String get settingsCurrency => 'Валюта';

  @override
  String get settingsSelectCurrency => 'Выберите валюту';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageRu => 'Русский';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsTheme => 'Оформление';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsExport => 'Экспорт в CSV';

  @override
  String get settingsExportSubtitle => 'Скачать все транзакции';

  @override
  String get settingsExportEmpty => 'Нет данных для экспорта';

  @override
  String get settingsExportError => 'Ошибка экспорта';

  @override
  String get settingsExportShareSubject => 'Мои финансы — экспорт';

  @override
  String get settingsExportShareText => 'Экспорт транзакций из «Где деньги?»';

  @override
  String get settingsClearData => 'Очистить все данные';

  @override
  String get settingsClearDataSubtitle => 'Это действие нельзя отменить';

  @override
  String get settingsClearDataConfirm =>
      'Вы уверены, что хотите удалить все данные?';

  @override
  String get settingsClearDone => 'Все данные удалены';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get settingsVersion => 'Версия';

  @override
  String get emptyTransactionsTitle => 'Нет транзакций';

  @override
  String get emptyTransactionsSubtitle =>
      'Добавьте первый доход или расход\nнажав кнопку ниже';

  @override
  String get emptyReportsTitle => 'Нет данных';

  @override
  String get emptyReportsSubtitle =>
      'За выбранный период транзакций не найдено';

  @override
  String get buttonSave => 'Сохранить';

  @override
  String get buttonCancel => 'Отмена';

  @override
  String get buttonConfirm => 'Подтвердить';

  @override
  String get buttonDelete => 'Удалить';

  @override
  String get buttonAdd => 'Добавить';

  @override
  String get buttonClear => 'Очистить';

  @override
  String get errorAmountEmpty => 'Введите сумму';

  @override
  String get errorAmountZero => 'Сумма должна быть больше нуля';

  @override
  String get errorCategoryEmpty => 'Выберите категорию';

  @override
  String get errorSaveTransaction => 'Не удалось сохранить транзакцию';

  @override
  String get errorDeleteTransaction => 'Не удалось удалить транзакцию';

  @override
  String get errorGeneral => 'Что-то пошло не так';
}
