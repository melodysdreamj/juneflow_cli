import 'dart:io';

import 'dart:io';
import 'package:yaml/yaml.dart';

import '../flutter_pub_get/function.dart';

Future<bool> addFlutterPackage(String packageName, {String? version, bool? devPackage = false}) async {
  final File pubspecFile = File('${Directory.current.path}/pubspec.yaml');
  final String pubspecContent = await pubspecFile.readAsString();
  final dynamic pubspec = loadYaml(pubspecContent);

  final Map<dynamic, dynamic>? dependencies = pubspec['dependencies'];
  final Map<dynamic, dynamic>? devDependencies = pubspec['dev_dependencies'];
  bool packageExists = (dependencies != null && dependencies.containsKey(packageName)) ||
      (devDependencies != null && devDependencies.containsKey(packageName));

  if (packageExists) {
    return true;
  }

  final isValidVersion = version != null && RegExp(r'^\d+(\.\d+)*$').hasMatch(version);
  final packageArgument = isValidVersion ? '$packageName:^$version' : packageName;

  final List<String> command = ['pub', 'add', packageArgument];
  if (devPackage == true) {
    command.add('--dev');
  }

  String flutterCommand = Platform.isWindows ? 'flutter.bat' : 'flutter';

  final result = await Process.run(flutterCommand, command, workingDirectory: Directory.current.path);

  await Future.delayed(Duration(seconds: 1));

  if (result.stderr.toString().isNotEmpty) {
    print('error: ${result.stderr}');
    return false;
  } else {
    final String devStr = (devPackage == true) ? 'dev_dependencies' : 'dependencies';
    print("Installed $packageName in $devStr.");
  }

  return false;
}