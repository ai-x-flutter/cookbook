# レシピ#2-7: GitHub ActionsでCI/CDを構築する - ビルドの自動化

手動でのビルド作業は、時間がかかり、ミスも起こりがちです。CI/CD（継続的インテグレーション/継続的デリバリー）パイプラインを構築することで、コードをプッシュするだけでテストやビルドが自動的に実行される、効率的で信頼性の高い開発フローを実現できます。

このレシピでは、**GitHub Actions**を使って、Flutterアプリのビルドを自動化する方法を学びます。

## なぜGitHub Actionsを使うのか？

*   **自動化:** `git push` をトリガーに、ビルドやテストを自動実行。
*   **クリーンな環境:** 毎回まっさらな仮想環境で実行されるため、ローカル環境の差異による問題を排除。
*   **共同開発の効率化:** Pull Requestごとにビルドが成功するかを自動でチェックできる。
*   **成果物の共有:** ビルドされたアプリ（`.apk`や`.aab`）を簡単にダウンロード・共有できる。

## Step 1: 基本のワークフロー作成 (Androidデバッグビルド)

まずは、`main`ブランチにコードがプッシュされるたびに、テスト用のデバッグAPKをビルドする簡単なワークフローから始めましょう。

1.  プロジェクトのルートに `.github/workflows` というディレクトリを作成します。
2.  その中に `android_build.yml` といった名前でファイルを作成し、以下の内容を記述します。

    ```yaml
    # .github/workflows/android_build.yml
    name: Android Build

    on:
      push:
        branches:
          - main
      pull_request:
        branches:
          - main

    jobs:
      build:
        runs-on: ubuntu-latest

        steps:
          # Step 1: リポジトリのコードをチェックアウト
          - name: Checkout repository
            uses: actions/checkout@v4

          # Step 2: Java環境をセットアップ
          - name: Setup Java
            uses: actions/setup-java@v4
            with:
              distribution: 'temurin'
              java-version: '17'

          # Step 3: Flutter環境をセットアップ
          - name: Setup Flutter
            uses: subosito/flutter-action@v2
            with:
              channel: 'stable'

          # Step 4: 依存関係をインストール
          - name: Install dependencies
            run: flutter pub get

          # Step 5: (オプション) コードをテスト
          - name: Run tests
            run: flutter test

          # Step 6: AndroidのデバッグAPKをビルド
          - name: Build Android APK
            run: flutter build apk --debug

          # Step 7: ビルドされたAPKを成果物としてアップロード
          - name: Upload APK Artifact
            uses: actions/upload-artifact@v4
            with:
              name: debug-apk
              path: build/app/outputs/flutter-apk/app-debug.apk
    ```

このファイルをリポジトリにプッシュすると、GitHubの「Actions」タブでワークフローが実行され、完了すると「Artifacts」セクションから`debug-apk.zip`がダウンロードできるようになります。

## Step 2: リリースビルドの自動化 (Android App Bundle with Signing)

次に、Google Playストアに提出するための、署名付きリリースビルド（`.aab`）を自動生成します。

### 2-1. 機密情報（署名キー）をGitHub Secretsに登録

**絶対にやってはいけないこと：キーストアファイルやパスワードをGitリポジトリに直接コミットすること。**

これらの機密情報は、GitHubの暗号化された保存領域である「Secrets」に登録します。

1.  **キーストアをBase64にエンコード:**
    キーストアファイルはバイナリなので、テキストとしてSecretsに保存するためにBase64エンコードします。ローカルPCのターミナルで実行します。
    ```bash
    # Windows (PowerShell)
    [Convert]::ToBase64String([IO.File]::ReadAllBytes("path/to/upload-keystore.jks")) | Out-File -FilePath keystore.jks.base64
    # Mac/Linux
    base64 path/to/upload-keystore.jks > keystore.jks.base64
    ```
    生成された `keystore.jks.base64` ファイルの中身（長い文字列）をコピーします。

2.  **GitHub Secretsの設定:**
    *   リポジトリの `Settings > Secrets and variables > Actions` に移動します。
    *   `New repository secret` をクリックし、以下の4つのSecretを登録します。
        *   `KEYSTORE_BASE64`: 先ほどコピーしたBase64の長い文字列を貼り付け。
        *   `KEY_PASSWORD`: キーストアのパスワード。
        *   `ALIAS_NAME`: キーストアのエイリアス名。
        *   `ALIAS_PASSWORD`: エイリアスのパスワード。

### 2-2. リリースビルド用のワークフローを記述

先ほどの `android_build.yml` を拡張（または新しいファイルを作成）します。ここでは、`v1.0.0` のような**タグ**がプッシュされた時だけ実行されるように設定します。

```yaml
# .github/workflows/android_release.yml
name: Android Release Build

on:
  push:
    tags:
      - 'v*.*.*' # vX.X.X形式のタグがプッシュされた時に実行

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: 'temurin', java-version: '17' }
      - uses: subosito/flutter-action@v2
        with: { channel: 'stable' }
      - run: flutter pub get

      # Step 1: Secretsからキーストアファイルを復元
      - name: Decode Keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/upload-keystore.jks

      # Step 2: Secretsからkey.propertiesファイルを生成
      - name: Create key.properties
        run: |
          echo "storeFile=upload-keystore.jks" > android/key.properties
          echo "storePassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.ALIAS_NAME }}" >> android/key.properties
          echo "keyPassword=${{ secrets.ALIAS_PASSWORD }}" >> android/key.properties

      # Step 3: リリース用のApp Bundleをビルド
      - name: Build Android App Bundle
        run: flutter build appbundle --release

      # Step 4: 成果物(.aab)をアップロード
      - name: Upload AAB Artifact
        uses: actions/upload-artifact@v4
        with:
          name: release-aab
          path: build/app/outputs/bundle/release/app-release.aab
```

これで、ローカルPCで `git tag v1.0.1` と打ち、`git push origin v1.0.1` を実行するだけで、署名済みのリリースビルドが自動的に作成され、いつでもGoogle Play Consoleにアップロードできる状態になります。

> **🤖 AI活用プロンプト (ワークフローファイルの生成)**
>
> 複雑なワークフローをゼロから書くのは大変です。AIに下書きを作ってもらいましょう。
> ```
> あなたはGitHub Actionsの専門家です。
>
> FlutterプロジェクトのCI/CDパイプラインを構築したい。
> `main`ブランチへのpushをトリガーとして、以下の処理を行うGitHub Actionsのワークフローファイル（YAML形式）を生成してください。
>
> 1. Flutterの安定版をセットアップ
> 2. `flutter test` を実行
> 3. `flutter build apk` を実行
>
> 各ステップには、何をしているか分かりやすいように `name` を付けてください。
> ```