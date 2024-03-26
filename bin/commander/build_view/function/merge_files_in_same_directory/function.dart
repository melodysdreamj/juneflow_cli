import 'dart:io';

import '../extract_impoers_and_exports/function.dart';

Future<Map<String, Map<String, String>>> mergeFilesInSameDirectory(
    List<String> filePaths) async {
  Map<String, List<String>> directoryFilesMap = {};
  Map<String, Map<String, String>> mergedResults = {};

  // 파일 경로를 바탕으로 디렉토리별 파일 리스트 생성
  for (var filePath in filePaths) {
    var file = File(filePath);
    var directory = file.parent.path;
    directoryFilesMap.putIfAbsent(directory, () => []);
    directoryFilesMap[directory]!.add(filePath);
  }

  // 디렉토리별로 파일 내용 분석 및 병합
  for (var directory in directoryFilesMap.keys) {
    List<String> importsExports = [];
    List<String> codes = [];

    for (var filePath in directoryFilesMap[directory]!) {
      String fileContent = await File(filePath).readAsString();
      var extracted = extractImportsAndExports(fileContent);

      extracted['imports_exports']!.split('\n').forEach((importExportLine) {
        if (!importsExports.contains(importExportLine) &&
            importExportLine.isNotEmpty) {
          importsExports.add(importExportLine);
        }
      });

      codes.add(extracted['code']!);
    }

    mergedResults[directory] = {
      'imports_exports': importsExports.join('\n'),
      'code': codes.join('\n\n')
    };
  }

  return mergedResults;
}
