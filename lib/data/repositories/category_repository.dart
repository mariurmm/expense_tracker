import 'package:injectable/injectable.dart';

import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

@lazySingleton
class CategoryRepository {
  const CategoryRepository({required CategoryLocalDatasource datasource})
      : _datasource = datasource;

  final CategoryLocalDatasource _datasource;

  Future<void> addCategory(Category category) => _datasource.put(category);

  Future<void> deleteCategory(String id) => _datasource.delete(id);

  List<Category> getAllCategories() =>
      _datasource.getAll()..sort((a, b) => a.name.compareTo(b.name));
}
