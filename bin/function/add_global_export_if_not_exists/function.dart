import 'dart:io';

Future<void> addExportIfNotExists(String filePath, String exportPath) async {

  String currentPath = Directory.current.path;
  filePath = '$currentPath/$filePath';
  print('filePath: $filePath');
  final file = File(filePath);
  if (!await file.exists()) {
    print('File does not exist: $filePath');
    return;
  }

  String content = await file.readAsString();
  if (content.contains("export '$exportPath';")) {
    print('Export already exists: $exportPath');
  } else {
    // Export 구문 추가
    final fileSink = file.openWrite(mode: FileMode.append);
    fileSink.write("\nexport '$exportPath';\n");
    await fileSink.flush();
    await fileSink.close();
    print('Export added: $exportPath');
  }
}
