import '../models/food_item.dart';
import '../models/food_template.dart';

/// ソート種別
enum SortType {
  expirationDate,  // 期限順
  registeredDate,  // 登録順
  name,            // 名前順
}

/// ソートヘルパー関数
class SortHelper {
  /// 食品リストをソート
  static List<FoodItem> sortFoods(List<FoodItem> foods, SortType sortType) {
    final sortedList = List<FoodItem>.from(foods);
    
    switch (sortType) {
      case SortType.expirationDate:
        sortedList.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
        break;
      case SortType.registeredDate:
        sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortType.name:
        sortedList.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    return sortedList;
  }

  /// テンプレートリストをソート
  static List<FoodTemplate> sortTemplates(
    List<FoodTemplate> templates,
    SortType sortType,
  ) {
    final sortedList = List<FoodTemplate>.from(templates);
    
    switch (sortType) {
      case SortType.expirationDate:
        // テンプレートの場合は期限日数でソート
        sortedList.sort((a, b) => a.defaultDays.compareTo(b.defaultDays));
        break;
      case SortType.name:
        sortedList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortType.registeredDate:
        // テンプレートは登録順ソート非対応（元の順序を維持）
        break;
    }
    
    return sortedList;
  }

  /// ソート種別の表示名を取得
  static String getSortTypeName(SortType sortType) {
    switch (sortType) {
      case SortType.expirationDate:
        return '期限順';
      case SortType.registeredDate:
        return '登録順';
      case SortType.name:
        return '名前順';
    }
  }
}
