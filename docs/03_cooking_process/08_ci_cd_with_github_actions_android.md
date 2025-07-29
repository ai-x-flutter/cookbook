# レシピ#3-8: Androidビルドの自動化 with GitHub Actions

前のレシピで、手動でのリリースビルドとストア公開の方法を学びました。しかし、バージョンアップのたびにこの作業を繰り返すのは、時間がかかり、人的ミスの原因にもなります。

このレシピでは、CI/CD（継続的インテグレーション/継続的デリバリー）ツールである**GitHub Actions**を使い、この面倒なAndroidのビルドと署名のプロセスを**完全に自動化**する方法を学びます。

## なぜ自動化するのか？ - CI/CDのメリット

*   **ヒューマンエラーの削減:** 手順がコード化されるため、「署名パスワードを間違えた」「ビルドコマンドを間違えた」といったミスがなくなります。
*   **時間と手間の節約:** `git push`するだけで、ビルドから成果物の作成までが自動で行われます。あなたは他の作業に集中できます。
*   **再現性の確保:** いつでも、誰でも、同じ手順で、同じ品質のビルドを生成できます。
*   **チーム開発の円滑化:** Pull Requestが作成されるたびに、ビルドが成功するかを自動でチェックし、品質を保ちます。

---

## Step 1: 基本のワークフロー作成 (デバッグビルド)

まずは、`main`ブランチにコードがプッシュされるたびに、テスト用のデバッグAPKをビルドする簡単なワークフローから始めましょう。これにより、GitHub Actionsの基本的な仕組みに慣れることができます。

1.  プロジェクトのルートに `.github/workflows` というディレクトリを作成します。
2.  その中に `android_build.yml` といった名前でYAMLファイルを作成し、以下の内容を記述します。

    ```yaml
    # .github/workflows/android_build.yml
    name: Android Build CI

    on:
      push:
        branches: [ "main" ]
      pull_request:
        branches: [ "main" ]

    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-java@v4
            with:
              distribution: 'temurin'
              java-version: '17'
          - uses: subosito/flutter-action@v2
            with:
              channel: 'stable'

          - name: Install dependencies
            run: flutter pub get

          - name: Analyze project source
            run: flutter analyze

          - name: Run tests
            run: flutter test

          - name: Build debug APK
            run: flutter build apk --debug

          - name: Upload APK artifact
            uses: actions/upload-artifact@v4
            with:
              name: debug-apk
              path: build/app/outputs/flutter-apk/app-debug.apk
    ```
このファイルをリポジトリにプッシュすると、GitHubの「Actions」タブでワークフローが実行され、完了すると「Artifacts」セクションから`debug-apk.zip`がダウンロードできるようになります。

---

## Step 2: リリースビルドの自動化 (署名付きApp Bundle)

次に、このCookbookのハイライト、Google Playストアに提出するための**署名付きリリースビルド（`.aab`**）を自動生成します。

### 2-1. 機密情報（署名キー）をGitHub Secretsに登録

**絶対にやってはいけないこと：キーストアファイルやパスワードをGitリポジトリに直接コミットすること。**

これらの機密情報は、GitHubの暗号化された保存領域である「Secrets」に登録します。

1.  **キーストアをBase64にエンコード:**
    キーストアファイルはバイナリなので、テキストとしてSecretsに保存するためにBase64エンコードします。ローカルPCのターミナルで実行します。
    ```bash
    # Windows (PowerShell)
    [Convert]::ToBase64String([IO.File]::ReadAllBytes("path/to/upload-keystore.jks")) | Set-Content -Path keystore.jks.base64
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

新しいワークフローファイル `android_release.yml` を作成します。ここでは、`v1.0.0` のような**Gitタグ**がプッシュされた時だけ、リリースビルドが実行されるように設定するのが一般的です。

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

      - name: Decode Keystore
        run: echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/upload-keystore.jks

      - name: Create key.properties
        run: |
          echo "storeFile=upload-keystore.jks" > android/key.properties
          echo "storePassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.ALIAS_NAME }}" >> android/key.properties
          echo "keyPassword=${{ secrets.ALIAS_PASSWORD }}" >> android/key.properties

      - name: Build Android App Bundle
        run: flutter build appbundle --release

      - name: Upload Release AAB
        uses: actions/upload-artifact@v4
        with:
          name: release-aab
          path: build/app/outputs/bundle/release/app-release.aab
```

## Step 3: ワークフローの実行

1.  ローカルPCで、リリースしたいコミットに対してGitタグを作成します。
    ```bash
    # 例: バージョン1.0.1のタグを作成
    git tag v1.0.1
    ```
2.  作成したタグをGitHubにプッシュします。
    ```bash
    git push origin v1.0.1
    ```

このプッシュをトリガーに、GitHub Actionsが自動的に起動します。ワークフローが完了すると、署名済みの`release-aab.zip`がArtifactsとして生成され、いつでもGoogle Play Consoleにアップロードできる状態になります。

あなたはもう、面倒なビルドコマンドや署名プロセスを思い出す必要はありません！