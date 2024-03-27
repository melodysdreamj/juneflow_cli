import 'dart:io';

Future<List<String>> findFilesWithJuneViewAnnotations(String directoryPath) async {
  List<String> filesWithAnnotations = [];

  // 디렉토리를 재귀적으로 탐색하는 비동기 함수
  Future<void> searchDirectory(Directory directory) async {
    await for (var entity in directory.list(recursive: false, followLinks: false)) {
      if (entity is File) {
        // 파일인 경우 내용을 검사
        try {
          String content = await entity.readAsString();
          if (content.contains('@JuneViewAction()') || content.contains('@JuneViewEvent()')) {
            filesWithAnnotations.add(entity.path);
          }
        } catch (e) {
          if (e is FileSystemException) {
            // print("읽을 수 없는 파일을 건너뜁니다: ${entity.path}");
          } else {
            throw e; // 알려지지 않은 다른 종류의 예외는 다시 던집니다.
          }
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