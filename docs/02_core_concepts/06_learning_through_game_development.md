# レシピ#2-6: ゲーム開発で学ぶFlutterの基本的な考え方

ゲーム開発は、Flutterの**状態管理**、**UI更新**、**ユーザーインタラクション**といった核心的な概念を楽しく学ぶ最良の方法の一つです。

AI時代の今、有名なゲームなら「○○ゲームを作って」と言うだけでAIが作ってくれます。しかし、**オリジナルのゲームを作ろうとすると、ゲームのロジックをAIに教える必要があります。**

このレシピでは、AIにゲームロジックを教える4つの方法を学び、その過程でFlutterの基本的な考え方を深く理解します。

---

## なぜゲーム開発で学ぶのか

### ゲームが教えてくれること

```
【状態管理】
ゲームスコア、プレイヤー位置、敵の動き
→ 全て「状態」として管理する必要がある

【UI更新】
状態が変わったら即座に画面を更新
→ Flutterの宣言的UIの本質

【ユーザーインタラクション】
タップ、スワイプ、ドラッグ
→ イベント処理とレスポンス

【タイマーと非同期処理】
ゲームループ、アニメーション
→ Future, Stream, Timer の実践

【データ構造】
ゲームボード、アイテムリスト
→ List, Map, Set の活用
```

---

## AI時代のゲーム開発

### パターン1: 有名なゲームを作る

**簡単！AIが全て知っている**

```
【あなた】
Flutterでテトリスを作って

【Claude】
テトリスを実装します。以下の要素を含めます:

1. ゲームボード（10×20グリッド）
2. テトリミノ（7種類のブロック）
3. 回転、移動、落下の制御
4. ライン消去とスコア計算
5. ゲームオーバー判定

[完全なコードを生成]
```

**他の有名ゲーム例:**
- スネークゲーム
- ブロック崩し
- 2048
- マインスイーパー
- 神経衰弱

これらは「作って」と言うだけで、AIが完全に実装してくれます。

---

### パターン2: オリジナルのゲームを作る

**課題: AIはあなたのゲームのルールを知らない**

```
【あなた】
「色合わせバブルゲーム」を作って

【Claude】
申し訳ありませんが、「色合わせバブルゲーム」の
具体的なルールが分かりません。

以下の情報を教えていただけますか？
- ゲームの目的は？
- プレイヤーは何をするのか？
- 勝敗の条件は？
- 特別なルールは？
```

**→ ゲームロジックを教える必要がある！**

---

## AIにゲームロジックを教える4つの方法

### 方法1: 画像で教える

**視覚的に見せることで、AIが理解しやすくなる**

#### 例: オリジナル「カラーマッチパズル」

**手書きスケッチをAIに見せる:**

```
┌─────────────────┐
│  🔴  🔵  🔴     │  ← 3×3のグリッド
│  🔵  🟢  🔵     │
│  🔴  🔵  🔴     │
└─────────────────┘

【ルール】
1. タップで隣と交換
2. 3つ揃ったら消える
3. 上から新しい色が落ちてくる

【状態遷移図】
待機 → タップ1 → タップ2 → 交換アニメ → チェック → 消去 → 落下 → 待機
```

**AIへの指示:**

```
【あなた】
この画像のゲームを実装して。

[画像を添付]

ルール:
- 3×3のグリッドに赤、青、緑のランダムな色
- 隣接する2つをタップで交換
- 縦または横に3つ同じ色が並んだら消える
- 上から新しい色が補充される
- スコアは消した数 × 10

【Claude】
理解しました。以下のように実装します:

1. データ構造: List<List<Color>> でグリッド表現
2. 状態管理: StatefulWidget で選択状態とスコア管理
3. タップ検出: GestureDetector
4. アニメーション: AnimatedContainer で交換
5. チェックロジック: 3つ揃いの検出アルゴリズム

[実装コード生成]
```

---

### 方法2: プロンプトで教える

**ルールを明確に言語化することで、AIが正確に実装**

#### 例: オリジナル「数字パズルゲーム」

**詳細なプロンプト:**

