# Vercel設定ガイド - ランディングページ + Flutterアプリ統合

## 🚨 重要: Vercel設定を正しく行う

現在のプロジェクト構成:
```
/
├── landing/           ← ランディングページ (/, /css/, /js/, /assets/)
│   ├── index.html
│   ├── css/
│   ├── js/
│   └── assets/
└── build/web/         ← Flutterアプリ (/app/)
    ├── index.html
    ├── main.dart.js
    └── assets/
```

## ✅ Vercel プロジェクト設定手順

### 1. **Framework Preset**: `Other`

### 2. **Root Directory**: **空欄** (または `.`)
   - **絶対に `build/web` にしないこと！**
   - プロジェクトルート (`.`) を指定してください

### 3. **Build Command**: **空欄** (Override OFF)
   - ビルドコマンドは不要（事前ビルド済み）

### 4. **Output Directory**: **空欄** (Override OFF)
   - デフォルトのルートディレクトリを使用

### 5. **Install Command**: **空欄** (Override OFF)

### 6. **Development Command**: `None`

### 7. **Include source files outside of the Root Directory in the Build Step**: `Enabled`

---

## 🔄 ルーティング仕様

`vercel.json` で以下のルーティングを設定済み:

| URL                          | 配信ファイル                    | 説明                |
|------------------------------|--------------------------------|---------------------|
| `/`                          | `/landing/index.html`          | ランディングページ  |
| `/css/*`                     | `/landing/css/*`               | LP CSS              |
| `/js/*`                      | `/landing/js/*`                | LP JavaScript       |
| `/assets/*`                  | `/landing/assets/*`            | LP 画像/リソース    |
| `/app`                       | `/build/web/index.html`        | Flutterアプリ       |
| `/app/*` (任意のパス)        | `/build/web/*`                 | アプリ静的ファイル  |

---

## 🐛 トラブルシューティング

### 問題1: ランディングページが表示されない（404エラー）

**原因**: `Output Directory` が `build/web` に設定されている
**解決策**: 
1. Vercel Dashboard → Settings → Build & Development Settings
2. `Output Directory` を **空欄** にする (Override OFF)
3. `Root Directory` を **空欄** または `.` にする
4. Save → Redeploy

### 問題2: CSS/JSが読み込まれない（スタイルが崩れる）

**原因**: ルーティング設定が反映されていない
**解決策**:
1. `vercel.json` が正しくコミット・プッシュされているか確認
2. Vercelで再デプロイを実行
3. ブラウザのキャッシュをクリア (Ctrl+Shift+R / Cmd+Shift+R)

### 問題3: `/app/` にアクセスできない（404エラー）

**原因**: `build/web` ディレクトリがGitに含まれていない
**解決策**:
1. `build/web` がGitリポジトリに含まれていることを確認
2. `.gitignore` で `build/` が除外されていないか確認
3. 現在のプロジェクトでは `build/web` は強制追加済み（問題なし）

### 問題4: デモモード (`/app/?demo=true`) が動作しない

**原因**: Flutter Webのデモモード検出コードが実行されていない
**解決策**:
1. ブラウザコンソール (F12 → Console) でエラーを確認
2. `dart:html` の制約により、モバイルビルドではなくWebビルドが必要
3. 現在はWebビルドのみなので問題なし

---

## ✅ デプロイ確認チェックリスト

### ランディングページ (/)
- [ ] `https://reizoukoban-app.vercel.app/` にアクセス
- [ ] ヒーローセクションが表示される
- [ ] CSS/JSが正しく読み込まれる（スタイルが適用されている）
- [ ] スクリーンショット画像が表示される
- [ ] スクロールアニメーションが動作する
- [ ] FAQアコーディオンが動作する
- [ ] 「無料で始める」ボタンが `/app/` に遷移する
- [ ] 「デモを見る」ボタンが `/app/?demo=true` に遷移する

### Flutterアプリ (/app/)
- [ ] `https://reizoukoban-app.vercel.app/app/` にアクセス
- [ ] ログイン画面が表示される
- [ ] 通常ログイン/新規登録が動作する
- [ ] デモモード (`/app/?demo=true`) で自動匿名ログインが実行される
- [ ] ログイン後、ダッシュボードが表示される
- [ ] CRUD操作（食材登録/編集/削除）が動作する
- [ ] Supabaseリアルタイム同期が動作する

---

## 📝 カスタムドメイン設定

カスタムドメイン (`reizoukoban.ideandtity.com`) を使用する場合:

1. Vercel Dashboard → Settings → Domains
2. `reizoukoban.ideandtity.com` を追加
3. DNSプロバイダーで `CNAME` レコードを追加:
   - 名前: `reizoukoban`
   - 値: `cname.vercel-dns.com`
4. Supabase認証URL設定を更新:
   - Site URL: `https://reizoukoban.ideandtity.com`
   - Redirect URLs:
     - `https://reizoukoban.ideandtity.com/**`
     - `https://reizoukoban.ideandtity.com/app/**`

---

## 🔧 現在のプロジェクト状態

- ✅ ランディングページ完全実装 (`landing/`)
- ✅ Flutter Webアプリビルド済み (`build/web/`)
- ✅ `vercel.json` ルーティング設定完了
- ✅ デモモード機能実装
- ✅ GitHubリポジトリ同期済み (コミット: `1c31644`)
- ⏳ Vercel設定確認待ち (Output Directory を空欄にする)

---

## 🚀 次のアクション

1. **Vercel設定を確認** → `Output Directory` を空欄にする
2. **Redeploy** → 最新のコミット (`1c31644`) をデプロイ
3. **動作確認** → 上記チェックリストで全項目を確認
4. **エラー発生時** → ビルドログとブラウザコンソールを共有

---

最終更新: 2024-12-03  
コミット: `1c31644` - パス修正とVercelルーティング設定
