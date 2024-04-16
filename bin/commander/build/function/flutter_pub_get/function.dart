import 'dart:io';

Future<void> runFlutterPubGet() async {
  var currentDirectory = Directory.current.path;
  String flutterCommand = 'flutter';

  // Windows에서만 'where' 명령을 사용하여 Flutter 위치를 찾습니다.
  if (Platform.isWindows) {
    var whereResult = await Process.run('where', ['flutter']);
    if (whereResult.exitCode == 0) {
      flutterCommand = (whereResult.stdout as String).split('\n').first.trim();
    } else {
      print('Flutter not found in your path.');
      return;
    }
  }

  // 'flutter pub get' 명령을 실행합니다.
  var result = await Process.run(flutterCommand, ['pub', 'get'], workingDirectory: currentDirectory);

  // 실행 결과를 출력합니다.
  if (result.stdout.isNotEmpty) {
    print(result.stdout);
  }
  if (result.stderr.isNotEmpty) {
    print('Error: ${result.stderr}');
  }
}