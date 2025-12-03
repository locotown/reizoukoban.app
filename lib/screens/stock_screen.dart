import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Models
import '../models/stock_item.dart';
import '../models/shopping_item.dart';

// Constants
import '../constants/stock_categories.dart';

// Services
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

/// ストック管理画面
class StockScreen extends StatefulWidget {
  final List<StockItem> stocks;
  final Function(List<StockItem>) onStocksChanged;
  final Function(ShoppingItem)? onAddToShoppingList;

  const StockScreen({
    super.key,
    required this.stocks,
    required this.onStocksChanged,
    this.onAddToShoppingList,
  });

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final _supabaseService = SupabaseService();

  // 有効なストックカテゴリIDのリスト
  static const _validStockCategoryIds = {
    'daily', 'bath', 'cleaning', 'food_stock', 'medicine', 'other'
  };

  // フィルタリングされたストック（食材カテゴリを除外）
  List<StockItem> get _stocks {
    return widget.stocks.where((stock) {
      // ストック専用カテゴリのみ表示（食材カテゴリ fridge, freezer, room を除外）
      return _validStockCategoryIds.contains(stock.categoryId);
    }).toList();
  }

  // 買い物が必要なアイテム数
  int get _urgentCount => _stocks.where((s) => s.isUrgent).length;
  int get _lowCount => _stocks.where((s) => s.status == StockStatus.low).length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // 買い物リストタブを削除（フッターに統合）
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addStock(StockItem stock) async {
    final updatedStocks = [..._stocks, stock];
    StorageService.saveStocks(updatedStocks);
    widget.onStocksChanged(updatedStocks);
    
    // Supabaseに保存
    await _supabaseService.addStock(stock);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${stock.icon} ${stock.name} を追加しました'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _updateStock(StockItem stock) async {
    final updatedStocks =
        _stocks.map((s) => s.id == stock.id ? stock : s).toList();
    StorageService.saveStocks(updatedStocks);
    widget.onStocksChanged(updatedStocks);
    
    // Supabaseに保存
    await _supabaseService.updateStock(stock);
  }

  void _deleteStock(String id) async {
    final updatedStocks = _stocks.where((s) => s.id != id).toList();
    StorageService.saveStocks(updatedStocks);
    widget.onStocksChanged(updatedStocks);
    
    // Supabaseから削除
    await _supabaseService.deleteStock(id);
  }

