# 🚀 Vercelデプロイガイド - 冷蔵庫番

## 📋 現在の状態
- **ブランチ:** `deploy/github-pages`
- **ビルド:** `build/web` (本番用ビルド完了)
- **Supabase:** 統合済み (Project ID: gnxtjyqjmmztlkogojyp)

---

## 🔧 Vercelデプロイ手順

### 方法1: Vercel Web UI経由（最も簡単・推奨）

#### ステップ1: GitHubにプッシュ

まず、GitHubリポジトリに最新コードをプッシュする必要があります。

**オプションA: GitHub Web UIで直接マージ**

1. https://github.com/locotown/reizoukoban.app にアクセス
2. **Compare & pull request** ボタンをクリック（または直接Pull Request作成）
3. `base: main` ← `compare: deploy/github-pages` を選択
4. **Create pull request**
5. **Merge pull request** → **Confirm merge**

**オプションB: Personal Access Token使用**

```bash
# 1. GitHub Personal Access Token作成
# https://github.com/settings/tokens
# Scopes: repo, workflow

# 2. Tokenでプッシュ
cd /home/user/flutter_app
git push https://YOUR_GITHUB_TOKEN@github.com/locotown/reizoukoban.app.git deploy/github-pages

# 3. mainにマージ（GitHub Web UIで）
```

#### ステップ2: Vercelでインポート

1. **Vercelダッシュボード**: https://vercel.com/dashboard にアクセス
2. **Add New...** → **Project**
3. **Import Git Repository**
4. `locotown/reizoukoban.app` を選択
5. **Import**

#### ステップ3: プロジェクト設定

**Framework Preset**: `Other`

**Build & Development Settings**:
- **Build Command**: 
  ```bash
  flutter build web --release --pwa-strategy=none --dart-define=FLUTTER_WEB_USE_SKIA=false
  ```
- **Output Directory**: `build/web`
- **Install Command**: 
  ```bash
  if [ ! -d "$HOME/flutter" ]; then git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter; fi && export PATH="$HOME/flutter/bin:$PATH" && flutter --version && flutter pub get
  ```

**Environment Variables**: (不要、すべて `supabase_config.dart` に記載済み)

#### ステップ4: デプロイ

**Deploy** ボタンをクリック → 自動ビルド＆デプロイが開始されます（約3-5分）

---

### 方法2: Vercel CLI経由（高度な設定向け）

#### 前提条件

Vercel CLIのインストールと認証:

```bash
# Vercel CLIインストール
npm install -g vercel

# Vercel認証
vercel login
```

#### デプロイコマンド

```bash
cd /home/user/flutter_app

# プレビューデプロイ（テスト用）
vercel

# 本番デプロイ
vercel --prod
```

---

## 🌐 カスタムドメイン設定

### Vercel側の設定

1. **Vercelプロジェクトダッシュボード** → **Settings** → **Domains**
2. カスタムドメイン（例: `reizoukoban.yourdomain.com`）を追加
3. DNSレコードの指示が表示されます

### DNSプロバイダー側の設定

あなたのDNSプロバイダー（例: お名前.com, Cloudflare）で以下を設定:

#### CNAMEレコード（推奨）
```
タイプ: CNAME
名前: reizoukoban
値: cname.vercel-dns.com
TTL: 3600
```

#### Aレコード（apex domainの場合）
```
タイプ: A
名前: @
値: 76.76.21.21
TTL: 3600
```

### SSL証明書

Vercelが自動的にLet's Encrypt証明書を発行します（数分）。

---

## ⚙️ Supabase設定の更新（重要！）

デプロイ後、**必ず**Supabase側でURLを更新してください。

### 1. デプロイURLの確認

デプロイ完了後、Vercelから以下のようなURLが発行されます:
- **本番URL**: `https://reizoukoban-app.vercel.app`
- **カスタムドメイン**: `https://reizoukoban.yourdomain.com`（設定した場合）

### 2. Supabase Authentication URL Configuration

https://supabase.com/dashboard/project/gnxtjyqjmmztlkogojyp/auth/url-configuration

#### Site URL
```
https://reizoukoban-app.vercel.app
```
または
```
https://reizoukoban.yourdomain.com
```

#### Redirect URLs
以下を**すべて**追加:
```
https://reizoukoban-app.vercel.app/**
https://reizoukoban-app.vercel.app/
```

