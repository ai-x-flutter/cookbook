# 重要概念#2-2-2: 状態管理の基礎 Part2: より実践的なパターン

## はじめに

[状態管理の基礎](./02_state_management_basics.md)では、StatefulWidget、InheritedWidget、ChangeNotifierといった基本的なパターンを学びました。

この章では、実際のアプリ開発でよく遭遇する、より実践的なパターンを学びます。これらは毎回使うわけではありませんが、知っておくことで対応できる範囲が大きく広がります。また、AIxFlutterの場合であれば、このようなパターンがあることを知っていれば、自分でコードを書けなくても指示すればAIがコードを書いてくれます。AIにとっては、このようなコードを書くのは得意です。

## 1. 子→親の状態通知パターン

子Widgetの状態を親Widgetが知る必要がある場合のパターンです。

### コールバック関数（最も基本的）
```dart
// 子Widget
class CounterWidget extends StatefulWidget {
  final Function(int) onCountChanged; // コールバック

  const CounterWidget({
    super.key,
    required this.onCountChanged,
  });

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
    // 親に通知
    widget.onCountChanged(_counter);
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

// 親Widget
class ParentWidget extends StatefulWidget {
  const ParentWidget({super.key});

  @override
  State<ParentWidget> createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  int _childCount = 0;

  void _onChildCountChanged(int newCount) {
    setState(() {
      _childCount = newCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('親が知っている子のカウント: $_childCount'),
        CounterWidget(
          onCountChanged: _onChildCountChanged,
        ),
      ],
    );
  }
}
```

### 複数の値を通知する場合

データクラスを使って構造化します。
```dart
// データクラス
class FormData {
  final String name;
  final String email;
  final bool agreedToTerms;

  FormData({
    required this.name,
    required this.email,
    required this.agreedToTerms,
  });
}

// 子Widget（フォーム）
class UserFormWidget extends StatefulWidget {
  final Function(FormData) onFormChanged;

  const UserFormWidget({
    super.key,
    required this.onFormChanged,
  });

  @override
  State<UserFormWidget> createState() => _UserFormWidgetState();
}

class _UserFormWidgetState extends State<UserFormWidget> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_notifyParent);
    _emailController.addListener(_notifyParent);
  }

  void _notifyParent() {
    widget.onFormChanged(FormData(
      name: _nameController.text,
      email: _emailController.text,
      agreedToTerms: _agreedToTerms,
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: '名前'),
        ),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'メール'),
        ),
        CheckboxListTile(
          title: const Text('利用規約に同意'),
          value: _agreedToTerms,
          onChanged: (value) {
            setState(() {
              _agreedToTerms = value ?? false;
            });
            _notifyParent();
          },
        ),
      ],
    );
  }
}

// 親Widget
class ParentWidget extends StatefulWidget {
  const ParentWidget({super.key});

  @override
  State<ParentWidget> createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  FormData? _formData;
  bool _canSubmit = false;

  void _onFormChanged(FormData data) {
    setState(() {
      _formData = data;
      _canSubmit = data.name.isNotEmpty &&
                   data.email.isNotEmpty &&
                   data.agreedToTerms;
    });
  }

  void _submit() {
    if (_canSubmit && _formData != null) {
      print('送信: ${_formData!.name}, ${_formData!.email}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserFormWidget(
          onFormChanged: _onFormChanged,
        ),
        ElevatedButton(
          onPressed: _canSubmit ? _submit : null,
          child: const Text('送信'),
        ),
      ],
    );
  }
}
```

### ValueNotifier（リアルタイム監視）

親が子の状態変化を自動的に受け取りたい場合に使用します。
```dart
// 子Widget
class CounterWidget extends StatefulWidget {
  final ValueNotifier<int> counterNotifier; // 親から渡される

  const CounterWidget({
    super.key,
    required this.counterNotifier,
  });

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  void _increment() {
    widget.counterNotifier.value++;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.counterNotifier,
      builder: (context, count, child) {
        return Column(
          children: [
            Text('Count: $count'),
            ElevatedButton(
              onPressed: _increment,
              child: const Text('Increment'),
            ),
          ],
        );
      },
    );
  }
}

// 親Widget
class ParentWidget extends StatefulWidget {
  const ParentWidget({super.key});

  @override
  State<ParentWidget> createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  final _counterNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _counterNotifier.addListener(() {
      print('子のカウントが変更: ${_counterNotifier.value}');
    });
  }

  @override
  void dispose() {
    _counterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<int>(
          valueListenable: _counterNotifier,
          builder: (context, count, child) {
            return Text('親が知っているカウント: $count');
          },
        ),
        CounterWidget(
          counterNotifier: _counterNotifier,
        ),
      ],
    );
  }
}
```

**使い分け：**

| パターン | 用途 | 頻度 |
|---------|------|------|
| コールバック関数 | シンプルな通知 | ★★★★★ |
| データクラス + コールバック | 複数の値を通知 | ★★★★☆ |
| ValueNotifier | リアルタイム監視 | ★★★☆☆ |

## 2. RouteObserver（画面遷移のライフサイクル）

