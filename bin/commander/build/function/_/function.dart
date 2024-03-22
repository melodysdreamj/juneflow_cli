import 'dart:io';

import '../../../../entity/model/pubspec_code/model.dart';
import '../../../../singleton/build_info/model.dart';
import '../add_asset_paths_in_pubspec/function.dart';
import '../add_bloc_to_pubspec/function.dart';
import '../add_global_export_if_not_exists/function.dart';
import '../add_line_to_gitignore/function.dart';
import '../add_package_in_modules/function.dart';
import '../add_readme/function.dart';
import '../apply_temp_dir_to_project/function.dart';
import '../build_app_with_juneflow_style/function.dart';
import '../check_assets_exist_and_add_folder/function.dart';
import '../check_is_right_project/function.dart';
import '../get_june_packages_in_project/function.dart';
import '../pasted_all_code_files_to_temp_dir/function.dart';
import '../reset_temp_dir/function.dart';

buildApp() async {
  if (!await checkIsRightProject()) {
    print('This is not a juneflow project');
    return;
  }

  await getJuneFlowPackagesInProject();

  // print(BuildInfo.instance.ModuleList);

  // 시작전 초기화하고 진행
  await resetTempDir();

  for (var module in BuildInfo.instance.ModuleList) {
    // 6. copy and paste the code file to the lib folder
    await pasteAllCodeFiles(module.LibraryName, module.Files);
  }

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
    await updatePubspecWithCodeBlocks(module.PubspecCodeBloc);

    // 4. add readme
    await addReadme(module.ReadMeContents, module.LibraryName);

    // 5. check asset if exist, add to pubspec
    await addAssetPaths(
        module.AddLineToPubspecAssetsBlock.map((item) => item.toString())
            .toList());

    // 7. add package to pubspec
    await addPackageInModules(module.Packages);
    await addDevPackageInModules(module.DevPackage);

    await checkAndAddModules(module.Packages, devPackages: false);
    await checkAndAddModules(module.DevPackage, devPackages: true);
  }

  // 7. apply .tempDir to lib folder
  await applyTempDirToProject();

  // 8. build project with juneflow style
  await buildAppWithJuneFlowStyle();
}
