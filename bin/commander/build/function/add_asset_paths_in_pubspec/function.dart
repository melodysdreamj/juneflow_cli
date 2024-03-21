import 'dart:convert';
import 'dart:io';

Future<void> addAssetPaths(List<String> newPaths) async {
  const String filePath = 'pubspec.yaml';
  File file = File(filePath);

  if (await file.exists()) {
    final contents = await file.readAsString();
    List<String> lines = const LineSplitter().convert(contents);

    // 대주제 'flutter:' 섹션의 인덱스를 찾습니다.
    int flutterSectionIndex = lines.indexWhere((line) => line.trim() == 'flutter:');
    if (flutterSectionIndex != -1) {
      // 'flutter:' 섹션 다음에 나타나는 첫 번째 'assets:' 섹션의 인덱스를 찾습니다.
      int assetsIndex = lines.indexWhere((line) => line.trim() == 'assets:', flutterSectionIndex);
      if (assetsIndex == -1) {
        // 'assets:' 섹션이 없으면, 'flutter:' 섹션 아래에 새로 추가합니다.
        lines.insert(flutterSectionIndex + 1, '  assets:');
        assetsIndex = flutterSectionIndex + 1;
      }

      // 새 경로를 'assets:' 섹션에 추가합니다.
      int insertIndex = assetsIndex + 1; // 새 경로를 추가할 위치
      for (String newPath in newPaths) {
        bool pathExists = lines.skip(assetsIndex + 1).takeWhile((line) => line.startsWith('    -')).any((line) => line.trim() == '- $newPath');

        if (!pathExists) {
          lines.insert(insertIndex++, '    - $newPath');
          print('Added asset path: $newPath');
        } else {
          print('Asset path already exists and was not added: $newPath');
        }
      }

      // 파일에 변경사항을 적용합니다.
      await file.writeAsString(lines.join('\n'));
      print('Asset paths processing completed.');
    } else {
      print('Main "flutter:" section not found in pubspec.yaml');
    }
  } else {
    print('pubspec.yaml file not found.');
  }
}
