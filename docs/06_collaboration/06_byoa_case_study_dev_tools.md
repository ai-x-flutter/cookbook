# レシピ#6-6: 【事例研究】Web/アプリ開発ツールをBYOAで作る

このレシピでは、BYOA開発のもう一つの具体例として、**自分専用の開発ツール**を作る方法を学びます。

## この事例の特徴：Cursor + Claude の組み合わせ

開発ツールの場合、**開発支援**と**実行時のAI機能**の両方が役立ちます。

```
【育児アプリとの違い】

育児アプリ:
└─ 実行時のAIエージェント機能が必須
   └─ アプリ内でユーザーがAIと対話
   └─ Claude API統合が中心

開発ツール:
└─ 開発支援 + 実行時AI の両方
   ├─ Cursor: コード書く時のAI支援
   ├─ Claude API: 自分専用の機能統合
   └─ プロジェクト固有の知識を組み込む
```

**推奨される組み合わせ：Cursor + Claude Pro**

---

## 対象とする課題

### 誰のためのツールか

- **ソフトウェア開発者**
- **このCookbookで学んでいる人**
- **特定のフレームワーク・パターンを使うチーム**

### 解決したい課題

```
❌ GitHub Copilot: 汎用的すぎて、プロジェクト固有の文脈が弱い
❌ 毎回、コーディング規約を説明する必要がある
❌ 「Self-Contained Widget」等、独自パターンを理解してくれない
❌ プロジェクトの設計思想を毎回説明
❌ ベンダーロックイン（GitHub/Microsoft依存）
```

---

## 従来のアプローチ vs BYOA開発

### 【従来1】GitHub Copilot

```
✅ コード補完が速い
✅ 一般的なパターンは得意
✅ 多くの言語に対応

❌ 月$10-20（継続的なコスト）
❌ プロジェクト固有の文脈は弱い
❌ カスタマイズ不可
❌ データはGitHub/Microsoftに送信
❌ 「Self-Contained Widget」等の独自パターンは理解しない

コスト: 月$10-20
```

### 【従来2】Cursor（単体）

```
✅ AI統合エディタ
✅ コードベース全体を理解
✅ チャットでコード生成

❌ 月$20
❌ 汎用的（プロジェクト固有の深い理解は限定的）
❌ Cursor依存（エディタを変えられない）

コスト: 月$20
```

### 【従来3】手動でChatGPT/Claudeに相談

```
✅ 無料 or Claude Pro（月$20-25）
✅ 詳しく説明すれば、良い回答

❌ 毎回、プロジェクトの文脈を説明する必要
❌ エディタとの統合なし
❌ コピペが面倒
❌ 効率が悪い

コスト: 無料〜月$20-25
```

---

### 【BYOA】Cursor + Claude + プロジェクト固有の知識

```
✅ Cursor: 開発時のAI支援
✅ Claude API: プロジェクト固有の機能
✅ 一度設定すれば、常にプロジェクトの文脈で回答
✅ 自分で機能追加・カスタマイズ可能
✅ VS Code拡張としても展開可能
✅ チームで共有できる

❌ 初期セットアップが必要
❌ Cursor + Claude Proで月約5,000円

コスト:
- Cursor: 月$20
- Claude Pro: 月$20-25
合計: 月約5,000円
```

**コストは上がるが、生産性向上で十分ペイする。**

---

## 具体的な開発プロセス

### Week 1: Cursorでの開発開始

まず、Cursorを使って通常の開発を始めます。

```typescript
// Cursorの基本的な使い方

// 1. コマンドパレット（Cmd/Ctrl + K）
// 「Self-Contained Widgetを作って」と入力
// → Cursorが生成するが、このCookbookのパターンとは少し違う

// 2. チャット（Cmd/Ctrl + L）
// プロジェクトの文脈を毎回説明する必要がある

// 問題:
// - 毎回「Self-Contained Widgetパターンで」と指示
// - 「Riverpodは使わない」と毎回言う
// - プロジェクト固有の規約を理解していない
```

**Week 1の結論：**
- Cursorは便利だが、プロジェクト固有の深い理解には限界
- 毎回同じ説明を繰り返すのは非効率

---

### Week 2-3: プロジェクト固有の知識ベース作成

Cursor + Claude APIを組み合わせて、プロジェクト専用のアシスタントを作ります。

