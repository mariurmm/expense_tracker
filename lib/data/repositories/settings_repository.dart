import 'package:injectable/injectable.dart';

import '../datasources/settings_local_datasource.dart';

@lazySingleton
class SettingsRepository {
  const SettingsRepository({required SettingsLocalDatasource datasource})
      : _datasource = datasource;

  final SettingsLocalDatasource _datasource;

  String get userName => _datasource.get('userName', defaultValue: '');
  String get currencyCode =>
      _datasource.get('currencyCode', defaultValue: 'KZT');
  String get locale => _datasource.get('locale', defaultValue: 'ru');
  String get themeMode =>
      _datasource.get('themeMode', defaultValue: 'system');

  Future<void> setUserName(String name) => _datasource.put('userName', name);
  Future<void> setCurrencyCode(String code) =>
      _datasource.put('currencyCode', code);
  Future<void> setLocale(String languageCode) =>
      _datasource.put('locale', languageCode);
  Future<void> setThemeMode(String mode) =>
      _datasource.put('themeMode', mode);
}
