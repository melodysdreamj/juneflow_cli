import '../../../../entity/model/pubspec_code/model.dart';
import '../../../../singleton/build_info/model.dart';
import '../add_bloc_to_pubspec/function.dart';
import '../add_global_export_if_not_exists/function.dart';
import '../add_line_to_gitignore/function.dart';
import '../add_readme/function.dart';
import '../get_june_packages_in_project/function.dart';

buildApp() async {
  await getJuneFlowPackagesInProject();

  print(BuildInfo.instance.ModuleList);

  // 5개(global_imports, pubspec(code bloc), pubspec(assets), readme, gitignore)의 파일을 수정한다.

  for (var module in BuildInfo.instance.ModuleList) {
    // 1. global_imports.dart 수정
    for (var globalImport in module.AddLineToGlobalImports) {
      // global_imports.dart 파일을 읽어서 해당 모듈의 global_imports를 추가한다.
      await addExportIfNotExists(globalImport);
    }

    // 2. gitignore 추가
    for (var gitignore in module.AddLineToGitignore) {
      // gitignore 파일을 읽어서 해당 모듈의 gitignore를 추가한다.
      await addLineToGitignore(gitignore);
    }

    // 3. add code block to pubspec
    await updatePubspecWithCodeBlocks(module.CodeBloc);

    // 4. add readme
    await addReadme(module.ReadMeContents);

    // 5. check asset if exist, copy file and add to pubspec


    // 6. copy and paste the file to the lib folder



  }
}
