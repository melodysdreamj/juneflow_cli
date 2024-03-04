import 'package:args/args.dart';

import 'function/add_global_export_if_not_exists/function.dart';
import 'function/check_is_right_project/function.dart';
import 'function/clone_or_update_github_repository/function.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    )

    ..addFlag(
      'practice',
      negatable: false,
      help: 'Run the practices.',
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart juneflutter_cli.dart <flags> [arguments]');
  print(argParser.usage);
}

void runPractices(List<String> testArgs) async {
  print('Running practices...');
  if (testArgs.isNotEmpty) {
    print('Test arguments: $testArgs');
    // 여기에 테스트 실행 로직을 구현합니다.
    // 예를 들어, testArgs에 따라 다른 테스트 케이스를 실행할 수 있습니다.
    if(testArgs.first == 'add_global_export_if_not_exists') {
      print('add_global_export_if_not_exists');
      addExportIfNotExists('new/package/path.dart');
    }
    if(testArgs.first == 'flutter_package_add') {
      print('flutter_package_add');
    }
    if(testArgs.first == 'flutter_package_remove') {
      print('flutter_package_remove');
    }
    if(testArgs.first == 'clone_or_update_git_repository') {
      print('clone_or_update_git_repository');
      cloneOrUpdateGitHubRepository('https://github.com/melodysdreamj/JuneFlutter',
          branchName: 'view_store');
    }
    if(testArgs.first == 'check_is_right_project') {
      print('check_is_right_project:${await checkIsRightProject()}');
    }
  } else {
    print('No test arguments provided.');
    // 기본 테스트 실행 로직을 구현합니다.

  }
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      print('juneflutter_cli version: $version');
      return;
    }
    if (results.wasParsed('verbose')) {
      verbose = true;
    }

    // 테스트 플래그를 처리합니다.
    if (results.wasParsed('practice')) {
      runPractices(results.rest); // 테스트 실행 함수를 호출합니다.
      return;
    }

    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');
    if (verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}
