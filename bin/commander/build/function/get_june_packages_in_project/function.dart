import 'dart:io';

import '../../../../entity/model/pubspec_code/model.dart';
import '../../../../util/run_flutter_pub_get/function.dart';
import '../../../../entity/model/file_path_and_contents/model.dart';
import '../../../../entity/model/module/model.dart';
import '../../../../entity/model/package_info/model.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../../../../singleton/build_info/model.dart';
import '../check_assets_exist_and_add_folder/function.dart';
import 'usage.dart';

Future<void> getJuneFlowPackagesInProject() async {
  await runFlutterPubGet();
  // pubspec.lock 파일 읽기
  var lockFile = File('pubspec.lock');
  var content = await lockFile.readAsString();
  var yamlContent = loadYaml(content);

  // 디펜던시 목록 추출
  var dependencies = yamlContent['packages'] as Map;

  for (var entry in dependencies.entries) {
    String name = entry.key;
    Map details = entry.value;

    var packagePath = _getPackagePath(name, details['version']);
    if (packagePath == null) continue;

    if (await _checkJuneFlowModule(packagePath, name, details['version'])) {
      Module? module = await generateModuleObjFromPackage(
          packagePath, name, details['version']);

      if (module != null) {
        //   여기서 assets에 파일이 있는지 확인후, 있을경우 해당 경로 추가하고, assets파일자체들 자체를
        //   임시폴더(복붙용)에 옮겨주자.
        module = await checkAssetsHandler(packagePath, module, '$packagePath/assets');

        BuildInfo.instance.ModuleList.add(module);
      }
    }
  }
}

Future<bool> _checkJuneFlowModule(
    String packagePath, String packageName, String packageVersion) async {
  File file = File('$packagePath/juneflow_module.yaml');
  if (await file.exists()) {
    String contents = await file.readAsString();
    // 정규식을 사용하여 각 섹션의 존재 여부 확인
    final RegExp copyPathRegexp =
        RegExp(r'^copy_path:\s*\n(?!#)-', multiLine: true);
    final RegExp gitignoreRegexp =
        RegExp(r'^add_line_to_gitignore:\s*\n(?!#)-', multiLine: true);
    final RegExp pubspecRegexp =
        RegExp(r'^add_code_block_to_pubspec:\s*\n(?!#)-', multiLine: true);
    final RegExp globalImportsRegexp =
        RegExp(r'^add_line_to_global_imports:\s*\n(?!#)-', multiLine: true);

    // 하나라도 주석이 아닌 항목이 있는지 검사
    if (copyPathRegexp.hasMatch(contents) ||
        gitignoreRegexp.hasMatch(contents) ||
        pubspecRegexp.hasMatch(contents) ||
        globalImportsRegexp.hasMatch(contents)) {
      return true;
    }
  }
  // 파일이 없거나 모든 항목이 주석 처리된 경우
  return false;
}

Future<String> _readReadmeContent(String projectPath) async {
  File readmeFile = File('$projectPath/README.md');
  if (await readmeFile.exists()) {
    return await readmeFile.readAsString();
  } else {
    return '';
  }
}

String? _getPackagePath(String packageName, String packageVersion) {
  // 환경 변수에서 홈 디렉토리 경로 가져오기
  var homePath =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  if (homePath == null) {
    print('Cannot find user home directory');
    return null;
  }

  // .pub-cache 경로 옵션 설정
  var pubCacheHostedPath = path.join(homePath, '.pub-cache', 'hosted');
  var pubDevPath = path.join(pubCacheHostedPath, 'pub.dev');
  var pubDartlangOrgPath = path.join(pubCacheHostedPath, 'pub.dartlang.org');

  // 존재하는 .pub-cache 호스팅 경로 확인
  String? packageHostedPath;
  if (Directory(pubDevPath).existsSync()) {
    packageHostedPath = pubDevPath;
  } else if (Directory(pubDartlangOrgPath).existsSync()) {
    packageHostedPath = pubDartlangOrgPath;
  }

  return path.join(packageHostedPath!, '$packageName-$packageVersion');
}

