import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';
import '../models/food_template.dart';
import '../models/stock_item.dart';
import 'auth_service.dart';

/// Firestoreデータ同期サービス
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  /// ユーザーIDを取得
  String? get _userId => _authService.userId;

  /// ユーザーのドキュメント参照を取得
  DocumentReference? get _userDoc {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId);
  }

  // ========== 食材データ (Foods) ==========

  /// 食材データを保存
  Future<void> saveFoods(List<FoodItem> foods) async {
    if (_userId == null) throw '認証が必要です';

    final batch = _firestore.batch();
    final foodsCollection = _userDoc!.collection('foods');

    // 既存データを削除
    final existingDocs = await foodsCollection.get();
    for (var doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }

    // 新しいデータを追加
    for (var food in foods) {
      batch.set(foodsCollection.doc(food.id), food.toJson());
    }

    await batch.commit();
  }

  /// 食材データをリアルタイムで監視
  Stream<List<FoodItem>> watchFoods() {
    if (_userId == null) return Stream.value([]);

    return _userDoc!
        .collection('foods')
        .orderBy('added_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodItem.fromJson(doc.data()))
          .toList();
    });
  }

  /// 食材データを読み込み
  Future<List<FoodItem>> loadFoods() async {
    if (_userId == null) return [];

    final snapshot = await _userDoc!
        .collection('foods')
        .orderBy('added_at', descending: true)
        .get();

    return snapshot.docs.map((doc) => FoodItem.fromJson(doc.data())).toList();
  }

  // ========== カスタムテンプレート ==========

  /// カスタムテンプレートを保存
  Future<void> saveCustomTemplates(List<FoodTemplate> templates) async {
    if (_userId == null) throw '認証が必要です';

    final batch = _firestore.batch();
    final templatesCollection = _userDoc!.collection('custom_templates');

    // 既存データを削除
    final existingDocs = await templatesCollection.get();
    for (var doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }

    // 新しいデータを追加
    for (var template in templates) {
      batch.set(templatesCollection.doc(template.id), template.toJson());
    }

    await batch.commit();
  }

  /// カスタムテンプレートをリアルタイムで監視
  Stream<List<FoodTemplate>> watchCustomTemplates() {
    if (_userId == null) return Stream.value([]);

    return _userDoc!
        .collection('custom_templates')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodTemplate.fromJson(doc.data()))
          .toList();
    });
  }

  /// カスタムテンプレートを読み込み
  Future<List<FoodTemplate>> loadCustomTemplates() async {
    if (_userId == null) return [];

    final snapshot =
        await _userDoc!.collection('custom_templates').orderBy('name').get();

    return snapshot.docs
        .map((doc) => FoodTemplate.fromJson(doc.data()))
        .toList();
  }

  // ========== ストックデータ (Stocks) ==========

  /// ストックデータを保存
  Future<void> saveStocks(List<StockItem> stocks) async {
    if (_userId == null) throw '認証が必要です';

    final batch = _firestore.batch();
    final stocksCollection = _userDoc!.collection('stocks');

    // 既存データを削除
    final existingDocs = await stocksCollection.get();
    for (var doc in existingDocs.docs) {
      batch.delete(doc.reference);
    }

    // 新しいデータを追加
    for (var stock in stocks) {
      batch.set(stocksCollection.doc(stock.id), stock.toJson());
    }

    await batch.commit();
  }

  /// ストックデータをリアルタイムで監視
  Stream<List<StockItem>> watchStocks() {
    if (_userId == null) return Stream.value([]);

    return _userDoc!
        .collection('stocks')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StockItem.fromJson(doc.data()))
          .toList();
    });
  }

  /// ストックデータを読み込み
  Future<List<StockItem>> loadStocks() async {
    if (_userId == null) return [];

    final snapshot =
        await _userDoc!.collection('stocks').orderBy('name').get();

    return snapshot.docs
        .map((doc) => StockItem.fromJson(doc.data()))
        .toList();
  }

  // ========== データ同期 ==========

  /// ローカルデータをFirestoreにアップロード
  Future<void> uploadLocalData({
    required List<FoodItem> foods,
    required List<FoodTemplate> customTemplates,
    required List<StockItem> stocks,
  }) async {
    if (_userId == null) throw '認証が必要です';

    await Future.wait([
      saveFoods(foods),
      saveCustomTemplates(customTemplates),
      saveStocks(stocks),
    ]);
  }

  /// Firestoreデータをダウンロード
  Future<Map<String, dynamic>> downloadCloudData() async {
    if (_userId == null) throw '認証が必要です';

    final results = await Future.wait([
      loadFoods(),
      loadCustomTemplates(),
      loadStocks(),
    ]);

    return {
      'foods': results[0] as List<FoodItem>,
      'customTemplates': results[1] as List<FoodTemplate>,
      'stocks': results[2] as List<StockItem>,
    };
  }
}
