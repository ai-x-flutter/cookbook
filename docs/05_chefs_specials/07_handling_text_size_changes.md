# レシピ#5-7: テキストサイズ変更への対応 - ダッシュボードとアクセシビリティ

Flutterアプリを実用的に開発する際、**ユーザーのテキストサイズ設定**への対応が重要になります。特に、ダッシュボードやグラフ、精密なレイアウトでは、テキストサイズ変更によってUIが崩れることがあります。

このレシピでは、アクセシビリティとUI安定性のバランスを取る方法を学びます。

---

## 🎯 なぜテキストサイズ変更対応が必要か？

### アクセシビリティの重要性

**iOS・Androidでは、ユーザーがシステム設定でテキストサイズを変更できます：**

- 視力が弱い人は、テキストを大きくして読みやすくする
- デフォルトサイズ以外を使うユーザーは意外と多い
- アクセシビリティ対応はアプリの品質指標の一つ

### 問題：UIが崩れる

**テキストサイズが大きくなると：**

```
❌ ダッシュボードのカードが崩れる
❌ グラフのラベルが重なる
❌ ボタンが画面からはみ出る
❌ 表組みのレイアウトが崩壊
```

**特に問題になる場面：**
- ダッシュボード（データ表示が密集）
- グラフ・チャート（軸ラベル、凡例）
- テーブル・リスト（精密なレイアウト）
- ナビゲーションバー（固定サイズ想定）

---

## 💡 基本概念：textScaleFactor

### textScaleFactorとは？

**Flutterでは、`MediaQuery.textScaleFactor`でユーザーのテキストサイズ設定を取得できます：**

```dart
// デフォルト: 1.0
// ユーザーが「大」に設定: 1.2〜1.3
// ユーザーが「最大」に設定: 2.0〜3.0
final textScaleFactor = MediaQuery.of(context).textScaleFactor;
```

**全てのTextウィジェットに自動適用されます：**

```dart
Text(
  'Hello',
  style: TextStyle(fontSize: 16), // ユーザー設定で自動拡大
)
// textScaleFactor = 1.5 の場合、実質 16 * 1.5 = 24px
```

---

## 🛠️ 解決策：textScaleFactorの制御

### 方法1: アプリ全体で固定する（非推奨）

**❌ 推奨しない方法：**

```dart
MaterialApp(
  builder: (context, child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 1.0, // 常に固定
      ),
      child: child!,
    );
  },
  home: MyHomePage(),
)
```

**問題点：**
- アクセシビリティを完全に無視
- ユーザーの設定を尊重しない
- ストアのレビューで批判される可能性

---

### 方法2: 特定の画面だけ固定する（推奨）

**✅ 推奨：ダッシュボードや精密レイアウトのみ固定**

```dart
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 1.0, // この画面だけ固定
      ),
      child: Scaffold(
        appBar: AppBar(title: Text('ダッシュボード')),
        body: _buildDashboard(),
      ),
    );
  }
}
```

**メリット：**
- 通常の画面ではユーザー設定を尊重
- ダッシュボードだけUI崩れを防ぐ
- バランスの取れたアプローチ

---

### 方法3: 最大値を制限する（ベストプラクティス）

