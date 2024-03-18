import 'dart:io';
import 'package:path/path.dart' as p;

Future<void> renameNewFolders(String directoryPath, String newName) async {
  final Directory directory = Directory(directoryPath);

  if (!await directory.exists()) {
    print('The specified directory does not exist.');
    return;
  }

  await for (final FileSystemEntity entity in directory.list(recursive: true)) {
    if (entity is Directory) {
      final String dirName = p.basename(entity.path);
      if (dirName == '_new') {
        final String newPath = entity.path.replaceFirst(RegExp(r'_new$'), newName);
        await entity.rename(newPath);
        // print('Renamed ${entity.path} to $newPath');
      }
    }
  }
}
