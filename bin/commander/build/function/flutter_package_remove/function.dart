import 'dart:io';

import 'package:yaml/yaml.dart';

// 패키지를 입력받아 flutter pub remove 명령을 실행하는 함수
import 'dart:io';
import 'package:yaml/yaml.dart';

// 패키지를 입력받아 flutter pub remove 명령을 실행하는 함수
Future<void> removeFlutterPackage(String packageName) async {
  final pubspecFile = File('${Directory.current.path}/pubspec.yaml');
  final pubspecContent = await pubspecFile.readAsString();
  final pubspecYaml = loadYaml(pubspecContent);

  bool hasDependency = _checkDependencies(pubspecYaml['dependencies'], packageName);
  bool hasDevDependency = _checkDevDependencies(pubspecYaml['dev_dependencies'], packageName);

  if (hasDependency || hasDevDependency) {
    String flutterCommand = Platform.isWindows ? 'flutter.bat' : 'flutter';

    final result = await Process.run(flutterCommand, ['pub', 'remove', packageName],
        workingDirectory: Directory.current.path);

    if (result.stderr.toString().isNotEmpty) {
      // print('Error removing package: ${result.stderr}');
    } else {
      // print("Removed $packageName successfully");
    }
  } else {
    // print("Package '$packageName' not found in pubspec.yaml");
  }
}

// dependencies 내의 모든 항목을 확인하여 패키지 존재 여부를 반환하는 함수
bool _checkDependencies(YamlMap? dependencies, String packageName) {
  if (dependencies == null) return false;
  for (var key in dependencies.keys) {
    if (key == packageName) {
      return true;
    }
    var value = dependencies[key];
    // Map 내의 더 깊은 항목을 검사해야 하는 경우
    if (value is YamlMap && _checkDependencies(value, packageName)) {
      return true;
    }
  }
  return false;
}

// dev_dependencies 내의 모든 항목을 확인하여 패키지 존재 여부를 반환하는 함수
bool _checkDevDependencies(YamlMap? devDependencies, String packageName) {
  if (devDependencies == null) return false;
  for (var key in devDependencies.keys) {
    if (key == packageName) {
      return true;
    }
    var value = devDependencies[key];
    // Map 내의 더 깊은 항목을 검사해야 하는 경우
    if (value is YamlMap && _checkDevDependencies(value, packageName)) {
      return true;
    }
  }
  return false;
}
