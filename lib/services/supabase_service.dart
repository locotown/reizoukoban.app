import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/food_item.dart';
import '../models/food_template.dart';
import '../models/stock_item.dart';
import '../supabase_config.dart';

/// Supabaseデータ同期サービス
class SupabaseService {
  final _supabase = supabase;

  // ===== Foods (食材) =====

  /// 食材一覧を取得
  Future<List<FoodItem>> getFoods() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('foods')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => FoodItem.fromSupabase(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ getFoods error: $e');
      }
      return [];
    }
  }

  /// 食材を追加
  Future<bool> addFood(FoodItem food) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('foods').insert({
        'user_id': userId,
        'name': food.name,
        'icon': food.icon,
        'expiry_date': food.expiryDate?.toIso8601String(),
        'category': food.category,
        'memo': food.memo,
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ addFood error: $e');
      }
      return false;
    }
  }

  /// 食材を更新
  Future<bool> updateFood(FoodItem food) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('foods').update({
        'name': food.name,
        'icon': food.icon,
        'expiry_date': food.expiryDate?.toIso8601String(),
        'category': food.category,
        'memo': food.memo,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', food.id).eq('user_id', userId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ updateFood error: $e');
      }
      return false;
    }
  }

  /// 食材を削除
  Future<bool> deleteFood(String foodId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from('foods')
          .delete()
          .eq('id', foodId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ deleteFood error: $e');
      }
      return false;
    }
  }

  /// 食材のリアルタイム変更を監視
  RealtimeChannel watchFoods(Function(List<FoodItem>) onUpdate) {
    final userId = _supabase.auth.currentUser?.id;
    
    final channel = _supabase
        .channel('foods_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'foods',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            // データ変更時に最新データを取得
            final foods = await getFoods();
            onUpdate(foods);
          },
        )
        .subscribe();

    return channel;
  }

  // ===== Stocks (ストック) =====

  /// ストック一覧を取得
  Future<List<StockItem>> getStocks() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('stocks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => StockItem.fromSupabase(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ getStocks error: $e');
      }
      return [];
    }
  }

  /// ストックを追加
  Future<bool> addStock(StockItem stock) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('stocks').insert({
        'user_id': userId,
        'name': stock.name,
        'icon': stock.icon,
        'category_id': stock.categoryId,
        'status': stock.status.name,
        'memo': stock.memo,
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ addStock error: $e');
      }
      return false;
    }
  }

  /// ストックを更新
  Future<bool> updateStock(StockItem stock) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('stocks').update({
        'name': stock.name,
        'icon': stock.icon,
        'category_id': stock.categoryId,
        'status': stock.status.name,
        'memo': stock.memo,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', stock.id).eq('user_id', userId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ updateStock error: $e');
      }
      return false;
    }
  }

  /// ストックを削除
  Future<bool> deleteStock(String stockId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from('stocks')
          .delete()
          .eq('id', stockId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ deleteStock error: $e');
      }
      return false;
    }
  }

  /// ストックのリアルタイム変更を監視
  RealtimeChannel watchStocks(Function(List<StockItem>) onUpdate) {
    final userId = _supabase.auth.currentUser?.id;
    
    final channel = _supabase
        .channel('stocks_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stocks',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            // データ変更時に最新データを取得
            final stocks = await getStocks();
            onUpdate(stocks);
          },
        )
        .subscribe();

    return channel;
  }

  // ===== Custom Templates (カスタムテンプレート) =====

  /// カスタムテンプレート一覧を取得
  Future<List<FoodTemplate>> getCustomTemplates() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('custom_templates')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => FoodTemplate.fromSupabase(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ getCustomTemplates error: $e');
      }
      return [];
    }
  }

  /// カスタムテンプレートを追加
  Future<bool> addCustomTemplate(FoodTemplate template) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase.from('custom_templates').insert({
        'user_id': userId,
        'name': template.name,
        'icon': template.icon,
        'category': template.category,
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ addCustomTemplate error: $e');
      }
      return false;
    }
  }

  /// カスタムテンプレートを削除
  Future<bool> deleteCustomTemplate(String templateId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from('custom_templates')
          .delete()
          .eq('id', templateId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ deleteCustomTemplate error: $e');
      }
      return false;
    }
  }

  /// カスタムテンプレートのリアルタイム変更を監視
  RealtimeChannel watchCustomTemplates(Function(List<FoodTemplate>) onUpdate) {
    final userId = _supabase.auth.currentUser?.id;
    
    final channel = _supabase
        .channel('custom_templates_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'custom_templates',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            // データ変更時に最新データを取得
            final templates = await getCustomTemplates();
            onUpdate(templates);
          },
        )
        .subscribe();

    return channel;
  }

  // ===== ユーティリティ =====

  /// チャンネル購読解除
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _supabase.removeChannel(channel);
  }
}
