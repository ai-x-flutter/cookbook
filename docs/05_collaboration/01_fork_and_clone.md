# レシピ#5-1: 他の人のリポジトリをFork & Cloneする

オープンソース開発に参加したり、他の人の優れたコードを参考にしたりする第一歩は、リポジトリを**Fork**し、それを自分のPCに持ってくることです。このマニュアルでは、その一連の手順を解説します。

## なぜForkするのか？

*   **自由に実験できる:** Forkすると、元のリポジトリの完全なコピーが、あなたのGitHubアカウント配下に作成されます。これにより、あなたは元のリポジトリに影響を与えることなく、自由にコードを変更したり、新しい機能を追加したりできます。
*   **貢献（Pull Request）の準備:** あなたがForkしたリポジトリで行った改善を、元のリポジトリに「こういう改善をしたので、取り込んでくれませんか？」と提案（Pull Request）することができます。これがオープンソースへの貢献の基本フローです。

## 用語の整理

*   **Upstream (上流):** あなたがForkした**元の**リポジトリのこと。（例: `flutter/flutter`）
*   **Origin (起点):** あなたがForkして作成された、**あなたのアカウント配下にある**リポジトリのこと。（例: `your-username/flutter`）

![Forkの概念図](https://docs.github.com/assets/cb-130393/images/help/repository/fork-repo-diagram.png)

---

## Step 1: GitHub上でリポジトリをForkする

1.  GitHubで、Forkしたいリポジトリのページにアクセスします。
2.  ページの右上にある「**Fork**」ボタンをクリックします。
3.  「Create a new fork」という画面が表示されます。
    *   **Owner:** あなたのGitHubアカウントが選択されていることを確認します。
    *   **Repository name:** 通常は元のリポジトリ名と同じでOKです。
4.  「**Create fork**」ボタンをクリックします。

数秒待つと、あなたのGitHubアカウント配下に、同じ名前のリポジトリのコピーが作成され、そのページに移動します。ブラウザのアドレスバーが `github.com/your-username/repository-name` になっていることを確認してください。

---

## Step 2: ForkしたリポジトリをPCにCloneする

次に、あなたのGitHubアカウント上にあるリポジトリ（Origin）を、あなたのPCにダウンロードします。この作業を`clone`と呼びます。

1.  あなたがForkして作成したリポジトリのページ（`github.com/your-username/repository-name`）を開きます。
2.  緑色の「**<> Code**」ボタンをクリックします。
3.  表示されたURL（HTTPSまたはSSH）の右側にあるコピーボタンをクリックして、URLをコピーします。
    *   通常は `https://github.com/your-username/repository-name.git` のようなURLです。

4.  PCのターミナルを開き、プロジェクトを置きたい親フォルダに移動します。
    ```bash
    # 例: ~/Development (macOS) や C:\dev (Windows) など
    cd path/to/your/projects_folder
    ```
5.  `git clone` コマンドを使って、リポジトリをクローンします。
    ```bash
    git clone https://github.com/your-username/repository-name.git
    ```

これで、あなたのPC上にリポジトリの全ファイルがダウンロードされ、作業準備が整いました。

---

## Step 3: Upstream（本家）の変更を取り込めるように設定する

あなたは今、自分のリポジトリのコピーを手元に持っています。しかし、その間に元のリポジトリ（Upstream）は、他の開発者によって更新されていくかもしれません。

その最新の変更を、あなたのローカルリポジトリにも取り込めるように、「リモートリポジトリ」としてUpstreamを登録しておく必要があります。これは非常に重要な設定です。

1.  ターミナルで、先ほどクローンしたリポジトリのディレクトリに移動します。
    ```bash
    cd repository-name
    ```

2.  現在登録されているリモートリポジトリを確認します。
    ```bash
    git remote -v
    ```
    実行すると、`origin` という名前で、あなた自身のGitHubリポジトリのURLが表示されるはずです。

3.  次に、**元のリポジトリ**（Upstream）を `upstream` という名前でリモートに追加します。
    *   まず、元のリポジトリのURL（例: `https://github.com/flutter/flutter.git`）をコピーします。
    *   以下のコマンドを実行します。
    ```bash
    # git remote add <リモート名> <元のリポジトリのURL>
    git remote add upstream https://github.com/original-owner/repository-name.git
    ```

4.  再度 `git remote -v` を実行して、`origin` と `upstream` の両方が登録されていることを確認してください。
    ```
    origin    https://github.com/your-username/repository-name.git (fetch)
    origin    https://github.com/your-username/repository-name.git (push)
    upstream  https://github.com/original-owner/repository-name.git (fetch)
    upstream  https://github.com/original-owner/repository-name.git (push)
    ```
    この状態になっていれば完璧です！

---

## Step 4: Upstreamの最新の変更を取り込む（Pullする）

これで、いつでもUpstreamの最新状態に追いつくことができます。

1.  まず、Upstreamリポジトリの最新情報を取得します。
    ```bash
    git fetch upstream
    ```
2.  あなたの作業ブランチ（通常は `main` または `master`）に、Upstreamの変更をマージ（統合）します。
    ```bash
    # 現在のブランチがmainであることを確認
    git checkout main

    # upstreamのmainブランチの内容を、現在のブランチにマージする
    git merge upstream/main
    ```

これで、あなたのPC上のローカルリポジトリは、本家のリポジトリと全く同じ最新の状態になりました。ここから、あなた自身の変更を加えていくことができます。

次のレシピでは、このリポジトリで行った変更を、本家に提案（Pull Request）する方法を学びます。

➡️ **次のレシピへ:** [`02_push_and_pull_request.md`](./02_push_and_pull_request.md)