import 'dart:io';

class AnnotationInfo {
  String path;
  String functionName;
  double? index; // 이제 index는 double 타입입니다.

  AnnotationInfo({required this.path, required this.functionName, this.index});
}


findReadyAnnotationsAndGenerateReadyCode() {
  final List<AnnotationInfo> readyRunAppList = [];
  final List<AnnotationInfo> readyAppList = [];
  final List<AnnotationInfo> readyMaterialAppList = [];

  String basePath = '${Directory.current.path}/lib/util/ready';

  final directory = Directory(basePath);
  if (directory.existsSync()) {
    directory.listSync(recursive: true).forEach((file) {
      if (file is File && file.path.endsWith('.dart')) {
        final relativePath = file.path.replaceFirst('$basePath/', ''); // 지정된 기본 경로 제거
        final content = file.readAsStringSync();

        // 어노테이션 검사를 위한 패턴 리스트
        var annotationPatterns = {
          'ReadyRunApp': readyRunAppList,
          'ReadyApp': readyAppList,
          'ReadyMaterialApp': readyMaterialAppList,
        };

        annotationPatterns.forEach((annotation, list) {
          // 어노테이션과 함수명 매칭 패턴
          RegExp exp = RegExp('@$annotation\\((index: (\\d+(\\.\\d+)?))?\\)\\s+Future<void>\\s+(\\w+)\\s*\\(\\)', multiLine: true);
          final matches = exp.allMatches(content);

          for (var match in matches) {
            final index = match.group(2) != null ? double.parse(match.group(2)!) : null;
            final functionName = match.group(4)!;

            list.add(AnnotationInfo(
              path: relativePath,
              functionName: functionName,
              index: index,
            ));
          }
        });
      }
    });
  }

  // 결과 출력
  print('ReadyRunApp Annotations:');
  readyRunAppList.forEach((info) =>
      print('${info.path} - ${info.functionName} - Index: ${info.index}'));
  print('ReadyApp Annotations:');
  readyAppList.forEach((info) =>
      print('${info.path} - ${info.functionName} - Index: ${info.index}'));
  print('ReadyMaterialApp Annotations:');
  readyMaterialAppList.forEach((info) =>
      print('${info.path} - ${info.functionName} - Index: ${info.index}'));

  var _ = _generateInitializationCode(
      readyRunAppList, readyAppList, readyMaterialAppList);
  // print(_);

  _overwriteFile("${Directory.current.path}/lib/util/ready/ready.dart", _);
}

String _generateInitializationCode(
    List<AnnotationInfo> readyRunAppList,
    List<AnnotationInfo> readyAppList,
    List<AnnotationInfo> readyMaterialAppList) {
  // 기본 import 구문과 변수 선언
  String baseImports = '''
import 'package:flutter/material.dart';
import '../start_app.dart';
import 'web_url_strategy/none.dart'
    if (dart.library.html) 'web_url_strategy/_.dart' as url_strategy;
''';

  // Import paths
  Set<String> allPaths = {...readyRunAppList, ...readyAppList, ...readyMaterialAppList}.map((info) => info.path).toSet();
  String imports = allPaths.map((path) => "import '$path';\n").join();

  // 함수 호출 정렬 및 생성
  String generateFunctionCalls(List<AnnotationInfo> annotations) {
    // 인덱스 있는 것과 없는 것 분리
    var indexed = annotations.where((info) => info.index != null).toList()
      ..sort((a, b) => a.index!.compareTo(b.index!));
    var nonIndexed = annotations.where((info) => info.index == null).toList();

    // 인덱스 있는 것 순서대로 실행
    String indexedCalls = indexed.map((info) => "  await ${info.functionName}();\n").join();

    // 인덱스 없는 것 동시 실행
    if (nonIndexed.isNotEmpty) {
      String nonIndexedCalls = nonIndexed.map((info) => "    ${info.functionName}(),\n").join();
      indexedCalls += "  await Future.wait([\n$nonIndexedCalls  ]);\n";
    }

    return indexedCalls;
  }

  // 각 초기화 함수에 대한 호출 문자열 생성
  String runAppStartBody = generateFunctionCalls(readyRunAppList);
  String materialAppStartBody = generateFunctionCalls(readyMaterialAppList);
  String appStartBody = generateFunctionCalls(readyAppList);

  // 최종 코드 템플릿
  String codeTemplate = '''
$baseImports

$imports

readyForRunAppStart() async {
  if (_readyForRunAppStart) return;
  _readyForRunAppStart = true;

  url_strategy.readyForWebUrlStrategy();
$runAppStartBody}

readyForMaterialAppStart() async {
  if (_readyForMaterialAppStart) return;
  _readyForMaterialAppStart = true;
$materialAppStartBody}

Future<void> readyForAppStart(BuildContext context) async {
  if (_readyForAppStart) return;
  _readyForAppStart = true;
$appStartBody}

bool _readyForRunAppStart = false;
bool _readyForMaterialAppStart = false;
bool _readyForAppStart = false;
''';

  return codeTemplate;
}


Future<void> _overwriteFile(String filePath, String content) async {
  var file = File(filePath);

  try {
    // 파일에 문자열 쓰기 (기존 내용은 덮어쓰기)
    await file.writeAsString(content);
    print('File overwritten successfully with new content.');
  } catch (e) {
    print('An error occurred while writing to the file: $e');
  }
}
