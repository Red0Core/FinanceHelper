import 'package:flutter/material.dart';
import 'package:finance_helper/data/database.dart';
import 'package:finance_helper/data/models/category.dart';

/// Показывает bottom sheet для выбора категории/подкатегории
/// Возвращает выбранную категорию или null, если выбор был отменен
Future<CategoryInterface?> showCategoryBottomSheet(
  BuildContext context, {
  CategoryInterface? initialSelected,
}) async {
  // Загружаем категории и подкатегории
  final categories = await AppDatabase.instance.categoryDao.getAllCategories();
  final subcategories = await AppDatabase.instance.categoryDao.getAllSubcategories();
  
  // Группируем подкатегории по categoryId для быстрого доступа
  final Map<int, List<SubcategoryModel>> subcategoriesByCategory = {};
  for (final subcat in subcategories) {
    subcategoriesByCategory.putIfAbsent(subcat.categoryId, () => []).add(subcat);
  }

  // Определяем родительскую категорию, если initialSelected - это подкатегория
  int? initialExpandedCategoryId;
  if (initialSelected is SubcategoryModel) {
    initialExpandedCategoryId = initialSelected.categoryId;
  }
  return showModalBottomSheet<CategoryInterface>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          CategoryInterface? selectedCategory = initialSelected;
          
          // Множество для хранения идентификаторов раскрытых категорий
          final Set<int> expandedCategories = {};
          
          // Если initialSelected - подкатегория, добавляем её родительскую категорию
          // в множество раскрытых категорий
          if (initialExpandedCategoryId != null) {
            expandedCategories.add(initialExpandedCategoryId);
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Заголовок и панель закрытия (без изменений)
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Выберите категорию',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Список категорий
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final hasSubcategories = subcategoriesByCategory.containsKey(category.id) && 
                                              subcategoriesByCategory[category.id]!.isNotEmpty;
                        
                        // Проверяем, выбрана ли текущая категория
                        final bool isCategorySelected = selectedCategory == category;
                        
                        if (hasSubcategories) {
                          // Проверяем, должна ли быть эта категория изначально раскрыта
                          final bool isInitiallyExpanded = 
                              category.id != null && 
                              (expandedCategories.contains(category.id) || 
                              category.id == initialExpandedCategoryId);
                          
                          // Категория с подкатегориями
                          return ExpansionTile(
                            key: Key('cat_${category.id}'), // Ключ для стабильности ExpansionTile
                            initiallyExpanded: isInitiallyExpanded,
                            onExpansionChanged: (isExpanded) {
                              if (category.id != null) {
                                setState(() {
                                  if (isExpanded) {
                                    expandedCategories.add(category.id!);
                                  } else {
                                    expandedCategories.remove(category.id!);
                                  }
                                });
                              }
                            },
                            leading: Text(
                              category.emoji ?? '📁',
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: isCategorySelected ? FontWeight.bold : FontWeight.normal,
                                color: isCategorySelected ? Theme.of(context).primaryColor : null,
                              ),
                            ),
                            children: subcategoriesByCategory[category.id!]!.map((subcat) {
                              // Проверяем, выбрана ли текущая подкатегория
                              final bool isSubcatSelected = selectedCategory?.id == subcat.id && 
                                                            selectedCategory is SubcategoryModel;
                              
                              return ListTile(
                                leading: SizedBox(
                                  width: 40,
                                  child: Text(
                                    subcat.emoji ?? '📄',
                                    style: const TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                title: Text(subcat.name),
                                selected: isSubcatSelected,
                                selectedTileColor: Theme.of(context).primaryColor.withAlpha(20),
                                onTap: () {
                                  setState(() {
                                    selectedCategory = subcat;
                                  });
                                  Navigator.of(context).pop(subcat);
                                },
                              );
                            }).toList(),
                          );
                        } else {
                          // Категория без подкатегорий (без изменений)
                          return ListTile(
                            leading: Text(
                              category.emoji ?? '📁',
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(category.name),
                            selected: isCategorySelected,
                            selectedTileColor: Theme.of(context).primaryColor.withAlpha(20),
                            onTap: () {
                              setState(() {
                                selectedCategory = category;
                              });
                              Navigator.of(context).pop(category);
                            },
                          );
                        }
                      },
                    ),
                  ),
                  // Кнопка закрытия (без изменений)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Отмена'),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}