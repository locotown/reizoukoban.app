-- ============================================
-- Row Level Security (RLS) ポリシー設定
-- 冷蔵庫番アプリ - ユーザーデータ分離
-- ============================================

-- 1. 既存のポリシーを削除（クリーンスタート）
DROP POLICY IF EXISTS "Users can view own foods" ON foods;
DROP POLICY IF EXISTS "Users can insert own foods" ON foods;
DROP POLICY IF EXISTS "Users can update own foods" ON foods;
DROP POLICY IF EXISTS "Users can delete own foods" ON foods;

DROP POLICY IF EXISTS "Users can view own stocks" ON stocks;
DROP POLICY IF EXISTS "Users can insert own stocks" ON stocks;
DROP POLICY IF EXISTS "Users can update own stocks" ON stocks;
DROP POLICY IF EXISTS "Users can delete own stocks" ON stocks;

DROP POLICY IF EXISTS "Users can view own templates" ON custom_templates;
DROP POLICY IF EXISTS "Users can insert own templates" ON custom_templates;
DROP POLICY IF EXISTS "Users can update own templates" ON custom_templates;
DROP POLICY IF EXISTS "Users can delete own templates" ON custom_templates;

-- 2. RLSを有効化
ALTER TABLE foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE stocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_templates ENABLE ROW LEVEL SECURITY;

-- 3. foodsテーブルのポリシー
CREATE POLICY "Users can view own foods" 
ON foods FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own foods" 
ON foods FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own foods" 
ON foods FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own foods" 
ON foods FOR DELETE 
USING (auth.uid() = user_id);

-- 4. stocksテーブルのポリシー
CREATE POLICY "Users can view own stocks" 
ON stocks FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own stocks" 
ON stocks FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own stocks" 
ON stocks FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own stocks" 
ON stocks FOR DELETE 
USING (auth.uid() = user_id);

-- 5. custom_templatesテーブルのポリシー
CREATE POLICY "Users can view own templates" 
ON custom_templates FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own templates" 
ON custom_templates FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own templates" 
ON custom_templates FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own templates" 
ON custom_templates FOR DELETE 
USING (auth.uid() = user_id);

-- 6. インデックス作成（パフォーマンス最適化）
CREATE INDEX IF NOT EXISTS idx_foods_user_id ON foods(user_id);
CREATE INDEX IF NOT EXISTS idx_stocks_user_id ON stocks(user_id);
CREATE INDEX IF NOT EXISTS idx_custom_templates_user_id ON custom_templates(user_id);

-- 完了メッセージ
DO $$
BEGIN
  RAISE NOTICE '✅ RLSポリシーの設定が完了しました';
  RAISE NOTICE '各ユーザーは自分のデータだけを閲覧・編集できるようになりました';
END $$;
