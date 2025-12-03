# Row Level Security (RLS) 設定ガイド

## 📋 概要

このガイドでは、冷蔵庫番アプリのデータベースにRow Level Security (RLS) を設定し、各ユーザーが自分のデータだけを見られるようにする手順を説明します。

---

## 🚨 現在の問題

**症状：**
- 匿名ユーザーと通常ユーザーのデータが混在している
- あるユーザーが作成したデータが他のユーザーにも見える
- ユーザーごとのデータ分離ができていない

**原因：**
- RLSポリシーがSupabaseデータベースに適用されていない

---

## ✅ 解決策：RLSポリシーの適用

### **ステップ1: Supabase SQL Editorにアクセス**

1. Supabaseダッシュボードを開く
   - URL: https://supabase.com/dashboard
2. プロジェクト「冷蔵庫番」を選択
3. 左側メニューから **「SQL Editor」** をクリック

### **ステップ2: RLSポリシーを適用**

1. SQL Editorで **「New query」** をクリック
2. 以下のファイルの内容をコピー&ペースト：
   ```
   setup_rls_policies.sql
   ```
3. **「Run」** ボタンをクリック
4. 成功メッセージが表示されることを確認

### **ステップ3: RLS設定を確認**

1. SQL Editorで新しいクエリを作成
2. 以下のファイルの内容をコピー&ペースト：
   ```
   check_rls_status.sql
   ```
3. **「Run」** ボタンをクリック
4. 結果を確認：
   - すべてのテーブルで `RLS Enabled = true`
   - 各テーブルに4つのポリシー（SELECT, INSERT, UPDATE, DELETE）が存在

---

## 🎯 RLSポリシーの効果

### **適用前：**
```
ユーザーA: 牛乳、卵、りんご
ユーザーB: 牛乳、卵、りんご ← ユーザーAのデータも見える！
```

### **適用後：**
```
ユーザーA: 牛乳、卵、りんご
ユーザーB: (自分のデータのみ表示)
```

---

## 🎭 デモモードの改善

### **現在の問題**

- `?demo=true` パラメータは単に「自動匿名ログイン」をトリガーするだけ
- 匿名ユーザーも通常ユーザーと同じデータベースを使用
- データが混在する

### **推奨される改善策**

#### **オプション1: デモ専用固定アカウント（推奨）**

**メリット：**
- サンプルデータをあらかじめ用意できる
- デモユーザーは常に同じデータを見る
- 定期的にデータをリセット可能

**実装手順：**

1. **デモ用アカウントを作成**
   - Supabase Dashboard → Authentication → Users → "Add user"
   - Email: `demo@reizoukoban.app`
   - Password: `Demo123456!`（または強力なパスワード）
   - "Confirm email" をONにする

2. **サンプルデータを作成**
   - ユーザーのUUIDをコピー
   - `setup_demo_data.sql` を編集してUUIDを設定
   - SQL Editorで実行

3. **アプリ側の実装を修正**
   - `?demo=true` の場合、固定アカウントでログイン
   - ログイン画面に「デモを試す」ボタンを追加

#### **オプション2: 読み取り専用デモモード**

**メリット：**
- データ汚染を完全に防止
- ユーザーはデータを見ることができるが、編集は保存されない

**実装手順：**
- デモモードフラグを状態管理に追加
- デモモード時は書き込み操作をローカルのみに制限
- サーバーへのデータ送信をスキップ

#### **オプション3: セッション限定匿名デモ**

**メリット：**
- RLSにより、匿名ユーザーも完全にデータ分離される
- セッション終了後、データは自動削除（Supabaseの機能）

**実装手順：**
- RLSポリシーを適用（上記手順）
- 匿名ログインを継続使用
- セッション終了後のデータクリーンアップをスケジュール

---

## 🔧 トラブルシューティング

### **問題1: RLSポリシー適用後、データが見えなくなった**

**原因：**
- 既存のデータに `user_id` が設定されていない

**解決策：**
```sql
-- 既存データにuser_idを設定（テストデータの場合）
-- 注意: 本番環境では慎重に実行してください
UPDATE foods SET user_id = auth.uid() WHERE user_id IS NULL;
UPDATE stocks SET user_id = auth.uid() WHERE user_id IS NULL;
UPDATE custom_templates SET user_id = auth.uid() WHERE user_id IS NULL;
```

### **問題2: 匿名ユーザーがデータを作成できない**

**原因：**
- Flutter側で `user_id` を正しく設定していない

**解決策：**
```dart
// データ作成時に必ずuser_idを設定
final userId = supabase.auth.currentUser?.id;
if (userId == null) throw Exception('ユーザーが認証されていません');

await supabase.from('foods').insert({
  'user_id': userId,  // 必須！
  'name': name,
  // ... 他のフィールド
});
```

---

## 📊 RLS設定の確認方法

### **方法1: SQL Editorで確認**
```sql
-- RLS有効化状況
SELECT tablename, rowsecurity FROM pg_tables 
WHERE tablename IN ('foods', 'stocks', 'custom_templates');

-- ポリシー一覧
SELECT tablename, policyname FROM pg_policies 
WHERE tablename IN ('foods', 'stocks', 'custom_templates');
```

### **方法2: Supabase Dashboardで確認**
1. Database → Tables → 各テーブル（foods, stocks, custom_templates）
2. 「RLS enabled」が表示されているか確認
3. 「Policies」タブで4つのポリシーが表示されているか確認

---

## 🚀 実装完了後の確認テスト

### **テスト1: データ分離の確認**
1. ユーザーAでログインし、食材を登録
2. ログアウト
3. ユーザーBでログインし、食材リストを確認
4. ✅ ユーザーAのデータが見えないことを確認

### **テスト2: 匿名ユーザーの確認**
1. 匿名ログインで食材を登録
2. ログアウト
3. 再度匿名ログイン（別セッション）
4. ✅ 前回のデータが見えないことを確認

### **テスト3: デモモードの確認**
1. `?demo=true` でアクセス
2. サンプルデータが表示されることを確認
3. データを編集・追加
4. ログアウトして再度デモモードでアクセス
5. ✅ データがリセットされているか、またはデモ用データのみ表示されることを確認

---

## 📝 まとめ

### **必須実施項目：**
1. ✅ `setup_rls_policies.sql` を実行してRLSを有効化
2. ✅ `check_rls_status.sql` で設定を確認
3. ✅ アプリで動作テストを実施

### **推奨実施項目：**
1. デモ専用アカウントの作成とサンプルデータ設定
2. デモモードの改善実装
3. 定期的なデータクリーンアップスクリプトの設定

---

## 🔗 関連ファイル

- `setup_rls_policies.sql` - RLSポリシー適用スクリプト
- `check_rls_status.sql` - RLS設定確認スクリプト
- `setup_demo_data.sql` - デモ用サンプルデータ作成スクリプト
- `supabase_schema.sql` - データベーススキーマ定義

---

## ❓ 質問・サポート

RLS設定で問題が発生した場合は、以下を確認してください：
1. Supabaseプロジェクトの権限（OwnerまたはAdmin権限が必要）
2. SQLスクリプトの実行エラーメッセージ
3. ブラウザコンソールのエラーログ

**それでも解決しない場合は、開発チームにお問い合わせください。**
