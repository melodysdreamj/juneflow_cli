import 'dart:io';
import 'package:path/path.dart' as p;

Future<void> applyTempDirToProject() async {
  Directory tempDir = Directory('.tempDir');
  if (await tempDir.exists()) {
    print("Temp directory exists.");
    await for (var element in tempDir.list(recursive: true)) {
      print("Processing: ${element.path}"); // 현재 처리 중인 파일 경로 출력
      if (element is File) {
        String newPath = p.join(p.dirname(element.path), p.basename(element.path).replaceAll('.tempDir', ''));
        print("New path: $newPath"); // 새 파일 경로 출력
        File newFile = File(newPath);
        if (await newFile.exists()) {
          print("File already exists and will be skipped: $newPath");
          continue;
        }
        await newFile.create(recursive: true);
        await newFile.writeAsString(await element.readAsString());
        print("File created and written: $newPath");
      }
    }
    print("All files processed, considering deleting .tempDir");
    // await tempDir.delete(recursive: true);  // 주의: 실제 사용시 이 부분의 주석을 해제해야 합니다.
  } else {
    print("Temp directory does not exist.");
  }
}
