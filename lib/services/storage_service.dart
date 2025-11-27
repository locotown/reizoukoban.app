import 'dart:convert';
import 'dart:html' as html;
import '../models/food_item.dart';
import '../models/food_template.dart';

class StorageService {
  static const String _foodKey = 'fresh_alert_foods';
  static const String _customTemplateKey = 'fresh_alert_custom_templates';

  static List<FoodItem> loadFoods() {
    final data = html.window.localStorage[_foodKey];
    if (data == null || data.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => FoodItem.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static void saveFoods(List<FoodItem> foods) {
    final jsonList = foods.map((f) => f.toJson()).toList();
    html.window.localStorage[_foodKey] = jsonEncode(jsonList);
  }

  static List<FoodTemplate> loadCustomTemplates() {
    final data = html.window.localStorage[_customTemplateKey];
    if (data == null || data.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => FoodTemplate.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static void saveCustomTemplates(List<FoodTemplate> templates) {
    final jsonList = templates.map((t) => t.toJson()).toList();
    html.window.localStorage[_customTemplateKey] = jsonEncode(jsonList);
  }
}
