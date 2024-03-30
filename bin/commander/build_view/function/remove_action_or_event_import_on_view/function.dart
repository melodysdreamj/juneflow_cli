import 'dart:io';
import 'package:path/path.dart' as p;


Future<void> removeActionOrEventImportOnView(String path) async {
  // path에서 두 번 상위 폴더의 경로를 가져옵니다.
  String upperDirectoryPath = p.dirname(p.dirname(path));

  // 두 번 상위 폴더 내의 view.dart 파일의 경로를 구성합니다.
  String viewPath = p.join(upperDirectoryPath, 'view.dart');

  // view.dart 파일에서 각 줄을 읽어들입니다.
  List<String> lines = await File(viewPath).readAsLines();

  // 'action/' 또는 'event/'로 시작하는 import와 export 구문을 제외하고 필터링합니다.
  List<String> filteredLines = lines
      .where((line) => !(line.startsWith("import 'action/") ||
      line.startsWith("import 'event/") ||
      line.startsWith("export 'action/") ||
      line.startsWith("export 'event/")))
      .toList();

  // 필터링된 내용으로 view.dart 파일을 다시 씁니다.
  await File(viewPath).writeAsString(filteredLines.join('\n'));
}

void main() {
  // 함수 사용 예시
  removeActionOrEventImportOnView('path/to/your/dart/file.dart');
}