```typescript
// project-assistant/src/project-context.ts

/**
 * プロジェクト固有の知識
 *
 * このCookbookのパターンを教え込む
 */
export interface ProjectContext {
  architecture: string;
  codingStandards: string[];
  patterns: DesignPattern[];
  doNotUse: string[];
}

export const FLUTTER_COOKBOOK_CONTEXT: ProjectContext = {
  architecture: `
    このプロジェクトは、シンプルで保守性の高いFlutterアプリを目指します。

    【基本方針】
    - 複雑な状態管理ライブラリは使わない
    - Self-Contained Widgetパターンを基本とする
    - ビジネスロジックはService Classに分離
  `,

  codingStandards: [
    'Widget名は必ず末尾に "Widget" を付ける（例: UserProfileWidget）',
    'StatefulWidgetを優先（シンプル、理解しやすい）',
    'プライベートメソッドは _ プレフィックス',
    '日本語コメントOK（むしろ推奨）',
  ],

  patterns: [
    {
      name: 'Self-Contained Widget',
      description: `
        状態をWidget内で完結させるパターン

        【テンプレート】
        class FooWidget extends StatefulWidget {
          @override
          State<FooWidget> createState() => _FooWidgetState();
        }

        class _FooWidgetState extends State<FooWidget> {
          // 状態はここで管理
          int _counter = 0;

          @override
          Widget build(BuildContext context) {
            return ...;
          }
        }
      `,
    },
    {
      name: 'Service Class',
      description: `
        ビジネスロジックを分離

        【テンプレート】
        class FooService {
          // シングルトンまたはDI
          static final instance = FooService._();
          FooService._();

          Future<Result> doSomething() async {
            // ビジネスロジック
          }
        }
      `,
    },
  ],

  doNotUse: [
    'Riverpod（このプロジェクトの方針で使わない）',
    'BLoC（複雑すぎる）',
    'GetX（Magicすぎる）',
  ],
};
```

---

### Week 3-4: Claude API統合

プロジェクトの知識を使って、Claude APIに問い合わせます。

```typescript
// project-assistant/src/claude-assistant.ts
import Anthropic from '@anthropic-ai/sdk';
import { FLUTTER_COOKBOOK_CONTEXT } from './project-context';

export class ProjectAssistant {
  private claude: Anthropic;

  constructor(apiKey: string) {
    this.claude = new Anthropic({ apiKey });
  }

  /**
   * プロジェクト固有の文脈でコード生成
   */
  async generateWidget(requirement: string): Promise<string> {
    const response = await this.claude.messages.create({
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: 2048,
      messages: [{
        role: 'user',
        content: `
【プロジェクト情報】
${FLUTTER_COOKBOOK_CONTEXT.architecture}

【コーディング規約】
${FLUTTER_COOKBOOK_CONTEXT.codingStandards.join('\n')}

【使用パターン】
${FLUTTER_COOKBOOK_CONTEXT.patterns.map(p => `
## ${p.name}
${p.description}
`).join('\n')}

【使ってはいけないもの】
${FLUTTER_COOKBOOK_CONTEXT.doNotUse.join(', ')}

【要件】
${requirement}

上記のプロジェクト規約に厳密に従って、Widgetを生成してください。
`,
      }],
    });

    return response.content[0].type === 'text'
      ? response.content[0].text
      : '';
  }

  /**
   * コードレビュー（規約チェック）
   */
  async reviewCode(code: string): Promise<string> {
    const response = await this.claude.messages.create({
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: 1024,
      messages: [{
        role: 'user',
        content: `
【プロジェクトのコーディング規約】
${FLUTTER_COOKBOOK_CONTEXT.codingStandards.join('\n')}

【レビュー対象コード】
\`\`\`dart
${code}
\`\`\`

このコードをプロジェクトの規約に照らしてレビューしてください。
違反があれば指摘し、修正案を提示してください。
`,
      }],
    });

    return response.content[0].type === 'text'
      ? response.content[0].text
      : '';
  }
}
```

---

### Month 2: VS Code拡張機能化

```typescript
// extension.ts
import * as vscode from 'vscode';
import { ProjectAssistant } from './project-assistant';

