import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;

class ReadyBeforeRunApp {
  final double? index;

  const ReadyBeforeRunApp({this.index});
}

class AnnotatedFunctionInfo {
  final String filePath;
  final String functionName;
  final double? index;

  AnnotatedFunctionInfo({required this.filePath, required this.functionName, this.index});
}

Future<void> findFunctionsAndGenerateFile() async {
  const String searchDirectory = 'lib/util/ready_app/ready_functions/before_run_app';
  const String targetFilePath = 'lib/util/ready_app/ready_functions/before_run_app/_.dart';
  final List<AnnotatedFunctionInfo> functions = await _findAnnotatedFunctions(searchDirectory);

  await _generateAndWriteReadyBeforeRunApp(functions, targetFilePath, searchDirectory);
}

Future<List<AnnotatedFunctionInfo>> _findAnnotatedFunctions(String searchDirectory) async {
  final List<AnnotatedFunctionInfo> functions = [];
  final directory = Directory(searchDirectory);
  if (!directory.existsSync()) {
    print('Search directory does not exist.');
    return functions;
  }

  await for (final file in directory.list(recursive: true, followLinks: false)) {
    if (file is File && file.path.endsWith('.dart')) {
      final content = await file.readAsString();
      final RegExp exp = RegExp(r'@ReadyBeforeRunApp\((index:\s*(\d+(\.\d+)?)\s*)?\)\s*Future<void>\s*(\w+)\s*\(\)\s*async', multiLine: true);
      final matches = exp.allMatches(content);

      for (final match in matches) {
        final index = match.group(2) != null ? double.parse(match.group(2)!) : null;
        final functionName = match.group(4)!;
        functions.add(AnnotatedFunctionInfo(filePath: file.path, functionName: functionName, index: index));
      }
    }
  }

  return functions;
}

Future<void> _generateAndWriteReadyBeforeRunApp(List<AnnotatedFunctionInfo> functions, String targetFilePath, String searchDirectory) async {
  final StringBuffer functionCalls = StringBuffer();
  final Set<String> imports = {};

  functions.sort((a, b) => a.index?.compareTo(b.index ?? 0) ?? -1);

  for (final functionInfo in functions) {
    final relativeFilePath = p.relative(functionInfo.filePath, from: p.dirname(targetFilePath));
    final importPath = relativeFilePath.replaceAll('\\', '/');
    imports.add("import '$importPath';");

    functionCalls.writeln('  await ${functionInfo.functionName}();');
  }

  if (functions.any((f) => f.index == null)) {
    functionCalls.write('  await Future.wait([\n');
    functions.where((f) => f.index == null).forEach((functionInfo) {
      functionCalls.write('    ${functionInfo.functionName}(),\n');
    });
    functionCalls.write('  ]);\n');
  }

  final String importStatements = imports.join('\n');

  final String readyBeforeRunAppFunction = '''
import 'package:flutter/material.dart';

import '../../../../main.dart';

import 'web_url_strategy/none.dart'
    if (dart.library.html) 'web_url_strategy/_.dart' as url_strategy;
$importStatements

Future<void> readyBeforeRunApp() async {
  url_strategy.readyForWebUrlStrategy();

  await readyForWidgetsBinding();

${functionCalls.toString()}
}
''';

  final File targetFile = File(targetFilePath);
  await targetFile.writeAsString(readyBeforeRunAppFunction);
  print('readyBeforeRunApp function updated successfully with dynamic imports.');
}

Future<void> main() async {
  await findFunctionsAndGenerateFile();
}
