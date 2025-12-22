# レシピ#6-9: 実践的なMCP活用でBYOAアプリを進化させる

08章でMCPの基礎を学びました。この章では、07章で作った**特化型機能**に**MCP**を統合して、さらに強力なBYOAアプリを構築する方法を学びます。

実際のユースケースを通じて、MCPがどのように独自の価値を生み出すかを見ていきましょう。

---

## MCPが特化型機能にもたらす価値

### 07章の特化型機能の限界

```
【育児アプリ】
✅ 記録からアルバム生成（07章で実装）
❌ でも、地域の保育園情報は手動で探す
❌ 予防接種スケジュールは別管理

【栽培アプリ】
✅ 栽培記録から販売ページ生成（07章で実装）
❌ でも、天気は自分で確認
❌ 市場価格は別途リサーチ

【家計簿アプリ】
✅ 投資分析機能（07章で実装）
❌ でも、株価は手動で入力
❌ 為替レートも手動更新
```

### MCPによる拡張

```
【育児アプリ + MCP】
✅ 地域保育園情報を自動取得（Nursery MCP）
✅ 予防接種スケジュールを統合（Health MCP）
✅ 成長データを医療基準と比較

【栽培アプリ + MCP】
✅ リアルタイム気象データ（Weather MCP）
✅ 市場価格情報（Market MCP）
✅ 最適な出荷タイミングを提案

【家計簿アプリ + MCP】
✅ 株価・為替の自動更新（Finance MCP）
✅ ニュースと投資判断の統合（News MCP）
✅ ポートフォリオの最適化提案
```

---

## ユースケース1: 育児アプリ × MCP

### 実装する機能

```
【基本機能】（06-07章で実装済み）
- 日々の成長記録
- アルバム自動生成

【MCP統合で追加】
✅ 地域の保育園情報検索
✅ 予防接種スケジュール管理
✅ 成長曲線との比較
✅ 地域イベント情報
```

---

### カスタムMCP: 保育園情報サーバー

**nursery-mcp-server.ts**

```typescript
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

// 保育園データ型定義
interface Nursery {
  id: string;
  name: string;
  address: string;
  latitude: number;
  longitude: number;
  capacity: number;
  ageRange: string;
  phone: string;
  website?: string;
  openingHours: string;
  features: string[];
}

// サンプルデータ（実際はDBやAPIから取得）
const nurseries: Nursery[] = [
  {
    id: '1',
    name: 'さくら保育園',
    address: '東京都渋谷区○○1-2-3',
    latitude: 35.6586,
    longitude: 139.7454,
    capacity: 60,
    ageRange: '0-5歳',
    phone: '03-1234-5678',
    openingHours: '7:30-18:30',
    features: ['園庭あり', '給食あり', '延長保育'],
  },
  {
    id: '2',
    name: 'ひまわり保育園',
    address: '東京都渋谷区△△2-3-4',
    latitude: 35.6612,
    longitude: 139.7435,
    capacity: 40,
    ageRange: '1-5歳',
    phone: '03-2345-6789',
    openingHours: '8:00-18:00',
    features: ['少人数制', '英語教育', '食育'],
  },
];

// 2点間の距離計算（Haversine公式）
function calculateDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371; // 地球の半径（km）
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

const server = new Server(
  {
    name: 'nursery-info',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'search_nurseries',
        description: '現在地から指定距離内の保育園を検索します',
        inputSchema: {
          type: 'object',
          properties: {
            latitude: {
              type: 'number',
              description: '緯度',
            },
            longitude: {
              type: 'number',
              description: '経度',
            },
            radius: {
              type: 'number',
              description: '検索半径（km）',
              default: 3,
            },
            ageRange: {
              type: 'string',
              description: '対象年齢（例: 0歳, 1-2歳）',
            },
          },
          required: ['latitude', 'longitude'],
        },
      },
      {
        name: 'get_nursery_details',
        description: '保育園の詳細情報を取得します',
        inputSchema: {
          type: 'object',
          properties: {
            nurseryId: {
              type: 'string',
              description: '保育園ID',
            },
          },
          required: ['nurseryId'],
        },
      },
      {
        name: 'get_vaccination_schedule',
        description: '予防接種スケジュールを取得します',
        inputSchema: {
          type: 'object',
          properties: {
            birthDate: {
              type: 'string',
              description: '生年月日（YYYY-MM-DD）',
            },
            completedVaccinations: {
              type: 'array',
              items: { type: 'string' },
              description: '接種済みのワクチン',
            },
          },
          required: ['birthDate'],
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case 'search_nurseries': {
      const lat = args.latitude as number;
      const lon = args.longitude as number;
      const radius = (args.radius as number) || 3;

      const nearbyNurseries = nurseries
        .map((n) => ({
          ...n,
          distance: calculateDistance(lat, lon, n.latitude, n.longitude),
        }))
        .filter((n) => n.distance <= radius)
        .sort((a, b) => a.distance - b.distance);

      const result = nearbyNurseries
        .map(
          (n) => `
