import 'dart:io';

void main(List<String> arguments) {
  print('Welcome to the June Project/Module Creator!');
  createProjectOrModule();
}

void createProjectOrModule() {
  String type = 'app'; // Default value
  while (true) {
    print('[Step 1 of 3] What are you creating? (Press Enter for default [1. App], type "cancel" to exit)');
    print('1. App(default)');
    print('2. Module');
    String? typeSelection = stdin.readLineSync();
    if (typeSelection?.toLowerCase() == 'cancel') {
      print('Operation cancelled.');
      return;
    }
    switch (typeSelection) {
      case '1':
        type = 'app';
        break;
      case '2':
        type = 'module';
        break;
      case '':
        print('Default selection [1. App] is used.');
        break;
      default:
        print('Invalid selection. Please enter 1 for App, 2 for Module or "cancel" to exit.');
        continue;
    }
    break;
  }

  String? name;
  while (true) {
    print('[Step 2 of 3] Enter the name for your $type (e.g., my_app), or type "cancel" to exit:');
    print('The name should be all lowercase and may include underscores (_) to separate words.');
    name = stdin.readLineSync();
    if (name?.toLowerCase() == 'cancel') {
      print('Operation cancelled.');
      return;
    } else if (!isValidProjectName(name)) {
      print('Error: The project name must be all lowercase, including underscores to separate words, and cannot start with a digit. Please try again.');
      continue;
    }
    break;
  }

  String? packageName;
  while (true) {
    print('[Step 3 of 3] Enter the package name for your $type (e.g., com.example.myapp), or type "cancel" to exit:');
    print('The package name must consist of lowercase letters and numbers only, separated by dots (.).');
    print('It should be at least three segments long, like a reversed domain name (no dashes, underscores, or spaces).');
    packageName = stdin.readLineSync();
    if (packageName?.toLowerCase() == 'cancel') {
      print('Operation cancelled.');
      return;
    } else if (!isValidPackageName(packageName)) {
      print('Error: The package name must be a valid domain name in reverse domain name notation, consisting of at least three segments separated by dots, and all lowercase. Please try again.');
      continue;
    }
    break;
  }

  // 프로젝트/모듈 생성 로직...
  print('\nCongratulations! Your $type has been created successfully!');
  print('Project/Module name: $name');
  print('Package name: $packageName');
  print('You can now navigate to the project/module directory and start coding.');
}

bool isValidProjectName(String? name) {
  return name != null && RegExp(r'^[a-z_][a-z0-9_]*$').hasMatch(name);
}

bool isValidPackageName(String? packageName) {
  return packageName != null && RegExp(r'^[a-z]+(\.[a-z0-9]+){2,}$').hasMatch(packageName);
}
