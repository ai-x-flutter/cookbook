# レシピ#3-3: Cursor + Claudeで実装するロジックと状態管理

美しいUI（ユーザーインターフェース）が完成したら、次はその裏側で動く「頭脳」、つまりアプリケーションのロジックと状態管理を実装します。

このレシピでは、前のレシピで作成した写真メモアプリに、**StatefulWidget**を使って状態管理の仕組みを導入し、実際にメモを管理できるようにするプロセスを、Cursor + Claudeと協力して進めます。

> **前提知識:**
> このレシピは、[状態管理の基本](../02_core_concepts/02_state_management_basics.md)の概念を理解していることを前提としています。

---

## Step 1: Cursorで状態管理の「設計図」を作る

いきなりコードを書き始めるのではなく、まず「どのような状態を、どうやって管理したいか」という設計をCursorに相談します。

> **💬 Cursor活用プロンプト (状態管理の設計)**
>
> 写真メモアプリの状態管理を実装したい。以下の要件を満たすコードを提案してください。
>
> **管理したい状態:**
> - メモのリスト (`List<Memo>`)
>
> **必要な機能（メソッド）:**
> - 新しいメモを追加する (`addMemo`)
> - 既存のメモを削除する (`removeMemo`)
>
> **実装方針:**
> - StatefulWidgetで状態管理
> - シンプルで理解しやすいコード
> - `models/memo.dart`は、すでにID, タイトル, 画像パスなどを持つクラスとして定義済み
>
> HomeScreenをStatefulWidgetとして実装し、メモリストを管理するコードを書いてください。

**Claudeの応答（例）:**
```dart
// screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/memo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // メモのリストを管理する状態
  List<Memo> _memos = [];

  // 新しいメモをリストに追加するメソッド
  void _addMemo(Memo newMemo) {
    setState(() {
      _memos.add(newMemo);
    });
  }

  // IDを指定してメモをリストから削除するメソッド
  void _removeMemo(String memoId) {
    setState(() {
      _memos.removeWhere((memo) => memo.id == memoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('写真メモ'),
      ),
      body: _memos.isEmpty
          ? const Center(
              child: Text('メモがありません'),
            )
          : ListView.builder(
              itemCount: _memos.length,
              itemBuilder: (context, index) {
                final memo = _memos[index];
                return Dismissible(
                  key: Key(memo.id),
                  onDismissed: (direction) {
                    _removeMemo(memo.id);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: MemoCard(memo: memo),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ダミーのメモを追加（後でカメラ機能と連携）
          final newMemo = Memo(
            id: DateTime.now().toString(),
            title: 'サンプルメモ',
            imagePath: '',
            createdAt: DateTime.now(),
          );
          _addMemo(newMemo);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**なぜこれが良いのか？**
*   **シンプルで理解しやすい:** StatefulWidgetの基本に忠実で、初心者でも理解できる
*   **外部ライブラリ不要:** Flutterの標準機能のみで実装
*   **保守しやすい:** 状態とUIが同じファイルにあり、流れが追いやすい

---

## Step 2: より複雑な状態が必要な場合 - Serviceクラスの活用

アプリが成長して、複数の画面でメモリストを共有したい場合は、Serviceクラスを使います。

> **💬 Cursor活用プロンプト (Serviceクラス)**
>
> メモリストを複数の画面で共有したいです。
> ChangeNotifierを使ったServiceクラスパターンで実装してください。
>
> **要件:**
> - lib/services/memo_service.dartを作成
> - シングルトンパターン
> - ChangeNotifierで状態変更を通知
> - メモの追加・削除・取得機能

**Claudeの応答（例）:**
```dart
// lib/services/memo_service.dart
import 'package:flutter/foundation.dart';
import '../models/memo.dart';

class MemoService extends ChangeNotifier {
  // シングルトンパターン
  static final MemoService instance = MemoService._internal();
  MemoService._internal();
  factory MemoService() => instance;

  // メモのリスト（プライベート）
  final List<Memo> _memos = [];

  // 外部からはread-onlyで公開
  List<Memo> get memos => List.unmodifiable(_memos);

  // メモを追加
  void addMemo(Memo memo) {
    _memos.add(memo);
    notifyListeners(); // リスナーに通知
  }

  // メモを削除
  void removeMemo(String memoId) {
    _memos.removeWhere((memo) => memo.id == memoId);
    notifyListeners();
  }

  // メモを更新
  void updateMemo(Memo updatedMemo) {
    final index = _memos.indexWhere((m) => m.id == updatedMemo.id);
    if (index != -1) {
      _memos[index] = updatedMemo;
      notifyListeners();
    }
  }
}
```

**HomeScreenでの使用例:**
```dart
class _HomeScreenState extends State<HomeScreen> {
  final _memoService = MemoService.instance;

  @override
  void initState() {
    super.initState();
    // 変更を監視
    _memoService.addListener(_onMemosChanged);
  }

  void _onMemosChanged() {
    if (mounted) {
      setState(() {}); // リビルド
    }
  }

  @override
  void dispose() {
    // リスナーを解除
    _memoService.removeListener(_onMemosChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memos = _memoService.memos;

    return Scaffold(
      // ... 以下同様
    );
  }
}
```

---

## Step 3: Cursorでセルフレビューをさせる

コードが完成したら、最後にCursorに「セルフレビュー」をさせてみましょう。

> **💬 Cursor活用プロンプト (セルフレビュー)**
>
> これまでの対話で完成したコードをレビューしてください。
>
> **確認ポイント:**
> - メモリークの可能性はないか？
> - IDの生成方法は適切か？
> - エラーハンドリングは十分か？
> - パフォーマンス上の問題はないか？
>
> 改善できる点があれば提案してください。

このステップにより、Claude自身が見落としていた点（例: IDが重複する可能性がある、disposeでのリスナー解除漏れなど）に気づき、より堅牢なコードへと改善するきっかけを得ることができます。

---

## まとめ: 状態管理のベストプラクティス

**シンプルなケース（単一画面）:**
- ✅ StatefulWidgetで十分
- ✅ 学習コストが低い
- ✅ デバッグしやすい

**複雑なケース（複数画面で共有）:**
- ✅ ChangeNotifier + Serviceクラス
- ✅ シングルトンパターン
- ✅ 外部ライブラリ不要

**❌ 避けるべき:**
- Riverpod（バージョンアップの負債が大きい）
- BLoC（複雑すぎる）
- 過度な抽象化

**Cursor + Claudeを使えば、どちらのパターンも数分で実装できます。**

これで、あなたのアプリはただの見た目だけでなく、実際にデータを操作できる「生きた」アプリケーションになりました。
