import 'package:flutter/material.dart';
import '../models/category.dart';

const List<Category> defaultCategories = [
  Category(id: 'refrigerated', name: '冷蔵', icon: '🥬', color: Color(0xFF4CAF50)),
  Category(id: 'frozen', name: '冷凍', icon: '🧊', color: Color(0xFF2196F3)),
  Category(id: 'pantry', name: '常温', icon: '🥫', color: Color(0xFFFF9800)),
];

const List<SubCategory> defaultSubCategories = [
  // 冷蔵
  SubCategory(id: 'meat', name: '肉類', icon: '🥩', parentCategoryId: 'refrigerated'),
  SubCategory(id: 'fish', name: '魚介類', icon: '🐟', parentCategoryId: 'refrigerated'),
  SubCategory(id: 'vegetable', name: '野菜', icon: '🥬', parentCategoryId: 'refrigerated'),
  SubCategory(id: 'fruit', name: 'フルーツ', icon: '🍎', parentCategoryId: 'refrigerated'),
  SubCategory(id: 'dairy', name: '乳製品', icon: '🥛', parentCategoryId: 'refrigerated'),
  SubCategory(id: 'other_ref', name: 'その他', icon: '🍱', parentCategoryId: 'refrigerated'),
  // 冷凍
  SubCategory(id: 'frozen_meat', name: '冷凍肉', icon: '🍖', parentCategoryId: 'frozen'),
  SubCategory(id: 'frozen_fish', name: '冷凍魚', icon: '🦐', parentCategoryId: 'frozen'),
  SubCategory(id: 'frozen_veg', name: '冷凍野菜', icon: '🥦', parentCategoryId: 'frozen'),
  SubCategory(id: 'frozen_meal', name: '冷凍食品', icon: '🍕', parentCategoryId: 'frozen'),
  SubCategory(id: 'ice_cream', name: 'アイス', icon: '🍦', parentCategoryId: 'frozen'),
  SubCategory(id: 'other_frozen', name: 'その他', icon: '📦', parentCategoryId: 'frozen'),
  // 常温
  SubCategory(id: 'bread', name: 'パン類', icon: '🍞', parentCategoryId: 'pantry'),
  SubCategory(id: 'noodle', name: '麺類', icon: '🍜', parentCategoryId: 'pantry'),
  SubCategory(id: 'canned', name: '缶詰・瓶詰', icon: '🥫', parentCategoryId: 'pantry'),
  SubCategory(id: 'snack', name: 'お菓子', icon: '🍪', parentCategoryId: 'pantry'),
  SubCategory(id: 'seasoning', name: '調味料', icon: '🧂', parentCategoryId: 'pantry'),
  SubCategory(id: 'other_pantry', name: 'その他', icon: '🛒', parentCategoryId: 'pantry'),
];
