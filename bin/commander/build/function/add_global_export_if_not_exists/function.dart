import 'dart:io';
import 'package:path/path.dart' as path;

Future<void> addExportIfNotExists(String exportPath) async {
  String currentPath = Directory.current.path;
  String filePath = path.join(currentPath, 'lib', 'util', 'config', '_', 'global_imports.dart');
  final file = File(filePath);
  if (!await file.exists()) {
    print('File does not exist: $filePath');
    return;
  }

  String content = await file.readAsString();
  if (!content.contains(exportPath)) {
    final fileSink = file.openWrite(mode: FileMode.append);
    fileSink.write("\n$exportPath\n");
    await fileSink.flush();
    await fileSink.close();
  }
}

