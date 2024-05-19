import 'dart:io';
import 'package:path/path.dart' as p;

Future<void> renameNewFolders(String directoryPath, String newName, {List<String>? checkDirName}) async {
  final Directory directory = Directory(directoryPath);

  if (!await directory.exists()) {
    print('The specified directory does not exist.');
    return;
  }

  // 폴더 이름을 변경할 대상 폴더 목록을 먼저 수집합니다.
  final List<Directory> directoriesToRename = [];

  await for (final FileSystemEntity entity in directory.list(recursive: true)) {
    if (entity is Directory) {
      final String dirName = p.basename(entity.path);
      // _new는 항상 체크하고, checkDirName 목록에 있는 이름과 일치하는지 확인합니다.
      if (dirName == '_new' || (checkDirName != null && checkDirName.contains(dirName))) {
        directoriesToRename.add(entity);
      }
    }
  }

  // 수집한 폴더 목록의 이름을 변경합니다.
  for (final Directory dir in directoriesToRename) {
    String newPath = dir.path.replaceFirst(RegExp(r'_new$'), newName);
    if (checkDirName != null) {
      for (final String name in checkDirName) {
        newPath = newPath.replaceFirst(RegExp(name + r'$'), newName);
      }
    }
    await dir.rename(newPath);
    // print('Renamed ${dir.path} to $newPath');
  }
}
