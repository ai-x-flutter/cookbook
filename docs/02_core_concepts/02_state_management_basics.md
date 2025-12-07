# 重要概念#2-2: 状態管理の基礎

## はじめに

「状態管理」と聞くと難しそうに感じるかもしれませんが、実はとてもシンプルな概念です。

**状態（State）とは、「アプリが覚えておくべき情報」**のことです。

たとえば：
- カウンターアプリの「現在の数字」
- TODOアプリの「TODOリスト」
- 設定画面の「ダークモードのON/OFF」

これらの情報を**どこに保存し、どう更新するか**が「状態管理」です。

## なぜ状態管理を学ぶのか？

Flutterアプリは、ユーザーの操作に応じて画面が変化します。この変化を実現するには：

1. **情報を覚えておく**（状態の保持）
2. **情報が変わったら画面を更新する**（状態の変更）

この2つができないと、ボタンを押しても何も起こらないアプリになってしまいます。

## 基本中の基本：StatefulWidget

Flutterで状態を管理する最もシンプルな方法が**StatefulWidget**です。

### シンプルなカウンターアプリ

```dart
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;  // ← これが「状態」

  void _increment() {
    setState(() {      // ← setStateで「状態が変わった」と通知
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('カウント: $_counter'),
        ElevatedButton(
          onPressed: _increment,
          child: const Text('+1'),
        ),
      ],
    );
  }
}
```

### 重要なポイント

1. **`_counter`** が状態（覚えておきたい情報）
2. **`setState(() { ... })`** で状態を更新
3. 状態が更新されると、Flutterが自動で画面を再描画

**これだけです！** これが状態管理の基本です。

## 状態の種類

状態には大きく2種類あります：

### 1. ローカル状態（Widget内だけで使う）

特定のWidget内でのみ使用する状態。

**例：**
- テキストフィールドの入力内容
- 展開/折りたたみの状態
- アニメーションの進行状態

**管理方法:** StatefulWidget

### 2. 共有状態（複数のWidgetで使う）

複数のWidgetで共有する状態。

**例：**
- ユーザー設定（テーマ、言語）
- ログイン情報
- ショッピングカートの中身

**管理方法:** 後で説明（まずはローカル状態から理解しましょう）

## よくある間違い

### ❌ 間違い1：setStateを忘れる

```dart
void _increment() {
  _counter++;  // ← これだけでは画面が更新されない
}
```

**正解:**
```dart
void _increment() {
  setState(() {
    _counter++;  // ← setStateで囲む
  });
}
```

### ❌ 間違い2：StatelessWidgetで状態を持とうとする

```dart
class MyWidget extends StatelessWidget {
  int _counter = 0;  // ← StatelessWidgetでは状態を持てない

  @override
  Widget build(BuildContext context) {
    return Text('$_counter');
  }
}
```

**正解:** 状態が必要なら**StatefulWidget**を使う

## 実践例：ON/OFFスイッチ

```dart
class ToggleWidget extends StatefulWidget {
  const ToggleWidget({super.key});

  @override
  State<ToggleWidget> createState() => _ToggleWidgetState();
}

class _ToggleWidgetState extends State<ToggleWidget> {
  bool _isOn = false;  // ← ON/OFFの状態

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_isOn ? 'ON' : 'OFF'),
        Switch(
          value: _isOn,
          onChanged: (value) {
            setState(() {
              _isOn = value;  // ← 状態を更新
            });
          },
        ),
      ],
    );
  }
}
```

## ライフサイクル：Widgetの一生

StatefulWidgetには「ライフサイクル」があります。

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    // ← Widget作成時に1度だけ呼ばれる
    //   データの読み込みなどを行う
  }

  @override
  void dispose() {
    // ← Widget破棄時に呼ばれる
    //   タイマーの停止などを行う
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ← 画面を描画
    return Container();
  }
}
```

### 重要な注意点：mounted チェック

非同期処理（APIからデータを取得するなど）の後は、必ず`mounted`をチェック：

```dart
Future<void> _fetchData() async {
  final data = await api.fetch();

  // ← Widgetが破棄されていないか確認
  if (mounted) {
    setState(() {
      _data = data;
    });
  }
}
```

これを忘れると、エラーが発生します。

## まとめ

状態管理の基本：

1. **状態 = アプリが覚えておく情報**
2. **StatefulWidget** で状態を持つ
3. **setState()** で状態を更新
4. **initState** で初期化、**dispose** で後片付け
5. 非同期処理後は **mounted** をチェック

これだけ理解できれば、基本的なFlutterアプリを作れます。

## 次のステップ

複数のWidgetで状態を共有する方法については、別のドキュメントで解説します。

まずは、StatefulWidgetを使ったシンプルなアプリを作ってみましょう！

> **🤖 AI活用プロンプト**
>
> ```
> StatefulWidgetを使って、テキストの表示/非表示を切り替えるボタンを作ってください。
> ボタンを押すと、テキストが表示されたり消えたりするようにしてください。
> ```

---

**より詳しい状態管理（ChangeNotifier、InheritedWidgetなど）については、実際にアプリを作りながら学んでいきましょう。**
