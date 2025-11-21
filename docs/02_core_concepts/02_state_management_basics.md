# 重要概念#2-2: 状態管理の基礎

## はじめに

状態管理は、Flutterアプリ開発において最も重要な概念の一つです。しかし、状態管理ライブラリに依存する前に、**Flutterの基本機能を使って状態管理の本質を理解することが重要**です。

この章では、外部ライブラリに頼らず、Flutterの標準機能だけを使って効果的な状態管理を実装する方法を学びます。

## なぜFlutterの基本機能を学ぶべきか

### 状態管理ライブラリ依存の問題

多くのチュートリアルが、すぐに状態管理ライブラリ（Provider、Riverpod、BLoC等）の使用を推奨していますが、以下の問題があります：

1. **本質的な理解の欠如**
   - ライブラリの使い方は覚えても、状態管理の原理を理解できない
   - 問題が起きたときにデバッグできない

2. **柔軟性の欠如**
   - ライブラリの制約に縛られる
   - シンプルな問題にも複雑な解決策を強いられる

3. **長期的なリスク**
   - ライブラリの仕様変更に影響される
   - ライブラリの保守終了リスク

### Flutterの基本機能の利点

✅ **本質的な理解**: 状態管理の原理を直接学べる  
✅ **柔軟性**: アプリの要件に合わせて自由に設計できる  
✅ **保守性**: Flutterのコア機能なので長期的に安定  
✅ **デバッグ容易**: 何が起きているか明確に理解できる  

## 状態管理の基本パターン

### 1. StatefulWidget（最も基本的なパターン）

各Widgetが自分の状態を管理する、最もシンプルで強力なパターンです。
```dart
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_counter'),
        ElevatedButton(
          onPressed: _increment,
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

**このパターンが適している場合：**
- 状態が特定のWidget内でのみ使用される
- 他のWidgetと状態を共有する必要がない
- シンプルな状態（カウンター、入力フォーム、表示/非表示等）

### 2. InheritedWidget（状態の共有）

複数のWidgetで状態を共有する必要がある場合、InheritedWidgetを使用します。
```dart
// 共有する状態を定義
class AppState {
  final String userName;
  final ThemeMode themeMode;

  AppState({
    required this.userName,
    required this.themeMode,
  });

  AppState copyWith({
    String? userName,
    ThemeMode? themeMode,
  }) {
    return AppState(
      userName: userName ?? this.userName,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

// InheritedWidgetの定義
class AppStateWidget extends InheritedWidget {
  final AppState state;
  final Function(AppState) updateState;

  const AppStateWidget({
    super.key,
    required this.state,
    required this.updateState,
    required super.child,
  });

  static AppStateWidget? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateWidget>();
  }

  static AppStateWidget of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No AppStateWidget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppStateWidget oldWidget) {
    return state != oldWidget.state;
  }
}

// アプリのルートで状態を管理
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppState _state = AppState(
    userName: 'Guest',
    themeMode: ThemeMode.system,
  );

  void _updateState(AppState newState) {
    setState(() {
      _state = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppStateWidget(
      state: _state,
      updateState: _updateState,
      child: MaterialApp(
        themeMode: _state.themeMode,
        home: HomeScreen(),
      ),
    );
  }
}

// 子Widgetから状態を使用
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateWidget.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${appState.state.userName}'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final newState = appState.state.copyWith(
              userName: 'User',
            );
            appState.updateState(newState);
          },
          child: const Text('Update Name'),
        ),
      ),
    );
  }
}
```

### 3. ChangeNotifier（より高度な状態管理）

複雑な状態管理が必要な場合、ChangeNotifierを使用します。これはFlutterの標準機能です。
```dart
import 'package:flutter/foundation.dart';

// 状態を管理するクラス
class SettingsService extends ChangeNotifier {
  // シングルトンパターン
  static final SettingsService instance = SettingsService._internal();
  SettingsService._internal();
  factory SettingsService() => instance;

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners(); // リスナーに通知
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }
}

