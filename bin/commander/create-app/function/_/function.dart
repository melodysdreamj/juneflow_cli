import '../../../../entity/enum/project_type/enum.dart';
import '../../../../entity/model/creation_result/model.dart';
import '../../../../util/clone_and_remove_git/function.dart';
import '../ask_user_input_for_project_creation/function.dart';

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

  cloneAndRemoveGit('https://github.com/melodysdreamj/juneflow.git', branchName,
      result.Name);
}