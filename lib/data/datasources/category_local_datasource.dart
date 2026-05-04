import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:injectable/injectable.dart';

import '../models/category_model.dart';

@lazySingleton
class CategoryLocalDatasource {
  static const String boxName = 'categories';

  Box<Category> get _box => Hive.box<Category>(boxName);

  bool get isEmpty => _box.isEmpty;

  Future<void> put(Category category) => _box.put(category.id, category);

  Future<void> delete(String id) => _box.delete(id);

  List<Category> getAll() => _box.values.toList();
}
