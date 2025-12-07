# ケーススタディ#5-3: リアルタイム共有メモアプリを作る - Supabase Realtime

## このケーススタディで作るもの

**Cursor + Claude**を使って、複数のデバイス間でリアルタイムに同期するメモアプリを作ります。

**機能:**
- ✅ メモの作成・編集・削除
- ✅ **複数デバイス間でリアルタイム同期**
- ✅ 他のユーザーの編集が即座に反映
- ✅ オフライン対応（ローカルキャッシュ）
- ✅ ユーザー認証

**技術スタック:**
- Flutter 3.27+
- Supabase（BaaS - Backend as a Service）
  - Realtime機能（WebSocket）
  - PostgreSQLデータベース
  - 認証機能
- StatefulWidget（状態管理）
- Serviceクラス（API通信）

**避けるもの:**
- ❌ Riverpod
- ❌ BLoC
- ❌ 自前のバックエンドサーバー構築

## 完成イメージ

```
デバイス1               デバイス2
┌──────────────┐      ┌──────────────┐
│ 📝 メモ一覧  │ ←WebSocket→ │ 📝 メモ一覧  │
├──────────────┤      ├──────────────┤
│ • 買い物リスト│ ⚡即座に同期⚡ │ • 買い物リスト│
│ • 会議メモ   │ ←────────→ │ • 会議メモ   │
│ • アイデア   │      │ • アイデア   │
└──────────────┘      └──────────────┘
     ↓編集                   ↓即座に反映
```

**リアルタイム同期の動作:**
1. デバイス1でメモを編集
2. Supabaseに保存
3. WebSocketで全デバイスに通知
4. デバイス2が自動更新

## なぜSupabase？

**Supabaseの利点:**
- ✅ 無料枠が大きい（500MB DB, 50MBストレージ）
- ✅ リアルタイム機能が標準搭載
- ✅ PostgreSQL（本格的なRDB）
- ✅ 認証機能も標準搭載
- ✅ セットアップが簡単
- ✅ バックエンドコード不要

**Firebaseとの違い:**
- Supabase: PostgreSQL（SQL）
- Firebase: NoSQL
- Supabase: オープンソース
- Firebase: Google独自

## Step 1: Supabaseプロジェクトのセットアップ

### 1-1. Supabaseアカウント作成

