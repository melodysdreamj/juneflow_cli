import 'dart:io';

Future<void> addReadme(String ReadmeContent) async {
  if(ReadmeContent.isEmpty) {
    print('Readme content is empty.');
    return;
  }
  String currentPath = Directory.current.path;
  String filePath = 'lib/util/usage/logger_module/README.md';
  // print('filePath: $filePath');

  // 해당위치로 README.md 파일을 생성하거나 있을경우 덮어씌운다.
  File file = File(filePath);
  file.writeAsStringSync(ReadmeContent);
  // print('README.md has been updated.');

}