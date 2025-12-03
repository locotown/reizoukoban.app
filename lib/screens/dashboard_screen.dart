import 'package:flutter/material.dart';

// Models
import '../models/category.dart';
import '../models/food_item.dart';

// Constants
import '../constants/categories.dart';

// Services
import '../services/storage_service.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_service.dart';

// Screens
import 'help_screen.dart';

// Widgets
import '../widgets/mini_tag.dart';
import '../widgets/sort_button.dart';
import '../widgets/food_card.dart';

// Additional imports
import '../models/shopping_item.dart';
import 'package:uuid/uuid.dart';

/// Dashboard画面（食品一覧表示）
class DashboardScreen extends StatefulWidget {
  final List<FoodItem> foods;
  final Function(List<FoodItem>) onFoodsChanged;
  final Function(ShoppingItem)? onAddToShoppingList;

  const DashboardScreen({
    super.key,
    required this.foods,
    required this.onFoodsChanged,
    this.onAddToShoppingList,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sortMode = 'expiration'; // 'expiration', 'status', 'added'
  
  final _supabaseService = SupabaseService();

  int get _expiredCount => widget.foods.where((f) => f.isExpired).length;
  int get _warningCount => widget.foods.where((f) => f.isWarning).length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _deleteFood(String id) async {
    final updatedFoods = widget.foods.where((f) => f.id != id).toList();
    StorageService.saveFoods(updatedFoods);
    widget.onFoodsChanged(updatedFoods);
    
    // Supabaseから削除
    await _supabaseService.deleteFood(id);
  }

  void _updateFood(FoodItem food) async {
    final updatedFoods =
        widget.foods.map((f) => f.id == food.id ? food : f).toList();
    StorageService.saveFoods(updatedFoods);
    widget.onFoodsChanged(updatedFoods);
    
    // Supabaseに保存
    await _supabaseService.updateFood(food);
  }

  List<FoodItem> _getSortedFoods([String? categoryId]) {
    final foods = categoryId == null
        ? List<FoodItem>.from(widget.foods)
        : widget.foods.where((f) => f.categoryId == categoryId).toList();
    switch (_sortMode) {
      case 'expiration':
        foods.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
        break;
      case 'status':
        foods.sort((a, b) {
          if (a.isExpired != b.isExpired) return a.isExpired ? -1 : 1;
          if (a.isWarning != b.isWarning) return a.isWarning ? -1 : 1;
          return a.expirationDate.compareTo(b.expirationDate);
        });
        break;
      case 'added':
        foods.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return foods;
  }

  String _getTodayString() {
    final now = DateTime.now();
    final weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    final weekday = weekdays[now.weekday - 1];
    return '${now.month}/${now.day}($weekday)';
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
            Image.asset(
              'assets/icons/app_icon.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            const Text(
              '冷蔵庫番',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.today,
                      size: 11, color: Color(0xFF2196F3)),
                  const SizedBox(width: 3),
                  Text(
                    _getTodayString(),
                    style: const TextStyle(
                      color: Color(0xFF2196F3),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // ログアウトボタン
          IconButton(
            onPressed: () async {
              final authService = SupabaseAuthService();
              try {
                await authService.signOut();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('ログアウトに失敗しました: $e')),
                  );
                }
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout, size: 18, color: Colors.grey),
            ),
          ),
          // ヘルプボタン
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.help_outline, size: 18, color: Color(0xFF2196F3)),
            ),
          ),
          // ステータスタグ
          if (_expiredCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: MiniTag(
                  icon: '🚨',
                  count: _expiredCount,
                  color: const Color(0xFFE53935)),
            ),
          if (_warningCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: MiniTag(
                  icon: '⚠️',
                  count: _warningCount,
                  color: const Color(0xFFFF9800)),
            ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2196F3),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2196F3),
          indicatorWeight: 3,
          tabs: [
            const Tab(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('📋', style: TextStyle(fontSize: 16)),
                SizedBox(width: 4),
                Text('全て',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            )),
            ...defaultCategories.map((cat) => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(cat.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                )),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFoodList(null),
          ...defaultCategories.map((cat) => _buildFoodList(cat.id)),
        ],
      ),
    );
  }

  Widget _buildFoodList(String? categoryId) {
    final sortedFoods = _getSortedFoods(categoryId);
    final categoryName = categoryId == null
        ? 'すべて'
        : defaultCategories.firstWhere((c) => c.id == categoryId).name;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 食材一覧ヘッダー + ソート
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${categoryId == null ? "📋" : defaultCategories.firstWhere((c) => c.id == categoryId).icon} ${categoryName}の食材',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // ソート切り替えボタン
              SortButton(
                sortMode: _sortMode,
                onTap: () {
                  setState(() {
                    if (_sortMode == 'expiration') {
                      _sortMode = 'status';
                    } else if (_sortMode == 'status') {
                      _sortMode = 'added';
                    } else {
                      _sortMode = 'expiration';
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (sortedFoods.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Text('🧊', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      '食材がまだありません',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '下の「登録」タブから追加しましょう',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...sortedFoods.map((food) {
              final category = defaultCategories.firstWhere(
                (c) => c.id == food.categoryId,
                orElse: () => defaultCategories.first,
              );
              return FoodCard(
                food: food,
                category: category,
                onTap: () => _showEditDialog(food, category),
                onDelete: () => _deleteFood(food.id),
                onLongPress: () => _showFoodOptions(food, category),
              );
            }),
        ],
      ),
    );
  }

  void _showEditDialog(FoodItem food, Category category) {
    DateTime selectedDate = food.expirationDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
                        child: Text(food.icon,
                            style: const TextStyle(fontSize: 32))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(category.name,
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('賞味期限を変更',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setModalState(() => selectedDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: category.color),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: category.color),
                      const SizedBox(width: 12),
                      Text(
                        '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildQuickDateButton(
                      '-1日',
                      () => setModalState(() => selectedDate =
                          selectedDate.subtract(const Duration(days: 1))),
                      Colors.red),
                  _buildQuickDateButton(
                      '+1日',
                      () => setModalState(() => selectedDate =
                          selectedDate.add(const Duration(days: 1))),
                      category.color),
                  _buildQuickDateButton(
                      '+3日',
                      () => setModalState(() => selectedDate =
                          selectedDate.add(const Duration(days: 3))),
                      category.color),
                  _buildQuickDateButton(
                      '+7日',
                      () => setModalState(() => selectedDate =
                          selectedDate.add(const Duration(days: 7))),
                      category.color),
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
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('キャンセル'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        final updatedFood =
                            food.copyWith(expirationDate: selectedDate);
                        _updateFood(updatedFood);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: category.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('保存する',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildQuickDateButton(String label, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  /// 食材オプションメニューを表示
  void _showFoodOptions(FoodItem food, Category category) {
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
                    child: Text(food.icon, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        category.name,
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
              subtitle: const Text('同じ商品を買いたい時に便利'),
              onTap: () {
                Navigator.pop(context);
                _addToShoppingList(food);
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
              subtitle: const Text('この食材を削除します'),
              onTap: () {
                Navigator.pop(context);
                _deleteFood(food.id);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 食材を買い物リストに追加
  void _addToShoppingList(FoodItem food) async {
    final shoppingItem = ShoppingItem(
      id: const Uuid().v4(),
      name: food.name,
      icon: food.icon,
      categoryId: food.categoryId,
      source: ShoppingSource.food,
      sourceId: food.id,
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
          content: Text('${food.icon} ${food.name} を買い物リストに追加しました'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
