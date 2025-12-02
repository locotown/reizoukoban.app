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

  /// Supabaseのデータからオブジェクトを作成
  factory FoodTemplate.fromSupabase(Map<String, dynamic> json) {
    return FoodTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '🍽️',
      categoryId: json['category'] as String? ?? '',
      subCategoryId: 'custom',  // カスタムテンプレート用
      defaultDays: 7,  // デフォルト7日
    );
  }

  // 互換性のためのゲッター
  String get category => categoryId;
}
