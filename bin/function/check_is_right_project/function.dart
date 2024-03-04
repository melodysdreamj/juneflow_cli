import 'dart:io';

Future<bool> checkIsRightProject() async {
  String currentPath = Directory.current.path;
  List<String> filePaths = [
    '$currentPath/lib/util/start_app.dart',
    '$currentPath/lib/util/global_imports.dart',
    '$currentPath/lib/util/ready/ready.dart',
  ];

  for (String path in filePaths) {
    File file = File(path);
    bool exists = await file.exists();
    // 하나라도 존재하지 않으면 false 반환
    if (!exists) return false;
  }

  // 모든 파일이 존재하면 true 반환
  return true;
}
