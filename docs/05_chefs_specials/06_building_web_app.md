# ケーススタディ#5-6: Webアプリを作る - ブラウザで動くFlutterアプリ

## このケーススタディで作るもの

**Cursor + Claude**を使って、ブラウザで動作するFlutter Webアプリを作り、Firebase HostingやGitHub Pagesにデプロイします。

**機能:**
- ✅ レスポンシブなWebレイアウト
- ✅ URLルーティング
- ✅ SEO対策（メタタグ、タイトル）
- ✅ PWA対応（オフライン動作）
- ✅ Webブラウザの機能活用
- ✅ ホスティングとデプロイ

**技術スタック:**
- Flutter 3.27+ (Web)
- go_router（URLルーティング）
- url_strategy（URLクリーン化）
- Firebase Hosting / GitHub Pages
- PWA（Progressive Web App）

**対応ブラウザ:**
- 🌐 Chrome / Edge
- 🦊 Firefox
- 🧭 Safari
- 🎭 Opera

## 完成イメージ

```
┌──────────────────────────────────────────────┐
│ https://myapp.web.app                        │
├──────────────────────────────────────────────┤
│  [Logo]  Home  About  Contact    [Login]    │ ← ナビゲーションバー
├──────────────────────────────────────────────┤
│                                              │
│     Welcome to My Web App!                   │
│                                              │
│     [Get Started]  [Learn More]              │
│                                              │
│     ・モバイルからデスクトップまで対応      │
│     ・高速でスムーズな動作                  │
│     ・オフラインでも動作                    │
│                                              │
├──────────────────────────────────────────────┤
│ © 2025 My App  |  Privacy  |  Terms          │
└──────────────────────────────────────────────┘
```

## Step 1: Webサポートの有効化

### 既存プロジェクトでWebを有効にする

```bash
# Webサポートを有効化
flutter config --enable-web

# Webプラットフォームを追加
flutter create --platforms=web .

# 確認
flutter devices
```

**出力例:**
```
Chrome (web) • chrome • web-javascript • Google Chrome 120.0
Edge (web) • edge • web-javascript • Microsoft Edge 120.0
```

### プロジェクト構造の確認

```
my_web_app/
├── lib/
├── web/          ← Web固有ファイル
│   ├── index.html
│   ├── manifest.json
│   └── icons/
└── pubspec.yaml
```

## Step 2: URLルーティングの実装

### go_routerのセットアップ

**Cursorに以下をリクエスト:**

```
pubspec.yamlに以下のパッケージを追加してください：
- go_router: ^14.0.0
- url_strategy: ^0.3.0
```

### ルーティング設定

**Cursorに以下をリクエスト:**

```
go_routerを使って、以下のルートを設定してください：
- / (ホームページ)
- /about (アバウトページ)
- /contact (コンタクトページ)
- /blog/:id (ブログ詳細、動的ルート)

URLから#を除去するurl_strategyも設定してください。
```

