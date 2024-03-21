import 'dart:io';
import 'package:yaml/yaml.dart';

import '../../../../entity/model/package_info/model.dart';

Future<List<PackageInfo>> getDirectDependenciesWithVersions(String packagePath) async {
  final pubspecYaml = File('$packagePath/pubspec.yaml');
  final pubspecLock = File('pubspec.lock');

  // `pubspec.yaml`에서 직접 의존성 이름과 주석을 추출
  final pubspecContents = await pubspecYaml.readAsLines();
  final directDependenciesWithComments = {};
  bool inDependenciesSection = false;
  for (var line in pubspecContents) {
    if (line.trim() == 'dependencies:') {
      inDependenciesSection = true;
    } else if (inDependenciesSection && line.trim().isEmpty) {
      inDependenciesSection = false; // End of dependencies section
    } else if (inDependenciesSection && line.contains('#@add')) {
      final dependencyName = line.split(':')[0].trim();
      directDependenciesWithComments[dependencyName] = true;
    }
  }

  // `pubspec.lock`에서 버전 정보 추출
  final pubspecLockContents = await pubspecLock.readAsString();
  final lockfile = loadYaml(pubspecLockContents);
  final packages = lockfile['packages'] as YamlMap;

  final List<PackageInfo> dependenciesWithVersions = [];
  for (var packageName in directDependenciesWithComments.keys) {
    final version = packages.containsKey(packageName) ? (packages[packageName] as YamlMap)['version'] as String : 'Unknown Version';
    dependenciesWithVersions.add(PackageInfo()..Name = packageName..Version = version);
  }

  return dependenciesWithVersions;
}


Future<List<PackageInfo>> getDirectDevDependenciesWithVersions(String packagePath) async {

  final pubspecYaml = File('$packagePath/pubspec.yaml');
  final pubspecLock = File('pubspec.lock');

  // `pubspec.yaml`에서 직접 의존성 이름과 주석을 추출
  final pubspecContents = await pubspecYaml.readAsLines();
  final directDependenciesWithComments = {};
  bool inDependenciesSection = false;
  for (var line in pubspecContents) {
    if (line.trim() == 'dev_dependencies:') {
      inDependenciesSection = true;
    } else if (inDependenciesSection && line.trim().isEmpty) {
      inDependenciesSection = false; // End of dependencies section
    } else if (inDependenciesSection && line.contains('#@add')) {
      final dependencyName = line.split(':')[0].trim();
      directDependenciesWithComments[dependencyName] = true;
    }
  }

  // `pubspec.lock`에서 버전 정보 추출
  final pubspecLockContents = await pubspecLock.readAsString();
  final lockfile = loadYaml(pubspecLockContents);
  final packages = lockfile['packages'] as YamlMap;

  final List<PackageInfo> dependenciesWithVersions = [];
  for (var packageName in directDependenciesWithComments.keys) {
    final version = packages.containsKey(packageName) ? (packages[packageName] as YamlMap)['version'] as String : 'Unknown Version';
    dependenciesWithVersions.add(PackageInfo()..Name = packageName..Version = version);
  }

  return dependenciesWithVersions;
}
