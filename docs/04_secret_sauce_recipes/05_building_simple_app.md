# レシピ#4-5: Cursor + Claudeでシンプルなアプリを作る

## はじめに

これまで学んだ内容を実践します。Cursor + Claudeを使って、シンプルだけど実用的なアプリを作りましょう。

## 今回作るアプリ: メモアプリ

**機能:**
- メモの追加
- メモ一覧表示
- メモの編集
- メモの削除
- データの永続化（SharedPreferences）

**技術スタック:**
- Flutter 3.27
- StatefulWidget（状態管理）
- SharedPreferences（データ保存）
- Serviceクラス（ビジネスロジック）

**避けるもの:**
- ❌ Riverpod
- ❌ BLoC
- ❌ 複雑なアーキテクチャ

## Step 1: プロジェクト作成

```bash
flutter create memo_app
cd memo_app
cursor .
```

## Step 2: データ構造を設計（Cursorに依頼）

**プロンプト:**
```
メモアプリのデータ構造を設計してください。

必要な情報:
- ID (UUID)
- タイトル
- 内容
- 作成日時
- 更新日時

以下を含めてください:
1. Memoクラスの定義
2. JSONシリアライゼーション（toJson/fromJson）
3. サンプルデータ

注意: freezedなどの複雑なパッケージは使わない
```

**Claudeの回答例:**
```dart
import 'package:uuid/uuid.dart';

class Memo {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Memo({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // JSONから変換
  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // コピーして更新
  Memo copyWith({
    String? title,
    String? content,
  }) {
    return Memo(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
```

## Step 3: Serviceクラス作成

**プロンプト:**
```
MemoServiceクラスを作成してください。

機能:
- メモ一覧の取得
- メモの追加
- メモの更新
- メモの削除
- SharedPreferencesで永続化

構成:
- シングルトンパターン
- エラーハンドリング付き
- 先ほど定義したMemoクラスを使用
```

**Claudeの回答例:**
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MemoService {
  static final MemoService instance = MemoService._internal();
  MemoService._internal();
  factory MemoService() => instance;

  static const String _key = 'memos';
  List<Memo> _memos = [];

  // 初期化
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List;
      _memos = jsonList.map((json) => Memo.fromJson(json)).toList();
    }
  }

  // メモ一覧取得
  List<Memo> getMemos() {
    return List.unmodifiable(_memos);
  }

  // メモ追加
  Future<void> addMemo(String title, String content) async {
    final memo = Memo(title: title, content: content);
    _memos.insert(0, memo);
    await _save();
  }

  // メモ更新
  Future<void> updateMemo(String id, String title, String content) async {
    final index = _memos.indexWhere((m) => m.id == id);
    if (index != -1) {
      _memos[index] = _memos[index].copyWith(
        title: title,
        content: content,
      );
      await _save();
    }
  }

  // メモ削除
  Future<void> deleteMemo(String id) async {
    _memos.removeWhere((m) => m.id == id);
    await _save();
  }

  // 保存
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _memos.map((m) => m.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }
}
```

## Step 4: メイン画面作成

**プロンプト:**
```
メモ一覧画面を作成してください。

UI:
- AppBar: タイトル「メモ」と追加ボタン
- Body: メモ一覧（ListViewで表示）
- FloatingActionButton: 新規メモ作成

各メモアイテム:
- タイトルを太字で表示
- 内容を1行で表示（省略記号付き）
- 更新日時を小さく表示
- タップで編集画面へ
- スワイプで削除（確認ダイアログ表示）

状態管理:
- StatefulWidget
- MemoServiceを使用
```

## Step 5: 編集画面作成

**プロンプト:**
```
メモ編集画面を作成してください。

UI:
- AppBar: タイトル「メモ編集」と保存ボタン
- タイトル入力フィールド
- 内容入力フィールド（複数行）

機能:
- 新規作成と編集の両方に対応
- 保存ボタンでMemoServiceを使って保存
- 保存後は前の画面に戻る

注意:
- TextEditingControllerを使用
- disposeで必ずController破棄
```

## Step 6: 動作確認とリファクタリング

**プロンプト:**
```
このコードをレビューしてください:

1. エラーがないか
2. リソースリークはないか
3. より良い書き方があれば提案
4. Flutter 3.27のベストプラクティスに従っているか

簡潔に指摘してください。
```

## 完成イメージ

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MemoService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'メモアプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MemoListScreen(),
    );
  }
}
```

## まとめ

このアプリの特徴：

**シンプルさ:**
- ✅ Riverpod不使用
- ✅ 外部パッケージ最小限
- ✅ 理解しやすい構造

**実用性:**
- ✅ データ永続化
- ✅ CRUD操作完備
- ✅ エラーハンドリング

**保守性:**
- ✅ Serviceクラスで分離
- ✅ 自己完結型Widget
- ✅ AIが理解しやすい

**学んだパターン:**
1. Serviceクラスパターン
2. StatefulWidgetでの状態管理
3. SharedPreferencesでの永続化
4. ナビゲーション
5. リソース管理

次のレシピでは、Google Antigravityについて（注意点付きで）解説します。

➡️ **次のレシピへ:** [`06_antigravity_with_cautions.md`](./06_antigravity_with_cautions.md)
