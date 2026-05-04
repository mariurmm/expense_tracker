import 'package:flutter/foundation.dart' hide Category;
import '../data/models/category_model.dart';
import '../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider(this._repository);

  final CategoryRepository _repository;

  List<Category> _categories = [];

  List<Category> get categories => List.unmodifiable(_categories);

  void loadCategories() {
    _categories = _repository.getAllCategories();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await _repository.addCategory(category);
    loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    loadCategories();
  }

  /// Looks up a category by name. Returns null when not found (e.g. legacy data).
  Category? findByName(String name) {
    for (final c in _categories) {
      if (c.name == name) return c;
    }
    return null;
  }
}
