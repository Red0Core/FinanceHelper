sealed class CategoryInterface {
  int? get id;
  String get name;
  String? get emoji;
}

class CategoryModel implements CategoryInterface {
  @override
  final int? id;
  @override
  final String name;
  @override
  final String? emoji;

  CategoryModel({this.id, required this.name, this.emoji});

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      emoji: map['emoji']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji
    };
  }
}

class SubcategoryModel implements CategoryInterface {
  @override
  final int? id;
  final int categoryId;
  @override
  final String name;
  @override
  final String? emoji;

  SubcategoryModel({this.id, required this.categoryId, required this.name, this.emoji});

  factory SubcategoryModel.fromMap(Map<String, dynamic> map) {
    return SubcategoryModel(
      id: map['id'],
      categoryId: map['category_id'],
      name: map['name'],
      emoji: map['emoji']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'emoji': emoji
    };
  }
}