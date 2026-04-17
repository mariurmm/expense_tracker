import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final CategoryLocalDatasource _datasource;

  CategoryRepository({required CategoryLocalDatasource datasource})
      : _datasource = datasource;

  Future<void> addCategory(Category category) => _datasource.put(category);

  Future<void> deleteCategory(String id) => _datasource.delete(id);

  List<Category> getAllCategories() =>
      _datasource.getAll()..sort((a, b) => a.name.compareTo(b.name));
}