```
【あなた】
以下のルールで数字パズルゲームを実装してください:

## ゲーム概要
4×4のグリッドに1-15の数字と1つの空白がある。
空白に隣接する数字タイルをタップすると、空白と交換される。
全ての数字を順番（左上から右下へ1,2,3...15）に並べるのが目的。

## 詳細ルール
1. 初期状態: ランダムにシャッフル（ただし解けない配置は避ける）
2. 移動: 空白の上下左右に隣接するタイルのみ移動可能
3. 勝利条件: 1-15が順番に並び、右下が空白
4. スコア: 移動回数をカウント（少ない方が良い）

## エッジケース
- 隅のタイルは2方向のみ移動可能
- 辺のタイルは3方向のみ移動可能
- 解けない配置の判定（転倒数が偶数かチェック）

## UI要件
- タイルは見やすい数字とボーダー
- タップ可能なタイルはハイライト
- 勝利時はダイアログ表示
- リセットボタン

【Claude】
詳細な仕様、ありがとうございます。実装します:

1. データ構造:
   ```dart
   class PuzzleState {
     List<int> tiles; // 0が空白を表す
     int moves;
     bool isSolved;
   }
   ```

2. 解けない配置の判定:
   ```dart
   bool isSolvable(List<int> tiles) {
     int inversions = 0;
     for (int i = 0; i < tiles.length; i++) {
       for (int j = i + 1; j < tiles.length; j++) {
         if (tiles[i] > tiles[j] && tiles[i] != 0 && tiles[j] != 0) {
           inversions++;
         }
       }
     }
     return inversions % 2 == 0;
   }
   ```

[完全な実装]
```

**プロンプトのポイント:**
- ゲームの目的を明確に
- ルールを箇条書きで
- エッジケースを具体的に
- UI要件も含める

---

### 方法3: JSONデータで教える

**ゲーム設定をデータ化して、AIがデータ駆動で実装**

#### 例: オリジナル「RPG風クイズゲーム」

**game_data.json:**

```json
{
  "game": {
    "title": "歴史クイズRPG",
    "description": "クイズに答えて冒険を進めよう"
  },
  "stages": [
    {
      "id": 1,
      "name": "古代エジプト",
      "background": "desert.png",
      "enemy": {
        "name": "スフィンクス",
        "hp": 100,
        "image": "sphinx.png"
      },
      "questions": [
        {
          "question": "ピラミッドを建てたファラオは？",
          "choices": ["クフ王", "ツタンカーメン", "クレオパトラ", "ラムセス2世"],
          "correctAnswer": 0,
          "damage": 30
        },
        {
          "question": "ナイル川が流れる方角は？",
          "choices": ["東", "西", "南", "北"],
          "correctAnswer": 3,
          "damage": 25
        }
      ]
    },
    {
      "id": 2,
      "name": "古代ローマ",
      "background": "colosseum.png",
      "enemy": {
        "name": "剣闘士",
        "hp": 150,
        "image": "gladiator.png"
      },
      "questions": [
        {
          "question": "ローマ帝国初代皇帝は？",
          "choices": ["ネロ", "アウグストゥス", "カエサル", "トラヤヌス"],
          "correctAnswer": 1,
          "damage": 35
        }
      ]
    }
  ],
  "gameRules": {
    "playerHp": 100,
    "correctAnswerDamage": "questions[].damage",
    "wrongAnswerPenalty": -20,
    "victoryCondition": "enemy.hp <= 0",
    "defeatCondition": "player.hp <= 0"
  }
}
```

**AIへの指示:**

```
【あなた】
この JSON データに基づいて、RPG風クイズゲームを実装してください。

[game_data.json を添付]

要件:
1. JSONファイルを読み込んでゲームデータとして使用
2. ステージごとに敵が変わる
3. 問題に正解すると敵にダメージ
4. 不正解だとプレイヤーがダメージ
5. 敵のHPが0になったら次のステージへ
6. プレイヤーのHPが0になったらゲームオーバー

【Claude】
JSONデータ駆動のゲームを実装します:

1. データモデル:
   ```dart
   class GameData {
     final String title;
     final List<Stage> stages;
     final GameRules rules;

     factory GameData.fromJson(Map<String, dynamic> json) { ... }
   }

   class Stage {
     final int id;
     final String name;
     final Enemy enemy;
     final List<Question> questions;

     factory Stage.fromJson(Map<String, dynamic> json) { ... }
   }
   ```

2. データ読み込み:
   ```dart
   Future<GameData> loadGameData() async {
     final jsonString = await rootBundle.loadString('assets/game_data.json');
     final jsonData = json.decode(jsonString);
     return GameData.fromJson(jsonData);
   }
   ```

3. ゲームロジック:
   - ステージ管理
   - HP計算
   - 勝敗判定

[完全な実装]
```

