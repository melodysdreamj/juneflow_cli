import '../../../build/function/_/function.dart';
import '../../../build/function/add_package_in_modules/function.dart';
import '../../../build/function/flutter_package_add/function.dart';
import '../../../build/function/flutter_pub_get/function.dart';

addModule(String moduleName) async {
  await addFlutterPackage(moduleName, devPackage: true);

  await runFlutterPubGet();

  await buildApp();
}