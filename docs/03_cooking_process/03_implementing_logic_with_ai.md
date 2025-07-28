# レシピ#3-3: AIと実装するロジックと状態管理

美しいUI（ユーザーインターフェース）が完成したら、次はその裏側で動く「頭脳」、つまりアプリケーションのロジックと状態管理を実装します。

このレシピでは、前のレシピで作成した写真メモアプリに、**Riverpod**を使って状態管理の仕組みを導入し、実際にメモを管理できるようにするプロセスを、AIと協力して進めます。

> **前提知識:**
> このレシピは、[状態管理の基本](../02_core_concepts/02_state_management_basics.md)の概念を理解していることを前提としています。

---

## Step 1: 状態管理の「設計図」をAIに作らせる

いきなりコードを書き始めるのではなく、まず「どのような状態を、どうやって管理したいか」という設計をAIに相談します。

> **🤖 AI活用プロンプト (状態管理の設計)**
>
> あなたは、Riverpodを使った状態管理に非常に詳しいFlutterのエキスパートです。
>
> 写真メモアプリの状態管理を設計したい。以下の要件を満たす、**Riverpodの`NotifierProvider`を使った状態管理クラス**のコードを提案してください。
>
> **管理したい状態:**
> - メモのリスト (`List<Memo>`)
>
> **必要な機能（メソッド）:**
> - 新しいメモを追加する (`addMemo`)
> - 既存のメモを削除する (`removeMemo`)
>
> **その他:**
> - `models/memo.dart`は、すでにID, タイトル, 画像パスなどを持つクラスとして定義済みです。
> - 生成するコードは、`providers/memo_provider.dart`というファイルに記述することを想定してください。
> - なぜこの設計にしたのか、簡単な解説もお願いします。

**AIの応答（例）:**
```dart
// providers/memo_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/memo.dart'; // Memoモデルをインポート

// メモのリストを管理するNotifier
class MemoNotifier extends Notifier<List<Memo>> {
  // buildメソッドで状態の初期値を設定します。
  // アプリ起動時は空のリストから始まります。
  @override
  List<Memo> build() {
    return [];
  }

  // 新しいメモをリストに追加するメソッド
  void addMemo(Memo newMemo) {
    // 現在の状態（state）のコピーを作成し、新しいメモを追加して、状態を更新します。
    // state = [...state, newMemo] は、イミュータブル（不変）な状態更新の定石です。
    state = [...state, newMemo];
  }

  // IDを指定してメモをリストから削除するメソッド
  void removeMemo(String memoId) {
    // 現在の状態（state）から、指定されたID以外のメモだけをフィルタリングして、状態を更新します。
    state = state.where((memo) => memo.id != memoId).toList();
  }
}

// UI側からMemoNotifierにアクセスするためのNotifierProvider
final memoProvider = NotifierProvider<MemoNotifier, List<Memo>>(() {
  return MemoNotifier();
});
```

**なぜこれが良いのか？**
*   **定型コードの自動化:** Riverpodの`Notifier`と`NotifierProvider`の決まりきった書き方を、AIがすべて肩代わりしてくれます。
*   **ベストプラクティスの導入:** `state = [...state, newMemo]`のような、状態を直接変更せず、新しいリストを作成して更新する「イミュータブルな更新方法」を、AIが自然に採用してくれます。

---

## Step 2: UIとロジックをAIに接続させる

状態管理の「頭脳」部分ができたので、次はUI（`HomeScreen`）からそれを呼び出せるように「神経」を繋げる作業です。この接続部分のコードもAIに任せましょう。

> **🤖 AI活用プロンプト (UIとの接続)**
>
> ありがとうございます。`memoProvider`が完成しました。
>
> 次に、以前作成した`screens/home_screen.dart`を、**この`memoProvider`と連携させてください。**
>
> **【元のUIコード】**
> ```dart
> // (ここに、ListView.builderでダミーデータを表示していたHomeScreenのコードを貼り付ける)
> ```
>
> **要件:**
> 1.  `StatelessWidget`を**`ConsumerWidget`**に変更してください。
> 2.  `ListView.builder`のデータソースを、ダミーデータから`memoProvider`が提供する実際のメモリストに変更してください。
> 3.  リストが空の場合は、「メモがありません」というテキストを中央に表示してください。
> 4.  `FloatingActionButton`が押された時に、`memoProvider`の`addMemo`メソッドを呼び出し、ダミーの新しいメモを追加する処理を実装してください。
> 5.  各`MemoCard`をスワイプで削除できるように、`Dismissible`ウィジェットでラップしてください。削除時には`removeMemo`メソッドを呼び出してください。

**なぜこれが良いのか？**
*   **文脈の提供:** 元のUIコードを渡すことで、AIは差分を正確に理解し、最小限の変更でロジックを統合してくれます。
*   **複雑な実装の委任:** `ConsumerWidget`への変更、`ref.watch`や`ref.read`の使い分け、`Dismissible`の実装など、FlutterとRiverpodの知識が必要な部分を、AIが一手に引き受けてくれます。

---

## Step 3: AIに動作確認をさせる

コードが完成したら、最後にAIに「セルフレビュー」をさせてみましょう。

> **🤖 AI活用プロンプト (セルフレビュー)**
>
> これまでの対話で完成した`memo_provider.dart`と`home_screen.dart`のコードを提示します。
>
> **【コード全体】**
> ```dart
> // (ここに、完成した2つのファイルのコードをすべて貼り付ける)
> ```
>
> あなたがシニア開発者としてこのコードをレビューする場合、何か改善できる点や、潜在的なバグはありますか？
> 例えば、メモを追加する際のIDの生成方法などについて、何かアドバイスはありますか？

このステップにより、AI自身が見落としていた点（例: IDが重複する可能性がある、など）に気づき、より堅牢なコードへと改善するきっかけを得ることができます。

これで、あなたのアプリはただの見た目だけでなく、実際にデータを操作できる「生きた」アプリケーションになりました。