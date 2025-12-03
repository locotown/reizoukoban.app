import 'dart:convert';
import 'dart:html' as html;
import '../models/food_item.dart';
import '../models/food_template.dart';
import '../models/stock_item.dart';
import '../supabase_config.dart';

class StorageService {
  // ユーザーIDをキーに含めることで、ユーザーごとにデータを分離
  static String _getUserKey(String baseKey) {
    final userId = supabase.auth.currentUser?.id ?? 'anonymous';
    return '${baseKey}_$userId';
  }

  static String get _foodKey => _getUserKey('fresh_alert_foods');
  static String get _customTemplateKey => _getUserKey('fresh_alert_custom_templates');
  static String get _stockKey => _getUserKey('fresh_alert_stocks');

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

  // ストック管理機能
  static List<StockItem> loadStocks() {
    final data = html.window.localStorage[_stockKey];
    if (data == null || data.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((json) => StockItem.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static void saveStocks(List<StockItem> stocks) {
    final jsonList = stocks.map((s) => s.toJson()).toList();
    html.window.localStorage[_stockKey] = jsonEncode(jsonList);
  }

  /// ユーザーのローカルストレージデータを全て削除
  /// ログアウト時に呼び出すことで、データ漏洩を防ぐ
  static void clearUserData() {
    try {
      // 現在のユーザーIDを取得
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // ユーザー固有のキーを削除
      final keysToRemove = [
        'fresh_alert_foods_$userId',
        'fresh_alert_custom_templates_$userId',
        'fresh_alert_stocks_$userId',
      ];

      for (final key in keysToRemove) {
        html.window.localStorage.remove(key);
      }
    } catch (e) {
      // エラーが発生しても処理を続行
      print('ローカルストレージクリアエラー: $e');
    }
  }

  /// 全てのユーザーのローカルストレージデータを削除（開発用）
  /// 注意: 本番環境では使用しないでください
  static void clearAllData() {
    try {
      final keysToRemove = <String>[];
      
      // 全てのキーをチェック
      for (var i = 0; i < html.window.localStorage.length; i++) {
        final key = html.window.localStorage.keys.elementAt(i);
        if (key.startsWith('fresh_alert_')) {
          keysToRemove.add(key);
        }
      }

      // 削除
      for (final key in keysToRemove) {
        html.window.localStorage.remove(key);
      }
    } catch (e) {
      print('全ローカルストレージクリアエラー: $e');
    }
  }

  /// 古いキー（ユーザーID無し）のデータを削除
  /// マイグレーション用：ユーザーID分離実装前のデータをクリア
  static void clearLegacyData() {
    try {
      final legacyKeys = [
        'fresh_alert_foods',
        'fresh_alert_custom_templates',
        'fresh_alert_stocks',
      ];

      for (final key in legacyKeys) {
        html.window.localStorage.remove(key);
      }
    } catch (e) {
      print('レガシーデータクリアエラー: $e');
    }
  }
}
