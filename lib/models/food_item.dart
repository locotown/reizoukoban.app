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
    'categoryId': categoryId,
    'expirationDate': expirationDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'],
    name: json['name'],
    icon: json['icon'] ?? '🍽️',
    categoryId: json['categoryId'],
    expirationDate: DateTime.parse(json['expirationDate']),
    createdAt: DateTime.parse(json['createdAt']),
  );

  /// Supabaseのデータからオブジェクトを作成
  factory FoodItem.fromSupabase(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'] ?? '',
      icon: json['icon'] ?? '🍽️',
      categoryId: json['category'] ?? '',
      expirationDate: json['expiry_date'] != null 
          ? DateTime.parse(json['expiry_date'])
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
