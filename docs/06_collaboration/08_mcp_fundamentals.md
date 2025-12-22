# レシピ#6-8: MCP（Model Context Protocol）でClaudeを拡張する

06章で個人用アプリを作り、07章でコラボレーションを通じて進化させました。しかし、アプリが成長するにつれて、**外部データや専門的なツールとの連携**が必要になってきます。

**MCP（Model Context Protocol）**は、Claudeを外部システムと安全に連携させるための標準プロトコルです。

このレシピでは、MCPの基礎から、既存MCPサーバーの活用、そして自分専用のMCPサーバーの作成方法まで学びます。

---

## MCPとは何か

### 従来の課題

```
【アプリ開発での課題】

ToDoアプリを作った
  ↓
「Googleカレンダーと連携したい」
  ↓
でも...
❌ APIキーの管理が複雑
❌ 毎回認証コードを書く必要
❌ エラーハンドリングが大変
❌ セキュリティリスク
```

### MCPによる解決

```
【MCPを使うと】

MCP Server（カレンダー連携）
  ↓
Claude が MCP を通じて安全にアクセス
  ↓
✅ 認証・セキュリティは MCP Server が管理
✅ 一度設定すれば使い続けられる
✅ エラーハンドリングも MCP Server が対応
✅ あなたは「カレンダーに予定を追加して」と話すだけ
```

---

### MCPの3つの重要な概念

#### 1. MCP Server

**外部システムとの橋渡し役**

```
【役割】
- 外部APIへの接続
- 認証・セキュリティ管理
- データの取得・操作
- エラーハンドリング

【例】
- Google Calendar MCP: カレンダー操作
- GitHub MCP: リポジトリ・Issue管理
- Database MCP: データベースアクセス
- File System MCP: ローカルファイル操作
```

#### 2. MCP Client（Claude）

**MCPサーバーを利用する側**

```
Claude が:
- MCP Server に接続
- 必要なデータを要求
- 返ってきたデータを理解
- ユーザーに分かりやすく提示
```

#### 3. Tools & Resources

**MCPサーバーが提供する機能**

```
【Tools（ツール）】
実行可能な操作
- add_calendar_event（予定追加）
- search_files（ファイル検索）
- query_database（DB検索）

【Resources（リソース）】
アクセス可能なデータ
- カレンダーの予定一覧
- ファイルの内容
- データベースのレコード
```

---

### なぜBYOA開発でMCPが重要か

```
【06章】個人用アプリ
- データはLocalStorageのみ
- 機能は限定的

【07章】特化型機能の追加
- データを活用
- 独自の価値創出

【08章】MCPによる拡張
✅ 外部サービスと連携
✅ 専門的なデータにアクセス
✅ 既存ツールを活用
✅ セキュアな統合

【例】
- 育児アプリ: 地域の保育園情報API連携
- 栽培アプリ: 気象データAPI連携
- 家計簿: 銀行API連携（将来）
- 読書記録: 書籍情報API連携
```

---

## 既存のMCPサーバーを使う

### 人気のMCPサーバー

#### 1. Filesystem MCP

**ローカルファイルへの安全なアクセス**

```
できること:
- ファイルの読み書き
- ディレクトリ一覧取得
- ファイル検索
- テキスト置換

使用例:
「プロジェクト内の全てのTODOコメントを探して」
「settings.jsonを読んで、設定を教えて」
```

#### 2. GitHub MCP

**GitHubリポジトリとの統合**

```
できること:
- Issue の作成・検索
- Pull Request の管理
- ファイル内容の取得
- コミット履歴の確認

使用例:
「このリポジトリの未解決Issueを一覧表示して」
「新しいPRを作成して、レビュワーにAさんを指定」
```

#### 3. PostgreSQL MCP

**データベースへのアクセス**

```
できること:
- SQLクエリ実行
- テーブル構造確認
- データの検索・集計

使用例:
「先月の売上を集計して」
「ユーザー数が多い上位10都市は？」
```

