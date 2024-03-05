List<String> findAnnotatedFunctions() {
  // 예시 함수 목록, 실제 구현에서는 파일에서 이 정보를 추출
  return [
    'readyForWidgetsBinding',
    'readyForFlutterNativeSplashPreserve',
    'readyForFlutterNativeSplashRemove',
  ];
}

String generateDartCode(List<String> functionNames) {
  // 기본적으로 포함될 import 문과 변수 선언
  String code = '''
import 'package:flutter/material.dart';
import '../start_app.dart';
import 'flutter_native_splash/_.dart';
import 'web_url_strategy/none.dart'
    if (dart.library.html) 'web_url_strategy/_.dart' as url_strategy;
import 'widgets_binding/_.dart';

bool _readyForRunAppStart = false;
bool _readyForMaterialAppStart = false;
bool _readyForAppStart = false;
''';

  // runApp 시작 함수
  code += '''
  
readyForRunAppStart() async {
  if (_readyForRunAppStart) return;
  _readyForRunAppStart = true;

  url_strategy.readyForWebUrlStrategy();
''';

  // 어노테이션이 포함된 함수들을 호출
  for (String functionName in functionNames) {
    code += '  await $functionName();\n';
  }

  code += '}\n';

  // 기타 필요한 함수들
  code += '''
  
readyForMaterialAppStart() async {
  if (_readyForMaterialAppStart) return;
  _readyForMaterialAppStart = true;
}

Future<void> readyForAppStart(BuildContext context) async {
  if (_readyForAppStart) return;
  _readyForAppStart = true;
}
''';

  return code;
}

void main() {
  List<String> functionNames = findAnnotatedFunctions();
  String generatedCode = generateDartCode(functionNames);
  print(generatedCode);
}
