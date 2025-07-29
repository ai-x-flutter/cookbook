# レシピ#4-8: AIと描くCustomPainter - 数学をコードに

FlutterのほとんどのUIは、既存のウィジェットを組み合わせることで構築できます。しかし、時として、独自の図形、グラフ、凝ったアニメーションなど、**標準ウィジェットだけでは表現できない、完全にカスタムな描画**を行いたい場合があります。

そのための強力な武器が`CustomPainter`です。`CustomPainter`を使えば、画面上のキャンバスに、線、円、パスなどを自由自在に描画できます。

しかし、これには座標計算などの数学的な知識が必要となり、多くの開発者にとって挑戦的なタスクです。このレシピでは、**AIを「優秀な数学教師」兼「グラフィックプログラマー」として活用し**、複雑なカスタム描画を実装する方法を学びます。

---

## 1. 基本的な図形をAIに描かせる

まずは、`CustomPainter`の基本構造と、簡単な図形を描画するコードをAIに生成してもらうことから始めましょう。

> **🤖 AI活用プロンプト (基本のCustomPainter)**
>
> あなたはFlutterの`CustomPainter`に非常に詳しいエキスパートです。
>
> 以下の要件を満たす、シンプルな`CustomPainter`のコードを生成してください。
>
> **要件:**
> 1.  `CustomPaint`ウィジェットと、それに対応する`CustomPainter`クラスの完全なコードを提示する。
> 2.  `CustomPainter`は、与えられたキャンバスの中央に、半径50ピクセルの**赤い円**を描画する。
> 3.  コードには、`paint`メソッドと`shouldRepaint`メソッドがそれぞれ何をしているのか、簡単な解説コメントを付ける。

**AIの応答（例）:**
```dart
import 'package:flutter/material.dart';

// CustomPaintウィジェットを使って、カスタム描画領域をUIに配置
class MyCustomDrawing extends StatelessWidget {
  const MyCustomDrawing({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200), // 描画領域のサイズ
      painter: CirclePainter(),      // 実際に描画を行うPainterクラスを指定
    );
  }
}

// 描画ロジックを実装するCustomPainterクラス
class CirclePainter extends CustomPainter {
  // paintメソッドに、実際の描画処理を記述する
  @override
  void paint(Canvas canvas, Size size) {
    // 描画に使うPaintオブジェクト（筆）を用意
    final paint = Paint()
      ..color = Colors.red // 筆の色を赤に
      ..style = PaintingStyle.fill; // 塗りつぶしスタイル

    // キャンバスの中央座標を計算
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 50.0;

    // キャンバスの中央に円を描画
    canvas.drawCircle(center, radius, paint);
  }

  // shouldRepaintは、再描画が必要かどうかを判断するメソッド
  // 今回は静的な描画なので、常にfalseを返す
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
```
このコードを画面に配置するだけで、赤い円が表示されます。`CustomPainter`の基本構造を理解するのに最適な出発点です。

---

## 2. AIに複雑な数学計算を任せる

`CustomPainter`の真価が発揮されるのは、より複雑な図形を描画する時です。例えば、正多角形や、動的なグラフなどです。これらの描画には、三角関数などの数学計算が必要になります。

### 例：データに基づいた円グラフを描画させる

> **🤖 AI活用プロンプト (円グラフの描画)**
>
> `CustomPainter`を使って、データに基づいた円グラフを描画したい。
>
> **要件:**
> 1.  `PieChartPainter`という名前の`CustomPainter`を作成する。
> 2.  このPainterは、`List<double> data`（例: `[10, 20, 30, 40]`）と`List<Color> colors`をコンストラクタで受け取る。
> 3.  データリストの各値の比率に応じて、円グラフの各セクターの**開始角度（startAngle**）と**掃引角度（sweepAngle**）を計算し、`canvas.drawArc`を使って描画する。
> 4.  各セクターは、対応する色で塗りつぶす。
> 5.  ラジアン（Radian）の計算など、必要な数学的処理もすべて実装する。
>
> この`PieChartPainter`クラスの完全なコードを提示してください。

**なぜこれが良いのか？**
*   **数学計算の丸投げ:** 円グラフの各セクターの角度を計算するには、データの合計値を求め、各値の割合を計算し、それを円周（2πラジアン）に換算するという、面倒な計算が必要です。AIは、このような数学的アルゴリズムを正確にコードに変換してくれます。
*   **Flutter APIの知識:** `canvas.drawArc`のような、特定の描画APIの正しい使い方（引数の意味など）をAIが知っているため、あなたはAPIドキュメントを細かく読む必要がありません。

---

## 3. アニメーションとの組み合わせ

`CustomPainter`は、`AnimationController`と組み合わせることで、非常に滑らかなアニメーションを実現できます。

> **🤖 AI活用プロンプト (アニメーションの実装)**
>
> 先ほど作成した`PieChartPainter`に、アニメーションを追加したい。
>
> `StatefulWidget`と`AnimationController`を使い、円グラフが0から徐々に描画されていくようなアニメーションを実装してください。
>
> **要件:**
> 1.  `AnimationController`を初期化し、例えば1秒間でアニメーションが完了するように設定する。
> 2.  `CustomPaint`ウィジェットを`AnimatedBuilder`でラップする。
> 3.  `PieChartPainter`に、現在のアニメーションの値（`controller.value`、0.0から1.0）を渡し、その値に応じて描画する円グラフの全体の角度が変わるようにする。

このプロンプトにより、AIは`StatefulWidget`のライフサイクル（`initState`, `dispose`）に沿った`AnimationController`の管理方法や、`AnimatedBuilder`を使った効率的な再描画のパターンなど、アニメーション実装の定石に沿ったコードを生成してくれます。

`CustomPainter`は、一見すると難易度が高い機能ですが、**数学的な思考や複雑な計算をAIに任せる**ことで、あなたは「何を描きたいか」という創造的な部分に集中できます。AIとの協力体制が、最も劇的な効果を発揮する分野の一つと言えるでしょう。