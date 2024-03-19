import 'dart:io';

import '../../../../entity/model/pubspec_code/model.dart';

Future<void> updatePubspecWithCodeBlocks(List<PubspecCode> codeBloc) async {
  File pubspecFile = File('${Directory.current.path}/pubspec.yaml');

  if (!await pubspecFile.exists()) {
    print('One or both of the specified files do not exist.');
    return;
  }

  String pubspecContent = await pubspecFile.readAsString();

  // pubspec.yaml에 없는 대제목이면 추가
  bool modified = false;
  for(PubspecCode pubspecCode in codeBloc) {
    // RegExp 패턴에 'm' 플래그를 추가하여, 문자열 전체에 걸쳐 여러 줄 모드에서 작동하도록 합니다.
    if (!pubspecContent.contains(RegExp(r'^${pubspecCode.title}:', multiLine: true))) {
      // 여러 줄의 코드 블록을 처리하기 위해, 각 줄 앞에 2개의 공백을 추가합니다.
      String formattedBlock = pubspecCode.CodeBloc.split('\n').map((line) => '  $line').join('\n');
      pubspecContent += '\n${pubspecCode.Title}:\n$formattedBlock';
      modified = true;
      print('Adding ${pubspecCode.Title} block to pubspec.yaml');
    }
  }

  // 파일이 수정되었으면 새 내용으로 쓰기
  if (modified) {
    await pubspecFile.writeAsString(pubspecContent);
    print('pubspec.yaml has been updated with new blocks.');
  } else {
    print('No new blocks were added to pubspec.yaml.');
  }
}

void main() async {
  // 'config_file_path.yaml'과 'pubspec.yaml'을 실제 파일 경로로 변경하세요.
  await updatePubspecWithCodeBlocks([]);
}
