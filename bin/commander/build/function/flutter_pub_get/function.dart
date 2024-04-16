import 'dart:io';

// flutter pub get을 실행하는 함수
Future<void> runFlutterPubGet() async {
  var currentDirectory = Directory.current.path;
  String flutterCommand = 'flutter';  // 기본 커맨드 설정

  if (Platform.isWindows) {
    print("Windows 환경에서 실행 중");
    var whereResult = await Process.run('where', ['flutter.bat']);
    if (whereResult.exitCode == 0) {
      flutterCommand = (whereResult.stdout as String).split('\n').first.trim();
    } else {
      print('Flutter not found in your path.');
      return;
    }
  } else {
    print("비Windows 환경에서 실행 중: ${Platform.operatingSystem}");
  }

  var result = await Process.run(flutterCommand, ['pub', 'get'], workingDirectory: currentDirectory);

  if (result.stdout.isNotEmpty) {
    print(result.stdout);
  }
  if (result.stderr.isNotEmpty) {
    print('Error: ${result.stderr}');
  }
}
