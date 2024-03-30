import 'dart:io';

Future<void> removeActionOrEventImportOnView(String path) async {
  // 파일에서 각 줄을 읽어들입니다.
  List<String> lines = await File(path).readAsLines();

  // 'action/' 또는 'event/'로 시작하는 import와 export 구문을 제외하고 필터링합니다.
  List<String> filteredLines = lines
      .where((line) => !(line.startsWith("import 'action/") ||
          line.startsWith("import 'event/") ||
          line.startsWith("export 'action/") ||
          line.startsWith("export 'event/")))
      .toList();

  // 필터링된 내용으로 파일을 다시 씁니다.
  await File(path).writeAsString(filteredLines.join('\n'));
}

void main() {
  // 함수 사용 예시
  removeActionOrEventImportOnView('path/to/your/dart/file.dart');
}
