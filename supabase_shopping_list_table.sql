-- ============================================
-- 買い物リストテーブル作成SQL
-- ============================================

-- 1. 買い物リストテーブルを作成
CREATE TABLE IF NOT EXISTS shopping_list (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  icon TEXT DEFAULT '🛒',
  category_id TEXT NOT NULL,
  is_purchased BOOLEAN DEFAULT FALSE,
  source TEXT DEFAULT 'manual',  -- 'stock', 'food', 'manual'
  source_id UUID,  -- 元のアイテムのID（stock_id または food_id）
  memo TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. インデックスを作成（パフォーマンス向上）
CREATE INDEX IF NOT EXISTS idx_shopping_list_user_id ON shopping_list(user_id);
CREATE INDEX IF NOT EXISTS idx_shopping_list_is_purchased ON shopping_list(is_purchased);
CREATE INDEX IF NOT EXISTS idx_shopping_list_source ON shopping_list(source);

-- 3. RLS (Row Level Security) を有効化
ALTER TABLE shopping_list ENABLE ROW LEVEL SECURITY;

-- 4. RLSポリシーを作成（ユーザーごとにデータを分離）

-- SELECT: 自分のデータのみ取得可能
CREATE POLICY "Users can view their own shopping items"
  ON shopping_list FOR SELECT
  USING (auth.uid() = user_id);

-- INSERT: 自分のデータのみ挿入可能
CREATE POLICY "Users can insert their own shopping items"
  ON shopping_list FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- UPDATE: 自分のデータのみ更新可能
CREATE POLICY "Users can update their own shopping items"
  ON shopping_list FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- DELETE: 自分のデータのみ削除可能
CREATE POLICY "Users can delete their own shopping items"
  ON shopping_list FOR DELETE
  USING (auth.uid() = user_id);

-- 5. updated_atカラムの自動更新トリガーを作成
CREATE OR REPLACE FUNCTION update_shopping_list_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_shopping_list_updated_at_trigger
  BEFORE UPDATE ON shopping_list
  FOR EACH ROW
  EXECUTE FUNCTION update_shopping_list_updated_at();

-- ============================================
-- テーブル作成完了
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
