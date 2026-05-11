import 'package:injectable/injectable.dart';

import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';
import '../models/default_categories.dart';

@lazySingleton
class CategoryRepository {
  const CategoryRepository({required CategoryLocalDatasource datasource})
      : _datasource = datasource;

  final CategoryLocalDatasource _datasource;

  Future<void> addCategory(Category category) => _datasource.put(category);

  Future<void> deleteCategory(String id) => _datasource.delete(id);

  List<Category> getAllCategories() =>
      _datasource.getAll()..sort((a, b) => a.name.compareTo(b.name));

  Future<void> seedDefaultCategoriesIfNeeded() async {
    final existing = {for (final c in _datasource.getAll()) c.id: c};
    for (final def in defaultCategories) {
      final stored = existing[def.id];
      if (stored == null || stored.nameKey.isEmpty) {
        await _datasource.put(def);
      }
    }
  }

  Future<void> clearAndReseed() async {
    await _datasource.clear();
    for (final def in defaultCategories) {
      await _datasource.put(def);
    }
  }
}