**✅ 最も推奨：過度な拡大を防ぐ**

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        final data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(
            // 最大1.3倍まで許可（それ以上は固定）
            textScaleFactor: data.textScaleFactor.clamp(1.0, 1.3),
          ),
          child: child!,
        );
      },
      home: MyHomePage(),
    );
  }
}
```

**メリット：**
- アクセシビリティを一定程度尊重
- 極端なUI崩れを防ぐ
- 実用的なバランス

**推奨範囲：**
- **一般的なアプリ:** 1.0〜1.5
- **ダッシュボード系:** 1.0〜1.3
- **シンプルなアプリ:** 1.0〜2.0（制限なし）

---

## 🎨 実践例

### 例1: ダッシュボードアプリ

**問題：**
- グラフのラベルが重なる
- カードレイアウトが崩れる

**解決策：**

```dart
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 1.0, // ダッシュボードは固定
      ),
      child: Scaffold(
        appBar: AppBar(title: Text('売上ダッシュボード')),
        body: Column(
          children: [
            _buildSalesChart(), // グラフ
            _buildMetricsCards(), // メトリクスカード
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Container(
      height: 200,
      child: LineChart(/* ... */),
    );
  }

  Widget _buildMetricsCards() {
    return Row(
      children: [
        _MetricCard(label: '今日の売上', value: '¥123,456'),
        _MetricCard(label: '今月の売上', value: '¥9,876,543'),
      ],
    );
  }
}
```

---

### 例2: 通常の画面とダッシュボードを混在

**ベストプラクティス：**

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

// 通常の画面：ユーザー設定を尊重
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // textScaleFactorは自動適用
    return Scaffold(
      appBar: AppBar(title: Text('ホーム')),
      body: ListView(
        children: [
          ListTile(title: Text('設定')),
          ListTile(title: Text('ダッシュボード')),
        ],
      ),
    );
  }
}

// ダッシュボード：固定
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 1.0, // 固定
      ),
      child: Scaffold(
        appBar: AppBar(title: Text('ダッシュボード')),
        body: _buildComplexLayout(),
      ),
    );
  }
}
```

---

### 例3: グラフのラベルだけ固定

**より細かい制御：**

```dart
class ChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // グラフエリア：textScaleFactorを無視
        MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: Container(
            height: 200,
            child: LineChart(/* ... */),
          ),
        ),

        // 説明テキスト：ユーザー設定を尊重
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'このグラフは過去30日間の売上推移を表しています。',
            // textScaleFactorが適用される
          ),
        ),
      ],
    );
  }
}
```

---

## 📐 レイアウト崩れを防ぐ設計

### 1. Flexibleレイアウトを使う

**❌ 固定サイズに依存：**

```dart
Row(
  children: [
    Container(width: 100, child: Text('ラベル')),
    Container(width: 200, child: Text('値')),
  ],
)
// textScaleFactorが大きいと、テキストがはみ出る
```

**✅ Flexibleを使う：**

```dart
Row(
  children: [
    Flexible(flex: 1, child: Text('ラベル')),
    Flexible(flex: 2, child: Text('値')),
  ],
)
// テキストサイズが変わっても自動調整
```

---

### 2. overflowを適切に処理

**テキストが長い場合の対策：**

```dart
Text(
  '非常に長いテキストがここに入ります',
  overflow: TextOverflow.ellipsis, // 省略記号で表示
  maxLines: 1,
)

Text(
  '非常に長いテキストがここに入ります',
  overflow: TextOverflow.fade, // フェードアウト
  maxLines: 2,
)
```

---

### 3. FittedBoxを使う

**テキストを自動的にフィットさせる：**

```dart
Container(
  width: 100,
  height: 50,
  child: FittedBox(
    fit: BoxFit.scaleDown, // はみ出る場合だけ縮小
    child: Text('長いテキスト', style: TextStyle(fontSize: 20)),
  ),
)
```

**⚠️ 注意：**
- FittedBoxは便利だが、読みにくくなる可能性
- アクセシビリティとのトレードオフ

---

## ♿ アクセシビリティとのバランス

### 推奨アプローチ

**1. 基本方針：**
- **通常の画面:** ユーザー設定を尊重（textScaleFactorを適用）
- **ダッシュボード・グラフ:** 固定 or 最大値制限
- **理由を明確に:** ストア説明やアプリ内で説明

**2. 代替手段を提供：**

```dart
// ダッシュボードでtextScaleFactorを固定する場合
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 1.0,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('ダッシュボード'),
          actions: [
            // 拡大表示ボタンを提供
            IconButton(
              icon: Icon(Icons.zoom_in),
              onPressed: () => _showLargeView(context),
            ),
          ],
        ),
        body: _buildDashboard(),
      ),
    );
  }

  void _showLargeView(BuildContext context) {
    // 拡大表示モードを提供
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LargeTextDashboard(),
      ),
    );
  }
}
```

**3. テストする：**

```dart
// iOSシミュレータ：設定 > アクセシビリティ > 画面表示とテキストサイズ > さらに大きな文字
// Androidエミュレータ：設定 > ユーザー補助 > フォントサイズ

// または、開発中にコードで確認
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaleFactor: 2.0, // 極端なケースをテスト
  ),
  child: MyWidget(),
)
```

---

## 🎯 ベストプラクティスまとめ

### ✅ 推奨事項

1. **アプリ全体で最大値を制限**
   ```dart
   textScaleFactor: data.textScaleFactor.clamp(1.0, 1.3)
   ```

2. **ダッシュボード・グラフは固定**
   ```dart
   MediaQuery.copyWith(textScaleFactor: 1.0)
   ```

3. **通常の画面はユーザー設定を尊重**
   - 設定画面、リスト、記事閲覧など

4. **Flexibleレイアウトを使う**
   - 固定サイズに依存しない設計

5. **代替手段を提供**
   - 拡大表示モード、詳細画面など

6. **実機でテスト**
   - 様々なテキストサイズ設定でUIを確認

---

### ❌ 避けるべき事項

1. **アプリ全体でtextScaleFactorを1.0に固定**
   - アクセシビリティを無視

2. **固定サイズに依存したレイアウト**
   - UI崩れの原因

3. **理由なくユーザー設定を無視**
   - ストアレビューで批判される

4. **テストせずにリリース**
   - 実際のユーザー環境で確認が必要

---

## 📝 実装チェックリスト

### 開発時

- [ ] ダッシュボード・グラフ画面でtextScaleFactorを固定または制限
- [ ] 通常の画面ではユーザー設定を尊重
- [ ] Flexibleレイアウトを使用
- [ ] overflow処理を適切に設定

### テスト時

- [ ] テキストサイズ「小」でテスト
- [ ] テキストサイズ「標準」でテスト
- [ ] テキストサイズ「大」でテスト
- [ ] テキストサイズ「最大」でテスト
- [ ] UI崩れがないか確認

### リリース前

- [ ] アクセシビリティ対応をストア説明に記載
- [ ] 必要に応じて代替手段を提供
- [ ] ユーザーガイドに説明を追加

---

## 🔍 AIと一緒に実装する

### Cursor / Claude Codeでの指示例

```
Composer（Ctrl+I）で：

「ダッシュボード画面を作成してください。
- テキストサイズ変更に対応するため、textScaleFactorを1.0に固定
- 売上グラフ、メトリクスカード（今日/今月の売上）を表示
- レイアウトはFlexibleを使って崩れないように」
```

```
Chat（Ctrl+L）で：

「このダッシュボード画面で、ユーザーがテキストサイズを「最大」に設定した場合の
UI崩れを防ぐにはどうすればいいですか？アクセシビリティも考慮した解決策を教えてください。」
```

---

## まとめ

**テキストサイズ変更対応は、実用的なアプリ開発で重要です：**

1. **アクセシビリティを尊重** - 通常の画面ではユーザー設定を適用
2. **UI安定性を確保** - ダッシュボード・グラフでは固定または制限
3. **バランスを取る** - 最大値制限（1.0〜1.3）が実用的
4. **代替手段を提供** - 拡大表示モードなど
5. **実機でテスト** - 様々な設定で確認

これにより、アクセシビリティとUI品質の両立が可能になります。

---

**次のステップ:** 実際のダッシュボードやグラフを含むアプリで、テキストサイズ対応を実装してみましょう。

➡️ **関連レシピ:**
- [`#5-4: レスポンシブデザインの基礎`](04_responsive_design_basics.md)
- [`#4-1: Cursorを使った効率的な開発ワークフロー`](../04_secret_sauce_recipes/01_cursor_workflow.md)