Future<List<FilePathAndContents>> _generateFilePathAndContentsList(
    String libraryName, String projectPath, List<String> copyPaths) async {
  /// 여기서 copyPaths 를 수정해야하는데, 왜냐하면 util쪽은 함부로 건들면 안되고 정해진대로 해야하기때문. 그외는 상관없음.
  /// 만약 문자열이 lib/util 로 시작할경우, 끝이 libraryName 로 끝나는 경우를 제외하고는 지우기
  // lib/util로 시작하며, libraryName으로 끝나지 않는 경로를 필터링
  List<String> filteredCopyPaths = copyPaths.where((path) {
    // 'lib/util'로 시작하는지 확인
    bool startsWithUtil = path.startsWith('lib/util');
    // 'libraryName'으로 끝나는지 확인
    bool endsWithLibraryName = path.endsWith(libraryName);
    // 'assets/'로 시작하지 않는지 확인
    bool doesNotStartWithAssets = !path.startsWith('assets/');
    // 파일 이름이 '.gitkeep'으로 끝나지 않는지 확인
    bool doesNotEndWithGitkeep = !path.endsWith('.gitkeep');

    // 'lib/util'로 시작하지 않거나, 'lib/util'로 시작하며 'libraryName'으로 끝나며, 동시에 'assets/'로 시작하지 않고, '.gitkeep'으로 끝나지 않는 경우 true를 반환
    return doesNotStartWithAssets &&
        doesNotEndWithGitkeep &&
        (!startsWithUtil || (startsWithUtil && endsWithLibraryName));
  }).toList();

  List<FilePathAndContents> files = [];

  for (String relativePath in filteredCopyPaths) {
    String fullPath = '$projectPath/$relativePath';
    File file = File(fullPath);
    if (await file.exists()) {
      String content = await file.readAsString();
      files.add(FilePathAndContents()
        ..Path = relativePath
        ..CodeBloc = content);
    } else {
      print('File not found: $fullPath');
      // 파일을 찾을 수 없는 경우, 빈 내용을 가진 FilePathAndContents를 추가할 수 있습니다.
      // 이는 선택적으로 처리할 수 있으며, 필요에 따라 생략하거나 다른 처리를 할 수 있습니다.
      // files.add(FilePathAndContents(path: fullPath, codeBlock: ''));
    }
  }

  return files;
}

Future<Module?> generateModuleObjFromPackage(
  String projectPath,
  String libraryName,
  String libraryVersion,
) async {
  Module moduleObj = Module();

  // add README contents
  moduleObj.ReadMeContents = await _readReadmeContent(projectPath);
  moduleObj.LibraryName = libraryName;
  moduleObj.LibraryVersion = libraryVersion;

  File yamlFile = File('$projectPath/juneflow_module.yaml');
  if (await yamlFile.exists()) {
    String content = await yamlFile.readAsString();
    var yamlContent = loadYaml(content);

    // 여기서부터 YAML 파일로부터 필요한 정보를 추출하여 TableModule 객체를 생성하는 로직 구현
    moduleObj.AddLineToGitignore =
        _parseYamlList(yamlContent, 'add_line_to_gitignore');
    moduleObj.AddLineToGlobalImports =
        _parseYamlList(yamlContent, 'add_line_to_global_imports');
    moduleObj.Files = await _generateFilePathAndContentsList(
        libraryName, projectPath, _parseYamlList(yamlContent, 'copy_path'));

    moduleObj.PubspecCodeBloc = await _getCodeBlocksFromPubspec(projectPath);

    return moduleObj;
  } else {
    print('File not found: ${yamlFile.path}');
    return null;
  }
}

List<String> _parseYamlList(YamlMap yamlContent, String key) {
  var list = yamlContent[key];
  if (list is YamlList) {
    return list.map((item) => item.toString()).toList();
  }
  return [];
}

Future<List<PubspecCode>> _getCodeBlocksFromPubspec(String projectPath) async {
  File pubspecFile = File('$projectPath/pubspec.yaml');
  if (await pubspecFile.exists()) {
    String configContent = await pubspecFile.readAsString();

    List<PubspecCode> codeBlocksToCheck = [];

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
        String value = match
            .group(2)!
            .trim()
            .replaceAll(RegExp(r'\n\s+'), '\n'); // 들여쓰기 최소화
        // 값이 바로 뒤에 오는 경우를 위해 조건 추가
        if (value.startsWith('|')) {
          value = value.substring(1).trim();
          codeBlocksToCheck.add(PubspecCode()
            ..Title = key
            ..CodeBloc = value);
        } else {
          codeBlocksToCheck.add(PubspecCode()
            ..Title = key
            ..CodeBloc = "\n$value");
        }
      }
    }

    return codeBlocksToCheck;
  } else {
    print('File not found: ${pubspecFile.path}');
    return [];
  }
}
