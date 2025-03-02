import 'package:sqflite/sqflite.dart';
import 'package:finance_helper/data/models/category.dart';

class CategoryDao {
  final Database db;

  CategoryDao(this.db);

  Future<int> insertCategory(CategoryModel category) async {
    return await db.insert('categories', category.toMap());
  }

  Future<int> insertSubcategory(SubcategoryModel subcategory) async {
    return await db.insert('subcategories', subcategory.toMap());
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return CategoryModel.fromMap(maps[i]);
    });
  }

  Future<List<SubcategoryModel>> getAllSubcategories() async {
    final List<Map<String, dynamic>> maps = await db.query('subcategories');
    return List.generate(maps.length, (i) {
      return SubcategoryModel.fromMap(maps[i]);
    });
  }

  Future<List<SubcategoryModel>> getSubcategoriesByCategoryId(int categoryId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'subcategories',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) {
      return SubcategoryModel.fromMap(maps[i]);
    });
  }

  Future<CategoryModel> getCategoryByName(String name) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1
    );
    return CategoryModel.fromMap(maps.first);
  }

  Future<SubcategoryModel> getSubcategoryByName(String name) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'subcategories',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1
    );
    return SubcategoryModel.fromMap(maps.first);
  }
}