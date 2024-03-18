import '../../../../entity/enum/project_type/enum.dart';
import '../../../../entity/model/creation_result/model.dart';
import '../../../../util/clone_and_remove_git/function.dart';
import '../ask_user_input_for_project_creation/function.dart';
import '../change_project_name/function.dart';
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

  if (result.Type == ProjectTypeEnum.Module) {
    await replaceStringInFiles(
        result.Name, 'june.lee.love', result.PackageName);
  }

  print('\nCongratulations! Your project has been created successfully!');
}