1. [Supabase](https://supabase.com/)にアクセス
2. GitHubアカウントでサインアップ
3. 新しいプロジェクトを作成
   - Project name: `realtime-memo-app`
   - Database password: 安全なパスワードを設定
   - Region: `Northeast Asia (Tokyo)`（日本の場合）

### 1-2. データベーステーブル作成

**Supabase Dashboard > SQL Editor で以下を実行:**

```sql
-- メモテーブル
create table memos (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  title text not null,
  content text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- リアルタイム機能を有効化
alter publication supabase_realtime add table memos;

-- 行レベルセキュリティ（RLS）を有効化
alter table memos enable row level security;

-- ポリシー: 自分のメモのみ閲覧可能
create policy "Users can view their own memos"
  on memos for select
  using (auth.uid() = user_id);

-- ポリシー: 自分のメモのみ作成可能
create policy "Users can create their own memos"
  on memos for insert
  with check (auth.uid() = user_id);

-- ポリシー: 自分のメモのみ更新可能
create policy "Users can update their own memos"
  on memos for update
  using (auth.uid() = user_id);

-- ポリシー: 自分のメモのみ削除可能
create policy "Users can delete their own memos"
  on memos for delete
  using (auth.uid() = user_id);
```

### 1-3. API情報の取得

**Supabase Dashboard > Settings > API:**

- **Project URL:** `https://xxxxx.supabase.co`
- **anon public key:** `eyJhbGciOi...`（長い文字列）

これらをメモしておきます。

## Step 2: Flutterプロジェクト作成

```bash
flutter create realtime_memo_app
cd realtime_memo_app
cursor .
```

### 依存関係を追加

**Cursorで以下をリクエスト:**

```
pubspec.yamlに以下の依存関係を追加してください：

- supabase_flutter: ^2.0.0（Supabase SDK）
- flutter_dotenv: ^5.1.0（環境変数管理）
```

### .envファイルの作成

**Cursorで以下をリクエスト:**

```
プロジェクトルートに.envファイルを作成してください：

SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...

※ .gitignoreに.envを追加してください
```

## Step 3: Supabaseの初期化

**Cursorで以下をリクエスト:**

```
lib/main.dartを修正して、Supabaseを初期化してください：

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(MyApp());
}

// グローバルアクセス用
final supabase = Supabase.instance.client;
```

## Step 4: データモデルの設計

**Cursorで以下をリクエスト:**

```
lib/models/memo.dartを作成してください：

クラス名: Memo
フィールド:
- id: String
- userId: String
- title: String
- content: String
- createdAt: DateTime
- updatedAt: DateTime

メソッド:
- factory Memo.fromJson(Map<String, dynamic> json)
- Map<String, dynamic> toJson()
- copyWith()
```

## Step 5: Supabase Serviceクラスの実装

**Cursorで以下をリクエスト:**

```
lib/services/supabase_service.dartを作成してください。

仕様:
- シングルトンパターン
- Supabaseのメモテーブルとの連携
- リアルタイム購読機能

メソッド:

1. Future<List<Memo>> fetchMemos()
   - 自分のメモ一覧を取得

2. Future<void> createMemo(String title, String content)
   - 新しいメモを作成

3. Future<void> updateMemo(String id, String title, String content)
   - メモを更新

4. Future<void> deleteMemo(String id)
   - メモを削除

5. Stream<List<Memo>> subscribeToMemos()
   - リアルタイム更新を購読
   - PostgreSQL Changesを監視
   - INSERT/UPDATE/DELETEイベントを受信

6. void unsubscribe()
   - リアルタイム購読を解除
```

## Step 6: 認証画面の実装

**Cursorで以下をリクエスト:**

```
lib/screens/auth_screen.dartを作成してください。

仕様:
- メールアドレスとパスワードでサインアップ/ログイン
- Supabase Authを使用
- StatefulWidget

UI:
- メールアドレス入力欄
- パスワード入力欄
- サインアップボタン
- ログインボタン
- エラーメッセージ表示

処理:
- サインアップ: supabase.auth.signUp()
- ログイン: supabase.auth.signInWithPassword()
- 成功したらメモ一覧画面に遷移
```

## Step 7: メモ一覧画面の実装（リアルタイム対応）

**Cursorで以下をリクエスト:**

```
lib/screens/memo_list_screen.dartを作成してください。

仕様:
- StatefulWidgetを使用
- リアルタイム更新に対応

状態:
- List<Memo> _memos
- bool _isLoading
- StreamSubscription? _subscription

ライフサイクル:
- initState():
  - メモ一覧を取得
  - リアルタイム購読を開始
- dispose():
  - リアルタイム購読を解除

UI:
- AppBar:
  - タイトル「メモ一覧」
  - ログアウトボタン
- ListView.builder:
  - メモをカード形式で表示
  - タップで編集画面へ
  - スワイプで削除
- FloatingActionButton:
  - 新規メモ作成

リアルタイム処理:
_subscription = SupabaseService.instance.subscribeToMemos().listen((memos) {
  if (mounted) {
    setState(() {
      _memos = memos;
    });
  }
});
```

## Step 8: メモ編集画面の実装

**Cursorで以下をリクエスト:**

```
lib/screens/memo_edit_screen.dartを作成してください。

仕様:
- StatefulWidgetを使用
- 新規作成と編集の両方に対応

引数:
- Memo? memo（nullの場合は新規作成）

UI:
- タイトル入力欄（TextField）
- 内容入力欄（TextField、複数行）
- 保存ボタン
- キャンセルボタン

処理:
- 保存時:
  - 新規の場合: SupabaseService.createMemo()
  - 編集の場合: SupabaseService.updateMemo()
  - 保存後、一覧画面に戻る
```

## Step 9: リアルタイム同期の核心部分

```dart
// lib/services/supabase_service.dart の例

Stream<List<Memo>> subscribeToMemos() {
  return supabase
      .from('memos')
      .stream(primaryKey: ['id'])
      .eq('user_id', supabase.auth.currentUser!.id)
      .map((data) => data.map((json) => Memo.fromJson(json)).toList());
}
```

**仕組み:**
1. `.stream()`: PostgreSQL Changesを監視
2. `.eq()`: 自分のメモのみフィルタ
3. `.map()`: JSONをMemoオブジェクトに変換
4. 変更があると自動でStreamに流れる

## Step 10: 実行とテスト

```bash
flutter run
```

**テストシナリオ:**

1. **認証テスト:**
   - 新規ユーザー登録
   - ログイン

2. **CRUD操作:**
   - メモを作成
   - メモを編集
   - メモを削除

3. **リアルタイム同期テスト（重要）:**
   - 2台のデバイスで同じアカウントにログイン
   - デバイス1でメモを作成
   - デバイス2で即座に反映されるか確認
   - デバイス2でメモを編集
   - デバイス1で即座に反映されるか確認

## Step 11: 機能拡張

### 拡張1: オフライン対応

**Cursorで以下をリクエスト:**

```
sqfliteを使って、メモをローカルにキャッシュしてください。
オフライン時はローカルデータを表示し、
オンライン復帰時にSupabaseと同期してください。
```

### 拡張2: 共同編集機能

**Cursorで以下をリクエスト:**

```
メモを他のユーザーと共有できる機能を追加してください。
共有されたメモは、全員がリアルタイムで編集できるようにしてください。

新しいテーブル:
- shared_memos (memo_id, user_id)
```

### 拡張3: 編集中の表示

**Cursorで以下をリクエスト:**

```
現在誰かが編集中のメモに「編集中」バッジを表示してください。
Supabase Presenceを使って実装してください。
```

### 拡張4: タグ・カテゴリ機能

**Cursorで以下をリクエスト:**

```
メモにタグを付けられるようにしてください。
タグでフィルタリングできる機能も追加してください。
```

## よくある問題と解決策

### 問題1: リアルタイム更新が動作しない

**原因:** Realtimeが有効化されていない

**解決策:**
```sql
-- Supabase Dashboard > SQL Editorで実行
alter publication supabase_realtime add table memos;
```

### 問題2: RLSエラー（permission denied）

**原因:** Row Level Security ポリシーが正しく設定されていない

**解決策:**
- Supabase Dashboard > Table Editor > memos
- RLSポリシーを確認
- auth.uid()が正しく使われているか確認

### 問題3: Stream が複数回呼ばれる

**原因:** Streamの購読を解除していない

**解決策:**
```dart
@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

### 問題4: 認証状態の管理

**原因:** ログアウト後もセッションが残っている

**解決策:**
```dart
// main.dartでAuthStateの監視
supabase.auth.onAuthStateChange.listen((data) {
  final session = data.session;
  if (session == null) {
    // ログイン画面へ遷移
  }
});
```

## まとめ

このケーススタディで学んだこと：

✅ **BaaS活用:** Supabaseを使ったバックエンド不要の開発
✅ **リアルタイム通信:** WebSocketを使った双方向通信
✅ **認証:** Supabase Authでのユーザー管理
✅ **データベース:** PostgreSQLとRow Level Security
✅ **Stream処理:** Dart Streamを使った非同期データ処理

**次のステップ:**
- より複雑な共同編集機能
- ファイル添付機能（Supabase Storage）
- プッシュ通知
- オフライン完全対応

---

**完成版コードは、[examples/realtime_memo_app](../../examples/realtime_memo_app/)を参照してください。**
