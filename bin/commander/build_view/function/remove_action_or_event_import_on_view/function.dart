import 'dart:io';

List<String> removeActionOrEventImportOnView(String fileContents) {
  // 파일에서 각 줄을 읽어들입니다.
  List<String> lines = fileContents.split('\n');

  // 'action/' 또는 'event/'로 시작하는 import와 export 구문을 제외하고 필터링합니다.
  List<String> filteredLines = lines.where((line) =>
  !(line.startsWith("import 'action/") ||
      line.startsWith("import 'event/") ||
      line.startsWith("export 'action/") ||
      line.startsWith("export 'event/"))
  ).toList();

  return filteredLines;
}