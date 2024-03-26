import 'dart:io';

import 'package:path/path.dart';

import 'function.dart';
import 'function/extract_impoers_and_exports/function.dart';
import 'function/find_files_with_june_view_annotations/function.dart';
import 'function/merge_files_in_same_directory/function.dart';

buildView() async {
  List<String> targetFilePaths =
      await findFilesWithJuneViewAnnotations(Directory.current.path);

  Map<String, Map<String, String>> mergedDirectoryContents =
      await mergeFilesInSameDirectory(targetFilePaths);


}

