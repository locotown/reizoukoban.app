-- ============================================
-- 買い物リストに数量カラムを追加
-- ============================================

-- 1. quantityカラムを追加（デフォルト値1）
ALTER TABLE shopping_list 
ADD COLUMN IF NOT EXISTS quantity INTEGER DEFAULT 1 NOT NULL;

-- 2. 既存データのquantityを1に設定（念のため）
UPDATE shopping_list 
SET quantity = 1 
WHERE quantity IS NULL OR quantity < 1;

-- 3. 制約を追加（数量は1以上）
ALTER TABLE shopping_list 
ADD CONSTRAINT quantity_positive CHECK (quantity >= 1);

-- ============================================
-- 完了
-- ============================================
-- 
-- 使い方:
-- 1. Supabaseダッシュボードにアクセス
-- 2. SQL Editorを開く
-- 3. このSQLをコピー&ペースト
-- 4. 「Run」ボタンをクリック
-- 
-- 確認方法:
-- SELECT * FROM shopping_list;
-- ============================================
