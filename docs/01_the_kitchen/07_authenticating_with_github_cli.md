# レシピ#1-7: GitHub CLIでPCを認証する

前のレシピで`git push`を実行した際、認証エラーが出たか、あるいはユーザー名とパスワードを尋ねられて困惑したかもしれません。現在のGitHubでは、パスワードを使った`git`操作はセキュリティ上の理由から廃止されています。

このレシピでは、**GitHubの公式コマンドラインツールである `gh` (GitHub CLI)** を使って、あなたのPCとGitHubアカウントを安全に、そして恒久的に接続（認証）する方法を解説します。

この設定は、**あなたのPCで最初の一度だけ**行えばOKです。完了すれば、今後の`git push`や`git pull`で、認証情報を尋ねられることは二度とありません。

---

## Step 1: GitHub CLIのインストール

まず、お使いのOSにGitHub CLI (`gh`) をインストールします。

*   **Windows (Wingetを使用):**
    ターミナル（PowerShell）で以下のコマンドを実行します。
    ```powershell
    winget install --id GitHub.cli
    ```

*   **macOS (Homebrewを使用):**
    ターミナルで以下のコマンドを実行します。
    ```bash
    brew install gh
    ```

*   **Linux (Debian/Ubuntu系):**
    ターミナルで以下のコマンドを実行します。
    ```bash
    sudo apt update
    sudo apt install gh
    ```
    *(もし上記以外の環境の場合や、うまくいかない場合は、[GitHub CLI公式インストールガイド](https://github.com/cli/cli#installation)を参照してください)*

インストールが完了したら、ターミナルで`gh --version`と入力し、バージョン情報が表示されれば成功です。

---

## Step 2: GitHubアカウントとの連携認証

次に、インストールした`gh`を、あなたのGitHubアカウントと連携させます。ターミナルで以下のコマンドを実行し、表示される質問に答えていくだけです。

```bash
gh auth login
```

### 【対話の手順】

以下のように、ターミナルがあなたに質問をしてきます。矢印キーで選択し、Enterキーで決定してください。

1.  **ログイン先のアカウントは？**
    `? What account do you want to log into?`
    ➡️ **`GitHub.com`** を選択します。

2.  **Git操作で使うプロトコルは？**
    `? What is your preferred protocol for Git operations?`
    ➡️ **`HTTPS`** を選択します。（ファイアウォールなどがある環境でも動作しやすく、初心者におすすめです）

3.  **Gitの認証情報を`gh`で上書きする？**
    `? Authenticate Git with your GitHub credentials?`
    ➡️ **`Y`** (Yes) を入力してEnterを押します。（`gh`にGitの認証を管理させるための重要なステップです）

4.  **どうやって認証する？**
    `? How would you like to authenticate GitHub CLI?`
    ➡️ **`Login with a web browser`** を選択します。（最も簡単で安全な方法です）

5.  **ワンタイムコードのコピー**
    `! First copy your one-time code: XXXX-XXXX`
    ターミナルに、ハイフンで繋がれた8桁の**ワンタイムコード**が表示されます。
    このコードをマウスで選択し、コピーしてください (`Ctrl+C` or `Cmd+C`)。

    コピーしたら、`Press Enter to open github.com in your browser...` と表示されている状態で、**Enterキー**を押します。

6.  **ブラウザでの認証**
    *   自動的にWebブラウザが起動し、GitHubのデバイス認証ページが開きます。
    *   先ほどコピーしたワンタイムコードを、ページの入力欄に貼り付けます。
    *   「Continue」をクリックし、次の画面で「Authorize GitHub CLI（承認）」ボタンをクリックします。
    *   GitHubのパスワード（またはパスキー）の入力を求められたら、入力してください。

7.  **完了！**
    ターミナルに戻ると、「✓ Authentication complete.」といった成功メッセージが表示されているはずです。

---

## Step 3: 最終確認

最後に、すべてが正しく設定されたかを確認しましょう。

```bash
gh auth status
```
以下のように、緑色のチェックマークと共に、あなたのユーザー名が表示されれば、すべての設定は完璧です。
```
✓ Logged in to github.com as your-username
✓ Git operations for github.com will use https protocol.
✓ Token valid for repo, gist, ... scopes.
```

おめでとうございます！
これで、あなたのPCはGitHubと完全に信頼関係を結びました。
前のレシピに戻って、もう一度`git push -u origin main`を実行してみてください。今度は、パスワードやトークンを尋ねられることなく、スムーズにコードがアップロードされるはずです。

これで、本当に「キッチンの準備」は万端です。次のセクションから始まる、本格的な「料理（開発プロセス）」を存分に楽しんでください！