import 'dart:io';

// 패키지를 입력받아 flutter pub remove 명령을 실행하는 함수
Future<void> removeFlutterPackage(String packageName) async {
  final result = await Process.run('flutter', ['pub', 'remove', packageName],
      workingDirectory: Directory.current.path // 현재 작업 중인 디렉토리를 사용합니다.
      );

  // 실행 결과 출력
  // print('Exit code: ${result.exitCode}');
  // print('Stdout: ${result.stdout}');
  // print('Stderr: ${result.stderr}');

  print("removed $packageName");
}
