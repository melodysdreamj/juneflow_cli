import 'dart:io';

Future<void> addFlutterPackage(String packageName, {String? version}) async {
  final packageArgument =
      version != null ? '$packageName:$version' : packageName;
  final result = await Process.run('flutter', ['pub', 'add', packageArgument],
      workingDirectory: Directory.current.path // 현재 작업 중인 디렉토리를 사용합니다.
      );

  // 실행 결과 출력
  // print('Exit code: ${result.exitCode}');
  // print('Stdout: ${result.stdout}');
  // print('Stderr: ${result.stderr}');

  print("installed $packageName");
}
