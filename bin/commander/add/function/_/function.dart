import 'dart:io';

import 'package:yaml/yaml.dart';

import '../../../build/function/_/function.dart';
import '../../../build/function/add_package_in_modules/function.dart';
import '../../../build/function/flutter_package_add/function.dart';
import '../../../build/function/flutter_package_remove/function.dart';
import '../../../build/function/flutter_pub_get/function.dart';

addModule(String moduleName) async {
  // await checkAndAddModules(moduleName, devPackage: true);

  // final file = File('pubspec.yaml');
  // final yamlString = await file.readAsString();
  // YamlMap yamlDoc = loadYaml(yamlString);
  // bool isDuplicated = await isPackageDuplicated(yamlDoc, moduleName,
  //     devPackage: true);
  // if (!isDuplicated) {
  //   await addFlutterPackage(moduleName,
  //       devPackage: true);
  // }

  await removeFlutterPackage(moduleName);
  await addFlutterPackage(moduleName,
      devPackage: true);

  await buildApp();
}