import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const FallingBlockPuzzleApp());
}

class FallingBlockPuzzleApp extends StatelessWidget {
  const FallingBlockPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Falling Block Puzzle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

/// ブロックの種類を定義
enum BlockType { I, O, T, S, Z, J, L }

/// ブロックの形状を定義
class BlockShape {
  final BlockType type;
  final List<List<int>> shape;
  final Color color;

  BlockShape({required this.type, required this.shape, required this.color});

  /// ブロックを90度回転
  List<List<int>> rotate() {
    final rows = shape.length;
    final cols = shape[0].length;
    final rotated = List.generate(cols, (_) => List.filled(rows, 0));

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        rotated[j][rows - 1 - i] = shape[i][j];
      }
    }
    return rotated;
  }

  /// ブロックをコピーして回転
  BlockShape rotated() {
    return BlockShape(type: type, shape: rotate(), color: color);
  }

  /// ブロック形状のファクトリー
  static BlockShape random() {
    final types = BlockType.values;
    final type = types[Random().nextInt(types.length)];
    return BlockShape.fromType(type);
  }

  static BlockShape fromType(BlockType type) {
    switch (type) {
      case BlockType.I:
        return BlockShape(
          type: type,
          shape: [
            [1, 1, 1, 1]
          ],
          color: Colors.cyan,
        );
      case BlockType.O:
        return BlockShape(
          type: type,
          shape: [
            [1, 1],
            [1, 1]
          ],
          color: Colors.yellow,
        );
      case BlockType.T:
        return BlockShape(
          type: type,
          shape: [
            [0, 1, 0],
            [1, 1, 1]
          ],
          color: Colors.purple,
        );
      case BlockType.S:
        return BlockShape(
          type: type,
          shape: [
            [0, 1, 1],
            [1, 1, 0]
          ],
          color: Colors.green,
        );
      case BlockType.Z:
        return BlockShape(
          type: type,
          shape: [
            [1, 1, 0],
            [0, 1, 1]
          ],
          color: Colors.red,
        );
      case BlockType.J:
        return BlockShape(
          type: type,
          shape: [
            [1, 0, 0],
            [1, 1, 1]
          ],
          color: Colors.blue,
        );
      case BlockType.L:
        return BlockShape(
          type: type,
          shape: [
            [0, 0, 1],
            [1, 1, 1]
          ],
          color: Colors.orange,
        );
    }
  }
}

