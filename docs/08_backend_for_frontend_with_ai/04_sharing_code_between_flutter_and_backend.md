# レシピ#8-4: FlutterアプリとDartバックエンドでコードを共有する

これまでのレシピでは、FlutterアプリとDart Frogバックエンドという2つのプロジェクトを個別に構築してきました。
しかし現状では、両者は完全に独立しており、たとえばユーザーデータを扱う場合、Userモデルクラスをそれぞれのプロジェクトで重複して定義しなければなりません。これは、保守性の低下や不整合によるバグの温床となります。

このレシピでは、そのような問題を解消し、Dartによるフルスタック開発の真価を引き出すための「**コード共有**」の実践方法を学びます。

今、FlutterとDartを用いたフルスタック開発が注目されているのは、フロントエンドとバックエンドを同じ言語・同じ型システムで統一できるという、他のスタックにはない大きな利点があるからです。
その強みを最大限に活かすためには、データモデルの共有が欠かせません。
1つのモデル定義を全体で使い回すことで、記述の重複や整合性チェックの手間を減らし、開発スピードと品質の両方を飛躍的に高めることができます。
FlutterとDart Frogを使ってアプリを作るなら、今この段階でコード共有の基盤を整えておくことは、将来的な拡張や保守においても大きなアドバンテージとなるでしょう。

## ゴール

*   **1つの場所**で定義したデータモデル（例: `User`クラス）を、FlutterアプリとDart Frogサーバーの両方から`import`して利用する。
*   これにより、開発効率を向上させ、フロントエンドとバックエンド間の型安全性を保証する。

---

## 1. モノレポ構造の導入

コードを共有するための最も一般的な方法は、両方のプロジェクトを一つの大きなリポジトリ、すなわち**モノレポ（Monorepo）**で管理することです。

### 1-1. ディレクトリ構造の準備

まず、`ai-x-flutter`のような、あなたの開発用親フォルダの中に、このモノレポのルートとなる新しいフォルダを作成します（例: `my_fullstack_project`）。
このmodelsパッケージは「アプリ全体の共通ルールを定義する場」です。  
APIの設計・データ構造の定義・変換メソッドなどをここに集約することで、プロジェクトの一貫性が保たれます。
その中に、これまでのプロジェクトを以下のように配置します。

```
my_fullstack_project/
├── packages/
│   └── models/          # ★共有コードを置く新しいパッケージ
│       ├── lib/
│       │   └── src/
│       │       └── user.dart
│       └── pubspec.yaml
├── my_flutter_app/      # 既存のFlutterアプリ
│   ├── lib/
│   └── pubspec.yaml
└── my_api_server/       # 既存のDart Frogサーバー
    ├── routes/
    └── pubspec.yaml
```

### 1-2. 共有パッケージの作成

`packages/`ディレクトリの中に、共有コードを置くための、新しい純粋なDartパッケージを作成します。

> **🤖 AI活用プロンプト (共有パッケージ作成)**
>
> あなたはDartのパッケージ管理に詳しいエキスパートです。
>
> FlutterプロジェクトとDart Frogプロジェクトの間でコードを共有するための、純粋なDartパッケージを作成したい。
>
> ターミナルで、`packages/`ディレクトリに移動した後、`models`という名前の新しいDartパッケージを作成するためのコマンドを教えてください。

**AIの応答（例）:**
> `dart create`コマンドを使い、`--template=package`を指定します。
> ```bash
> # my_fullstack_project/packages/ ディレクトリにいる状態で...
> dart create --template=package models
> ```

このコマンドを実行すると、`packages/models`フォルダに必要なファイルが生成されます。
`packages/models/lib/src/user.dart`に、共有したい`User`クラスを定義しましょう。

**`packages/models/lib/src/user.dart`:**
```dart
class User {
  const User({required this.id, required this.name});

  final String id;
  final String name;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
```

---

## 2. 共有パッケージへの依存設定

次に、FlutterアプリとDart Frogサーバーの両方に、「この`models`パッケージを使いますよ」と教えてあげる必要があります。

これは、それぞれの`pubspec.yaml`ファイルに、**パス（`path`）**を使った依存関係を追加することで実現します。

### 2-1. Flutterアプリ側の設定

**`my_flutter_app/pubspec.yaml`:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 追加する部分
  models:
    path: ../packages/models # このファイルから見た、modelsパッケージへの相対パス
```

### 2-2. Dart Frogサーバー側の設定

**`my_api_server/pubspec.yaml`:**
```yaml
dependencies:
  dart_frog: ^1.0.0
  
  # 追加する部分
  models:
    path: ../packages/models # このファイルから見た、modelsパッケージへの相対パス
```

設定を書き換えたら、**両方のプロジェクト**で`flutter pub get`（Flutterアプリ）と`dart pub get`（Dart Frog）を実行するのを忘れないでください。

---

## 3. 共有コードの利用

これで準備は完了です！FlutterアプリとDart Frogサーバーの両方で、同じ`User`クラスを`import`して利用できるようになりました。

### 3-1. Dart Frogサーバー側での利用

> **🤖 AI活用プロンプト (サーバーサイドでの利用)**
>
> `my_api_server`の`routes/users/[id].dart`を修正したい。
>
> 共有パッケージ`models`から`User`クラスをインポートし、ダミーの`User`オブジェクトを作成して、それをJSONとして返すようにコードを書き換えてください。

**AIの応答（例）:**
```dart
// my_api_server/routes/users/[id].dart
import 'package:dart_frog/dart_frog.dart';
import 'package:models/models.dart'; // ★共有パッケージをインポート！

Response onRequest(RequestContext context, String id) {
  // 共有されたUserクラスを使ってオブジェクトを作成
  final user = User(id: id, name: 'Taro Yamada');

  // toJson()メソッドも共有されているので、そのまま使える
  return Response.json(body: user.toJson());
}
```

### 3-2. Flutterアプリ側での利用

> **🤖 AI活用プロンプト (クライアントサイドでの利用)**
>
> `my_flutter_app`で、先ほどのAPIを叩いてユーザー情報を表示する機能を実装したい。
>
> `http`パッケージを使い、APIから返ってきたJSONを、共有パッケージ`models`の`User.fromJson()`を使って`User`オブジェクトに変換し、その名前を画面に表示する、という一連のコードを書いてください。

このステップにより、あなたはフロントエンドとバックエンドの間で、**型安全性が完全に保証された**データ連携を実現しました。もし将来、`User`モデルに`email`プロパティを追加する必要が出ても、`packages/models/user.dart`を**一箇所修正するだけ**で、アプリとサーバーの両方に変更が反映されます。

これが、Dartによるフルスタック開発がもたらす、圧倒的な生産性と安全性の源泉なのです。