📍 ${n.name}
   住所: ${n.address}
   距離: ${n.distance.toFixed(2)}km
   定員: ${n.capacity}名
   対象: ${n.ageRange}
   特徴: ${n.features.join(', ')}
   電話: ${n.phone}
          `
        )
        .join('\n---\n');

      return {
        content: [
          {
            type: 'text',
            text: result || '指定範囲内に保育園が見つかりませんでした',
          },
        ],
      };
    }

    case 'get_nursery_details': {
      const nurseryId = args.nurseryId as string;
      const nursery = nurseries.find((n) => n.id === nurseryId);

      if (!nursery) {
        throw new Error(`保育園が見つかりません: ${nurseryId}`);
      }

      const details = `
# ${nursery.name}

## 基本情報
- 住所: ${nursery.address}
- 電話: ${nursery.phone}
- 開園時間: ${nursery.openingHours}
${nursery.website ? `- Website: ${nursery.website}` : ''}

## 定員・対象年齢
- 定員: ${nursery.capacity}名
- 対象: ${nursery.ageRange}

## 特徴
${nursery.features.map((f) => `- ${f}`).join('\n')}
      `.trim();

      return {
        content: [{ type: 'text', text: details }],
      };
    }

    case 'get_vaccination_schedule': {
      const birthDate = new Date(args.birthDate as string);
      const completed = (args.completedVaccinations as string[]) || [];

      // 予防接種スケジュール（日本の標準的なスケジュール）
      const schedule = [
        {
          name: 'ヒブワクチン',
          timing: '生後2ヶ月〜',
          doses: 4,
          interval: '4-8週間隔で3回、追加1回',
        },
        {
          name: '小児用肺炎球菌',
          timing: '生後2ヶ月〜',
          doses: 4,
          interval: '4週間隔で3回、追加1回',
        },
        {
          name: 'B型肝炎',
          timing: '生後2ヶ月〜',
          doses: 3,
          interval: '4週間隔で2回、追加1回',
        },
        {
          name: 'ロタウイルス',
          timing: '生後2ヶ月〜',
          doses: 2,
          interval: '4週間隔',
        },
        {
          name: '四種混合（DPT-IPV）',
          timing: '生後2ヶ月〜',
          doses: 4,
          interval: '3-8週間隔で3回、追加1回',
        },
        {
          name: 'BCG',
          timing: '生後5ヶ月〜8ヶ月未満',
          doses: 1,
          interval: '1回',
        },
        {
          name: 'MR（麻しん風しん混合）',
          timing: '1歳〜',
          doses: 2,
          interval: '1期、2期（年長）',
        },
        {
          name: '水痘（水ぼうそう）',
          timing: '1歳〜',
          doses: 2,
          interval: '3ヶ月以上あけて2回',
        },
      ];

      const now = new Date();
      const ageInMonths =
        (now.getTime() - birthDate.getTime()) / (1000 * 60 * 60 * 24 * 30);

      const upcoming = schedule
        .filter((v) => !completed.includes(v.name))
        .map((v) => {
          let status = '今後接種';
          if (v.timing.includes('2ヶ月') && ageInMonths >= 2) {
            status = '接種可能';
          } else if (v.timing.includes('5ヶ月') && ageInMonths >= 5) {
            status = '接種可能';
          } else if (v.timing.includes('1歳') && ageInMonths >= 12) {
            status = '接種可能';
          }

          return `
${v.name}
  接種時期: ${v.timing}
  回数: ${v.doses}回（${v.interval}）
  状態: ${status}
          `.trim();
        })
        .join('\n\n');

      const result = `
# 予防接種スケジュール

現在の月齢: ${Math.floor(ageInMonths)}ヶ月

## 接種済み
${completed.length > 0 ? completed.map((v) => `- ${v}`).join('\n') : 'なし'}

## 今後の予定
${upcoming}
      `.trim();

      return {
        content: [{ type: 'text', text: result }],
      };
    }

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Nursery Info MCP Server running');
}

main().catch(console.error);
```

---

### 育児アプリでのMCP活用

**Claude Projectsでの使用例**

```
【あなた】
現在地（緯度35.6586、経度139.7454）から
2km以内の保育園を探して

【Claude】
Nursery Info MCPを使って検索します...

📍 さくら保育園
   住所: 東京都渋谷区○○1-2-3
   距離: 0.00km
   定員: 60名
   対象: 0-5歳
   特徴: 園庭あり, 給食あり, 延長保育
   電話: 03-1234-5678

---

📍 ひまわり保育園
   住所: 東京都渋谷区△△2-3-4
   距離: 0.35km
   定員: 40名
   対象: 1-5歳
   特徴: 少人数制, 英語教育, 食育
   電話: 03-2345-6789

【あなた】
さくら保育園の詳細を教えて

【Claude】
[詳細情報を表示]

【あなた】
子供の生年月日は2024-06-15。
予防接種スケジュールを確認して

【Claude】
# 予防接種スケジュール

現在の月齢: 6ヶ月

## 今後の予定

ヒブワクチン
  接種時期: 生後2ヶ月〜
  回数: 4回（4-8週間隔で3回、追加1回）
  状態: 接種可能

小児用肺炎球菌
  接種時期: 生後2ヶ月〜
  回数: 4回（4週間隔で3回、追加1回）
  状態: 接種可能

BCG
  接種時期: 生後5ヶ月〜8ヶ月未満
  回数: 1回
  状態: 接種可能

...
```

