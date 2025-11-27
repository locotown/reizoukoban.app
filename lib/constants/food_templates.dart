import '../models/food_template.dart';

const List<FoodTemplate> defaultTemplates = [
  // === 冷蔵 - 肉類 ===
  FoodTemplate(id: 't1', name: '豚ロース', icon: '🥩', categoryId: 'refrigerated', subCategoryId: 'meat', defaultDays: 3),
  FoodTemplate(id: 't2', name: '豚バラ', icon: '🥓', categoryId: 'refrigerated', subCategoryId: 'meat', defaultDays: 3),
  FoodTemplate(id: 't3', name: '鶏もも', icon: '🍗', categoryId: 'refrigerated', subCategoryId: 'meat', defaultDays: 2),
  FoodTemplate(id: 't4', name: '鶏むね', icon: '🍗', categoryId: 'refrigerated', subCategoryId: 'meat', defaultDays: 2),
  FoodTemplate(id: 't5', name: '牛肉', icon: '🥩', categoryId: 'refrigerated', subCategoryId: 'meat', defaultDays: 3),
  FoodTemplate(id: 't6', name: 'ひき肉', icon: '🍖', categoryId: 'refrigerated', subCategoryId: 'meat', defaultDays: 2),
  FoodTemplate(id: 't7', name: 'ベーコン', icon: '🥓', categoryId: 'refrigerated', subCategoryId: 'meat', defaultDays: 7),
  FoodTemplate(id: 't8', name: 'ハム', icon: '🍖', categoryId: 'refrigerated', subCategoryId: 'meat', defaultDays: 7),
  
  // === 冷蔵 - 魚介類 ===
  FoodTemplate(id: 't9', name: '秋刀魚', icon: '🐟', categoryId: 'refrigerated', subCategoryId: 'fish', defaultDays: 2),
  FoodTemplate(id: 't10', name: '鮭', icon: '🐟', categoryId: 'refrigerated', subCategoryId: 'fish', defaultDays: 2),
  FoodTemplate(id: 't11', name: '鯖', icon: '🐟', categoryId: 'refrigerated', subCategoryId: 'fish', defaultDays: 2),
  FoodTemplate(id: 't12', name: 'マグロ', icon: '🍣', categoryId: 'refrigerated', subCategoryId: 'fish', defaultDays: 1),
  FoodTemplate(id: 't13', name: 'エビ', icon: '🦐', categoryId: 'refrigerated', subCategoryId: 'fish', defaultDays: 2),
  FoodTemplate(id: 't14', name: 'イカ', icon: '🦑', categoryId: 'refrigerated', subCategoryId: 'fish', defaultDays: 2),
  FoodTemplate(id: 't15', name: 'アサリ', icon: '🐚', categoryId: 'refrigerated', subCategoryId: 'fish', defaultDays: 1),
  
  // === 冷蔵 - 野菜 ===
  FoodTemplate(id: 't16', name: 'キャベツ', icon: '🥬', categoryId: 'refrigerated', subCategoryId: 'vegetable', defaultDays: 7),
  FoodTemplate(id: 't17', name: 'レタス', icon: '🥬', categoryId: 'refrigerated', subCategoryId: 'vegetable', defaultDays: 5),
  FoodTemplate(id: 't18', name: '人参', icon: '🥕', categoryId: 'refrigerated', subCategoryId: 'vegetable', defaultDays: 14),
  FoodTemplate(id: 't19', name: '玉ねぎ', icon: '🧅', categoryId: 'refrigerated', subCategoryId: 'vegetable', defaultDays: 30),
  FoodTemplate(id: 't20', name: 'じゃがいも', icon: '🥔', categoryId: 'refrigerated', subCategoryId: 'vegetable', defaultDays: 21),
  FoodTemplate(id: 't21', name: 'トマト', icon: '🍅', categoryId: 'refrigerated', subCategoryId: 'vegetable', defaultDays: 7),
  FoodTemplate(id: 't22', name: 'きゅうり', icon: '🥒', categoryId: 'refrigerated', subCategoryId: 'vegetable', defaultDays: 5),
  FoodTemplate(id: 't23', name: 'ほうれん草', icon: '🥬', categoryId: 'refrigerated', subCategoryId: 'vegetable', defaultDays: 3),
  FoodTemplate(id: 't24', name: 'もやし', icon: '🌱', categoryId: 'refrigerated', subCategoryId: 'vegetable', defaultDays: 2),
  FoodTemplate(id: 't25', name: 'ネギ', icon: '🧅', categoryId: 'refrigerated', subCategoryId: 'vegetable', defaultDays: 7),
  FoodTemplate(id: 't26', name: 'ピーマン', icon: '🫑', categoryId: 'refrigerated', subCategoryId: 'vegetable', defaultDays: 7),
  FoodTemplate(id: 't27', name: 'なす', icon: '🍆', categoryId: 'refrigerated', subCategoryId: 'vegetable', defaultDays: 5),
  
  // === 冷蔵 - フルーツ ===
  FoodTemplate(id: 't28', name: 'りんご', icon: '🍎', categoryId: 'refrigerated', subCategoryId: 'fruit', defaultDays: 14),
  FoodTemplate(id: 't29', name: 'みかん', icon: '🍊', categoryId: 'refrigerated', subCategoryId: 'fruit', defaultDays: 14),
  FoodTemplate(id: 't30', name: 'バナナ', icon: '🍌', categoryId: 'refrigerated', subCategoryId: 'fruit', defaultDays: 5),
  FoodTemplate(id: 't31', name: 'いちご', icon: '🍓', categoryId: 'refrigerated', subCategoryId: 'fruit', defaultDays: 3),
  FoodTemplate(id: 't32', name: 'ぶどう', icon: '🍇', categoryId: 'refrigerated', subCategoryId: 'fruit', defaultDays: 5),
  FoodTemplate(id: 't33', name: 'キウイ', icon: '🥝', categoryId: 'refrigerated', subCategoryId: 'fruit', defaultDays: 7),
  FoodTemplate(id: 't34', name: 'レモン', icon: '🍋', categoryId: 'refrigerated', subCategoryId: 'fruit', defaultDays: 21),
  FoodTemplate(id: 't35', name: '桃', icon: '🍑', categoryId: 'refrigerated', subCategoryId: 'fruit', defaultDays: 3),
  FoodTemplate(id: 't36', name: 'メロン', icon: '🍈', categoryId: 'refrigerated', subCategoryId: 'fruit', defaultDays: 5),
  FoodTemplate(id: 't37', name: 'スイカ', icon: '🍉', categoryId: 'refrigerated', subCategoryId: 'fruit', defaultDays: 3),
  
  // === 冷蔵 - 乳製品 ===
  FoodTemplate(id: 't38', name: '牛乳', icon: '🥛', categoryId: 'refrigerated', subCategoryId: 'dairy', defaultDays: 7),
  FoodTemplate(id: 't39', name: '卵', icon: '🥚', categoryId: 'refrigerated', subCategoryId: 'dairy', defaultDays: 14),
  FoodTemplate(id: 't40', name: 'ヨーグルト', icon: '🥣', categoryId: 'refrigerated', subCategoryId: 'dairy', defaultDays: 10),
  FoodTemplate(id: 't41', name: 'チーズ', icon: '🧀', categoryId: 'refrigerated', subCategoryId: 'dairy', defaultDays: 21),
  FoodTemplate(id: 't42', name: 'バター', icon: '🧈', categoryId: 'refrigerated', subCategoryId: 'dairy', defaultDays: 30),
  FoodTemplate(id: 't43', name: '豆腐', icon: '🧈', categoryId: 'refrigerated', subCategoryId: 'dairy', defaultDays: 5),
  FoodTemplate(id: 't44', name: '納豆', icon: '🫘', categoryId: 'refrigerated', subCategoryId: 'dairy', defaultDays: 7),
  
  // === 冷凍 - 肉 ===
  FoodTemplate(id: 't45', name: '冷凍豚肉', icon: '🍖', categoryId: 'frozen', subCategoryId: 'frozen_meat', defaultDays: 90),
  FoodTemplate(id: 't46', name: '冷凍鶏肉', icon: '🍗', categoryId: 'frozen', subCategoryId: 'frozen_meat', defaultDays: 90),
  FoodTemplate(id: 't47', name: '冷凍牛肉', icon: '🥩', categoryId: 'frozen', subCategoryId: 'frozen_meat', defaultDays: 90),
  FoodTemplate(id: 't48', name: '冷凍ひき肉', icon: '🍖', categoryId: 'frozen', subCategoryId: 'frozen_meat', defaultDays: 60),
  
  // === 冷凍 - 魚 ===
  FoodTemplate(id: 't49', name: '冷凍鮭', icon: '🐟', categoryId: 'frozen', subCategoryId: 'frozen_fish', defaultDays: 60),
  FoodTemplate(id: 't50', name: '冷凍エビ', icon: '🦐', categoryId: 'frozen', subCategoryId: 'frozen_fish', defaultDays: 90),
  FoodTemplate(id: 't51', name: '冷凍イカ', icon: '🦑', categoryId: 'frozen', subCategoryId: 'frozen_fish', defaultDays: 90),
  
  // === 冷凍 - 野菜 ===
  FoodTemplate(id: 't52', name: '冷凍ブロッコリー', icon: '🥦', categoryId: 'frozen', subCategoryId: 'frozen_veg', defaultDays: 60),
  FoodTemplate(id: 't53', name: '冷凍枝豆', icon: '🫛', categoryId: 'frozen', subCategoryId: 'frozen_veg', defaultDays: 90),
  FoodTemplate(id: 't54', name: 'ミックスベジタブル', icon: '🥗', categoryId: 'frozen', subCategoryId: 'frozen_veg', defaultDays: 60),
  
  // === 冷凍 - 冷凍食品 ===
  FoodTemplate(id: 't55', name: '冷凍餃子', icon: '🥟', categoryId: 'frozen', subCategoryId: 'frozen_meal', defaultDays: 60),
  FoodTemplate(id: 't56', name: '冷凍ピザ', icon: '🍕', categoryId: 'frozen', subCategoryId: 'frozen_meal', defaultDays: 90),
  FoodTemplate(id: 't57', name: '冷凍ご飯', icon: '🍚', categoryId: 'frozen', subCategoryId: 'frozen_meal', defaultDays: 30),
  FoodTemplate(id: 't58', name: '冷凍うどん', icon: '🍜', categoryId: 'frozen', subCategoryId: 'frozen_meal', defaultDays: 60),
  FoodTemplate(id: 't59', name: '冷凍チャーハン', icon: '🍳', categoryId: 'frozen', subCategoryId: 'frozen_meal', defaultDays: 60),
  
  // === 冷凍 - アイス ===
  FoodTemplate(id: 't60', name: 'アイスクリーム', icon: '🍦', categoryId: 'frozen', subCategoryId: 'ice_cream', defaultDays: 180),
  FoodTemplate(id: 't61', name: 'アイスバー', icon: '🍧', categoryId: 'frozen', subCategoryId: 'ice_cream', defaultDays: 180),
  
  // === 常温 - パン ===
  FoodTemplate(id: 't62', name: '食パン', icon: '🍞', categoryId: 'pantry', subCategoryId: 'bread', defaultDays: 4),
  FoodTemplate(id: 't63', name: 'ロールパン', icon: '🥐', categoryId: 'pantry', subCategoryId: 'bread', defaultDays: 3),
  FoodTemplate(id: 't64', name: 'フランスパン', icon: '🥖', categoryId: 'pantry', subCategoryId: 'bread', defaultDays: 2),
  
  // === 常温 - 麺類 ===
  FoodTemplate(id: 't65', name: 'カップ麺', icon: '🍜', categoryId: 'pantry', subCategoryId: 'noodle', defaultDays: 180),
  FoodTemplate(id: 't66', name: '袋麺', icon: '🍜', categoryId: 'pantry', subCategoryId: 'noodle', defaultDays: 180),
  FoodTemplate(id: 't67', name: 'パスタ', icon: '🍝', categoryId: 'pantry', subCategoryId: 'noodle', defaultDays: 365),
  FoodTemplate(id: 't68', name: 'そうめん', icon: '🍜', categoryId: 'pantry', subCategoryId: 'noodle', defaultDays: 365),
  
  // === 常温 - 缶詰 ===
  FoodTemplate(id: 't69', name: 'ツナ缶', icon: '🥫', categoryId: 'pantry', subCategoryId: 'canned', defaultDays: 365),
  FoodTemplate(id: 't70', name: 'トマト缶', icon: '🥫', categoryId: 'pantry', subCategoryId: 'canned', defaultDays: 365),
  FoodTemplate(id: 't71', name: 'コーン缶', icon: '🥫', categoryId: 'pantry', subCategoryId: 'canned', defaultDays: 365),
  FoodTemplate(id: 't72', name: 'フルーツ缶', icon: '🥫', categoryId: 'pantry', subCategoryId: 'canned', defaultDays: 365),
  
  // === 常温 - お菓子 ===
  FoodTemplate(id: 't73', name: 'クッキー', icon: '🍪', categoryId: 'pantry', subCategoryId: 'snack', defaultDays: 60),
  FoodTemplate(id: 't74', name: 'チョコレート', icon: '🍫', categoryId: 'pantry', subCategoryId: 'snack', defaultDays: 180),
  FoodTemplate(id: 't75', name: 'ポテトチップス', icon: '🥔', categoryId: 'pantry', subCategoryId: 'snack', defaultDays: 60),
  
  // === 常温 - 調味料 ===
  FoodTemplate(id: 't76', name: '醤油', icon: '🧂', categoryId: 'pantry', subCategoryId: 'seasoning', defaultDays: 180),
  FoodTemplate(id: 't77', name: 'みりん', icon: '🍶', categoryId: 'pantry', subCategoryId: 'seasoning', defaultDays: 180),
  FoodTemplate(id: 't78', name: 'お米', icon: '🌾', categoryId: 'pantry', subCategoryId: 'seasoning', defaultDays: 60),
  
  // === 冷蔵 - その他 ===
  FoodTemplate(id: 't79', name: '肉まん', icon: '🥟', categoryId: 'refrigerated', subCategoryId: 'other_ref', defaultDays: 3),
  FoodTemplate(id: 't80', name: 'あんまん', icon: '🥮', categoryId: 'refrigerated', subCategoryId: 'other_ref', defaultDays: 3),
  FoodTemplate(id: 't81', name: '惣菜', icon: '🍱', categoryId: 'refrigerated', subCategoryId: 'other_ref', defaultDays: 2),
  FoodTemplate(id: 't82', name: 'サラダ', icon: '🥗', categoryId: 'refrigerated', subCategoryId: 'other_ref', defaultDays: 1),
  FoodTemplate(id: 't83', name: 'お弁当', icon: '🍱', categoryId: 'refrigerated', subCategoryId: 'other_ref', defaultDays: 1),
  FoodTemplate(id: 't84', name: 'デザート', icon: '🍮', categoryId: 'refrigerated', subCategoryId: 'other_ref', defaultDays: 3),
  FoodTemplate(id: 't85', name: 'ケーキ', icon: '🍰', categoryId: 'refrigerated', subCategoryId: 'other_ref', defaultDays: 3),
  FoodTemplate(id: 't86', name: 'プリン', icon: '🍮', categoryId: 'refrigerated', subCategoryId: 'other_ref', defaultDays: 5),
  
  // === 冷凍 - その他 ===
  FoodTemplate(id: 't87', name: '冷凍ケーキ', icon: '🍰', categoryId: 'frozen', subCategoryId: 'other_frozen', defaultDays: 90),
  FoodTemplate(id: 't88', name: '冷凍パン', icon: '🍞', categoryId: 'frozen', subCategoryId: 'other_frozen', defaultDays: 30),
  FoodTemplate(id: 't89', name: '保冷剤', icon: '🧊', categoryId: 'frozen', subCategoryId: 'other_frozen', defaultDays: 365),
  
  // === 常温 - その他 ===
  FoodTemplate(id: 't90', name: 'ドリンク', icon: '🧃', categoryId: 'pantry', subCategoryId: 'other_pantry', defaultDays: 180),
  FoodTemplate(id: 't91', name: 'お茶', icon: '🍵', categoryId: 'pantry', subCategoryId: 'other_pantry', defaultDays: 365),
  FoodTemplate(id: 't92', name: 'コーヒー', icon: '☕', categoryId: 'pantry', subCategoryId: 'other_pantry', defaultDays: 365),
  FoodTemplate(id: 't93', name: 'レトルト', icon: '🍛', categoryId: 'pantry', subCategoryId: 'other_pantry', defaultDays: 180),
  FoodTemplate(id: 't94', name: 'ふりかけ', icon: '🍚', categoryId: 'pantry', subCategoryId: 'other_pantry', defaultDays: 180),
];
