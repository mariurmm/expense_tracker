import 'package:injectable/injectable.dart';

import '../datasources/settings_local_datasource.dart';

@lazySingleton
class SettingsRepository {
  const SettingsRepository({required SettingsLocalDatasource datasource})
      : _datasource = datasource;

  final SettingsLocalDatasource _datasource;

  String get userName =>
      _datasource.get('userName', defaultValue: '');
  String get currencySymbol =>
      _datasource.get('currencySymbol', defaultValue: '₸');
  String get currencyLocale =>
      _datasource.get('currencyLocale', defaultValue: 'ru_RU');
  String get locale =>
      _datasource.get('locale', defaultValue: 'ru');

  Future<void> setUserName(String name) =>
      _datasource.put('userName', name);
  Future<void> setCurrencySymbol(String symbol) =>
      _datasource.put('currencySymbol', symbol);
  Future<void> setCurrencyLocale(String locale) =>
      _datasource.put('currencyLocale', locale);
  Future<void> setLocale(String languageCode) =>
      _datasource.put('locale', languageCode);
}
