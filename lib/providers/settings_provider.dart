import 'package:flutter/foundation.dart';
import '../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._repository);

  final SettingsRepository _repository;

  String _userName = '';
  String _currencySymbol = '₸';
  String _currencyLocale = 'ru_RU';

  String get userName => _userName;
  String get currencySymbol => _currencySymbol;
  String get currencyLocale => _currencyLocale;

  void load() {
    _userName = _repository.userName;
    _currencySymbol = _repository.currencySymbol;
    _currencyLocale = _repository.currencyLocale;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    await _repository.setUserName(name);
    _userName = name;
    notifyListeners();
  }

  Future<void> setCurrency({
    required String symbol,
    required String locale,
  }) async {
    await _repository.setCurrencySymbol(symbol);
    await _repository.setCurrencyLocale(locale);
    _currencySymbol = symbol;
    _currencyLocale = locale;
    notifyListeners();
  }
}