---

## ユースケース2: 栽培アプリ × MCP

### 実装する機能

```
【基本機能】（06-07章で実装済み）
- 栽培記録
- 販売用Web生成

【MCP統合で追加】
✅ リアルタイム気象データ
✅ 栽培アドバイス（気象条件に基づく）
✅ 市場価格情報
✅ 最適な出荷タイミング提案
```

---

### カスタムMCP: 農業支援サーバー

**agriculture-mcp-server.py**

```python
import asyncio
from typing import Any
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent
import httpx
from datetime import datetime, timedelta

app = Server("agriculture-support")

# 気象データ取得（Open-Meteo API）
async def get_weather_data(latitude: float, longitude: float):
    async with httpx.AsyncClient() as client:
        response = await client.get(
            "https://api.open-meteo.com/v1/forecast",
            params={
                "latitude": latitude,
                "longitude": longitude,
                "daily": "temperature_2m_max,temperature_2m_min,precipitation_sum,soil_moisture_0_to_10cm",
                "timezone": "Asia/Tokyo",
                "forecast_days": 7
            }
        )
        return response.json()

# 栽培アドバイス生成
def generate_cultivation_advice(weather_data: dict, crop: str) -> str:
    daily = weather_data["daily"]
    today = daily["time"][0]
    temp_max = daily["temperature_2m_max"][0]
    temp_min = daily["temperature_2m_min"][0]
    precip = daily["precipitation_sum"][0]
    soil_moisture = daily["soil_moisture_0_to_10cm"][0]

    advice = f"# {today}の栽培アドバイス\n\n"
    advice += f"作物: {crop}\n\n"

    # 気温に基づくアドバイス
    if temp_max > 30:
        advice += "⚠️ 高温注意\n"
        advice += "- 朝夕の涼しい時間に水やり\n"
        advice += "- 遮光ネットの使用を検討\n"
        advice += "- 葉焼けに注意\n\n"
    elif temp_min < 10:
        advice += "⚠️ 低温注意\n"
        advice += "- 霜対策が必要\n"
        advice += "- 不織布やビニールトンネルで保温\n"
        advice += "- 水やりは午前中に\n\n"
    else:
        advice += "✅ 栽培適温\n"
        advice += "- 通常の管理で問題ありません\n\n"

    # 降水量に基づくアドバイス
    if precip > 10:
        advice += "☔ 降雨予報\n"
        advice += "- 水やり不要\n"
        advice += "- 排水対策を確認\n"
        advice += "- 病気予防（風通し確保）\n\n"
    elif precip > 0:
        advice += "🌦️ 小雨予報\n"
        advice += "- 水やりは控えめに\n\n"
    else:
        advice += "☀️ 晴天\n"
        advice += f"- 土壌水分: {soil_moisture:.1f}%\n"
        if soil_moisture < 20:
            advice += "- 水やりが必要です\n\n"
        else:
            advice += "- 水やりは様子を見て\n\n"

    # 作業提案
    advice += "## 本日の作業\n"
    if precip == 0 and temp_max < 30:
        advice += "- 除草作業に適しています\n"
        advice += "- 追肥のタイミングです\n"
    if temp_max > 25 and crop in ["トマト", "キュウリ"]:
        advice += "- 収穫適期です（朝の涼しい時間に）\n"

    return advice

# 市場価格情報（サンプル）
MARKET_PRICES = {
    "トマト": {"price": 800, "trend": "上昇", "demand": "高"},
    "キュウリ": {"price": 600, "trend": "安定", "demand": "中"},
    "ナス": {"price": 700, "trend": "下降", "demand": "中"},
    "ピーマン": {"price": 900, "trend": "上昇", "demand": "高"},
}

@app.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="get_cultivation_advice",
            description="気象データに基づいた栽培アドバイスを取得します",
            inputSchema={
                "type": "object",
                "properties": {
                    "latitude": {"type": "number", "description": "緯度"},
                    "longitude": {"type": "number", "description": "経度"},
                    "crop": {"type": "string", "description": "作物名"}
                },
                "required": ["latitude", "longitude", "crop"]
            }
        ),
        Tool(
            name="get_market_price",
            description="作物の市場価格情報を取得します",
            inputSchema={
                "type": "object",
                "properties": {
                    "crop": {"type": "string", "description": "作物名"}
                },
                "required": ["crop"]
            }
        ),
        Tool(
            name="suggest_harvest_timing",
            description="気象と市場価格から最適な収穫・出荷タイミングを提案します",
            inputSchema={
                "type": "object",
                "properties": {
                    "latitude": {"type": "number", "description": "緯度"},
                    "longitude": {"type": "number", "description": "経度"},
                    "crop": {"type": "string", "description": "作物名"},
                    "estimated_harvest_date": {
                        "type": "string",
                        "description": "予想収穫日（YYYY-MM-DD）"
                    }
                },
                "required": ["latitude", "longitude", "crop", "estimated_harvest_date"]
            }
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: Any) -> list[TextContent]:
    if name == "get_cultivation_advice":
        lat = arguments["latitude"]
        lon = arguments["longitude"]
        crop = arguments["crop"]

        weather_data = await get_weather_data(lat, lon)
        advice = generate_cultivation_advice(weather_data, crop)

        return [TextContent(type="text", text=advice)]

    elif name == "get_market_price":
        crop = arguments["crop"]
        price_info = MARKET_PRICES.get(crop, {
            "price": 0,
            "trend": "不明",
            "demand": "不明"
        })

        result = f"""
# {crop}の市場価格情報

現在価格: ¥{price_info['price']}/kg
価格動向: {price_info['trend']}
需要: {price_info['demand']}

## 出荷アドバイス
"""
        if price_info['trend'] == "上昇":
            result += "- 価格上昇中です。出荷のタイミングとして良好。\n"
        elif price_info['trend'] == "下降":
            result += "- 価格下降中です。早めの出荷を検討してください。\n"
        else:
            result += "- 価格は安定しています。通常通りの出荷で問題ありません。\n"

        return [TextContent(type="text", text=result.strip())]

    elif name == "suggest_harvest_timing":
        lat = arguments["latitude"]
        lon = arguments["longitude"]
        crop = arguments["crop"]
        harvest_date = arguments["estimated_harvest_date"]

        weather_data = await get_weather_data(lat, lon)
        price_info = MARKET_PRICES.get(crop, {"price": 0, "trend": "不明"})

        daily = weather_data["daily"]

        result = f"# {crop}の収穫・出荷タイミング提案\n\n"
        result += f"予定収穫日: {harvest_date}\n\n"

        result += "## 今後7日間の天気\n"
        for i in range(7):
            date = daily["time"][i]
            temp_max = daily["temperature_2m_max"][i]
            precip = daily["precipitation_sum"][i]
            result += f"{date}: 最高{temp_max}°C, 降水{precip}mm\n"

        result += f"\n## 市場価格\n"
        result += f"現在価格: ¥{price_info['price']}/kg\n"
        result += f"動向: {price_info['trend']}\n\n"

        result += "## 推奨アクション\n"

        # 天気と価格から判断
        rainy_days = sum(1 for p in daily["precipitation_sum"][:3] if p > 5)

        if rainy_days > 1:
            result += "⚠️ 今後3日間、雨が多い予報です。\n"
            result += "- 収穫は雨の前に済ませましょう\n"
            result += "- 品質低下を防ぐため早めの出荷を推奨\n"
        else:
            result += "✅ 天候は安定しています。\n"
            result += "- 計画通りの収穫で問題ありません\n"

        if price_info['trend'] == "上昇":
            result += "\n💰 価格上昇中です。\n"
            result += "- 可能であれば数日待つと良い価格で出荷できる可能性があります\n"
        elif price_info['trend'] == "下降":
            result += "\n📉 価格下降中です。\n"
            result += "- 早めの出荷をお勧めします\n"

        return [TextContent(type="text", text=result)]

    else:
        raise ValueError(f"Unknown tool: {name}")

async def main():
    async with stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            app.create_initialization_options()
        )

if __name__ == "__main__":
    asyncio.run(main())
```

