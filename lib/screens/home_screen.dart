import 'package:flutter/material.dart';

// Models
import '../models/category.dart';
import '../models/food_item.dart';
import '../models/food_template.dart';

// Constants
import '../constants/categories.dart';
import '../constants/food_templates.dart';

// Services
import '../services/storage_service.dart';

// Widgets
import '../widgets/mini_tag.dart';

/// 登録画面（食品登録とテンプレート追加）
class HomeScreen extends StatefulWidget {
  final List<FoodItem> foods;
  final List<FoodTemplate> customTemplates;
  final Function(List<FoodItem>) onFoodsChanged;
  final Function(List<FoodTemplate>) onTemplatesChanged;

  const HomeScreen({
    super.key,
    required this.foods,
    required this.customTemplates,
    required this.onFoodsChanged,
    required this.onTemplatesChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSubCategoryId = '';
  String _sortMode = 'added'; // 'expiration', 'status', 'added' - 登録画面は追加順がデフォルト

  List<FoodItem> get _foods => widget.foods;
  List<FoodTemplate> get _customTemplates => widget.customTemplates;
  List<FoodTemplate> get _allTemplates =>
      [...defaultTemplates, ..._customTemplates];

  int get _expiredCount => _foods.where((f) => f.isExpired).length;
  int get _warningCount => _foods.where((f) => f.isWarning).length;
  int get _safeCount =>
      _foods.where((f) => !f.isExpired && !f.isWarning).length;

  String _getTodayString() {
    final now = DateTime.now();
    final weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    final weekday = weekdays[now.weekday - 1];
    return '${now.month}/${now.day}($weekday)';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedSubCategoryId = '';
      });
    });
  }

  void _addFood(FoodItem food) {
    final updatedFoods = [..._foods, food];
    StorageService.saveFoods(updatedFoods);
    widget.onFoodsChanged(updatedFoods);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food.icon} ${food.name} を追加しました'),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateFood(FoodItem food) {
    final updatedFoods =
        _foods.map((f) => f.id == food.id ? food : f).toList();
    StorageService.saveFoods(updatedFoods);
    widget.onFoodsChanged(updatedFoods);
  }

  void _quickAddFromTemplate(FoodTemplate template) {
    final food = FoodItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: template.name,
      icon: template.icon,
      categoryId: template.categoryId,
      expirationDate:
          DateTime.now().add(Duration(days: template.defaultDays)),
    );
    _addFood(food);
  }

  void _addCustomTemplate(FoodTemplate template) {
    final updatedTemplates = [..._customTemplates, template];
    StorageService.saveCustomTemplates(updatedTemplates);
    widget.onTemplatesChanged(updatedTemplates);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${template.icon} ${template.name} をテンプレートに保存しました'),
        backgroundColor: const Color(0xFFFF9800),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteCustomTemplate(String id) {
    final updatedTemplates = _customTemplates.where((t) => t.id != id).toList();
    StorageService.saveCustomTemplates(updatedTemplates);
    widget.onTemplatesChanged(updatedTemplates);
  }

  void _updateCustomTemplate(FoodTemplate template) {
    final updatedTemplates = _customTemplates
        .map((t) => t.id == template.id ? template : t)
        .toList();
    StorageService.saveCustomTemplates(updatedTemplates);
    widget.onTemplatesChanged(updatedTemplates);
  }

  void _deleteFood(String id) {
    final updatedFoods = _foods.where((f) => f.id != id).toList();
    StorageService.saveFoods(updatedFoods);
    widget.onFoodsChanged(updatedFoods);
  }

  void _showMyTemplatesDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ヘッダー
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.bookmark, color: Color(0xFFFF9800), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'マイテンプレート',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_customTemplates.length}件のカスタムテンプレート',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // テンプレート一覧
              Expanded(
                child: _customTemplates.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'マイテンプレートがありません',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'カスタム追加時に「テンプレートとして保存」を\nチェックすると追加されます',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[400], fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _customTemplates.length,
                        itemBuilder: (context, index) {
                          final template = _customTemplates[index];
                          final category = defaultCategories.firstWhere(
                            (c) => c.id == template.categoryId,
                            orElse: () => defaultCategories.first,
                          );
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: category.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(template.icon, style: const TextStyle(fontSize: 24)),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    template.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: category.color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(category.icon, style: const TextStyle(fontSize: 10)),
                                        const SizedBox(width: 4),
                                        Text(
                                          category.name,
                                          style: TextStyle(
                                            color: category.color,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                'デフォルト保存期限: ${template.defaultDays}日',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 編集ボタン
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showEditTemplateDialog(template, category);
                                    },
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.edit, size: 18, color: Color(0xFF2196F3)),
                                    ),
                                  ),
                                  // 削除ボタン
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showDeleteTemplateConfirmDialog(template);
                                    },
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE53935).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.delete, size: 18, color: Color(0xFFE53935)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // 使い方のヒント
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, size: 18, color: Color(0xFFFF9800)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'テンプレートを長押しすると編集・削除できます',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          // マイテンプレート管理ボタン
          if (_customTemplates.isNotEmpty)
            GestureDetector(
              onTap: () => _showMyTemplatesDialog(),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bookmark, size: 14, color: Color(0xFFFF9800)),
                    const SizedBox(width: 4),
                    Text(
                      'マイ(${_customTemplates.length})',
                      style: const TextStyle(
                        color: Color(0xFFFF9800),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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
              padding: const EdgeInsets.only(right: 4),
              child: MiniTag(
                  icon: '⚠️',
                  count: _warningCount,
                  color: const Color(0xFFFF9800)),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: MiniTag(
                icon: '✅',
                count: _safeCount,
                color: const Color(0xFF4CAF50)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2196F3),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2196F3),
          indicatorWeight: 3,
          tabs: defaultCategories
              .map((cat) => Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(cat.name,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: defaultCategories.map((cat) {
          final items = _foods.where((f) => f.categoryId == cat.id).toList();
          final subCategories = defaultSubCategories
              .where((s) => s.parentCategoryId == cat.id)
              .toList();
          return _buildCategoryPage(items, subCategories, cat);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('カスタム追加',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  List<FoodItem> _getSortedItems(List<FoodItem> items) {
    final sortedItems = List<FoodItem>.from(items);
    switch (_sortMode) {
      case 'expiration':
        sortedItems.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
        break;
      case 'status':
        sortedItems.sort((a, b) {
          if (a.isExpired != b.isExpired) return a.isExpired ? -1 : 1;
          if (a.isWarning != b.isWarning) return a.isWarning ? -1 : 1;
          return a.expirationDate.compareTo(b.expirationDate);
        });
        break;
      case 'added':
        sortedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return sortedItems;
  }

  Widget _buildCategoryPage(
      List<FoodItem> items, List<SubCategory> subCategories, Category category) {
    final sortedItems = _getSortedItems(items);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // サブカテゴリ選択
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.category, color: category.color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '種類を選択',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: category.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: subCategories.map((sub) {
                    final isSelected = _selectedSubCategoryId == sub.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSubCategoryId = isSelected ? '' : sub.id;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? category.color
                              : category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(sub.icon, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              sub.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : category.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ワンタップ追加セクション
          if (_selectedSubCategoryId.isNotEmpty) ...[
            _buildTemplateSection(category),
            const SizedBox(height: 16),
          ],

          // 登録済みアイテムセクション + ソート
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(category.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '${category.name}の食材',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${items.length}件',
                      style: TextStyle(
                          color: category.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
              // ソート切り替えボタン
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_sortMode == 'added') {
                      _sortMode = 'expiration';
                    } else if (_sortMode == 'expiration') {
                      _sortMode = 'status';
                    } else {
                      _sortMode = 'added';
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _sortMode == 'added'
                            ? Icons.history
                            : _sortMode == 'expiration'
                                ? Icons.schedule
                                : Icons.priority_high,
                        size: 14,
                        color: const Color(0xFF2196F3),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _sortMode == 'added'
                            ? '追加順'
                            : _sortMode == 'expiration'
                                ? '期限順'
                                : '緊急度順',
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      '種類を選んで\n食材を追加しましょう',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ...sortedItems.map((food) => _buildFoodCard(food, category)),
        ],
      ),
    );
  }

  Widget _buildTemplateSection(Category category) {
    final templates = _allTemplates
        .where((t) =>
            t.categoryId == category.id &&
            t.subCategoryId == _selectedSubCategoryId)
        .toList();

    if (templates.isEmpty) return const SizedBox.shrink();

    final subCategory = defaultSubCategories.firstWhere(
      (s) => s.id == _selectedSubCategoryId,
      orElse: () => const SubCategory(
          id: '', name: '', icon: '', parentCategoryId: ''),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(subCategory.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                '${subCategory.name}をワンタップ追加',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: category.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: templates
                .map((template) => _buildTemplateButton(template, category))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateButton(FoodTemplate template, Category category) {
    final isCustom = template.id.startsWith('custom_');
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _quickAddFromTemplate(template),
        onLongPress: isCustom ? () => _showTemplateOptionsDialog(template, category) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCustom 
                  ? const Color(0xFFFF9800).withValues(alpha: 0.5)
                  : category.color.withValues(alpha: 0.3),
              width: isCustom ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(template.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        template.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (isCustom) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.bookmark, size: 12, color: Color(0xFFFF9800)),
                      ],
                    ],
                  ),
                  Text(
                    '${template.defaultDays}日',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
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

  void _showTemplateOptionsDialog(FoodTemplate template, Category category) {
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
                    child: Text(template.icon, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            template.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bookmark, size: 12, color: Color(0xFFFF9800)),
                                SizedBox(width: 4),
                                Text(
                                  'マイテンプレート',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFFFF9800),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '保存期限: ${template.defaultDays}日',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 編集ボタン
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit, color: Color(0xFF2196F3)),
              ),
              title: const Text('テンプレートを編集', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('名前・アイコン・保存期限を変更', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                _showEditTemplateDialog(template, category);
              },
            ),
            const SizedBox(height: 8),
            // 削除ボタン
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Color(0xFFE53935)),
              ),
              title: const Text('テンプレートを削除', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFE53935))),
              subtitle: const Text('このテンプレートを完全に削除', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                _showDeleteTemplateConfirmDialog(template);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditTemplateDialog(FoodTemplate template, Category category) {
    final nameController = TextEditingController(text: template.name);
    String selectedIcon = template.icon;
    int defaultDays = template.defaultDays;

    final icons = ['🥛', '🧀', '🥚', '🥩', '🍖', '🐟', '🐔', '🥬', '🥕', '🍅', '🥒', '🍎', '🍊', '🍌', '🍞', '🍚', '🍜', '🥫', '🍵', '🧃', '🍺', '🍷', '🧁', '🍰', '🍫', '🍿', '🥜', '🌶️', '🧄', '🧅'];

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
                    const Icon(Icons.edit, color: Color(0xFF2196F3)),
                    const SizedBox(width: 8),
                    const Text(
                      'テンプレートを編集',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // アイコン選択
                const Text('アイコン', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: icons.length,
                    itemBuilder: (context, index) {
                      final icon = icons[index];
                      final isSelected = icon == selectedIcon;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedIcon = icon),
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? category.color.withValues(alpha: 0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected ? Border.all(color: category.color, width: 2) : null,
                          ),
                          child: Center(
                            child: Text(icon, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // 名前入力
                const Text('テンプレート名', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'テンプレート名を入力',
                    prefixIcon: Text(selectedIcon, style: const TextStyle(fontSize: 20)),
                    prefixIconConstraints: const BoxConstraints(minWidth: 48),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: category.color, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 保存期限
                const Text('デフォルト保存期限（日）', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (defaultDays > 1) {
                          setModalState(() => defaultDays--);
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.remove, color: category.color),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Text(
                            '$defaultDays 日',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (defaultDays < 365) {
                          setModalState(() => defaultDays++);
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.add, color: category.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // クイック日数ボタン
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [3, 5, 7, 14, 30, 60, 90].map((days) {
                    return GestureDetector(
                      onTap: () => setModalState(() => defaultDays = days),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: defaultDays == days ? category.color : category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$days日',
                          style: TextStyle(
                            color: defaultDays == days ? Colors.white : category.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
                          
                          final updatedTemplate = FoodTemplate(
                            id: template.id,
                            name: nameController.text.trim(),
                            icon: selectedIcon,
                            categoryId: template.categoryId,
                            subCategoryId: template.subCategoryId,
                            defaultDays: defaultDays,
                          );
                          _updateCustomTemplate(updatedTemplate);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$selectedIcon ${nameController.text.trim()} を更新しました'),
                              backgroundColor: const Color(0xFF2196F3),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('保存', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showDeleteTemplateConfirmDialog(FoodTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Color(0xFFE53935)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('テンプレートを削除', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(template.icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(template.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('保存期限: ${template.defaultDays}日', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'このテンプレートを削除しますか？\nこの操作は取り消せません。',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteCustomTemplate(template.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${template.icon} ${template.name} を削除しました'),
                  backgroundColor: const Color(0xFFE53935),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(FoodItem food, Category category) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (food.isExpired) {
      statusColor = const Color(0xFFE53935);
      statusText = '期限切れ';
      statusIcon = Icons.error;
    } else if (food.isWarning) {
      statusColor = const Color(0xFFFF9800);
      statusText = 'あと${food.daysUntilExpiration}日';
      statusIcon = Icons.warning;
    } else {
      statusColor = const Color(0xFF4CAF50);
      statusText = 'あと${food.daysUntilExpiration}日';
      statusIcon = Icons.check_circle;
    }

    return Dismissible(
      key: Key(food.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteFood(food.id),
      child: GestureDetector(
        onTap: () => _showEditDialog(food, category),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(food.icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            title: Text(
              food.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Row(
              children: [
                Text(
                  '〜 ${food.expirationDate.month}/${food.expirationDate.day}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit, size: 14, color: Colors.grey[400]),
                Text(
                  ' タップで編集',
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(FoodItem food, Category category) {
    DateTime selectedDate = food.expirationDate;
    final nameController = TextEditingController(text: food.name);

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
                            style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '食材を編集',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '登録日: ${food.createdAt.month}/${food.createdAt.day}',
                            style:
                                TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 名前編集フィールド
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('食材名',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: '食材名を入力',
                    prefixIcon: Text(food.icon,
                        style: const TextStyle(fontSize: 20)),
                    prefixIconConstraints: const BoxConstraints(minWidth: 48),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: category.color, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('賞味期限',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setModalState(() => selectedDate = date);
                    }
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
                const SizedBox(height: 8),
                // クイック日付変更ボタン
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildQuickDateButton('-1日', () {
                      setModalState(() {
                        selectedDate =
                            selectedDate.subtract(const Duration(days: 1));
                      });
                    }, Colors.red),
                    _buildQuickDateButton('+1日', () {
                      setModalState(() {
                        selectedDate = selectedDate.add(const Duration(days: 1));
                      });
                    }, category.color),
                    _buildQuickDateButton('+3日', () {
                      setModalState(() {
                        selectedDate = selectedDate.add(const Duration(days: 3));
                      });
                    }, category.color),
                    _buildQuickDateButton('+7日', () {
                      setModalState(() {
                        selectedDate = selectedDate.add(const Duration(days: 7));
                      });
                    }, category.color),
                    _buildQuickDateButton('今日', () {
                      setModalState(() {
                        selectedDate = DateTime.now();
                      });
                    }, category.color),
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
                          final newName = nameController.text.trim();
                          if (newName.isEmpty) return;
                          
                          final updatedFood = food.copyWith(
                            name: newName,
                            expirationDate: selectedDate,
                          );
                          _updateFood(updatedFood);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${food.icon} $newName を更新しました'),
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
                        child: const Text(
                          '保存する',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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

  Widget _buildQuickDateButton(String label, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    String selectedCategoryId = defaultCategories[_tabController.index].id;
    String selectedIcon = '🍽️';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    int defaultDays = 7;
    bool saveAsTemplate = false;

    final iconOptions = [
      '🍽️',
      '🥗',
      '🍱',
      '🥘',
      '🍲',
      '🥙',
      '🌮',
      '🌯',
      '🍛',
      '🍝',
      '🥪',
      '🍔',
      '🍟',
      '🍕',
      '🌭',
      '🥓',
      '🍗',
      '🍖',
      '🦴',
      '🌶️',
      '🫑',
      '🥒',
      '🥕',
      '🧅',
      '🧄',
      '🥔',
      '🍠',
      '🫘',
      '🥜',
      '🍇',
      '🍈',
      '🍉',
      '🍊',
      '🍋',
      '🍌',
      '🍍',
      '🥭',
      '🍎',
      '🍏',
      '🍐',
      '🍑',
      '🍒',
      '🍓',
      '🫐',
      '🥝',
      '🐟',
      '🦐',
      '🦑',
      '🐚',
      '🥩',
      '🥛',
      '🥚',
      '🧀',
      '🧈',
      '🍞',
      '🥐',
      '🥖'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
                  'カスタム食材を追加',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text('アイコン',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 10,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: iconOptions.length,
                    itemBuilder: (context, index) {
                      final icon = iconOptions[index];
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedIcon = icon),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2196F3)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child:
                                Text(icon, style: const TextStyle(fontSize: 18)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '食材名',
                    hintText: '例: 手作りサラダ',
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
                const Text('カテゴリ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: defaultCategories.map((cat) {
                    final isSelected = selectedCategoryId == cat.id;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setModalState(() => selectedCategoryId = cat.id),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? cat.color : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(cat.icon,
                                  style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(
                                cat.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('賞味期限',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setModalState(() {
                        selectedDate = date;
                        defaultDays = date.difference(DateTime.now()).inDays;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Color(0xFF2196F3)),
                        const SizedBox(width: 12),
                        Text(
                          '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: saveAsTemplate,
                        onChanged: (v) =>
                            setModalState(() => saveAsTemplate = v ?? false),
                        activeColor: const Color(0xFFFF9800),
                      ),
                      const Expanded(
                        child: Text('テンプレートとして保存',
                            style: TextStyle(fontSize: 13)),
                      ),
                      const Icon(Icons.bookmark, color: Color(0xFFFF9800)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty) return;

                      final food = FoodItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        icon: selectedIcon,
                        categoryId: selectedCategoryId,
                        expirationDate: selectedDate,
                      );
                      _addFood(food);

                      if (saveAsTemplate) {
                        final template = FoodTemplate(
                          id:
                              'custom_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameController.text.trim(),
                          icon: selectedIcon,
                          categoryId: selectedCategoryId,
                          subCategoryId: 'other',
                          defaultDays: defaultDays,
                        );
                        _addCustomTemplate(template);
                      }

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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
