-- ============================================
-- デモアカウント用サンプルデータ作成
-- 冷蔵庫番アプリ - デモモード専用
-- ============================================

-- 注意: 'DEMO_USER_ID' を実際のデモアカウントのUser IDに置き換えてください
-- デモアカウント: demo@reizoukoban.app

-- 1. 既存のデモデータを削除（クリーンスタート）
DELETE FROM foods WHERE user_id = 'DEMO_USER_ID';
DELETE FROM stocks WHERE user_id = 'DEMO_USER_ID';
DELETE FROM custom_templates WHERE user_id = 'DEMO_USER_ID';

-- 2. 冷蔵の食材（賞味期限が近いもの、切れているもの、余裕があるもの）
INSERT INTO foods (user_id, name, icon, expiry_date, category, location, memo, created_at) VALUES
-- 期限切れ（赤色表示のテスト）
('DEMO_USER_ID', '牛乳', '🥛', CURRENT_DATE - INTERVAL '2 days', '乳製品', '冷蔵', '開封済み', NOW() - INTERVAL '7 days'),
('DEMO_USER_ID', '納豆', '🫘', CURRENT_DATE - INTERVAL '1 day', '大豆製品', '冷蔵', '3パック入り', NOW() - INTERVAL '5 days'),

-- 期限が近い（黄色表示のテスト：3日以内）
('DEMO_USER_ID', 'ヨーグルト', '🥛', CURRENT_DATE + INTERVAL '2 days', '乳製品', '冷蔵', 'プレーン', NOW() - INTERVAL '4 days'),
('DEMO_USER_ID', '豆腐', '🧊', CURRENT_DATE + INTERVAL '3 days', '大豆製品', '冷蔵', '絹ごし', NOW() - INTERVAL '3 days'),
('DEMO_USER_ID', '卵', '🥚', CURRENT_DATE + INTERVAL '3 days', '卵・乳製品', '冷蔵', '6個入り', NOW() - INTERVAL '10 days'),

-- 期限に余裕（緑色表示のテスト：4日以上）
('DEMO_USER_ID', 'チーズ', '🧀', CURRENT_DATE + INTERVAL '14 days', '乳製品', '冷蔵', 'スライスチーズ', NOW() - INTERVAL '2 days'),
('DEMO_USER_ID', 'ハム', '🥓', CURRENT_DATE + INTERVAL '7 days', '加工肉', '冷蔵', 'ロースハム', NOW() - INTERVAL '1 day'),
('DEMO_USER_ID', 'レタス', '🥬', CURRENT_DATE + INTERVAL '5 days', '野菜', '冷蔵', '新鮮', NOW()),
('DEMO_USER_ID', 'トマト', '🍅', CURRENT_DATE + INTERVAL '6 days', '野菜', '冷蔵', '3個', NOW()),
('DEMO_USER_ID', 'バター', '🧈', CURRENT_DATE + INTERVAL '30 days', '乳製品', '冷蔵', '無塩', NOW() - INTERVAL '5 days');

-- 3. 冷凍の食材
INSERT INTO foods (user_id, name, icon, expiry_date, category, location, memo, created_at) VALUES
('DEMO_USER_ID', '冷凍餃子', '🥟', CURRENT_DATE + INTERVAL '60 days', '冷凍食品', '冷凍', '20個入り', NOW() - INTERVAL '15 days'),
('DEMO_USER_ID', 'アイスクリーム', '🍦', CURRENT_DATE + INTERVAL '90 days', 'デザート', '冷凍', 'バニラ', NOW() - INTERVAL '20 days'),
('DEMO_USER_ID', '冷凍ブロッコリー', '🥦', CURRENT_DATE + INTERVAL '120 days', '野菜', '冷凍', '便利', NOW() - INTERVAL '30 days');

