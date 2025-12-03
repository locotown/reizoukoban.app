# 🚀 RLS クイックセットアップガイド

## 📌 5分でデータ分離を実現

このガイドに従って、**各ユーザーが自分のデータだけを見られる**ようにセットアップできます。

---

## ⚡ クイックスタート（3ステップ）

### **ステップ1: Supabase SQL Editorを開く**

1. https://supabase.com/dashboard にアクセス
2. プロジェクト「冷蔵庫番」を選択
3. 左メニュー → **「SQL Editor」**

### **ステップ2: RLSポリシーを適用**

以下のSQLをコピー&ペーストして **「Run」** をクリック：

```sql
-- RLSを有効化
ALTER TABLE foods ENABLE ROW LEVEL SECURITY;
ALTER TABLE stocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_templates ENABLE ROW LEVEL SECURITY;

-- 既存のポリシーを削除（クリーンスタート）
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

-- foodsテーブルのポリシー
CREATE POLICY "Users can view own foods" ON foods FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own foods" ON foods FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own foods" ON foods FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own foods" ON foods FOR DELETE USING (auth.uid() = user_id);

-- stocksテーブルのポリシー
CREATE POLICY "Users can view own stocks" ON stocks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own stocks" ON stocks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own stocks" ON stocks FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own stocks" ON stocks FOR DELETE USING (auth.uid() = user_id);

-- custom_templatesテーブルのポリシー
CREATE POLICY "Users can view own templates" ON custom_templates FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own templates" ON custom_templates FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own templates" ON custom_templates FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own templates" ON custom_templates FOR DELETE USING (auth.uid() = user_id);

-- インデックス作成（パフォーマンス最適化）
CREATE INDEX IF NOT EXISTS idx_foods_user_id ON foods(user_id);
CREATE INDEX IF NOT EXISTS idx_stocks_user_id ON stocks(user_id);
CREATE INDEX IF NOT EXISTS idx_custom_templates_user_id ON custom_templates(user_id);
```

### **ステップ3: 設定を確認**

以下のSQLをコピー&ペーストして **「Run」** をクリック：

```sql
-- RLS有効化状況の確認
SELECT tablename, rowsecurity AS "RLS Enabled"
FROM pg_tables
WHERE tablename IN ('foods', 'stocks', 'custom_templates');

-- ポリシー数の確認（各テーブル4つあればOK）
SELECT tablename, COUNT(*) AS policy_count
FROM pg_policies
WHERE tablename IN ('foods', 'stocks', 'custom_templates')
GROUP BY tablename;
```

**期待される結果：**
- すべてのテーブルで `RLS Enabled = true`
- 各テーブルに `policy_count = 4`

---

## ✅ 完了！

RLSポリシーが適用されました。これで：

- ✅ ユーザーAのデータはユーザーAだけが見える
- ✅ ユーザーBのデータはユーザーBだけが見える
- ✅ 匿名ユーザーも完全に分離される

---

## 🧪 動作確認テスト

### **テスト1: データ分離の確認**

1. **ユーザーA** でログイン
2. 食材を1つ登録（例：牛乳）
3. ログアウト
4. **ユーザーB** でログイン（別のアカウント）
5. 食材リストを確認
6. ✅ **「牛乳」が表示されない**ことを確認

### **テスト2: 匿名ユーザーの分離**

1. **匿名ログイン**（「匿名でログイン」ボタン）
2. 食材を登録
3. ログアウト
4. 再度 **匿名ログイン**（新しいセッション）
5. ✅ **前回のデータが表示されない**ことを確認

### **テスト3: デモモード**

1. `https://reizoukoban-app.vercel.app/app/?demo=true` にアクセス
2. 自動的に匿名ログインされる
3. データを登録
4. ログアウトして再度 `?demo=true` でアクセス
5. ✅ **空のデータベースから開始**されることを確認

---

## 🎭 デモモードの違い（RLS適用後）

### **`/app/` (通常モード)**
- ユーザーがログイン方法を選択
- Email/Password または 匿名ログイン
- データは永続化（ログアウト後も保存）

### **`/app/?demo=true` (デモモード)**
- 自動的に匿名ログイン
- 新しいセッションごとに空のデータベース
- 他のユーザーのデータは一切見えない

**重要：** RLS適用後は、**匿名ユーザー間でもデータが混在しない**ため、安心してデモモードを提供できます！

---

## ❓ トラブルシューティング

### **問題1: RLS適用後、自分のデータも見えなくなった**

**原因：** 既存データに `user_id` が設定されていない

**解決策：**
```sql
-- テストデータの場合のみ実行（本番環境では注意）
-- 現在ログインしているユーザーのIDを全データに設定
UPDATE foods SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;
UPDATE stocks SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;
UPDATE custom_templates SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;
```

**より安全な方法：** 既存データを削除して、新しいデータを作成してください。

### **問題2: SQLエラーが発生する**

**原因：** テーブルが存在しないか、権限がない

**解決策：**
- Supabaseプロジェクトで **Owner** または **Admin** 権限を持っているか確認
- テーブル名が正しいか確認（`foods`, `stocks`, `custom_templates`）

---

## 📚 詳細ドキュメント

より詳しい情報は以下を参照してください：
- `RLS_SETUP_GUIDE.md` - 完全な設定ガイド
- `setup_rls_policies.sql` - RLS適用SQLスクリプト
- `check_rls_status.sql` - 設定確認SQLスクリプト
- `setup_demo_data.sql` - デモ用サンプルデータ作成

---

## 🎉 完了

これでユーザーデータの完全な分離が実現しました！

各ユーザーは自分のデータだけを見ることができ、プライバシーとセキュリティが確保されています。
