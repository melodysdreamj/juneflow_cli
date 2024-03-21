import 'dart:convert';
import 'dart:io';
import 'package:yaml/yaml.dart';

Future<void> addAssetPaths(List<String> newPaths) async {
  const String filePath = 'pubspec.yaml';
  File file = File(filePath);

  if (await file.exists()) {
    String contents = await file.readAsString();

    var doc = loadYaml(contents);
    if (doc is YamlMap) {
      // YamlMap을 수정 가능한 Map으로 변환합니다.
      Map<String, dynamic> yamlMap = Map<String, dynamic>.from(doc);

      if (yamlMap.containsKey('flutter')) {
        Map<String, dynamic> flutterSection = Map<String, dynamic>.from(yamlMap['flutter']);
        List<dynamic> assets = flutterSection['assets'] != null ? List<dynamic>.from(flutterSection['assets']) : [];

        // 새 경로를 assets에 추가합니다.
        newPaths.forEach((newPath) {
          if (!assets.contains(newPath)) {
            assets.add(newPath);
          }
        });

        flutterSection['assets'] = assets; // 변경된 assets를 flutter 섹션에 다시 할당합니다.
        yamlMap['flutter'] = flutterSection; // 변경된 flutter 섹션을 yamlMap에 다시 할당합니다.

        // yamlMap을 문자열로 변환합니다. 이 예제에서는 jsonEncode를 사용하나, 실제로는 Yaml 형식으로 변환해야 합니다.
        // JSON을 사용하는 것은 단지 예시이며, 실제 YAML 형식에 맞게 변환 로직을 구현해야 합니다.
        String updatedContents = jsonEncode(yamlMap); // 적절한 YAML 변환 필요

        await file.writeAsString(updatedContents);
        print('Asset paths processing completed.');
      } else {
        print('Flutter section not found in pubspec.yaml');
      }
    }
  } else {
    print('pubspec.yaml file not found.');
  }
}
