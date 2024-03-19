import '../../../../singleton/build_info/model.dart';
import '../get_june_packages_in_project/function.dart';

buildApp() async {
  await getJuneFlowPackagesInProject();

  print(BuildInfo.instance.ModuleList);
}