/// ゲーム画面
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int boardWidth = 10;
  static const int boardHeight = 20;
  static const Duration fallInterval = Duration(milliseconds: 500);

  // ゲームボード（0=空、1以上=色のインデックス）
  late List<List<int>> board;
  late List<List<Color?>> boardColors;

  // 現在のブロック
  late BlockShape currentBlock;
  late int blockX;
  late int blockY;

  // 次のブロック
  late BlockShape nextBlock;

  // ゲーム状態
  Timer? gameTimer;
  int score = 0;
  int highScore = 0;
  bool isNewHighScore = false;
  bool isGameOver = false;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _initGame();
  }

  /// ハイスコアを読み込む
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('high_score') ?? 0;
    });
  }

  /// ハイスコアを保存する
  Future<void> _saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('high_score', score);
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void _initGame() {
    // ボード初期化
    board = List.generate(boardHeight, (_) => List.filled(boardWidth, 0));
    boardColors = List.generate(boardHeight, (_) => List.filled(boardWidth, null));

    // 最初のブロック
    currentBlock = BlockShape.random();
    nextBlock = BlockShape.random();
    blockX = boardWidth ~/ 2 - 2;
    blockY = 0;

    score = 0;
    isGameOver = false;
    isPaused = false;
    isNewHighScore = false;

    // ゲームループ開始
    _startGameLoop();
  }

  void _startGameLoop() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(fallInterval, (timer) {
      if (!isPaused && !isGameOver) {
        _moveDown();
      }
    });
  }

  bool _canMove(int newX, int newY, List<List<int>> shape) {
    for (int i = 0; i < shape.length; i++) {
      for (int j = 0; j < shape[i].length; j++) {
        if (shape[i][j] == 1) {
          final boardX = newX + j;
          final boardY = newY + i;

          // 範囲外チェック
          if (boardX < 0 || boardX >= boardWidth || boardY >= boardHeight) {
            return false;
          }

          // 衝突チェック
          if (boardY >= 0 && board[boardY][boardX] != 0) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void _moveLeft() {
    if (_canMove(blockX - 1, blockY, currentBlock.shape)) {
      setState(() {
        blockX--;
      });
    }
  }

  void _moveRight() {
    if (_canMove(blockX + 1, blockY, currentBlock.shape)) {
      setState(() {
        blockX++;
      });
    }
  }

  void _moveDown() {
    if (_canMove(blockX, blockY + 1, currentBlock.shape)) {
      setState(() {
        blockY++;
      });
    } else {
      _lockBlock();
      _checkLines();
      _spawnNewBlock();
    }
  }

  void _rotate() {
    final rotated = currentBlock.rotated();
    if (_canMove(blockX, blockY, rotated.shape)) {
      setState(() {
        currentBlock = rotated;
      });
    }
  }

  void _drop() {
    while (_canMove(blockX, blockY + 1, currentBlock.shape)) {
      blockY++;
    }
    _lockBlock();
    _checkLines();
    _spawnNewBlock();
    setState(() {});
  }

  void _lockBlock() {
    for (int i = 0; i < currentBlock.shape.length; i++) {
      for (int j = 0; j < currentBlock.shape[i].length; j++) {
        if (currentBlock.shape[i][j] == 1) {
          final boardX = blockX + j;
          final boardY = blockY + i;
          if (boardY >= 0 && boardY < boardHeight && boardX >= 0 && boardX < boardWidth) {
            board[boardY][boardX] = 1;
            boardColors[boardY][boardX] = currentBlock.color;
          }
        }
      }
    }
  }

  void _checkLines() {
    int linesCleared = 0;
    for (int i = boardHeight - 1; i >= 0; i--) {
      if (board[i].every((cell) => cell != 0)) {
        board.removeAt(i);
        board.insert(0, List.filled(boardWidth, 0));
        boardColors.removeAt(i);
        boardColors.insert(0, List.filled(boardWidth, null));
        linesCleared++;
        i++; // 同じ行を再チェック
      }
    }

    if (linesCleared > 0) {
      setState(() {
        score += linesCleared * 100;
        if (score > highScore) {
          highScore = score;
          isNewHighScore = true;
          _saveHighScore(highScore);
        }
      });
    }
  }

  void _spawnNewBlock() {
    currentBlock = nextBlock;
    nextBlock = BlockShape.random();
    blockX = boardWidth ~/ 2 - 2;
    blockY = 0;

    if (!_canMove(blockX, blockY, currentBlock.shape)) {
      setState(() {
        isGameOver = true;
      });
      gameTimer?.cancel();
    }
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Falling Block Puzzle'),
        actions: [
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: isGameOver ? null : _togglePause,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _initGame();
              });
            },
          ),
        ],
      ),
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent && !isPaused && !isGameOver) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _moveLeft();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _moveRight();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _moveDown();
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              _rotate();
            } else if (event.logicalKey == LogicalKeyboardKey.space) {
              _drop();
            }
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // スコア表示
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Score: $score',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'High Score: $highScore',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (isNewHighScore) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 24,
                            ),
                            const Text(
                              'NEW!',
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // ゲームボードと次のブロック
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ゲームボード
                    _buildGameBoard(),
                    const SizedBox(width: 20),
                    // 次のブロック
                    _buildNextBlock(),
                  ],
                ),

                const SizedBox(height: 20),

                // コントロールボタン
                _buildControls(),

                // ゲームオーバー表示
                if (isGameOver)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Game Over!',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),

                // 操作説明
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Keyboard: ←→↓ to move, ↑ to rotate, Space to drop',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameBoard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        color: Colors.black12,
      ),
      child: Column(
        children: List.generate(boardHeight, (y) {
          return Row(
            children: List.generate(boardWidth, (x) {
              Color? cellColor = boardColors[y][x];

              // 現在のブロックを描画
              if (!isGameOver) {
                for (int i = 0; i < currentBlock.shape.length; i++) {
                  for (int j = 0; j < currentBlock.shape[i].length; j++) {
                    if (currentBlock.shape[i][j] == 1) {
                      final bx = blockX + j;
                      final by = blockY + i;
                      if (bx == x && by == y) {
                        cellColor = currentBlock.color;
                      }
                    }
                  }
                }
              }

              return Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: cellColor ?? Colors.grey[900],
                  border: Border.all(color: Colors.grey[800]!, width: 0.5),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildNextBlock() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Next',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black12,
              border: Border.all(color: Colors.grey),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(nextBlock.shape.length, (i) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(nextBlock.shape[i].length, (j) {
                      return Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: nextBlock.shape[i][j] == 1
                              ? nextBlock.color
                              : Colors.transparent,
                          border: Border.all(color: Colors.grey[800]!, width: 0.5),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.arrow_left),
          onPressed: isGameOver || isPaused ? null : _moveLeft,
        ),
        Column(
          children: [
            IconButton(
              iconSize: 48,
              icon: const Icon(Icons.rotate_right),
              onPressed: isGameOver || isPaused ? null : _rotate,
            ),
            IconButton(
              iconSize: 48,
              icon: const Icon(Icons.arrow_downward),
              onPressed: isGameOver || isPaused ? null : _drop,
            ),
          ],
        ),
        IconButton(
          iconSize: 48,
          icon: const Icon(Icons.arrow_right),
          onPressed: isGameOver || isPaused ? null : _moveRight,
        ),
      ],
    );
  }
}
