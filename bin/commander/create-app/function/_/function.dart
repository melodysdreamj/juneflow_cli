import 'dart:io';

import '../../../../entity/enum/project_type/enum.dart';
import '../../../../entity/model/creation_result/model.dart';
import '../ask_user_input_for_project_creation/function.dart';
import '../change_project_name/function.dart';
import '../clone_and_remove_git/function.dart';
import '../rename_new_folder/function.dart';
import '../replace_string_in_file/function.dart';
import '../replace_sttring_in_files/function.dart';

createApp() async {
  CreationResult? result = await askUserInputForProjectCreation();
  if (result == null) {
    print('The app creation has been cancelled.');
    return;
  }

  String branchName;
  if (result.Type == ProjectTypeEnum.Skeleton) {
    branchName = 'main';
  } else {
    branchName = 'module_template';
  }

  await cloneAndRemoveGit(
      'https://github.com/melodysdreamj/juneflow.git', branchName, result.Name);

  await changeProjectName(result.Name, result.Name);

  if (result.Type == ProjectTypeEnum.Skeleton) {
    await replaceStringInFiles(
        result.Name, 'june.lee.love', result.PackageName);
  } else {
    await replaceStringInFiles('${result.Name}/lib/util/_/initial_app', 'New',
        _toPascalCase(result.Name));

    await renameNewFolders('${result.Name}/lib/util', result.Name);

    await renameNewFolders('${result.Name}/assets/module', result.Name);

    await replaceStringInFile(
        '${result.Name}/README.md', 'NewModule', result.Name);

    await replaceStringInFile(
        '${Directory.current.path}/${result.Name}/juneflow_module.yaml',
        '_new',
        result.Name);
  }

  print('\nCongratulations! Your project has been created successfully!');
}

String _toPascalCase(String text) {
  // 언더스코어로 단어를 분리하여 리스트를 생성
  List<String> words = text.split('_');

  // 모든 단어의 첫 글자를 대문자로 변환
  for (int i = 0; i < words.length; i++) {
    if (words[i].isNotEmpty) {
      words[i] =
          words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
    }
  }

  // 단어들을 다시 하나의 문자열로 합침
  return words.join('');
}
