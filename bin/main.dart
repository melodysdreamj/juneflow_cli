import 'dart:io';

// 패키지와 버전을 입력받아 flutter pub add 명령을 실행하는 함수
Future<void> addFlutterPackage(String packageName, {String? version}) async {
  final packageArgument = version != null ? '$packageName:$version' : packageName;
  final result = await Process.run('flutter', ['pub', 'add', packageArgument]);

  // 실행 결과 출력
  // print('Exit code: ${result.exitCode}');
  // print('Stdout: ${result.stdout}');
  // print('Stderr: ${result.stderr}');

  print("installed $packageName");
}

void main() async {
  // 함수 사용 예시
  await addFlutterPackage('http', version: '0.13.3');
}
