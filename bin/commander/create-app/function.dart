import 'dart:io';

import '../../entity/enum/project_type/enum.dart';
import '../../entity/model/creation_result/model.dart';
import 'function/ask_user_input_for_project_creation/function.dart';
import 'function/change_project_name/function.dart';
import 'function/clone_and_remove_git/function.dart';
import 'function/remove_file/function.dart';
import 'function/rename_new_folder/function.dart';
import 'function/replace_string_in_file/function.dart';
import 'function/replace_sttring_in_files/function.dart';

createApp() async {
  CreationResult? result = await askUserInputForProjectCreation();
  if (result == null) {
    print('The app creation has been cancelled.');
    return;
  }

  String branchName;
  if (result.Type == ProjectTypeEnum.Skeleton) {
    branchName = 'main';
  } else if (result.Type == ProjectTypeEnum.ModuleTemplate) {
    branchName = 'module_template';
  } else if (result.Type == ProjectTypeEnum.JuneViewProject) {
    branchName = 'june_view_project';
  } else {
    branchName = 'view_template';
  }

  if (result.Type == ProjectTypeEnum.ViewTemplate) {
    await cloneAndRemoveGit(
        'https://github.com/melodysdreamj/june_view_store.git',
        branchName,
        result.Name);
  } else if (result.Type == ProjectTypeEnum.JuneViewProject) {
    await cloneAndRemoveGit('https://github.com/juneflow-songdo/june_view',
        'project-template', result.Name);
  } else {
    await cloneAndRemoveGit('https://github.com/melodysdreamj/juneflow.git',
        branchName, result.Name);
  }

  await changeProjectName(result.Name, result.Name);

  if (result.Type == ProjectTypeEnum.Skeleton) {
    await replaceStringInFiles(
        result.Name, 'june.lee.love', result.PackageName);
    await removeFile('${result.Name}/LICENSE');
  } else if (result.Type == ProjectTypeEnum.JuneViewProject) {
    await replaceStringInFiles(
        result.Name, 'june.lee.love', result.PackageName);
    await removeFile('${result.Name}/LICENSE');
  } else if (result.Type == ProjectTypeEnum.ModuleTemplate) {
    await replaceStringInFiles('${result.Name}/lib/util/_/initial_app', 'New',
        _toPascalCase(result.Name));

    await renameNewFolders('${result.Name}/lib/util', result.Name);

    await renameNewFolders('${result.Name}/assets/module', result.Name);

    await replaceStringInFile(
        '${result.Name}/README.md', 'NewModule', result.Name);
  } else if (result.Type == ProjectTypeEnum.ViewTemplate) {
    await renameNewFolders('${result.Name}/assets/view', result.Name);
    // await renameNewFolders(
    //     '${result.Name}/lib/app/_/_/interaction', result.Name);
  } else {
    print('Invalid project type: ${result.Type}');
    return;
  }

  print('\nCongratulations! Your project has been created successfully!');
  print(
      'Please change your current directory to the project directory by executing the following command:');
  print('>>>> cd ${result.Name} && flutter run -d chrome <<<<');
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