---

### 栽培アプリでのMCP活用

```
【あなた】
畑の位置（緯度35.6586、経度139.7454）で
トマトを育てているんだけど、今日の栽培アドバイスを教えて

【Claude】
Agriculture Support MCPを使って気象データを取得し、
栽培アドバイスを生成します...

# 2025-12-22の栽培アドバイス

作物: トマト

✅ 栽培適温
- 通常の管理で問題ありません

☀️ 晴天
- 土壌水分: 15.2%
- 水やりが必要です

## 本日の作業
- 除草作業に適しています
- 追肥のタイミングです
- 収穫適期です（朝の涼しい時間に）

【あなた】
トマトの市場価格も教えて

【Claude】
# トマトの市場価格情報

現在価格: ¥800/kg
価格動向: 上昇
需要: 高

## 出荷アドバイス
- 価格上昇中です。出荷のタイミングとして良好。

【あなた】
収穫予定は12月25日。最適な出荷タイミングを提案して

【Claude】
# トマトの収穫・出荷タイミング提案

予定収穫日: 2025-12-25

## 今後7日間の天気
2025-12-22: 最高16°C, 降水0mm
2025-12-23: 最高14°C, 降水0mm
2025-12-24: 最高15°C, 降水2mm
2025-12-25: 最高13°C, 降水8mm
2025-12-26: 最高12°C, 降水12mm
2025-12-27: 最高14°C, 降水0mm
2025-12-28: 最高15°C, 降水0mm

## 市場価格
現在価格: ¥800/kg
動向: 上昇

## 推奨アクション
⚠️ 今後3日間、雨が多い予報です。
- 収穫は雨の前に済ませましょう
- 品質低下を防ぐため早めの出荷を推奨

💰 価格上昇中です。
- 可能であれば数日待つと良い価格で出荷できる可能性があります

**提案: 12月24日（雨の前）に収穫し、12月27日（価格安定後）に出荷**
```

