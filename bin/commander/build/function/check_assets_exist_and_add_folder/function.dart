import 'dart:io';
import 'package:path/path.dart' as p;

import '../../../../entity/model/module/model.dart';

Future<Module> checkAssetsHandler(Module moduleObj, String moduleAssetsPaths) async {
  // 1. 해당 위치에 별도의 파일이 존재하는지 체크
  if(await _isExistAssetInDirectory(moduleAssetsPaths)) {

    // 2. 재귀적으로 검사하면서 모든 디렉토리 검사해서 목록으로 만들어두기
    List<String> directories = await _findAllDirectoriesRelative(moduleAssetsPaths);
    for(String directory in directories) {
      moduleObj.AddLineToPubspecAssetsBlock.add(directory);
    }


    이제 해야할거는 임시폴더를 만들고 거기에 모든파일을 넣어두는것.

  }

  return moduleObj;
}


// 디렉토리 내에 .gitkeep 외에 다른 파일이나 폴더가 없는지 확인
Future<bool> _isExistAssetInDirectory(String directoryPath) async {
  // Directory 객체 생성
  final directory = Directory(directoryPath);

  // 디렉토리가 존재하는지 확인
  if (!await directory.exists()) {
    print('Directory does not exist.');
    return false;
  }

  // 디렉토리 내의 모든 항목을 async* 스트림으로 반환
  await for (final entity in directory.list()) {
    // entity가 파일이면서 .gitkeep가 아닌 경우 true 반환
    if (entity is File && !entity.path.endsWith('/.gitkeep')) {
      return true;
    }
    // entity가 디렉토리인 경우(하위 디렉토리 탐색은 여기서 수행하지 않음)
    if (entity is Directory) {
      return true;
    }
  }

  // .gitkeep 이외에 다른 파일이나 폴더가 없는 경우 false 반환
  return false;
}

Future<List<String>> _findAllDirectoriesRelative(String assetFolderPath) async {
  String basePath = '${Directory.current.path}/$assetFolderPath';
  Directory baseDir = Directory(basePath);
  List<String> directories = [assetFolderPath];

  if (!(await baseDir.exists())) {
    print('The specified base path does not exist.');
    return directories;
  }

  await for (var entity in baseDir.list(recursive: true, followLinks: false)) {
    if (entity is Directory) {
      // 절대 경로로부터 basePath 까지의 상대 경로를 계산
      String relativePath = p.relative(entity.path, from: basePath);
      directories.add('$assetFolderPath/$relativePath');
    }
  }

  return directories;
}
