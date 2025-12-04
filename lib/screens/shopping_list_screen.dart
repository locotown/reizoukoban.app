import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Models
import '../models/shopping_item.dart';
import '../models/stock_item.dart';
import '../models/food_item.dart';

// Services
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

/// 買い物リスト画面
class ShoppingListScreen extends StatefulWidget {
  final List<ShoppingItem> shoppingItems;
  final List<StockItem> stocks;
  final List<FoodItem> foods;
  final Function(List<ShoppingItem>) onShoppingItemsChanged;
  final Function(List<StockItem>) onStocksChanged;
  final Function(List<FoodItem>) onFoodsChanged;

  const ShoppingListScreen({
    super.key,
    required this.shoppingItems,
    required this.stocks,
    required this.foods,
    required this.onShoppingItemsChanged,
    required this.onStocksChanged,
    required this.onFoodsChanged,
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _supabaseService = SupabaseService();
  List<String> _selectedIds = [];

  List<ShoppingItem> get _shoppingItems => widget.shoppingItems;
  List<ShoppingItem> get _unpurchasedItems =>
      _shoppingItems.where((item) => !item.isPurchased).toList();
  List<ShoppingItem> get _purchasedItems =>
      _shoppingItems.where((item) => item.isPurchased).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Text('🛒', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              '買い物リスト',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        actions: [
          // 一括購入済みボタン
          if (_selectedIds.isNotEmpty)
            TextButton.icon(
              onPressed: _markSelectedAsPurchased,
              icon: const Icon(Icons.check_circle, size: 20),
              label: Text(
                '購入済み(${_selectedIds.length})',
                style: const TextStyle(fontSize: 14),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
              ),
            ),
          // 手動追加ボタン
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF3498DB)),
            onPressed: _showAddItemDialog,
          ),
        ],
      ),
      body: _unpurchasedItems.isEmpty && _purchasedItems.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 未購入アイテム
                  if (_unpurchasedItems.isNotEmpty) ...[
                    _buildSectionHeader('買う予定 (${_unpurchasedItems.length}件)', false),
                    ..._unpurchasedItems.map((item) => _buildShoppingItemCard(item)),
                  ],
                  
                  // 購入済みアイテム
                  if (_purchasedItems.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSectionHeader('購入済み (${_purchasedItems.length}件)', true),
                    ..._purchasedItems.map((item) => _buildPurchasedItemCard(item)),
                  ],
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  /// 空の状態
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          const Text(
            '買い物リストは空です',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'ストックや食材から追加するか\n右上の＋ボタンで手動追加できます',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF95A5A6),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// セクションヘッダー
  Widget _buildSectionHeader(String title, bool isPurchased) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Icon(
            isPurchased ? Icons.check_circle : Icons.shopping_cart,
            size: 20,
            color: isPurchased ? const Color(0xFF95A5A6) : const Color(0xFF3498DB),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isPurchased ? const Color(0xFF95A5A6) : const Color(0xFF2C3E50),
              ),
            ),
          ),
          // 購入済み一括削除ボタン
          if (isPurchased && _purchasedItems.isNotEmpty)
            TextButton.icon(
              onPressed: _deletePurchasedItems,
              icon: const Icon(Icons.delete_sweep, size: 18),
              label: const Text('一括削除', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE74C3C),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
        ],
      ),
    );
  }

  /// 買い物アイテムカード（未購入）- モバイル対応レイアウト
  Widget _buildShoppingItemCard(ShoppingItem item) {
    final isSelected = _selectedIds.contains(item.id);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedIds.remove(item.id);
            } else {
              _selectedIds.add(item.id);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 上段: チェックボックス + アイコン + 商品名 + 数量 + 削除
              Row(
                children: [
                  // チェックボックス
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedIds.add(item.id);
                          } else {
                            _selectedIds.remove(item.id);
                          }
                        });
                      },
                      activeColor: const Color(0xFF4CAF50),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // アイコン
                  Text(item.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  // 商品名 + 数量
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name.isNotEmpty ? item.name : '(名前なし)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.memo != null && item.memo!.isNotEmpty)
                          Text(
                            item.memo!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF95A5A6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // 削除ボタン
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 22),
                    color: const Color(0xFFE74C3C),
                    onPressed: () => _deleteItem(item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 下段: ソースバッジ + 数量コントロール
              Row(
                children: [
                  const SizedBox(width: 32), // チェックボックス分のスペース
                  // ソース表示
                  _buildSourceBadge(item.source),
                  const Spacer(),
                  // 数量コントロール
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 減少ボタン
                        InkWell(
                          onTap: () => _decreaseQuantity(item),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: item.quantity > 1 
                                  ? const Color(0xFFE74C3C).withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 18,
                              color: item.quantity > 1 
                                  ? const Color(0xFFE74C3C)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        // 数量表示
                        Container(
                          constraints: const BoxConstraints(minWidth: 40),
                          alignment: Alignment.center,
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                        // 増加ボタン
                        InkWell(
                          onTap: () => _increaseQuantity(item),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 購入済みアイテムカード - モバイル対応レイアウト
  Widget _buildPurchasedItemCard(ShoppingItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // チェックマーク
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 26,
            ),
            const SizedBox(width: 10),
            // アイコン
            Text(item.icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            // 商品名 + 数量
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.isNotEmpty ? item.name : '(名前なし)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF95A5A6),
                      decoration: TextDecoration.lineThrough,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${item.quantity}個',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFBDC3C7),
                    ),
                  ),
                ],
              ),
            ),
            // 削除ボタン
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 22),
              color: const Color(0xFFBDC3C7),
              onPressed: () => _deleteItem(item),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      ),
    );
  }

  /// ソースバッジ
  Widget _buildSourceBadge(ShoppingSource source) {
    String text;
    Color color;
    
    switch (source) {
      case ShoppingSource.stock:
        text = 'ストック';
        color = const Color(0xFF9B59B6);
        break;
      case ShoppingSource.food:
        text = '食材';
        color = const Color(0xFF3498DB);
        break;
      case ShoppingSource.manual:
        text = '手動';
        color = const Color(0xFF95A5A6);
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// 選択したアイテムを購入済みにする
  /// - ストック由来 → ストックに反映
  /// - 食材由来 → 購入済みにするのみ（ストックには追加しない）
  /// - 手動追加 → 購入済みにするのみ（ストックには追加しない）
  void _markSelectedAsPurchased() async {
    if (_selectedIds.isEmpty) return;

    final selectedItems = _shoppingItems
        .where((item) => _selectedIds.contains(item.id))
        .toList();

    print('🛒 [購入済み処理] 選択されたアイテム: ${selectedItems.length}件');

    // 1. 買い物リストを購入済みに更新
    final updatedShoppingItems = _shoppingItems.map((item) {
      if (_selectedIds.contains(item.id)) {
        return item.copyWith(isPurchased: true);
      }
      return item;
    }).toList();

    // 2. ソース別に処理を分岐
    final stockItems = selectedItems.where((item) => item.source == ShoppingSource.stock).toList();
    final foodItems = selectedItems.where((item) => item.source == ShoppingSource.food).toList();
    final manualItems = selectedItems.where((item) => item.source == ShoppingSource.manual).toList();

    print('📦 [購入済み処理] ストック由来: ${stockItems.length}件');
    print('🥬 [購入済み処理] 食材由来: ${foodItems.length}件');
    print('✍️ [購入済み処理] 手動追加: ${manualItems.length}件');

    final updatedStocks = List<StockItem>.from(widget.stocks);
    final updatedFoods = List<FoodItem>.from(widget.foods);
    int stocksAddedCount = 0;
    int foodsAddedCount = 0;
    
    // ストック由来のアイテム → ストックに反映
    for (final item in stockItems) {
      print('🔍 [購入済み処理] ストック処理中: ${item.name}');
      
      final existingStockIndex = updatedStocks.indexWhere(
        (stock) => stock.name.toLowerCase() == item.name.toLowerCase(),
      );

      if (existingStockIndex != -1) {
        print('✏️ [購入済み処理] 既存ストック更新: ${item.name}');
        final existingStock = updatedStocks[existingStockIndex];
        updatedStocks[existingStockIndex] = existingStock.copyWith(
          status: StockStatus.sufficient,
        );
        await _supabaseService.updateStock(updatedStocks[existingStockIndex]);
        stocksAddedCount++;
      } else {
        print('➕ [購入済み処理] 新規ストック作成: ${item.name}');
        
        final newStock = StockItem(
          id: const Uuid().v4(),
          name: item.name,
          icon: item.icon,
          categoryId: item.categoryId,
          status: StockStatus.sufficient,
          memo: item.memo,
        );
        updatedStocks.add(newStock);
        await _supabaseService.addStock(newStock);
        stocksAddedCount++;
      }
    }

    // 食材由来のアイテム → 食材リストに新規追加（数量分）
    for (final item in foodItems) {
      print('🥬 [購入済み処理] 食材処理中: ${item.name} x ${item.quantity}');
      
      // 数量分だけ新しい食材を追加
      for (int i = 0; i < item.quantity; i++) {
        // 新しい食材を作成（賞味期限は1週間後をデフォルト）
        final newFood = FoodItem(
          id: const Uuid().v4(),
          name: item.name,
          icon: item.icon,
          categoryId: _mapShoppingCategoryToFoodCategory(item.categoryId),
          expirationDate: DateTime.now().add(const Duration(days: 7)),
        );
        updatedFoods.add(newFood);
        await _supabaseService.addFood(newFood);
        foodsAddedCount++;
        print('➕ [購入済み処理] 食材追加 ${i + 1}/${item.quantity}: ${newFood.name}');
      }
    }

    // 手動追加のアイテム → 食材リストに新規追加（数量分）
    for (final item in manualItems) {
      print('✍️ [購入済み処理] 手動追加アイテム処理中: ${item.name} x ${item.quantity}');
      
      // 数量分だけ新しい食材を追加
      for (int i = 0; i < item.quantity; i++) {
        // 新しい食材を作成（賞味期限は1週間後をデフォルト）
        final newFood = FoodItem(
          id: const Uuid().v4(),
          name: item.name,
          icon: item.icon,
          categoryId: _mapShoppingCategoryToFoodCategory(item.categoryId),
          expirationDate: DateTime.now().add(const Duration(days: 7)),
        );
        updatedFoods.add(newFood);
        await _supabaseService.addFood(newFood);
        foodsAddedCount++;
        print('➕ [購入済み処理] 手動追加アイテムを食材に追加 ${i + 1}/${item.quantity}: ${newFood.name} (カテゴリ: ${newFood.categoryId})');
      }
    }

    // ストックが更新された場合のみ保存
    if (stocksAddedCount > 0) {
      StorageService.saveStocks(updatedStocks);
      widget.onStocksChanged(updatedStocks);
      print('📦 [購入済み処理] ストック更新: ${stocksAddedCount}件');
    }

    // 食材が追加された場合のみ保存
    if (foodsAddedCount > 0) {
      StorageService.saveFoods(updatedFoods);
      widget.onFoodsChanged(updatedFoods);
      print('🥬 [購入済み処理] 食材追加: ${foodsAddedCount}件');
    }

    // 買い物リストも更新
    widget.onShoppingItemsChanged(updatedShoppingItems);
    for (final item in selectedItems) {
      final updatedItem = item.copyWith(isPurchased: true);
      await _supabaseService.updateShoppingItem(updatedItem);
    }

    setState(() {
      _selectedIds.clear();
    });

    // ユーザーへのフィードバック
    if (mounted) {
      String message;
      if (stocksAddedCount > 0 && foodsAddedCount > 0) {
        message = '${selectedItems.length}件を購入済みに（ストック${stocksAddedCount}件、食材${foodsAddedCount}件追加）';
      } else if (stocksAddedCount > 0) {
        message = '${stocksAddedCount}件を購入済みにしてストックに追加しました';
      } else if (foodsAddedCount > 0) {
        message = '${foodsAddedCount}件を購入済みにして食材に追加しました';
      } else {
        message = '${selectedItems.length}件を購入済みにしました';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    print('✅ [購入済み処理] 完了');
  }

  /// 買い物リストのカテゴリIDを食材カテゴリIDにマッピング
  String _mapShoppingCategoryToFoodCategory(String categoryId) {
    // 食材カテゴリ: fridge, freezer, room
    // ストックカテゴリ: daily, bath, cleaning, food_stock, medicine, other
    switch (categoryId) {
      // 既に食材カテゴリの場合はそのまま返す
      case 'fridge':
        return 'fridge';  // 冷蔵 → 冷蔵
      case 'freezer':
        return 'freezer'; // 冷凍 → 冷凍
      case 'room':
        return 'room';    // 常温 → 常温
      
      // ストックカテゴリから食材カテゴリへのマッピング
      case 'food_stock':
      case '食品':
        return 'fridge';  // 食品ストック → 冷蔵
      case 'daily':
      case '日用品':
        return 'room';    // 日用品 → 常温
      case '調味料':
        return 'fridge';  // 調味料 → 冷蔵
      case '乳製品':
      case '卵・乳製品':
        return 'fridge';  // 乳製品 → 冷蔵
      case '冷凍':
        return 'freezer'; // 冷凍 → 冷凍
      default:
        return 'fridge';  // デフォルトは冷蔵
    }
  }

  /// 数量を増やす
  void _increaseQuantity(ShoppingItem item) async {
    final updatedItem = item.copyWith(quantity: item.quantity + 1);
    final updatedItems = _shoppingItems.map((i) => i.id == item.id ? updatedItem : i).toList();
    
    widget.onShoppingItemsChanged(updatedItems);
    await _supabaseService.updateShoppingItem(updatedItem);
  }

  /// 数量を減らす
  void _decreaseQuantity(ShoppingItem item) async {
    if (item.quantity <= 1) return; // 最小値は1
    
    final updatedItem = item.copyWith(quantity: item.quantity - 1);
    final updatedItems = _shoppingItems.map((i) => i.id == item.id ? updatedItem : i).toList();
    
    widget.onShoppingItemsChanged(updatedItems);
    await _supabaseService.updateShoppingItem(updatedItem);
  }

  /// 購入済みアイテムを一括削除
  void _deletePurchasedItems() async {
    // 確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('購入済みアイテムを削除'),
        content: Text('購入済みの${_purchasedItems.length}件をすべて削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 購入済みアイテムを削除
    final purchasedIds = _purchasedItems.map((item) => item.id).toList();
    final updatedItems = _shoppingItems.where((item) => !item.isPurchased).toList();
    
    widget.onShoppingItemsChanged(updatedItems);

    // Supabaseから削除
    for (final id in purchasedIds) {
      await _supabaseService.deleteShoppingItem(id);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('購入済み${purchasedIds.length}件を削除しました'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// アイテムを削除
  void _deleteItem(ShoppingItem item) async {
    final updatedItems = _shoppingItems.where((i) => i.id != item.id).toList();
    widget.onShoppingItemsChanged(updatedItems);
    
    await _supabaseService.deleteShoppingItem(item.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.icon} ${item.name} を削除しました'),
          backgroundColor: const Color(0xFFE74C3C),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 手動追加ダイアログ
  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final memoController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    String selectedIcon = '🛒';
    String selectedCategoryId = 'food_stock'; // デフォルトカテゴリ（ストックと同じID）

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('買い物リストに追加'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // アイコン選択
                DropdownButtonFormField<String>(
                  initialValue: selectedIcon,
                  decoration: const InputDecoration(
                    labelText: 'アイコン',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '🛒', child: Text('🛒', style: TextStyle(fontSize: 24))),
                    DropdownMenuItem(value: '🍎', child: Text('🍎', style: TextStyle(fontSize: 24))),
                    DropdownMenuItem(value: '🥬', child: Text('🥬', style: TextStyle(fontSize: 24))),
                    DropdownMenuItem(value: '🥛', child: Text('🥛', style: TextStyle(fontSize: 24))),
                    DropdownMenuItem(value: '🍖', child: Text('🍖', style: TextStyle(fontSize: 24))),
                    DropdownMenuItem(value: '🍞', child: Text('🍞', style: TextStyle(fontSize: 24))),
                    DropdownMenuItem(value: '🧴', child: Text('🧴', style: TextStyle(fontSize: 24))),
                    DropdownMenuItem(value: '🧻', child: Text('🧻', style: TextStyle(fontSize: 24))),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedIcon = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // 名前入力
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '商品名',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // カテゴリ選択
                DropdownButtonFormField<String>(
                  initialValue: selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'カテゴリ',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'food_stock', child: Text('🍶 調味料・食品')),
                    DropdownMenuItem(value: 'daily', child: Text('🧻 日用品')),
                    DropdownMenuItem(value: 'bath', child: Text('🧴 バス・洗面')),
                    DropdownMenuItem(value: 'cleaning', child: Text('🧹 掃除・洗濯')),
                    DropdownMenuItem(value: 'other', child: Text('📦 その他')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategoryId = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // 数量入力
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: '数量',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_basket),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                
                // メモ入力
                TextField(
                  controller: memoController,
                  decoration: const InputDecoration(
                    labelText: 'メモ（任意）',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('商品名を入力してください')),
                  );
                  return;
                }
                
                final quantity = int.tryParse(quantityController.text.trim()) ?? 1;
                if (quantity < 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('数量は1以上を入力してください')),
                  );
                  return;
                }
                
                _addItem(
                  name: nameController.text.trim(),
                  icon: selectedIcon,
                  categoryId: selectedCategoryId,
                  quantity: quantity,
                  memo: memoController.text.trim().isEmpty
                      ? null
                      : memoController.text.trim(),
                );
                
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
              ),
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }

  /// アイテムを追加
  void _addItem({
    required String name,
    required String icon,
    required String categoryId,
    int quantity = 1,
    String? memo,
  }) async {
    final newItem = ShoppingItem(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      categoryId: categoryId,
      quantity: quantity,
      source: ShoppingSource.manual,
      memo: memo,
    );

    final updatedItems = [..._shoppingItems, newItem];
    widget.onShoppingItemsChanged(updatedItems);
    
    await _supabaseService.addShoppingItem(newItem);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$icon $name を追加しました'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
