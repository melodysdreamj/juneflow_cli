import 'dart:io';

Future<void> addExportIfNotExists(String exportPath) async {

  String currentPath = Directory.current.path;
  String filePath = '$currentPath/lib/util/config/_/global_imports.dart';
  // print('filePath: $filePath');
  final file = File(filePath);
  if (!await file.exists()) {
    print('File does not exist: $filePath');
    return;
  }

  String content = await file.readAsString();
  // print('exportPath: $exportPath');
  if (content.contains(exportPath)) {
  } else {
    // Export 구문 추가
    final fileSink = file.openWrite(mode: FileMode.append);
    fileSink.write("\n$exportPath\n");
    await fileSink.flush();
    await fileSink.close();
    // print('Export added: $exportPath');
  }
}
