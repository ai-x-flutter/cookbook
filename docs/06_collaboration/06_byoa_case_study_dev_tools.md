# レシピ#6-6: チャットだけで自分用のWebアプリを作る

このレシピでは、**プログラミングを学ばずに**、**Claudeとの会話だけで**自分用の実用的なWebアプリを作る方法を学びます。

---

## この章の対象読者

### ✅ こんな人におすすめ

- ちょっとした自分用のツールが欲しい
- プログラミングは学びたくない
- ブラウザで動けば十分
- コードは理解しなくていい、結果だけ欲しい

### ❌ 向いていない人

- 本格的なアプリを作りたい → [05_chefs_specials](../05_chefs_specials/) へ
- プログラミングを学びたい → 別の学習リソースへ
- モバイルアプリが必要 → 05_chefs_specials へ

---

## 05章との違い

| 項目 | 05章（Chef's Specials） | 06章（この章） |
|------|------------------------|---------------|
| 対象者 | PM的能力がある非開発者 | 普通の非開発者 |
| ツール | Cursor + Claude | **Claude Webチャットのみ** |
| 目的 | 本格的なアプリ開発 | 自分用の小さなツール |
| スキル | 技術的な指示ができる | 普通に会話できればOK |
| 出力 | デスクトップ/モバイルアプリ | **Webアプリ** |
| 学習曲線 | やや急 | **ほぼフラット** |

---

## なぜClaudeのWebチャットだけで十分なのか

### Claude Projects + Artifacts の強み

```
【Claude Projects】
✅ 会話の履歴を保持
✅ ファイルをアップロードして参照
✅ プロジェクトごとにコンテキストを管理

【Claude Artifacts】
✅ コードをリアルタイムでプレビュー
✅ HTML/CSS/JS、Reactが動く
✅ その場で確認して修正依頼
✅ ダウンロードして保存
```

### 従来の方法との比較

| 方法 | 必要なもの | 難易度 | コスト |
|------|----------|--------|--------|
| 従来の開発 | プログラミング学習 | 高 | 無料 |
| Cursor + Claude | Cursor + Claude Pro | 中 | 月6,200-6,975円 |
| **Claude Webチャット** | **Claude Pro のみ** | **低** | **月3,100-3,875円** |

→ **ちょっとした自分用ツールには、Claude Webチャットが最適**

---

## 必要なもの

### 1. Claude Pro契約

```
料金: 月3,100-3,875円 ($20-25)
機能:
- ✅ Webチャット使い放題（定額）
- ✅ Projects機能
- ✅ Artifacts機能
- ✅ 使いすぎの心配なし
```

**なぜClaude Proなのか:**

他のサービスとの比較：

| サービス | 月額 | Webチャット | Artifacts相当 | 定額 |
|---------|------|------------|--------------|------|
| Claude Pro | 3,100-3,875円 | ✅ | ✅ | ✅ |
| ChatGPT Plus | 3,100円 | ✅ | △ Code Interpreter | ✅ |
| Gemini Advanced | 2,900円 | ✅ | △ 限定的 | ✅ |

→ **Webアプリのプレビュー機能が最も優れているのはClaude**

### 2. Webブラウザ

```
Chrome、Edge、Firefox、Safari等
特別なソフトウェアは不要
```

---

## 基本的な流れ

### Step 1: Projectを作成

```
1. Claude.aiにアクセス
2. 左サイドバーの「Projects」をクリック
3. 「New Project」をクリック
4. プロジェクト名を入力（例: 「My ToDo App」）
```

### Step 2: 要件を伝える

```
「以下の仕様でToDoリストアプリを作ってください：

1. タスクを追加できる
2. タスクを完了にできる
3. タスクを削除できる
4. データはブラウザのローカルストレージに保存
5. シンプルで使いやすいデザイン」
```

### Step 3: Artifactsでプレビュー

```
Claudeがコードを生成
  ↓
右側のArtifactsパネルに表示
  ↓
リアルタイムでプレビュー
  ↓
その場で動作確認
```

