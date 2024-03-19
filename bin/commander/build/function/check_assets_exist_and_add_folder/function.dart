import 'dart:io';

// 디렉토리 내에 .gitkeep 외에 다른 파일이나 폴더가 없는지 확인
Future<bool> _isOnlyGitKeepInDirectory(String directoryPath) async {
  // Directory 객체 생성
  final directory = Directory(directoryPath);

  // 디렉토리가 존재하는지 확인
  if (!await directory.exists()) {
    print('Directory does not exist.');
    return false;
  }

  // 디렉토리 내의 모든 항목을 async* 스트림으로 반환
  await for (final entity in directory.list()) {
    // entity가 파일이면서 .gitkeep가 아닌 경우 false 반환
    if (entity is File && !entity.path.endsWith('/.gitkeep')) {
      return false;
    }
    // entity가 디렉토리인 경우(하위 디렉토리 탐색은 여기서 수행하지 않음)
    if (entity is Directory) {
      // 루트 디렉토리를 제외한 어떠한 디렉토리도 존재하지 않아야 한다.
      return false;
    }
  }

  // .gitkeep 이외에 다른 파일이나 폴더가 없는 경우 true 반환
  return true;
}
