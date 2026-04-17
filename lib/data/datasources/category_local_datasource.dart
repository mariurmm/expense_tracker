import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';

class CategoryLocalDatasource {
  static const String boxName = 'categories';

  Box<Category> get _box => Hive.box<Category>(boxName);

  bool get isEmpty => _box.isEmpty;

  Future<void> put(Category category) => _box.put(category.id, category);

  Future<void> delete(String id) => _box.delete(id);

  List<Category> getAll() => _box.values.toList();
}
