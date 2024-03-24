import 'dart:io';

import 'package:yaml/yaml.dart';

// 패키지를 입력받아 flutter pub remove 명령을 실행하는 함수
Future<void> removeFlutterPackage(String packageName) async {
  // pubspec.yaml 파일 읽기
  final pubspecFile = File('${Directory.current.path}/pubspec.yaml');
  final pubspecContent = await pubspecFile.readAsString();

  // pubspec.yaml 내용 파싱
  final pubspecYaml = loadYaml(pubspecContent);

  // dependencies 또는 dev_dependencies에 패키지가 있는지 확인
  final bool hasPackage = pubspecYaml['dependencies']?.containsKey(packageName) ?? false ||
      pubspecYaml['dev_dependencies']?.containsKey(packageName) ?? false;

  if (hasPackage) {
    print("Removing $packageName...");
    // 패키지가 존재하면 제거 명령 실행
    final result = await Process.run('flutter', ['pub', 'remove', packageName],
        workingDirectory: Directory.current.path // 현재 작업 중인 디렉토리를 사용합니다.
    );

    // 실행 결과 출력(필요에 따라)
    // print('Exit code: ${result.exitCode}');
    // print('Stdout: ${result.stdout}');
    // print('Stderr: ${result.stderr}');

    // print("removed $packageName");
  } else {
    // 패키지가 존재하지 않으면 메시지 출력
    // print("Package '$packageName' not found in pubspec.yaml");
  }
}