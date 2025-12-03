import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Models
import '../models/shopping_item.dart';
import '../models/stock_item.dart';

// Services
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

/// 買い物リスト画面
class ShoppingListScreen extends StatefulWidget {
  final List<ShoppingItem> shoppingItems;
  final List<StockItem> stocks;
  final Function(List<ShoppingItem>) onShoppingItemsChanged;
  final Function(List<StockItem>) onStocksChanged;

  const ShoppingListScreen({
    super.key,
    required this.shoppingItems,
    required this.stocks,
    required this.onShoppingItemsChanged,
    required this.onStocksChanged,
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

  /// 買い物アイテムカード（未購入）
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
      ),
      child: ListTile(
        leading: Checkbox(
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
        ),
        title: Row(
          children: [
            Text(item.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 数量表示
                  Text(
                    'x${item.quantity}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3498DB),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: item.memo != null && item.memo!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4, left: 32),
                child: Text(
                  item.memo!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF95A5A6),
                  ),
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 数量減少ボタン
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              color: const Color(0xFF95A5A6),
              onPressed: () => _decreaseQuantity(item),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 4),
            // 数量増加ボタン
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              color: const Color(0xFF4CAF50),
              onPressed: () => _increaseQuantity(item),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            // ソース表示
            _buildSourceBadge(item.source),
            const SizedBox(width: 8),
            // 削除ボタン
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: const Color(0xFFE74C3C),
              onPressed: () => _deleteItem(item),
            ),
          ],
        ),
      ),
    );
  }

  /// 購入済みアイテムカード
  Widget _buildPurchasedItemCard(ShoppingItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.check_circle,
          color: Color(0xFF4CAF50),
          size: 24,
        ),
        title: Row(
          children: [
            Text(item.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF95A5A6),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 数量表示
                  Text(
                    'x${item.quantity}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFBDC3C7),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          color: const Color(0xFFBDC3C7),
          onPressed: () => _deleteItem(item),
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
        color: color.withOpacity(0.1),
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

    // 2. ストックに追加または更新
    final updatedStocks = List<StockItem>.from(widget.stocks);
    print('📦 [購入済み処理] 現在のストック数: ${updatedStocks.length}');
    
    for (final item in selectedItems) {
      print('🔍 [購入済み処理] 処理中: ${item.name}');
      
      // 同名のストックがあるか確認
      final existingStockIndex = updatedStocks.indexWhere(
        (stock) => stock.name.toLowerCase() == item.name.toLowerCase(),
      );

      if (existingStockIndex != -1) {
        // 既存のストックを「十分」に更新
        print('✏️ [購入済み処理] 既存ストック更新: ${item.name}');
        final existingStock = updatedStocks[existingStockIndex];
        updatedStocks[existingStockIndex] = existingStock.copyWith(
          status: StockStatus.sufficient,
        );
        await _supabaseService.updateStock(updatedStocks[existingStockIndex]);
      } else {
        // 新しいストックを作成
        print('➕ [購入済み処理] 新規ストック作成: ${item.name}');
        print('   - カテゴリID: ${item.categoryId}');
        print('   - アイコン: ${item.icon}');
        print('   - メモ: ${item.memo}');
        
        final newStock = StockItem(
          id: const Uuid().v4(),
          name: item.name,
          icon: item.icon,
          categoryId: item.categoryId,
          status: StockStatus.sufficient,
          memo: item.memo,
        );
        updatedStocks.add(newStock);
        print('💾 [購入済み処理] Supabaseに保存: ${newStock.id}');
        print('   - ストック総数: ${updatedStocks.length}');
        
        final result = await _supabaseService.addStock(newStock);
        print('✅ [購入済み処理] Supabase保存結果: $result');
      }
    }

    print('📦 [購入済み処理] 更新後のストック数: ${updatedStocks.length}');

    // 3. ローカルストレージとSupabaseに保存
    StorageService.saveStocks(updatedStocks);
    print('💾 [購入済み処理] ローカルストレージに保存完了');
    
    widget.onStocksChanged(updatedStocks);
    print('🔄 [購入済み処理] 親コンポーネントに通知完了');

    // 買い物リストも更新
    widget.onShoppingItemsChanged(updatedShoppingItems);
    for (final item in selectedItems) {
      final updatedItem = item.copyWith(isPurchased: true);
      await _supabaseService.updateShoppingItem(updatedItem);
    }

    setState(() {
      _selectedIds.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selectedItems.length}件を購入済みにしてストックに追加しました'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    print('✅ [購入済み処理] 完了');
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