export function activate(context: vscode.ExtensionContext) {
  // Claude APIキーを設定から取得
  const config = vscode.workspace.getConfiguration('flutterCookbook');
  const apiKey = config.get<string>('claudeApiKey') || process.env.CLAUDE_API_KEY;

  if (!apiKey) {
    vscode.window.showErrorMessage('Claude API キーを設定してください');
    return;
  }

  const assistant = new ProjectAssistant(apiKey);

  // コマンド1: Widget生成
  const generateWidget = vscode.commands.registerCommand(
    'flutterCookbook.generateWidget',
    async () => {
      const requirement = await vscode.window.showInputBox({
        prompt: 'どんなWidgetを作りますか？',
        placeHolder: '例: ユーザープロフィール表示',
      });

      if (!requirement) return;

      const editor = vscode.window.activeTextEditor;
      if (!editor) return;

      // プロジェクト固有の文脈でコード生成
      const code = await assistant.generateWidget(requirement);

      // エディタに挿入
      editor.edit(editBuilder => {
        editBuilder.insert(editor.selection.active, code);
      });

      vscode.window.showInformationMessage('Widget生成完了！');
    }
  );

  // コマンド2: コードレビュー
  const reviewCode = vscode.commands.registerCommand(
    'flutterCookbook.reviewCode',
    async () => {
      const editor = vscode.window.activeTextEditor;
      if (!editor) return;

      const code = editor.document.getText(editor.selection);
      if (!code) {
        vscode.window.showWarningMessage('コードを選択してください');
        return;
      }

      // プロジェクトの規約でレビュー
      const review = await assistant.reviewCode(code);

      // 新しいドキュメントで表示
      const doc = await vscode.workspace.openTextDocument({
        content: review,
        language: 'markdown',
      });
      await vscode.window.showTextDocument(doc);
    }
  );

  // コマンド3: Cursorと連携（Cursor用のRules生成）
  const generateCursorRules = vscode.commands.registerCommand(
    'flutterCookbook.generateCursorRules',
    async () => {
      // .cursorrules ファイルを生成
      const rules = `
# Flutter Cookbook プロジェクトルール

${FLUTTER_COOKBOOK_CONTEXT.architecture}

## コーディング規約
${FLUTTER_COOKBOOK_CONTEXT.codingStandards.map(s => `- ${s}`).join('\n')}

## パターン
${FLUTTER_COOKBOOK_CONTEXT.patterns.map(p => `
### ${p.name}
${p.description}
`).join('\n')}

## 使用禁止
${FLUTTER_COOKBOOK_CONTEXT.doNotUse.map(d => `- ${d}`).join('\n')}
`;

      const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
      if (!workspaceFolder) return;

      const cursorRulesPath = vscode.Uri.joinPath(
        workspaceFolder.uri,
        '.cursorrules'
      );

      await vscode.workspace.fs.writeFile(
        cursorRulesPath,
        Buffer.from(rules, 'utf8')
      );

      vscode.window.showInformationMessage('.cursorrules 生成完了！');
    }
  );

  context.subscriptions.push(
    generateWidget,
    reviewCode,
    generateCursorRules
  );
}
```

---

## Cursorとの連携：.cursorrules

Cursorは `.cursorrules` ファイルでプロジェクト固有のルールを設定できます。

```markdown
<!-- .cursorrules -->
# Flutter Cookbook プロジェクトルール

あなたは、このFlutter Cookbookのパターンに従ったコードを生成するアシスタントです。

## アーキテクチャ
- シンプルで保守性の高いFlutterアプリを目指す
- 複雑な状態管理ライブラリは使わない
- Self-Contained Widgetパターンを基本とする

## コーディング規約
- Widget名は必ず末尾に "Widget" を付ける
- StatefulWidgetを優先
- プライベートメソッドは _ プレフィックス
- 日本語コメントOK

## パターン

### Self-Contained Widget
状態をWidget内で完結させる。

\`\`\`dart
class FooWidget extends StatefulWidget {
  @override
  State<FooWidget> createState() => _FooWidgetState();
}

class _FooWidgetState extends State<FooWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return ...;
  }
}
\`\`\`

### Service Class
ビジネスロジックを分離。

\`\`\`dart
class FooService {
  static final instance = FooService._();
  FooService._();

  Future<Result> doSomething() async { ... }
}
\`\`\`

## 使用禁止
- Riverpod（このプロジェクトの方針）
- BLoC（複雑すぎる）
- GetX（Magicすぎる）

## コード生成時の注意
1. 必ずこのパターンに従う
2. 説明は日本語でOK
3. シンプルを心がける
```

**これで、Cursorもプロジェクトのルールを理解します！**

---

## 実際の使用例

### 例1: Widgetの生成

