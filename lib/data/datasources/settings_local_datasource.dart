import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SettingsLocalDatasource {
  static const String boxName = 'settings';

  Box<dynamic> get _box => Hive.box<dynamic>(boxName);

  T get<T>(String key, {required T defaultValue}) =>
      (_box.get(key, defaultValue: defaultValue) as T?) ?? defaultValue;

  Future<void> put(String key, dynamic value) => _box.put(key, value);
}
