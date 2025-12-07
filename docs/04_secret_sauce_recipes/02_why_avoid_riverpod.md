# レシピ#4-2: なぜRiverpodを避けるべきか - 個人開発 × AI時代の状態管理

## はじめに

Flutter開発を学ぶと、必ず「Riverpod」という状態管理ライブラリの名前を聞くでしょう。多くのチュートリアルが推奨し、「現代的な状態管理」として紹介されています。

しかし、**個人開発 × AI を前提にした場合、Riverpodは明確に避けるべき**です。

このレシピでは、その理由を明確に説明します。

## Riverpodとは？

Riverpodは、Flutterの状態管理ライブラリです。Provider の後継として開発され、以下の特徴があります：

- コンパイル時の型安全性
- テストが容易
- 依存性注入（DI）の仕組み
- グローバル状態の管理

**一見すると素晴らしいツール**に見えます。実際、大規模開発やチーム開発では力を発揮します。

## ❌ しかし、個人開発には向かない

### 問題1: バージョンアップの負債が大きい

**これが最大の問題です。**

Riverpodは破壊的変更が多く、バージョンアップのたびにコードの大幅な書き直しが必要になります。

#### 何が変わるのか？

- `provider` の書き方が変わる
- `autoDispose` の扱いが変わる
- `ref` の扱いが変わる
- `AsyncValue` の仕様が変わる
- `riverpod_generator` の仕様が変わる

**実際の例:**

```dart
// Riverpod 1.x
final counterProvider = StateProvider<int>((ref) => 0);

// Riverpod 2.x
final counterProvider = NotifierProvider<Counter, int>(Counter.new);

class Counter extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}
```

**個人開発の場合:**
- 半年ぶりにプロジェクトを開いたらコンパイルが通らない
- Riverpodのドキュメントを読み直す必要がある
- アプリの改善ではなく、ライブラリ対応に時間を取られる

**これは生産性の大幅な低下です。**

### 問題2: 依存パッケージが連鎖的に壊れる

Riverpodを使うと、通常以下のパッケージも必要になります：

```yaml
dependencies:
  flutter_riverpod: ^2.x.x
  riverpod_annotation: ^2.x.x

dev_dependencies:
  riverpod_generator: ^2.x.x
  build_runner: ^2.x.x
  # 場合によっては
  freezed: ^2.x.x
  json_serializable: ^6.x.x
```

**問題:**
- これらが雪崩式に壊れる
- Flutter SDKのアップデート時に大混乱
- `build_runner`が動かなくなる
- バージョンの組み合わせ問題に悩まされる

**個人開発ではこの負債に時間を取られます。**

### 問題3: AIが変更に追随できない

**これがAI時代の重大な問題です。**

AI（Claude、ChatGPT、Gemini）は、Riverpodの最新仕様を正しく理解していないことが多いです。

**理由:**
- Riverpodの進化が速すぎる
- AIのトレーニングデータが古い
- ドキュメントが追いつかない

**結果:**
```
あなた: 「Riverpodでカウンターアプリを作って」

AI: [古い書き方のコードを生成]

あなた: 「これは古いバージョンです。最新のRiverpod 2.xで」

AI: [微妙に間違ったコードを生成]

あなた: 「providerの依存関係が壊れています」

AI: [また別の間違ったコードを生成]
```

**AIとの相性が最悪になります。**

個人開発でAIを活用する最大の理由は「開発速度の向上」ですが、Riverpodを使うとその利点が失われます。

### 問題4: 個人アプリでは過剰機能

Riverpodが真価を発揮するのは：

- ✅ 大規模アプリ（10万行以上）
- ✅ 複数人チーム（5人以上）
- ✅ レイヤー分割が必要
- ✅ 厳密なテストが必須
- ✅ 再利用性の高いアーキテクチャ