画面の表示/非表示を検知して処理を行うパターンです。

### セットアップ
```dart
// main.dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // RouteObserverをグローバルに定義
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      navigatorObservers: [routeObserver], // 登録
      home: HomeScreen(),
    );
  }
}
```

### 基本的な使い方
```dart
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      MyApp.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    MyApp.routeObserver.unsubscribe(this);
    super.dispose();
  }

  // 画面が表示されたとき
  @override
  void didPush() {
    print('画面が表示されました');
  }

  // 画面に戻ってきたとき
  @override
  void didPopNext() {
    print('画面に戻ってきました');
    _refreshData(); // データを再読み込み
  }

  // 他の画面に遷移したとき
  @override
  void didPushNext() {
    print('他の画面に遷移しました');
  }

  // 画面が閉じられるとき
  @override
  void didPop() {
    print('画面が閉じられました');
  }

  void _refreshData() {
    // データの再読み込み
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Screen')),
      body: Center(child: Text('画面')),
    );
  }
}
```

### 実践例1：リスト画面のデータ更新
```dart
class FavoriteListScreen extends StatefulWidget {
  const FavoriteListScreen({super.key});

  @override
  State<FavoriteListScreen> createState() => _FavoriteListScreenState();
}

class _FavoriteListScreenState extends State<FavoriteListScreen> with RouteAware {
  List<FavoriteData> _favorites = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      MyApp.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    MyApp.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didPopNext() {
    // 詳細画面からお気に入りを変更して戻ってきた時に更新
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoriteService.instance.getFavorites();
    if (mounted) {
      setState(() {
        _favorites = favorites;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('お気に入り')),
      body: ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final favorite = _favorites[index];
          return ListTile(
            title: Text(favorite.name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(id: favorite.id),
                ),
              );
              // 戻ってきたら didPopNext() が自動的に呼ばれる
            },
          );
        },
      ),
    );
  }
}
```

### 実践例2：タイマーの制御（省電力）
```dart
class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> with RouteAware {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      MyApp.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    MyApp.routeObserver.unsubscribe(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didPush() {
    _startTimer();
  }

  @override
  void didPopNext() {
    // 画面に戻ってきた時：タイマー再開 + 時刻即座に更新
    setState(() {
      _currentTime = DateTime.now();
    });
    _startTimer();
  }

  @override
  void didPushNext() {
    // 他の画面に行った時：タイマー停止（省電力）
    _stopTimer();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('世界時計')),
      body: Center(
        child: Text(
          DateFormat('HH:mm:ss').format(_currentTime),
          style: TextStyle(fontSize: 48),
        ),
      ),
    );
  }
}
```

### LifecycleObserverMixin（コードの共通化）

RouteObserverのボイラープレートを削減するためのMixinです。
```dart
// lib/mixins/lifecycle_observer_mixin.dart
import 'package:flutter/material.dart';

mixin LifecycleObserverMixin<T extends StatefulWidget> on State<T>, RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      MyApp.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    MyApp.routeObserver.unsubscribe(this);
    super.dispose();
  }

  // サブクラスでオーバーライド可能なメソッド
  void onScreenResumed() {}
  void onScreenPaused() {}

  @override
  void didPush() {
    onScreenResumed();
  }

  @override
  void didPopNext() {
    onScreenResumed();
  }

  @override
  void didPushNext() {
    onScreenPaused();
  }

  @override
  void didPop() {
    onScreenPaused();
  }
}
```

**使用例：**
```dart
class FavoriteListScreen extends StatefulWidget {
  const FavoriteListScreen({super.key});

  @override
  State<FavoriteListScreen> createState() => _FavoriteListScreenState();
}

class _FavoriteListScreenState extends State<FavoriteListScreen> 
    with LifecycleObserverMixin {
  
  List<FavoriteData> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void onScreenResumed() {
    // 画面に戻ってきた時に自動的に呼ばれる
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoriteService.instance.getFavorites();
    if (mounted) {
      setState(() {
        _favorites = favorites;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('お気に入り')),
      body: ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_favorites[index].name),
          );
        },
      ),
    );
  }
}
```

**RouteObserverを使うべき場面：**

| ユースケース | 頻度 | 理由 |
|------------|------|------|
| リスト画面のデータ更新 | ★★★★★ | 詳細画面で編集して戻ってきた時 |
| タイマーの制御 | ★★★★☆ | 省電力化 |
| API呼び出しの制御 | ★★★☆☆ | 無駄な通信を防ぐ |
| 動画/音声の再生制御 | ★★☆☆☆ | バックグラウンド再生防止 |

## 3. FocusNode（フォーカス管理）

テキストフィールドのフォーカスを制御するパターンです。

### 基本的な使い方
```dart
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    // Emailが空なら、Emailにフォーカス
    if (_emailController.text.isEmpty) {
      _emailFocusNode.requestFocus();
      return;
    }

    // Passwordが空なら、Passwordにフォーカス
    if (_passwordController.text.isEmpty) {
      _passwordFocusNode.requestFocus();
      return;
    }

    // ログイン処理
    print('Login: ${_emailController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          decoration: InputDecoration(labelText: 'メール'),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            // Enterキーで次のフィールドへ
            _passwordFocusNode.requestFocus();
          },
        ),
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          decoration: InputDecoration(labelText: 'パスワード'),
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            // Enterキーで送信
            _submit();
          },
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text('ログイン'),
        ),
      ],
    );
  }
}
```

