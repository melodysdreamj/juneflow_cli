import 'dart:io';

// 패키지를 입력받아 flutter pub remove 명령을 실행하는 함수
Future<void> removeFlutterPackage(String packageName) async {
  final result = await Process.run('flutter', ['pub', 'remove', packageName]);

  // 실행 결과 출력
  // print('Exit code: ${result.exitCode}');
  // print('Stdout: ${result.stdout}');
  // print('Stderr: ${result.stderr}');

  print("removed $packageName");
}
