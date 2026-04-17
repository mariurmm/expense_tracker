import '../datasources/settings_local_datasource.dart';

class SettingsRepository {
  final SettingsLocalDatasource _datasource;

  SettingsRepository({required SettingsLocalDatasource datasource})
      : _datasource = datasource;

  String get userName =>
      _datasource.get('userName', defaultValue: '');
  String get currencySymbol =>
      _datasource.get('currencySymbol', defaultValue: '₸');
  String get currencyLocale =>
      _datasource.get('currencyLocale', defaultValue: 'ru_RU');

  Future<void> setUserName(String name) =>
      _datasource.put('userName', name);
  Future<void> setCurrencySymbol(String symbol) =>
      _datasource.put('currencySymbol', symbol);
  Future<void> setCurrencyLocale(String locale) =>
      _datasource.put('currencyLocale', locale);
}
