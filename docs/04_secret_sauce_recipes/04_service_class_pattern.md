# レシピ#4-4: Serviceクラスパターン - ビジネスロジックの分離

## はじめに

前のレシピで、自己完結型Widgetパターンを学びました。これはUI層の状態管理に最適です。

しかし、アプリが成長すると以下のような疑問が出てきます：

- API呼び出しのコードをWidgetに書くべき？
- データベース操作はどこに書く？
- 設定の保存・読み込みは？
- 複数の画面で共有するロジックは？

答えは**Serviceクラス**です。

## Serviceクラスとは？

**Serviceクラス**は、ビジネスロジックを担当するクラスです：

- API通信
- データベース操作
- 設定の保存・読み込み
- 認証処理
- データ変換

**特徴:**
- Widgetから分離
- シングルトンパターン（通常）
- 状態を持たない（または最小限）

## 基本的な例: 設定Service

```dart
class SettingsService {
  // シングルトンパターン
  static final SettingsService instance = SettingsService._internal();
  SettingsService._internal();
  factory SettingsService() => instance;

  // 設定の状態
  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'ja';

  // Getter
  ThemeMode get themeMode => _themeMode;
  String get language => _language;

  // 初期化（アプリ起動時に1度だけ呼ぶ）
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values.byName(
      prefs.getString('theme_mode') ?? 'system',
    );
    _language = prefs.getString('language') ?? 'ja';
  }

  // テーマ変更
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
  }

  // 言語変更
  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
  }
}
```

### 使い方

```dart
// アプリ起動時
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.instance.initialize();
  runApp(MyApp());
}

// Widgetから使用
class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsService.instance;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('テーマ'),
          subtitle: Text(_settings.themeMode.name),
          onTap: () async {
            // テーマ変更
            await _settings.setThemeMode(ThemeMode.dark);
            setState(() {}); // UI更新
          },
        ),
      ],
    );
  }
}
```

## 実践例: API Service

```dart
class NewsApiService {
  static final NewsApiService instance = NewsApiService._internal();
  NewsApiService._internal();
  factory NewsApiService() => instance;

  final String _baseUrl = 'https://api.example.com';
  final _http = http.Client();

  // ニュース一覧取得
  Future<List<NewsArticle>> getArticles({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _http.get(
        Uri.parse('$_baseUrl/news?page=$page&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => NewsArticle.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to fetch articles: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // 記事詳細取得
  Future<NewsArticle> getArticleById(String id) async {
    try {
      final response = await _http.get(
        Uri.parse('$_baseUrl/news/$id'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NewsArticle.fromJson(data);
      } else {
        throw ApiException('Article not found');
      }
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // リソース解放（アプリ終了時）
  void dispose() {
    _http.close();
  }
}

// カスタム例外
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

// データモデル
class NewsArticle {
  final String id;
  final String title;
  final String content;
  final DateTime publishedAt;

  NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }
}
```

### Widgetから使用

```dart
class NewsListWidget extends StatefulWidget {
  @override
  State<NewsListWidget> createState() => _NewsListWidgetState();
}

class _NewsListWidgetState extends State<NewsListWidget> {
  final _api = NewsApiService.instance;
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final articles = await _api.getArticles();
      if (mounted) {
        setState(() {
          _articles = articles;
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
      return Center(child: Text('エラー: $_error'));
    }

    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return ListTile(
          title: Text(article.title),
          subtitle: Text(
            DateFormat('yyyy/MM/dd').format(article.publishedAt),
          ),
        );
      },
    );
  }
}
```

## データベースService

```dart
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();
  factory DatabaseService() => instance;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'app_database.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // TODO追加
  Future<int> insertTodo(String title) async {
    final db = await database;
    return await db.insert('todos', {
      'title': title,
      'is_completed': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // TODO一覧取得
  Future<List<Todo>> getTodos() async {
    final db = await database;
    final maps = await db.query(
      'todos',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Todo.fromMap(map)).toList();
  }

  // TODO更新
  Future<void> updateTodo(int id, {String? title, bool? isCompleted}) async {
    final db = await database;
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (isCompleted != null) data['is_completed'] = isCompleted ? 1 : 0;

    await db.update(
      'todos',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // TODO削除
  Future<void> deleteTodo(int id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// TODOモデル
class Todo {
  final int id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int,
      title: map['title'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
```

## パターンのベストプラクティス

### 1. シングルトンパターンを使う

```dart
class MyService {
  // ✅ シングルトンパターン
  static final MyService instance = MyService._internal();
  MyService._internal();
  factory MyService() => instance;

  // メソッド
}

// 使用
final service = MyService.instance;
```

### 2. 責任を明確に分割

```dart
// ✅ 良い例: 責任ごとに分割
class ApiService { }      // API通信のみ
class DatabaseService { } // DB操作のみ
class SettingsService { } // 設定のみ

// ❌ 悪い例: 全部入り
class AppService {
  // API、DB、設定、認証...全部
}
```

### 3. エラーハンドリングを統一

```dart
class ApiService {
  Future<T> _request<T>(
    Future<http.Response> Function() request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await request();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw ApiException('HTTP ${response.statusCode}');
      }
    } on SocketException {
      throw ApiException('ネットワークエラー');
    } catch (e) {
      throw ApiException('予期しないエラー: $e');
    }
  }
}
```

### 4. 依存関係を注入可能に（テスト用）

```dart
class NewsService {
  final http.Client httpClient;

  NewsService({
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  // メソッド
}

// テスト時
final mockClient = MockClient();
final service = NewsService(httpClient: mockClient);
```

## Cursorでの活用

### プロンプト例

```
以下の要件でServiceクラスを作成してください:

要件:
- 天気情報を取得するAPIサービス
- エンドポイント: https://api.weather.com/v1/weather
- 都市名で検索
- 7日間の予報を取得

構成:
- WeatherApiService クラス
- シングルトンパターン
- エラーハンドリング付き
- Weatherモデルクラス

注意:
- Riverpodなどは使わない
- シンプルな構造
- テスト可能な設計
```

## まとめ

Serviceクラスパターン：

### 役割
- API通信
- データベース操作
- 設定管理
- 認証処理
- ビジネスロジック

### 基本原則
1. ✅ シングルトンパターン
2. ✅ 責任を明確に分割
3. ✅ Widgetから分離
4. ✅ エラーハンドリング統一

### Widgetとの関係

```
Widget (UI)
  ↓ 使用
Service (ビジネスロジック)
  ↓ 使用
API / Database / SharedPreferences
```

### 利点
- コードが整理される
- テストが容易
- 再利用可能
- デバッグしやすい
- AIが理解しやすい

次のレシピでは、CursorとClaudeを使って実際にアプリを作ります。

➡️ **次のレシピへ:** [`05_building_app_with_cursor.md`](./05_building_app_with_cursor.md)
