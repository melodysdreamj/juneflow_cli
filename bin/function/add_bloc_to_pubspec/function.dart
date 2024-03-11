import 'dart:io';

Future<void> updatePubspecWithCodeBlocks(String configFilePath, String pubspecFilePath) async {
  File configFile = File(configFilePath);
  File pubspecFile = File(pubspecFilePath);

  if (!await configFile.exists() || !await pubspecFile.exists()) {
    print('One or both of the specified files do not exist.');
    return;
  }

  String configContent = await configFile.readAsString();
  String pubspecContent = await pubspecFile.readAsString();

  Map<String, String> codeBlocksToCheck = {};

  // 'add_code_block_to_pubspec:' 섹션 찾기
  RegExp regExp = RegExp(r'add_code_block_to_pubspec:(.*?)#', dotAll: true);
  var matches = regExp.firstMatch(configContent);

  if (matches != null) {
    // 코드 블록 추출
    String blocksContent = matches.group(1)!;
    RegExp blockRegExp = RegExp(r'- (.*?): *\|\n(.*?)\n\s*\n', dotAll: true);
    var blockMatches = blockRegExp.allMatches(blocksContent);

    for (var match in blockMatches) {
      String key = match.group(1)!.trim();
      String value = match.group(2)!.trim().replaceAll(RegExp(r'\n\s+'), '\n'); // 들여쓰기 최소화
      // 값이 바로 뒤에 오는 경우를 위해 조건 추가
      if (value.startsWith('|')) {
        value = value.substring(1).trim();
        codeBlocksToCheck[key] = "$key: $value"; // 같은 줄에 값 추가
      } else {
        codeBlocksToCheck[key] = "$key:\n$value"; // 새로운 줄에 값 추가
      }
    }
  }

  // pubspec.yaml에 없는 대제목이면 추가
  bool modified = false;
  codeBlocksToCheck.forEach((title, block) {
    if (!pubspecContent.contains(RegExp(r'^$title:|\n$title:'))) {
      pubspecContent += '\n$block';
      modified = true;
      print('Adding $title block to pubspec.yaml');
    }
  });

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
  await updatePubspecWithCodeBlocks('config_file_path.yaml', 'pubspec.yaml');
}
