/// ストックアイテムのステータス
enum StockStatus {
  sufficient,  // 十分
  low,         // 残りわずか
  empty,       // 切れた
}

/// ストックアイテムモデル
class StockItem {
  final String id;
  final String name;
  final String icon;
  final String categoryId;
  final StockStatus status;
  final String? memo;  // 購入メモ（メーカーなど）
  final DateTime createdAt;
  final DateTime updatedAt;

  StockItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.categoryId,
    required this.status,
    this.memo,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// ステータスに応じた表示テキスト
  String get statusText {
    switch (status) {
      case StockStatus.sufficient:
        return '十分';
      case StockStatus.low:
        return '残りわずか';
      case StockStatus.empty:
        return '切れた';
    }
  }

  /// ステータスに応じたアイコン
  String get statusIcon {
    switch (status) {
      case StockStatus.sufficient:
        return '🟢';
      case StockStatus.low:
        return '🟡';
      case StockStatus.empty:
        return '🔴';
    }
  }

  /// 買い物リストに表示すべきか
  bool get needsToBuy => status == StockStatus.low || status == StockStatus.empty;

  /// 緊急で必要か（切れた状態）
  bool get isUrgent => status == StockStatus.empty;

  /// copyWithメソッド
  StockItem copyWith({
    String? id,
    String? name,
    String? icon,
    String? categoryId,
    StockStatus? status,
    String? memo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockItem(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// JSONからの変換
  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      categoryId: json['categoryId'] as String,
      status: StockStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StockStatus.sufficient,
      ),
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
      'status': status.name,
      'memo': memo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Supabaseのデータからオブジェクトを作成
  factory StockItem.fromSupabase(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? '📦',
      categoryId: json['category_id'] as String? ?? '',
      status: StockStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StockStatus.sufficient,
      ),
      memo: json['memo'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
