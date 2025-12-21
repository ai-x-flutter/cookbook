# レシピ#3-10: Xcode Cloudで実現するiOSアプリの完全自動ビルド

GitHub ActionsでiOSのCI/CDを実現する方法を学びましたが、Appleは公式のCI/CDサービス**Xcode Cloud**も提供しています。

このレシピでは、Appleが提供する**Xcode Cloud**を使って、iOSアプリのビルド、テスト、TestFlightへの配布までを自動化する方法を学びます。GitHub Actionsと違い、Xcode統合で設定でき、Appleのエコシステムとの相性が抜群です。

> **参考:** このレシピは[Flutter公式ドキュメントのXcode Cloudガイド](https://docs.flutter.dev/deployment/cd#xcode-cloud)に基づいています。

## Xcode Cloudとは？

**Xcode Cloud**は、Appleが提供するクラウドベースの継続的インテグレーション・継続的デリバリー（CI/CD）サービスです。Xcodeに直接統合されており、コードのビルド、テスト、配布を自動化できます。

### Xcode Cloudのメリット

*   **Appleエコシステムとの完全統合:** 証明書やプロビジョニングプロファイルの管理が自動化され、App Store ConnectやTestFlightとシームレスに連携します。
*   **macOS環境が不要:** Appleのクラウドインフラでビルドが行われるため、ローカルにMacがなくてもiOSアプリの自動ビルドが可能です。
*   **Xcodeから直接設定:** ワークフローの設定がXcodeのGUIから行え、YAMLファイルを書く必要がありません。
*   **無料枠あり:** 月25時間の無料ビルド時間が提供されており、小規模プロジェクトなら無料で運用できます。（それ以降は従量課金）

### GitHub Actionsとの違い

| 特徴 | Xcode Cloud | GitHub Actions |
|------|-------------|----------------|
| 設定方法 | XcodeのGUIから設定 | YAMLファイルで記述 |
| 証明書管理 | 自動管理 | 手動でSecretsに登録 |
| 料金 | 月25時間無料、以降従量課金 | パブリックリポジトリは無料、プライベートは制限あり |
| 柔軟性 | iOSに特化 | あらゆるプラットフォームに対応 |
| 統合 | App Store Connect統合 | サードパーティツール経由 |

---

## 前提条件

Xcode Cloudを使用するには、以下が必要です。

*   **Apple Developer Program**への登録（年間99ドル）
*   **Xcode 13以降**がインストールされたMac
*   **App Store Connect**へのアクセス権（管理者、App Manager、またはDeveloper権限）
*   **GitHubリポジトリ**（またはGitLab、Bitbucket）に管理されているFlutterプロジェクト

---

## Step 1: Xcode CloudとGitHubリポジトリの接続

### 1-1. プロジェクトをXcodeで開く

FlutterプロジェクトのiOSワークスペースをXcodeで開きます。

```bash
cd your_flutter_project
open ios/Runner.xcworkspace
```

### 1-2. Xcode Cloudの有効化

1.  Xcodeのメニューバーから `Product > Xcode Cloud > Create Workflow...` を選択します。
2.  初めて使用する場合、App Store Connectへのサインインを求められます。Apple IDでサインインします。
3.  「Start Building」ダイアログが表示されます。`Next`をクリックして進みます。

### 1-3. GitHubリポジトリとの接続

1.  ソースコードの場所を聞かれたら、`GitHub`を選択します。
2.  GitHubアカウントへのアクセスを許可します。Xcodeが初めてGitHubに接続する場合、認証画面が表示されます。
3.  接続するリポジトリを選択します。
4.  Xcode Cloudが使用するブランチ（通常は`main`または`develop`）を選択します。

---

## Step 2: ワークフローの設定

Xcode Cloudでは、**ワークフロー**という単位でビルドやテストの自動化を定義します。

### 2-1. 初期ワークフローの確認

接続が完了すると、Xcodeが自動的にデフォルトのワークフローを作成します。

1.  Xcodeのナビゲーターエリアで `Report Navigator`（時計アイコン）を開きます。
2.  上部のタブから `Cloud` を選択します。
3.  `Manage Workflows...`をクリックします。

### 2-2. ワークフローの編集

ワークフローの詳細を編集して、ビルド条件や配布設定をカスタマイズします。

1.  作成されたワークフローをクリックし、`Edit Workflow`を選択します。
2.  以下の項目を設定します。

#### 環境（Environment）

*   **Xcode Version:** 最新の安定版を選択します（例：Xcode 15.x）。
*   **macOS Version:** Xcodeに対応したmacOSバージョンが自動選択されます。
*   **Environment Variables:** 必要に応じて環境変数を追加できます。Flutterの場合は通常不要です。

#### ビルド条件（Start Conditions）

ビルドをトリガーする条件を設定します。

*   **Branch Changes:** 特定のブランチ（例：`main`）にコミットがプッシュされた時
*   **Pull Request Changes:** プルリクエストが作成または更新された時
*   **Tag Changes:** Gitタグがプッシュされた時（リリース専用ワークフローに便利）
*   **Schedule:** 定期的に実行（例：毎晩のビルド）

例えば、リリース用ワークフローでは以下のように設定します。

*   **Branch or Tag:** `Tag Changes`を選択
*   **Tag Pattern:** `v*.*.*` （例：`v1.0.0`形式のタグ）

#### ビルドアクション（Actions）

Xcode Cloudが実行するアクションを定義します。

*   **Archive:** リリース用のアーカイブを作成します。これを選択すると、ビルド後にTestFlightに自動配布できます。
    *   **Platform:** `iOS`を選択
    *   **Scheme:** `Runner`（Flutterプロジェクトのデフォルト）
    *   **Deployment Preparation:** `TestFlight and App Store`を選択
*   **Test:** ユニットテストやUIテストを実行します（オプション）。
*   **Analyze:** 静的解析を実行します（オプション）。

#### 配布後の処理（Post-Actions）

ビルド成功後に実行されるアクションを設定します。

*   **TestFlight Internal Testing:** 内部テスターグループに自動配布
*   **TestFlight External Testing:** 外部テスターグループに自動配布（App Reviewが必要）
*   **Notify:** Slackやメールで通知（オプション）

### 2-3. Flutterビルドコマンドのカスタマイズ

Xcode CloudはFlutterプロジェクトを直接認識しませんが、**カスタムビルドスクリプト**を使ってFlutterのビルドプロセスを組み込むことができます。

`ios/ci_scripts` ディレクトリを作成し、その中に `ci_post_clone.sh` スクリプトを配置します。このスクリプトは、Xcode Cloudがリポジトリをクローンした後に自動的に実行されます。

```bash
mkdir -p ios/ci_scripts
```

`ios/ci_scripts/ci_post_clone.sh` ファイルを作成し、以下の内容を記述します。

```bash
#!/bin/sh

# デフォルトでは、このスクリプトの実行ディレクトリはci_scriptsディレクトリです
# CI_WORKSPACEは、クローンされたリポジトリのディレクトリです
echo "🟩 Navigate from ($PWD) to ($CI_WORKSPACE)"
cd $CI_WORKSPACE

echo "🟩 Install Flutter"
time git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

echo "🟩 Flutter Precache"
time flutter precache --ios

echo "🟩 Install Flutter Dependencies"
time flutter pub get

echo "🟩 Install CocoaPods via Homebrew"
time HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods

echo "🟩 Install CocoaPods dependencies..."
time cd ios && pod install

exit 0
```

> **注意:** このスクリプトは、ビルド時間に約10分追加されます。

スクリプトに実行権限を付与してコミット・プッシュします。

```bash
git add ios/ci_scripts/ci_post_clone.sh --chmod=+x
git commit -m "Add Xcode Cloud build script for Flutter"
git push
```

---

## Step 3: ワークフローの実行とモニタリング

### 3-1. 手動でビルドを開始

設定が完了したら、手動でビルドをトリガーしてテストします。

1.  Xcodeの `Report Navigator > Cloud`タブに戻ります。
2.  ワークフローを選択し、`Start Build`をクリックします。
3.  ビルドが開始され、進行状況がXcodeにリアルタイムで表示されます。

### 3-2. App Store Connectでの確認

ビルドが完了すると、[App Store Connect](https://appstoreconnect.apple.com/)の以下の場所で確認できます。

*   **TestFlight:** ビルドが自動的にアップロードされ、テスターに配布できます。
*   **Xcode Cloud:** ビルドログ、テスト結果、配布状態を確認できます。

### 3-3. 自動ビルドのトリガー

設定したトリガー条件（ブランチへのプッシュ、タグのプッシュなど）に従って、Xcode Cloudが自動的にビルドを開始します。

例えば、リリース用ワークフローをタグで設定した場合：

```bash
git tag v1.0.0
git push origin v1.0.0
```

このタグプッシュをトリガーに、Xcode Cloudがビルドを開始し、成功すればTestFlightに自動配布されます。

---

## Step 4: 証明書とプロビジョニングプロファイルの管理

Xcode Cloudの大きなメリットの一つが、**証明書とプロビジョニングプロファイルの自動管理**です。

### 自動管理の仕組み

*   Xcode Cloudは、ビルド時に必要な証明書とプロビジョニングプロファイルを自動的に生成または更新します。
*   これらは**Appleの管理下**に置かれ、GitHub Secretsのように手動で登録する必要はありません。
*   証明書の有効期限が近づくと、自動的に更新されます。

### 手動管理が必要な場合

特定の証明書を使用する必要がある場合（例：企業向け配布用の証明書）は、App Store Connectから手動で設定できます。

1.  [App Store Connect](https://appstoreconnect.apple.com/)にアクセスします。
2.  `Xcode Cloud`セクションに移動します。
3.  `Settings > Code Signing`で、使用する証明書とプロファイルを指定します。

---

## Step 5: 料金とビルド時間の管理

Xcode Cloudは従量課金制ですが、無料枠があります。

### 料金プラン

*   **無料枠:** 月25時間のビルド時間
*   **有料プラン:** 25時間超過後、追加の1時間あたり約$0.95（プランによって異なる）

### ビルド時間の最適化

*   **依存関係のキャッシュ:** Flutterの依存関係やCocoaPodsのキャッシュを活用することで、ビルド時間を短縮できます。
*   **不要なビルドを避ける:** ドキュメントの変更など、コードに影響しないコミットではビルドをスキップするように条件を設定します。

```bash
# ci_post_clone.shでドキュメント変更時にスキップする例
if git diff --name-only HEAD~1 HEAD | grep -qvE '\.(dart|yaml|swift|m)$'; then
    echo "No code changes detected, skipping build"
    exit 0
fi
```

### ビルド使用状況の確認

App Store Connectの`Xcode Cloud > Usage`セクションで、月間のビルド時間や料金を確認できます。

---

## まとめ

Xcode Cloudを使うことで、以下が実現できました。

✅ GitHubへのプッシュやタグで自動的にiOSアプリをビルド
✅ 証明書とプロビジョニングプロファイルの自動管理
✅ TestFlightへの自動配布で、テスターにすぐに新しいビルドを届けられる
✅ XcodeのGUIから直接設定でき、YAMLファイルを書く必要がない

Xcode CloudはAppleエコシステムとの統合に優れており、特にiOS専用のプロジェクトや、証明書管理の複雑さを避けたい場合に最適です。

一方、AndroidとiOSを同じCI/CDで管理したい場合や、より高度なカスタマイズが必要な場合は、GitHub Actionsの方が適している場合もあります。プロジェクトのニーズに応じて、最適なCI/CDツールを選択しましょう！

---

## 参考リンク

*   [Flutter公式ドキュメント - Continuous delivery with Flutter](https://docs.flutter.dev/deployment/cd#xcode-cloud)
*   [Apple Developer - Xcode Cloud](https://developer.apple.com/xcode-cloud/)