カスタムドメインを使用する場合:
```
https://reizoukoban.yourdomain.com/**
https://reizoukoban.yourdomain.com/
```

開発環境URLは削除可能:
```
https://5060-inearajuml55cvidefkr2-2e1b9533.sandbox.novita.ai/** (削除)
http://localhost:5060/** (削除)
```

### 3. Email Providerの確認

https://supabase.com/dashboard/project/gnxtjyqjmmztlkogojyp/auth/providers

- **Email**: 有効
- **Confirm email**: 本番では **ON** 推奨（開発時は OFF 可能）

---

## 🧪 デプロイ後のテスト

### 1. アプリの動作確認

1. デプロイされたURL（`https://reizoukoban-app.vercel.app`）にアクセス
2. **Ctrl + Shift + R** でハードリロード
3. **読み込み時間を確認**（3-5秒以内が目標）
4. **進捗表示**が正しく動作することを確認

### 2. Supabase認証テスト

#### 新規登録テスト
1. 「新規会員登録」ボタンをクリック
2. メールアドレスとパスワードを入力（実際のメールアドレス推奨）
3. 登録成功 → 確認メール受信
4. メール内の「Confirm your mail」リンクをクリック

#### ログインテスト
1. 登録したメールアドレスとパスワードでログイン
2. メイン画面（ホーム、登録、ストック）に遷移
3. 食材追加・更新・削除をテスト

#### リアルタイム同期テスト
1. 2つのブラウザ（またはデバイス）で同じアカウントにログイン
2. 片方のブラウザで食材を追加
3. もう片方のブラウザで自動的に反映されることを確認

### 3. ブラウザコンソール確認

F12キーを押してデベロッパーツールを開き、エラーがないか確認:

✅ **正常な場合:**
```
✅ Supabase初期化成功
✅ ユーザー認証成功
✅ データ読み込み成功
```

❌ **エラーがある場合:**
```
❌ AuthRetryableFetchException: Failed to fetch
→ Supabase URLが未更新の可能性
```

---

## 🛡️ トラブルシューティング

### 認証エラー: "Failed to fetch"

**原因**: Supabase Redirect URLsが本番URLに更新されていない

**解決策**:
1. Supabase URL Configuration設定を確認
2. 本番URLが登録されているか確認
3. ブラウザキャッシュをクリア（Ctrl + Shift + Delete）

### 白画面が長時間表示される

**原因**: ブラウザキャッシュ、またはVercelビルドの問題

**解決策**:
1. **ハードリロード**: Ctrl + Shift + R
2. **シークレットモード**でテスト
3. Vercelダッシュボードでビルドログを確認

### カスタムドメインが反映されない

**原因**: DNS伝播の遅延（最大48時間）

**解決策**:
1. DNS設定を再確認
2. `dig reizoukoban.yourdomain.com` でDNS解決を確認
3. Vercel側で「Refresh」ボタンをクリック

---

## 📊 デプロイ状況の確認

### Vercel Dashboard

- **デプロイ履歴**: https://vercel.com/locotown/reizoukoban-app
- **ビルドログ**: 各デプロイをクリック → **Build Logs**
- **Analytics**: トラフィックやパフォーマンスを確認

### Git統合

Vercelは自動的にGitHubリポジトリと連携:
- **mainブランチへのpush** → 本番デプロイ
- **他のブランチへのpush** → プレビューデプロイ

---

## 🎉 完了チェックリスト

- [ ] GitHubにコードをプッシュ
- [ ] Vercelでプロジェクトをインポート
- [ ] Vercelデプロイ成功（本番URL取得）
- [ ] Supabase Site URLを本番URLに変更
- [ ] Supabase Redirect URLsに本番URLを追加
- [ ] デプロイ後の動作確認（登録、ログイン、CRUD）
- [ ] リアルタイム同期の動作確認
- [ ] カスタムドメイン設定（オプション）
- [ ] DNS設定（カスタムドメイン使用時）
- [ ] SSL証明書の発行確認

---

## 📞 サポート

質問やエラーが発生した場合は、以下の情報を共有してください:
- Vercelデプロイログのスクリーンショット
- ブラウザコンソールのエラーメッセージ
- Supabase設定のスクリーンショット
