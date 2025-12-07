# レシピ#3-2: Cursor + Claudeと対話しながらUIを構築する

プロジェクトの骨組みとなるフォルダ構成が決まりました。次は、ユーザーが直接目にする「画面（UI）」を、**Cursor + Claude**と対話しながら効率的に作り上げていきましょう。

このレシピでは、前のレシピで決めた`screens/home_screen.dart`を例に、ゼロからUIを構築していくプロセスを体験します。

## ゴール

*   **Cursor + Claude**にUIの定型的なコードを生成させ、開発者はデザインの微調整に集中する。
*   自然言語での指示から、具体的なFlutterウィジェットのコードを生成させる。
*   既存のUIを、対話を通じて反復的に改善していく。

---

## Step 1: 画面の「骨格」をCursor + Claudeに作らせる

まずは、画面の最も基本的な構造（骨格）をCursor + Claudeに作ってもらいます。

> **💬 Cursor活用プロンプト (画面の骨格作成)**
>
> あなたは、FlutterのMaterial Designに精通したUIデザイナーです。
>
> `home_screen.dart` というファイルに、写真メモアプリのホーム画面を作成します。
> 以下の要件を満たす、**`StatelessWidget`** の基本的なコードを生成してください。
>
> **要件:**
> 1.  画面上部に「PhotoMemo」というタイトルが表示された `AppBar` を配置する。
> 2.  画面本体（`body`）には、現時点では「ここにメモのリストが表示されます」というテキストを中央に表示するだけにする。
> 3.  画面右下に、新しいメモを追加するための `FloatingActionButton` (FAB) を配置する。FABには「プラス（`+`）」のアイコンを表示する。

**Claudeの応答（例）:**
```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PhotoMemo'),
        backgroundColor: Colors.blue, // 例として色を追加
      ),
      body: const Center(
        child: Text('ここにメモのリストが表示されます'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 新しいメモを追加する画面に遷移する処理を実装
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

このコードを`lib/screens/home_screen.dart`に貼り付け、`lib/main.dart`から呼び出すように変更すれば、すぐに画面の骨格を確認できます。

---

## Step 2: UI部品（ウィジェット）をCursor + Claudeに作らせる

次に、ホーム画面に表示する「メモ1件分」のカードUIを、再利用可能な部品としてCursor + Claudeに作ってもらいます。これは、`widgets/memo_card.dart`に配置する想定です。

> **💬 Cursor活用プロンプト (カスタムウィジェット作成)**
>
> 次に、ホーム画面のリストに表示する、メモ1件分のカードUIを作成します。
> `memo_card.dart` というファイルに、以下の要件を満たす**`StatelessWidget`**を作成してください。
>
> **要件:**
> 1.  ウィジェット全体を `Card` で囲む。
> 2.  カードの中は、`Row` を使って、左に画像、右にテキスト情報を配置する。
> 3.  **左側:** 100x100ピクセルの固定サイズの画像を表示する。現時点では `Image.network` を使い、仮のURLを入れておく。
> 4.  **右側:** `Column` を使い、上にメモのタイトル（太字）、下にメモの作成日時（小さい文字、灰色）を表示する。
> 5.  このウィジェットは、コンストラクタで「画像URL」「タイトル」「作成日時」の文字列を受け取れるようにする。

**なぜこれが良いのか？**
*   **関心の分離:** 画面全体（`HomeScreen`）と、その中の部品（`MemoCard`）を別々に作ることで、コードが整理されます。
*   **再利用性:** `MemoCard`は、検索結果画面など、他の画面でも再利用できる可能性があります。
*   **具体的な指示:** サイズ（100x100）やウィジェット名（`Card`, `Row`, `Column`）を具体的に指示することで、**Cursor + Claude**はより的確なコードを生成します。

---

## Step 3: UIを組み立て、対話で改善する

UIの骨格と部品が揃ったので、これらを組み合わせてホーム画面を完成させ、さらに対話で見た目を改善していきます。

> **💬 Cursor活用プロンプト (UIの組み立てと改善)**
>
> ありがとう。`MemoCard`が完成しました。
>
> 最初のプロンプトで作成した `HomeScreen` の`body`部分を、以下のように修正してください。
>
> **要件:**
> 1.  `Center`ウィジェットを削除し、代わりに `ListView.builder` を使って、ダミーの`MemoCard`を10個表示するようにしてください。
> 2.  `MemoCard`に渡すデータは、現時点ではすべて同じダミーデータで構いません。
> 3.  各カードの上下に、`8.0`の余白を設けてください。

この指示で、リスト表示の基本的な形が完成します。さらに、ここから見た目を微調整していきます。

> **💬 Cursor活用プロンプト (微調整)**
>
> いい感じです。リストの見た目をもう少しきれいにしたいです。
>
> `HomeScreen`の`Scaffold`の背景色を、少し温かみのある白（`Color(0xFFF5F5F5)`）に変更してください。
> また、`AppBar`の`elevation`（影）を`0`にして、よりフラットなデザインにしてください。

このように、「**Cursor + Claudeに作らせる → 確認する → 対話で微調整する**」という短いサイクルを繰り返すことで、デザインツールを触るように、コーディングを進めることができます。これが、**Cursor + Claude**駆動UI開発の醍醐味です。