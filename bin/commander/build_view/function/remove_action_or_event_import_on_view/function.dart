import 'dart:io';
import 'package:path/path.dart' as p;

Future<void> removeActionOrEventImportOnView(String path) async {
  // path에서 두 번 상위 폴더의 경로를 가져옵니다.
  String upperDirectoryPath = p.dirname(p.dirname(path));

  // 두 번 상위 폴더 내의 view.dart 파일의 경로를 구성합니다.
  String viewPath = p.join(upperDirectoryPath, 'view.dart');

  // view.dart 파일에서 각 줄을 읽어들입니다.
  List<String> lines = await File(viewPath).readAsLines();

  // 파일의 마지막 줄이 비어 있는지 확인합니다.
  bool endsWithEmptyLine = lines.isNotEmpty && lines.last.isEmpty;

  // 오직 'import ' 또는 'export '로 시작하는 줄만 필터링합니다.
  // 그리고 'action/' 또는 'event/'로 시작하는 경우에만 제외합니다.
  List<String> filteredLines = lines.map((line) {
    if (line.startsWith("import ") || line.startsWith("export ")) {
      if (line.contains(" 'action/") || line.contains(" 'event/")) {
        return null; // 이 조건에 해당하는 줄은 제거합니다.
      }
    }
    return line; // 나머지 줄들은 변경하지 않고 유지합니다.
  }).whereType<String>().toList(); // null이 아닌 줄들만 다시 리스트로 만듭니다.

  // 필터링된 내용으로 view.dart 파일을 다시 씁니다.
  // 파일의 마지막 줄이 비어 있었다면, 저장할 때 그 상태를 유지합니다.
  String contentToWrite = filteredLines.join('\n');
  if (endsWithEmptyLine) {
    contentToWrite += '\n'; // 마지막 줄이 비어 있었다면, 추가적인 줄바꿈을 추가합니다.
  }

  await File(viewPath).writeAsString(contentToWrite);
}
