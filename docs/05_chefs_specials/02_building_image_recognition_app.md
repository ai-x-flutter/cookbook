# ケーススタディ#5-2: 画像認識カメラアプリを作る - ML Kit / TFLite活用

## このケーススタディで作るもの

**Cursor + Claude**を使って、スマホのカメラで撮影した画像をAIが認識する実用的なアプリを作ります。

**機能:**
- ✅ カメラで写真撮影
- ✅ ギャラリーから画像選択
- ✅ AI画像認識（物体検出・ラベル付け）
- ✅ 認識結果の表示
- ✅ 結果の保存・共有

**技術スタック:**
- Flutter 3.27+
- camera パッケージ（カメラ機能）
- image_picker（ギャラリー選択）
- google_mlkit_image_labeling（ML Kit）または tflite_flutter（TFLite）
- StatefulWidget（状態管理）

**避けるもの:**
- ❌ Riverpod
- ❌ BLoC
- ❌ 複雑な状態管理ライブラリ

## 完成イメージ

```
┌─────────────────────────┐
│  AI Vision App          │
├─────────────────────────┤
│                         │
│   📷 [撮影した画像]    │
│                         │
│   🤖 認識結果:         │
│   • 🐕 犬 (95%)       │
│   • 🌳 木 (87%)       │
│   • 🏞️ 公園 (76%)     │
│                         │
│  [📷 カメラ] [🖼️ ギャラリー]│
│  [💾 保存]   [🔄 再認識] │
│                         │
└─────────────────────────┘
```

## Step 1: AI画像認識の選択

### Option A: Google ML Kit（推奨 - 初心者向け）

**特徴:**
- ✅ Googleの公式ライブラリ
- ✅ セットアップが簡単
- ✅ オンデバイスで動作（インターネット不要）
- ✅ 無料
- ✅ 物体検出、顔認識、テキスト認識など多機能

**制限:**
- モデルのカスタマイズ不可

### Option B: TFLite（上級者向け）

**特徴:**
- ✅ カスタムモデルを使用可能
- ✅ より高精度な認識
- ✅ 独自データで学習したモデルを使える

**制限:**
- セットアップが複雑
- モデルファイルの準備が必要

**このケーススタディでは、ML Kitを使用します。**

## Step 2: プロジェクト作成

```bash
flutter create ai_vision_app
cd ai_vision_app
cursor .
```

### 依存関係を追加

**Cursorで以下をリクエスト:**

```
pubspec.yamlに以下の依存関係を追加してください：

- camera: ^0.10.5+5（カメラ機能）
- image_picker: ^1.0.5（ギャラリー選択）
- google_mlkit_image_labeling: ^0.10.0（ML Kit画像認識）
- path_provider: ^2.1.1（ファイルパス取得）
- path: ^1.8.3（パス操作）
```

### プラットフォーム設定

**Android (android/app/src/main/AndroidManifest.xml):**

**Cursorで以下をリクエスト:**

```
AndroidManifest.xmlに以下のパーミッションを追加してください：

<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**iOS (ios/Runner/Info.plist):**

**Cursorで以下をリクエスト:**

```
Info.plistに以下のキーを追加してください：

<key>NSCameraUsageDescription</key>
<string>カメラで写真を撮影するために使用します</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>ギャラリーから画像を選択するために使用します</string>
```

## Step 3: データモデルの設計

**Cursorで以下をリクエスト:**

```
lib/models/recognition_result.dartを作成してください。

クラス名: RecognitionResult
フィールド:
- label: String（認識されたラベル名）
- confidence: double（信頼度 0.0〜1.0）
- timestamp: DateTime（認識時刻）

メソッド:
- toJson() / fromJson()
- copyWith()
- confidencePercentage（信頼度をパーセント表示）
```

## Step 4: ML Kit Serviceクラスの実装

**Cursorで以下をリクエスト:**

```
lib/services/ml_kit_service.dartを作成してください。

仕様:
- シングルトンパターン
- google_mlkit_image_labelingを使用
- 画像からラベルを検出

メソッド:
Future<List<RecognitionResult>> recognizeImage(String imagePath)
  - 引数: 画像ファイルのパス
  - 戻り値: 認識結果のリスト
  - 処理:
    1. InputImageを作成
    2. ImageLabelerで画像を解析
    3. 結果をRecognitionResultに変換
    4. 信頼度でソート（降順）
  - エラーハンドリング

初期化とクリーンアップ:
- initialize(): ImageLabelerの初期化
- dispose(): リソースの解放
```

## Step 5: カメラ撮影画面の実装

**Cursorで以下をリクエスト:**

```
lib/screens/camera_screen.dartを作成してください。

仕様:
- StatefulWidgetを使用
- cameraパッケージでカメラプレビュー表示
- 撮影ボタンで写真を撮影
- 撮影後、結果画面に遷移

状態:
- CameraController _controller
- bool _isCameraInitialized（初期化完了フラグ）

ライフサイクル:
- initState(): カメラ初期化
- dispose(): カメラリソース解放

UI:
- CameraPreview（カメラプレビュー）
- FloatingActionButton（撮影ボタン）
- 撮影後、画像パスを結果画面に渡す
```

## Step 6: 画像認識結果画面の実装

**Cursorで以下をリクエスト:**

```
lib/screens/result_screen.dartを作成してください。

