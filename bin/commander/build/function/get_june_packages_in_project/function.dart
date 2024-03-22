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
  print('copyPaths: $copyPaths');
  List<String> filteredCopyPaths = copyPaths.where((copyPath) {
    // 'lib/util'로 시작하는지 확인
    bool startsWithUtil = copyPath.startsWith('lib/util');
    // 경로 중간과 끝에 'libraryName'이 포함되어 있는지 확인 (더 넓은 범위를 위해 수정됨)
    bool containsLibraryName = copyPath.contains('/$libraryName');
    // 'assets/'로 시작하지 않는지 확인
    bool doesNotStartWithAssets = !copyPath.startsWith('assets/');
    // 파일 이름이 '.gitkeep'으로 끝나지 않는지 확인
    bool doesNotEndWithGitkeep = !copyPath.endsWith('.gitkeep');

    return doesNotStartWithAssets &&
        doesNotEndWithGitkeep &&
        (!startsWithUtil || (startsWithUtil && containsLibraryName));
  }).toList();

  List<FilePathAndContents> files = [];

  for (String relativePath in filteredCopyPaths) {
    String fullPath = path.join(projectPath, relativePath);
    FileSystemEntityType entityType =
        await FileSystemEntity.type(fullPath, followLinks: false);

    if (entityType == FileSystemEntityType.file) {
      File file = File(fullPath);
      String content = await file.readAsString();
      // 파일 내용의 첫 줄이 //@add 또는 #@add 로 시작하는 경우 그 줄을 제거
      List<String> lines = content.split('\n');
      if (lines.isNotEmpty &&
          (lines.first.startsWith('//@add') ||
              lines.first.startsWith('#@add'))) {
        lines.removeAt(0); // 첫 줄 제거
      }
      content = lines.join('\n'); // 수정된 내용으로 다시 합치기

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
          // 파일 내용의 첫 줄이 //@add 또는 #@add 로 시작하는 경우 그 줄을 제거
          List<String> lines = content.split('\n');
          if (lines.isNotEmpty &&
              (lines.first.startsWith('//@add') ||
                  lines.first.startsWith('#@add'))) {
            lines.removeAt(0); // 첫 줄 제거
          }
          content = lines.join('\n'); // 수정된 내용으로 다시 합치기

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

  // moduleObj.AddLineToGitignore =
  //     await _collectLinesWithAddTag('$projectPath/.gitignore', '#@add');
  moduleObj.AddLineToGlobalImports = await _collectLinesWithAddTag(
      '$projectPath/lib/util/config/_/global_imports.dart', '//@add');
  // moduleObj.AddLineToGitAttributes =
  //     await _collectLinesWithAddTag('$projectPath/.gitattributes', '#@add');
  moduleObj.Files = await _generateFilePathAndContentsList(libraryName,
      projectPath, await _findFilesInDirectoriesWithGitkeepForAdd(projectPath));

  moduleObj.PubspecCodeBloc = await _extractPubspecCodes(projectPath);

  return moduleObj;
}

Future<List<String>> _findFilesInDirectoriesWithGitkeepForAdd(
    String directoryPath) async {
  Directory directory = Directory(directoryPath);
  List<String> filesWithAddTag = [];

  Future<void> searchGitkeepFiles(Directory dir, String basePath) async {
    await for (FileSystemEntity entity
        in dir.list(recursive: false, followLinks: false)) {
      if (entity is Directory) {
        await searchGitkeepFiles(entity, basePath);
      } else if (entity is File) {
        try {
          String firstLine = await entity
              .readAsLines()
              .then((lines) => lines.isNotEmpty ? lines.first : '');
          if (entity.path.endsWith('.gitkeep')) {
            if (firstLine.startsWith('@add')) {
              await for (FileSystemEntity fileEntity
                  in entity.parent.list(recursive: false, followLinks: false)) {
                if (fileEntity is File && fileEntity.path != entity.path) {
                  String relativePath =
                      path.relative(fileEntity.path, from: basePath);
                  filesWithAddTag.add(relativePath);
                }
              }
            }
          } else {
            if (firstLine.startsWith('#@add') ||
                firstLine.startsWith('//@add')) {
              String relativePath = path.relative(entity.path, from: basePath);
              filesWithAddTag.add(relativePath);
            }
          }
        } catch (e) {
          // 파일 읽기 중 발생하는 에러를 잡아서 그냥 넘어갑니다. 처리를 계속합니다.
          print("Error reading file: ${entity.path}, error: $e");
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
        codes.add(PubspecCode()
          ..Title = title
          ..CodeBloc = codeBloc.trim());
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
