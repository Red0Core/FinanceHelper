import 'package:flutter/material.dart';
import 'package:finance_helper/data/models/category.dart';
import 'package:finance_helper/features/category/show_category_bottom_sheet.dart';

class CategorySelector extends StatelessWidget {
  final CategoryInterface? selectedCategory;
  final void Function(CategoryInterface) onCategorySelected;
  final String label;
  final String placeholder;
  final BorderRadius borderRadius;
  final double elevation;
  
  const CategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
    this.label = 'Категория',
    this.placeholder = 'Выберите категорию',
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.elevation = 2,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final category = await showCategoryBottomSheet(
          context, 
          initialSelected: selectedCategory,
        );
        
        if (category != null) {
          onCategorySelected(category);
        }
      },
      borderRadius: borderRadius,
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (selectedCategory != null && selectedCategory!.emoji != null)
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    selectedCategory!.emoji!,
                    style: const TextStyle(fontSize: 24),
                  ),
                )
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.category, color: Colors.grey),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedCategory != null
                          ? selectedCategory!.name
                          : placeholder,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: selectedCategory != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}