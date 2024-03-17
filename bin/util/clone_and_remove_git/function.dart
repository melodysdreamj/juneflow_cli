import 'dart:io';

Future<void> cloneAndRemoveGit(
    String repoUrl, String branchName, String targetDirectory) async {
  // Git 저장소를 클론하는 명령어 실행
  var result = await Process.run(
      'git', ['clone', '-b', branchName, repoUrl, targetDirectory]);
  if (result.exitCode != 0) {
    print('Git 클론에 실패했습니다: ${result.stderr}');
    return;
  } else {
    print('Git 클론 성공: ${result.stdout}');
  }

  // 클론된 디렉토리에서 .git 폴더를 제거
  var dir = Directory('$targetDirectory/.git');
  if (await dir.exists()) {
    await dir.delete(recursive: true);
    print('.git 폴더를 성공적으로 제거했습니다.');
  } else {
    print('.git 폴더가 없습니다.');
  }
}
