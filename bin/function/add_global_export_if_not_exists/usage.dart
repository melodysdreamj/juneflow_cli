import 'function.dart';

void main() {
  const filePath = 'util/global_imports.dart';
  const exportPath = 'new/package/path.dart';

  addExportIfNotExists(filePath, exportPath).then((_) => print('Done'));
}
