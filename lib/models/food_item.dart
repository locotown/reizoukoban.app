class FoodItem {
  final String id;
  final String name;
  final String icon;
  final String categoryId;
  final DateTime expirationDate;
  final DateTime createdAt;

  FoodItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.categoryId,
    required this.expirationDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get daysUntilExpiration =>
      expirationDate.difference(DateTime.now()).inDays;

  bool get isExpired => daysUntilExpiration < 0;
  bool get isWarning => daysUntilExpiration <= 3 && !isExpired;

  FoodItem copyWith({
    String? name,
    String? icon,
    String? categoryId,
    DateTime? expirationDate,
  }) {
    return FoodItem(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      categoryId: categoryId ?? this.categoryId,
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'category_id': categoryId,  // スネークケースに変更（バックエンドAPI対応）
    'expiration_date': expirationDate.toIso8601String(),  // スネークケースに変更
    'created_at': createdAt.toIso8601String(),  // スネークケースに変更
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'] ?? json['_id'] ?? '',
    name: json['name'] ?? '',
    icon: json['icon'] ?? '🍽️',
    categoryId: json['category_id'] ?? json['categoryId'] ?? '',  // 両方対応
    expirationDate: DateTime.parse(json['expiration_date'] ?? json['expirationDate'] ?? DateTime.now().toIso8601String()),  // 両方対応
    createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),  // 両方対応
  );

  /// Supabaseのデータからオブジェクトを作成
  factory FoodItem.fromSupabase(Map<String, dynamic> json) {
    // 後方互換性のため、両方のフィールド名をサポート
    final categoryId = json['category_id'] ?? json['category'] ?? '';
    final expirationDateStr = json['expiration_date'] ?? json['expiry_date'];
    
    return FoodItem(
      id: json['id'],
      name: json['name'] ?? '',
      icon: json['icon'] ?? '🍽️',
      categoryId: categoryId,
      expirationDate: expirationDateStr != null 
          ? DateTime.parse(expirationDateStr)
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  // 互換性のためのゲッター
  String get category => categoryId;
  DateTime? get expiryDate => expirationDate;
  String? get memo => null; // 将来的に追加予定
}
