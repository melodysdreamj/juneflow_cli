import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;

class AnnotatedFunctionInfo {
  final String filePath;
  final String functionName;
  final double? index;

  AnnotatedFunctionInfo({required this.filePath, required this.functionName, this.index});
}

Future<void> findFunctionsAndGenerateFileBeforeMaterialApp() async {
  const String searchDirectory = 'lib/util/_commander/initial_app/ready_functions/before_material_app';
  const String targetFilePath = 'lib/util/_commander/initial_app/ready_functions/before_material_app/_commander.dart';
  final List<AnnotatedFunctionInfo> functions = await _findAnnotatedFunctions(searchDirectory);

  await _generateAndWriteReadyBeforeMaterialApp(functions, targetFilePath, searchDirectory);
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
      // 매개변수를 포함하는 함수 형태를 처리할 수 있도록 정규 표현식 수정
      final RegExp exp = RegExp(r'@ReadyBeforeMaterialApp\((index:\s*(\d+(\.\d+)?)\s*)?\)\s*Future<void>\s*(\w+)\s*\(\s*BuildContext context\s*\)\s*async', multiLine: true);
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

Future<void> _generateAndWriteReadyBeforeMaterialApp(List<AnnotatedFunctionInfo> functions, String targetFilePath, String searchDirectory) async {
  final StringBuffer functionCalls = StringBuffer();
  final Set<String> imports = {};

// 인덱스 기준으로 함수 정렬
  functions.sort((a, b) => a.index?.compareTo(b.index ?? 0) ?? -1);

// 인덱스가 있는 함수와 없는 함수를 분리
  final indexedFunctions = functions.where((f) => f.index != null).toList();
  final unindexedFunctions = functions.where((f) => f.index == null).toList();

// 인덱스가 있는 함수들의 호출문 생성
  for (final functionInfo in indexedFunctions) {
    final relativeFilePath = p.relative(functionInfo.filePath, from: p.dirname(targetFilePath));
    final importPath = relativeFilePath.replaceAll('\\', '/');
    imports.add("import '$importPath';");
    functionCalls.writeln('  await ${functionInfo.functionName}(context);');
  }

// 인덱스가 없는 함수들의 호출문 생성
  if (unindexedFunctions.isNotEmpty) {
    // 인덱스가 없는 함수가 단 하나인 경우, Future.wait 없이 직접 호출
    if (unindexedFunctions.length == 1) {
      final functionInfo = unindexedFunctions.first;
      final relativeFilePath = p.relative(functionInfo.filePath, from: p.dirname(targetFilePath));
      final importPath = relativeFilePath.replaceAll('\\', '/');
      imports.add("import '$importPath';");
      functionCalls.writeln('  await ${functionInfo.functionName}(context);');
    } else {
      // 여러 개인 경우, Future.wait 사용
      functionCalls.writeln('  await Future.wait([');
      for (final functionInfo in unindexedFunctions) {
        final relativeFilePath = p.relative(functionInfo.filePath, from: p.dirname(targetFilePath));
        final importPath = relativeFilePath.replaceAll('\\', '/');
        imports.add("import '$importPath';");
        functionCalls.writeln('    ${functionInfo.functionName}(context),');
      }
      functionCalls.writeln('  ]);');
    }
  }

  final String importStatements = imports.join('\n');

  final String readyBeforeMaterialAppFunction = '''
import 'package:flutter/material.dart';
import '../../../../../main.dart';
$importStatements

/// At this stage, the context is directly received from MyApp,
/// so it does not contain information on navigation and various other aspects.
/// Please keep this in mind when using it.
Future<void> readyBeforeMaterialApp(BuildContext context) async {
${functionCalls.toString()}
}
''';

  final File targetFile = File(targetFilePath);
  await targetFile.writeAsString(readyBeforeMaterialAppFunction);
  print('readyBeforeMaterialApp util updated successfully with dynamic imports and util calls.');
}

Future<void> main() async {
  await findFunctionsAndGenerateFileBeforeMaterialApp();
}
