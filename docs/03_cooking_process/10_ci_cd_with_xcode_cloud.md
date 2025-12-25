# レシピ#3-10: Xcode Cloudで実現するiOSアプリの完全自動ビルド

GitHub ActionsでiOSのCI/CDを実現する方法を学びましたが、Appleは公式のCI/CDサービス**Xcode Cloud**も提供しています。

このレシピでは、Appleが提供する**Xcode Cloud**を使って、iOSアプリのビルド、テスト、TestFlightへの配布までを自動化する方法を学びます。GitHub Actionsと違い、Xcode統合で設定でき、Appleのエコシステムとの相性が抜群です。

> **参考:** このレシピは[Flutter公式ドキュメントのXcode Cloudガイド](https://docs.flutter.dev/deployment/cd#xcode-cloud)に基づいています。

**重要な公式ドキュメント**:
- [Configuring Xcode Cloud for your team](https://developer.apple.com/documentation/xcode/configuring-xcode-cloud-for-your-team) - **必読**
- [Requirements for using Xcode Cloud](https://developer.apple.com/documentation/xcode/requirements-for-using-xcode-cloud)

---

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

## 必要なアカウントと権限

### Apple 関連

**注意**: **App Store Connect** と **Apple Developer Program** は別々のシステムです。両方でアクセス権が必要です。

| サービス | 役割 | 必要な権限・条件 |
|---------|------|-----------------|
| Apple Developer Program | - | メンバーシップ登録必須（年額 $99） |
| App Store Connect | Account Holder | 全権限。契約締結、メンバーシップ更新が可能 |
| App Store Connect | Admin | ワークフロー作成、アプリ登録、ユーザー管理が可能 |
| App Store Connect | App Manager | アプリ登録、TestFlight 管理が可能 |
| App Store Connect | Developer | Create Apps permission があればアプリ登録可能 |
| App Store Connect | Marketing | Create Apps permission があればアプリ登録可能 |

### Xcode Cloud ワークフロー作成に必要な権限

公式ドキュメント（[Get started with Xcode Cloud](https://developer.apple.com/xcode-cloud/get-started/)）より:

> ワークフローの設定は、Account Holder、Admin、または App Manager が行えます。また、App Store Connect で **Create Apps permission** を付与された Developer または Marketing 役割のチームメンバーも設定可能です。

### Individual vs Organization の違い

| 登録タイプ | チームメンバー追加 | アプリ配布可能な役割 |
|-----------|------------------|---------------------|
| Individual | App Store Connect のみ（Developer Program には追加不可） | Account Holder のみ |
| Organization | Developer Program に追加可能 | Account Holder, Admin, App Manager |

**注意**: Individual 登録の場合、他のメンバーを Xcode のチームに追加できません。チーム開発が必要な場合は Organization への変更を検討してください。

**公式ドキュメント**:
- [Role Permissions](https://developer.apple.com/help/app-store-connect/reference/role-permissions/)
- [Apple Developer Program Roles](https://developer.apple.com/support/roles/)

### GitHub / ソースコード管理

| 権限 | Xcode Cloud 初期設定 | コード Push | ビルド結果閲覧 |
|------|---------------------|------------|--------------|
| Admin | ✅ | ✅ | ✅ |
| Write | ❌ | ✅ | ✅ |
| Read | ❌ | ❌ | ✅ |

**重要**: Xcode Cloud の初期設定には **GitHub Admin 権限**が必要です。Webhook 設定と Apple との連携認証のためです。

### ソースコードアクセスの管理

App Store Connect でチームメンバーのソースコードアクセスを管理できます：

**App Store Connect → Users and Access → Xcode Cloud タブ**

ここで各メンバーに対して：
- どのリポジトリにアクセスできるか
- ビルドの閲覧・実行権限

を設定できます。

**公式ドキュメント**: [Configuring Xcode Cloud for your team](https://developer.apple.com/documentation/xcode/configuring-xcode-cloud-for-your-team)

---

## 初期設定の前提条件

### Xcode Cloud 初期設定に必要な環境

Xcode Cloud の初期ワークフロー作成は **Mac 上の Xcode から行う必要があります**。

**必要な条件**:
1. **Mac** + **Xcode 15.0 以上**（公式要件）
2. **Apple Developer Program メンバーシップ**
3. **GitHub Admin 権限**を持つアカウント（リポジトリ接続時）
4. **App Store Connect で適切な権限**:
   - Account Holder、Admin、App Manager のいずれか
   - または Developer/Marketing + Create Apps permission

**公式ドキュメント**: [Requirements for using Xcode Cloud](https://developer.apple.com/documentation/xcode/requirements-for-using-xcode-cloud)

### GitHub 管理者が Apple 開発者でない場合

公式ドキュメントより:

> リポジトリの管理者が Apple プラットフォーム開発の専門知識を持っていない場合でも、その管理者に Xcode Cloud 用のプロジェクト設定を行わせ、**最初のビルドが失敗しても問題ありません**。

つまり：
1. GitHub Admin が Mac + Xcode で初期接続のみ行う
2. 最初のビルドは失敗しても OK
3. その後、iOS 開発者がワークフローを修正

### 無料枠について

- **毎月 25 compute hours** が無料で利用可能
- compute hour = クラウドでタスク実行に使用した時間
- 追加の compute hours が必要な場合は、Account Holder がサブスクリプションを購入

---

## Step 1: App Store Connect 事前設定

### 1-1. Identifiers（App ID）登録

**Apple Developer Portal → Certificates, Identifiers & Profiles → Identifiers**

| 項目 | 設定例 |
|------|-------|
| Description | `My App` |
| Bundle ID | `com.example.myapp`（Explicit） |
| Capabilities | 必要に応じて選択（後から追加可能） |

### 1-2. アプリ登録

**App Store Connect → マイ App → 「+」→ 新規 App**

| 項目 | 設定例 |
|------|-------|
| プラットフォーム | iOS |
| 名前 | `My App` |
| プライマリ言語 | 日本語 |
| バンドル ID | 先ほど作成した App ID を選択 |
| SKU | `myapp`（内部管理用、変更不可） |

---

## Step 2: Xcode プロジェクト設定

### 2-1. プロジェクトを開く

FlutterプロジェクトのiOSワークスペースをXcodeで開きます。

```bash
cd /path/to/your/flutter/project
open ios/Runner.xcworkspace
```

**重要**: `.xcodeproj` ではなく **`.xcworkspace`** を開いてください（CocoaPods 使用のため）。

### 2-2. Signing & Capabilities 設定

**Runner** ターゲット → **Signing & Capabilities** タブ

| 項目 | 設定 |
|------|------|
| Automatically manage signing | ✅ チェック |
| Team | 自分のチームを選択 |
| Bundle Identifier | App ID と一致させる |

**全ターゲットで設定が必要**:
- Runner
- RunnerTests
- RunnerUITests

### 2-3. Info.plist の設定

使用する機能に応じて、`ios/Runner/Info.plist` に説明を追加:

```xml
<!-- カメラ使用（QRスキャンなど） -->
<key>NSCameraUsageDescription</key>
<string>QRコードをスキャンするためにカメラを使用します</string>

<!-- 写真ライブラリ読み取り -->
<key>NSPhotoLibraryUsageDescription</key>
<string>写真を選択するためにライブラリにアクセスします</string>

<!-- 写真ライブラリ保存 -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>写真を保存するためにライブラリにアクセスします</string>

<!-- 位置情報 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>現在地を取得するために位置情報を使用します</string>
```

### 2-4. Podfile の設定

`ios/Podfile` で iOS バージョンを明示的に指定:

```ruby
# コメントアウトを解除して設定
platform :ios, '13.0'
```

設定後:

```bash
cd ios
pod install --repo-update
```

---

## Step 3: Xcode CloudとGitHubリポジトリの接続

### 3-1. Xcode Cloudの有効化

1.  Xcodeのメニューバーから `Product > Xcode Cloud > Create Workflow...` を選択します。
2.  初めて使用する場合、App Store Connectへのサインインを求められます。Apple IDでサインインします。
3.  「Start Building」ダイアログが表示されます。`Next`をクリックして進みます。

### 3-2. GitHubリポジトリとの接続

1.  ソースコードの場所を聞かれたら、`GitHub`を選択します。
2.  GitHubアカウントへのアクセスを許可します。Xcodeが初めてGitHubに接続する場合、認証画面が表示されます。
3.  接続するリポジトリを選択します。
4.  Xcode Cloudが使用するブランチ（通常は`main`または`develop`）を選択します。

---

## Step 4: ワークフローの設定

Xcode Cloudでは、**ワークフロー**という単位でビルドやテストの自動化を定義します。

### 4-1. 初期ワークフローの確認

接続が完了すると、Xcodeが自動的にデフォルトのワークフローを作成します。

1.  Xcodeのナビゲーターエリアで `Report Navigator`（時計アイコン）を開きます。
2.  上部のタブから `Cloud` を選択します。
3.  `Manage Workflows...`をクリックします。

### 4-2. ワークフローの編集

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

### 4-3. Flutterビルドコマンドのカスタマイズ（CI スクリプト）

**重要**: CI スクリプトは Flutter や Xcode Cloud のアップデートにより変更される可能性があります。最新の情報は公式ドキュメントを確認してください：
- [Flutter 公式: Continuous delivery](https://docs.flutter.dev/deployment/cd) - **必ず確認**
- [Apple: Writing custom build scripts](https://developer.apple.com/documentation/xcode/writing-custom-build-scripts)

Xcode CloudはFlutterプロジェクトを直接認識しませんが、**カスタムビルドスクリプト**を使ってFlutterのビルドプロセスを組み込むことができます。

`ios/ci_scripts` ディレクトリを作成し、その中に `ci_post_clone.sh` スクリプトを配置します。このスクリプトは、Xcode Cloudがリポジトリをクローンした後に自動的に実行されます。

```bash
mkdir -p ios/ci_scripts
```

`ios/ci_scripts/ci_post_clone.sh` ファイルを作成し、以下の内容を記述します。

```bash
#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH

# ※ Flutter プロジェクトがサブディレクトリにある場合は移動
# cd frontend/myapp

# Install Flutter using git.
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

# Install CocoaPods dependencies.
cd ios && pod install

exit 0
```

> **注意:** このスクリプトは、ビルド時間に約10分追加されます。

スクリプトに実行権限を付与してコミット・プッシュします。

```bash
chmod +x ios/ci_scripts/ci_post_clone.sh
git add ios/ci_scripts/
git commit -m "Add Xcode Cloud CI script"
git push
```

---

## Step 5: ワークフローの実行とモニタリング

### 5-1. 手動でビルドを開始

設定が完了したら、手動でビルドをトリガーしてテストします。

1.  Xcodeの `Report Navigator > Cloud`タブに戻ります。
2.  ワークフローを選択し、`Start Build`をクリックします。
3.  ビルドが開始され、進行状況がXcodeにリアルタイムで表示されます。

### 5-2. App Store Connectでの確認

ビルドが完了すると、[App Store Connect](https://appstoreconnect.apple.com/)の以下の場所で確認できます。

*   **TestFlight:** ビルドが自動的にアップロードされ、テスターに配布できます。
*   **Xcode Cloud:** ビルドログ、テスト結果、配布状態を確認できます。

### 5-3. 自動ビルドのトリガー

設定したトリガー条件（ブランチへのプッシュ、タグのプッシュなど）に従って、Xcode Cloudが自動的にビルドを開始します。

例えば、リリース用ワークフローをタグで設定した場合：

```bash
git tag v1.0.0
git push origin v1.0.0
```

このタグプッシュをトリガーに、Xcode Cloudがビルドを開始し、成功すればTestFlightに自動配布されます。

---

## Step 6: 証明書とプロビジョニングプロファイルの管理

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

## Step 7: ローカルでの Archive & アップロード

Xcode Cloud を使わずに手動でアップロードする場合:

### 7-1. Archive 作成

1. デバイス選択: **Any iOS Device (arm64)**
2. **Product → Archive**

### 7-2. App Store Connect にアップロード

1. Organizer ウィンドウで Archive を選択
2. **Distribute App** をクリック
3. **TestFlight & App Store** または **TestFlight Internal Only** を選択
4. アップロード実行

### 7-3. 輸出コンプライアンス

暗号化に関する質問が表示された場合:

| アプリの状況 | 選択 |
|-------------|------|
| HTTPS 通信のみ（Firebase、API など） | 「標準的な暗号化アルゴリズム」 |
| 独自の暗号化を実装 | 「独自の暗号化アルゴリズム」 |
| 暗号化なし | 「どれでもない」 |

一般的な Flutter アプリ（Firebase、REST API 使用）は「標準的な暗号化アルゴリズム」を選択し、免除に該当します。

---

## Step 8: 料金とビルド時間の管理

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

## よくあるエラーと対処法

### Signing エラー

**エラー**: `Signing for "Runner" requires a development team`

**対処**: Xcode → Runner ターゲット → Signing & Capabilities → Team を選択

全ターゲット（Runner, RunnerTests, RunnerUITests）で設定が必要です。

### Module not found

**エラー**: `Module 'mobile_scanner' not found`

**対処**:

```bash
flutter clean
flutter pub get
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
```

Xcode で **Product → Clean Build Folder**（`Cmd + Shift + K`）後、再度 Archive。

### Info.plist エラー

**エラー**: `Missing purpose string in Info.plist`

**対処**: 使用している機能の説明を `ios/Runner/Info.plist` に追加（Step 2-3 参照）

### Xcode Cloud でプロジェクトが見つからない

**エラー**: `Expected to find project root in current working directory`

**原因**: Flutter プロジェクトがリポジトリのサブディレクトリにある

**対処**: `ci_post_clone.sh` でディレクトリを移動:

```bash
cd $CI_PRIMARY_REPOSITORY_PATH
cd frontend/myapp  # ← サブディレクトリに移動
```

### xcworkspace 変更の競合

**状況**: `pod install` 後に Xcode でダイアログが表示される

**対処**: **Use Version on disk** を選択

---

## 役割別の作業範囲

### iOS 担当者

- Xcode プロジェクト設定
- Archive 作成・アップロード
- TestFlight でのテスト管理

### GitHub 管理者（初回のみ）

- Xcode Cloud 初期設定時の認証許可
- Mac + Xcode が必要（最初のビルド失敗は OK）

### Flutter 開発者

- Flutter コードの開発
- `flutter pub get` / `flutter build ios`
- `ci_post_clone.sh` の修正

### プロジェクトマネージャー

- App Store Connect でのアプリ登録
- TestFlight テスター管理
- メタデータ・スクリーンショット管理

---

## チェックリスト

### 初期設定

- [ ] Apple Developer Program 登録済み
- [ ] App Store Connect でアプリ登録済み
- [ ] Bundle ID 登録済み
- [ ] Xcode で Signing & Capabilities 設定済み
- [ ] Info.plist に必要な説明を追加済み
- [ ] Podfile で iOS バージョン指定済み
- [ ] `ci_post_clone.sh` 作成・コミット済み

### Xcode Cloud 設定

- [ ] GitHub Admin 権限あり
- [ ] Xcode からワークフロー作成済み
- [ ] 初回ビルド成功

### TestFlight 配布

- [ ] Archive 作成成功
- [ ] App Store Connect にアップロード成功
- [ ] テスターに招待送信済み

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

### Xcode Cloud（必読）
- [Configuring Xcode Cloud for your team](https://developer.apple.com/documentation/xcode/configuring-xcode-cloud-for-your-team) - **チーム設定の公式ガイド**
- [Requirements for using Xcode Cloud](https://developer.apple.com/documentation/xcode/requirements-for-using-xcode-cloud) - 必要要件
- [Get started with Xcode Cloud](https://developer.apple.com/xcode-cloud/get-started/) - 概要と料金

### 権限・役割
- [App Store Connect Role Permissions](https://developer.apple.com/help/app-store-connect/reference/role-permissions/) - 権限一覧表
- [Apple Developer Program Roles](https://developer.apple.com/support/roles/) - 役割の詳細
- [Overview of accounts and roles](https://developer.apple.com/help/app-store-connect/manage-your-team/overview-of-accounts-and-roles/) - アカウント管理

### Flutter
- [Flutter Continuous Delivery](https://docs.flutter.dev/deployment/cd) - **CI/CD 公式ガイド（必読）**
- [Flutter iOS デプロイ](https://docs.flutter.dev/deployment/ios)
