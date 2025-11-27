import 'package:flutter/material.dart';
import '../models/food_item.dart';

/// 日付フォーマットユーティリティ
class DateFormatter {
  /// 期限日を表示用文字列に変換
  static String formatExpirationDate(FoodItem food) {
    final date = food.expirationDate;
    return '${date.month}/${date.day}';
  }

  /// 残り日数を表示用文字列に変換
  static String formatDaysRemaining(FoodItem food) {
    if (food.isExpired) {
      return '期限切れ';
    } else if (food.daysUntilExpiration == 0) {
      return '今日まで';
    } else if (food.daysUntilExpiration == 1) {
      return '明日まで';
    } else {
      return 'あと${food.daysUntilExpiration}日';
    }
  }

  /// 残り日数に応じた色を取得
  static Color getDaysColor(FoodItem food) {
    if (food.isExpired) {
      return const Color(0xFFEF5350); // 赤
    } else if (food.isWarning) {
      return const Color(0xFFFFA726); // オレンジ
    } else {
      return const Color(0xFF66BB6A); // 緑
    }
  }
}
