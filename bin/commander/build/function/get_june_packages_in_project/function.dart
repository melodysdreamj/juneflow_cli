import 'dart:io';

import '../../../../entity/model/pubspec_code/model.dart';
import '../../../../entity/model/file_path_and_contents/model.dart';
import '../../../../entity/model/module/model.dart';
import '../../../../entity/model/package_info/model.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../../../../singleton/build_info/model.dart';
import '../check_assets_exist_and_add_folder/function.dart';
import '../flutter_pub_get/function.dart';
import '../get_direct_dependencies_with_versions/function.dart';
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
      Module module = await generateModuleObjFromPackage(
          packagePath, name, details['version']);

      module =
          await checkAssetsHandler(packagePath, module, '$packagePath/assets');

      // 패키지 어떤게 있는지도 챙겨서 넣어주자.
      module.Packages = await getDirectDependenciesWithVersions(packagePath);
      module.DevPackage =
          await getDirectDevDependenciesWithVersions(packagePath);

      // print("module.Packages: ${module.Packages} name:${module.LibraryName}");
      // print("module.DevPackage: ${module.DevPackage} name:${module.LibraryName}");

      BuildInfo.instance.ModuleList.add(module);
    }
  }
}

Future<bool> _checkJuneFlowModule(
    String packagePath, String packageName, String packageVersion) async {
  File file = File(
      '$packagePath/lib/util/_/initial_app/build_app_widget/build_run_app/_.dart');

  if (await file.exists()) {
    return true;
  }
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
    FileSystemEntityType entityType =
        await FileSystemEntity.type(fullPath, followLinks: false);

    if (entityType == FileSystemEntityType.file) {
      File file = File(fullPath);
      String content = await file.readAsString();
      files.add(FilePathAndContents()
        ..Path = relativePath
        ..CodeBloc = content);
    } else if (entityType == FileSystemEntityType.directory) {
      Directory directory = Directory(fullPath);
      await for (FileSystemEntity entity
          in directory.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          String entityPath = entity.path.replaceFirst('$projectPath/', '');
          String content = await entity.readAsString();
          files.add(FilePathAndContents()
            ..Path = entityPath
            ..CodeBloc = content);
        }
      }
    }
  }

  return files;
}

Future<Module> generateModuleObjFromPackage(
  String projectPath,
  String libraryName,
  String libraryVersion,
) async {
  Module moduleObj = Module();

  // add README contents
  moduleObj.ReadMeContents = await _readReadmeContent(projectPath);
  moduleObj.LibraryName = libraryName;
  moduleObj.LibraryVersion = libraryVersion;

  moduleObj.AddLineToGitignore =
      await _collectLinesWithAddTag('$projectPath/.gitignore', '#@add');
  moduleObj.AddLineToGlobalImports = await _collectLinesWithAddTag(
      '$projectPath/lib/util/config/_/global_imports.dart', '//@add');
  moduleObj.AddLineToGitAttributes =
      await _collectLinesWithAddTag('$projectPath/.gitattributes', '#@add');
  moduleObj.Files = await _generateFilePathAndContentsList(libraryName,
      projectPath, await _findFilesInDirectoriesWithGitkeepForAdd(projectPath));

  moduleObj.PubspecCodeBloc = await _extractPubspecCodes(projectPath);

  return moduleObj;
}

Future<List<String>> _findFilesInDirectoriesWithGitkeepForAdd(
    String directoryPath) async {
  Directory directory = Directory(directoryPath);
  List<String> filesWithAddTag = [];

  // 비동기 재귀 함수로 디렉토리 내의 모든 .gitkeep 파일 탐색
  Future<void> searchGitkeepFiles(Directory dir, String basePath) async {
    await for (FileSystemEntity entity
        in dir.list(recursive: false, followLinks: false)) {
      if (entity is Directory) {
        // 하위 디렉토리를 재귀적으로 탐색
        await searchGitkeepFiles(entity, basePath);
      } else if (entity is File && entity.path.endsWith('.gitkeep')) {
        // .gitkeep 파일이면 내용의 첫 번째 라인만 확인
        String firstLine = await entity
            .readAsLines()
            .then((lines) => lines.isNotEmpty ? lines.first : '');
        if (firstLine.startsWith('@add')) {
          // 첫 번째 라인이 '@add'로 시작하면 해당하는 폴더 내의 모든 파일의 경로를 수집 (단, .gitkeep 파일은 제외)
          await for (FileSystemEntity fileEntity
              in entity.parent.list(recursive: false, followLinks: false)) {
            if (fileEntity is File && fileEntity.path != entity.path) {
              // .gitkeep 파일 자체는 제외
              String relativePath = path.relative(fileEntity.path, from: basePath);
              filesWithAddTag.add(relativePath);
            }
          }
        }
      }
    }
  }

  await searchGitkeepFiles(directory, directoryPath);

  return filesWithAddTag;
}

Future<List<String>> _collectLinesWithAddTag(
    String filePath, String filterKeyword) async {
  var file = File(filePath);
  var linesWithAddTag = <String>[];

  // 파일이 존재하는지 확인
  if (await file.exists()) {
    // 파일의 각 줄을 읽기
    var lines = await file.readAsLines();
    for (var line in lines) {
      // 줄 끝에 '@add' 태그가 있는지 확인
      if (line.trim().endsWith(filterKeyword)) {
        // '@add' 태그를 제거한 줄을 리스트에 추가
        linesWithAddTag.add(line.split(filterKeyword)[0].trim());
      }
    }
  } else {
    print('File not found: $filePath');
  }

  return linesWithAddTag;
}

List<String> _parseYamlList(YamlMap yamlContent, String key) {
  var list = yamlContent[key];
  if (list is YamlList) {
    return list.map((item) => item.toString()).toList();
  }
  return [];
}

Future<List<PubspecCode>> _extractPubspecCodes(String projectPath) async {
  File pubspecFile = File('$projectPath/pubspec.yaml');
  if (!await pubspecFile.exists()) {
    print("File does not exist: ${pubspecFile.path}");
    return [];
  }

  List<String> lines = await pubspecFile.readAsLines();
  List<PubspecCode> codes = [];
  bool isAddSection = false;
  String title = '';
  String codeBloc = '';

  for (String line in lines) {
    if (line.trim() == "#@add start") {
      // Reset for a new section
      isAddSection = true;
      title = '';
      codeBloc = '';
    } else if (line.trim() == "#@add end" && isAddSection) {
      // Only add if we are inside a section
      if (title.isNotEmpty && codeBloc.isNotEmpty) {
        codes.add(PubspecCode()..Title = title..CodeBloc = codeBloc.trim());
      }
      isAddSection = false; // Reset flag
    } else if (isAddSection) {
      // Accumulate lines and detect title if not set
      if (title.isEmpty && line.contains(':')) {
        title = line.split(':')[0].trim();
      } else {
        codeBloc += line + '\n';
      }
    }
  }
  return codes;
}