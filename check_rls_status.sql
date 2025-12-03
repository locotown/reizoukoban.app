-- ============================================
-- RLS (Row Level Security) 状況確認スクリプト
-- ============================================

-- 1. RLS有効化状況の確認
SELECT 
  schemaname,
  tablename,
  rowsecurity AS "RLS Enabled"
FROM pg_tables
WHERE tablename IN ('foods', 'stocks', 'custom_templates')
ORDER BY tablename;

-- 2. 適用されているポリシーの一覧
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd AS "Command",
  qual AS "USING Expression",
  with_check AS "WITH CHECK Expression"
FROM pg_policies
WHERE tablename IN ('foods', 'stocks', 'custom_templates')
ORDER BY tablename, policyname;

-- 3. テーブルのレコード数（各テーブルの現在のデータ量）
SELECT 'foods' AS table_name, COUNT(*) AS record_count FROM foods
UNION ALL
SELECT 'stocks' AS table_name, COUNT(*) AS record_count FROM stocks
UNION ALL
SELECT 'custom_templates' AS table_name, COUNT(*) AS record_count FROM custom_templates;

-- 4. user_idが設定されているレコード数の確認
SELECT 'foods' AS table_name, 
       COUNT(*) AS total_records,
       COUNT(user_id) AS records_with_user_id,
       COUNT(*) - COUNT(user_id) AS records_without_user_id
FROM foods
UNION ALL
SELECT 'stocks' AS table_name, 
       COUNT(*) AS total_records,
       COUNT(user_id) AS records_with_user_id,
       COUNT(*) - COUNT(user_id) AS records_without_user_id
FROM stocks
UNION ALL
SELECT 'custom_templates' AS table_name, 
       COUNT(*) AS total_records,
       COUNT(user_id) AS records_with_user_id,
       COUNT(*) - COUNT(user_id) AS records_without_user_id
FROM custom_templates;
