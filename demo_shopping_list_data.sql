-- ============================================
-- デモアカウント用買い物リストサンプルデータ
-- デモアカウントUser ID: ca2b3523-9472-43b9-a71a-2549b48c60ee
-- ============================================

-- 1. 既存の買い物リストデータを削除（デモアカウントのみ）
DELETE FROM shopping_list WHERE user_id = 'ca2b3523-9472-43b9-a71a-2549b48c60ee';

-- 2. 買い物リストサンプルデータを追加（5件）

-- ストックから追加された買い物アイテム（在庫切れ・少ない）
INSERT INTO shopping_list (id, user_id, name, icon, category_id, is_purchased, source, source_id, memo, created_at, updated_at) VALUES
('b1111111-1111-1111-1111-111111111111', 'ca2b3523-9472-43b9-a71a-2549b48c60ee', '醤油', '🍶', '調味料', FALSE, 'stock', NULL, 'いつものメーカー', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
('b2222222-2222-2222-2222-222222222222', 'ca2b3523-9472-43b9-a71a-2549b48c60ee', 'みりん', '🍶', '調味料', FALSE, 'stock', NULL, NULL, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
('b3333333-3333-3333-3333-333333333333', 'ca2b3523-9472-43b9-a71a-2549b48c60ee', 'サラダ油', '🛢️', '調味料', FALSE, 'stock', NULL, '大容量', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day');

-- 食材から追加された買い物アイテム（期限切れ・近い）
INSERT INTO shopping_list (id, user_id, name, icon, category_id, is_purchased, source, source_id, memo, created_at, updated_at) VALUES
('b4444444-4444-4444-4444-444444444444', 'ca2b3523-9472-43b9-a71a-2549b48c60ee', '牛乳', '🥛', '乳製品', FALSE, 'food', NULL, '低脂肪', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
('b5555555-5555-5555-5555-555555555555', 'ca2b3523-9472-43b9-a71a-2549b48c60ee', '卵', '🥚', '卵・乳製品', FALSE, 'food', NULL, '10個入り', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days');

-- 3. 登録確認
SELECT 
  'shopping_list' as table_name,
  COUNT(*) as record_count
FROM shopping_list 
WHERE user_id = 'ca2b3523-9472-43b9-a71a-2549b48c60ee';

-- ============================================
-- 期待される結果:
-- shopping_list: 5 records
-- ============================================