**JSONデータの利点:**
- ゲームデザイナーとプログラマーの分業
- 問題やステージの追加が容易
- 翻訳・多言語対応が簡単
- データのバリデーションが可能

---

### 方法4: 対話形式で教える

**最も自然！段階的にゲームロジックを構築**

#### 例: オリジナル「タワーディフェンスゲーム」

**対話の流れ:**

```
【あなた】
タワーディフェンスゲームを作りたいんだけど、
まず基本的な枠組みを作って

【Claude】
タワーディフェンスの基本構造を作成します:

1. ゲームフィールド（グリッド）
2. 敵が進む道（パス）
3. タワーを配置できる場所
4. 基本的な敵（直線移動）
5. 基本的なタワー（射撃）

[初期実装コード]

現時点で以下ができます:
- 敵がパスに沿って移動
- タワーをグリッドに配置
- タワーが範囲内の敵を攻撃

次にどの要素を追加しましょうか？

【あなた】
いいね！次は敵の種類を増やしたい。
速い敵、硬い敵、飛行する敵の3種類

【Claude】
敵のバリエーションを追加します:

```dart
enum EnemyType {
  fast,   // 速い敵: HP 50, Speed 3.0
  tank,   // 硬い敵: HP 200, Speed 1.0
  flying, // 飛行敵: HP 80, Speed 2.0, 道を無視
}

class Enemy {
  final EnemyType type;
  double hp;
  double speed;
  bool canFly;

  Enemy(this.type) {
    switch (type) {
      case EnemyType.fast:
        hp = 50; speed = 3.0; canFly = false;
        break;
      case EnemyType.tank:
        hp = 200; speed = 1.0; canFly = false;
        break;
      case EnemyType.flying:
        hp = 80; speed = 2.0; canFly = true;
        break;
    }
  }
}
```

実装しました。飛行敵は道を無視して直線で進みます。

【あなた】
完璧！じゃあタワーも種類を増やして。
対空タワー、範囲攻撃タワー、減速タワー

【Claude】
タワーのバリエーションを追加します:

```dart
enum TowerType {
  basic,    // 基本: 単体攻撃、中ダメージ
  antiAir,  // 対空: 飛行敵に特化
  area,     // 範囲: 複数敵に同時攻撃
  slow,     // 減速: ダメージ小、敵を遅くする
}

class Tower {
  final TowerType type;
  double damage;
  double range;
  double attackSpeed;
  bool canTargetFlying;
  double slowEffect; // 0.0-1.0

  Tower(this.type) {
    switch (type) {
      case TowerType.basic:
        damage = 20; range = 100; attackSpeed = 1.0;
        canTargetFlying = false; slowEffect = 0;
        break;
      case TowerType.antiAir:
        damage = 30; range = 120; attackSpeed = 1.2;
        canTargetFlying = true; slowEffect = 0;
        break;
      case TowerType.area:
        damage = 15; range = 80; attackSpeed = 0.8;
        canTargetFlying = false; slowEffect = 0;
        break;
      case TowerType.slow:
        damage = 5; range = 100; attackSpeed = 1.5;
        canTargetFlying = false; slowEffect = 0.5;
        break;
    }
  }
}
```

【あなた】
いいね！最後にウェーブシステムを追加して。
ウェーブごとに敵の数と種類が変わるようにしたい

【Claude】
ウェーブシステムを実装します:

```dart
class Wave {
  final int waveNumber;
  final List<EnemySpawn> enemies;
  final double spawnInterval;

  Wave(this.waveNumber, this.enemies, this.spawnInterval);
}

class EnemySpawn {
  final EnemyType type;
  final int count;

  EnemySpawn(this.type, this.count);
}

// ウェーブ定義
final waves = [
  Wave(1, [EnemySpawn(EnemyType.fast, 10)], 1.0),
  Wave(2, [
    EnemySpawn(EnemyType.fast, 15),
    EnemySpawn(EnemyType.tank, 3),
  ], 0.8),
  Wave(3, [
    EnemySpawn(EnemyType.fast, 10),
    EnemySpawn(EnemyType.flying, 5),
    EnemySpawn(EnemyType.tank, 5),
  ], 0.7),
];
```

完成です！ゲームの流れ:
1. ウェーブ開始
2. 定義された敵が順番にスポーン
3. 全ての敵を倒したら次のウェーブ
4. 敵がゴールに到達したらライフ減少
5. ライフが0でゲームオーバー

【あなた】
完璧！これでゲームが完成した。ありがとう！
```

