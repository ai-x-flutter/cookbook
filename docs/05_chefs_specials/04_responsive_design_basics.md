# ケーススタディ#5-4: レスポンシブデザインの基礎 - あらゆる画面サイズに対応する

## このケーススタディで学ぶこと

**Cursor + Claude**を使って、スマートフォン、タブレット、デスクトップなど、あらゆる画面サイズに対応するレスポンシブなFlutterアプリを作ります。

**学習内容:**
- ✅ 画面サイズの取得と判定
- ✅ ブレークポイントの設定
- ✅ レイアウトの動的切り替え
- ✅ レスポンシブウィジェットの作成
- ✅ MediaQueryの活用

**技術スタック:**
- Flutter 3.27+
- MediaQuery
- LayoutBuilder
- OrientationBuilder
- Flexible / Expanded

**避けるもの:**
- ❌ 複雑なレスポンシブライブラリ
- ❌ 過度な画面サイズ分岐

## レスポンシブデザインの重要性

Flutterアプリは、一つのコードベースで以下の全てに対応できます：

```
📱 スマートフォン    (320px - 480px)
📱 大型スマホ        (480px - 768px)
📱 タブレット        (768px - 1024px)
💻 ラップトップ      (1024px - 1440px)
🖥️ デスクトップ      (1440px+)
```

**同じコードが全ての画面サイズで美しく表示される**ことが、Flutterの最大の強みです。

## Step 1: 画面サイズの取得

### MediaQueryを使った画面情報の取得

**Cursorに以下をリクエスト:**

```
MediaQueryを使って画面サイズを取得するサンプルコードを作成してください。
画面の幅、高さ、向き（縦/横）を表示するシンプルなアプリを作ってください。
```

**生成されるコード例:**

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Info App',
      home: ScreenInfoPage(),
    );
  }
}

class ScreenInfoPage extends StatelessWidget {
  const ScreenInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('画面情報'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('幅: ${size.width.toStringAsFixed(1)}px'),
            Text('高さ: ${size.height.toStringAsFixed(1)}px'),
            Text('向き: ${orientation == Orientation.portrait ? "縦" : "横"}'),
          ],
        ),
      ),
    );
  }
}
```

## Step 2: ブレークポイントの定義

### デバイスタイプ別のブレークポイント

**Cursorに以下をリクエスト:**

```
画面幅に基づいてデバイスタイプを判定するヘルパークラスを作成してください。
以下のブレークポイントを使用：
- モバイル: 0 - 600px
- タブレット: 600 - 1024px
- デスクトップ: 1024px以上
```

**生成されるコード例:**

```dart
// lib/utils/responsive_helper.dart
class ResponsiveHelper {
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width < tabletMaxWidth;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }

  static String getDeviceType(BuildContext context) {
    if (isMobile(context)) return 'Mobile';
    if (isTablet(context)) return 'Tablet';
    return 'Desktop';
  }
}
```

## Step 3: レスポンシブレイアウトの実装

### デバイスに応じたレイアウト切り替え

**Cursorに以下をリクエスト:**

```
ResponsiveHelperを使って、デバイスタイプに応じてレイアウトを切り替えるページを作成してください。
- モバイル: 1カラム
- タブレット: 2カラム
- デスクトップ: 3カラム
```

**生成されるコード例:**

```dart
class ResponsiveGridPage extends StatelessWidget {
  const ResponsiveGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レスポンシブグリッド'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(context),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            return Card(
              child: Center(
                child: Text(
                  'Item ${index + 1}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    if (ResponsiveHelper.isMobile(context)) return 1;
    if (ResponsiveHelper.isTablet(context)) return 2;
    return 3;
  }
}
```

## Step 4: レスポンシブウィジェットの作成

### 汎用的なレスポンシブウィジェット

**Cursorに以下をリクエスト:**

```
モバイル、タブレット、デスクトップで異なるウィジェットを表示できる
ResponsiveWidgetを作成してください。
```

**生成されるコード例:**

```dart
// lib/widgets/responsive_widget.dart
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }
    if (ResponsiveHelper.isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}
