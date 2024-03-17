// import 'dart:io';
// import 'dart:mirrors';
//
// void main(List<String> arguments) {
//   print('Welcome to the June Project/Module Creator!');
//   getUserInputForProjectCreation();
// }
//
// class CreationResult {
//   final String? type;
//   final String? name;
//   final String? packageName;
//
//   CreationResult({this.type, this.name, this.packageName});
// }
//
// CreationResult? getUserInputForProjectCreation() {
//   String type = 'skeleton'; // Default value
//   while (true) {
//     print(
//         'What are you creating? (Press Enter for default, type "cancel" to exit)');
//     print('1. Skeleton project(default)');
//     print('2. Module project');
//     String? typeSelection = stdin.readLineSync();
//     if (typeSelection?.toLowerCase() == 'cancel') {
//       print('Operation cancelled.');
//       return null;
//     }
//     switch (typeSelection) {
//       case '1':
//         type = 'skeleton';
//         break;
//       case '2':
//         type = 'module';
//         break;
//       case '':
//         print('Default selection [1. Skeleton project] is used.');
//         break;
//       default:
//         print(
//             'Invalid selection. Please enter 1 for Skeleton project, 2 for Module or "cancel" to exit.');
//         continue;
//     }
//     break;
//   }
//
//   CreationResult? result;
//   if (type == 'module') {
//     result = createModule();
//   } else {
//     result = createProject(type);
//   }
//
//   if (result != null) {
//     printSuccessMessage(
//         result.type ?? 'Skeleton', result.name, result.packageName);
//     print('The $type has been created successfully!');
//     return result;
//   } else {
//     print('The $type creation has been cancelled.');
//   }
//   return null;
// }
//
// CreationResult? createProject(String type) {
//   String? name = getName(type);
//   if (name == null) return null; // Operation was cancelled.
//
//   String? packageName = getPackageName(type);
//   if (packageName == null) return null; // Operation was cancelled.
//
//   return CreationResult(type: type, name: name, packageName: packageName);
// }
//
// CreationResult? createModule() {
//   String? name = getName('module');
//   if (name == null) return null; // Operation was cancelled.
//   return CreationResult(type: 'module', name: name);
// }
//
// String? getName(String type) {
//   String? name;
//   while (true) {
//     print(
//         'Enter the name for your $type (e.g., my_app), or type "cancel" to exit:');
//     print(
//         'The name should be all lowercase and may include underscores (_) to separate words.');
//     name = stdin.readLineSync();
//     if (name?.toLowerCase() == 'cancel') {
//       print('Operation cancelled.');
//       return null;
//     } else if (!isValidProjectName(name)) {
//       print(
//           'Error: The project name must be all lowercase, including underscores to separate words, and cannot start with a digit. Please try again.');
//       continue;
//     }
//     break;
//   }
//   return name;
// }
//
// String? getPackageName(String type) {
//   String? packageName;
//   while (true) {
//     print(
//         'Enter the package name for your $type (e.g., com.example.myapp), or type "cancel" to exit:');
//     packageName = stdin.readLineSync();
//     if (packageName?.toLowerCase() == 'cancel') {
//       print('Operation cancelled.');
//       return null;
//     } else if (!isValidPackageName(packageName)) {
//       print(
//           'Error: The package name must be a valid domain name in reverse domain name notation, consisting of at least three segments separated by dots, and all lowercase. Please try again.');
//       continue;
//     }
//     break;
//   }
//   return packageName;
// }
//
// printSuccessMessage(String type, String? name, String? packageName) {
//   print('\nCongratulations! Your $type has been created successfully!');
//   print('Project/Module name: $name');
//   if (packageName != null) {
//     print('Package name: $packageName');
//   }
// }
//
// bool isValidProjectName(String? name) {
//   return name != null && RegExp(r'^[a-z_][a-z0-9_]*$').hasMatch(name);
// }
//
// bool isValidPackageName(String? packageName) {
//   return packageName != null &&
//       RegExp(r'^[a-z]+(\.[a-z0-9]+){2,}$').hasMatch(packageName);
// }
