import 'dart:io';

Future<void> applyTempDirToProject() async {
  Directory tempDir = Directory('.tempDir');
  if (await tempDir.exists()) {
    await for (var element in tempDir.list(recursive: true)) {
      if (element is File) {
        String newPath = p.join(p.dirname(element.path), p.basename(element.path).replaceAll('.tempDir', ''));
        File newFile = File(newPath);
        if (await newFile.exists()) {
          continue;
        }
        await newFile.create(recursive: true);
        await newFile.writeAsString(await element.readAsString());
      }
    }
    await tempDir.delete(recursive: true);  // 주의: 실제 사용시 이 부분의 주석을 해제해야 합니다.
  }
}