---

## ユースケース3: 家計簿アプリ × MCP

### 実装する機能

```
【基本機能】（06-07章で実装済み）
- 収支記録
- 投資分析

【MCP統合で追加】
✅ 株価・為替の自動更新
✅ 経済ニュースの統合
✅ ポートフォリオ最適化提案
✅ リスク分析
```

---

### カスタムMCP: 金融データサーバー

**finance-mcp-server.ts**

```typescript
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

// 株価データ（実際はYahoo FinanceやAlpha Vantage APIを使用）
interface StockPrice {
  symbol: string;
  price: number;
  change: number;
  changePercent: number;
  volume: number;
}

// サンプルデータ
const mockStockData: { [key: string]: StockPrice } = {
  'AAPL': {
    symbol: 'AAPL',
    price: 195.50,
    change: 2.30,
    changePercent: 1.19,
    volume: 50000000,
  },
  'GOOGL': {
    symbol: 'GOOGL',
    price: 142.80,
    change: -0.50,
    changePercent: -0.35,
    volume: 25000000,
  },
  'MSFT': {
    symbol: 'MSFT',
    price: 378.90,
    change: 5.20,
    changePercent: 1.39,
    volume: 35000000,
  },
};

// 為替レート（実際はFX APIを使用）
const exchangeRates: { [key: string]: number } = {
  'USD/JPY': 155.50,
  'EUR/JPY': 168.20,
  'GBP/JPY': 195.80,
};

const server = new Server(
  {
    name: 'finance-data',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'get_stock_price',
        description: '株価情報を取得します',
        inputSchema: {
          type: 'object',
          properties: {
            symbol: {
              type: 'string',
              description: 'ティッカーシンボル（例: AAPL, GOOGL）',
            },
          },
          required: ['symbol'],
        },
      },
      {
        name: 'get_exchange_rate',
        description: '為替レートを取得します',
        inputSchema: {
          type: 'object',
          properties: {
            pair: {
              type: 'string',
              description: '通貨ペア（例: USD/JPY）',
            },
          },
          required: ['pair'],
        },
      },
      {
        name: 'analyze_portfolio',
        description: 'ポートフォリオを分析し、リスクとリターンを評価します',
        inputSchema: {
          type: 'object',
          properties: {
            holdings: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  symbol: { type: 'string' },
                  shares: { type: 'number' },
                  avgCost: { type: 'number' },
                },
              },
              description: '保有銘柄リスト',
            },
          },
          required: ['holdings'],
        },
      },
      {
        name: 'suggest_rebalancing',
        description: 'ポートフォリオのリバランス提案を生成します',
        inputSchema: {
          type: 'object',
          properties: {
            currentAllocation: {
              type: 'object',
              description: '現在の資産配分（％）',
            },
            targetAllocation: {
              type: 'object',
              description: '目標の資産配分（％）',
            },
            totalValue: {
              type: 'number',
              description: '総資産額',
            },
          },
          required: ['currentAllocation', 'targetAllocation', 'totalValue'],
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case 'get_stock_price': {
      const symbol = (args.symbol as string).toUpperCase();
      const stock = mockStockData[symbol];

      if (!stock) {
        throw new Error(`株価データが見つかりません: ${symbol}`);
      }

      const result = `
# ${stock.symbol} 株価情報

現在値: $${stock.price.toFixed(2)}
変動: ${stock.change >= 0 ? '+' : ''}${stock.change.toFixed(2)} (${
        stock.change >= 0 ? '+' : ''
      }${stock.changePercent.toFixed(2)}%)
出来高: ${stock.volume.toLocaleString()}

${stock.changePercent > 0 ? '📈 上昇中' : '📉 下落中'}
      `.trim();

      return {
        content: [{ type: 'text', text: result }],
      };
    }

    case 'get_exchange_rate': {
      const pair = args.pair as string;
      const rate = exchangeRates[pair];

      if (!rate) {
        throw new Error(`為替レートが見つかりません: ${pair}`);
      }

      const result = `
# ${pair} 為替レート

現在レート: ¥${rate.toFixed(2)}

【活用例】
$100 = ¥${(100 * rate).toFixed(0)}
$1,000 = ¥${(1000 * rate).toFixed(0)}
      `.trim();

      return {
        content: [{ type: 'text', text: result }],
      };
    }

    case 'analyze_portfolio': {
      const holdings = args.holdings as Array<{
        symbol: string;
        shares: number;
        avgCost: number;
      }>;

      let totalValue = 0;
      let totalCost = 0;
      const analysis: string[] = [];

      for (const holding of holdings) {
        const stock = mockStockData[holding.symbol];
        if (!stock) continue;

        const currentValue = stock.price * holding.shares;
        const cost = holding.avgCost * holding.shares;
        const gain = currentValue - cost;
        const gainPercent = (gain / cost) * 100;

        totalValue += currentValue;
        totalCost += cost;

        analysis.push(`