#### 4. Google Drive MCP

**Google Driveファイルの操作**

```
できること:
- ファイル・フォルダ検索
- ファイル内容の読み取り
- 新規ファイル作成
- 共有設定の管理

使用例:
「プロジェクト資料フォルダの最新ファイルを探して」
「この文書をPDFで保存して、チームと共有」
```

---

## Claude Desktop/WebでのMCP設定

### Claude Desktopでの設定

**Step 1: 設定ファイルの場所**

```bash
# macOS
~/Library/Application Support/Claude/claude_desktop_config.json

# Windows
%APPDATA%\Claude\claude_desktop_config.json

# Linux
~/.config/Claude/claude_desktop_config.json
```

**Step 2: 設定ファイルの編集**

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/username/Documents"
      ]
    },
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your_github_token_here"
      }
    }
  }
}
```

**Step 3: Claude Desktop を再起動**

```
Claude Desktop を終了 → 再起動
→ MCPサーバーが自動的に起動
→ Claude のツールパネルに表示される
```

---

### Claude WebでのMCP設定（将来対応予定）

```
現在、MCPは主にClaude Desktopで利用可能です。

Web版での対応は、Anthropicが段階的に展開中です。
最新情報は公式ドキュメントを確認してください:
https://docs.anthropic.com/claude/docs/model-context-protocol
```

---

### MCP サーバーの動作確認

**Claude Desktop で確認:**

```
【あなた】
利用可能なMCPツールを教えて

【Claude】
以下のMCPツールが利用可能です:

Filesystem:
- read_file: ファイルを読む
- write_file: ファイルに書き込む
- list_directory: ディレクトリ一覧
- search_files: ファイル検索

GitHub:
- create_issue: Issue作成
- search_issues: Issue検索
- get_file_contents: ファイル内容取得
- create_pull_request: PR作成

これらのツールを使って、何かお手伝いしましょうか？
```

---

## カスタムMCPサーバーの作成

### なぜカスタムMCPサーバーを作るのか

```
【既存MCPサーバーの限界】

既存のMCPサーバー:
- 汎用的な機能
- 特定のドメインに特化していない

カスタムMCPサーバー:
✅ 自分の領域に特化した機能
✅ 独自のデータソース
✅ 業務固有のロジック
✅ BYOA開発の真価

【例】
- 育児アプリ: 地域の保育園API → カスタムMCP
- 栽培アプリ: 気象データ + 栽培DB → カスタムMCP
- 家計簿: 複数銀行の統合 → カスタムMCP
```

---

### 最初のカスタムMCPサーバー（TypeScript）

**例: タスク管理MCP Server**

**Step 1: プロジェクト作成**

```bash
# 新規ディレクトリ作成
mkdir mcp-task-manager
cd mcp-task-manager

# npm初期化
npm init -y

# 必要なパッケージをインストール
npm install @modelcontextprotocol/sdk
npm install -D typescript @types/node tsx

# TypeScript設定
npx tsc --init
```

**Step 2: MCP Server 実装**

```typescript
// src/index.ts
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

// タスクの型定義
interface Task {
  id: string;
  title: string;
  completed: boolean;
  dueDate?: string;
  priority: 'high' | 'medium' | 'low';
}

// シンプルなインメモリストレージ
let tasks: Task[] = [];

// MCP Server作成
const server = new Server(
  {
    name: 'task-manager',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// 利用可能なツールのリスト
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'add_task',
        description: '新しいタスクを追加します',
        inputSchema: {
          type: 'object',
          properties: {
            title: {
              type: 'string',
              description: 'タスクのタイトル',
            },
            dueDate: {
              type: 'string',
              description: '期限（YYYY-MM-DD形式）',
            },
            priority: {
              type: 'string',
              enum: ['high', 'medium', 'low'],
              description: '優先度',
            },
          },
          required: ['title'],
        },
      },
      {
        name: 'list_tasks',
        description: 'タスク一覧を取得します',
        inputSchema: {
          type: 'object',
          properties: {
            filter: {
              type: 'string',
              enum: ['all', 'active', 'completed'],
              description: 'フィルター条件',
            },
          },
        },
      },
      {
        name: 'complete_task',
        description: 'タスクを完了にします',
        inputSchema: {
          type: 'object',
          properties: {
            taskId: {
              type: 'string',
              description: 'タスクID',
            },
          },
          required: ['taskId'],
        },
      },
      {
        name: 'delete_task',
        description: 'タスクを削除します',
        inputSchema: {
          type: 'object',
          properties: {
            taskId: {
              type: 'string',
              description: 'タスクID',
            },
          },
          required: ['taskId'],
        },
      },
    ],
  };
});