**個人開発の場合:**
- ❌ 小〜中規模アプリ（数千〜数万行）
- ❌ 一人開発
- ❌ シンプルな構造で十分
- ❌ テストは最小限
- ❌ 柔軟性が重要

**むしろ構造が複雑になるだけです。**

### 問題5: Flutter本体の変化にも弱い

Flutter SDKの更新で：

- `immutable class` の扱い
- `StateNotifier` 的なもの
- `generator` の仕様変更
- `build_runner` の相性問題

などに巻き込まれます。

**個人開発だと時間のロスが致命的です。**

## ✅ 代わりに何を使うべきか？

### 推奨アプローチ: シンプルな3層構成

```
1. 自己完結型Widget（UI + ローカル状態）
   ↓
2. Service クラス（ビジネスロジック、API、DB）
   ↓
3. 必要なら Provider を軽く使う（グローバル状態）
```

**この構成の利点:**
- ✅ バージョンアップの影響が最小
- ✅ AIが理解しやすい
- ✅ シンプルで保守しやすい
- ✅ テストも容易
- ✅ 学習コストが低い

### 具体例: カウンターアプリ

#### ❌ Riverpod版（複雑）

```dart
// provider定義
final counterProvider = NotifierProvider<Counter, int>(Counter.new);

class Counter extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

// UI
class CounterScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Column(
      children: [
        Text('$count'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).increment(),
          child: Text('+1'),
        ),
      ],
    );
  }
}
```

#### ✅ シンプル版（推奨）

```dart
class CounterScreen extends StatefulWidget {
  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _count = 0;

  void _increment() {
    setState(() => _count++);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$_count'),
        ElevatedButton(
          onPressed: _increment,
          child: Text('+1'),
        ),
      ],
    );
  }
}
```

**どちらがシンプルか一目瞭然です。**

### より実践的な例: 設定の保存

#### ❌ Riverpod版

```dart
// 設定provider
@riverpod
class Settings extends _$Settings {
  @override
  FutureOr<SettingsData> build() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsData.fromPrefs(prefs);
  }

  Future<void> updateTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', mode.name);
    ref.invalidateSelf();
  }
}

// riverpod_generator, build_runner, freezed なども必要
```

#### ✅ シンプル版（推奨）

```dart
class SettingsService {
  static final instance = SettingsService._();
  SettingsService._();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('theme') ?? 'system';
    _themeMode = ThemeMode.values.byName(themeName);
  }

  Future<void> updateTheme(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', mode.name);
  }
}
```

**シンプルで、AIも理解しやすく、バージョンアップにも強い。**

## まとめ

### Riverpodの問題点（個人開発 × AI）

1. ❌ **バージョンアップの負債が大きい** - 最大の問題
2. ❌ **依存パッケージが連鎖的に壊れる** - build_runnerの地獄
3. ❌ **AIが追随できない** - 開発速度が下がる
4. ❌ **個人アプリでは過剰** - 不要な複雑さ
5. ❌ **Flutter本体の変化に弱い** - 時間のロス

### 推奨アプローチ

1. ✅ **StatefulWidget** - ローカル状態
2. ✅ **Serviceクラス** - ビジネスロジック
3. ✅ **必要なら軽いProvider** - グローバル状態

**この構成なら:**
- バージョンアップに強い
- AIが理解しやすい
- シンプルで保守しやすい
- 学習コストが低い

## 重要なメッセージ

**「Riverpodは悪いツールではありません。**
**ただし、個人開発 × AI という文脈では、明確に避けるべきです。」**

大規模プロジェクトやチーム開発に参加する際には、Riverpodの学習も有益でしょう。しかし、個人で小〜中規模のアプリを作るなら、シンプルな構成の方が圧倒的に効率的です。

**管理コストより開発速度を優先しましょう。**

次のレシピでは、自己完結型Widgetパターンについて詳しく解説します。

➡️ **次のレシピへ:** [`03_self_contained_widget_pattern.md`](./03_self_contained_widget_pattern.md)
