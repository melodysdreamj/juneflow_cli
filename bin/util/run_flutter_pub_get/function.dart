import 'dart:io';

// flutter pub get을 실행하는 함수
Future<void> runFlutterPubGet() async {
  // 현재 작업 디렉토리를 가져옵니다.
  var currentDirectory = Directory.current.path;

  // 'flutter pub get' 명령을 실행합니다.
  var result = await Process.run('flutter', ['pub', 'get'], workingDirectory: currentDirectory);

  // 실행 결과를 출력합니다.
  print(result.stdout);
  // 에러가 있다면 에러도 출력합니다.
  if (result.stderr.isNotEmpty) {
    print('Error: ${result.stderr}');
  }
}