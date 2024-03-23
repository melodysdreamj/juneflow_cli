import 'dart:io';

import '../../../../entity/model/pubspec_code/model.dart';

Future<void> updatePubspecWithCodeBlocks(List<PubspecCode> codeBloc) async {
  File pubspecFile = File('${Directory.current.path}/pubspec.yaml');

  if (!await pubspecFile.exists()) {
    print('One or both of the specified files do not exist.');
    return;
  }

  String pubspecContent = await pubspecFile.readAsString();

  // 파일이 수정되었는지 여부를 추적합니다.
  bool modified = false;
  for (PubspecCode pubspecCode in codeBloc) {
    // 주어진 타이틀이 이미 pubspec.yaml 파일 내에 존재하는지 확인합니다.
    if (!pubspecContent.contains(RegExp(r'^${pubspecCode.title}:', multiLine: true))) {
      // 여기서는 원본 코드 블록의 들여쓰기를 그대로 유지합니다.
      String formattedBlock = pubspecCode.CodeBloc;
      pubspecContent += '\n\n${pubspecCode.Title}:\n$formattedBlock\n\n';
      modified = true;
      print('Adding ${pubspecCode.Title} block to pubspec.yaml');
    }
  }

  // 파일이 수정되었다면 새로운 내용으로 파일을 업데이트합니다.
  if (modified) {
    await pubspecFile.writeAsString(pubspecContent);
    print('pubspec.yaml has been updated with new blocks.');
  }
}

void main() async {
  // 'config_file_path.yaml'과 'pubspec.yaml'을 실제 파일 경로로 변경하세요.
  await updatePubspecWithCodeBlocks([]);
}
