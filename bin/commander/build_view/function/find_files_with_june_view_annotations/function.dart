import 'dart:io';

Future<List<String>> findFilesWithJuneViewAnnotations(String directoryPath) async {
  List<String> filesWithAnnotations = [];

  // 디렉토리를 재귀적으로 탐색하는 비동기 함수
  Future<void> searchDirectory(Directory directory) async {
    await for (var entity in directory.list(recursive: false, followLinks: false)) {
      if (entity is File) {
        // 파일인 경우 내용을 검사
        String content = await entity.readAsString();
        if (content.contains('@JuneViewAction()') || content.contains('@JuneViewEvent()')) {
          filesWithAnnotations.add(entity.path);
        }
      } else if (entity is Directory) {
        // 디렉토리인 경우 재귀적으로 탐색
        await searchDirectory(entity);
      }
    }
  }

  // 지정된 시작 디렉토리부터 탐색 시작
  await searchDirectory(Directory(directoryPath));

  return filesWithAnnotations;
}