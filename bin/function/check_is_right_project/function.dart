import 'dart:io';

Future<bool> checkIsRightProject() async {
  List<String> filePaths = [
    'lib/util/start_app.dart',
    'lib/util/global_imports.dart',
    'lib/util/ready/ready.dart',
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
