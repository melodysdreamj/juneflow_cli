import 'dart:io';
import 'package:path/path.dart' as path;


String? getPackagePath(String packageName, String packageVersion) {
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