**対話形式の利点:**
- 段階的に機能を追加できる
- AIが提案してくれることもある
- すぐにテストして改善できる
- 自然な言葉で指示できる
- 途中で方向転換も可能

---

## これがFlutterの基本的な考え方を学ぶ理由

### 1. 状態管理の重要性

**ゲームは常に状態が変化する**

```dart
class GameState {
  // プレイヤーの状態
  int score = 0;
  int lives = 3;
  int level = 1;

  // ゲームオブジェクトの状態
  List<Enemy> enemies = [];
  List<Bullet> bullets = [];
  Player player = Player();

  // ゲームフロー状態
  GameStatus status = GameStatus.ready; // ready, playing, paused, gameOver

  // 時間の状態
  double elapsedTime = 0;
}
```

**状態が変わったらUIを更新:**

```dart
class GameWidget extends StatefulWidget {
  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  GameState gameState = GameState();

  void updateGame() {
    setState(() {
      // ゲームロジックで状態を更新
      gameState.elapsedTime += 0.016; // 約60FPS

      // 敵の移動
      for (var enemy in gameState.enemies) {
        enemy.move();
      }

      // 当たり判定
      checkCollisions();

      // スコア更新
      gameState.score += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 状態に基づいてUIを構築
    return Column(
      children: [
        Text('Score: ${gameState.score}'),
        Text('Lives: ${gameState.lives}'),
        GameField(enemies: gameState.enemies),
      ],
    );
  }
}
```

**学び:**
- 状態と UI を分離する
- `setState()` で UI を更新
- 状態の変更は一箇所で管理

---

### 2. 宣言的UI

**「どう描くか」ではなく「何を描くか」**

```dart
// ❌ 命令的UI（古い考え方）
// canvas.drawRect(...)
// canvas.drawCircle(...)
// if (gameOver) canvas.drawText("Game Over")

// ✅ 宣言的UI（Flutterの考え方）
Widget build(BuildContext context) {
  return Stack(
    children: [
      // ゲームフィールド
      GameField(),

      // 敵を描画
      ...gameState.enemies.map((enemy) =>
        Positioned(
          left: enemy.x,
          top: enemy.y,
          child: EnemyWidget(enemy: enemy),
        )
      ),

      // ゲームオーバー時のオーバーレイ
      if (gameState.status == GameStatus.gameOver)
        GameOverOverlay(score: gameState.score),
    ],
  );
}
```

**学び:**
- 現在の状態に基づいてUIを記述
- 条件分岐で表示を切り替え
- Flutterが効率的に再描画

---

### 3. データ駆動設計

**ゲームデータとロジックの分離**

```dart
// レベルデザインをデータ化
class LevelData {
  final int levelNumber;
  final List<EnemyWave> waves;
  final String backgroundImage;
  final Color backgroundColor;

  const LevelData({
    required this.levelNumber,
    required this.waves,
    required this.backgroundImage,
    required this.backgroundColor,
  });
}

// データから読み込み
final levels = [
  LevelData(
    levelNumber: 1,
    waves: [
      EnemyWave(type: EnemyType.basic, count: 10, interval: 1.0),
    ],
    backgroundImage: 'forest.png',
    backgroundColor: Colors.green,
  ),
  LevelData(
    levelNumber: 2,
    waves: [
      EnemyWave(type: EnemyType.basic, count: 15, interval: 0.8),
      EnemyWave(type: EnemyType.fast, count: 5, interval: 0.5),
    ],
    backgroundImage: 'desert.png',
    backgroundColor: Colors.orange,
  ),
];

// ゲームロジック
class Game {
  LevelData currentLevel;

  void loadLevel(int levelNumber) {
    currentLevel = levels[levelNumber - 1];
    // レベルデータに基づいてゲームを初期化
  }
}
```

**学び:**
- データとロジックを分離
- 設定変更がコード変更不要
- テストが容易

---

### 4. 非同期処理とタイマー

**ゲームループの実装**

