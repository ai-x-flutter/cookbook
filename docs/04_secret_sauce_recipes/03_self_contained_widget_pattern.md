# レシピ#4-3: 自己完結型Widgetパターン

## はじめに

前のレシピで、Riverpodなどの複雑な状態管理ライブラリを避けるべき理由を学びました。

では、代わりに何を使うべきか？答えは**自己完結型Widget**です。

これは、Widgetが自分の状態とライフサイクルを完全に管理するシンプルなパターンです。

## 自己完結型Widgetとは？

**自己完結型Widget**とは：

- 自分の状態（State）を持つ
- 自分のライフサイクル（initState、dispose）を管理する
- 必要なデータ取得を自分で行う
- 他のWidgetに依存しない

**利点:**
- ✅ シンプルで理解しやすい
- ✅ AIが生成しやすい
- ✅ テストが容易
- ✅ 再利用可能
- ✅ デバッグしやすい

## 基本的な例: 天気情報Widget

```dart
class WeatherWidget extends StatefulWidget {
  final String cityName;

  const WeatherWidget({
    super.key,
    required this.cityName,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  // 状態
  String? _temperature;
  String? _condition;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Widget作成時にデータ取得
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // API呼び出し（例）
      final response = await http.get(
        Uri.parse('https://api.weather.com/v1/weather?city=${widget.cityName}'),
      );

      if (mounted) {  // ← 重要: Widget破棄チェック
        final data = jsonDecode(response.body);
        setState(() {
          _temperature = data['temperature'];
          _condition = data['condition'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('エラー: $_error'),
            ElevatedButton(
              onPressed: _fetchWeather,
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              widget.cityName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text('$_temperature°C'),
            Text(_condition ?? ''),
          ],
        ),
      ),
    );
  }
}
```

### このパターンの利点

1. **完全に独立している**
   - 他のWidgetに影響を与えない
   - どこにでも配置できる

2. **ライフサイクルが明確**
   - initState: データ取得開始
   - dispose: リソース解放（後述）

3. **エラーハンドリングが含まれる**
   - ローディング状態
   - エラー状態
   - 成功状態

4. **AIが理解しやすい**
   ```
   プロンプト: 「東京の天気を表示するWidgetを作って」
   → Claudeが上記のようなコードを生成
   ```

## タイマーやリソースの管理

### 例: 自動更新される時計Widget

```dart
class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late String _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    // 1秒ごとに更新
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateTime(),
    );
  }

  @override
  void dispose() {
    // ← 重要: タイマーを停止
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentTime,
      style: Theme.of(context).textTheme.displayMedium,
    );
  }
}
```

**重要なポイント:**

1. **disposeでリソース解放**
   - タイマーの停止
   - ストリームのクローズ
   - コントローラーの破棄

2. **mountedチェック**
   - 非同期処理後は必ず確認
   - Widgetが破棄されていないか確認

## 実践例: ページネーション付きリスト

```dart
class PaginatedListWidget extends StatefulWidget {
  const PaginatedListWidget({super.key});

  @override
  State<PaginatedListWidget> createState() => _PaginatedListWidgetState();
}

class _PaginatedListWidgetState extends State<PaginatedListWidget> {
  final List<String> _items = [];
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
    // スクロール監視
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();  // ← 重要
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // API呼び出し（例）
      final response = await http.get(
        Uri.parse('https://api.example.com/items?page=$_currentPage'),
      );

      if (mounted) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _items.addAll(data.cast<String>());
          _currentPage++;
          _hasMore = data.isNotEmpty;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return ListTile(
          title: Text(_items[index]),
        );
      },
    );
  }
}
```

## パターンのベストプラクティス

### 1. 状態は最小限に

```dart
// ❌ 悪い例: 不要な状態
class BadWidget extends StatefulWidget {
  @override
  State<BadWidget> createState() => _BadWidgetState();
}

class _BadWidgetState extends State<BadWidget> {
  String? _calculatedValue;  // これはbuild内で計算できる
  DateTime? _currentDate;    // これはbuild内で取得できる

  @override
  Widget build(BuildContext context) {
    // ...
  }
}

// ✅ 良い例: 必要な状態だけ
class GoodWidget extends StatefulWidget {
  @override
  State<GoodWidget> createState() => _GoodWidgetState();
}

class _GoodWidgetState extends State<GoodWidget> {
  int _counter = 0;  // これは本当に状態として必要

  @override
  Widget build(BuildContext context) {
    final calculatedValue = _counter * 2;  // 計算値
    final currentDate = DateTime.now();     // 現在値
    // ...
  }
}
```

### 2. リソースは必ず解放

```dart
@override
void dispose() {
  // コントローラー
  _textController.dispose();
  _scrollController.dispose();
  _animationController.dispose();

  // タイマー
  _timer?.cancel();

  // ストリーム購読
  _subscription?.cancel();

  super.dispose();
}
```

### 3. mountedチェックを忘れずに

```dart
Future<void> _fetchData() async {
  final data = await api.fetch();

  // ← 非同期処理の後は必ずチェック
  if (mounted) {
    setState(() {
      _data = data;
    });
  }
}
```

### 4. 明確な命名

```dart
// ✅ 状態変数は _ で始める
int _counter = 0;
String? _userName;
bool _isLoading = false;

// ✅ メソッドも _ で始める（プライベート）
void _increment() { }
Future<void> _fetchData() async { }
```

## Cursorでの活用

### プロンプト例

```
自己完結型のWidgetを作成してください:

要件:
- ニュース記事のリストを表示
- APIから取得（https://api.example.com/news）
- Pull-to-refresh対応
- エラーハンドリング付き
- ローディング表示

注意点:
- StatefulWidgetを使用
- ライフサイクル管理を適切に
- mountedチェックを忘れずに
- リソースは確実に解放
```

Claudeがこのパターンに従ったコードを生成します。

## まとめ

自己完結型Widgetパターン：

### 基本原則
1. ✅ 自分の状態を持つ
2. ✅ 自分でライフサイクル管理
3. ✅ 他のWidgetに依存しない
4. ✅ リソースを確実に解放

### 重要なポイント
- **initState**: 初期化、データ取得開始
- **dispose**: リソース解放
- **mounted**: 非同期処理後のチェック
- **setState**: 状態更新

### 利点
- シンプルで理解しやすい
- AIが生成しやすい
- テストが容易
- デバッグしやすい
- バージョンアップに強い

次のレシピでは、Serviceクラスパターンについて解説します。

➡️ **次のレシピへ:** [`04_service_class_pattern.md`](./04_service_class_pattern.md)
