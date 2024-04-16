import 'dart:io';
import 'package:path/path.dart' as p;

import '../../../../entity/model/module/model.dart';


import 'dart:io';
import 'package:path/path.dart' as p;

Future<Module> checkAssetsHandler(String packageAbsolutePath, Module moduleObj, String moduleAssetsAbsolutePaths) async {
  String currentPath = Directory.current.path;
  String relativePath = p.relative(moduleAssetsAbsolutePaths, from: packageAbsolutePath);
  String targetPath = p.join(currentPath, relativePath);

  if (await _isExistAssetInDirectory(moduleAssetsAbsolutePaths)) {
    List<String> directories = await _findAllDirectoriesRelative(packageAbsolutePath, moduleAssetsAbsolutePaths);
    for (String directory in directories) {
      String _ = p.posix.relative(directory, from: packageAbsolutePath);
      moduleObj.AddLineToPubspecAssetsBlock.add('$_/');
    }

    await for (var entity in Directory(moduleAssetsAbsolutePaths).list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final String newPath = p.posix.join(targetPath, p.posix.relative(entity.path, from: moduleAssetsAbsolutePaths));
        if(newPath.endsWith('add.june')) {
          continue;
        }
        final File newFile = File(newPath);

        if (!await newFile.parent.exists()) {
          await newFile.parent.create(recursive: true);
        }

        await entity.copy(newPath);
      }
    }
  }

  return moduleObj;
}

Future<bool> _isExistAssetInDirectory(String directoryPath) async {
  final directory = Directory(directoryPath);
  if (!await directory.exists()) {
    return false;
  }

  await for (final entity in directory.list()) {
    if (entity is File && !entity.path.endsWith('add.june')) {
      return true;
    }
    if (entity is Directory) {
      return true;
    }
  }

  return false;
}


Future<List<String>> _findAllDirectoriesRelative(String packageAbsolutePath, String assetFolderPath) async {
  Directory assetsDir = Directory(assetFolderPath);
  List<String> directories = [assetFolderPath];

  // if (!(await baseDir.exists())) {
  //   print('The specified base path does not exist.');
  //   return directories;
  // }

  await for (var entity in assetsDir.list(recursive: true, followLinks: false)) {
    if (entity is Directory) {
      // 절대 경로로부터 basePath 까지의 상대 경로를 계산
      String relativePath = p.relative(entity.path, from: packageAbsolutePath);
      directories.add(relativePath);
    }
  }

  return directories;
}
