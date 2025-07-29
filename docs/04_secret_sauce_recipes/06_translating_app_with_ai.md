# レシピ#4-6: AIによるアプリの多言語対応（国際化）

あなたのアプリを世界中のユーザーに使ってもらうためには、多言語対応（国際化、i18n）が不可欠です。しかし、翻訳作業や、言語ごとのファイル管理は非常に手間のかかるプロセスです。

このレシピでは、AIを「優秀な翻訳家」兼「ファイル管理アシスタント」として活用し、Flutterアプリの国際化を効率的に行う方法を学びます。

## Step 1: 国際化の土台を準備する

Flutterで国際化を行うには、いくつかの標準的なパッケージと設定が必要です。この面倒な初期設定も、AIに手順を尋ねることから始めましょう。

> **🤖 AI活用プロンプト (初期設定の質問)**
>
> あなたはFlutterの国際化（i18n）に詳しいエキスパートです。
>
> `flutter_localizations` SDKと`intl`パッケージを使って、Flutterアプリを国際化するための初期設定の手順をステップバイステップで教えてください。
>
> 1. `pubspec.yaml`に必要なパッケージを追加する方法。
> 2. `MaterialApp`ウィジェットに、`localizationsDelegates`と`supportedLocales`を設定する方法。
>
> `l10n.yaml`ファイルを作成し、基本的な設定を行う方法も説明してください。

AIの指示に従い、`pubspec.yaml`に`flutter_localizations`と`intl`を追加し、`l10n.yaml`ファイルを作成・設定します。

**`l10n.yaml`の例:**
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

---

## Step 2: AIによる翻訳ファイル（`.arb`）の生成

国際化の中心となるのが、各言語の文字列をキーと値のペアで管理する`.arb` (Application Resource Bundle) ファイルです。

まず、基準となる言語（ここでは英語）のファイル`app_en.arb`を作成します。
**`lib/l10n/app_en.arb`**
```json
{
  "helloWorld": "Hello World!",
  "appTitle": "Photo Memo App",
  "addMemoButton": "Add Memo"
}
```

次に、この英語版のファイルを元に、**日本語版の`app_ja.arb`をAIに一括で生成させます。**

> **🤖 AI活用プロンプト (翻訳ファイルの生成)**
>
> あなたは多言語の翻訳が得意なAIアシスタントです。
>
> 以下のFlutter国際化用`.arb`ファイル（英語）の内容を、**自然な日本語に翻訳**し、日本語用の`.arb`ファイル（`app_ja.arb`）を生成してください。
> JSONのキーは変更せず、値（文字列）だけを翻訳してください。
>
> 【**元のファイル: `app_en.arb`**】
> ```json
> {
>   "helloWorld": "Hello World!",
>   "appTitle": "Photo Memo App",
>   "addMemoButton": "Add Memo"
> }
> ```

**AIの応答（例）:**
```json
{
  "helloWorld": "こんにちは、世界！",
  "appTitle": "写真メモアプリ",
  "addMemoButton": "メモを追加"
}
```
この応答を`lib/l10n/app_ja.arb`として保存します。数十、数百の文字列があっても、AIは一瞬で翻訳してくれます。

---

## Step 3: UIコードへの適用

`.arb`ファイルを用意したら、ターミナルで`flutter pub get`を実行（またはIDEを再起動）すると、`intl`パッケージが`app_localizations.dart`というファイルを自動生成してくれます。

あとは、UIコード内のハードコーディングされた文字列を、この生成されたクラスを使って置き換えるだけです。

**修正前:**
```dart
Text('Hello World!')
```

**修正後:**
```dart
// まず、生成されたクラスをインポート
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// buildメソッド内で
Text(AppLocalizations.of(context)!.helloWorld)
```

> **🤖 AI活用プロンプト (コードの置換リファクタリング)**
>
> 既存のコードが大量にある場合、手動での置き換えは大変です。AIにリファクタリングを依頼しましょう。
> ```
> 以下のFlutterのウィジェットコードがあります。
> ハードコーディングされている文字列（例: `'Photo Memo App'`）を、`intl`パッケージで生成された`AppLocalizations.of(context)!`を使った形式に書き換えてください。
>
> 【**元のコード**】
> ```dart
> // (ここに、ハードコーディングされた文字列を含むウィジェットのコードを貼り付ける)
> ```
>
> 【**対応する.arbのキー**】
> - `'Photo Memo App'` -> `appTitle`
> - `'Add Memo'` -> `addMemoButton`
>
> 修正後のコードを提示してください。
> ```

## Step 4: 応用編 - 引数や複数形を含む翻訳

国際化では、単なる文字列置換だけでなく、より複雑なケースも存在します。

> **🤖 AI活用プロンプト (応用的な翻訳)**
>
> `intl`パッケージの`.arb`形式で、以下の要件を満たす翻訳を生成してください。
>
> 1.  `welcomeMessage`: `Welcome, {userName}!` のように、`userName`という**引数**を受け取れるようにする。
> 2.  `itemCount`: `You have {count} items.` のように、`count`の**数値によって単数形と複数形を切り替えられる**ようにする。（例: 1 item / 2 items）
>
> この2つのキーを持つ、英語の`.arb`ファイルと、それに対応する自然な日本語の`.arb`ファイルを生成してください。

このプロンプトにより、AIはICUメッセージフォーマットと呼ばれる標準的な記法を使った、高度な`.arb`ファイルを生成してくれます。

AIを翻訳パートナーにすることで、これまで数日かかっていたかもしれない国際化対応作業を、数時間に短縮することも可能です。