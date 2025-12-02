# 🚀 GitHub Pagesデプロイガイド

## 📋 現在の状態
- **ブランチ:** `deploy/github-pages`
- **リモート:** `https://github.com/locotown/reizoukoban.app.git`
- **Flutter Version:** 3.35.4
- **Supabase統合:** 完了

## 🔧 デプロイ手順

### 1. GitHub Pages有効化

1. GitHubリポジトリページにアクセス: `https://github.com/locotown/reizoukoban.app`
2. **Settings** → **Pages** に移動
3. **Source** を **GitHub Actions** に設定
4. 保存

### 2. コードのプッシュ

```bash
cd /home/user/flutter_app
git add .
git commit -m "GitHub Pagesデプロイ設定追加"
git push origin deploy/github-pages
```

### 3. mainブランチへマージ（動作確認後）

```bash
git checkout main
git merge deploy/github-pages
git push origin main
```

これにより、GitHub Actionsが自動的にビルド→デプロイを実行します。

## 🌐 カスタムドメイン設定（オプション）

### GitHub側の設定

1. **Settings** → **Pages** → **Custom domain**
2. カスタムドメイン（例: `reizoukoban.yourdomain.com`）を入力
3. **Save**

### DNSレコードの設定

あなたのドメインプロバイダー（例: お名前.com, Cloudflare）で以下のレコードを追加:

#### Aレコード（apex domain: yourdomain.com）
```
A    @    185.199.108.153
A    @    185.199.109.153
A    @    185.199.110.153
A    @    185.199.111.153
```

#### CNAMEレコード（subdomain: reizoukoban.yourdomain.com）
```
CNAME   reizoukoban   locotown.github.io
```

### web/CNAMEファイルの更新

`web/CNAME`ファイルのコメントを外し、カスタムドメインを記載:

```
reizoukoban.yourdomain.com
```

## 🔍 デプロイ後の確認

### GitHub Actions実行状況

`https://github.com/locotown/reizoukoban.app/actions`

### デプロイURL

- **GitHub Pages (デフォルト):** `https://locotown.github.io/reizoukoban.app/`
- **カスタムドメイン:** 設定したドメイン

## ⚙️ Supabase設定の更新（重要！）

デプロイ後、Supabase側でURLを更新:

### 1. Authentication URL Configuration

`https://supabase.com/dashboard/project/gnxtjyqjmmztlkogojyp/auth/url-configuration`

- **Site URL:** `https://locotown.github.io/reizoukoban.app/` （またはカスタムドメイン）
- **Redirect URLs:** 
  - `https://locotown.github.io/reizoukoban.app/**`
  - `https://locotown.github.io/reizoukoban.app/`

### 2. 既存のlocalhost URLを削除

開発環境（localhost:5060）のURLは削除可能です。

## 🛡️ トラブルシューティング

### 404エラー

- `--base-href`が正しく設定されているか確認
- GitHub Pagesの設定でブランチが正しいか確認

### 認証エラー

- Supabase URLが本番URLに更新されているか確認
- Redirect URLsに本番URLが登録されているか確認

### ビルドエラー

- GitHub Actions logsを確認: `https://github.com/locotown/reizoukoban.app/actions`
- Flutter versionが3.35.4か確認
