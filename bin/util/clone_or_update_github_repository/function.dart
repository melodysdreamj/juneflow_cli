import 'dart:io';

Future<void> cloneOrUpdateGitHubRepository(
    String repositoryUrl,
    {String branchName = 'main'}) async {

  String baseDirectory = './.clone-june-flutter';
  // URL에서 사용자 ID와 프로젝트명 추출
  var uri = Uri.parse(repositoryUrl);
  var segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.length < 2) {
    print('Invalid GitHub repository URL');
    return;
  }
  var userId = segments[segments.length - 2];
  var projectName = segments.last;

  // 최종 디렉토리 경로 구성
  final directoryPath = '$baseDirectory/$userId/$projectName/$branchName';
  final directory = Directory(directoryPath);

  if (await directory.exists()) {
    var result = await Process.run(
        'git', ['rev-parse', '--is-inside-work-tree'],
        workingDirectory: directoryPath);
    if (result.stdout.toString().trim() == 'true') {
      result =
      await Process.run('git', ['pull'], workingDirectory: directoryPath);
      if (result.exitCode == 0) {
        print('Repository updated successfully at $directoryPath');
      } else {
        print('Failed to update repository: ${result.stderr}');
      }
    } else {
      print('Directory at $directoryPath is not a git repository.');
    }
  } else {
    // 해당 경로에 디렉토리 생성
    await directory.create(recursive: true);
    var result = await Process.run(
        'git', ['clone', '-b', branchName, repositoryUrl, '.'],
        workingDirectory: directoryPath);
    if (result.exitCode == 0) {
      print('Repository cloned successfully to $directoryPath');
    } else {
      print('Failed to clone repository: ${result.stderr}');
    }
  }
}
