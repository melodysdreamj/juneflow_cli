import 'dart:convert';
import 'dart:io';

Future<void> addAssetPaths(List<String> newPaths) async {
  const String filePath = 'pubspec.yaml';
  File file = File(filePath);

  if (await file.exists()) {
    final contents = await file.readAsString();
    List<String> lines = const LineSplitter().convert(contents);

    // `flutter:` 섹션의 인덱스를 찾습니다.
    int flutterSectionIndex = lines.indexWhere((line) => line.trim() == 'flutter:');
    if (flutterSectionIndex != -1) {
      // `flutter:` 섹션 다음으로 오는 내용 중, `assets:` 섹션을 찾거나 새로 만듭니다.
      int assetsIndex = -1;
      bool inFlutterSection = false;
      for (int i = flutterSectionIndex + 1; i < lines.length; i++) {
        // 다른 주석이나 섹션이 시작되면 'flutter:' 섹션을 벗어난 것으로 간주합니다.
        if (lines[i].startsWith(' ') && !lines[i].startsWith('    ')) {
          inFlutterSection = true;
        } else if (!lines[i].startsWith(' ')) {
          if (inFlutterSection) {
            break; // 'flutter:' 섹션을 벗어난 경우
          }
        }

        if (inFlutterSection && lines[i].trim().startsWith('assets:')) {
          assetsIndex = i;
          break;
        }
      }

      if (assetsIndex == -1) {
        // 'assets:' 섹션이 'flutter:' 섹션 내에 없는 경우, 새로 추가합니다.
        lines.insert(flutterSectionIndex + 1, '  assets:');
        lines.insert(flutterSectionIndex + 2, ''); // 'assets:' 아래에 빈 줄 추가
        assetsIndex = flutterSectionIndex + 1;
      }

      // 새 경로를 'assets:' 섹션에 추가합니다.
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

      // 파일에 변경사항을 적용합니다.
      await file.writeAsString(lines.join('\n'));
      print('Asset paths processing completed.');
    } else {
      print('Flutter section not found in pubspec.yaml');
    }
  } else {
    print('pubspec.yaml file not found.');
  }
}