```
【Cursor（.cursorrules あり）】

開発者: "ユーザープロフィール表示のWidgetを作って"

Cursor:
```dart
/// ユーザープロフィール表示Widget
///
/// Self-Contained Widgetパターンで実装
class UserProfileWidget extends StatefulWidget {
  final String userId;

  const UserProfileWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await UserService.instance.getUser(widget.userId);
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(_user!.name, style: Theme.of(context).textTheme.headline6),
            Text(_user!.email),
          ],
        ),
      ),
    );
  }
}
```

→ プロジェクトのパターンに完全準拠！
```

### 例2: VS Code拡張でコードレビュー

```
【コードを選択して「Code Review」実行】

対象コード:
class UserProfile extends StatelessWidget {
  final user;
  UserProfile(this.user);
  ...
}

レビュー結果:
## コードレビュー

以下の点を修正してください:

1. ❌ Widget名に "Widget" サフィックスがない
   - `UserProfile` → `UserProfileWidget`

2. ❌ StatelessWidget を使用
   - このプロジェクトではStatefulWidgetを優先

3. ❌ 型がない（`final user`）
   - `final User user` とする

4. ❌ constコンストラクタではない
   - `const UserProfileWidget` にする

## 修正案:
class UserProfileWidget extends StatefulWidget {
  final User user;

  const UserProfileWidget({
    Key? key,
    required this.user,
  }) : super(key: key);
  ...
}
```

---

## Cursor + Claude Pro の組み合わせの利点

| 機能 | Cursor単体 | Cursor + Claude Pro |
|------|-----------|---------------------|
| コード補完 | ✅ 高速 | ✅ 高速 |
| プロジェクト理解 | △ 汎用的 | ✅ 深い理解 |
| カスタムパターン | △ .cursorrules | ✅ API + .cursorrules |
| コードレビュー | △ 基本的 | ✅ 規約準拠チェック |
| 定額料金 | ✅ $20 | ✅ $20 + $25 |
| データ送信先 | Cursor社 | 自分のAPIキー |

**コスト: 月$45（約5,000円）**
**生産性向上: 少なくとも2-3倍**
**→ 十分ペイする**

---

## チーム展開

### GitHubで共有

```markdown
# README.md

## 開発環境セットアップ

### 1. Cursorインストール
https://cursor.sh/

### 2. VS Code拡張インストール
\`\`\`bash
code --install-extension flutter-cookbook-assistant
\`\`\`

### 3. Claude APIキー設定
\`\`\`bash
# .env
CLAUDE_API_KEY=your_api_key_here
\`\`\`

### 4. プロジェクトルール確認
\`.cursorrules\` に自動的に適用されます。

## 使い方

### Widget生成
1. Cmd/Ctrl + Shift + P
2. "Flutter Cookbook: Generate Widget"
3. 要件を入力

### コードレビュー
1. コードを選択
2. Cmd/Ctrl + Shift + P
3. "Flutter Cookbook: Review Code"
```

---

## コスト対効果

### 従来の開発

```
GitHub Copilot: 月$10
  ↓
毎回、規約を説明
  ↓
コピペ、修正で時間ロス
  ↓
レビューで指摘される
  ↓
手戻り

時間ロス: 月10-20時間
```

### BYOA開発

```
Cursor + Claude Pro: 月$45（約5,000円）
  ↓
自動的に規約準拠
  ↓
レビュー指摘が激減
  ↓
品質向上

時間節約: 月10-20時間
時給換算: 2,500-5,000円/時間節約
→ 十分ペイする
```

---

## まとめ：開発ツールのBYOA

### なぜBYOAが向いているか

```
✅ 開発者自身がユーザー
   → ニーズを完全に理解

✅ カスタマイズが価値
   → 汎用ツールでは不十分

✅ 技術的ハードルが低い
   → すでにプログラミングができる

✅ 改善サイクルが高速
   → 使いながらその場で改善

✅ チームで共有しやすい
   → GitHubで簡単に展開
```

### Cursor + Claude Pro が最適な理由

```
✅ Cursor: 開発時のAI支援（リアルタイム）
✅ Claude Pro: プロジェクト固有の深い理解（定額）
✅ .cursorrules: プロジェクトルール共有
✅ VS Code拡張: 高度なカスタマイズ

コスト: 月5,000円
効果: 生産性2-3倍、品質向上
```

**開発ツールは、BYOAの入門に最適です。**
**Cursor + Claude Proの組み合わせで、プロジェクト固有の強力な開発環境が構築できます。**

次のレシピ（実践ガイド）で、セットアップから運営までを詳しく学びましょう！