// ツール実行のハンドラ
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case 'add_task': {
      const task: Task = {
        id: Date.now().toString(),
        title: args.title as string,
        completed: false,
        dueDate: args.dueDate as string | undefined,
        priority: (args.priority as Task['priority']) || 'medium',
      };
      tasks.push(task);

      return {
        content: [
          {
            type: 'text',
            text: `タスクを追加しました: ${task.title} (ID: ${task.id})`,
          },
        ],
      };
    }

    case 'list_tasks': {
      const filter = (args.filter as string) || 'all';
      let filteredTasks = tasks;

      if (filter === 'active') {
        filteredTasks = tasks.filter((t) => !t.completed);
      } else if (filter === 'completed') {
        filteredTasks = tasks.filter((t) => t.completed);
      }

      const taskList = filteredTasks
        .map(
          (t) =>
            `[${t.completed ? 'x' : ' '}] ${t.title} (${t.priority}) ${
              t.dueDate ? `期限: ${t.dueDate}` : ''
            }`
        )
        .join('\n');

      return {
        content: [
          {
            type: 'text',
            text: taskList || 'タスクがありません',
          },
        ],
      };
    }

    case 'complete_task': {
      const taskId = args.taskId as string;
      const task = tasks.find((t) => t.id === taskId);

      if (!task) {
        throw new Error(`タスクが見つかりません: ${taskId}`);
      }

      task.completed = true;

      return {
        content: [
          {
            type: 'text',
            text: `タスクを完了しました: ${task.title}`,
          },
        ],
      };
    }

    case 'delete_task': {
      const taskId = args.taskId as string;
      const index = tasks.findIndex((t) => t.id === taskId);

      if (index === -1) {
        throw new Error(`タスクが見つかりません: ${taskId}`);
      }

      const deleted = tasks.splice(index, 1)[0];

      return {
        content: [
          {
            type: 'text',
            text: `タスクを削除しました: ${deleted.title}`,
          },
        ],
      };
    }

    default:
      throw new Error(`未知のツール: ${name}`);
  }
});

// サーバー起動
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Task Manager MCP Server running on stdio');
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
```

**Step 3: package.json 設定**

```json
{
  "name": "mcp-task-manager",
  "version": "1.0.0",
  "type": "module",
  "bin": {
    "mcp-task-manager": "./build/index.js"
  },
  "scripts": {
    "build": "tsc",
    "prepare": "npm run build"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.3.0",
    "tsx": "^4.7.0"
  }
}
```

**Step 4: TypeScript設定（tsconfig.json）**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "outDir": "./build",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

**Step 5: ビルド**

```bash
npm run build
```

**Step 6: Claude Desktop に登録**

```json
// claude_desktop_config.json
{
  "mcpServers": {
    "task-manager": {
      "command": "node",
      "args": [
        "/path/to/mcp-task-manager/build/index.js"
      ]
    }
  }
}
```

**Step 7: Claude Desktop で使用**

```
【あなた】
「レシピを書く」というタスクを追加して、優先度は高で

【Claude】
Task Manager MCPを使用してタスクを追加します...

タスクを追加しました: レシピを書く (ID: 1734876543210)

【あなた】
タスク一覧を表示して

