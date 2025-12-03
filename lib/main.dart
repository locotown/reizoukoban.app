import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Supabase
import 'supabase_config.dart';

// Models
import 'models/food_item.dart';
import 'models/food_template.dart';
import 'models/stock_item.dart';
import 'models/shopping_item.dart';

// Services
import 'services/storage_service.dart';
import 'services/supabase_auth_service.dart';
import 'services/supabase_service.dart';

// Supabase Realtime
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/shopping_list_screen.dart';
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
  List<ShoppingItem> _shoppingItems = [];
  List<StockItem> _stocks = [];
  
  bool _isInitialLoading = true;
  
  // Supabaseサービス
  final _supabaseService = SupabaseService();
  
  // リアルタイムチャンネル
  RealtimeChannel? _foodsChannel;
  RealtimeChannel? _stocksChannel;
  RealtimeChannel? _shoppingChannel;
  RealtimeChannel? _templatesChannel;

  @override
  void initState() {
    super.initState();
    // 古いキー（ユーザーID無し）のデータをクリア
    StorageService.clearLegacyData();
    _loadData();
    _startRealtimeSync();
  }

  @override
  void dispose() {
    // チャンネル購読解除
    if (_foodsChannel != null) _supabaseService.unsubscribe(_foodsChannel!);
    if (_stocksChannel != null) _supabaseService.unsubscribe(_stocksChannel!);
    if (_shoppingChannel != null) _supabaseService.unsubscribe(_shoppingChannel!);
    if (_templatesChannel != null) _supabaseService.unsubscribe(_templatesChannel!);
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Supabaseからデータ読み込み（常にサーバーデータを優先）
      final foods = await _supabaseService.getFoods();
      final stocks = await _supabaseService.getStocks();
      final shoppingItems = await _supabaseService.getShoppingItems();
      final templates = await _supabaseService.getCustomTemplates();

      if (mounted) {
        setState(() {
          // Supabaseのデータを優先（RLSによりユーザーごとに分離されている）
          _foods = foods;
          _stocks = stocks;
          _shoppingItems = shoppingItems;
          _customTemplates = templates;
          _isInitialLoading = false;
        });

        // ローカルストレージにも保存
        StorageService.saveFoods(_foods);
        StorageService.saveStocks(_stocks);
        StorageService.saveCustomTemplates(_customTemplates);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ データ読み込みエラー: $e');
      }
      
      // エラー時はローカルストレージから読み込み
      if (mounted) {
        setState(() {
          _foods = StorageService.loadFoods();
          _customTemplates = StorageService.loadCustomTemplates();
          _stocks = StorageService.loadStocks();
          _shoppingItems = []; // ローカルストレージには保存しない（買い物リストはSupabase専用）
          _isInitialLoading = false;
        });
      }
    }
  }

  /// リアルタイム同期開始
  void _startRealtimeSync() {
    // 食材のリアルタイム監視
    _foodsChannel = _supabaseService.watchFoods((foods) {
      if (mounted) {
        setState(() => _foods = foods);
        StorageService.saveFoods(foods);
      }
    });

    // ストックのリアルタイム監視
    _stocksChannel = _supabaseService.watchStocks((stocks) {
      if (mounted) {
        setState(() => _stocks = stocks);
        StorageService.saveStocks(stocks);
      }
    });

    // 買い物リストのリアルタイム監視
    _shoppingChannel = _supabaseService.watchShoppingItems((items) {
      if (mounted) {
        setState(() => _shoppingItems = items);
      }
    });

    // カスタムテンプレートのリアルタイム監視
    _templatesChannel = _supabaseService.watchCustomTemplates((templates) {
      if (mounted) {
        setState(() => _customTemplates = templates);
        StorageService.saveCustomTemplates(templates);
      }
    });
  }

  void _updateFoods(List<FoodItem> foods) {
    setState(() => _foods = foods);
    StorageService.saveFoods(foods);
    // Supabase同期はリアルタイムリスナーが自動処理
  }

  void _updateCustomTemplates(List<FoodTemplate> templates) {
    setState(() => _customTemplates = templates);
    StorageService.saveCustomTemplates(templates);
    // Supabase同期はリアルタイムリスナーが自動処理
  }

  void _updateStocks(List<StockItem> stocks) {
    setState(() => _stocks = stocks);
    StorageService.saveStocks(stocks);
    // Supabase同期はリアルタイムリスナーが自動処理
  }

  void _updateShoppingItems(List<ShoppingItem> items) {
    setState(() => _shoppingItems = items);
    // 買い物リストはSupabase専用のためローカルストレージには保存しない
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

    // 買い物リストの未購入アイテム数（バッジ用）
    final needShoppingCount = _shoppingItems.where((item) => !item.isPurchased).length;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(
            foods: _foods,
            onFoodsChanged: _updateFoods,
            onAddToShoppingList: (item) {
              final updated = [..._shoppingItems, item];
              _updateShoppingItems(updated);
            },
          ),
          HomeScreen(
            foods: _foods,
            customTemplates: _customTemplates,
            onFoodsChanged: _updateFoods,
            onTemplatesChanged: _updateCustomTemplates,
          ),
          ShoppingListScreen(
            shoppingItems: _shoppingItems,
            stocks: _stocks,
            onShoppingItemsChanged: _updateShoppingItems,
            onStocksChanged: _updateStocks,
          ),
          StockScreen(
            stocks: _stocks,
            onStocksChanged: _updateStocks,
            onAddToShoppingList: (item) {
              final updated = [..._shoppingItems, item];
              _updateShoppingItems(updated);
            },
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
                _buildNavItemWithBadge(2, Icons.shopping_cart, '買い物', needShoppingCount),
                _buildNavItem(3, Icons.inventory_2_outlined, 'ストック'),
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
