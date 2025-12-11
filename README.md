# 🍳 AI x Flutter Cookbook

**AIをエージェントとして活用し、Flutter開発を学び、加速させるための実践的なレシピ集。**

AIは「ペアプログラマー」から「エージェント」へと進化しました。Cursor, Claude Code, Antigravityなどのツールにより、初心者でもAIに開発を任せられる時代になりました。コードを一緒に書く時代から、タスクを任せて設計と判断に集中する時代へ。このCookbookは、その新しい開発スタイルを探求し、知見を共有する場所です。

プログラミング初心者から経験豊富な開発者まで、AIとの協働に興味があるすべての人を歓迎します。

[![CC BY-SA 4.0][cc-by-sa-shield]][cc-by-sa]

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/
[cc-by-sa-shield]: https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg

---

### 🤖 このCookbookの成り立ちについて (A Note from the Human Editor)

この`ai-x-flutter/cookbook`は、「**AIと協力して、一体どうすれば質の高いアプリを効率的に開発できるのだろう？**」という、私自身の素朴な問いから始まりました。

当初、私はChatGPTやGoogle AIをパートナーとして、数百回にわたる対話を重ねました。このCookbookの初期バージョンは、その長い対話の結晶です。

#### AIエージェント時代への転換

2025年後半、AI開発ツールは大きく進化しました。コードを一緒に書く時代から、タスクを任せて設計と判断に集中する時代へ。

この転換で見えてきたのは、**コーディングエージェントに必要な能力は、難しい問題を解く能力ではない**ということです。

一番困るのは、ハルシネーションを起こして、それでコードを書き換えてしまうこと。そして、古い記憶を「正解」として押し付け、最新のAPIを無視してしまうこと。エージェントには、記憶に頼らず新しいドキュメントを読み解く能力と、「分からないことは分からない」と言える誠実さが求められます。

だからこそ、正確性と信頼性が重視されるClaudeがコーディングで選ばれています。現在、このCookbookはClaudeとの協働で更新を続けています。

#### 実際のアプリ開発から得た教訓

AIとの協働でアプリを開発する中で、もう一つ重要な気づきがありました。それは、**Riverpod等の高機能パッケージを避けること**です。

高機能なパッケージほど、AIはハルシネーションを起こしやすくなります。複雑なAPI、頻繁なバージョン変更、抽象化されたパターン。これらがAIの「古い記憶」と衝突し、動かないコードや既存コードの破壊を引き起こします。

このCookbookが「小さな自己完結型Widget」を推奨するのは、この経験に基づいています。シンプルな構造は、人間にもAIにも優しい。依存関係が少ないほど、AIは正確に動作します。

#### 人間の役割

私は「編集長」として問いを立て、方向性を示し、AIからの提案を吟味・修正してきました。AIは「優秀な共著者」として、膨大な知識から瞬時に回答とコードを生成し、時には私自身も気づかなかった視点を提供してくれました。

このCookbookは、単にAIとの開発手法を解説するだけでなく、**その制作プロセス自体が「AIと人間がどのように協力して、新しい価値を創造できるか」という実験**でもあります。

どうか、このレシピ集をあなたの学習に役立ててください。そして、あなたもAIとの対話を通じて得た新しい発見があれば、ぜひPull Requestを送ってください。それもまた、この対話の続きとなるのですから。

---

## 📖 このCookbookで学べること

*   **AIとの対話術:** Cursor, Claude Code, Antigravityから、意図通りのコードやアイデアを引き出すための具体的なプロンプト技術と開発ワークフロー。
*   **シンプルな設計:** Flutterの標準機能を活かした「小さな自己完結型Widget」による、AIフレンドリーな状態管理。
*   **モダンな開発ワークフロー:** CI/CD（GitHub Actions）など、現代的なアプリ開発に不可欠な技術を、AIの助けを借りて効率的に実装する手順。
*   **実践的なトラブルシューティング:** 誰もが遭遇するエラーの原因を理解し、AIと共に解決していくための具体的な手法。

## 🗺️ レシピ一覧 (Table of Contents)

このCookbookは、あなたが料理の腕を上げていくように、ステップバイステップで学べる構成になっています。

---

###  sección 1: 🍳 キッチンの準備 (The Kitchen)
*開発を始めるための全ての準備を整えます。*

