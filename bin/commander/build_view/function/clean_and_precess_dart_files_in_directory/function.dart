import 'dart:io';
import 'package:path/path.dart' as path;

Future<void> main() async {
  const projectPath = 'your_project_path_here';
  await cleanAndProcessDartFilesInDirectory(projectPath);
}

Future<void> cleanAndProcessDartFilesInDirectory(String directoryPath) async {
  final directory = Directory(directoryPath);
  final List<FileSystemEntity> entities = await directory.list(recursive: true).toList();

  for (final entity in entities) {
    if (entity is File && entity.path.endsWith('.dart')) {
      await cleanImportsAndGeneratedCodeInFile(entity.path);
    }
  }
}

Future<void> cleanImportsAndGeneratedCodeInFile(String filePath) async {
  String fileContent = await File(filePath).readAsString();
  List<String> lines = fileContent.split('\n');

  // 필요한 import 외 삭제
  final requiredImports = [
    "import 'package:flutter/cupertino.dart';",
    "import 'package:flutter/material.dart';",
    "import '../../../../../../../../main.dart';",
    "import '../view.dart';",
  ];
  lines = lines.where((line) {
    return line.startsWith('@JuneViewChild()') ||
        line.startsWith('@JuneViewMother()') ||
        requiredImports.contains(line.trim()) ||
        !line.startsWith('import ');
  }).toList();

  // 자동 생성된 코드 블록 처리
  removeContentBetweenGeneratedCodeMarkers(lines, 'action');
  removeContentBetweenGeneratedCodeMarkers(lines, 'event');

  // 파일에 변경사항 저장
  await File(filePath).writeAsString(lines.join('\n'));
}

void removeContentBetweenGeneratedCodeMarkers(List<String> lines, String type) {
  const startMarker = '/// automatically generated {type} code - don\'t change this code';
  const endMarker = '/// end of automatically {type} generated code';
  int startIndex = -1;
  int endIndex = -1;

  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains(startMarker)) {
      startIndex = i;
    }
    if (lines[i].contains(endMarker)) {
      endIndex = i;
      break; // 끝 인덱스를 찾으면 반복 종료
    }
  }

  if (startIndex != -1 && endIndex != -1) {
    lines.removeRange(startIndex + 1, endIndex);
    lines.insert(startIndex + 1, ''); // 빈 줄 추가
  }
}
