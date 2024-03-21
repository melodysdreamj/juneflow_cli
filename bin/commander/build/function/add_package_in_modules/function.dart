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