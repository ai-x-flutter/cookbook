# 重要概念#2-4: 画面遷移の基本（Routing） - Navigatorのpush/pop

ほとんどのアプリは、複数の画面で構成されています。ユーザーがある画面から別の画面に移動する、このプロセスを「**画面遷移**」または「**ルーティング（Routing）**」と呼びます。

Flutterでは、この画面遷移を**`Navigator`**ウィジェットが管理しています。このドキュメントでは、`Navigator`の最も基本的な操作である`push`と`pop`を、**カードの山（スタック**）に例えて解説します。

## 1. `Navigator`とは「画面を管理するスタック」

`Navigator`を理解する最も簡単な方法は、トランプのカードの山（スタック）を想像することです。

*   **画面（`Route`**） → 1枚1枚の**カード**
*   **`Navigator`** → カードを重ねて管理する**山（スタック**）

ユーザーが今見ている画面は、常にスタックの一番上にあるカードです。

![Navigatorのスタック構造](https://docs.flutter.dev/assets/images/docs/ui/navigation/navigator-stack.png)
*(Image credit: flutter.dev)*

## 2. `push`：新しい画面を上に重ねる

`push`は、新しい画面に移動する際の最も基本的な操作です。これは、**スタックの上に新しいカードを重ねる**行為に相当します。

*   **動作:** 現在の画面（一番上のカード）の上に、新しい画面（新しいカード）を置きます。
*   **結果:** ユーザーには、新しく置かれた一番上の画面が見えるようになります。古い画面は、その下に隠れて存在し続けています。

### コード例

`ElevatedButton`を押すと、`SecondScreen`という新しい画面に遷移する例です。

```dart
ElevatedButton(
  child: const Text('次の画面へ'),
  onPressed: () {
    // Navigator.pushは、画面遷移を実行するお決まりの書き方
    Navigator.push(
      context, // 現在の画面の場所を教えるための情報
      MaterialPageRoute(
        builder: (context) => const SecondScreen(), // 次に表示したい画面ウィジェット
      ),
    );
  },
)
```
`MaterialPageRoute`は、プラットフォーム（Android/iOS）に合わせた標準的な画面遷移アニメーション（下からスライドインなど）を提供してくれる便利なクラスです。

## 3. `pop`：一番上の画面を取り除く

`pop`は、現在の画面を閉じて、前の画面に戻る際の操作です。これは、**スタックの一番上にあるカードを取り除く**行為に相当します。

*   **動作:** 現在の画面（一番上のカード）をスタックから取り除きます。
*   **結果:** 一つ下の階層にあったカードが一番上になり、ユーザーにはその画面が見えるようになります。

### コード例

`SecondScreen`に配置された「戻る」ボタンを押すと、元の画面に戻る例です。

```dart
// SecondScreenの中のボタン
ElevatedButton(
  child: const Text('前の画面に戻る'),
  onPressed: () {
    // Navigator.popは、現在の画面を閉じるためのお決まりの書き方
    Navigator.pop(context);
  },
)
```

**ヒント:** `Scaffold`ウィジェットと`AppBar`を一緒に使うと、`AppBar`の左側に自動的に「戻る」ボタンが表示されます。このボタンは、内部で`Navigator.pop(context)`を呼び出してくれているため、自分で戻るボタンを実装する必要がない場合も多くあります。

## 4. 画面間でデータをやり取りする

`push`と`pop`は、単に画面を移動するだけでなく、**データを渡したり、結果を受け取ったりする**こともできます。

### A. 次の画面へデータを渡す

新しい画面のコンストラクタに引数を渡すだけです。

```dart
// 最初の画面
Navigator.push(
  context,
  MaterialPageRoute(
    // SecondScreenに、ID '123' を渡す
    builder: (context) => const SecondScreen(memoId: '123'),
  ),
);

// SecondScreen側
class SecondScreen extends StatelessWidget {
  final String memoId;
  const SecondScreen({super.key, required this.memoId});
  // ...
}
```

### B. 前の画面へ結果を返す

`pop`の第2引数に、返したいデータを指定します。そして、`push`する側は、`Future`としてその結果を`await`で待つことができます。

```dart
// 最初の画面側
Future<void> _navigateToSecondScreen() async {
  // SecondScreenから返ってくる結果を待つ
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SecondScreen()),
  );

  // resultには '成功！' という文字列が入る
  if (result != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('結果: $result')),
    );
  }
}

// SecondScreen側
ElevatedButton(
  child: const Text('操作を完了して戻る'),
  onPressed: () {
    // 前の画面に '成功！' という文字列を返す
    Navigator.pop(context, '成功！');
  },
)
```

> **🤖 AI活用プロンプト**
>
> 画面遷移のコードがうまく書けない時は、AIに手伝ってもらいましょう。
> ```
> あなたはFlutterの画面遷移のエキスパートです。
>
> `ProductListScreen`から`ProductDetailScreen`へ画面遷移するコードを書いてください。
>
> **要件:**
> - `ProductListScreen`のリスト項目をタップした時に遷移する。
> - 遷移時に、タップされた商品のID（`productId`という`String`）を`ProductDetailScreen`に渡したい。
> - `ProductDetailScreen`は、AppBarに戻るボタンを自動で表示するようにしてください。
>
> それぞれの画面の基本的なウィジェットコードを提示してください。
> ```

`Navigator`の`push`と`pop`は、Flutterアプリの骨格を作る上で最も基本的な操作です。このカードスタックのイメージを掴めば、ユーザーをアプリ内の様々な場所に自由に案内できるようになります。