${holding.symbol}
  保有数: ${holding.shares}株
  平均取得単価: $${holding.avgCost.toFixed(2)}
  現在価格: $${stock.price.toFixed(2)}
  評価額: $${currentValue.toFixed(2)}
  損益: ${gain >= 0 ? '+' : ''}$${gain.toFixed(2)} (${
          gain >= 0 ? '+' : ''
        }${gainPercent.toFixed(2)}%)
        `.trim());
      }

      const totalGain = totalValue - totalCost;
      const totalGainPercent = (totalGain / totalCost) * 100;

      const result = `
# ポートフォリオ分析

## 保有銘柄

${analysis.join('\n\n')}

## 全体サマリー

総評価額: $${totalValue.toFixed(2)}
総投資額: $${totalCost.toFixed(2)}
総損益: ${totalGain >= 0 ? '+' : ''}$${totalGain.toFixed(2)} (${
        totalGain >= 0 ? '+' : ''
      }${totalGainPercent.toFixed(2)}%)

${totalGain > 0 ? '✅ 利益が出ています' : '⚠️ 含み損があります'}
      `.trim();

      return {
        content: [{ type: 'text', text: result }],
      };
    }

    case 'suggest_rebalancing': {
      const current = args.currentAllocation as { [key: string]: number };
      const target = args.targetAllocation as { [key: string]: number };
      const total = args.totalValue as number;

      const suggestions: string[] = [];

      for (const asset in target) {
        const currentPercent = current[asset] || 0;
        const targetPercent = target[asset];
        const diff = targetPercent - currentPercent;

        if (Math.abs(diff) > 5) {
          // 5%以上のずれ
          const amount = (total * diff) / 100;

          if (diff > 0) {
            suggestions.push(
              `${asset}: ${amount.toFixed(0)}円 買い増し（${currentPercent.toFixed(
                1
              )}% → ${targetPercent.toFixed(1)}%）`
            );
          } else {
            suggestions.push(
              `${asset}: ${Math.abs(amount).toFixed(
                0
              )}円 売却（${currentPercent.toFixed(1)}% → ${targetPercent.toFixed(
                1
              )}%）`
            );
          }
        }
      }

      const result = `
# リバランス提案

総資産: ¥${total.toLocaleString()}

## 現在の配分
${Object.entries(current)
  .map(([k, v]) => `- ${k}: ${v.toFixed(1)}%`)
  .join('\n')}

## 目標配分
${Object.entries(target)
  .map(([k, v]) => `- ${k}: ${v.toFixed(1)}%`)
  .join('\n')}

## 推奨アクション
${suggestions.length > 0 ? suggestions.join('\n') : '現在の配分は目標に近い状態です。'}

## 注意事項
- リバランスは手数料を考慮してください
- 一度に全て調整する必要はありません
- 市場環境を見ながら段階的に実施しましょう
      `.trim();

      return {
        content: [{ type: 'text', text: result }],
      };
    }

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Finance Data MCP Server running');
}

main().catch(console.error);
```

---

### 家計簿アプリでのMCP活用

```
【あなた】
AAPLの現在の株価を教えて

【Claude】
Finance Data MCPで株価を取得します...

# AAPL 株価情報

現在値: $195.50
変動: +$2.30 (+1.19%)
出来高: 50,000,000

📈 上昇中

【あなた】
ポートフォリオを分析して。
AAPL 10株（平均$180）、GOOGL 5株（平均$145）持ってる

【Claude】
# ポートフォリオ分析

## 保有銘柄

AAPL
  保有数: 10株
  平均取得単価: $180.00
  現在価格: $195.50
  評価額: $1,955.00
  損益: +$155.00 (+8.61%)

GOOGL
  保有数: 5株
  平均取得単価: $145.00
  現在価格: $142.80
  評価額: $714.00
  損益: -$11.00 (-1.52%)

## 全体サマリー

総評価額: $2,669.00
総投資額: $2,525.00
総損益: +$144.00 (+5.70%)

✅ 利益が出ています

【あなた】
目標配分は株式60%、債券30%、現金10%。
現在は株式75%、債券20%、現金5%で、総資産300万円。
リバランス提案して

【Claude】
# リバランス提案

総資産: ¥3,000,000

## 現在の配分
- 株式: 75.0%
- 債券: 30.0%
- 現金: 5.0%

## 目標配分
- 株式: 60.0%
- 債券: 30.0%
- 現金: 10.0%

## 推奨アクション
株式: 450,000円 売却（75.0% → 60.0%）
債券: 300,000円 買い増し（20.0% → 30.0%）
現金: 150,000円 買い増し（5.0% → 10.0%）

## 注意事項
- リバランスは手数料を考慮してください
- 一度に全て調整する必要はありません
- 市場環境を見ながら段階的に実施しましょう
```

---

## ユースケース4: 読書アプリ × MCP

### 実装する機能

```
【基本機能】（06-07章で実装済み）
- 読書記録
- 書評ブログ自動生成

【MCP統合で追加】
✅ 書籍情報API連携（Google Books等）
✅ 書籍レビューの収集
✅ おすすめ本の提案
✅ 読書傾向の分析
```

---

### カスタムMCP: 書籍情報サーバー

**book-info-mcp-server.ts**

