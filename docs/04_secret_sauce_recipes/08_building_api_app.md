# レシピ#4-8: 実践 - APIを使ったニュースアプリを作る

## このレシピのゴール

Cursor + Claudeを使って、実際のAPIからデータを取得して表示するニュースアプリを作ります。

**機能:**
- ✅ ニュース記事一覧表示
- ✅ 記事詳細表示
- ✅ カテゴリ別表示
- ✅ Pull-to-refresh
- ✅ ページネーション
- ✅ お気に入り機能

**技術:**
- ✅ REST API通信
- ✅ JSONパース
- ✅ 非同期処理
- ✅ エラーハンドリング
- ✅ ローディング状態管理

## Step 1: API選定

**無料で使えるニュースAPI:**
- [NewsAPI](https://newsapi.org/) - 無料プランあり
- [GNews API](https://gnews.io/) - 無料プランあり
- または、公開されている任意のREST API

**今回の例:** NewsAPIを使用

## Step 2: プロジェクトセットアップ

```bash
flutter create news_app
cd news_app
cursor .
```

**Cursorに依頼:**
```
pubspec.yamlに以下のパッケージを追加してください:
- http: 最新版
- cached_network_image: 最新版
- url_launcher: 最新版
- shared_preferences: 最新版（お気に入り機能用）
```

## Step 3: データモデル作成

**プロンプト:**
```
ニュース記事のデータモデルを作成してください。

以下はNewsAPIのレスポンス例です:
{
  "articles": [
    {
      "source": {"id": "abc-news", "name": "ABC News"},
      "author": "John Doe",
      "title": "Sample News Title",
      "description": "Sample description",
      "url": "https://example.com/article",
      "urlToImage": "https://example.com/image.jpg",
      "publishedAt": "2025-01-07T10:00:00Z",
      "content": "Full article content..."
    }
  ]
}

必要なもの:
1. ArticleクラスとSourceクラス
2. fromJson メソッド
3. NewsResponseクラス（記事リストを含む）

シンプルな構造でお願いします。
```

## Step 4: ApiService作成

**プロンプト:**
```
NewsApiServiceクラスを作成してください。

機能:
- トップニュース取得
- カテゴリ別ニュース取得
  （business, technology, sports, entertainment など）
- 検索機能
- ページネーション対応

構成:
- シングルトンパターン
- httpパッケージ使用
- エラーハンドリング（ネットワークエラー、APIエラー）
- APIキーの管理（定数として）

注意:
- タイムアウト設定（10秒）
- カスタム例外クラス作成
```

## Step 5: メイン画面作成

**プロンプト:**
```
ニュース一覧画面を作成してください。

UI構成:
- AppBar
  - タイトル「ニュース」
  - 検索アイコン

- TabBar
  - 「トップ」
  - 「ビジネス」
  - 「テクノロジー」
  - 「スポーツ」
  - 「エンタメ」

- Body
  - ニュース記事カード一覧（ListView）
  - Pull-to-refresh機能
  - 無限スクロール（ページネーション）

各記事カード:
- 画像（左側、正方形）
- タイトル（太字）
- 説明（2行まで）
- ソース名と時刻
- タップで詳細画面へ

状態:
- ローディング表示
- エラー表示
- 空の場合の表示

実装:
- StatefulWidget
- NewsApiServiceを使用
- ScrollControllerでページネーション検知
```

## Step 6: 記事詳細画面

**プロンプト:**
```
記事詳細画面を作成してください。

UI:
- AppBar
  - タイトル（ソース名）
  - 共有ボタン
  - お気に入りボタン

- Body（スクロール可能）
  - 記事画像（全幅）
  - タイトル（大きく）
  - ソース名と投稿日時
  - 記事内容
  - 「続きを読む」ボタン
    → url_launcherで元記事をブラウザで開く

機能:
- お気に入り追加/削除
- URLを開く（url_launcher使用）
- （オプション）記事共有

実装:
- StatefulWidget
- Articleモデルを受け取る
```

## Step 7: お気に入り機能

**プロンプト:**
```
お気に入り機能を実装してください。

機能:
- 記事をお気に入りに追加
- お気に入りから削除
- お気に入り一覧表示

データ保存:
- SharedPreferencesを使用
- 記事IDのリストを保存
- FavoriteServiceクラスで管理

UI:
- BottomNavigationBarで切り替え
  - ホーム
  - お気に入り
- お気に入りアイコンの状態表示
  （お気に入り登録済みは塗りつぶし）

実装:
- シングルトンパターンのServiceクラス
- お気に入り状態の同期
```

## Step 8: 検索機能

**プロンプト:**
```
検索機能を追加してください。

UI:
- AppBarの検索アイコンをタップ
- 検索画面に遷移
- 検索TextField（自動フォーカス）
- 検索結果一覧

機能:
- キーワードで記事検索
- APIに検索クエリを送信
- デバウンス処理（入力から500ms後に検索）
- 検索履歴保存（オプション）

実装:
- Timer使用（デバウンス）
- NewsApiService.search() メソッド使用
```

## Step 9: エラーハンドリングとローディング

**プロンプト:**
```
より良いエラーハンドリングとローディング表示を実装してください。

ローディング:
- 初回ロード: 中央にCircularProgressIndicator
- 追加ロード（ページネーション）: リスト下部に小さなインジケータ
- Pull-to-refresh: 標準のRefreshIndicator

エラー:
- ネットワークエラー: 「インターネット接続を確認してください」
- APIエラー: 具体的なエラーメッセージ
- タイムアウト: 「接続がタイムアウトしました」
- リトライボタンを表示

実装:
- エラー状態を enum で管理
- エラーごとに適切なメッセージとアイコン表示
```

## Step 10: キャッシュ機能（オプション）

**プロンプト:**
```
簡易キャッシュ機能を追加してください。

機能:
- API レスポンスをメモリにキャッシュ
- 5分間有効
- オフラインでも最後のデータを表示

実装:
- Map<String, CachedData> 形式
- CachedData クラス（data + timestamp）
- ApiService 内で管理
- キャッシュヒット時はAPIコールをスキップ
```

## 完成後のファイル構成

```
lib/
├── main.dart
├── models/
│   ├── article.dart
│   └── news_response.dart
├── services/
│   ├── news_api_service.dart
│   └── favorite_service.dart
├── screens/
│   ├── news_list_screen.dart
│   ├── article_detail_screen.dart
│   ├── search_screen.dart
│   └── favorites_screen.dart
└── widgets/
    ├── article_card.dart
    ├── loading_indicator.dart
    └── error_view.dart
```

## まとめ

このアプリで学んだこと：

### API通信
- REST API の基本
- HTTPリクエスト
- JSONパース
- エラーハンドリング

### 非同期処理
- Future と async/await
- ローディング状態管理
- エラー状態管理

### UXパターン
- Pull-to-refresh
- 無限スクロール
- デバウンス検索
- キャッシュ

### 実践的パターン
- Serviceクラス
- 自己完結型Widget
- StatefulWidgetでの状態管理
- エラーハンドリング戦略

**重要なポイント:**
- ✅ Riverpod不要で実用アプリ完成
- ✅ シンプルで保守しやすい構造
- ✅ AIが理解しやすいコード
- ✅ バージョンアップに強い

## Section 4 完了！

おめでとうございます！Section 4「秘伝のソース」を完了しました。

**学んだこと:**
1. Cursor + Claudeの効率的なワークフロー
2. Riverpodを避けるべき理由
3. 自己完結型Widgetパターン
4. Serviceクラスパターン
5. 実践的なアプリ開発（メモ、TODO、ニュース）
6. Antigravityの現状と注意点

**次のステップ:**
- Section 5: シェフの特製料理（より高度なアプリ）
- または、自分のアイデアでアプリを作ってみましょう！

Happy Coding with AI! 🎉
