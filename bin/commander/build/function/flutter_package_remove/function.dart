import 'dart:io';

// 패키지를 입력받아 flutter pub remove 명령을 실행하는 함수
Future<void> removeFlutterPackage(String packageName, {bool? devPackage = false}) async {
  // devPackage가 true일 경우 '--dev' 옵션을 추가합니다.
  final List<String> command = ['pub', 'remove', packageName];
  if (devPackage == true) {
    command.add('--dev');
  }

  // 프로세스를 실행하여 패키지를 제거합니다.
  final result = await Process.run('flutter', command,
      workingDirectory: Directory.current.path // 현재 작업 중인 디렉토리를 사용합니다.
  );

  // 실행 결과를 출력합니다.
  if (result.stderr.toString().isNotEmpty) {
    print('error: ${result.stderr}');
  } else {
    final String devStr = (devPackage == true) ? 'dev_dependencies' : 'dependencies';
    print("Removed $packageName from $devStr.");
  }
}