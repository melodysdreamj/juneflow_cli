import 'dart:convert';
import 'dart:io';

Future<void> addAssetPaths(List<String> newPaths) async {
  const String filePath = 'pubspec.yaml';
  File file = File(filePath);

  if (await file.exists()) {
    final contents = await file.readAsString();
    List<String> lines = const LineSplitter().convert(contents);

    int flutterSectionIndex = lines.indexWhere((line) => line.trim() == 'flutter:');
    if (flutterSectionIndex != -1) {
      // 'flutter:' 섹션 뒤의 내용을 처리합니다.
      int assetsIndex = -1;
      // 'flutter:' 섹션 바로 다음부터 시작하여 'assets:' 섹션을 찾습니다.
      for (int i = flutterSectionIndex + 1; i < lines.length; i++) {
        if (lines[i].contains('assets:')) {
          assetsIndex = i;
          break;
        }
        if (!lines[i].startsWith('  ')) {
          // 다음 메인 섹션을 만나면 중지합니다.
          break;
        }
      }

      if (assetsIndex == -1) {
        // 'assets:' 섹션이 없으면, 'flutter:' 섹션 바로 아래에 추가합니다.
        assetsIndex = flutterSectionIndex + 1;
        lines.insert(assetsIndex, '  assets:');
      }

      // 'assets:' 섹션에 새 경로를 추가합니다.
      for (String newPath in newPaths) {
        bool pathExists = false;
        for (int i = assetsIndex + 1; i < lines.length && lines[i].startsWith('    -'); i++) {
          if (lines[i].trim() == '- $newPath') {
            pathExists = true;
            break;
          }
        }
        if (!pathExists) {
          lines.insert(assetsIndex + 1, '    - $newPath');
          print('Added asset path: $newPath');
        } else {
          print('Asset path already exists and was not added: $newPath');
        }
      }

      // 수정된 내용을 파일에 다시 씁니다.
      await file.writeAsString(lines.join('\n'));
      print('Asset paths processing completed.');
    } else {
      print('Flutter section not found in pubspec.yaml');
    }
  } else {
    print('pubspec.yaml file not found.');
  }
}
