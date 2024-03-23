import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import '../../../../entity/model/package_info/model.dart';
import '../flutter_package_add/function.dart';
import '../get_direct_dependencies_with_versions/function.dart';
import '../get_package_path/function.dart';

Future<void> addAllDevModules() async {
  // 현재꺼는 모든 dev를 가져옵니다.
  List<dynamic> devPackages = await _getAllDevPackages(Directory.current.path);
  print('DevPackage: $devPackages');
}

Future<List<dynamic>> _getAllDevPackages(String projectPath) async {
  final pubspecYaml = File('$projectPath/pubspec.yaml');
  final pubspecContent = await pubspecYaml.readAsString();

  final pubspecYamlMap = loadYaml(pubspecContent);
  final devDependencies = pubspecYamlMap['dev_dependencies'] as Map;

  return devDependencies.keys.toList();
}
