import 'dart:io';
import 'package:path/path.dart' as path;

Future<void> changeProjectName(String targetDirectory, String newName) async {
  final String pubspecPath = path.join('${Directory.current.path}/$targetDirectory', 'pubspec.yaml');
  final File pubspecFile = File(pubspecPath);

  if (await pubspecFile.exists()) {
    final lines = await pubspecFile.readAsLines();
    final updatedLines = lines.map((line) {
      if (line.startsWith('name:')) {
        return 'name: $newName';
      }
      return line;
    }).toList();

    await pubspecFile.writeAsString(updatedLines.join('\n'));
    print('Project name updated to $newName in pubspec.yaml');
  } else {
    print('pubspec.yaml not found in the provided project path.');
  }
}
