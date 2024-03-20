import 'dart:io';

Future<bool> checkIsRightProject() async {
  String currentPath = Directory.current.path;
  List<String> filePaths = [
    '$currentPath/lib/util/_/initial_app/build_app_widget/build_run_app/_.dart',
    '$currentPath/lib/util/config/_/global_imports.dart',
    '$currentPath/lib/util/_/initial_app/ready_functions/before_run_app/_.dart',
    '$currentPath/pubspec.lock',
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