### フォーカス状態の監視
```dart
class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    // フォーカス状態の変化を監視
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: '検索',
        // フォーカス時に色を変える
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: _isFocused ? Colors.blue : Colors.grey,
            width: _isFocused ? 2 : 1,
          ),
        ),
        suffixIcon: _isFocused
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                },
              )
            : Icon(Icons.search),
      ),
    );
  }
}
```

**FocusNodeを使うべき場面：**

| ユースケース | 頻度 | 理由 |
|------------|------|------|
| フォームのバリデーション | ★★★★☆ | エラー時に該当フィールドへ |
| 複数フィールドの順次入力 | ★★★☆☆ | UX向上 |
| フォーカス状態の視覚的変化 | ★★☆☆☆ | デザイン要件 |

## 4. ScrollController（スクロール制御）

リストやスクロール可能なWidgetを制御するパターンです。

### 基本的な使い方
```dart
class ScrollableList extends StatefulWidget {
  const ScrollableList({super.key});

  @override
  State<ScrollableList> createState() => _ScrollableListState();
}

class _ScrollableListState extends State<ScrollableList> {
  final _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // スクロール位置を監視
      if (_scrollController.offset > 500) {
        if (!_showScrollToTop) {
          setState(() {
            _showScrollToTop = true;
          });
        }
      } else {
        if (_showScrollToTop) {
          setState(() {
            _showScrollToTop = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        controller: _scrollController,
        itemCount: 100,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
          );
        },
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              child: Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}
```

### 無限スクロール（ページネーション）
```dart
class InfiniteScrollList extends StatefulWidget {
  const InfiniteScrollList({super.key});

  @override
  State<InfiniteScrollList> createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> {
  final _scrollController = ScrollController();
  final List<String> _items = [];
  bool _isLoading = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _scrollController.addListener(() {
      // 下端近くまでスクロールしたら次のページを読み込む
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading) {
          _loadItems();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // APIからデータ取得（シミュレーション）
    await Future.delayed(Duration(seconds: 1));
    final newItems = List.generate(20, (i) => 'Item ${(_page - 1) * 20 + i}');

    if (mounted) {
      setState(() {
        _items.addAll(newItems);
        _page++;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
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

**ScrollControllerを使うべき場面：**

| ユースケース | 頻度 | 理由 |
|------------|------|------|
| 「トップへ戻る」ボタン | ★★★★☆ | UX向上 |
| 無限スクロール | ★★★★☆ | 大量データの表示 |
| スクロール位置の保存/復元 | ★★☆☆☆ | 画面遷移時の状態保持 |

## 5. TextEditingController（テキスト入力制御）

テキストフィールドの値を制御するパターンです。

### 基本的な使い方
```dart
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<String> _results = [];

  @override
  void initState() {
    super.initState();
    // テキスト変更を監視
    _searchController.addListener(() {
      _performSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    // 検索処理
    setState(() {
      _results = ['Result 1 for $query', 'Result 2 for $query'];
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: '検索',
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: _clearSearch,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_results[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

### デバウンス（入力の遅延処理）

リアルタイム検索でAPI呼び出しを減らすパターンです。
```dart
class DebouncedSearchScreen extends StatefulWidget {
  const DebouncedSearchScreen({super.key});

  @override
  State<DebouncedSearchScreen> createState() => _DebouncedSearchScreenState();
}

class _DebouncedSearchScreenState extends State<DebouncedSearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<String> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // 既存のタイマーをキャンセル
    _debounceTimer?.cancel();

    // 500ms後に検索実行
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // API呼び出し（シミュレーション）
    await Future.delayed(Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _results = ['Result 1 for $query', 'Result 2 for $query'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: '検索',
            suffixIcon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_results[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

**TextEditingControllerを使うべき場面：**

| ユースケース | 頻度 | 理由 |
|------------|------|------|
| リアルタイム検索 | ★★★★☆ | ユーザー入力に応じた動的表示 |
| フォームのクリア | ★★★★☆ | UX向上 |
| 入力値の検証 | ★★★☆☆ | バリデーション |

## まとめ

この章で学んだパターンは、毎回使うわけではありませんが、知っておくことで対応できる範囲が大きく広がります。

| パターン | 使用頻度 | 主な用途 |
|---------|---------|---------|
| コールバック関数 | ★★★★★ | 子→親の状態通知 |
| RouteObserver | ★★★★☆ | 画面遷移時の処理 |
| FocusNode | ★★★☆☆ | フォーム操作の改善 |
| ScrollController | ★★★☆☆ | スクロール制御 |
| TextEditingController | ★★★★☆ | テキスト入力制御 |

**重要なポイント：**

- これらはすべてFlutterの標準機能
- 外部ライブラリ不要
- シンプルで理解しやすい
- 長期的に安定