### Step 4: 修正依頼

```
「タスク追加ボタンをもっと目立つ色にしてください」
「完了したタスクは薄くグレーアウトして」
「タイトルを『私のToDoリスト』に変更」
```

### Step 5: ダウンロードして保存

```
Artifactsパネルの「Copy code」をクリック
  ↓
テキストエディタ（メモ帳等）に貼り付け
  ↓
「todo.html」として保存
  ↓
ブラウザで開く
```

---

## 実例1: ToDoリスト

### Claudeへの指示

```markdown
以下の仕様でToDoリストアプリを作ってください：

【機能】
1. タスク追加
   - 入力欄とボタン
   - 空の入力はエラー表示

2. タスク管理
   - チェックボックスで完了/未完了
   - 削除ボタン
   - 完了したタスクは薄く表示

3. データ保存
   - ブラウザのlocalStorageに保存
   - ページを閉じても残る

【デザイン】
- シンプルでクリーン
- モバイルでも使いやすい
- 明るい配色
```

### 生成される例

```html
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>私のToDoリスト</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 600px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }

        h1 {
            text-align: center;
            color: #667eea;
            margin-bottom: 30px;
        }

        .input-area {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }

        input[type="text"] {
            flex: 1;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
        }

        button {
            padding: 12px 24px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            transition: background 0.3s;
        }

        button:hover {
            background: #5568d3;
        }

        .task-list {
            list-style: none;
        }

        .task-item {
            display: flex;
            align-items: center;
            padding: 15px;
            border-bottom: 1px solid #eee;
            transition: opacity 0.3s;
        }

        .task-item.completed {
            opacity: 0.5;
        }

        .task-item input[type="checkbox"] {
            margin-right: 10px;
            width: 20px;
            height: 20px;
        }

        .task-text {
            flex: 1;
            font-size: 16px;
        }

        .task-item.completed .task-text {
            text-decoration: line-through;
        }

        .delete-btn {
            padding: 8px 16px;
            background: #ff4757;
            font-size: 14px;
        }

        .delete-btn:hover {
            background: #ee5a6f;
        }

        .error {
            color: #ff4757;
            margin-bottom: 10px;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>私のToDoリスト</h1>

        <div class="input-area">
            <input type="text" id="taskInput" placeholder="タスクを入力...">
            <button onclick="addTask()">追加</button>
        </div>

        <div id="error" class="error"></div>

        <ul id="taskList" class="task-list"></ul>
    </div>

    <script>
        // ページ読み込み時にタスクを復元
        document.addEventListener('DOMContentLoaded', loadTasks);

        function addTask() {
            const input = document.getElementById('taskInput');
            const error = document.getElementById('error');
            const taskText = input.value.trim();

            if (taskText === '') {
                error.textContent = 'タスクを入力してください';
                return;
            }

            error.textContent = '';

            const task = {
                id: Date.now(),
                text: taskText,
                completed: false
            };

            saveTask(task);
            renderTask(task);
            input.value = '';
        }

        function renderTask(task) {
            const taskList = document.getElementById('taskList');
            const li = document.createElement('li');
            li.className = 'task-item' + (task.completed ? ' completed' : '');
            li.dataset.id = task.id;

            li.innerHTML = `
                <input type="checkbox" ${task.completed ? 'checked' : ''}
                       onchange="toggleTask(${task.id})">
                <span class="task-text">${task.text}</span>
                <button class="delete-btn" onclick="deleteTask(${task.id})">削除</button>
            `;

            taskList.appendChild(li);
        }

        function toggleTask(id) {
            let tasks = getTasks();
            tasks = tasks.map(task => {
                if (task.id === id) {
                    task.completed = !task.completed;
                }
                return task;
            });

            localStorage.setItem('tasks', JSON.stringify(tasks));
            reloadTasks();
        }

        function deleteTask(id) {
            let tasks = getTasks();
            tasks = tasks.filter(task => task.id !== id);
            localStorage.setItem('tasks', JSON.stringify(tasks));
            reloadTasks();
        }

        function saveTask(task) {
            const tasks = getTasks();
            tasks.push(task);
            localStorage.setItem('tasks', JSON.stringify(tasks));
        }

        function getTasks() {
            const tasks = localStorage.getItem('tasks');
            return tasks ? JSON.parse(tasks) : [];
        }

        function loadTasks() {
            const tasks = getTasks();
            tasks.forEach(renderTask);
        }

        function reloadTasks() {
            document.getElementById('taskList').innerHTML = '';
            loadTasks();
        }

        // Enterキーでも追加できるように
        document.getElementById('taskInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                addTask();
            }
        });
    </script>
</body>
</html>
```

