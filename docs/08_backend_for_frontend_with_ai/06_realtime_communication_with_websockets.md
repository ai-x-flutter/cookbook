# レシピ#8-6: AIと実装するリアルタイム通信 (WebSocket編)

これまでのAPIは、すべてクライアント（アプリ）からのリクエストに応じてサーバーが応答を返す「リクエスト/レスポンス」モデルでした。しかし、チャットアプリのように、サーバー側からクライアントに「新しいメッセージが来たよ！」と**プッシュ通知**したい場合はどうすれば良いでしょうか？

そのための技術が**WebSocket**です。WebSocketは、クライアントとサーバーの間に「双方向のトンネル」を開き、どちらからでも、いつでもリアルタイムにメッセージを送り合うことを可能にします。

このレシピでは、**Dart Frog**を使ってシンプルなWebSocketチャットサーバーを構築し、AIと協力してその仕組みを理解していきます。

---

## Step 1: WebSocketエンドポイントの作成

Dart Frogでは、WebSocketのエンドポイントを作成するのも非常に簡単です。`routes/`ディレクトリに、`onUpgrade`という特別な関数をエクスポートするファイルを作成するだけです。

> **🤖 AI活用プロンプト (WebSocketサーバー雛形)**
>
> あなたはDart Frogのリアルタイム通信機能に詳しいエキスパートです。
>
> Dart Frogで、`routes/ws.dart`というパスにWebSocketエンドポイントを作成したい。
>
> **要件:**
> 1.  クライアントが接続してきたら、「`[<接続ID>] connected!`」とサーバーのコンソールに表示する。
> 2.  クライアントからメッセージを受け取ったら、そのメッセージをそのまま「`ECHO: <受け取ったメッセージ>`」として、送ってきたクライアントにだけ送り返す（エコーサーバー）。
> 3.  クライアントが切断したら、「`[<接続ID>] disconnected!`」とサーバーのコンソールに表示する。
>
> この要件を満たす、`ws.dart`の完全なコードを生成してください。
> `WebSocketChannel`と`stream.listen`を使ってください。

**AIの応答（例）:**
```dart
// routes/ws.dart
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

Future<Response> onRequest(RequestContext context) async {
  // WebSocketハンドラを定義
  final handler = webSocketHandler(
    (channel, protocol) {
      // 接続IDを生成（デバッグ用）
      final connectionId = channel.hashCode;
      print('[$connectionId] connected!');

      // クライアントからのメッセージを待ち受ける
      channel.stream.listen(
        (message) {
          print('[-connectionId] received: $message');
          // 受け取ったメッセージをエコーバックする
          channel.sink.add('ECHO: $message');
        },
        // クライアントが切断した時の処理
        onDone: () => print('[connectionId] disconnected!'),
      );
    },
  );

  // リクエストをWebSocketハンドラにアップグレード
  return handler(context);
}
```
このファイルを保存し、Dart Frogサーバーを起動すれば、`ws://localhost:8080/ws`で接続を待ち受ける、シンプルなエコーサーバーが完成します。

---

## Step 2: グローバルなチャットルームの実装

エコーサーバーは基本を学ぶのに最適ですが、実際のチャットアプリでは、**あるクライアントからのメッセージを、接続している他のすべてのクライアントにブロードキャスト（一斉配信）する**必要があります。

これには、接続されているすべての`WebSocketChannel`を管理するための、グローバルな「マネージャー」クラスが必要になります。この設計もAIに任せましょう。

> **🤖 AI活用プロンプト (チャットルームマネージャー)**
>
> Dart Frogで、複数のクライアントが参加できるチャットルームを実装したい。
>
> 接続されているすべての`WebSocketChannel`を管理し、メッセージをブロードキャストするための`ChatRoomManager`クラスを設計・実装してください。
>
> **要件:**
> 1.  シングルトンパターンで実装し、アプリ全体で唯一のインスタンスを保持する。
> 2.  `add(WebSocketChannel channel)`メソッド: 新しいクライアントを管理リストに追加する。
> 3.  `remove(WebSocketChannel channel)`メソッド: 切断したクライアントをリストから削除する。
> 4.  `broadcast(String message)`メソッド: 管理しているすべてのクライアントに、同じメッセージを一斉配信する。

このプロンプトにより、接続管理の核心となるロジックが生成されます。
次に、このマネージャーをDart Frogのミドルウェアとして提供し、ルートハンドラから使えるようにします。

> **🤖 AI活用プロンプト (ミドルウェアとルートの実装)**
>
> 先ほど作成した`ChatRoomManager`を、Dart Frogの**ミドルウェア**として提供するコードを書いてください。
>
> そして、`routes/ws.dart`のハンドラを修正し、
> - 新しいクライアントが接続したら、マネージャーに追加する。
> - クライアントからメッセージを受け取ったら、マネージャーの`broadcast`メソッドを呼び出す。
> - クライアントが切断したら、マネージャーから削除する。
>
> というロジックを実装してください。

---

## Step 3: Flutterクライアントからの接続

サーバーの準備ができたので、Flutterアプリ側からWebSocketに接続します。公式の`web_socket_channel`パッケージを使うのが簡単です。

> **🤖 AI活用プロンプト (Flutter WebSocketクライアント)**
>
> `web_socket_channel`パッケージを使って、`ws://localhost:8080/ws`に接続するFlutterのUIを実装してください。
>
> **要件:**
> 1.  `WebSocketChannel`を初期化し、接続する。
> 2.  サーバーからのメッセージを待ち受ける`StreamBuilder`を使い、受信したメッセージを画面にリスト表示する。
> 3.  `TextField`と送信ボタンを配置し、ボタンが押されたら`channel.sink.add()`でサーバーにメッセージを送信する。
> 4.  ウィジェットが破棄される時に、`channel.sink.close()`で接続を適切に閉じる。
>
> この機能を持つ`StatefulWidget`の完全なコードを提示してください。

---

このレシピを通じて、あなたはリクエスト/レスポンスモデルを超えた、リアルタイム双方向通信の基本をマスターしました。チャットアプリ、オンラインゲーム、共同編集ツールなど、インタラクティブなアプリケーションを構築するための扉が開かれたのです。