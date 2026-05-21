import 'package:expense_tracker/core/constants/currencies.dart';
import 'package:flutter/material.dart';

import '../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._repository);

  final SettingsRepository _repository;

  String _userName = '';
  String _currencyCode = 'KZT';
  Locale _locale = const Locale('ru');
  ThemeMode _themeMode = ThemeMode.system;

  String get userName => _userName;
  String get currencyCode => _currencyCode;
  String get currencySymbol => currencyByCode(_currencyCode).symbol;
  String get currencyLocale => currencyByCode(_currencyCode).locale;
  String get currencyName => currencyByCode(_currencyCode).name;
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  void load() {
    _userName = _repository.userName;
    _currencyCode = _repository.currencyCode;
    _locale = Locale(_repository.locale);
    _themeMode = _themeModeFromString(_repository.themeMode);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    await _repository.setUserName(name);
    _userName = name;
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    await _repository.setCurrencyCode(code);
    _currencyCode = code;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    await _repository.setLocale(locale.languageCode);
    _locale = locale;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _repository.setThemeMode(_themeModeToString(mode));
    _themeMode = mode;
    notifyListeners();
  }

  static ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
