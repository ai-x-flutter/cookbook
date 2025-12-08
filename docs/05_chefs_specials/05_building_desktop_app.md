# ケーススタディ#5-5: デスクトップアプリを作る - Windows / macOS / Linux対応

## このケーススタディで作るもの

**Cursor + Claude**を使って、Windows、macOS、Linuxで動作する本格的なデスクトップアプリを作ります。

**機能:**
- ✅ ウィンドウのカスタマイズ（サイズ、タイトル）
- ✅ ネイティブメニューバー
- ✅ ファイルピッカー（開く/保存）
- ✅ キーボードショートカット
- ✅ マウス操作に最適化されたUI
- ✅ 複数ウィンドウ対応

**技術スタック:**
- Flutter 3.27+
- window_manager（ウィンドウ制御）
- file_picker（ファイル選択）
- path_provider（ファイルパス取得）
- menubar（メニューバー）

**対応プラットフォーム:**
- 🪟 Windows 10/11
- 🍎 macOS 10.14+
- 🐧 Linux (Ubuntu, Fedora等)

## 完成イメージ

```
┌────────────────────────────────────────┐
│ File  Edit  View  Help                │ ← メニューバー
├────────────────────────────────────────┤
│ ┌────────┐                             │
│ │ サイド │  メインコンテンツエリア    │
│ │ バー   │                             │
│ │        │  デスクトップらしい         │
│ │ - Home │  広々としたレイアウト       │
│ │ - Files│                             │
│ │ - Edit │  マウス操作に最適化         │
│ │        │                             │
│ └────────┘                             │
├────────────────────────────────────────┤
│ Status: Ready                          │ ← ステータスバー
└────────────────────────────────────────┘
```

## Step 1: デスクトップサポートの有効化

### 既存プロジェクトでデスクトップを有効にする

```bash
# Windows
flutter config --enable-windows-desktop
flutter create --platforms=windows .

# macOS
flutter config --enable-macos-desktop
flutter create --platforms=macos .

# Linux
flutter config --enable-linux-desktop
flutter create --platforms=linux .

# または全プラットフォームを一度に
flutter create --platforms=windows,macos,linux .
```

### プロジェクト構造の確認

```
my_desktop_app/
├── lib/
├── windows/      ← Windowsネイティブコード
├── macos/        ← macOSネイティブコード
├── linux/        ← Linuxネイティブコード
└── pubspec.yaml
```

## Step 2: ウィンドウマネージャーのセットアップ

### 依存関係の追加

**Cursorに以下をリクエスト:**

```
pubspec.yamlに以下のパッケージを追加してください：
- window_manager: ^0.3.0
- file_picker: ^6.0.0
- path_provider: ^2.1.0
```

### ウィンドウの初期設定

**Cursorに以下をリクエスト:**

```
main.dartでウィンドウマネージャーを初期化し、
以下の設定をしてください：
- 初期サイズ: 1200x800
- 最小サイズ: 800x600
- タイトル: "My Desktop App"
- 中央配置
```

**生成されるコード例:**

```dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // デスクトッププラットフォームのみで初期化
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    title: 'My Desktop App',
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Desktop App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
```

## Step 3: デスクトップレイアウトの実装

### サイドバー + メインコンテンツのレイアウト

**Cursorに以下をリクエスト:**

```
デスクトップらしいレイアウトを作成してください：
- 左側: 固定幅200pxのサイドバー（ナビゲーション）
- 右側: 可変幅のメインコンテンツエリア
- 上部: アプリバー
- 下部: ステータスバー
```

**生成されるコード例:**

```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<String> _pages = ['Home', 'Files', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Desktop App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Row(
        children: [
          // サイドバー
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder),
                label: Text('Files'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // メインコンテンツ
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildStatusBar(),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Text(
        '${_pages[_selectedIndex]} Page',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 24,
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Text(
            'Status: Ready',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
```

## Step 4: ファイルピッカーの実装

### ファイルの開く/保存ダイアログ

**Cursorに以下をリクエスト:**

```
file_pickerを使って、以下の機能を実装してください：
1. ファイルを開くボタン（テキストファイルのみ）
2. ファイルを保存ボタン
3. 選択したファイルパスを表示
```

**生成されるコード例:**

```dart
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  String? _selectedFilePath;
  String _fileContent = '';

  Future<void> _openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'json'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _selectedFilePath = file.path;
        _fileContent = file.readAsStringSync();
      });
    }
  }

  Future<void> _saveFile() async {
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'ファイルを保存',
      fileName: 'document.txt',
    );

    if (outputPath != null) {
      final file = File(outputPath);
      await file.writeAsString(_fileContent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存しました: $outputPath')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _openFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('ファイルを開く'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _saveFile,
                icon: const Icon(Icons.save),
                label: const Text('ファイルを保存'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedFilePath != null)
            Text('選択中: $_selectedFilePath'),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: _fileContent),
              onChanged: (value) => _fileContent = value,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'ファイル内容がここに表示されます',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Step 5: キーボードショートカットの実装

### ショートカットキーの追加

**Cursorに以下をリクエスト:**

```
以下のキーボードショートカットを実装してください：
- Ctrl/Cmd + O: ファイルを開く
- Ctrl/Cmd + S: ファイルを保存
- Ctrl/Cmd + Q: アプリを終了
```

**生成されるコード例:**

```dart
import 'package:flutter/services.dart';

