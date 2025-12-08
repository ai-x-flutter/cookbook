# レシピ#1-4: iOS開発の準備とセットアップ

日本ではiPhoneのシェアが高く、iOS向けのアプリ開発は非常に重要です。このレシピでは、FlutterでiOSアプリを開発・テストするための環境構築手順を解説します。

**このレシピで学ぶこと：**
- Apple IDの作成とAppleアカウントの準備
- Xcodeの基本設定
- iOS Simulatorの使い方
- 実機でのテスト方法
- Apple Developer Programについて

---

## 前提条件

iOS開発には**macOS**が必要です。WindowsやLinuxでは、iOS Simulatorや実機でのテストができません。

**必要な環境：**
- macOS 12.0以降
- Xcode 14.0以降（既に#1-1でインストール済み）
- Apple ID（無料）

---

## Step 1: Apple IDの作成

iOS開発には、無料のApple IDが必要です。

### 1-1. Apple IDを持っていない場合

1. [Apple IDの作成ページ](https://appleid.apple.com/account)にアクセス
2. 「Apple IDを作成」をクリック
3. 必要事項を入力：
   - 氏名
   - 生年月日
   - メールアドレス（これがApple IDになります）
   - パスワード
   - セキュリティ質問

4. メール認証を完了

### 1-2. 既にApple IDを持っている場合

iPhoneやMacで使用しているApple IDをそのまま使用できます。

---

## Step 2: Xcodeの初期設定

Xcodeは既に#1-1でインストールされていますが、初回起動時の設定が必要です。

### 2-1. Xcodeを起動

```bash
# Xcodeを起動
open -a Xcode
```

初回起動時：
1. 利用規約に同意
2. 追加コンポーネントのインストールが開始される（数分かかります）
3. 完了を待つ

### 2-2. Apple IDをXcodeに登録

1. Xcodeのメニューから **Xcode > Settings...** を選択
2. **Accounts** タブを開く
3. 左下の **+** ボタンをクリック
4. **Apple ID** を選択
5. Apple IDとパスワードを入力
6. サインイン完了

これで、Xcodeで無料のiOS開発ができるようになりました。

---

## Step 3: iOS Simulatorの使い方

iOS Simulatorは、Mac上でiPhoneやiPadをエミュレートして、アプリをテストできます。

### 3-1. Simulatorの起動

```bash
# Simulatorを起動
open -a Simulator
```

または、Xcodeから：
1. Xcode > Open Developer Tool > Simulator

### 3-2. 使用可能なSimulatorを確認

```bash
# インストール済みのSimulatorを表示
xcrun simctl list devices
```

**出力例：**
```
== Devices ==
-- iOS 17.0 --
    iPhone 15 (XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX) (Shutdown)
    iPhone 15 Pro (YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY) (Shutdown)
    iPad Pro (11-inch) (ZZZZZZZZ-ZZZZ-ZZZZ-ZZZZ-ZZZZZZZZZZZZ) (Shutdown)
```

### 3-3. FlutterアプリをSimulatorで実行

**方法1: コマンドラインから**

```bash
# プロジェクトディレクトリに移動
cd ~/Development/ai-x-flutter/my_first_app

# Simulatorが起動していることを確認
flutter devices

# Simulatorで実行
flutter run
```

**方法2: Cursorから**

Cursorの内蔵ターミナルで：
```bash
flutter run
```

**動作確認：**
- Simulatorが自動的に起動します
- カウンターアプリが表示されます
- 「+」ボタンを押して動作確認

### 3-4. Simulatorのデバイスを変更

Simulatorのメニューから：
1. **File > Open Simulator > iOS 17.0 > [デバイス名]**
2. 例：iPhone 15 Pro、iPad Proなど

または、コマンドラインで：
```bash
# 特定のSimulatorで起動
flutter run -d "iPhone 15 Pro"
```

---

## Step 4: 実機でのテスト（無料アカウント）

無料のApple IDでも、実機テストが可能です（ただし制限あり）。

### 4-1. iPhoneをMacに接続

1. iPhoneをUSBケーブルでMacに接続
2. iPhone側で「このコンピュータを信頼しますか？」→ **信頼**
3. パスコードを入力

### 4-2. デバイスの確認

```bash
flutter devices
```

**出力例：**
```
3 connected devices:

iPhone 15 Pro (mobile) • 00008110-XXXXXXXXXXXX • ios • iOS 17.0
iPhone 15 (simulator)  • YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY • ios
```

### 4-3. Flutterプロジェクトの設定

iOSプロジェクトを開く：
```bash
cd ~/Development/ai-x-flutter/my_first_app
open ios/Runner.xcworkspace
```

Xcodeで：
1. 左のナビゲータで **Runner** を選択
2. **Signing & Capabilities** タブを開く
3. **Team** で自分のApple IDを選択
4. **Bundle Identifier** が自動的に設定される
   - 形式：`com.[あなたのAppleID].myFirstApp`

### 4-4. 実機で実行

```bash
# 実機で実行
flutter run
```

または、デバイスを指定：
```bash
flutter run -d 00008110-XXXXXXXXXXXX
```

### 4-5. iPhoneで信頼する

初回実行時、iPhone側で以下の操作が必要：

1. 「信頼されていない開発元」のエラーが表示される
2. iPhone: **設定 > 一般 > VPNとデバイス管理**
3. 開発元アプリ欄で自分のApple IDを選択
4. **"[Apple ID]"を信頼** をタップ
5. 確認ダイアログで **信頼** をタップ

6. アプリを再実行：
```bash
flutter run
```

---

## Step 5: Apple Developer Programについて

### 5-1. 無料アカウントの制限

無料のApple IDでできること：
✅ iOS Simulatorでのテスト
✅ 実機でのテスト（7日間の署名有効期限）
✅ 開発とデバッグ

無料アカウントでできないこと：
❌ App Storeへの公開
❌ TestFlightでのベータ配信
❌ プッシュ通知などの一部機能
❌ 複数デバイスでの長期テスト

### 5-2. Apple Developer Program（有料）

**App Storeに公開する場合に必要：**

- **費用：** 年間 ¥12,980（約$99）
- **メリット：**
  - App Storeへの公開
  - TestFlightでのベータテスト
  - すべてのiOS機能へのアクセス
  - 署名期限なし

**登録方法：**
1. [Apple Developer Program](https://developer.apple.com/programs/)にアクセス
2. Apple IDでサインイン
3. 「Enroll」をクリック
4. 個人または組織を選択
5. 支払い情報を入力
6. 審査完了まで数日待つ

**注意：** 学習段階では無料アカウントで十分です。App Storeに公開する準備ができた時点で登録しましょう。

---

## Step 6: トラブルシューティング

### 問題1: "iPhone is busy: Preparing debugger support for iPhone"

**原因：** iPhoneがデバッグシンボルを準備中

**対処法：**
```bash
# Xcodeを開いて待つ
open -a Xcode

# Window > Devices and Simulators
# デバイスの準備が完了するまで待つ（数分）
```

### 問題2: "Signing for "Runner" requires a development team"

**原因：** Apple IDが設定されていない

**対処法：**
1. `ios/Runner.xcworkspace` をXcodeで開く
2. Signing & Capabilities > Team で Apple IDを選択

### 問題3: "The application could not be verified"

**原因：** iPhoneで開発元を信頼していない

**対処法：**
iPhone: **設定 > 一般 > VPNとデバイス管理** で信頼

### 問題4: CocoaPodsのエラー

**症状：**
```
Error running pod install
```

**対処法：**
```bash
# CocoaPodsを再インストール
cd ios
pod repo update
pod install
cd ..

# 再実行
flutter run
```

### 問題5: Xcodeバージョンが古い

**症状：**
```
Xcode 14.0 or greater is required
```

**対処法：**
```bash
# App StoreからXcodeを更新
# または
# https://developer.apple.com/xcode/
```

---

## Step 7: AIにiOS開発を手伝ってもらう

### CursorでiOS固有の問題を解決

**例1: iOS特有のエラー**

Cursor Chat（Ctrl+L）で：
```
以下のiOSビルドエラーが出ています。修正方法を教えてください：

[エラーメッセージをペースト]
```

**例2: Info.plistの編集**

```
@ios/Runner/Info.plist を編集して、
カメラパーミッションの設定を追加してください。
```

**例3: iOS固有のUI調整**

```
このウィジェットをiOS（Cupertino）スタイルにしてください。
```

---

## まとめ

これで、iOS開発の準備が整いました！

**できるようになったこと：**
✅ Apple IDでXcodeにサインイン
✅ iOS Simulatorでアプリをテスト
✅ 実機（iPhone）でアプリをテスト
✅ iOS固有の問題を理解

**重要なポイント：**
- **無料アカウントで開発とテストは十分可能**
- **App Store公開時にApple Developer Program（有料）が必要**
- **7日ごとに実機アプリの署名が必要（無料アカウント）**
- **iOS Simulatorは完全無料で使い放題**

### 次のステップ

iOS開発環境が整ったので、次はアプリのIDとアセット（アイコン、名前など）を設定しましょう。

➡️ **次のレシピへ:** [#1-5: アプリのIDとアセットの準備](./04_project_identity_and_assets.md)

---

## 参考リンク

- [Apple Developer](https://developer.apple.com/)
- [Xcode公式ドキュメント](https://developer.apple.com/xcode/)
- [Flutter iOS開発ガイド](https://docs.flutter.dev/get-started/install/macos#ios-setup)
- [CocoaPods公式サイト](https://cocoapods.org/)
