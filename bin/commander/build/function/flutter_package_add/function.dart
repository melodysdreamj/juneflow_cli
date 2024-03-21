import 'dart:io';

Future<void> addFlutterPackage(String packageName, {String? version, bool? devPackage = false}) async {
  // 패키지 이름과 버전을 조합합니다. 버전이 지정되었으면 해당 버전을, 아니면 최신 버전을 사용합니다.
  final packageArgument = version != null ? '$packageName:^$version' : packageName;
  // devPackage가 true일 경우 '--dev' 옵션을 추가합니다.
  final List<String> command = ['pub', 'add', packageArgument];
  if (devPackage == true) {
    command.add('--dev');
  }

  // 프로세스를 실행하여 패키지를 추가합니다.
  final result = await Process.run('flutter', command,
      workingDirectory: Directory.current.path // 현재 작업 중인 디렉토리를 사용합니다.
  );

  // 실행 결과를 출력합니다.
  if (result.stderr.toString().isNotEmpty) {
    print('error: ${result.stderr}');
  } else {
    final String devStr = (devPackage == true) ? 'dev_dependencies' : 'dependencies';
    print("Installed $packageName in $devStr.");
  }
}