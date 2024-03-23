import 'dart:io';

import '../../../../entity/model/pubspec_code/model.dart';

Future<void> updatePubspecWithCodeBlocks(List<PubspecCode> codeBloc) async {
  File pubspecFile = File('${Directory.current.path}/pubspec.yaml');

  if (!await pubspecFile.exists()) {
    print('One or both of the specified files do not exist.');
    return;
  }

  String pubspecContent = await pubspecFile.readAsString();
  bool modified = false;

  for (PubspecCode pubspecCode in codeBloc) {
    // 타이틀이 이미 존재하는지 여부를 확인합니다.
    // 여기서는 타이틀 뒤에 콜론과 공백을 포함하여 보다 정확한 일치를 검사합니다.
    String pattern = r'^' + RegExp.escape(pubspecCode.Title) + r':\s';
    if (!RegExp(pattern, multiLine: true).hasMatch(pubspecContent)) {
      String formattedBlock = pubspecCode.CodeBloc;
      pubspecContent += '\n\n$formattedBlock\n\n';
      modified = true;
      print('Adding ${pubspecCode.Title} block to pubspec.yaml');
    }
  }

  if (modified) {
    await pubspecFile.writeAsString(pubspecContent);
    print('pubspec.yaml has been updated with new blocks.');
  }
}


void main() async {
  // 'config_file_path.yaml'과 'pubspec.yaml'을 실제 파일 경로로 변경하세요.
  await updatePubspecWithCodeBlocks([]);
}
