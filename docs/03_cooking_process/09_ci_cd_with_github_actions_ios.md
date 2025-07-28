# レシピ#3-9: iOSビルドの自動化 with GitHub Actions

Androidのビルド自動化に続き、このレシピでは**iOSアプリ**のビルド、署名、そして**TestFlightへの自動アップロード**までをGitHub Actionsで実現する方法を学びます。

iOSの署名プロセスは複雑ですが、専用のActionを使えば、この面倒な作業も安全かつ確実に行うことができます。

## なぜiOSビルドを自動化するのか？

*   **macOS環境が手元になくてもビルド可能:** GitHubが提供するmacOSの仮想環境でビルドするため、チーム内にMacがないメンバーでもビルドのトリガーを引けます。（※最初の証明書作成など、一部の作業にはMacが必要です）
*   **証明書の安全な管理:** 有効期限のある証明書やプロファイルを、リポジトリに直接含めることなく、安全に管理・利用できます。
*   **TestFlightへの自動デプロイ:** `git push`するだけで、最新のビルドがテスターの元へ自動的に届けられる、という夢のような開発サイクルを実現できます。

---

## Step 1: 機密情報の準備とGitHub Secretsへの登録

iOSの署名とApp Store Connectへのアップロードには、以下の**4種類の機密情報**が必要です。これらを準備し、GitHub Secretsに登録します。

### 1-1. App Store Connect APIキー

App Store Connectへの自動アップロードには、パスワードの代わりにAPIキーを使います。

1.  [App Store Connect](https://appstoreconnect.apple.com/)にアクセスし、「ユーザーとアクセス」 > 「インテグレーション」タブ（または「キー」タブ）に移動します。
2.  「＋」ボタンで新しいキーを生成します。
    *   **名前:** `GitHub Actions` など分かりやすい名前
    *   **アクセス:** `App Manager` を選択
3.  キーを生成すると、以下の3つの情報が得られます。**これらは一度しか表示されないので、必ず安全な場所に保存してください。**
    *   **Issuer ID:** ページ上部に表示
    *   **Key ID:** 生成されたキーの行に表示
    *   **API Key (`.p8`ファイル):** 「APIキーをダウンロード」からダウンロード

### 1-2. ビルド証明書 (`.p12`ファイル)

これは「誰がビルドしたか」を証明するファイルです。

1.  ローカルのMacの「キーチェーンアクセス」アプリを開きます。
2.  App Storeへの提出に使う配布用証明書（`Apple Distribution: ...`など）を探します。
3.  証明書の横の▶︎を開き、証明書と、その下にある秘密鍵の両方を`Command`キーを押しながら選択します。
4.  右クリックから「2項目を書き出す」を選択し、ファイル形式で「個人情報交換（.p12）」を選び保存します。このとき、**エクスポート用のパスワードを設定します。**このパスワードは後で使います。

### 1-3. プロビジョニングプロファイル (`.mobileprovision`ファイル)

これは「どのアプリを、どの権限でビルドするか」を定義したファイルです。

1.  [Apple Developerサイト](https://developer.apple.com/account/resources/profiles/list)にアクセスします。
2.  `Profiles`セクションから、あなたのアプリに対応する`App Store`配布用のプロビジョニングプロファイルをダウンロードします。

### 1-4. Secretsへの登録

準備した情報をGitHub Secretsに登録します。バイナリファイル（`.p12`, `.mobileprovision`）は、**Base64エンコード**してテキスト化する必要があります。

1.  **エンコード:** ローカルのMacのターミナルで、以下のコマンドを実行します。
    ```bash
    # 証明書(.p12)をエンコード
    base64 -i YourCertificate.p12 > certificate.p12.base64

    # プロビジョニングプロファイルをエンコード
    base64 -i YourProfile.mobileprovision > profile.mobileprovision.base64
    ```
    生成された2つの`.base64`ファイルの中身（長い文字列）をコピーしておきます。

2.  **GitHub Secretsの設定:**
    リポジトリの `Settings > Secrets and variables > Actions` で、以下の**8つ**のSecretを登録します。

| Secret名                         | 値                                                                   |
| -------------------------------- | ---------------------------------------------------------------------- |
| `APP_STORE_CONNECT_ISSUER_ID`    | 1-1で取得した Issuer ID                                                |
| `APP_STORE_CONNECT_KEY_ID`       | 1-1で取得した Key ID                                                   |
| `APP_STORE_CONNECT_PRIVATE_KEY`  | 1-1でダウンロードした`.p8`ファイルの中身をすべて貼り付け               |
| `BUILD_CERTIFICATE_BASE64`       | エンコードした証明書（`.p12.base64`）の中身                        |
| `P12_PASSWORD`                   | `.p12`ファイル作成時に設定したエクスポート用パスワード               |
| `BUILD_PROVISION_PROFILE_BASE64` | エンコードしたプロビジョニングプロファイル（`.mobileprovision.base64`）の中身 |
| `APP_STORE_APP_ID`               | App Store Connectの「App情報」で確認できるApple ID (例: `1234567890`)     |
| `TEAM_ID`                        | Apple Developerサイトの「メンバーシップの詳細」で確認できるチームID        |

---

## Step 2: iOSリリース用のワークフローを記述

`.github/workflows/ios_release.yml` というファイルを作成します。Androidと同様、Gitタグをトリガーにするのが一般的です。

```yaml
# .github/workflows/ios_release.yml
name: iOS Release & Deploy to TestFlight

on:
  push:
    tags:
      - 'v*.*.*' # Androidと同じタグをトリガーにするか、-iosを付けるかはお好みで

jobs:
  build-and-deploy:
    runs-on: macos-latest # iOSビルドにはmacOS環境が必須

    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: 'stable' }
      - run: flutter pub get

      - name: Import Code-Signing Certificates
        uses: apple-actions/import-codesign-certs@v3
        with:
          p12-file-base64: ${{ secrets.BUILD_CERTIFICATE_BASE64 }}
          p12-password: ${{ secrets.P12_PASSWORD }}
          provisioning-profile-base64: ${{ secrets.BUILD_PROVISION_PROFILE_BASE64 }}

      - name: Build and sign IPA
        run: flutter build ipa --release --export-options-plist=ios/ExportOptions.plist

      - name: Deploy to TestFlight
        uses: apple-actions/upload-testflight-build@v2
        with:
          app-apple-id: ${{ secrets.APP_STORE_APP_ID }}
          team-id: ${{ secrets.TEAM_ID }}
          issuer-id: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          api-key-id: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          api-private-key: ${{ secrets.APP_STORE_CONNECT_PRIVATE_KEY }}
          build-path: build/ios/ipa/*.ipa

      - name: Clean up keychain and provisioning profile
        if: ${{ always() }} # 常に実行される
        run: |
          security delete-keychain "temporary_keychain"
          rm -f ~/Library/MobileDevice/Provisioning\ Profiles/*.mobileprovision
```
> **注意:** `ExportOptions.plist`は、`flutter build ipa`コマンドの挙動を制御する設定ファイルです。Xcodeで一度手動でアーカイブし、アドホック（Ad Hoc）配布などで書き出した際に生成されるものを、プロジェクトの`ios/`ディレクトリに含めておくと確実です。

## Step 3: ワークフローの実行

Androidと同様に、リリースしたいバージョンタグをプッシュします。

```bash
git tag v1.0.2
git push origin v1.0.2
```

このプッシュをトリガーに、GitHub ActionsがmacOS環境で起動し、iOSアプリのビルド、署名、そしてTestFlightへのアップロードまでを全自動で行います。成功すれば、数十分後にはテスターに新しいビルドを配布する準備が整います。