*   [#1-1: Flutter開発環境の準備](docs/01_the_kitchen/01_setting_up_flutter.md)
*   [#1-2: AI開発ツールの導入 - Cursor, Claude, Claude Code](docs/01_the_kitchen/02_ai_development_tools.md)
*   [#1-3: 最初のFlutterアプリ作成とプロジェクト探検](docs/01_the_kitchen/03_creating_first_app.md)
*   [#1-4: iOS開発の準備とセットアップ](docs/01_the_kitchen/04_ios_development_setup.md)
*   [#1-5: アプリのIDとアセットの準備](docs/01_the_kitchen/05_project_identity_and_assets.md)
*   [#1-6: 自分のプロジェクトをGitHubで管理する](docs/01_the_kitchen/06_managing_project_with_github.md)
*   [#1-7: GitHub CLIでPCを認証する](docs/01_the_kitchen/07_authenticating_with_github_cli.md)

---

### sección 2: 📚 Flutterの重要概念 (Core Concepts)
*アプリの「骨格」となる、Flutterの基本的な考え方を学びます。*

*   [#2-0: はじめに - なぜ概念を学ぶのか](docs/02_core_concepts/00_introduction.md)
*   [#2-1: Flutterの心臓部「ウィジェット」とは何か？](docs/02_core_concepts/01_what_is_a_widget.md)
*   [#2-2: 状態管理（State Management）とは何か？](docs/02_core_concepts/02_state_management_basics.md)
*   [#2-3: 非同期プログラミング（Futureとasync/await）](docs/02_core_concepts/03_async_programming.md)
*   [#2-4: 画面遷移の基本（Routing）](docs/02_core_concepts/04_introduction_to_routing.md)
*   [#2-5: `BuildContext`とは何か？ - ウィジェットの「現在地」](docs/02_core_concepts/05_understanding_build_context.md)

---

### sección 3: 🧑‍🍳 料理のプロセス (Cooking Process)
*AIと共に、一つのアプリをゼロから完成させるまでの開発フローを体験します。*

*   [#3-1: AIと決めるシンプルなプロジェクト構成](docs/03_cooking_process/01_simple_project_structure_with_ai.md)
*   [#3-2: AIと対話しながらUIを構築する](docs/03_cooking_process/02_building_ui_with_ai.md)
*   [#3-3: AIと実装するロジックと状態管理](docs/03_cooking_process/03_implementing_logic_with_ai.md)
*   [#3-4: AIによるデータ永続化の実装](docs/03_cooking_process/04_implementing_persistence_with_ai.md)
*   [#3-5: AIを擬似サーバーにして、API通信を実装する](docs/03_cooking_process/05_api_integration_with_ai.md)
*   [#3-6: AIによる最終コードレビューと品質向上](docs/03_cooking_process/06_finalizing_with_ai_code_review.md)
*   [#3-7: 手動でのリリースとストア公開](docs/03_cooking_process/07_manual_release_and_publication.md)
*   [#3-8: Androidビルドの自動化 with GitHub Actions](docs/03_cooking_process/08_ci_cd_with_github_actions_android.md)
*   [#3-9: iOSビルドの自動化 with GitHub Actions](docs/03_cooking_process/09_ci_cd_with_github_actions_ios.md)

---

### sección 4: 🌶️ 秘伝のソース (Secret Sauce Recipes)
*Cursor + Claudeを使った実践的な開発パターンとベストプラクティス。*

*   [#4-1: Cursorを使った効率的な開発ワークフロー](docs/04_secret_sauce_recipes/01_cursor_workflow.md)
*   [#4-2: なぜRiverpodを避けるべきか - 個人開発 × AI時代の状態管理](docs/04_secret_sauce_recipes/02_why_avoid_riverpod.md)
*   [#4-3: 自己完結型Widgetパターン](docs/04_secret_sauce_recipes/03_self_contained_widget_pattern.md)
*   [#4-4: Serviceクラスパターン - ビジネスロジックの分離](docs/04_secret_sauce_recipes/04_service_class_pattern.md)
*   [#4-5: Cursor + Claudeでシンプルなアプリを作る（メモアプリ）](docs/04_secret_sauce_recipes/05_building_simple_app.md)
*   [#4-6: Google Antigravityを試す（注意点付き）](docs/04_secret_sauce_recipes/06_antigravity_with_cautions.md)
*   [#4-7: 実践 - Cursorで完全なTODOアプリを作る](docs/04_secret_sauce_recipes/07_building_todo_app.md)
*   [#4-8: 実践 - APIを使ったニュースアプリを作る](docs/04_secret_sauce_recipes/08_building_api_app.md)
*   [#4-9: AIのトークン消費を抑える実践テクニック](docs/04_secret_sauce_recipes/09_reducing_token_consumption.md)

---

### sección 5: 🌟 シェフの特別料理 (Chef's Specials)
*Cursor + Claudeで作る、高度な機能を持つ実用的なアプリのケーススタディ集。*

*   [#5-1: AIチャットアプリを作る - Claude API / Gemini API連携](docs/05_chefs_specials/01_building_chat_app_with_gemini.md)
*   [#5-2: 画像認識カメラアプリを作る - ML Kit / TFLite活用](docs/05_chefs_specials/02_building_image_recognition_app.md)
*   [#5-3: リアルタイム共有メモアプリを作る - Supabase Realtime](docs/05_chefs_specials/03_building_realtime_app.md)
*   [#5-4: レスポンシブデザインの基礎 - あらゆる画面サイズに対応する](docs/05_chefs_specials/04_responsive_design_basics.md)
*   [#5-5: デスクトップアプリを作る - Windows / macOS / Linux対応](docs/05_chefs_specials/05_building_desktop_app.md)
*   [#5-6: Webアプリを作る - ブラウザで動くFlutterアプリ](docs/05_chefs_specials/06_building_web_app.md)

---

### sección 6: 🤝 他のシェフとの協業 (Collaboration)
*オープンソースへの貢献や、チーム開発で必要となるGitのスキルを学びます。*

*   [#6-1: 他の人のリポジトリをFork & Cloneする](docs/06_collaboration/01_fork_and_clone.md)
*   [#6-2: Pull Requestで本家に貢献する](docs/06_collaboration/02_push_and_pull_request.md)
*   [#6-3: マージコンフリクト（競合）を解決する](docs/06_collaboration/03_resolving_merge_conflicts.md)

---

### sección 7: 🚑 救急箱 (Troubleshooting)
*開発中によく遭遇する問題とその解決策。困った時に開いてください。*

*   [#7-1: `Could not read workspace metadata` エラーを解決する](docs/07_troubleshooting/01_fix_gradle_metadata_error.md)
*   [#7-2: Flutterビルドエラー上級編](docs/07_troubleshooting/02_advanced_build_troubleshooting.md)
*   [#7-3: `Null check operator used on a null value`エラーを理解する](docs/07_troubleshooting/03_understanding_null_safety_errors.md)
*   [#7-4: AIとの開発で起こる典型的なトラブルと対処法](docs/07_troubleshooting/04_ai_development_troubleshooting.md)

---

### sección 8: ☁️ BFFとサーバーサイドDart (Backend For Frontend)
*AIと共に、Flutterアプリのためのバックエンド（BFF）をDartで構築します。*

*   [#8-1: なぜDartでバックエンドを作るのか？ (BFFの概念)](docs/08_backend_for_frontend_with_ai/01_why_dart_for_backend.md)
*   [#8-2: Dartバックエンドフレームワークの選定](docs/08_backend_for_frontend_with_ai/02_choosing_backend_framework.md)
*   [#8-3: AIと作るシンプルなREST API (Dart Frog編)](docs/08_backend_for_frontend_with_ai/03_building_simple_api_with_dart_frog.md)
*   [#8-4: FlutterアプリとDartバックエンドでコードを共有する](docs/08_backend_for_frontend_with_ai/04_sharing_code_between_flutter_and_backend.md)
*   [#8-5: AIと創るフルスタック認証 (Serverpod編)](docs/08_backend_for_frontend_with_ai/05_full_stack_development_with_serverpod.md)
*   [#8-6: AIと実装するリアルタイム通信 (WebSocket編)](docs/08_backend_for_frontend_with_ai/06_realtime_communication_with_websockets.md)
*   [#8-7: AIとデプロイするDartバックエンド (Cloud Run編)](docs/08_backend_for_frontend_with_ai/07_deploying_dart_backend_with_ai.md)

---


### sección 9: 🎨 設計とプロトタイピング (Design & Prototyping)
*コーディングを始める前に、AIと共にアプリの「魂」を設計します。*

*   [#9-0: はじめに - なぜ設計が重要か](docs/09_ai_for_design_and_prototyping/00_introduction.md)
*   [#9-1: AIと創るデザインシステム](docs/09_ai_for_design_and_prototyping/01_creating_a_design_system_with_ai.md)
*   [#9-2: AIと定義するユーザーペルソナとユーザーストーリー](docs/09_ai_for_design_and_prototyping/02_generating_personas_and_user_stories.md)
*   [#9-3: AI x Flutter時代のキャリアパスを設計する](docs/09_ai_for_design_and_prototyping/03_ai_x_flutter_career_path.md)

---



## 🤝 貢献 (Contributing)

このCookbookは、コミュニティと共に成長していきます。
新しいレシピの提案、誤字脱字の修正、より良い説明のアイデアなど、どんな小さな貢献も大歓迎です。IssueやPull Requestをお気軽にお送りください！


---

## 📜 License

このリポジトリは、コンテンツの性質に応じてライセンスを使い分けています。

### ドキュメント (`docs/` ディレクトリ)

`docs/`ディレクトリに含まれるすべてのドキュメント（文章、マニュアル）は、**[Creative Commons Attribution-ShareAlike 4.0 International License (CC BY-SA 4.0)](LICENSE)** の下でライセンスされています。

このライセンスは、このCookbookの知識が、常にオープンな形でコミュニティに共有され、発展し続けることを保証するためのものです。このドキュメントを元に派生作品を作る場合は、同じライセンスで公開してください。

[![CC BY-SA 4.0][cc-by-sa-shield]][cc-by-sa]

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/
[cc-by-sa-shield]: https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg

### サンプルコード (`examples/` ディレクトリ)

`examples/`ディレクトリに含まれるすべてのサンプルコードは、**[Creative Commons Zero v1.0 Universal (CC0 1.0)](examples/LICENSE)** の下で、**パブリックドメイン**に提供されています。

これは、あなたがCookbookで学んだコードを、**いかなる制約もなく、著作権表示の義務すらなく**、商用・非商用を問わず、あらゆるプロジェクトで完全に自由に、そして安心して再利用できるようにするためです。

[![CC0][cc0-shield]][cc0]

[cc0]: http://creativecommons.org/publicdomain/zero/1.0/
[cc0-shield]: https://img.shields.io/badge/License-CC0%201.0-lightgrey.svg