  void _markAsPurchased(List<StockItem> items) async {
    final updatedStocks = _stocks.map((s) {
      if (items.any((item) => item.id == s.id)) {
        return s.copyWith(status: StockStatus.sufficient);
      }
      return s;
    }).toList();
    StorageService.saveStocks(updatedStocks);
    widget.onStocksChanged(updatedStocks);
    
    // Supabaseに保存（各アイテムを更新）
    for (final item in items) {
      final updatedItem = item.copyWith(status: StockStatus.sufficient);
      await _supabaseService.updateStock(updatedItem);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${items.length}件を購入済みにしました'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Text('🛒', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Text(
              'ストック管理',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        actions: [
          // 買い物必要アイテム数
          if (_urgentCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _buildMiniTag('🔴', _urgentCount, const Color(0xFFE53935)),
            ),
          if (_lowCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildMiniTag('🟡', _lowCount, const Color(0xFFFF9800)),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildStockListTab(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStockDialog(),
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('アイテム追加',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMiniTag(String icon, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ストック一覧タブ
  Widget _buildStockListTab() {
    if (_stocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📦', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'ストックアイテムがありません',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '「アイテム追加」から登録しましょう',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: defaultStockCategories.map((category) {
          final categoryStocks =
              _stocks.where((s) => s.categoryId == category.id).toList();
          if (categoryStocks.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // カテゴリヘッダー
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${categoryStocks.length}件',
                        style: TextStyle(
                          color: category.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // アイテムリスト
              ...categoryStocks.map((stock) => _buildStockCard(stock, category)),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStockCard(StockItem stock, StockCategory category) {
    Color statusColor;
    switch (stock.status) {
      case StockStatus.sufficient:
        statusColor = const Color(0xFF4CAF50);
        break;
      case StockStatus.low:
        statusColor = const Color(0xFFFF9800);
        break;
      case StockStatus.empty:
        statusColor = const Color(0xFFE53935);
        break;
    }

    return Dismissible(
      key: Key(stock.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteStock(stock.id),
      child: GestureDetector(
        onTap: () => _showEditStockDialog(stock, category),
        onLongPress: () => _showStockOptions(stock, category),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // アイコン
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(stock.icon, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              // 名前とメモ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (stock.memo != null && stock.memo!.isNotEmpty)
                      Text(
                        stock.memo!,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              // 買い物カートアイコン（ワンタップで買い物リストに追加）
              IconButton(
                onPressed: () => _addStockToShoppingList(stock),
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 20,
                  color: Color(0xFF3498DB),
                ),
                tooltip: '買い物リストに追加',
              ),
              const SizedBox(width: 4),
              // ステータス変更ボタン
              GestureDetector(
                onTap: () => _cycleStatus(stock),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(stock.statusIcon,
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        stock.statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _cycleStatus(StockItem stock) {
    StockStatus newStatus;
    switch (stock.status) {
      case StockStatus.sufficient:
        newStatus = StockStatus.low;
        break;
      case StockStatus.low:
        newStatus = StockStatus.empty;
        break;
      case StockStatus.empty:
        newStatus = StockStatus.sufficient;
        break;
    }
    _updateStock(stock.copyWith(status: newStatus));
  }

  // 買い物リストタブ
  // アイテム追加ダイアログ
  void _showAddStockDialog() {
    String selectedCategoryId = defaultStockCategories.first.id;
    String selectedIcon = '📦';
    final nameController = TextEditingController();
    final memoController = TextEditingController();
    StockStatus selectedStatus = StockStatus.sufficient;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final category = defaultStockCategories.firstWhere(
            (c) => c.id == selectedCategoryId,
          );
          final templates = defaultStockTemplates
              .where((t) => t.categoryId == selectedCategoryId)
              .toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ハンドル
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ストックアイテムを追加',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // カテゴリ選択
                  const Text('カテゴリ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: defaultStockCategories.map((cat) {
                        final isSelected = selectedCategoryId == cat.id;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedCategoryId = cat.id;
                              selectedIcon = cat.icon;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? cat.color
                                  : cat.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(cat.icon,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    color:
                                        isSelected ? Colors.white : cat.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // テンプレートから選択
                  if (templates.isNotEmpty) ...[
                    const Text('テンプレートから選択',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: templates.map((template) {
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              nameController.text = template.name;
                              selectedIcon = template.icon;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: category.color.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(template.icon,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 4),
                                Text(
                                  template.name,
                                  style: TextStyle(
                                    color: category.color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // アイテム名
                  const Text('アイテム名',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: '例: トイレットペーパー',
                      prefixIcon: Text(selectedIcon,
                          style: const TextStyle(fontSize: 20)),
                      prefixIconConstraints: const BoxConstraints(minWidth: 48),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // メモ
                  const Text('メモ（任意）',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: memoController,
                    decoration: InputDecoration(
                      hintText: '例: ○○メーカーのがいい',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ステータス選択
                  const Text('現在の在庫状況',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusOption(
                        '🟢 十分',
                        StockStatus.sufficient,
                        selectedStatus,
                        const Color(0xFF4CAF50),
                        (status) => setModalState(() => selectedStatus = status),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusOption(
                        '🟡 残少',
                        StockStatus.low,
                        selectedStatus,
                        const Color(0xFFFF9800),
                        (status) => setModalState(() => selectedStatus = status),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusOption(
                        '🔴 切れた',
                        StockStatus.empty,
                        selectedStatus,
                        const Color(0xFFE53935),
                        (status) => setModalState(() => selectedStatus = status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 追加ボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) return;

                        final stock = StockItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text.trim(),
                          icon: selectedIcon,
                          categoryId: selectedCategoryId,
                          status: selectedStatus,
                          memo: memoController.text.trim().isEmpty
                              ? null
                              : memoController.text.trim(),
                        );
                        _addStock(stock);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '追加する',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusOption(
    String label,
    StockStatus status,
    StockStatus selectedStatus,
    Color color,
    Function(StockStatus) onTap,
  ) {
    final isSelected = status == selectedStatus;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 編集ダイアログ
  void _showEditStockDialog(StockItem stock, StockCategory category) {
    final nameController = TextEditingController(text: stock.name);
    final memoController = TextEditingController(text: stock.memo ?? '');
    StockStatus selectedStatus = stock.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child:
                            Text(stock.icon, style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'アイテムを編集',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // アイテム名
                const Text('アイテム名',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    prefixIcon:
                        Text(stock.icon, style: const TextStyle(fontSize: 20)),
                    prefixIconConstraints: const BoxConstraints(minWidth: 48),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                  ),
                ),
                const SizedBox(height: 16),

                // メモ
                const Text('メモ', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: memoController,
                  decoration: InputDecoration(
                    hintText: '例: ○○メーカーのがいい',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                  ),
                ),
                const SizedBox(height: 16),

                // ステータス
                const Text('在庫状況',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusOption(
                      '🟢 十分',
                      StockStatus.sufficient,
                      selectedStatus,
                      const Color(0xFF4CAF50),
                      (status) => setModalState(() => selectedStatus = status),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusOption(
                      '🟡 残少',
                      StockStatus.low,
                      selectedStatus,
                      const Color(0xFFFF9800),
                      (status) => setModalState(() => selectedStatus = status),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusOption(
                      '🔴 切れた',
                      StockStatus.empty,
                      selectedStatus,
                      const Color(0xFFE53935),
                      (status) => setModalState(() => selectedStatus = status),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('キャンセル'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) return;

                          final updatedStock = stock.copyWith(
                            name: nameController.text.trim(),
                            memo: memoController.text.trim().isEmpty
                                ? null
                                : memoController.text.trim(),
                            status: selectedStatus,
                          );
                          _updateStock(updatedStock);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${stock.icon} ${nameController.text.trim()} を更新しました'),
                              backgroundColor: category.color,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: category.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('保存',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ストックオプションメニューを表示
  void _showStockOptions(StockItem stock, StockCategory category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(stock.icon, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${category.name} • ${stock.statusText}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 買い物リストに追加ボタン
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Color(0xFF3498DB),
                ),
              ),
              title: const Text('買い物リストに追加'),
              subtitle: const Text('買い忘れを防ぐ'),
              onTap: () {
                Navigator.pop(context);
                _addStockToShoppingList(stock);
              },
            ),
            const SizedBox(height: 8),
            // 削除ボタン
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete,
                  color: Color(0xFFE74C3C),
                ),
              ),
              title: const Text('削除'),
              subtitle: const Text('このストックを削除します'),
              onTap: () {
                Navigator.pop(context);
                _deleteStock(stock.id);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// ストックを買い物リストに追加
  void _addStockToShoppingList(StockItem stock) async {
    final shoppingItem = ShoppingItem(
      id: const Uuid().v4(),
      name: stock.name,
      icon: stock.icon,
      categoryId: stock.categoryId,
      source: ShoppingSource.stock,
      sourceId: stock.id,
      memo: stock.memo,
    );

    // Supabaseに保存
    await _supabaseService.addShoppingItem(shoppingItem);

    // コールバックを呼び出し
    if (widget.onAddToShoppingList != null) {
      widget.onAddToShoppingList!(shoppingItem);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${stock.icon} ${stock.name} を買い物リストに追加しました'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
