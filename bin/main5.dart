import 'main4.dart';

String generateInitializationCode(
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