```

**使用例:**

```dart
ResponsiveWidget(
  mobile: ListView(
    children: [
      UserProfile(),
      UserPosts(),
      UserComments(),
    ],
  ),
  tablet: Row(
    children: [
      Expanded(flex: 1, child: UserProfile()),
      Expanded(flex: 2, child: UserPosts()),
    ],
  ),
  desktop: Row(
    children: [
      Expanded(flex: 1, child: UserProfile()),
      Expanded(flex: 2, child: UserPosts()),
      Expanded(flex: 1, child: UserComments()),
    ],
  ),
)
```

## Step 5: LayoutBuilderでの動的レイアウト

### 親ウィジェットのサイズに基づいた調整

**Cursorに以下をリクエスト:**

```
LayoutBuilderを使って、利用可能なスペースに応じて
レイアウトを動的に調整するカードウィジェットを作成してください。
```

**生成されるコード例:**

```dart
class AdaptiveCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const AdaptiveCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 幅が600px以上なら横並び、それ以下なら縦並び
        if (constraints.maxWidth > 600) {
          return _buildHorizontalCard();
        } else {
          return _buildVerticalCard();
        }
      },
    );
  }

  Widget _buildHorizontalCard() {
    return Card(
      child: Row(
        children: [
          Image.network(imageUrl, width: 200, height: 150, fit: BoxFit.cover),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalCard() {
    return Card(
      child: Column(
        children: [
          Image.network(imageUrl, width: double.infinity, height: 150, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## Step 6: レスポンシブなフォントサイズ

### 画面サイズに応じたテキストサイズ調整

**Cursorに以下をリクエスト:**

```
画面サイズに応じて適切なフォントサイズを返す関数を作成してください。
```

**生成されるコード例:**

```dart
extension ResponsiveText on BuildContext {
  double get scaleFactor {
    final width = MediaQuery.of(this).size.width;
    if (width < 600) return 0.8;
    if (width < 1024) return 1.0;
    return 1.2;
  }

  TextStyle responsiveTextStyle(double baseFontSize) {
    return TextStyle(
      fontSize: baseFontSize * scaleFactor,
    );
  }
}

// 使用例
Text(
  'レスポンシブテキスト',
  style: context.responsiveTextStyle(16),
)
```

## Step 7: 実践例：レスポンシブダッシュボード

**Cursorに以下をリクエスト:**

```
以下の要件でレスポンシブなダッシュボードを作成してください：
1. モバイル: 縦一列に全要素を表示
2. タブレット: 2カラムグリッド
3. デスクトップ: サイドバー + メインコンテンツ
```

## まとめ

### 学んだこと

✅ **MediaQuery**: 画面サイズと向きの取得
✅ **ブレークポイント**: デバイスタイプの判定
✅ **レスポンシブウィジェット**: 画面サイズに応じたUI切り替え
✅ **LayoutBuilder**: 親のサイズに基づいた動的レイアウト
✅ **スケーリング**: フォントサイズの自動調整

### ベストプラクティス

1. **シンプルなブレークポイント**: 3段階（モバイル/タブレット/デスクトップ）で十分
2. **LayoutBuilderを優先**: MediaQueryよりも柔軟
3. **段階的な対応**: モバイルから始めて、徐々に大画面対応
4. **実機テスト**: 様々なデバイスで確認

### 次のステップ

このレスポンシブデザインの知識は、次のケーススタディで活用します：
- **#5-5: デスクトップアプリ** - 大画面レイアウトの実装
- **#5-6: Webアプリ** - ブラウザでのレスポンシブUI

➡️ **次のレシピへ:** [#5-5: デスクトップアプリを作る](./05_building_desktop_app.md)
