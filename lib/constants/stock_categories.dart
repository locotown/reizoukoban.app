import 'package:flutter/material.dart';

/// ストックカテゴリ
class StockCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;

  const StockCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// デフォルトのストックカテゴリ一覧
const List<StockCategory> defaultStockCategories = [
  StockCategory(
    id: 'daily',
    name: '日用品',
    icon: '🧻',
    color: Color(0xFF8D6E63),  // ブラウン
  ),
  StockCategory(
    id: 'bath',
    name: 'バス・洗面',
    icon: '🧴',
    color: Color(0xFF26C6DA),  // シアン
  ),
  StockCategory(
    id: 'cleaning',
    name: '掃除・洗濯',
    icon: '🧹',
    color: Color(0xFF66BB6A),  // グリーン
  ),
  StockCategory(
    id: 'food_stock',
    name: '食品ストック',
    icon: '🍚',
    color: Color(0xFFFFB74D),  // オレンジ
  ),
  StockCategory(
    id: 'medicine',
    name: '医薬品',
    icon: '💊',
    color: Color(0xFFEF5350),  // レッド
  ),
  StockCategory(
    id: 'other',
    name: 'その他',
    icon: '📦',
    color: Color(0xFF78909C),  // グレー
  ),
];

/// デフォルトのストックテンプレート（よく使うアイテム）
class StockTemplate {
  final String id;
  final String name;
  final String icon;
  final String categoryId;

  const StockTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.categoryId,
  });
}

const List<StockTemplate> defaultStockTemplates = [
  // 日用品
  StockTemplate(id: 'toilet_paper', name: 'トイレットペーパー', icon: '🧻', categoryId: 'daily'),
  StockTemplate(id: 'tissue', name: 'ティッシュ', icon: '📦', categoryId: 'daily'),
  StockTemplate(id: 'garbage_bag', name: 'ゴミ袋', icon: '🗑️', categoryId: 'daily'),
  StockTemplate(id: 'wrap', name: 'ラップ', icon: '🌀', categoryId: 'daily'),
  StockTemplate(id: 'aluminum_foil', name: 'アルミホイル', icon: '🔲', categoryId: 'daily'),
  StockTemplate(id: 'ziplock', name: 'ジップロック', icon: '📦', categoryId: 'daily'),
  
  // バス・洗面
  StockTemplate(id: 'shampoo', name: 'シャンプー', icon: '🧴', categoryId: 'bath'),
  StockTemplate(id: 'conditioner', name: 'コンディショナー', icon: '🧴', categoryId: 'bath'),
  StockTemplate(id: 'body_soap', name: 'ボディソープ', icon: '🧼', categoryId: 'bath'),
  StockTemplate(id: 'face_wash', name: '洗顔料', icon: '🫧', categoryId: 'bath'),
  StockTemplate(id: 'toothpaste', name: '歯磨き粉', icon: '🪥', categoryId: 'bath'),
  StockTemplate(id: 'toothbrush', name: '歯ブラシ', icon: '🪥', categoryId: 'bath'),
  StockTemplate(id: 'razor', name: 'カミソリ', icon: '🪒', categoryId: 'bath'),
  
  // 掃除・洗濯
  StockTemplate(id: 'laundry_detergent', name: '洗濯洗剤', icon: '🧴', categoryId: 'cleaning'),
  StockTemplate(id: 'fabric_softener', name: '柔軟剤', icon: '🌸', categoryId: 'cleaning'),
  StockTemplate(id: 'dish_soap', name: '食器用洗剤', icon: '🧽', categoryId: 'cleaning'),
  StockTemplate(id: 'sponge', name: 'スポンジ', icon: '🧽', categoryId: 'cleaning'),
  StockTemplate(id: 'floor_cleaner', name: '床用洗剤', icon: '🧹', categoryId: 'cleaning'),
  StockTemplate(id: 'bleach', name: '漂白剤', icon: '🧪', categoryId: 'cleaning'),
  
  // 食品ストック
  StockTemplate(id: 'rice', name: 'お米', icon: '🍚', categoryId: 'food_stock'),
  StockTemplate(id: 'pasta', name: 'パスタ', icon: '🍝', categoryId: 'food_stock'),
  StockTemplate(id: 'soy_sauce', name: '醤油', icon: '🫗', categoryId: 'food_stock'),
  StockTemplate(id: 'miso', name: '味噌', icon: '🥣', categoryId: 'food_stock'),
  StockTemplate(id: 'cooking_oil', name: 'サラダ油', icon: '🫒', categoryId: 'food_stock'),
  StockTemplate(id: 'salt', name: '塩', icon: '🧂', categoryId: 'food_stock'),
  StockTemplate(id: 'sugar', name: '砂糖', icon: '🍬', categoryId: 'food_stock'),
  StockTemplate(id: 'instant_noodle', name: 'インスタント麺', icon: '🍜', categoryId: 'food_stock'),
  StockTemplate(id: 'canned_food', name: '缶詰', icon: '🥫', categoryId: 'food_stock'),
  StockTemplate(id: 'coffee', name: 'コーヒー', icon: '☕', categoryId: 'food_stock'),
  StockTemplate(id: 'tea', name: 'お茶', icon: '🍵', categoryId: 'food_stock'),
  
  // 医薬品
  StockTemplate(id: 'painkiller', name: '鎮痛剤', icon: '💊', categoryId: 'medicine'),
  StockTemplate(id: 'cold_medicine', name: '風邪薬', icon: '💊', categoryId: 'medicine'),
  StockTemplate(id: 'stomach_medicine', name: '胃腸薬', icon: '💊', categoryId: 'medicine'),
  StockTemplate(id: 'bandage', name: '絆創膏', icon: '🩹', categoryId: 'medicine'),
  StockTemplate(id: 'antiseptic', name: '消毒液', icon: '🧴', categoryId: 'medicine'),
  StockTemplate(id: 'eye_drops', name: '目薬', icon: '👁️', categoryId: 'medicine'),
  
  // その他
  StockTemplate(id: 'battery', name: '電池', icon: '🔋', categoryId: 'other'),
  StockTemplate(id: 'light_bulb', name: '電球', icon: '💡', categoryId: 'other'),
  StockTemplate(id: 'garbage_bag_large', name: '大型ゴミ袋', icon: '🗑️', categoryId: 'other'),
  StockTemplate(id: 'mask', name: 'マスク', icon: '😷', categoryId: 'other'),
];
