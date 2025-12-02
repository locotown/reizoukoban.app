import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Supabase
import 'supabase_config.dart';

// Models
import 'models/food_item.dart';
import 'models/food_template.dart';
import 'models/stock_item.dart';

// Services
import 'services/storage_service.dart';
import 'services/supabase_auth_service.dart';

// Screens
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/stock_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supabase初期化
  try {
    await SupabaseConfig.initialize();
    if (kDebugMode) {
      print('✅ Supabase初期化成功');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Supabase初期化エラー: $e');
    }
  }
  
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
      home: const AuthWrapper(),  // Supabase認証を使用
    );
  }
}

// ===== 認証ラッパー =====

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = SupabaseAuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // ローディング中
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ログイン済み（Supabaseの認証状態を確認）
        if (snapshot.hasData && snapshot.data?.session != null) {
          return const MainNavigation();
        }

        // 未ログイン
        return const LoginScreen();
      },
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
  
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // ローカルストレージからデータを読み込み
    setState(() {
      _foods = StorageService.loadFoods();
      _customTemplates = StorageService.loadCustomTemplates();
      _stocks = StorageService.loadStocks();
      _isInitialLoading = false;
    });
  }

  void _updateFoods(List<FoodItem> foods) {
    setState(() => _foods = foods);
    StorageService.saveFoods(foods);
  }

  void _updateCustomTemplates(List<FoodTemplate> templates) {
    setState(() => _customTemplates = templates);
    StorageService.saveCustomTemplates(templates);
  }

  void _updateStocks(List<StockItem> stocks) {
    setState(() => _stocks = stocks);
    StorageService.saveStocks(stocks);
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('データを読み込み中...'),
            ],
          ),
        ),
      );
    }

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
