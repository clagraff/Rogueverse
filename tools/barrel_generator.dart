// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  generateBarrels('lib');
}

void generateBarrels(String directory) {
  final dir = Directory(directory);
  final entities = dir.listSync();
  final dirName = path.basename(directory);

  // Get all Dart files in current directory (excluding existing barrel files)
  final dartFiles = entities
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !path.basename(file.path).contains('.gen.'))
      .where((file) => !path.basename(file.path).contains('.init.'))
      .where((file) => !path.basename(file.path).contains('.barrel.'))
      .where((file) => !path.basename(file.path).contains('.mapper.'))
      .toList();

  // Get all subdirectories
  final subdirs = entities
      .whereType<Directory>()
      .toList();

  // First, recursively process subdirectories
  for (var subdir in subdirs) {
    generateBarrels(subdir.path);
  }

  // Create exports for current directory's Dart files
  final fileExports = dartFiles
      .map((file) => "export '${path.basename(file.path)}';")
      .join('\n');

  // Create exports for subdirectories (pointing to their barrel files)
  final dirExports = subdirs
      .map((subdir) {
    final subdirName = path.basename(subdir.path);
    return "export '$subdirName/$subdirName.barrel.dart';";
  })
      .join('\n');

  // Combine exports and write barrel file if we have anything to export
  final allExports = [fileExports, dirExports].where((e) => e.isNotEmpty).join('\n\n');

  if (allExports.isNotEmpty) {
    // Skip generating a barrel file for the root 'lib' directory
    if (dirName != 'lib') {
      final barrelFile = File(path.join(directory, '$dirName.barrel.dart'));
      barrelFile.writeAsStringSync(allExports);
      print('Generated barrel file: ${barrelFile.path}');
    }
  }
}
