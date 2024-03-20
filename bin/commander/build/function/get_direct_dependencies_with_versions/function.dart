import 'dart:io';
import 'package:yaml/yaml.dart';

import '../../../../entity/model/package_info/model.dart';

Future<List<PackageInfo>> getDirectDependenciesWithVersions() async {
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
    if (packages.containsKey(packageName)) {
      final packageInfo = packages[packageName] as YamlMap;
      final version = packageInfo['version'] as String;
      dependenciesWithVersions.add(PackageInfo()..Name = packageName..Version = version);
    }
  }

  return dependenciesWithVersions;
}