-- 4. 常温保存の食材
INSERT INTO foods (user_id, name, icon, expiry_date, category, location, memo, created_at) VALUES
('DEMO_USER_ID', 'じゃがいも', '🥔', CURRENT_DATE + INTERVAL '14 days', '野菜', '常温', '5個', NOW() - INTERVAL '3 days'),
('DEMO_USER_ID', '玉ねぎ', '🧅', CURRENT_DATE + INTERVAL '21 days', '野菜', '常温', '3個', NOW() - INTERVAL '5 days'),
('DEMO_USER_ID', 'バナナ', '🍌', CURRENT_DATE + INTERVAL '4 days', '果物', '常温', '熟してきた', NOW() - INTERVAL '2 days'),
('DEMO_USER_ID', 'りんご', '🍎', CURRENT_DATE + INTERVAL '10 days', '果物', '常温', '青森産', NOW() - INTERVAL '1 day');

-- 5. 在庫管理（ストック）のサンプル
INSERT INTO stocks (user_id, name, icon, quantity, unit, min_quantity, category, location, memo, status, created_at) VALUES
-- 在庫切れ（赤色表示）
('DEMO_USER_ID', '醤油', '🍶', 0, '本', 1, '調味料', 'パントリー', '補充必要', 'out_of_stock', NOW() - INTERVAL '2 days'),
('DEMO_USER_ID', 'みりん', '🍶', 0, '本', 1, '調味料', 'パントリー', '切れた', 'out_of_stock', NOW() - INTERVAL '1 day'),

-- 在庫少ない（黄色表示）
('DEMO_USER_ID', 'サラダ油', '🛢️', 1, '本', 2, '調味料', 'パントリー', 'もうすぐなくなる', 'low', NOW() - INTERVAL '5 days'),
('DEMO_USER_ID', '砂糖', '🍬', 1, 'パック', 2, '調味料', 'パントリー', '残り少ない', 'low', NOW() - INTERVAL '3 days'),

-- 在庫十分（緑色表示）
('DEMO_USER_ID', '塩', '🧂', 3, '袋', 1, '調味料', 'パントリー', '', 'sufficient', NOW() - INTERVAL '10 days'),
('DEMO_USER_ID', 'お米', '🌾', 5, 'kg', 2, '主食', 'パントリー', '新米', 'sufficient', NOW() - INTERVAL '7 days'),
('DEMO_USER_ID', 'ティッシュ', '🧻', 4, '箱', 2, '日用品', 'リビング', '', 'sufficient', NOW() - INTERVAL '15 days'),
('DEMO_USER_ID', 'トイレットペーパー', '🧻', 6, 'ロール', 3, '日用品', 'トイレ', '', 'sufficient', NOW() - INTERVAL '20 days');

-- 6. カスタムテンプレート（よく使う食材）
INSERT INTO custom_templates (user_id, name, icon, category, memo, created_at) VALUES
('DEMO_USER_ID', '卵', '🥚', '卵・乳製品', 'よく買う', NOW() - INTERVAL '30 days'),
('DEMO_USER_ID', '牛乳', '🥛', '乳製品', 'よく買う', NOW() - INTERVAL '30 days'),
('DEMO_USER_ID', '豆腐', '🧊', '大豆製品', 'よく買う', NOW() - INTERVAL '30 days'),
('DEMO_USER_ID', 'ヨーグルト', '🥛', '乳製品', 'よく買う', NOW() - INTERVAL '30 days'),
('DEMO_USER_ID', 'もやし', '🌱', '野菜', 'よく買う', NOW() - INTERVAL '30 days');

-- 完了メッセージ
DO $$
BEGIN
  RAISE NOTICE '✅ デモアカウント用サンプルデータの作成が完了しました';
  RAISE NOTICE 'デモアカウント: demo@reizoukoban.app';
  RAISE NOTICE '食材数: 17件（冷蔵10件、冷凍3件、常温4件）';
  RAISE NOTICE 'ストック数: 8件（切れ2件、少ない2件、十分4件）';
  RAISE NOTICE 'テンプレート数: 5件';
END $$;