class ShortcutsPage extends StatelessWidget {
  final VoidCallback onOpen;
  final VoidCallback onSave;
  final VoidCallback onQuit;

  const ShortcutsPage({
    super.key,
    required this.onOpen,
    required this.onSave,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyO):
            const OpenFileIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const SaveFileIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyQ):
            const QuitAppIntent(),
      },
      child: Actions(
        actions: {
          OpenFileIntent: CallbackAction<OpenFileIntent>(
            onInvoke: (_) => onOpen(),
          ),
          SaveFileIntent: CallbackAction<SaveFileIntent>(
            onInvoke: (_) => onSave(),
          ),
          QuitAppIntent: CallbackAction<QuitAppIntent>(
            onInvoke: (_) => onQuit(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Container(),
        ),
      ),
    );
  }
}

class OpenFileIntent extends Intent {
  const OpenFileIntent();
}

class SaveFileIntent extends Intent {
  const SaveFileIntent();
}

class QuitAppIntent extends Intent {
  const QuitAppIntent();
}
```

## Step 6: マウス右クリックメニュー

### コンテキストメニューの実装

**Cursorに以下をリクエスト:**

```
右クリックでコンテキストメニューを表示する機能を実装してください。
メニュー項目: コピー、ペースト、削除
```

**生成されるコード例:**

```dart
class ContextMenuExample extends StatelessWidget {
  const ContextMenuExample({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        child: const Text('右クリックしてメニューを表示'),
      ),
    );
  }

  void _showContextMenu(BuildContext context, Offset position) async {
    final result = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.copy, size: 18),
              SizedBox(width: 8),
              Text('コピー'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'paste',
          child: Row(
            children: [
              Icon(Icons.paste, size: 18),
              SizedBox(width: 8),
              Text('ペースト'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('削除', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );

    if (result != null) {
      print('選択: $result');
    }
  }
}
```

## Step 7: アプリのビルドと配布

### Windows向けビルド

```bash
# 開発版ビルド
flutter build windows

# リリース版ビルド（最適化）
flutter build windows --release

# 生成物: build/windows/runner/Release/
# 配布時は、Releaseフォルダ全体をZIPで配布
```

### macOS向けビルド

```bash
# ビルド
flutter build macos --release

# 生成物: build/macos/Build/Products/Release/
# .appファイルをDMGにパッケージングして配布
```

### Linux向けビルド

```bash
# ビルド
flutter build linux --release

# 生成物: build/linux/x64/release/bundle/
# bundleフォルダをtarで圧縮して配布、または.debパッケージを作成
```

## Step 8: インストーラーの作成（オプション）

### Windows: Inno Setupを使用

**Cursorに以下をリクエスト:**

```
Inno Setupスクリプトのテンプレートを作成してください。
アプリ名: My Desktop App
実行ファイル: my_desktop_app.exe
```

### macOS: create-dmgを使用

```bash
# Homebrewでcreate-dmgをインストール
brew install create-dmg

# DMGを作成
create-dmg \
  --volname "My Desktop App" \
  --window-pos 200 120 \
  --window-size 800 400 \
  MyDesktopApp.dmg \
  build/macos/Build/Products/Release/my_desktop_app.app
```

## まとめ

### 学んだこと

✅ **ウィンドウ管理**: サイズ、位置、タイトルのカスタマイズ
✅ **デスクトップレイアウト**: サイドバー、ステータスバー
✅ **ファイル操作**: ファイルピッカー、読み書き
✅ **ショートカット**: キーボードショートカットの実装
✅ **コンテキストメニュー**: 右クリックメニュー
✅ **ビルドと配布**: 各プラットフォーム向けのビルド方法

### デスクトップアプリ開発のベストプラクティス

1. **レスポンシブ対応**: 最小サイズを設定し、リサイズに対応
2. **キーボード優先**: ショートカットキーを充実させる
3. **ネイティブUI**: プラットフォームの慣習に従う
4. **ファイル管理**: 適切なディレクトリに保存
5. **エラーハンドリング**: ファイル操作は必ずtry-catch

### 次のステップ

デスクトップアプリの知識を活用して、次はWebアプリに挑戦しましょう：

➡️ **次のレシピへ:** [#5-6: Webアプリを作る](./06_building_web_app.md)