```typescript
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

const server = new Server(
  {
    name: 'book-info',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'search_books',
        description: '書籍を検索します（Google Books API使用）',
        inputSchema: {
          type: 'object',
          properties: {
            query: {
              type: 'string',
              description: '検索クエリ（タイトル、著者、ISBN等）',
            },
            maxResults: {
              type: 'number',
              description: '最大結果数',
              default: 5,
            },
          },
          required: ['query'],
        },
      },
      {
        name: 'get_book_details',
        description: '書籍の詳細情報を取得します',
        inputSchema: {
          type: 'object',
          properties: {
            bookId: {
              type: 'string',
              description: 'Google Books ID',
            },
          },
          required: ['bookId'],
        },
      },
      {
        name: 'recommend_books',
        description: '読書履歴に基づいておすすめの本を提案します',
        inputSchema: {
          type: 'object',
          properties: {
            readBooks: {
              type: 'array',
              items: { type: 'string' },
              description: '既読書籍のタイトルリスト',
            },
            genres: {
              type: 'array',
              items: { type: 'string' },
              description: '好きなジャンル',
            },
          },
          required: ['readBooks'],
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case 'search_books': {
      const query = args.query as string;
      const maxResults = (args.maxResults as number) || 5;

      // Google Books API呼び出し（実際の実装）
      const response = await fetch(
        `https://www.googleapis.com/books/v1/volumes?q=${encodeURIComponent(
          query
        )}&maxResults=${maxResults}`
      );

      const data = await response.json();

      if (!data.items || data.items.length === 0) {
        return {
          content: [
            { type: 'text', text: '検索結果が見つかりませんでした' },
          ],
        };
      }

      const results = data.items
        .map((item: any, index: number) => {
          const info = item.volumeInfo;
          return `
${index + 1}. ${info.title}
   著者: ${info.authors?.join(', ') || '不明'}
   出版社: ${info.publisher || '不明'}
   出版日: ${info.publishedDate || '不明'}
   ${info.description ? `概要: ${info.description.substring(0, 100)}...` : ''}
   ID: ${item.id}
          `.trim();
        })
        .join('\n\n');

      return {
        content: [{ type: 'text', text: results }],
      };
    }

    case 'get_book_details': {
      const bookId = args.bookId as string;

      const response = await fetch(
        `https://www.googleapis.com/books/v1/volumes/${bookId}`
      );

      const data = await response.json();
      const info = data.volumeInfo;

      const details = `
# ${info.title}

## 基本情報
- 著者: ${info.authors?.join(', ') || '不明'}
- 出版社: ${info.publisher || '不明'}
- 出版日: ${info.publishedDate || '不明'}
- ページ数: ${info.pageCount || '不明'}
- ISBN: ${info.industryIdentifiers?.find((id: any) => id.type === 'ISBN_13')?.identifier || '不明'}

## カテゴリ
${info.categories?.join(', ') || 'なし'}

## 概要
${info.description || '概要なし'}

## リンク
${info.infoLink || 'なし'}
      `.trim();

      return {
        content: [{ type: 'text', text: details }],
      };
    }

    case 'recommend_books': {
      const readBooks = args.readBooks as string[];
      const genres = (args.genres as string[]) || [];

      // 簡易的なレコメンデーション（実際はML等を使用）
      const recommendations = `
# おすすめ本の提案

## あなたの読書傾向
既読書籍: ${readBooks.length}冊
${genres.length > 0 ? `好きなジャンル: ${genres.join(', ')}` : ''}

## おすすめ理由
既読書籍の傾向から、以下のジャンルがお好きなようです:
- 技術書 / ビジネス書

## おすすめ書籍
1. "Clean Code" - Robert C. Martin
   理由: コード品質に関心がある方におすすめ

2. "The Pragmatic Programmer" - Andrew Hunt, David Thomas
   理由: 実践的なプログラミング哲学

3. "Domain-Driven Design" - Eric Evans
   理由: ソフトウェア設計の深い理解

※ これらの本を検索して詳細を確認できます
      `.trim();

      return {
        content: [{ type: 'text', text: recommendations }],
      };
    }

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Book Info MCP Server running');
}

main().catch(console.error);
```

---

## 複数MCPの組み合わせパターン

### パターン1: データ連携

```
【育児アプリ + 複数MCP】

Nursery MCP
  ↓
保育園情報取得
  ↓
Weather MCP
  ↓
今日の天気確認
  ↓
統合アドバイス:
「今日は雨なので、保育園までの移動は
 レインコートを忘れずに。
 さくら保育園（徒歩5分）が最寄りです。」
```

---

### パターン2: ワークフロー自動化

```
【栽培アプリ + 複数MCP】

Agriculture MCP → 栽培アドバイス取得
  ↓
Weather MCP → 今後の天気確認
  ↓
Market MCP → 市場価格取得
  ↓
Task Manager MCP → 作業タスク自動生成
  ↓
「今日の作業リスト」が自動で完成
```

---

### パターン3: 意思決定支援

```
【投資判断 + 複数MCP】

Finance MCP → 株価・為替取得
  ↓
