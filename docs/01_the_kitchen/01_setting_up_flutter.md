# レシピ#1-1: Flutter開発環境の準備（キッチンのセットアップ）

AIとの共同開発を始める前に、まずは基本となるFlutterの開発環境を整える必要があります。これは、料理を始める前の「キッチンのセットアップ」に相当します。

このマニュアルでは、Flutter SDKをインストールし、開発の準備が整っているかを確認するまでの手順を解説します。

## Step 1: Flutter SDKのインストール

Flutter SDKは、Flutterアプリを開発・ビルドするためのツールやライブラリの集合体です。

1.  **公式サイトからSDKをダウンロード:**
    *   [Flutter公式サイトのインストールページ](https://docs.flutter.dev/get-started/install)にアクセスします。
    *   お使いのOS（Windows, macOS, Linux）を選択し、最新のStableチャンネルのSDK（ZIPファイル）をダウンロードします。

2.  **SDKを配置:**
    *   ダウンロードしたZIPファイルを解凍します。
    *   解凍してできた`flutter`フォルダを、PC内の**適切な場所**に配置します。
        *   **推奨される場所:** `C:\flutter` (Windows) や `~/development/flutter` (macOS/Linux) など、**パスにスペースや日本語が含まれない、浅い階層のディレクトリ**が理想です。
        *   **避けるべき場所:** `C:\Program Files` のような、管理者権限が必要な場所は避けてください。

## Step 2: 環境変数 "Path" の設定

ターミナルのどこからでも`flutter`コマンドを実行できるように、Flutter SDKへの「道（Path）」をOSに教えてあげる必要があります。

1.  先ほど配置した`flutter`フォルダの中にある`bin`フォルダのフルパスをコピーします。
    *   例: `C:\flutter\bin` (Windows)
    *   例: `/Users/your-username/development/flutter/bin` (macOS/Linux)

2.  **環境変数`Path`に、コピーしたパスを追加します。**

    *   **Windowsの場合:**
        1.  スタートメニューで「環境変数」と検索し、「システム環境変数の編集」を開きます。
        2.  「環境変数...」ボタンをクリックします。
        3.  「（ユーザー名）のユーザー環境変数」セクションで、「Path」を選択し、「編集...」をクリックします。
        4.  「新規」をクリックし、コピーしたパス（例: `C:\flutter\bin`）を貼り付け、「OK」で全てのウィンドウを閉じます。

    *   **macOS/Linuxの場合:**
        1.  お使いのシェル設定ファイル（`.zshrc`, `.bash_profile`, `.bashrc`など）をテキストエディタで開きます。
        2.  ファイルの末尾に以下の行を追記します。（パスはあなたの環境に合わせてください）
            ```bash
            export PATH="$PATH:/Users/your-username/development/flutter/bin"
            ```
        3.  ファイルを保存し、ターミナルを再起動して設定を反映させます。

## Step 3: `flutter doctor`で健康診断

環境設定が正しく行われたかを確認するための、非常に便利なコマンドが`flutter doctor`です。

1.  **新しいターミナル（コマンドプロンプトやPowerShell）を開きます。**（環境変数を反映させるため、必ず新しいウィンドウを開いてください）
2.  以下のコマンドを実行します。
    ```bash
    flutter doctor
    ```
    `flutter doctor`は、あなたのシステムをスキャンし、Flutter開発に必要なツールが揃っているかを診断します。

### `doctor`の診断結果の見方

実行すると、以下のような診断結果が表示されます。

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on Microsoft Windows ...)
[!] Android toolchain - develop for Android devices (Android SDK version X.X.X)
    ✗ cmdline-tools component is missing
      Run `path/to/sdkmanager --install "cmdline-tools;latest"`
[✓] Chrome (develop for the web)
[!] Visual Studio - develop for Windows apps (Visual Studio Community 2022)
[!] Android Studio (version X.X)
    ✗ Unable to find bundled Java version.
[!] Connected device
    ! No devices available

! Doctor found issues in 3 categories.
```

*   `[✓]` **チェックマーク:** この項目は問題なく設定されています。
*   `[!]` **感嘆符** または `[✗]` **バツ印:** この項目には、何らかの問題や不足している設定があります。

### 問題の解決

`flutter doctor`は非常に親切で、多くの場合、**問題を解決するための具体的なコマンドや手順を提示してくれます。**

*   `Android toolchain`に問題がある場合: Android Studioのインストールや、必要なSDKコンポーネントのインストールが必要です。
*   `Visual Studio`に問題がある場合: Windowsデスクトップアプリを開発する場合に必要です。Visual Studio Installerで「C++によるデスクトップ開発」ワークロードをインストールします。
*   `Android Studio`に問題がある場合: Android Studioのプラグインが不足しているか、正しくインストールされていません。

表示されたメッセージに従って、一つずつ問題を解決し、再度`flutter doctor`を実行してください。**すべての主要な項目（Flutter, Android toolchainなど）が`[✓]`になる**ことが、このステップのゴールです。

キッチンのセットアップが完了しました！これで、あなたはFlutterアプリを料理する準備が整いました。
次のレシピでは、AIという最新の調理器具（ツール）をキッチンに導入する方法を見ていきましょう。