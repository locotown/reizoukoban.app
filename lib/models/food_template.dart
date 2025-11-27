class FoodTemplate {
  final String id;
  final String name;
  final String icon;
  final String categoryId;
  final String subCategoryId;
  final int defaultDays;

  const FoodTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.categoryId,
    required this.subCategoryId,
    required this.defaultDays,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'categoryId': categoryId,
    'subCategoryId': subCategoryId,
    'defaultDays': defaultDays,
  };

  factory FoodTemplate.fromJson(Map<String, dynamic> json) => FoodTemplate(
    id: json['id'],
    name: json['name'],
    icon: json['icon'],
    categoryId: json['categoryId'],
    subCategoryId: json['subCategoryId'] ?? 'other',
    defaultDays: json['defaultDays'],
  );
}
