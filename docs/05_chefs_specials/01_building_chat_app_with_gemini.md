# ケーススタディ#5-1: AIチャットアプリを作る - Claude API / Gemini API連携

## このケーススタディで作るもの

**Cursor + Claude**を使って、Claude APIまたはGemini APIと連携する本格的なAIチャットアプリを作ります。

**機能:**
- ✅ AIとのリアルタイム対話
- ✅ ストリーミングレスポンス（文字が順次表示される）
- ✅ チャット履歴の表示
- ✅ メッセージの送信・受信
- ✅ ローディング状態の管理

**技術スタック:**
- Flutter 3.27+
- StatefulWidget（状態管理）
- Serviceクラス（API通信）
- Claude API または Gemini API
- http パッケージ

**避けるもの:**
- ❌ Riverpod
- ❌ BLoC
- ❌ 複雑な状態管理ライブラリ

## 完成イメージ

```
┌─────────────────────────┐
│  AI Chat App            │
├─────────────────────────┤
│                         │
│  👤 こんにちは         │
│                         │
│         🤖 こんにちは！│
│         どうされました│
│         か？           │
│                         │
│  👤 Flutterについて    │
│     教えて            │
│                         │
│         🤖 Flutterは... │
│         [ストリーミング]│
│                         │
├─────────────────────────┤
│ [メッセージ入力欄] [送信]│
└─────────────────────────┘
```

## Step 1: API選択とセットアップ

### Option A: Claude API（推奨）

**特徴:**
- 最も安定したコード生成・対話
- 長文の理解に強い
- 日本語の品質が高い

