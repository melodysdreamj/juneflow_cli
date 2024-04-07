import 'dart:io';
import 'package:path/path.dart' as p;

Future<void> renameNewFolders(String directoryPath, String newName) async {
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
      if (dirName == '_new') {
        directoriesToRename.add(entity);
      }
    }
  }

  // 수집한 폴더 목록의 이름을 변경합니다.
  for (final Directory dir in directoriesToRename) {
    final String newPath = dir.path.replaceFirst(RegExp(r'_new$'), newName);
    await dir.rename(newPath);
    // print('Renamed ${dir.path} to $newPath');
  }
}