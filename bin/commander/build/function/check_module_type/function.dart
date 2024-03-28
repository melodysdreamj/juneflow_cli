import 'dart:io';

import '../../../../entity/enum/project_type/enum.dart';
import '../../../../entity/model/module/model.dart';

Future<Module> checkModuleType(String packagePath, Module moduleObj) async {

  File info = File('$packagePath/info.june');

  // 첫번째 줄이 project면 project타입, module이면 module 타입, view면 view타입이고 없으면 에러 발생
  if (!await info.exists()) {
    throw Exception('info.june file not found : $packagePath');
  }

  List<String> lines = await info.readAsLines();

  if (lines.isEmpty) {
    throw Exception('info.june file is empty : $packagePath');
  }

  String type = lines[0];

  if (type == 'project') {
    moduleObj.Type = ProjectTypeEnum.Skeleton;
  } else if(type == 'june-view project') {
    moduleObj.Type = ProjectTypeEnum.JuneViewProject;
  } else if(type == 'module') {
    moduleObj.Type = ProjectTypeEnum.ModuleTemplate;
  } else if(type == 'view') {
    moduleObj.Type = ProjectTypeEnum.ViewTemplate;
  } else {
    throw Exception('info.june file is invalid');
  }

  return moduleObj;
}