import 'dart:io';
import 'package:yaml/yaml.dart';

Future<void> addAssetPaths(List<String> newPaths) async {
  const String filePath = 'pubspec.yaml';
  File file = File(filePath);

  if (await file.exists()) {
    final contents = await file.readAsString();

    // Yaml 파일 로드
    var doc = loadYaml(contents);
    if (doc is YamlMap && doc.containsKey('flutter')) {
      var flutter = doc['flutter'];
      if (flutter is YamlMap) {
        List<dynamic> assets = [];
        if (flutter.containsKey('assets')) {
          assets = List.from(flutter['assets']);
        }

        // 새 경로를 추가합니다.
        for (String newPath in newPaths) {
          if (!assets.contains(newPath)) {
            assets.add(newPath);
          }
        }

        // assets 리스트를 업데이트합니다.
        (flutter as Map)['assets'] = assets;

        // Yaml 파일을 문자열로 다시 변환합니다.
        String updatedContents = contents;
        // 이 부분에서 Yaml 내용을 다시 문자열로 변환하는 방법을 구현해야 합니다.
        // Yaml 패키지는 직접적으로 Map을 Yaml로 변환하는 기능을 제공하지 않습니다.
        // 따라서, 여기에 적절한 변환 로직을 추가하거나, 다른 방법을 찾아야 합니다.

        // 파일에 변경사항을 적용합니다.
        await file.writeAsString(updatedContents);
        print('Asset paths processing completed.');
      }
    } else {
      print('Flutter section not found in pubspec.yaml');
    }
  } else {
    print('pubspec.yaml file not found.');
  }
}
