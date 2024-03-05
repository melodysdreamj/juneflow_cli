import 'dart:io';

import 'main5.dart';

class AnnotationInfo {
  String path;
  String functionName;
  double? index; // 이제 index는 double 타입입니다.

  AnnotationInfo({required this.path, required this.functionName, this.index});
}


void findAnnotations(String basePath) {
  final List<AnnotationInfo> readyRunAppList = [];
  final List<AnnotationInfo> readyAppList = [];
  final List<AnnotationInfo> readyMaterialAppList = [];

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

  var _ = generateInitializationCode(
      readyRunAppList, readyAppList, readyMaterialAppList);
  print(_);
}

void main() {
  // 함수 사용 예
  findAnnotations('/Users/june/Documents/GitHub/JuneFlutter/lib/util/ready');
}
