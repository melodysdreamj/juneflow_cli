import 'function.dart';

main() async {
  await cloneAndRemoveGit(
      'https://github.com/melodysdreamj/juneflow.git', 'module_template', 'exampleRepo');
}