```dart
class GameLoop {
  Timer? _gameTimer;

  void start() {
    // 60FPS = 約16.67ms
    _gameTimer = Timer.periodic(
      Duration(milliseconds: 16),
      (timer) {
        updateGame();
      },
    );
  }

  void stop() {
    _gameTimer?.cancel();
  }

  void updateGame() {
    // ゲーム状態を更新
    setState(() {
      // 敵の移動
      for (var enemy in enemies) {
        enemy.update(0.016); // デルタタイム
      }

      // 当たり判定
      checkCollisions();

      // ゲームオーバーチェック
      if (player.lives <= 0) {
        gameStatus = GameStatus.gameOver;
        stop();
      }
    });
  }
}
```

**アニメーションの活用:**

```dart
class AnimatedEnemy extends StatefulWidget {
  final Enemy enemy;

  @override
  State<AnimatedEnemy> createState() => _AnimatedEnemyState();
}

class _AnimatedEnemyState extends State<AnimatedEnemy>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            widget.enemy.x,
            widget.enemy.y + sin(_animation.value * 2 * pi) * 5,
          ),
          child: child,
        );
      },
      child: Image.asset(widget.enemy.image),
    );
  }
}
```

**学び:**
- `Timer` で定期実行
- `AnimationController` でスムーズなアニメーション
- 非同期処理の制御

---

### 5. イベント処理

**ユーザー入力の検出**

```dart
class GameField extends StatelessWidget {
  final Function(Offset) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        // タップ位置を取得
        final tapPosition = details.localPosition;
        onTap(tapPosition);
      },
      onPanUpdate: (details) {
        // ドラッグ中の位置
        final dragPosition = details.localPosition;
        // プレイヤーを移動
      },
      child: Container(
        width: 400,
        height: 600,
        color: Colors.black,
        child: CustomPaint(
          painter: GamePainter(gameState),
        ),
      ),
    );
  }
}
```

**学び:**
- `GestureDetector` でタッチ検出
- イベントから位置情報を取得
- コールバックで状態更新

---

## 実践: シンプルなゲームを作ってみよう

### 例題: 「バブルポップゲーム」

**ゲームルール:**
1. 画面に色付きバブルがランダムに表示される
2. 同じ色のバブルを2つタップすると消える
3. 制限時間内にできるだけ多く消す
4. スコアは消したバブル数 × 10

**AIに教える（対話形式）:**

```
【あなた】
バブルポップゲームを作りたい。
まず、画面にランダムな位置と色でバブルを10個表示して

【Claude】
バブルを表示するゲームを実装します:

```dart
import 'dart:math';
import 'package:flutter/material.dart';

class Bubble {
  final Offset position;
  final Color color;
  final double radius;

  Bubble({
    required this.position,
    required this.color,
    this.radius = 30,
  });
}

class BubblePopGame extends StatefulWidget {
  @override
  State<BubblePopGame> createState() => _BubblePopGameState();
}

