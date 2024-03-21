import 'dart:io';

Future<void> addFlutterPackage(String packageName, {String? version, bool? devPackage = false}) async {
  // 패키지 이름과 버전을 조합합니다. 유효한 버전이 제공되면 해당 버전을 사용하고, 그렇지 않으면 패키지 이름만 사용합니다.
  // 여기서는 버전이 명시적으로 제공되었을 때만 버전 정보를 추가하며, '^' 기호는 포함하지 않습니다.
  final packageArgument = (version != null && version.isNotEmpty) ? '$packageName:^$version' : packageName;

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