import 'dart:io';

Future<void> applyTempDirToProject() async {
  // /.tempDir 디렉토리의 파일들을 현재 디렉토리로 복사
  Directory tempDir = Directory('.tempDir');
  if (await tempDir.exists()) {
    // Stream을 사용한 파일 리스트 처리
    await for (var element in tempDir.list(recursive: true)) {
      if (element is File) {
        String newPath = element.path.replaceAll('.tempDir/', '');
        File newFile = File(newPath);
        if (await newFile.exists()) {
          // 기존 파일이 있을 경우, 이 파일 처리를 건너뛰고 계속 진행
          continue;
        }
        await newFile.create(recursive: true);
        await newFile.writeAsString(await element.readAsString());
      }
    }
    // 파일 복사 작업이 완료된 후, .tempDir 디렉토리 삭제
    // await tempDir.delete(recursive: true);
  }
}