class _BubblePopGameState extends State<BubblePopGame> {
  List<Bubble> bubbles = [];
  final random = Random();
  final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow];

  @override
  void initState() {
    super.initState();
    generateBubbles();
  }

  void generateBubbles() {
    bubbles.clear();
    for (int i = 0; i < 10; i++) {
      bubbles.add(Bubble(
        position: Offset(
          random.nextDouble() * 300,
          random.nextDouble() * 500,
        ),
        color: colors[random.nextInt(colors.length)],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bubble Pop')),
      body: Container(
        width: 400,
        height: 600,
        color: Colors.black12,
        child: Stack(
          children: bubbles.map((bubble) =>
            Positioned(
              left: bubble.position.dx,
              top: bubble.position.dy,
              child: Container(
                width: bubble.radius * 2,
                height: bubble.radius * 2,
                decoration: BoxDecoration(
                  color: bubble.color,
                  shape: BoxShape.circle,
                ),
              ),
            )
          ).toList(),
        ),
      ),
    );
  }
}
```

バブルが画面にランダムに表示されます。

【あなた】
いいね！次に、バブルをタップできるようにして、
同じ色を2つタップしたら両方消えるようにして

【Claude】
タップ機能を追加します:

```dart
class _BubblePopGameState extends State<BubblePopGame> {
  List<Bubble> bubbles = [];
  Bubble? firstTapped;
  int score = 0;

  void onBubbleTap(Bubble bubble) {
    setState(() {
      if (firstTapped == null) {
        // 1つ目のタップ
        firstTapped = bubble;
      } else if (firstTapped == bubble) {
        // 同じバブルをタップ → キャンセル
        firstTapped = null;
      } else if (firstTapped!.color == bubble.color) {
        // 同じ色 → 両方消す
        bubbles.remove(firstTapped);
        bubbles.remove(bubble);
        firstTapped = null;
        score += 10;

        // 新しいバブルを追加
        if (bubbles.length < 10) {
          bubbles.add(generateRandomBubble());
        }
      } else {
        // 違う色 → 選択をリセット
        firstTapped = bubble;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bubble Pop - Score: $score'),
      ),
      body: Container(
        child: Stack(
          children: bubbles.map((bubble) =>
            Positioned(
              left: bubble.position.dx,
              top: bubble.position.dy,
              child: GestureDetector(
                onTap: () => onBubbleTap(bubble),
                child: Container(
                  width: bubble.radius * 2,
                  height: bubble.radius * 2,
                  decoration: BoxDecoration(
                    color: bubble.color,
                    shape: BoxShape.circle,
                    border: firstTapped == bubble
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                  ),
                ),
              ),
            )
          ).toList(),
        ),
      ),
    );
  }
}
```

実装しました:
- タップしたバブルに白い枠がつく
- 同じ色を2つタップすると消える
- スコアが加算される
- 新しいバブルが補充される

【あなた】
完璧！最後に60秒のタイマーを追加して、
時間切れでゲームオーバーにして

【Claude】
タイマー機能を追加します:

```dart
class _BubblePopGameState extends State<BubblePopGame> {
  Timer? gameTimer;
  int remainingSeconds = 60;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    generateBubbles();
    startTimer();
  }

  void startTimer() {
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          gameOver = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score: $score | Time: ${remainingSeconds}s'),
      ),
      body: Stack(
        children: [
          // ゲームフィールド
          Container(...),

          // ゲームオーバー画面
          if (gameOver)
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                color: Colors.black87,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Game Over!',
                      style: TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Final Score: $score',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.yellow,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: resetGame,
                      child: Text('Play Again'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      score = 0;
      remainingSeconds = 60;
      gameOver = false;
      firstTapped = null;
      generateBubbles();
      startTimer();
    });
  }
}
```

完成です！ゲームの流れ:
1. 60秒でスタート
2. 同じ色のバブルを消してスコア獲得
3. 時間切れでゲームオーバー
4. "Play Again"で再スタート
```

---

## まとめ

### ゲーム開発で学んだFlutterの基本

```
【状態管理】
ゲームの状態（スコア、ライフ、敵の位置）
→ StatefulWidget と setState()

【宣言的UI】
状態に基づいてUIを記述
→ 「何を表示するか」を宣言

【データ駆動】
ゲーム設定をデータ化
→ ロジックとデータの分離

【非同期処理】
ゲームループ、アニメーション
→ Timer, Future, Animation

【イベント処理】
タップ、ドラッグ
→ GestureDetector
```

---

### AIにゲームロジックを教える4つの方法

| 方法 | 特徴 | 向いている場面 |
|------|------|----------------|
| **画像** | 視覚的、直感的 | UIデザイン、レイアウト |
| **プロンプト** | 詳細、明確 | 複雑なルール、エッジケース |
| **JSON** | データ駆動、拡張性 | レベルデザイン、設定 |
| **対話** | 柔軟、段階的 | 試行錯誤、反復開発 |

---

### 次のステップ

**簡単なゲームから始めよう:**
1. 既知のゲーム（テトリス、スネーク）をAIに作らせる
2. コードを読んで、状態管理を理解する
3. 小さな改造を加えてみる（色を変える、スピードを変える）
4. オリジナルのゲームアイデアを考える
5. 4つの方法でAIに教えて実装する

**ゲーム開発で得られるスキル:**
- 状態管理の深い理解
- Flutterのレイアウトシステム
- アニメーションとタイミング
- ユーザーインタラクション
- データ構造とアルゴリズム

---

**ゲーム開発は、Flutterの全ての概念を楽しく学べる最高の教材です。**

**まずは簡単なゲームから始めて、少しずつ複雑なゲームに挑戦しましょう！**

次のレシピで、実際のアプリ開発プロセスを学んでいきます！
