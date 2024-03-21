import 'dart:io';
import 'package:yaml/yaml.dart';

import '../../../../entity/model/package_info/model.dart';

Future<List<PackageInfo>> getDirectDependenciesWithVersions(String packagePath) async {
  print('Getting direct dependencies with versions...');
  final pubspecYaml = File('$packagePath/pubspec.yaml');
  final pubspecLock = File('$packagePath/pubspec.module');

  // `pubspec.yaml`에서 직접 의존성 이름 추출
  final pubspecContents = await pubspecYaml.readAsString();
  print('pubspecContents: $pubspecContents');
  final pubspec = loadYaml(pubspecContents);
  print("pubspec['dependencies']: ${pubspec['dependencies']}");
  final directDependencies = pubspec['dependencies'] as YamlMap;

  // `pubspec.module`에서 버전 정보 추출
  final pubspecLockContents = await pubspecLock.readAsString();
  final lockfile = loadYaml(pubspecLockContents);
  final packages = lockfile['packages'] as YamlMap;

  final List<PackageInfo> dependenciesWithVersions = [];
  for (var packageName in directDependencies.keys) {
    print('packageName: $packageName');
    if (directDependencies[packageName] is! YamlMap) {
      final version = packages.containsKey(packageName) ? (packages[packageName] as YamlMap)['version'] as String : 'Unknown Version';
      dependenciesWithVersions.add(PackageInfo()..Name = packageName..Version = version);
    }
  }

  return dependenciesWithVersions;
}