**生成されるコード例:**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  // URLから#を除去
  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My Web App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }

  static final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactPage(),
      ),
      GoRoute(
        path: '/blog/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlogDetailPage(id: id);
        },
      ),
    ],
  );
}
```

## Step 3: Webナビゲーションバーの実装

### レスポンシブなナビゲーション

**Cursorに以下をリクエスト:**

```
以下の仕様でナビゲーションバーを作成してください：
- デスクトップ: 横並びメニュー
- モバイル: ハンバーガーメニュー
- ロゴ、メニュー項目、ログインボタン
- 現在のページをハイライト
```

**生成されるコード例:**

```dart
class ResponsiveNavBar extends StatelessWidget {
  const ResponsiveNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AppBar(
      title: const Text('My Web App'),
      actions: isMobile ? null : _buildDesktopMenu(context),
    );
  }

  List<Widget> _buildDesktopMenu(BuildContext context) {
    return [
      TextButton(
        onPressed: () => context.go('/'),
        child: const Text('Home', style: TextStyle(color: Colors.white)),
      ),
      TextButton(
        onPressed: () => context.go('/about'),
        child: const Text('About', style: TextStyle(color: Colors.white)),
      ),
      TextButton(
        onPressed: () => context.go('/contact'),
        child: const Text('Contact', style: TextStyle(color: Colors.white)),
      ),
      const SizedBox(width: 16),
      ElevatedButton(
        onPressed: () {},
        child: const Text('Login'),
      ),
      const SizedBox(width: 16),
    ];
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ResponsiveNavBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to My Web App!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/about'),
              child: const Text('Learn More'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Step 4: SEO対策

### index.htmlのメタタグ設定

**Cursorに以下をリクエスト:**

```
web/index.htmlに以下のSEO設定を追加してください：
- タイトル: "My Web App - Flutter Powered"
- description: "A modern web app built with Flutter"
- OGP画像設定（SNSシェア用）
- Googleアナリティクス用の準備
```

**生成されるコード例:**

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <!-- SEO -->
  <title>My Web App - Flutter Powered</title>
  <meta name="description" content="A modern web app built with Flutter">
  <meta name="keywords" content="flutter, web app, modern">

  <!-- OGP (Open Graph Protocol) -->
  <meta property="og:title" content="My Web App">
  <meta property="og:description" content="A modern web app built with Flutter">
  <meta property="og:image" content="https://myapp.web.app/og-image.png">
  <meta property="og:url" content="https://myapp.web.app">
  <meta property="og:type" content="website">

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="My Web App">
  <meta name="twitter:description" content="A modern web app built with Flutter">
  <meta name="twitter:image" content="https://myapp.web.app/twitter-image.png">

  <link rel="icon" type="image/png" href="favicon.png"/>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

## Step 5: PWA（Progressive Web App）対応

### manifest.jsonの設定

**Cursorに以下をリクエスト:**

```
web/manifest.jsonをPWA対応にカスタマイズしてください：
- アプリ名: "My Web App"
- ショートカット名: "MyApp"
- テーマカラー: #2196F3
- アイコン: 192x192, 512x512
```

**生成されるコード例:**

```json
{
  "name": "My Web App",
  "short_name": "MyApp",
  "description": "A modern web app built with Flutter",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#FFFFFF",
  "theme_color": "#2196F3",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ]
}
```

### Service Workerの有効化

**web/index.htmlに追加:**

```html
<script>
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function () {
      navigator.serviceWorker.register('flutter_service_worker.js');
    });
  }
</script>
```

## Step 6: ローカルでのテスト

### Webアプリの起動

```bash
# 開発サーバーで起動
flutter run -d chrome

# または特定のブラウザで起動
flutter run -d edge
flutter run -d firefox

# ホットリロード有効
# コードを変更すると自動的にブラウザがリロード
```

### デバッグツール

```bash
# DevToolsを開く
flutter run -d chrome --web-renderer html

# CanvasKit（高品質レンダリング）
flutter run -d chrome --web-renderer canvaskit
```

**レンダラーの違い:**
- `html`: 軽量、テキスト中心のアプリ向け
- `canvaskit`: 高品質、グラフィック豊富なアプリ向け

## Step 7: ビルドとデプロイ

### リリースビルド

```bash
# HTMLレンダラー（軽量）
flutter build web --release --web-renderer html

# CanvasKitレンダラー（高品質）
flutter build web --release --web-renderer canvaskit

# 自動選択（推奨）
flutter build web --release --web-renderer auto

# 生成物: build/web/
```

### Firebase Hostingへのデプロイ

**Step 7-1: Firebase CLIのインストール**

```bash
npm install -g firebase-tools
firebase login
```

**Step 7-2: Firebaseプロジェクトの初期化**

```bash
firebase init hosting

# 質問への回答:
# - Public directory: build/web
# - Configure as single-page app: Yes
# - Automatic builds with GitHub: No（後で設定可能）
```

**Step 7-3: デプロイ**

```bash
# ビルド
flutter build web --release

# デプロイ
firebase deploy --only hosting

# 出力例:
# Hosting URL: https://my-app-12345.web.app
```

### GitHub Pagesへのデプロイ

**Step 7-1: リポジトリ設定**

```bash
# build/webの内容をgh-pagesブランチにプッシュ
flutter build web --release --base-href "/リポジトリ名/"

# gh-pagesブランチにデプロイ
cd build/web
git init
git add .
git commit -m "Deploy to GitHub Pages"
git branch -M gh-pages
git remote add origin https://github.com/username/repository.git
git push -f origin gh-pages
```

**Step 7-2: GitHub Settings**

1. リポジトリの Settings > Pages
2. Source: `gh-pages` ブランチを選択
3. 公開URL: `https://username.github.io/repository/`

## Step 8: パフォーマンス最適化

### ビルドサイズの最適化

**Cursorに以下をリクエスト:**

```
以下のパフォーマンス最適化を実施してください：
1. 不要なパッケージの削除
2. 画像の遅延読み込み
3. コード分割（Deferred loading）
```

**遅延読み込みの例:**

```dart
// lib/pages/heavy_page.dart を遅延読み込み
import 'pages/heavy_page.dart' deferred as heavy;

// 使用時
ElevatedButton(
  onPressed: () async {
    await heavy.loadLibrary();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => heavy.HeavyPage()),
    );
  },
  child: const Text('Load Heavy Page'),
)
```

## Step 9: Web固有の機能

### URLパラメータの取得

```dart
// URLパラメータの取得（例: /search?q=flutter）
final uri = Uri.base;
final query = uri.queryParameters['q']; // "flutter"
```

### ブラウザの履歴操作

```dart
import 'package:go_router/go_router.dart';

// 戻る
context.pop();

// 特定のページへ移動
context.go('/about');

// パラメータ付き
context.go('/blog/123');
```

### Clipboard API

```dart
import 'package:flutter/services.dart';

// コピー
await Clipboard.setData(ClipboardData(text: 'コピーするテキスト'));

// ペースト
final data = await Clipboard.getData('text/plain');
print(data?.text);
```

## まとめ

### 学んだこと

✅ **Webサポート**: Flutterアプリのブラウザ対応
✅ **URLルーティング**: go_routerでのナビゲーション
✅ **SEO対策**: メタタグとOGP設定
✅ **PWA対応**: オフライン動作とインストール
✅ **デプロイ**: Firebase Hosting、GitHub Pages
✅ **最適化**: ビルドサイズとパフォーマンス

### Web開発のベストプラクティス

1. **レスポンシブ対応**: モバイルからデスクトップまで
2. **SEO重視**: 検索エンジン最適化
3. **PWA化**: アプリライクな体験
4. **軽量化**: 初期読み込みを高速に
5. **URL設計**: わかりやすく、シェアしやすいURL

### Flutter Webの注意点

⚠️ **制限事項:**
- カメラ、Bluetooth等のネイティブ機能は制限あり
- ファイルシステムへの直接アクセス不可
- 初回読み込みに時間がかかる場合がある

✅ **得意な用途:**
- ダッシュボード、管理画面
- ポートフォリオサイト
- プレゼンテーション
- 社内ツール

### 完成！

これで、モバイル、デスクトップ、Webの全てに対応できるようになりました：

- **#5-4: レスポンシブデザイン** ✅
- **#5-5: デスクトップアプリ** ✅
- **#5-6: Webアプリ** ✅

**一つのFlutterコードベースで、あらゆるプラットフォームに展開できる**ことが、Flutterの最大の魅力です！

---

**おめでとうございます！** あなたは、Flutterのマルチプラットフォーム開発をマスターしました。次のステップでは、これらの知識を活かして実際のプロジェクトを作ってみましょう。

➡️ **次のセクションへ:** [sección 6: 他のシェフとの協業](../06_collaboration/01_fork_and_clone.md)
