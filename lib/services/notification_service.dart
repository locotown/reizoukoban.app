import 'dart:html' as html;
import '../models/food_item.dart';

class NotificationService {
  static Future<void> requestPermission() async {
    if (html.Notification.supported) {
      await html.Notification.requestPermission();
    }
  }

  static void showNotification(String title, String body) {
    if (html.Notification.supported &&
        html.Notification.permission == 'granted') {
      html.Notification(title, body: body, icon: '🚨');
    }
  }

  static void checkExpirations(List<FoodItem> foods) {
    final warnings = foods.where((f) => f.isWarning || f.isExpired).toList();
    if (warnings.isNotEmpty) {
      final expired = warnings.where((f) => f.isExpired).length;
      final warning = warnings.where((f) => f.isWarning).length;
      String message = '';
      if (expired > 0) message += '🚨 期限切れ: $expired件 ';
      if (warning > 0) message += '⚠️ 期限間近: $warning件';
      showNotification('冷蔵庫番アラート', message);
    }
  }
}
