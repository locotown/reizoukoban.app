# 冷蔵庫番 - 食材管理アプリ

## 🚨 Vercel デプロイ設定（必須）

### 現在の状態
- ✅ `public/` ディレクトリ構造作成済み
- ✅ シンプルな `vercel.json` 設定済み
- ⏳ **Vercel Dashboard 設定が必要**

### Vercel設定手順

1. **Vercel Dashboard** にアクセス: https://vercel.com/dashboard
2. プロジェクト `reizoukoban-app` を選択
3. **Settings** → **Build & Development Settings**
4. **以下を設定**:
   - Framework Preset: `Other`
   - Root Directory: 空欄
   - Build Command: 空欄 (Override OFF)
   - **Output Directory: `public`** ⚠️ 最重要
   - Install Command: 空欄 (Override OFF)
5. **Save** → **Redeploy**

### URL構造
- `/` → ランディングページ (`public/index.html`)
- `/app/` → Flutterアプリ (`public/app/index.html`)
- `/css/*` → LP CSS (`public/css/*`)
- `/js/*` → LP JS (`public/js/*`)
- `/assets/*` → LP Assets (`public/assets/*`)

### トラブルシューティング

**問題: `/app/` が404エラー**
- 原因: `Output Directory` が設定されていない
- 解決: Vercel設定で `Output Directory: public` を指定して再デプロイ

**問題: Flutter静的ファイルが404**
- 原因: 同上
- 解決: 同上 + ブラウザキャッシュクリア

## 📁 プロジェクト構造

```
public/                 ← Vercelが配信するルート
├── index.html         ← ランディングページ
├── css/
│   └── style.css
├── js/
│   └── main.js
├── assets/
│   ├── favicon.png
│   ├── logo.png
│   └── images/
└── app/               ← Flutterアプリ
    ├── index.html
    ├── flutter_bootstrap.js
    ├── main.dart.js
    └── ...
```

## 🎨 デザイン改善

- ✅ プロフェッショナルなデザインに刷新
- ✅ レスポンシブ対応強化
- ✅ レイアウトの整理・統一
- ✅ アイコンとテキストの配置改善

## 📝 開発情報

- Flutter: 3.35.4
- Dart: 3.9.2
- Backend: Supabase
- Hosting: Vercel
- GitHub: https://github.com/locotown/reizoukoban.app