**セットアップ:**
1. [Anthropic Console](https://console.anthropic.com/)でアカウント作成
2. API Keyを取得
3. 無料枠: $5 相当

### Option B: Gemini API

**特徴:**
- Googleの最新AIモデル
- 無料枠が大きい
- 画像認識も可能

**セットアップ:**
1. [Google AI Studio](https://aistudio.google.com/)でAPI Key取得
2. 無料枠: 月60リクエスト/分

## Step 2: プロジェクト作成

```bash
flutter create ai_chat_app
cd ai_chat_app
cursor .
```

### 依存関係を追加

**Cursorで以下をリクエスト:**

```
pubspec.yamlに以下の依存関係を追加してください：
- http: ^1.2.0
- flutter_dotenv: ^5.1.0（APIキー管理用）
```

**.envファイルの作成:**

```
プロジェクトルートに.envファイルを作成して、以下を追加してください：

# Claude APIの場合
ANTHROPIC_API_KEY=your_api_key_here

# または Gemini APIの場合
GEMINI_API_KEY=your_api_key_here
```

**重要:** `.gitignore`に`.env`を追加（APIキーをGitにコミットしない）

## Step 3: データモデルの設計

**Cursorで以下をリクエスト:**

```
lib/models/message.dartを作成して、以下の仕様でMessageクラスを作ってください：

クラス名: Message
フィールド:
- id: String（メッセージのユニークID）
- text: String（メッセージ本文）
- isUser: bool（ユーザーのメッセージかAIのメッセージか）
- timestamp: DateTime（送信時刻）

メソッド:
- toJson() / fromJson()（JSONシリアライズ）
- copyWith()（不変オブジェクト更新用）
```

## Step 4: API Serviceクラスの実装

### Claude APIの場合

**Cursorで以下をリクエスト:**

```
lib/services/claude_service.dartを作成してください。

仕様:
- シングルトンパターン
- Claude APIのMessages APIを使用
- ストリーミングレスポンス対応
- エラーハンドリング

メソッド:
Future<Stream<String>> sendMessage(String message, List<Message> history)
  - 引数: ユーザーメッセージとチャット履歴
  - 戻り値: ストリーミングレスポンス（Stream<String>）
  - APIエンドポイント: https://api.anthropic.com/v1/messages
  - モデル: claude-opus-4-20250514（または最新のOpus 4.5モデルID）
  - ヘッダー:
    - x-api-key: APIキー
    - anthropic-version: 2023-06-01
    - content-type: application/json
```

### Gemini APIの場合

**Cursorで以下をリクエスト:**

```
lib/services/gemini_service.dartを作成してください。

仕様:
- シングルトンパターン
- Gemini APIのgenerateContent APIを使用
- ストリーミングレスポンス対応

メソッド:
Future<Stream<String>> sendMessage(String message, List<Message> history)
  - エンドポイント: https://generativelanguage.googleapis.com/v1/models/gemini-pro:streamGenerateContent
  - パラメータにAPI Key
```

## Step 5: チャット画面UIの実装

**Cursorで以下をリクエスト:**

```
lib/screens/chat_screen.dartを作成してください。

仕様:
- StatefulWidgetを使用
- Scaffoldベース
- AppBarにタイトル「AI Chat」
- メッセージリスト（ListView.builder）
  - ユーザーメッセージは右寄せ（青色背景）
  - AIメッセージは左寄せ（グレー背景）
  - 時刻表示
- 下部にメッセージ入力欄とボタン
- 送信ボタンを押すとAPIにリクエスト
- ストリーミングレスポンスを1文字ずつ表示
- スクロールは自動で最下部へ

状態:
- List<Message> _messages（メッセージ履歴）
- TextEditingController _controller（入力欄）
- bool _isLoading（送信中フラグ）
- String _streamingText（ストリーミング中のテキスト）
```

## Step 6: ストリーミング表示の実装

**重要なポイント:**

```dart
// ストリーミングレスポンスの処理例
Future<void> _sendMessage() async {
  if (_controller.text.isEmpty) return;

  final userMessage = Message(
    id: DateTime.now().toString(),
    text: _controller.text,
    isUser: true,
    timestamp: DateTime.now(),
  );

  setState(() {
    _messages.add(userMessage);
    _isLoading = true;
    _streamingText = '';
  });

  _controller.clear();

  try {
    final stream = await ClaudeService.instance.sendMessage(
      userMessage.text,
      _messages,
    );

    await for (final chunk in stream) {
      if (mounted) {
        setState(() {
          _streamingText += chunk;
        });
      }
    }

    // ストリーミング完了後、メッセージに追加
    final aiMessage = Message(
      id: DateTime.now().toString(),
      text: _streamingText,
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(aiMessage);
      _streamingText = '';
      _isLoading = false;
    });
  } catch (e) {
    // エラーハンドリング
    setState(() {
      _isLoading = false;
    });
  }
}
```

## Step 7: 実行とテスト

```bash
# .envファイルにAPIキーが設定されているか確認
flutter run
```

**テストシナリオ:**
1. メッセージを送信
2. ストリーミングレスポンスが表示されるか確認
3. チャット履歴が正しく表示されるか確認
4. スクロールが自動で最下部になるか確認
5. エラーハンドリングが機能するか確認

## Step 8: 機能拡張

**Cursorで以下を追加リクエスト:**

### 拡張1: チャット履歴の永続化

```
SharedPreferencesを使って、チャット履歴をローカルに保存してください。
アプリを再起動しても履歴が残るようにしてください。
```

### 拡張2: チャット履歴のクリア

```
AppBarにクリアボタンを追加して、チャット履歴を全削除できるようにしてください。
確認ダイアログも表示してください。
```

### 拡張3: システムプロンプトのカスタマイズ

```
設定画面を追加して、AIのキャラクター（システムプロンプト）を
カスタマイズできるようにしてください。

例:
- フレンドリーなアシスタント
- 厳格な教師
- カジュアルな友達
```

### 拡張4: コードブロックのシンタックスハイライト

```
flutter_markdown パッケージを使って、AIの返答内のコードブロックを
シンタックスハイライト表示してください。
```

## よくある問題と解決策

### 問題1: ストリーミングが機能しない

**原因:** APIのストリーミングエンドポイントが正しくない

**解決策:**
- Claude: `stream: true`パラメータを確認
- Gemini: `:streamGenerateContent`エンドポイントを使用

### 問題2: APIキーエラー

**原因:** `.env`ファイルが読み込まれていない

**解決策:**
```dart
// main.dartで確実に読み込む
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
```

### 問題3: 日本語が文字化けする

**原因:** UTF-8エンコーディングの問題

**解決策:**
```dart
// httpリクエストのヘッダーに追加
headers: {
  'Content-Type': 'application/json; charset=utf-8',
}
```

## まとめ

このケーススタディで学んだこと：

✅ **API連携の基本:** REST APIの呼び出しとエラーハンドリング
✅ **ストリーミング処理:** Stream<String>を使ったリアルタイム表示
✅ **状態管理:** StatefulWidgetでの複雑な状態管理
✅ **セキュリティ:** APIキーの安全な管理
✅ **UX設計:** チャットUIのベストプラクティス

**次のステップ:**
- 画像送信機能の追加（Gemini Vision）
- 音声入力/出力機能
- マルチモーダル対話

---

**完成版コードは、[examples/ai_chat_app](../../examples/ai_chat_app/)を参照してください。**
