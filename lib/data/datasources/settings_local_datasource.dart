import 'package:hive_flutter/hive_flutter.dart';

class SettingsLocalDatasource {
  static const String boxName = 'settings';

  Box get _box => Hive.box(boxName);

  T get<T>(String key, {required T defaultValue}) =>
      (_box.get(key, defaultValue: defaultValue) as T?) ?? defaultValue;

  Future<void> put(String key, dynamic value) => _box.put(key, value);
}
