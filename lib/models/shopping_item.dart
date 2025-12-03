/// 買い物リストアイテムのソース（どこから追加されたか）
enum ShoppingSource {
  stock,    // ストックから追加
  food,     // 食材から追加
  manual,   // 手動で追加
}

/// 買い物リストアイテムモデル
class ShoppingItem {
  final String id;
  final String name;
  final String icon;
  final String categoryId;
  final bool isPurchased;         // 購入済みフラグ
  final ShoppingSource source;    // 追加元
  final String? sourceId;         // 元のアイテムID（food_id または stock_id）
  final String? memo;             // メモ
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.categoryId,
    this.isPurchased = false,
    this.source = ShoppingSource.manual,
    this.sourceId,
    this.memo,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 緊急度（ストックから追加された「切れた」アイテム）
  bool get isUrgent => source == ShoppingSource.stock && sourceId != null;

  /// copyWithメソッド
  ShoppingItem copyWith({
    String? id,
    String? name,
    String? icon,
    String? categoryId,
    bool? isPurchased,
    ShoppingSource? source,
    String? sourceId,
    String? memo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      categoryId: categoryId ?? this.categoryId,
      isPurchased: isPurchased ?? this.isPurchased,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// JSONからの変換
  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      categoryId: json['categoryId'] as String,
      isPurchased: json['isPurchased'] as bool? ?? false,
      source: ShoppingSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => ShoppingSource.manual,
      ),
      sourceId: json['sourceId'] as String?,
      memo: json['memo'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// JSONへの変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'categoryId': categoryId,
      'isPurchased': isPurchased,
      'source': source.name,
      'sourceId': sourceId,
      'memo': memo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Supabaseのデータからオブジェクトを作成
  factory ShoppingItem.fromSupabase(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '🛒',
      categoryId: json['category_id'] as String? ?? '',
      isPurchased: json['is_purchased'] as bool? ?? false,
      source: ShoppingSource.values.firstWhere(
        (e) => e.name == (json['source'] as String? ?? 'manual'),
        orElse: () => ShoppingSource.manual,
      ),
      sourceId: json['source_id'] as String?,
      memo: json['memo'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Supabase用のデータに変換
  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'category_id': categoryId,
      'is_purchased': isPurchased,
      'source': source.name,
      'source_id': sourceId,
      'memo': memo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