News MCP → 経済ニュース取得
  ↓
Analysis MCP → リスク分析
  ↓
総合判断:
「現在の市場環境では、リバランスは
 1ヶ月後が適切です。理由は...」
```

---

## MCPベストプラクティス（実践編）

### 1. エラーハンドリング

```typescript
// 外部API呼び出し時の堅牢なエラーハンドリング
async function fetchWithRetry(url: string, retries = 3): Promise<any> {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url);

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      return await response.json();
    } catch (error) {
      console.error(`Attempt ${i + 1} failed:`, error);

      if (i === retries - 1) {
        throw new Error(
          `Failed after ${retries} attempts: ${(error as Error).message}`
        );
      }

      // 指数バックオフ
      await new Promise((resolve) => setTimeout(resolve, 1000 * Math.pow(2, i)));
    }
  }
}
```

---

### 2. キャッシング

```typescript
// データキャッシュで API 呼び出しを削減
class DataCache {
  private cache: Map<string, { data: any; expiry: number }> = new Map();

  set(key: string, data: any, ttlMs: number = 300000) {
    // デフォルト5分
    this.cache.set(key, {
      data,
      expiry: Date.now() + ttlMs,
    });
  }

  get(key: string): any | null {
    const item = this.cache.get(key);
    if (!item) return null;

    if (Date.now() > item.expiry) {
      this.cache.delete(key);
      return null;
    }

    return item.data;
  }
}

const cache = new DataCache();

// 使用例
async function getStockPrice(symbol: string) {
  const cached = cache.get(`stock:${symbol}`);
  if (cached) {
    console.error('Cache hit:', symbol);
    return cached;
  }

  const data = await fetchStockData(symbol);
  cache.set(`stock:${symbol}`, data, 60000); // 1分キャッシュ
  return data;
}
```

---

### 3. レート制限

```typescript
// APIレート制限の遵守
class RateLimiter {
  private requests: number[] = [];
  private limit: number;
  private windowMs: number;

  constructor(limit: number, windowMs: number) {
    this.limit = limit;
    this.windowMs = windowMs;
  }

  async acquire(): Promise<void> {
    const now = Date.now();
    this.requests = this.requests.filter((time) => now - time < this.windowMs);

    if (this.requests.length >= this.limit) {
      const oldestRequest = this.requests[0];
      const waitTime = this.windowMs - (now - oldestRequest);
      console.error(`Rate limit reached, waiting ${waitTime}ms`);
      await new Promise((resolve) => setTimeout(resolve, waitTime));
      return this.acquire();
    }

    this.requests.push(now);
  }
}

// 使用例: 1分間に10リクエストまで
const limiter = new RateLimiter(10, 60000);

async function apiCall() {
  await limiter.acquire();
  // API呼び出し
}
```

---

## まとめ

### BYOAアプリの進化の全体像

```
【06章】個人用アプリ作成
- チャットのみ
- LocalStorage
- 基本機能

↓

【07章】コラボで進化
- 特化型機能追加
- データ活用
- 独自の価値

↓

【08章】MCP基礎
- MCPの概念
- 既存MCPサーバー活用
- カスタムMCP作成

↓

【09章】MCP実践（この章）
✅ 育児アプリ × 保育園情報・予防接種MCP
✅ 栽培アプリ × 気象・市場価格MCP
✅ 家計簿アプリ × 金融データMCP
✅ 読書アプリ × 書籍情報MCP
✅ 複数MCPの組み合わせ
✅ 実践的なベストプラクティス

↓

【05章 / Chef's Specials】本格開発へ
- Cursor + Claude
- Flutter
- CI/CD
```

---

### MCPが実現する価値

```
【データ連携】
外部システムとシームレスに統合
→ 手動入力の削減
→ リアルタイムな情報

【専門性の追加】
ドメイン固有の知識を統合
→ 保育園情報
→ 気象データ
→ 市場価格
→ 金融データ

【意思決定支援】
複数のデータソースを統合
→ 最適なタイミング提案
→ リスク分析
→ 総合的な判断

【自動化】
ワークフローを自動化
→ 作業リスト自動生成
→ アラート通知
→ レポート作成
```

---

### 次のステップ

**今すぐできること:**

1. 既存MCPサーバーを試す
   - Filesystem MCP
   - GitHub MCP

2. 簡単なカスタムMCPを作る
   - 自分のデータソース
   - 既存APIの統合

3. 07章の特化型機能にMCPを統合
   - 育児アプリ + 地域情報
   - 栽培アプリ + 気象データ
   - 家計簿 + 金融データ

4. 複数MCPを組み合わせる
   - ワークフロー自動化
   - 意思決定支援

---

**本格開発への準備が整ったら:**

📘 **05章（Chef's Specials）へ**
- Cursor + Claude で効率開発
- Flutter でマルチプラットフォーム
- MCP を組み込んだ本格アプリ
- コミュニティ駆動開発

---

**MCPは、あなたのBYOAアプリを外の世界と繋ぎ、**
**専門的な価値を生み出す強力なツールです。**

**一歩ずつ統合を進めて、唯一無二のアプリを作りましょう！**