仕様:
- StatefulWidgetを使用
- 撮影またはギャラリーから選択した画像を表示
- ML Kitで画像認識を実行
- 認識結果をリスト表示

引数:
- String imagePath（画像ファイルパス）
- ImageSource source（カメラ or ギャラリー）

状態:
- List<RecognitionResult> _results
- bool _isLoading（認識中フラグ）

UI:
- 画像表示（Image.file）
- 認識結果リスト（ListView.builder）
  - ラベル名
  - 信頼度（プログレスバー）
  - アイコン
- ローディングインジケーター
- 再認識ボタン
- 保存ボタン

処理フロー:
1. initStateで画像認識を実行
2. 結果を_resultsに保存
3. UIに表示
```

## Step 7: メイン画面の実装

**Cursorで以下をリクエスト:**

```
lib/screens/home_screen.dartを作成してください。

仕様:
- Scaffoldベース
- AppBarに「AI Vision」タイトル
- 2つの大きなボタン:
  1. カメラで撮影
  2. ギャラリーから選択
- それぞれのボタンを押すと対応する処理を実行

カメラボタン:
- CameraScreenに遷移
- 撮影後、ResultScreenに遷移

ギャラリーボタン:
- ImagePickerで画像選択
- 選択後、ResultScreenに遷移

UI:
- Material Designのカード
- アイコンと説明文
- スタイリッシュなレイアウト
```

## Step 8: 実装例（認識処理の核心部分）

```dart
// lib/services/ml_kit_service.dart の例
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class MLKitService {
  static final MLKitService instance = MLKitService._();
  MLKitService._();

  ImageLabeler? _labeler;

  Future<void> initialize() async {
    final options = ImageLabelerOptions(
      confidenceThreshold: 0.5, // 信頼度50%以上のみ
    );
    _labeler = ImageLabeler(options: options);
  }

  Future<List<RecognitionResult>> recognizeImage(String imagePath) async {
    if (_labeler == null) {
      await initialize();
    }

    final inputImage = InputImage.fromFilePath(imagePath);
    final labels = await _labeler!.processImage(inputImage);

    return labels
        .map((label) => RecognitionResult(
              label: label.label,
              confidence: label.confidence,
              timestamp: DateTime.now(),
            ))
        .toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  void dispose() {
    _labeler?.close();
  }
}
```

## Step 9: 実行とテスト

```bash
# 実機で実行（カメラはエミュレータでは動作しません）
flutter run
```

**テストシナリオ:**
1. カメラで犬、猫、車などを撮影
2. 認識結果が正しく表示されるか確認
3. ギャラリーから画像を選択
4. 信頼度が高い順に表示されるか確認
5. エラーハンドリングが機能するか確認

## Step 10: 機能拡張

### 拡張1: 認識結果の保存

**Cursorで以下をリクエスト:**

```
SharedPreferencesを使って、認識履歴を保存してください。
過去に認識した画像と結果を履歴画面で閲覧できるようにしてください。
```

### 拡張2: 物体検出（バウンディングボックス）

**Cursorで以下をリクエスト:**

```
google_mlkit_object_detectionを追加して、
画像内の物体を四角で囲んで表示してください。
CustomPainterを使って描画してください。
```

### 拡張3: テキスト認識（OCR）

**Cursorで以下をリクエスト:**

```
google_mlkit_text_recognitionを追加して、
画像内のテキストを読み取る機能を追加してください。
読み取ったテキストをコピー可能にしてください。
```

### 拡張4: リアルタイム認識

**Cursorで以下をリクエスト:**

```
CameraControllerのstartImageStreamを使って、
カメラプレビュー中にリアルタイムで物体を認識してください。
認識結果をプレビュー上にオーバーレイ表示してください。
```

## よくある問題と解決策

### 問題1: カメラが初期化されない

**原因:** パーミッションが許可されていない

**解決策:**
```dart
// 実機でアプリを削除して再インストール
// または設定でパーミッションを確認
```

### 問題2: ML Kitのエラー

**原因:** モデルのダウンロードに失敗

**解決策:**
- インターネット接続を確認
- 初回起動時にモデルがダウンロードされる
- Google Play開発者サービスが最新か確認（Android）

### 問題3: 画像認識の精度が低い

**原因:** 画像の品質や照明条件

**解決策:**
```dart
// confidenceThresholdを調整
final options = ImageLabelerOptions(
  confidenceThreshold: 0.7, // 70%以上に引き上げ
);
```

### 問題4: メモリリーク

**原因:** カメラやML Kitのリソースを解放していない

**解決策:**
```dart
@override
void dispose() {
  _controller?.dispose();
  MLKitService.instance.dispose();
  super.dispose();
}
```

## まとめ

このケーススタディで学んだこと：

✅ **カメラ機能:** Flutter でのカメラ制御
✅ **画像処理:** ML Kitを使った画像認識
✅ **リソース管理:** カメラ・ML Kitのライフサイクル管理
✅ **パーミッション:** Android/iOSのパーミッション設定
✅ **リアルタイム処理:** ストリーミング画像の処理

**次のステップ:**
- カスタムTFLiteモデルの使用
- 顔認識機能の追加
- AR（拡張現実）との統合

---

**完成版コードは、[examples/ai_vision_app](../../examples/ai_vision_app/)を参照してください。**
