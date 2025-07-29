# レシピ#8-5: AIと創るフルスタック認証 (Serverpod編)

Dart FrogでBFFの基本を学んだ今、私たちはより強力で、統合されたフルスタタック開発の世界へと足を踏み入れます。その案内役が**Serverpod**です。

Serverpodは単なるバックエンドフレームワークではありません。データベース、認証、そして**クライアントとサーバーのコード自動生成**までをも内包した、「サーバー界のFlutter」とも呼べる統合プラットフォームです。

このレシピでは、Serverpodの最も強力な機能であるコード自動生成を活用し、**AIと協力して、本格的なメール/パスワード認証機能**をゼロから実装します。

---

## Step 1: Serverpodのインストールとプロジェクト作成

Serverpodのセットアップは、Dart Frogよりも多くの要素（Dockerなど）を含みますが、AIに手順をガイドしてもらえば何も恐れることはありません。

> **🤖 AI活用プロンプト (Serverpodセットアップ)**
>
> あなたはServerpodの公式ドキュメントをすべて記憶しているエキスパートです。
>
> Serverpodを初めて使う開発者向けに、以下の手順を簡潔に説明してください。
>
> 1.  **前提条件:** `Docker Desktop`がインストール・起動している必要があること。
> 2.  ServerpodのCLIツールをインストールするコマンド。
> 3.  `serverpod create`を使って、`my_fullstack_app`という名前の新しいプロジェクトを作成するコマンド。この時、Flutterクライアントも同時に生成されること。
> 4.  生成されたサーバープロジェクト (`my_fullstack_app_server`) のディレクトリに移動し、`docker-compose up --build --detach`コマンドでデータベース（PostgreSQL）とRedisを起動する方法。
> 5.  サーバーとクライアントの両方を同時に起動し、開発を始めるためのコマンド。

AIのガイドに従ってセットアップを行うと、あなたの手元には3つのディレクトリが生成されます。
*   `my_fullstack_app_server/`: Serverpodサーバー本体
*   `my_fullstack_app_flutter/`: Flutterクライアントアプリ
*   `my_fullstack_app_client/`: サーバーとクライアントで共有されるコード

---

## Step 2: データモデルの定義とAIによるコード生成

Serverpodの魔法は、ここから始まります。私たちは、データベースのテーブル定義やAPIのエンドポイントを直接書きません。代わりに、**シンプルなYAMLファイル**で「欲しいデータモデル」を定義します。

`my_fullstack_app_server/lib/src/models/`ディレクトリに、`example.yaml`というファイルがあります。これをAIに修正させ、ユーザー認証に必要なモデルを定義させましょう。

> **🤖 AI活用プロンプト (モデル定義YAML生成)**
>
> Serverpodで、メールとパスワードによる認証機能に加えて、ユーザーのプロフィール情報（`displayName`と`avatarUrl`）を管理したい。
>
> Serverpodの**モデル定義用YAMLファイル**の構文に従って、以下の要件を満たすテーブル定義を書いてください。
>
> - **テーブル名:** `user_profile`
> - **フィールド:**
>   - `userId`: `int`型。`User`テーブルへのリレーション (`parent=serverpod_auth_user`)
>   - `displayName`: `String`
>   - `avatarUrl`: `String?` (nullを許容)

**AIの応答（例）:**
```yaml
# lib/src/models/user_profile.yaml
class: UserProfile
table: user_profile
fields:
  userId: int, parent=serverpod_auth_user
  displayName: String
  avatarUrl: String?
```

このYAMLファイルを保存した後、サーバープロジェクトのルートで以下のコマンドを実行します。
```bash
serverpod generate
```
すると、Serverpodは魔法のように、以下のものを**すべて自動で生成**します。
*   PostgreSQLの`user_profile`テーブルを作成・更新するためのSQLマイグレーションファイル。
*   `UserProfile`というDartクラス。
*   ユーザープロフィールを取得・更新するための、型安全なAPIエンドポイントの雛形。
*   そして、**Flutterクライアントがそのまま使える、`UserProfile`クラスと、APIを叩くためのクライアントメソッド！**

---

## Step 3: APIエンドポイントの実装

`serverpod generate`で生成された、`my_fullstack_app_server/lib/src/endpoints/`ディレクトリにあるエンドポイントの雛形ファイルに、具体的なロジックを書き加えます。これもAIに任せましょう。

> **🤖 AI活用プロンプト (エンドポイント実装)**
>
> Serverpodのエンドポイントクラスがあります。
> 現在ログインしているユーザーのプロフィールを作成・更新する`updateProfile`メソッドを実装してください。
>
> **要件:**
> 1.  メソッドは`Session`オブジェクトと、更新したい`UserProfile`オブジェクトを引数に取る。
> 2.  `session.isUserSignedIn`で、ユーザーがログインしているかを確認する。
> 3.  ログインしているユーザーのID (`session.userId`) と、渡された`UserProfile`の`userId`が一致するかを検証する。
> 4.  検証が通れば、データベースに`UserProfile`を保存（`upsert`）する。
>
> このロジックのDartコードを生成してください。

---

## Step 4: Flutterクライアントからの利用

サーバーサイドの実装が終われば、クライアントサイドからの利用は驚くほど簡単です。なぜなら、`serverpod generate`が、必要なクライアントコードをすべて生成してくれているからです。

> **🤖 AI活用プロンプト (クライアント実装)**
>
> ServerpodのFlutterクライアントがあります。
>
> ログイン後のプロフィール設定画面で、ユーザーが`displayName`を入力し、ボタンを押したら、**Serverpodのクライアントオブジェクトを使って`updateProfile`エンドポイントを呼び出す**コードを書いてください。
>
> **利用可能なオブジェクト:**
> - `client.userProfile.updateProfile(profile)`
>
> `try-catch`を使ったエラーハンドリングと、成功時に`SnackBar`でメッセージを表示する処理も実装してください。

あなたは、`http`パッケージの使い方や、JSONのパース、APIのURLなどを一切気にする必要はありません。Serverpodが生成した、**`client.userProfile.updateProfile(...)`という、型安全で、IDEの補完が効くメソッドを呼び出すだけ**です。

---

このレシピを通じて、あなたはServerpodとAIがいかにして、フルスタック開発における定型的でエラーの多い作業を撲滅し、開発者を本来の創造的な作業に集中させてくれるかを体験しました。これこそが、Dartによるフルスタック開発の未来です。