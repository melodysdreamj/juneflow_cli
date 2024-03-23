import 'dart:io';

import 'package:path/path.dart';

import '../../../../entity/model/package_info/model.dart';
import '../flutter_package_add/function.dart';
import '../get_direct_dependencies_with_versions/function.dart';

Future<void> addAllDevModules() async {
  List<PackageInfo> DevPackage =
  await getDirectDevDependenciesWithVersions(Directory.current.path);

  print('DevPackage: $DevPackage');

  for(PackageInfo package in DevPackage) {
    await addFlutterPackage(package.Name, devPackage: true);
  }
}