// Widgetで使用
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsService.instance;

  @override
  void initState() {
    super.initState();
    // 変更を監視
    _settings.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // リスナーを解除
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('通知'),
          value: _settings.notificationsEnabled,
          onChanged: _settings.setNotificationsEnabled,
        ),
        ListTile(
          title: const Text('テーマ'),
          subtitle: Text(_settings.themeMode.toString()),
          onTap: () {
            // テーマ切り替えダイアログ等
          },
        ),
      ],
    );
  }
}
```

## 実践的なパターン

### Widget独立化パターン

各Widgetが自分のライフサイクルと状態を管理する、保守性の高いパターンです。
```dart
// 例：天気情報を表示するWidget
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
  Timer? _timer;
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    // 10分毎に自動更新
    _timer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _fetchWeather(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // タイマーを確実に停止
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await WeatherApi.fetch(widget.cityName);
      if (mounted) {
        setState(() {
          _weatherData = data;
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
    if (_isLoading && _weatherData == null) {
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
              child: const Text('リトライ'),
            ),
          ],
        ),
      );
    }

    if (_weatherData == null) {
      return const Center(child: Text('データなし'));
    }

    return Column(
      children: [
        Text('${widget.cityName}: ${_weatherData!.temperature}°C'),
        Text(_weatherData!.condition),
      ],
    );
  }
}
```

**このパターンの利点：**
- ✅ ライフサイクルが明確（Widget作成時に開始、破棄時に停止）
- ✅ 他のWidgetに影響を与えない
- ✅ デバッグが容易
- ✅ テストが簡単
- ✅ 再利用可能

## 状態の種類と管理方法

### 1. ローカル状態（Widget内）

**特徴：** 特定のWidget内でのみ使用される状態

**管理方法：** StatefulWidget

**例：**
- フォームの入力値
- アニメーションの進行状態
- 展開/折りたたみ状態
- ページネーションの現在ページ

### 2. 共有状態（複数Widget間）

**特徴：** 複数のWidgetで共有される状態

**管理方法：** ChangeNotifier + シングルトンパターン

**例：**
- ユーザー設定（テーマ、言語）
- お気に入りリスト
- ショッピングカート
- 認証状態

### 3. 永続化が必要な状態

**特徴：** アプリを閉じても保持したい状態

**管理方法：** ChangeNotifier + SharedPreferences

**例：**
```dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService extends ChangeNotifier {
  static final FavoriteService instance = FavoriteService._internal();
  FavoriteService._internal();
  factory FavoriteService() => instance;

  static const String _favoritesKey = 'favorites';
  final Set<String> _favorites = {};
  bool _isInitialized = false;

  Set<String> get favorites => Set.unmodifiable(_favorites);

  /// 初期化（アプリ起動時に一度だけ呼ぶ）
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList(_favoritesKey) ?? [];
    _favorites.addAll(savedFavorites);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addFavorite(String itemId) async {
    _favorites.add(itemId);
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> removeFavorite(String itemId) async {
    _favorites.remove(itemId);
    await _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String itemId) {
    return _favorites.contains(itemId);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favorites.toList());
  }
}
```

## ベストプラクティス

### 1. 状態の責任を明確にする
```dart
// ❌ 悪い例：全ての状態を1つのServiceで管理
class AppService {
  String userName;
  List<Product> products;
  List<String> favorites;
  ThemeMode theme;
  // ... 全部入り
}

// ✅ 良い例：責任ごとに分割
class UserService {
  String userName;
  // ユーザー関連のみ
}

class FavoriteService {
  List<String> favorites;
  // お気に入り関連のみ
}

class SettingsService {
  ThemeMode theme;
  // 設定関連のみ
}
```

### 2. Widgetのライフサイクルを活用する
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Widget作成時の処理
    _startTimer();
  }

  @override
  void dispose() {
    // Widget破棄時の処理（重要！）
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        // 定期処理
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### 3. mounted チェックを忘れずに
```dart
Future<void> _fetchData() async {
  final data = await api.fetch();
  
  // 非同期処理後は必ずmountedチェック
  if (mounted) {
    setState(() {
      _data = data;
    });
  }
}
```

### 4. シンプルに保つ

複雑な状態管理が必要になったら、まず設計を見直しましょう。多くの場合、Widgetの分割やデータ構造の見直しで解決できます。
```dart
// ❌ 複雑
class ComplexState {
  Map<String, Map<int, List<Data>>> nestedData;
  // ...
}

// ✅ シンプル
class SimpleState {
  List<Data> data;
  // 必要なら別のServiceに分割
}
```

## 状態管理ライブラリはいつ使うべきか

以下の条件を**全て**満たす場合のみ、状態管理ライブラリの導入を検討してください：

1. Flutterの基本機能を十分に理解している
2. 基本機能では解決できない具体的な問題がある
3. チーム全員がライブラリの制約を理解している
4. 長期的な保守を考慮している

**重要：** 最初から状態管理ライブラリに依存せず、まずFlutterの基本機能で実装してみましょう。多くの場合、それで十分です。

## まとめ

- **状態管理の本質を理解する**ことが最も重要
- Flutterの基本機能（StatefulWidget、ChangeNotifier）で大部分のケースに対応できる
- Widget独立化パターンは保守性が高く、実用的
- 状態管理ライブラリは「必要になってから」検討する
- シンプルな設計を心がける

## 次のステップ

[状態管理の基礎 Part2: より実践的なパターン](./02_state_management_basics_part2.md)