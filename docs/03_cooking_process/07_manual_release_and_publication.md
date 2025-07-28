# レシピ#3-7: 手動でのリリースとストア公開

AIと共にアプリのコア機能を開発し、品質を高めました。いよいよ、あなたのアプリを世界に届ける時です！このレシピでは、自動化（CI/CD）を導入する前に、まず**手動で**リリース用のアプリをビルドし、各アプリストアに公開申請する基本的なプロセスを解説します。

この手動プロセスを一度経験することで、後のステップである「ビルドの自動化」のありがたみを深く理解できるでしょう。

> **⚠️ 事前準備**
> *   [Google Play Console](https://play.google.com/console/) と [Apple Developer Program](https://developer.apple.com/programs/) への開発者登録を済ませておいてください。
> *   [公開前の準備](../05_serving_the_app/00_introduction.md)で解説した、アプリアイコン、スクリーンショット、プライバシーポリシーのURLなどを用意しておいてください。

---

## 1. Androidアプリのリリースビルド (手動)

Google Playストアに提出するための、署名付きApp Bundle (`.aab`) を作成します。

### 1-1. 署名キーの準備

1.  **キーストアの作成:** まだ作成していない場合、[Flutter公式ドキュメント](https://docs.flutter.dev/deployment/android#create-an-upload-keystore)に従って、`upload-keystore.jks` ファイルを作成します。**このファイルとパスワードは絶対に紛失しないでください。**
2.  **`key.properties`の作成:** プロジェクトの `android` フォルダ直下に `key.properties` というファイルを作成し、署名情報を記述します。（**このファイルは必ず`.gitignore`に追加してください！**）
    ```properties
    # android/key.properties
    storePassword=あなたのストアパスワード
    keyPassword=あなたのキーパスワード
    keyAlias=upload
    storeFile=../upload-keystore.jks # プロジェクトルートからの相対パス
    ```

### 1-2. App Bundleのビルド

ターミナルで以下のコマンドを実行します。
```bash
flutter build appbundle --release
```
成功すると、`build/app/outputs/bundle/release/app-release.aab` にファイルが生成されます。これがGoogle Playにアップロードするファイルです。

### 1-3. Google Play Consoleへのアップロード

1.  [Google Play Console](https://play.google.com/console/)にログインし、対象のアプリを選択します。
2.  左側メニューの「製品版」から「新しいリリースを作成」に進みます。
3.  生成された`.aab`ファイルをアップロードし、リリースノートなどを記入します。
4.  ストア掲載情報やアプリのコンテンツ設定などをすべて埋め、審査に提出します。

---

## 2. iOSアプリのリリースビルド (手動)

App Storeに提出するための、署名付きIPA (`.ipa`) ファイルをビルドし、アップロードします。

### 2-1. Xcodeでの準備

1.  **Xcodeを開く:** ターミナルで `open ios/Runner.xcworkspace` を実行し、プロジェクトをXcodeで開きます。
2.  **署名設定の確認:** `Runner`ターゲットの「Signing & Capabilities」タブで、「Automatically manage signing」にチェックが入っていることと、あなたのDeveloperチームが選択されていることを確認します。
3.  **バージョン情報の設定:** 「General」タブで、`Version` (例: `1.0.0`) と `Build` (例: `1`) を設定します。

### 2-2. アーカイブとアップロード

1.  **Flutterでビルド:**
    ```bash
    flutter build ipa --release
    ```
2.  **Xcodeでアーカイブ:**
    Xcodeの上部メニューから `Product > Archive` を選択します。ビルドが完了すると、「Organizer」ウィンドウが開きます。
3.  **App Store Connectへアップロード:**
    Organizerウィンドウで、作成したアーカイブを選択し、「Distribute App」ボタンをクリックします。画面の指示に従い、「App Store Connect」経由でアップロードします。

### 2-3. App Store Connectでの申請

1.  [App Store Connect](https://appstoreconnect.apple.com/)にログインし、「マイアプリ」から対象のアプリを選択します。
2.  TestFlightで内部テストを行った後、「審査へ提出」の準備を進めます。
3.  アップロードしたビルドを選択し、スクリーンショットや説明文、キーワード、Appプライバシー情報などをすべて入力します。
4.  すべての準備が整ったら、「審査へ提出」します。

---

おめでとうございます！これで、あなたは手動でアプリをストアに公開する一連の流れをマスターしました。
しかし、バージョンアップのたびにこの作業を繰り返すのは大変だと思いませんか？

**次のレシピでは、いよいよこの面倒なビルドと署名のプロセスを、GitHub Actionsを使って完全に自動化する方法を学びます。**

➡️ **次のレシピへ:** [`07_ci_cd_with_github_actions.md`](./07_ci_cd_with_github_actions.md)