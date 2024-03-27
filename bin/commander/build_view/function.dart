import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';

import 'function.dart';
import 'function/apply_child_action_merged_contents/function.dart';
import 'function/apply_child_event_merged_contents/function.dart';
import 'function/apply_mother_action_merged_contents/function.dart';
import 'function/apply_mother_event_merged_contents/function.dart';
import 'function/extract_impoers_and_exports/function.dart';
import 'function/find_files_with_june_view_annotations/function.dart';
import 'function/merge_files_in_same_directory/function.dart';

buildView() async {
  Timer.periodic(Duration(seconds: 5), (Timer t) {
    _run();
  });
}

_run() async {
  print('Building view...');
  List<String> targetFilePaths =
      await findFilesWithJuneViewAnnotations(Directory.current.path);

  Map<String, Map<String, Map<String, String>>> mergedDirectoryContents =
      await mergeFilesInActionAndEventDirectories(targetFilePaths);

  // "action" 디렉토리의 병합 결과에 대한 처리
  if (mergedDirectoryContents.containsKey('action')) {
    await applyChildActionMergedContents(mergedDirectoryContents['action']!);
    await applyMotherActionMergedContents(mergedDirectoryContents['action']!);
  }

  // "event" 디렉토리의 병합 결과에 대한 처리
  if (mergedDirectoryContents.containsKey('event')) {
    await applyChildEventMergedContents(mergedDirectoryContents['event']!);
    await applyMotherEventMergedContents(mergedDirectoryContents['event']!);
  }
  print('View built successfully!');
}