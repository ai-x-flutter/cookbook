# レシピ#4-7: 実践 - Cursorで完全なTODOアプリを作る

## このレシピのゴール

Cursor + Claudeを使って、以下の機能を持つ完全なTODOアプリを作ります：

- ✅ TODO の追加・編集・削除
- ✅ 完了/未完了の切り替え
- ✅ カテゴリ分け
- ✅ 期限設定
- ✅ SQLiteでデータ永続化
- ✅ 検索・フィルタリング

**使わないもの:**
- ❌ Riverpod
- ❌ BLoC
- ❌ 複雑なアーキテクチャ

**使うもの:**
- ✅ StatefulWidget
- ✅ Serviceクラス
- ✅ SQLite（sqflite package）

## Step 1: プロジェクト作成とセットアップ

```bash
flutter create todo_app
cd todo_app
cursor .
```

**Cursorに依頼:**
```
pubspec.yamlに以下のパッケージを追加してください:
- sqflite: 最新版
- path: 最新版
- intl: 最新版
```

## Step 2: データモデル設計

**プロンプト:**
```
TODOアプリのデータモデルを設計してください。

必要な情報:
- ID (整数, 自動採番)
- タイトル
- 詳細（任意）
- カテゴリ（仕事、個人、買い物など）
- 期限（任意）
- 完了フラグ
- 作成日時
- 更新日時

以下を含めてください:
1. Todoクラス定義
2. SQLiteテーブル定義
3. fromMap/toMap メソッド

シンプルな構造でお願いします。
```

## Step 3: DatabaseService作成

**プロンプト:**
```
TodoDatabaseServiceクラスを作成してください。

機能:
- データベース初期化
- TODO追加
- TODO一覧取得（完了/未完了でフィルタ可能）
- TODO更新
- TODO削除
- カテゴリ一覧取得

構成:
- シングルトンパターン
- sqfliteを使用
- エラーハンドリング付き
- 先ほど定義したTodoクラスを使用

テーブル名: todos
```

## Step 4: メイン画面作成

**プロンプト:**
```
TODO一覧画面を作成してください。

UI構成:
- AppBar
  - タイトル「TODO」
  - 検索アイコン
  - メニュー（設定など）

- TabBar
  - 「すべて」
  - 「未完了」
  - 「完了」

- Body
  - TODO一覧（ListView）
  - 空の場合は「TODOがありません」と表示

- FloatingActionButton
  - 新規TODO作成

各TODOアイテム:
- Checkbox（完了/未完了切り替え）
- タイトル（完了の場合は取り消し線）
- カテゴリバッジ
- 期限表示（期限切れは赤色）
- スワイプで削除（確認ダイアログ）
- タップで編集画面へ

状態管理:
- StatefulWidget
- TodoDatabaseServiceを使用
```

## Step 5: TODO作成・編集画面

**プロンプト:**
```
TODO作成・編集画面を作成してください。

UI:
- AppBar
  - タイトル（新規 or 編集）
  - 保存ボタン

- Form
  - タイトル入力（必須）
  - 詳細入力（複数行）
  - カテゴリ選択（ドロップダウン）
  - 期限設定（DatePicker）
  - 完了フラグ（Switch）

機能:
- 新規作成と編集の両方に対応
- バリデーション（タイトル必須）
- 保存後は前の画面に戻る
- 編集時は既存データを表示

注意:
- TextEditingControllerを使用
- disposeで必ずController破棄
- Form Validationを実装
```

## Step 6: 検索機能追加

**プロンプト:**
```
検索機能を追加してください。

UI:
- AppBarの検索アイコンをタップ
- 検索モードに切り替わる
- TextField表示
- リアルタイムフィルタリング

機能:
- タイトルと詳細を検索
- 大文字小文字を区別しない
- 検索結果を即座に表示
- 検索クリアボタン

実装:
- StatefulWidgetで状態管理
- DatabaseServiceに検索メソッド追加
```

## Step 7: カテゴリフィルタ

**プロンプト:**
```
カテゴリフィルタ機能を追加してください。

UI:
- AppBarにフィルタアイコン
- タップでカテゴリ一覧ダイアログ
- 複数選択可能
- 「すべて」オプション

機能:
- 選択されたカテゴリのTODOのみ表示
- フィルタ状態を保持
- フィルタクリアボタン

実装:
- Set<String>でカテゴリ管理
- 状態を親Widgetで管理
```

## Step 8: 期限通知（オプション）

**プロンプト:**
```
期限が近いTODOを目立たせる機能を追加してください。

表示:
- 期限まで1日以内: オレンジ色
- 期限切れ: 赤色
- 期限なし: グレー

実装:
- TODOアイテムWidget内で判定
- DateTimeの比較
- 色付けとアイコン表示
```

## Step 9: 統計画面（オプション）

**プロンプト:**
```
簡単な統計画面を追加してください。

表示内容:
- 全TODO数
- 完了TODO数
- 未完了TODO数
- カテゴリ別TODO数

UI:
- Card形式で表示
- 簡単なグラフ（バーチャート）
  ※flutter_chartsなど軽量なパッケージ使用

ナビゲーション:
- BottomNavigationBarで切り替え
- または設定メニューから
```

## Step 10: テストとリファクタリング

**プロンプト:**
```
このアプリのコードをレビューしてください:

1. パフォーマンス問題はないか
2. メモリリークはないか
3. エラーハンドリングは適切か
4. ファイル構成は適切か

改善提案があれば、具体的に教えてください。
```

## 完成後のファイル構成

```
lib/
├── main.dart
├── models/
│   └── todo.dart
├── services/
│   └── database_service.dart
├── screens/
│   ├── todo_list_screen.dart
│   ├── todo_edit_screen.dart
│   └── statistics_screen.dart  (オプション)
└── widgets/
    ├── todo_item.dart
    └── category_filter_dialog.dart
```

## まとめ

このアプリで学んだこと：

1. **データベース操作**
   - SQLiteの基本
   - CRUD操作
   - クエリ最適化

2. **状態管理**
   - StatefulWidgetの活用
   - 親子Widget間のデータ受け渡し
   - 状態の更新と再描画

3. **UI/UX**
   - TabBar
   - BottomNavigationBar
   - DatePicker
   - スワイプアクション
   - 検索機能

4. **Cursorの活用**
   - 段階的な機能追加
   - コードレビュー
   - リファクタリング

**重要なポイント:**
- ✅ Riverpod不要で十分実用的
- ✅ Serviceクラスで責任分離
- ✅ 自己完結型Widget
- ✅ AIが理解しやすい構造

次のレシピでは、API連携アプリを作ります。

➡️ **次のレシピへ:** [`08_building_api_app.md`](./08_building_api_app.md)