### Artifactsでプレビュー

```
✅ 右側のパネルに実際に動くアプリが表示される
✅ タスクを追加してみる
✅ チェックボックスを試す
✅ 削除ボタンを試す
```

### カスタマイズ例

```
「完了したタスクを下に移動してください」
「ダークモードにしてください」
「タスクの優先度を設定できるようにしてください」
「期限を設定できるようにしてください」
```

---

## 実例2: 簡単な家計簿

### Claudeへの指示

```markdown
以下の仕様で簡単な家計簿アプリを作ってください：

【機能】
1. 支出を記録
   - 日付、カテゴリ、金額、メモ
   - カテゴリ: 食費、交通費、娯楽、その他

2. 一覧表示
   - 最新の記録を上に表示
   - 削除ボタン

3. 集計
   - 今月の合計支出
   - カテゴリ別の合計

4. データ保存
   - localStorageに保存

【デザイン】
- 見やすい表形式
- カテゴリごとに色分け
```

### カスタマイズ例

```
「収入も記録できるようにしてください」
「月ごとに表示を切り替えられるようにしてください」
「CSVでエクスポートできるようにしてください」
「グラフで視覚化してください」
```

---

## 実例3: 日記アプリ

### Claudeへの指示

```markdown
以下の仕様でシンプルな日記アプリを作ってください：

【機能】
1. 日記を書く
   - 日付は自動入力
   - タイトルと本文

2. 一覧表示
   - 日付順に表示
   - クリックで詳細表示

3. 編集・削除
   - 編集ボタンで内容を変更
   - 削除ボタン

4. データ保存
   - localStorageに保存

【デザイン】
- 落ち着いた色合い
- 読みやすいフォント
```

---

## ダウンロードと保存

### 方法1: 単一HTMLファイル

```
1. Artifactsパネルの「Copy code」をクリック
2. テキストエディタに貼り付け
3. 「app.html」として保存
4. ブラウザで開く

✅ すぐに使える
✅ ファイル1つで完結
```

### 方法2: ブックマークレット化

```
Claudeに依頼:
「このアプリをブックマークレットにしてください」

→ ブラウザのブックマークバーに追加
→ どのページからでも起動可能
```

### 方法3: GitHub Pagesで公開

```
1. GitHubアカウントを作成
2. 新しいリポジトリを作成
3. HTMLファイルをアップロード
4. GitHub Pagesを有効化

→ https://username.github.io/app/ でアクセス可能
→ スマホからも使える
```

---

## よくある質問

### Q1: コードを理解する必要はありますか？

```
A: 理解しなくても使えます。

ただし、簡単な修正（色変更、文字変更等）は
Claudeに依頼すればすぐにできます。
```

### Q2: スマホでも使えますか？

```
A: はい、使えます。

1. HTMLファイルをGitHub Pagesで公開
2. スマホのブラウザでアクセス
3. ホーム画面に追加

→ アプリのように使える
```

### Q3: データのバックアップは？

```
A: localStorageのデータは消える可能性があります。

対策:
1. CSVエクスポート機能を追加依頼
2. 定期的にエクスポート
3. Google Drive等に保存
```

### Q4: 他の人と共有できますか？