【Claude】
[ ] レシピを書く (high)
```

---

### PythonでのMCPサーバー実装

**例: 気象データMCP Server**

```python
# weather_mcp_server.py
import asyncio
import json
from typing import Any
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent
import httpx

# 気象データAPI（Open-Meteo）を使用
WEATHER_API_BASE = "https://api.open-meteo.com/v1"

# MCP Server 作成
app = Server("weather-service")

@app.list_tools()
async def list_tools() -> list[Tool]:
    """利用可能なツールのリスト"""
    return [
        Tool(
            name="get_current_weather",
            description="指定した都市の現在の天気を取得します",
            inputSchema={
                "type": "object",
                "properties": {
                    "latitude": {
                        "type": "number",
                        "description": "緯度"
                    },
                    "longitude": {
                        "type": "number",
                        "description": "経度"
                    }
                },
                "required": ["latitude", "longitude"]
            }
        ),
        Tool(
            name="get_forecast",
            description="7日間の天気予報を取得します",
            inputSchema={
                "type": "object",
                "properties": {
                    "latitude": {
                        "type": "number",
                        "description": "緯度"
                    },
                    "longitude": {
                        "type": "number",
                        "description": "経度"
                    }
                },
                "required": ["latitude", "longitude"]
            }
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: Any) -> list[TextContent]:
    """ツール実行"""

    if name == "get_current_weather":
        lat = arguments["latitude"]
        lon = arguments["longitude"]

        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{WEATHER_API_BASE}/forecast",
                params={
                    "latitude": lat,
                    "longitude": lon,
                    "current_weather": "true"
                }
            )
            data = response.json()

        weather = data["current_weather"]
        result = f"""
現在の天気:
気温: {weather['temperature']}°C
風速: {weather['windspeed']} km/h
天気コード: {weather['weathercode']}
        """.strip()

        return [TextContent(type="text", text=result)]

    elif name == "get_forecast":
        lat = arguments["latitude"]
        lon = arguments["longitude"]

        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"{WEATHER_API_BASE}/forecast",
                params={
                    "latitude": lat,
                    "longitude": lon,
                    "daily": "temperature_2m_max,temperature_2m_min,precipitation_sum",
                    "timezone": "Asia/Tokyo"
                }
            )
            data = response.json()

        daily = data["daily"]
        forecast_lines = []

        for i in range(7):
            date = daily["time"][i]
            temp_max = daily["temperature_2m_max"][i]
            temp_min = daily["temperature_2m_min"][i]
            precip = daily["precipitation_sum"][i]

            forecast_lines.append(
                f"{date}: 最高{temp_max}°C / 最低{temp_min}°C / 降水量{precip}mm"
            )

        result = "7日間の天気予報:\n" + "\n".join(forecast_lines)

        return [TextContent(type="text", text=result)]

    else:
        raise ValueError(f"Unknown tool: {name}")

async def main():
    """サーバー起動"""
    async with stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            app.create_initialization_options()
        )

if __name__ == "__main__":
    asyncio.run(main())
```

**requirements.txt**

```
mcp>=0.9.0
httpx>=0.27.0
```

**インストールと設定**

```bash
# 依存関係インストール
pip install -r requirements.txt

# Claude Desktop 設定
# claude_desktop_config.json に追加
{
  "mcpServers": {
    "weather": {
      "command": "python",
      "args": [
        "/path/to/weather_mcp_server.py"
      ]
    }
  }
}
```

**使用例**

```
【あなた】
東京（緯度35.6762、経度139.6503）の現在の天気を教えて

【Claude】
Weather MCPを使用して天気を取得します...

現在の天気:
気温: 15.2°C
風速: 12.5 km/h
天気コード: 1 (晴れ)

【あなた】
7日間の予報も見せて

【Claude】
7日間の天気予報:
2025-12-22: 最高16°C / 最低8°C / 降水量0mm
2025-12-23: 最高14°C / 最低7°C / 降水量0mm
2025-12-24: 最高15°C / 最低9°C / 降水量2mm
...
```

---

## BYOAアプリとMCPの連携

### パターン1: WebアプリからMCP経由でデータ取得

**栽培アプリの例**

```html
<!-- cultivation-app.html -->
<!DOCTYPE html>
<html lang="ja">
<head>
  <title>栽培管理アプリ</title>
