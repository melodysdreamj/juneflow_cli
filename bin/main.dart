import 'dart:io';

Future<void> cloneOrUpdateGitHubRepository(String repositoryUrl, String directoryPath, {String branchName = 'main'}) async {
  final directory = Directory(directoryPath);
  if (await directory.exists()) {
    var result = await Process.run('git', ['rev-parse', '--is-inside-work-tree'], workingDirectory: directoryPath);
    if (result.stdout.toString().trim() == 'true') {
      result = await Process.run('git', ['pull'], workingDirectory: directoryPath);
      if (result.exitCode == 0) {
        print('Repository updated successfully at $directoryPath');
      } else {
        print('Failed to update repository: ${result.stderr}');
      }
    } else {
      print('Directory at $directoryPath is not a git repository.');
    }
  } else {
    var result = await Process.run('git', ['clone', '-b', branchName, repositoryUrl, directoryPath]);
    if (result.exitCode == 0) {
      print('Repository cloned successfully to $directoryPath');
    } else {
      print('Failed to clone repository: ${result.stderr}');
    }
  }
}

main() {
  print('main');

  cloneOrUpdateGitHubRepository('https://github.com/melodysdreamj/JuneFlutter', './.clone-june-flutter', branchName: 'view_store');

}