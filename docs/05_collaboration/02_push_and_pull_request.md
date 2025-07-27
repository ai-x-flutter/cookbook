# レシピ#5-2: 変更をPushし、Pull Requestで本家に貢献する

Forkしたリポジトリで素晴らしい改善を加えたら、次はその変更を元のリポジトリ（Upstream）に取り込んでもらいましょう。このプロセスを**Pull Request（プルリクエスト）**、または親しみを込めて **PR** と呼びます。

このマニュアルでは、ローカルでの変更を自分のリモートリポジトリ（Origin）にPushし、そこからUpstreamへPull Requestを作成するまでの手順を解説します。

> **⚠️ 前提**
> このマニュアルは、[前のレシピ](./01_fork_and_clone.md)の続きです。Upstreamリポジトリの設定が完了していることを前提とします。

## オープンソースにおけるPull Requestのマナー

*   **1つのPRには、1つの関心事だけ:** バグ修正と新機能追加を同じPRに混ぜないでください。関連性のない変更は、別々のブランチで作業し、別々のPRを作成します。
*   **本家の規約に従う:** インデントや命名規則など、元のプロジェクトのスタイルに合わせましょう。多くのプロジェクトには`CONTRIBUTING.md`というファイルがあり、そこにルールが書かれています。
*   **分かりやすい説明を書く:** なぜこの変更が必要なのか、どのような問題が解決されるのかを、PRの説明欄に丁寧に記述します。レビュワーは、あなたの頭の中を読むことはできません。

---

## Step 1: 作業用のブランチを作成する

**重要:** `main`（または`master`）ブランチで直接作業するのは避けましょう。変更内容に合わせた名前のブランチを作成するのが、優れた開発者の習慣です。

1.  まず、ローカルの`main`ブランチがUpstreamの最新の状態であることを確認します。
    ```bash
    git checkout main
    git pull upstream main
    ```

2.  作業内容に合わせた名前で、新しいブランチを作成して、そのブランチに切り替えます。
    ```bash
    # git checkout -b <新しいブランチ名>
    git checkout -b fix/typo-in-readme
    ```
    *   ブランチ名の例:
        *   機能追加: `feature/add-login-button`
        *   バグ修正: `fix/incorrect-calculation`
        *   ドキュメント修正: `docs/update-installation-guide`

---

## Step 2: コードを編集し、コミットする

作成したブランチで、あなたの改善（コードの修正、機能追加など）を行います。作業が一区切りついたら、その変更を**コミット**（リポジトリの変更履歴に記録）します。

1.  変更を加えたファイルを**ステージングエリア**に追加します。
    ```bash
    # 特定のファイルを追加する場合
    git add path/to/your/file.dart

    # 変更したすべてのファイルを追加する場合
    git add .
    ```

2.  変更内容を説明するメッセージを付けてコミットします。
    ```bash
    git commit -m "Fix: Correct a typo in the README introduction"
    ```
    *   良いコミットメッセージの書き方:
        *   1行目は変更内容の要約（例: `Fix:`, `Feat:`, `Docs:` などの[Conventional Commits](https://www.conventionalcommits.org/)に従うと、よりプロフェッショナルです）。
        *   必要であれば、空行を挟んで2行目以降に詳細な説明を記述します。

---

## Step 3: 変更を自分のリモートリポジトリ（Origin）にPushする

ローカルPCで行ったコミットを、あなたのGitHub上のリポジトリ（Origin）にアップロードします。これを**Push**と呼びます。

```bash
# git push <リモート名> <ブランチ名>
git push origin fix/typo-in-readme
```

このコマンドは、「`origin`（あなたのGitHubリポジトリ）に、`fix/typo-in-readme`ブランチの変更をアップロードしてください」という意味です。

---

## Step 4: GitHub上でPull Requestを作成する

いよいよ最終段階です。Pushしたブランチから、UpstreamリポジトリへのPull Requestを作成します。

1.  あなたのGitHubリポジトリ（`github.com/your-username/repository-name`）のページにアクセスします。
2.  先ほどPushしたブランチ名と共に、「**Compare & pull request**」という緑色のボタンが表示されているはずです。これをクリックします。
    *   もしボタンが表示されていなければ、「Contribute」メニューから「Open pull request」をクリックします。

3.  **Pull Request作成画面**に移動します。ここで、いくつかの重要な項目を確認・編集します。
    *   **base repository:** `original-owner/repository-name` (Upstream)
    *   **base:** `main` (取り込んでもらう先のブランチ)
    *   **head repository:** `your-username/repository-name` (Origin)
    *   **compare:** `fix/typo-in-readme` (あなたがPushしたブランチ)

    この設定が「`original-owner`の`main`ブランチに、`your-username`の`fix/typo-in-readme`ブランチを取り込んでください」という意味になります。

4.  **タイトルと説明を記述します。**
    *   **タイトル:** コミットメッセージが自動で入りますが、PR全体の内容が分かるように、より包括的なタイトルに編集するのが親切です。
    *   **説明 (Description):** **ここが最も重要です。** 多くのプロジェクトにはPRのテンプレートが用意されています。それに従い、以下の点を明確に記述しましょう。
        *   **What (何を変更したか):** 変更点の概要。
        *   **Why (なぜ変更したか):** この変更が必要な理由。どんな問題を解決するのか。
        *   **How (どう実装したか):** (もしあれば) 技術的な詳細や、レビュワーに特に見てほしい点。
        *   関連するIssueがあれば、`Closes #123` や `Fixes #456` のように記述すると、このPRがマージされた時に自動でIssueも閉じられます。

5.  内容を確認したら、「**Create pull request**」ボタンをクリックします。

これで、あなたのPull RequestがUpstreamリポジトリに作成され、リポジトリの管理者に通知が送られます。管理者はあなたのコードをレビューし、修正依頼や質問をすることがあります。コミュニケーションを取りながら、マージを目指しましょう。

オープンソースへの最初の貢献、おめでとうございます！