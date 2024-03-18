import 'package:args/args.dart';

import 'util/add_global_export_if_not_exists/function.dart';
import 'util/check_is_right_project/function.dart';
import 'util/clone_or_update_github_repository/function.dart';
import 'util/find_ready_annotation_and_generate_ready_code/function.dart';
import 'util/flutter_package_add/function.dart';
import 'util/flutter_package_remove/function.dart';

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
      'create-app',
      negatable: false,
      help: 'Create a new app.',
    )

    ..addFlag(
      'build',
      negatable: false,
      help: 'initialize the project.',
    )

      // ..addFlag(
      //   'practice',
      //   negatable: false,
      //   help: 'Run the practices.',
      // );
      ;
}

void printUsage(ArgParser argParser) {
  print('Usage: dart juneflow_cli.dart <flags> [arguments]');
  print(argParser.usage);
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
      print('juneflow_cli version: $version');
      return;
    }
    if (results.wasParsed('verbose')) {
      verbose = true;
    }

    // 테스트 플래그를 처리합니다.
    if (results.wasParsed('create-app')) {
      print('create-app');
      return;
    }

    if (results.wasParsed('build')) {
      print('build');
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