```
A: はい、できます。

方法:
1. GitHub Pagesで公開
2. URLを共有
3. 各自が自分のブラウザでデータを保存
```

### Q5: もっと複雑な機能を追加したい

```
A: 段階的に依頼してください。

例:
1. 基本機能を作る
2. 「ユーザー認証を追加してください」
3. 「データをFirebaseに保存してください」

→ 徐々に機能追加していける
```

---

## 作れるアプリの例

### 個人用ツール

```
✅ ToDoリスト
✅ 日記・メモ
✅ 家計簿
✅ 読書記録
✅ 勉強時間記録
✅ 体重記録
✅ パスワードジェネレーター
✅ タイマー・ストップウォッチ
```

### 業務ツール

```
✅ 議事録テンプレート
✅ タスク管理
✅ 勤怠記録
✅ 経費精算フォーム
✅ 在庫管理
✅ 顧客管理（簡易版）
```

### クリエイティブツール

```
✅ アイデアメモ
✅ ストーリープロッター
✅ キャラクター設定管理
✅ 配色ジェネレーター
✅ マークダウンエディタ
```

---

## 成功のポイント

### 1. 小さく始める

```
❌ 「完璧な家計簿アプリを作ってください」
✅ 「まず支出を記録できる機能だけ作ってください」

→ 基本機能から始めて、徐々に追加
```

### 2. 具体的に依頼する

```
❌ 「きれいなデザインにして」
✅ 「背景を淡い青色、ボタンを丸角にしてください」

→ 具体的な指示の方が期待通りになる
```

### 3. 一つずつ修正する

```
❌ 「色を変えて、レイアウトも変えて、機能も追加して」
✅ 「まず背景色を変えてください」
    → 確認
    → 「次にボタンの位置を調整してください」

→ 一つずつ確認しながら進める
```

### 4. 動作確認を忘れずに

```
Artifactsでプレビュー
  ↓
実際に使ってみる
  ↓
問題があれば修正依頼
  ↓
満足したらダウンロード
```

---

## 05章との使い分け

### このような場合は05章へ

```
❌ モバイルアプリが必要
❌ デスクトップアプリが必要
❌ 複雑なデータベース連携
❌ 本格的な事業化
❌ チーム開発
```

### このような場合は06章（この章）で十分

```
✅ 自分だけが使う
✅ ブラウザで動けばOK
✅ シンプルな機能
✅ すぐに作りたい
✅ コストを抑えたい（Cursor不要）
```

---

## まとめ

**プログラミングを学ばなくても、Claudeとの会話だけで実用的なWebアプリが作れます。**

**このアプローチが向いている人:**
- ✅ ちょっとした自分用ツールが欲しい
- ✅ コードは理解しなくていい
- ✅ ブラウザで動けば十分
- ✅ 定額で安心して使いたい

**必要なもの:**
- ✅ Claude Pro（月3,100-3,875円）
- ✅ Webブラウザ
- ❌ Cursor不要
- ❌ プログラミング知識不要

**作れるもの:**
- ✅ ToDoリスト、家計簿、日記
- ✅ 業務ツール、クリエイティブツール
- ✅ 個人用の小さなアプリ全般

**次のステップ:**

1. Claude Proに登録
2. Projectを作成
3. 簡単なToDoリストから始める
4. 自分のニーズに合わせてカスタマイズ
5. 便利なツールを増やしていく

**本格的な開発に挑戦したくなったら:**

[05_chefs_specials](../05_chefs_specials/) でCursor + Claudeを使った本格開発を学べます。

---

**補足: Claude Proの料金について**

今回の議論で明らかになったように、Claude Proは：
- ✅ 定額でWeb + API両方使える唯一のサービス
- ✅ 使いすぎの心配なし
- ✅ 家計管理がシンプル

ChatGPT PlusやGemini Advancedは、APIが別料金のため、開発とチャット相談で2つの契約が必要になる可能性があります。

**自分用の小さなツール作りには、Claude Pro（チャットのみ）が最適です。**
