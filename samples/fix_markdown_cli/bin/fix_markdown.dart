import 'dart:io';
import 'package:args/args.dart';

// あなたが教えてくれたアルゴリズムを実装したコア関数
String correctBoldingLogic(String originalContent) {
  // 正規表現パターン: ** と ** で囲まれた、中身のテキストをキャプチャする
  final pattern = RegExp(r'\*\*(.*?)\*\*');
  
  // replaceAllMappedを使って、マッチした各箇所を個別に評価・置換する
  return originalContent.replaceAllMapped(pattern, (match) {
    // マッチした全体（例: **「テキスト」**）
    final fullMatch = match.group(0)!;
    // マッチした中身（例: 「テキスト」）
    String innerText = match.group(1)!;

    if (innerText.isEmpty) {
      return fullMatch;
    }

    const leftBrackets = '「（『【';
    const rightBrackets = '」）』】';

    String prefix = '';
    String suffix = '';

    // 条件A: 最初の文字が左括弧クラスか？
    if (leftBrackets.contains(innerText.substring(0, 1))) {
      prefix = innerText.substring(0, 1);
      innerText = innerText.substring(1);
    }

    // 条件B: 最後の文字が右括弧クラスか？
    // innerTextが空になっていないかチェック
    if (innerText.isNotEmpty && rightBrackets.contains(innerText.substring(innerText.length - 1))) {
      suffix = innerText.substring(innerText.length - 1);
      innerText = innerText.substring(0, innerText.length - 1);
    }
    
    // prefixかsuffixのどちらかが設定された場合のみ、再構築を行う
    // （つまり、何らかの修正が必要だった場合）
    if (prefix.isNotEmpty || suffix.isNotEmpty) {
      // 新しい形式を組み立てる
      return '$prefix**$innerText**$suffix';
    } else {
      // 条件に一致しない場合（通常の太字など）は、一切変更せずにそのまま返す
      return fullMatch;
    }
  });
}

Future<void> fixMarkdownBolding(String repoPath, bool dryRun) async {
  print('--- Markdown GFM互換性修正プログラム (Dart版) ---');
  print('🔍 ターゲットディレクトリ: $repoPath');
  if (dryRun) {
    print('👕 ドライランモードで実行します。ファイルは変更されません。');
  }
  print('-' * 40);

  final markdownFiles = await _getGitFiles(repoPath);
  if (markdownFiles.isEmpty) {
    print('📄 処理対象のMarkdownファイルが見つかりませんでした。');
    return;
  }

  var fixedFilesCount = 0;
  
  for (final mdFileRelative in markdownFiles) {
    final file = File('$repoPath/$mdFileRelative');
    if (!await file.exists()) continue;

    final originalContent = await file.readAsString();
    final newContent = correctBoldingLogic(originalContent);

    // 実際に変更があった場合のみ処理
    if (originalContent != newContent) {
      print('❗ GFM互換性の問題を $mdFileRelative で発見。');
      fixedFilesCount++;
      
      if (!dryRun) {
        await file.writeAsString(newContent);
        print('   -> ✅ ファイルを修正し、上書き保存しました。');
      } else {
        print('   -> (ドライランのため、変更はスキップしました)');
      }
    }
  }

  print('-' * 40);
  if (fixedFilesCount > 0) {
    if (!dryRun) {
      print('🎉 完了！合計 $fixedFilesCount 個のファイルを修正しました。');
      print('git diff で変更内容を確認し、問題がなければコミット＆プッシュしてください。');
    } else {
      print('👕 ドライラン完了。合計 $fixedFilesCount 個のファイルで問題が発見されました。');
      print('実際に修正するには、--dry-runオプションを外して再度実行してください。');
    }
  } else {
    print('👍 素晴らしい！修正が必要なファイルは見つかりませんでした。');
  }
  print('--- プログラムを終了します ---');
}

// _getGitFiles と main 関数は、前の回答から変更ありません。
Future<List<String>> _getGitFiles(String repoPath) async {
  try {
    final result = await Process.run('git', ['ls-files', '*.md'], workingDirectory: repoPath);
    if (result.exitCode != 0) {
        print('❌ git ls-filesの実行に失敗: ${result.stderr}');
        return [];
    }
    return result.stdout.toString().split(Platform.lineTerminator).where((s) => s.isNotEmpty).toList();
  } catch(e) {
    print('❌ Gitコマンドの実行に失敗しました。Gitはインストールされていますか？: $e');
    return [];
  }
}

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('path', abbr: 'p', mandatory: true, help: 'レビュー対象のリポジトリのパス')
    ..addFlag('dry-run', abbr: 'd', negatable: false, help: '実際にファイルを変更せず、修正対象のファイルを表示するだけ（ドライラン）')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'このヘルプメッセージを表示');

  try {
    final argResults = parser.parse(arguments);
    if (argResults['help']) {
      print('使用法: dart run <script.dart> --path <リポジトリパス> [--dry-run]');
      print(parser.usage);
      return;
    }
    final repoPath = argResults['path'];
    final dryRun = argResults['dry-run'] as bool;
    if (!Directory(repoPath).existsSync()) {
        print('❌ エラー: 指定されたパスが見つかりません: $repoPath');
        return;
    }
    fixMarkdownBolding(repoPath, dryRun);
  } on ArgParserException catch (e) {
    print('❌ 引数の解析に失敗しました: ${e.message}');
    print(parser.usage);
  }
}