</head>
<body>
  <h1>栽培管理</h1>

  <div id="weather-info">
    <h2>今日の天気</h2>
    <button onclick="updateWeather()">天気を更新</button>
    <div id="weather-display"></div>
  </div>

  <div id="cultivation-log">
    <h2>栽培記録</h2>
    <textarea id="work-note" placeholder="今日の作業"></textarea>
    <button onclick="saveLog()">記録</button>
  </div>

  <script>
    // Claude との連携を想定したコード
    // 実際には Claude Projects で実行

    async function updateWeather() {
      // Claude に依頼
      const prompt = `
気象MCPを使って、東京の現在の天気と
今週の予報を取得して、栽培に適した条件か判断してください。
      `;

      // Claude が MCP を使って天気を取得
      // 結果を表示
      document.getElementById('weather-display').innerHTML = `
        <p>気温: 15°C（栽培適温）</p>
        <p>降水: なし</p>
        <p><strong>本日の栽培作業: 適しています</strong></p>
      `;
    }

    function saveLog() {
      const note = document.getElementById('work-note').value;
      const log = {
        date: new Date().toISOString(),
        work: note,
        weather: '晴れ、15°C' // MCP経由で取得
      };

      // LocalStorageに保存
      const logs = JSON.parse(localStorage.getItem('logs') || '[]');
      logs.push(log);
      localStorage.setItem('logs', JSON.stringify(logs));

      alert('記録を保存しました');
      document.getElementById('work-note').value = '';
    }
  </script>
</body>
</html>
```

---

### パターン2: Claude Projects + MCP で統合開発

**育児アプリの例**

```markdown
# Claude Project: 育児記録アプリ

## カスタム指示

このプロジェクトは育児記録アプリの開発です。

利用可能なMCP:
- filesystem: アプリのコード管理
- childcare-info: 地域の保育園情報（カスタムMCP）

## 使い方

【あなた】
アプリに「近くの保育園検索」機能を追加したい。
現在地から3km以内の保育園を表示する機能。

【Claude】
Childcare Info MCPを使って、保育園情報を取得できます。
以下のコードを追加しましょう:

```javascript
// 保育園検索機能
async function searchNearbyNurseries(latitude, longitude) {
  // この部分で Claude が MCP を呼び出す想定
  const nurseries = await getNurseriesWithinRadius(
    latitude,
    longitude,
    3000 // 3km
  );

  return nurseries.map(n => ({
    name: n.name,
    address: n.address,
    distance: n.distance,
    capacity: n.capacity,
    phone: n.phone
  }));
}
```

Filesystem MCPを使って、このコードを
`src/nursery-search.js` に保存しました。
```

---

### パターン3: 複数MCPの組み合わせ

**プロジェクト管理アプリの例**

```
利用MCP:
- GitHub MCP: Issue管理
- Task Manager MCP: 個人タスク
- Weather MCP: 作業環境判断

【シナリオ】
「今週のスプリント計画を立てて」

【Claude の動作】
1. GitHub MCPでマイルストーンを確認
2. Task Manager MCPで個人タスクを取得
3. Weather MCPで今週の天気を確認
   → 雨の日は屋内作業を優先
4. 総合的なスプリント計画を提案

【出力例】
今週のスプリント計画:

月曜（晴れ）:
- GitHub Issue #45: 外部API統合テスト
- 個人タスク: ドキュメント更新

火曜（雨）:
- GitHub Issue #47: リファクタリング
- 個人タスク: コードレビュー

...
```

---

## MCPのセキュリティとベストプラクティス

### セキュリティ考慮事項

```
【重要】

❌ 避けるべきこと:
- APIキーをコードにハードコーディング
- 機密情報をログに出力
- 認証なしで外部公開

