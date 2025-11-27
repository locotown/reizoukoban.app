import 'package:flutter/material.dart';

// Models
import 'models/food_item.dart';
import 'models/food_template.dart';
import 'models/stock_item.dart';

// Services
import 'services/storage_service.dart';

// Screens
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/stock_screen.dart';

void main() {
  runApp(const FreshAlertApp());
}

class FreshAlertApp extends StatelessWidget {
  const FreshAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '冷蔵庫番',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainNavigation(),
    );
  }
}

// ===== メインナビゲーション =====

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  List<FoodItem> _foods = [];
  List<FoodTemplate> _customTemplates = [];
  List<StockItem> _stocks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _foods = StorageService.loadFoods();
      _customTemplates = StorageService.loadCustomTemplates();
      _stocks = StorageService.loadStocks();
    });
  }

  void _updateFoods(List<FoodItem> foods) {
    setState(() {
      _foods = foods;
    });
  }

  void _updateCustomTemplates(List<FoodTemplate> templates) {
    setState(() {
      _customTemplates = templates;
    });
  }

  void _updateStocks(List<StockItem> stocks) {
    setState(() {
      _stocks = stocks;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 買い物が必要なアイテム数（バッジ用）
    final needShoppingCount = _stocks.where((s) => s.needsToBuy).length;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            foods: _foods,
            onFoodsChanged: _updateFoods,
          ),
          HomeScreen(
            foods: _foods,
            customTemplates: _customTemplates,
            onFoodsChanged: _updateFoods,
            onTemplatesChanged: _updateCustomTemplates,
          ),
          StockScreen(
            stocks: _stocks,
            onStocksChanged: _updateStocks,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'ホーム'),
                _buildNavItem(1, Icons.add_circle_outline, '登録'),
                _buildNavItemWithBadge(2, Icons.shopping_cart_outlined, 'ストック', needShoppingCount),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge(int index, IconData icon, String label, int badgeCount) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
                  size: 26,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 18),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
