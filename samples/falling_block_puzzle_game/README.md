# Falling Block Puzzle Game

A classic falling block puzzle game built with Flutter, demonstrating game development concepts including game loops, collision detection, and state management.

**Note:** This is an educational sample for the AI x Flutter Cookbook. "Tetris" is a registered trademark of The Tetris Company.

## Features

- Classic block puzzle gameplay
- 7 different block types (I, O, T, S, Z, J, L)
- Block rotation
- Line clearing with score tracking
- **High score persistence** - Your best score is saved automatically
- Next block preview
- Keyboard controls (for desktop/web)
- Touch controls (for mobile)
- Pause/Resume functionality
- Game over detection
- New high score indicator with celebration animation

## Screenshots

*Game board with falling blocks, score display, and next block preview*

## How to Play

### Keyboard Controls (Desktop/Web)
- **←/→** - Move block left/right
- **↓** - Move block down
- **↑** - Rotate block
- **Space** - Drop block instantly

### Touch Controls (Mobile)
- Use the on-screen buttons to control the blocks

### Objective
- Arrange falling blocks to create complete horizontal lines
- Complete lines disappear and award points
- Game ends when blocks reach the top of the board

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher

### Installation

1. Clone the repository or copy this sample folder
2. Navigate to the project directory:
   ```bash
   cd falling_block_puzzle_game
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Code Structure

The entire game is implemented in a single file (`lib/main.dart`) following the Self-Contained Widget pattern recommended in the AI x Flutter Cookbook:

- `BlockShape` - Defines block types, shapes, colors, and rotation logic
- `GameScreen` - Main game widget with state management
- `_GameScreenState` - Contains game logic:
  - Board management (10x20 grid)
  - Collision detection
  - Block movement and rotation
  - Line clearing
  - Score tracking with high score persistence
  - Game loop using Timer
  - SharedPreferences for data persistence

## Learning Points

This sample demonstrates several Flutter and game development concepts:

1. **Game Loop**: Using `Timer.periodic` for continuous game updates
2. **Collision Detection**: Checking if blocks can move to new positions
3. **State Management**: Using `StatefulWidget` for simple game state
4. **Keyboard Input**: Handling keyboard events with `KeyboardListener`
5. **Custom Painting**: Drawing the game board with Container widgets
6. **Grid Layout**: Managing a 2D array for the game board
7. **Data Persistence**: Using `shared_preferences` to save and load high scores
8. **Async Programming**: Handling asynchronous operations with `Future` and `async/await`

## AI Development Tips

When working with AI tools (Cursor, Claude, etc.) to modify or extend this game:

1. **Start Simple**: The game uses basic Flutter widgets and straightforward logic
2. **Clear Structure**: All game logic is in one file, making it easy for AI to understand
3. **Well-Commented**: Key functions have clear purposes
4. **No Complex Dependencies**: Uses only Flutter's standard library

### Extension Ideas

Ask your AI assistant to help implement:
- Sound effects
- Different difficulty levels (faster falling)
- Held block feature
- Ghost block (shows where block will land)
- Score history and statistics
- Multiplayer mode
- Custom themes/colors
- Leaderboard with multiple high scores
- Achievement system

## License

This sample code is dedicated to the public domain under CC0 1.0 Universal.
See the LICENSE file for details.

## Related Resources

- [AI x Flutter Cookbook](../../README.md)
- [Flutter Game Development](https://docs.flutter.dev/cookbook)
- [Self-Contained Widget Pattern](../../docs/04_secret_sauce_recipes/03_self_contained_widget_pattern.md)
