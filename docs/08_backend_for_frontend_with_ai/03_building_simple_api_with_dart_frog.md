# レシピ#8-3: AIと作るシンプルなREST API (Dart Frog編)

前のレシピで、Dartのバックエンドフレームワークを選びました。このレシピでは、シンプルで軽量な**Dart Frog**を使って、あなたの最初のAPIサーバーを立ち上げる方法を、AIと協力しながら学びます。

ここでのゴールは、**数分でAPIサーバーを起動し、ブラウザやツールからアクセスできるエンドポイントを作成する**ことです。

---

## Step 1: Dart Frogのインストールとプロジェクト作成

まず、Dart FrogをあなたのPCにインストールし、新しいプロジェクトを作成します。この手順も、AIに尋ねることから始めましょう。

> **🤖 AI活用プロンプト (インストールとプロジェクト作成)**
>
> あなたはDart Frogの公式ドキュメントをすべて記憶しているエキスパートです。
>
> Dart Frogを初めて使う開発者向けに、以下の手順を簡潔に説明してください。
>
> 1.  Dart FrogのCLIツールを、`dart pub global activate`を使ってインストールするコマンド。
> 2.  `dart_frog create`を使って、`my_api_server`という名前の新しいプロジェクトを作成するコマンド。
> 3.  作成したプロジェクトのディレクトリに移動し、開発サーバーを起動するコマンド。
> 4.  サーバーが起動した後、ブラウザでアクセスして動作確認するためのURL。

**AIの応答（期待されるもの）:**
> 承知いたしました。Dart Frogのセットアップは非常に簡単です。
>
> 1.  **CLIのインストール:**
>     ```bash
>     dart pub global activate dart_frog_cli
>     ```
> 2.  **プロジェクトの作成:**
>     ```bash
>     dart_frog create my_api_server
>     ```
> 3.  **サーバーの起動:**
>     ```bash
>     cd my_api_server
>     dart_frog dev
>     ```
> 4.  **動作確認:**
>     サーバーが起動したら、Webブラウザで `http://localhost:8080` を開いてください。「Welcome to Dart Frog!」と表示されれば成功です。

---

## Step 2: 最初のルート（エンドポイント）を作成する

Dart Frogの最大の特徴は、**ファイルベースのルーティング**です。`routes/`ディレクトリにファイルを作成するだけで、それがAPIのエンドポイントになります。

`routes/`ディレクトリの下に、`hello.dart`という名前のファイルを作成してみましょう。

**`routes/hello.dart`**
```dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(body: 'Hello from the server!');
}
```
ファイルを保存すると、`dart_frog dev`コマンドが自動で変更を検知し、サーバーをリロードします。
今度はブラウザで `http://localhost:8080/hello` にアクセスしてみてください。「Hello from the server!」と表示されるはずです。

## Step 3: JSONを返すAPIをAIに作らせる

実際のAPIでは、プレーンテキストではなく、JSON形式でデータを返すのが一般的です。AIに、JSONを返すエンドポイントのコードを生成してもらいましょう。

> **🤖 AI活用プロ-ンプト (JSON API作成)**
>
> Dart Frogを使って、`routes/api/greetings.dart` というエンドポイントを作成したい。
>
> このエンドポイントは、アクセスされた際に、以下の構造を持つ**JSON**を返すようにしたい。
>
> ```json
> {
>   "message": "Welcome to our API!",
>   "timestamp": "（現在のISO 8601形式のタイムスタンプ）"
> }
> ```
>
> この要件を満たす、`greetings.dart`の完全なDartコードを生成してください。`Response.json()`を使ってください。

**AIの応答（例）:**
```dart
// routes/api/greetings.dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final responseData = {
    'message': 'Welcome to our API!',
    'timestamp': DateTime.now().toIso8601String(),
  };
  
  // DartのMapを自動的にJSON文字列に変換してレスポンスを返す
  return Response.json(body: responseData);
}
```
このファイルを保存し、`http://localhost:8080/api/greetings`にアクセスすれば、正しくフォーマットされたJSONが表示されます。

---

## Step 4: 動的なルートを作成する

APIでは、`users/123`のように、URLの一部が可変（動的）になっていることがよくあります。Dart Frogでは、ファイル名を`[id].dart`のように角括弧で囲むことで、これを簡単に実現できます。

> **🤖 AI活用プロンプト (動的ルート作成)**
>
> Dart Frogで、`routes/users/[id].dart` という動的なルートを作成したい。
>
> このエンドポイントは、URLから`id`の部分を文字列として受け取り、
> 「User ID is: (受け取ったID)」というJSONを返すようにしたい。
>
> **例:** `/users/abc` にアクセスされたら、`{"message": "User ID is: abc"}` を返す。
>
> この`[id].dart`の完全なコードを生成してください。

**AIの応答（例）:**
```dart
// routes/users/[id].dart
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String id) {
  // 第2引数として、URLの動的な部分を受け取ることができる
  return Response.json(
    body: {
      'message': 'User ID is: $id',
    },
  );
}
```

おめでとうございます！あなたは、Dart FrogとAIの助けを借りて、静的なルート、JSONを返すルート、そして動的なルートを持つ、本格的なAPIサーバーの基礎をわずかな時間で構築しました。

**次のレシピでは、このAPIとFlutterアプリを連携させ、両者でコードを共有する方法を見ていきましょう。**