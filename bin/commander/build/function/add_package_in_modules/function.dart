import 'dart:io';

import 'package:yaml/yaml.dart';

import '../../../../entity/model/package_info/model.dart';
import '../flutter_package_add/function.dart';

Future<void> addPackageInModules(List<PackageInfo> packages) async {
  for(PackageInfo package in packages) {
    // print('Add package: ${package.Name} in modules');
    await addFlutterPackage(package.Name, version: package.Version);
  }
}

Future<void> addDevPackageInModules(List<PackageInfo> devPackages) async {
  for(PackageInfo package in devPackages) {
    // print('Add package: ${package.Name} in modules');
    await addFlutterPackage(package.Name, version: package.Version,devPackage: true);
  }
}

Future<void> checkAndAddModules(List<PackageInfo> packages,
    {bool devPackages = false}) async {
  var yamlDoc = loadYaml(await File('pubspec.yaml').readAsString());

  Map<dynamic, dynamic> dependencies = devPackages
      ? yamlDoc['dev_dependencies'] ?? {}
      : yamlDoc['dependencies'] ?? {};

  for (final package in packages) {
    if (!dependencies.containsKey(package.Name)) {
      await addFlutterPackage(package.Name,
          version: package.Version, devPackage: devPackages);
    } else {
      // print('${package.Name} is already listed in ${devPackages ? "dev_dependencies" : "dependencies"}');
    }
  }
}
