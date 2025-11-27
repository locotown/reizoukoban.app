import 'package:flutter/material.dart';

// Models
import 'models/food_item.dart';
import 'models/food_template.dart';

// Services
import 'services/storage_service.dart';

// Screens
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _foods = StorageService.loadFoods();
      _customTemplates = StorageService.loadCustomTemplates();
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

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
}