✅ 推奨:
- 環境変数でAPIキー管理
- 適切なエラーハンドリング
- ローカルでの実行を基本とする
```

**環境変数の使用例**

```json
// claude_desktop_config.json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

```bash
# .env ファイル（gitignoreに追加）
GITHUB_TOKEN=ghp_your_token_here
```

---

### ベストプラクティス

#### 1. エラーハンドリング

```typescript
// 良い例
try {
  const result = await fetchData();
  return { content: [{ type: 'text', text: result }] };
} catch (error) {
  return {
    content: [{
      type: 'text',
      text: `エラーが発生しました: ${error.message}`
    }],
    isError: true
  };
}
```

#### 2. 入力バリデーション

```typescript
// 入力値の検証
if (!args.taskId || typeof args.taskId !== 'string') {
  throw new Error('taskIdは必須です（文字列）');
}

if (args.priority && !['high', 'medium', 'low'].includes(args.priority)) {
  throw new Error('priorityは high, medium, low のいずれかです');
}
```

#### 3. ログ出力

```typescript
// stderr にログ（Claude には表示されない）
console.error('[MCP] Task added:', task.id);
console.error('[MCP] Current tasks count:', tasks.length);

// エラーログ
console.error('[MCP ERROR]', error);
```

#### 4. リソース管理

```typescript
// データベース接続は適切にクローズ
const db = await openDatabase();
try {
  const result = await db.query('SELECT * FROM tasks');
  return formatResult(result);
} finally {
  await db.close();
}
```

---

## トラブルシューティング

### よくある問題と解決方法

#### 1. MCPサーバーが起動しない

```bash
# ログ確認
# macOS/Linux
tail -f ~/Library/Logs/Claude/mcp*.log

# 設定ファイルの文法チェック
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | jq .
```

**解決方法:**
- JSONの文法エラーを確認
- コマンドパスが正しいか確認
- 依存関係がインストールされているか確認

#### 2. ツールが表示されない

```
【確認事項】
✓ server.setRequestHandler(ListToolsRequestSchema) が実装されているか
✓ tools 配列が正しく返されているか
✓ Claude Desktop を再起動したか
```

#### 3. ツール実行時のエラー

```typescript
// デバッグログを追加
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  console.error('[DEBUG] Tool called:', request.params.name);
  console.error('[DEBUG] Arguments:', request.params.arguments);

  // ... ツール実行
});
```

---

## 次のステップ

### 学んだこと

```
✅ MCPの基本概念（Server, Client, Tools, Resources）
✅ 既存MCPサーバーの活用
✅ Claude Desktop での設定方法
✅ TypeScript/Python でのカスタムMCP作成
✅ BYOAアプリとの連携パターン
✅ セキュリティとベストプラクティス
```

### 09章で学ぶこと

**実践的なMCP活用編**

```
次のレシピでは:

✅ 育児アプリ × MCP の具体的実装
✅ 栽培アプリ × 気象データ連携
✅ 家計簿アプリ × データ分析MCP
✅ 読書アプリ × 書籍情報API連携
✅ 特化型機能とMCPの組み合わせ
✅ 実用的なユースケース集

→ 07章の特化型機能に、MCPを統合して
  さらに強力なBYOAアプリを構築します！
```

---

## まとめ

### MCPがBYOA開発にもたらす価値

```
【06章】個人用アプリ
- LocalStorageのみ
- 閉じた環境

【07章】コラボで進化
- 特化型機能
- データ活用

【08章】MCPで拡張
✅ 外部システムと安全に連携
✅ 専門的なデータへアクセス
✅ 既存APIの活用
✅ セキュアな統合

【09章】実践活用（次回）
✅ 具体的なユースケース
✅ 特化型機能との統合
✅ 実用的なパターン
```

---

**MCPは、あなたのBYOAアプリを外の世界とつなぐ架け橋です。**

**セキュアに、柔軟に、自分だけの統合を実現できます。**

次のレシピで、MCPを使った実践的な開発を学びましょう！
