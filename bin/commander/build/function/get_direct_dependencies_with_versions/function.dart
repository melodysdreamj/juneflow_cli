import 'dart:io';
import 'package:yaml/yaml.dart';

import '../../../../entity/model/package_info/model.dart';

Future<List<PackageInfo>> getDirectDependenciesWithVersions() async {
  print('Getting direct dependencies with versions...');
  final pubspecYaml = File('pubspec.yaml');
  final pubspecLock = File('pubspec.lock');

  // `pubspec.yaml`에서 직접 의존성 이름 추출
  final pubspecContents = await pubspecYaml.readAsString();
  final pubspec = loadYaml(pubspecContents);
  final directDependencies = pubspec['dependencies'] as YamlMap;

  // `pubspec.lock`에서 버전 정보 추출
  final pubspecLockContents = await pubspecLock.readAsString();
  final lockfile = loadYaml(pubspecLockContents);
  final packages = lockfile['packages'] as YamlMap;

  final List<PackageInfo> dependenciesWithVersions = [];
  for (var packageName in directDependencies.keys) {
    if (!directDependencies[packageName] is YamlMap) { // 단순 문자열 또는 버전 정보가 없는 경우
      final version = packages.containsKey(packageName) ? (packages[packageName] as YamlMap)['version'] as String : 'Unknown Version';
      dependenciesWithVersions.add(PackageInfo()..Name = packageName..Version = version);
    }
  }

  return dependenciesWithVersions;
}
