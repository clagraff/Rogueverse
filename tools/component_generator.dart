// generator.dart
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:args/args.dart';

// dart run ./tools/component_generator.dart --schema ./tools/components.yaml --output lib/src/engine/
void main(List<String> args) {
  final parser = ArgParser()
    ..addOption('schema', abbr: 's', help: 'Path to schema YAML file')
    ..addOption('output', abbr: 'o', help: 'Output directory for generated files')
    ..addFlag('help', abbr: 'h', help: 'Show usage information', negatable: false);

  try {
    final results = parser.parse(args);

    if (results['help']) {
      printUsage(parser);
      exit(0);
    }

    final schemaFile = results['schema'];
    final outputDir = results['output'];

    if (schemaFile == null || outputDir == null) {
      print('Error: Missing required arguments');
      printUsage(parser);
      exit(1);
    }

    generateCode(schemaFile, outputDir);
    print('Code generation completed successfully!');

  } catch (e) {
    print('Error: $e');
    printUsage(parser);
    exit(1);
  }
}

void printUsage(ArgParser parser) {
  print('Usage: dart generator.dart --schema <schema_file> --output <output_dir>');
  print(parser.usage);
}

void generateCode(String schemaFile, String outputDir) {
  // Ensure output directory exists
  final dir = Directory(outputDir);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  final yamlString = File(schemaFile).readAsStringSync();
  final schema = loadYaml(yamlString);

  final config = schema['config'] as YamlMap;
  final discriminatorField = config['discriminatorField'] as String;

  final modelsContent = generateModels(schema, discriminatorField);
  File('$outputDir/models.dart').writeAsStringSync(modelsContent);
}

String generateModels(dynamic schema, String discriminatorField) {
  final buffer = StringBuffer();
  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  buffer.writeln();
  buffer.writeln("import 'dart:convert';");
  buffer.writeln();

  // Generate classes
  final classes = schema['classes'] as YamlMap;

  for (final entry in classes.entries) {
    final className = entry.key;
    final classData = entry.value as YamlMap;
    final fields = classData['fields'] as YamlMap? ?? YamlMap();
    final parent = classData['extends'];
    final description = classData['description'] as String?;

    if (description != null) {
      buffer.writeln('/// $description');
    }
    buffer.writeln('class $className${parent != null ? ' extends $parent' : ''} {');

    // Fields
    for (final field in fields.entries) {
      final fieldName = field.key;
      final fieldData = field.value as YamlMap;
      final fieldType = fieldData['type'];
      final defaultValue = fieldData['default'];
      final fieldDescription = fieldData['description'] as String?;

      // Field is final if no default value is specified
      final isFinal = defaultValue == null;

      if (fieldDescription != null) {
        buffer.writeln('  /// $fieldDescription');
      }

      buffer.writeln('  ${isFinal ? 'final ' : ''}$fieldType $fieldName;');
    }

    if (fields.isNotEmpty) {
      buffer.writeln();
    }

    // Constructor
    if (fields.isEmpty && parent == null) {
      // Empty class with no parent - use simple constructor
      buffer.writeln('  const $className();');
    } else if (fields.isEmpty && parent != null) {
      // Empty class with parent - forward to super
      // Removed const keyword to fix the error
      buffer.writeln('  $className({');
      buffer.write(getParentParams(schema, parent));
      buffer.writeln('  });');
    } else {
      // Class with fields
      buffer.writeln('  $className({');

      // Track fields that need initialization in the constructor body
      final initInBody = <String, String>{};

      for (final field in fields.entries) {
        final fieldName = field.key;
        final fieldData = field.value as YamlMap;
        final fieldType = fieldData['type'].toString();
        final defaultValue = fieldData['default'];

        // Field is final if no default value is specified
        final isFinal = defaultValue == null;

        // Handle collections and non-constant defaults
        if (fieldType.startsWith('List<') || fieldType.startsWith('Map<')) {
          if (defaultValue != null && defaultValue != '{}' && defaultValue != '[]') {
            // Use the provided default
            buffer.writeln('    this.$fieldName = $defaultValue,');
          } else {
            // For collections, use nullable parameter and initialize in body
            buffer.writeln('    ${fieldType}? $fieldName,');

            // Default empty collection based on type
            final emptyValue = fieldType.startsWith('List') ? '[]' : '{}';
            initInBody[fieldName] = emptyValue;
          }
        } else if (defaultValue != null) {
          // Simple scalar with default
          buffer.writeln('    this.$fieldName = $defaultValue,');
        } else {
          // Required field
          buffer.writeln('    required this.$fieldName,');
        }
      }

      // Add super parameters if needed
      if (parent != null) {
        buffer.write('    ${getParentParams(schema, parent)}');
      }

      // Close parameters and add initializer list if needed
      if (initInBody.isNotEmpty) {
        buffer.writeln('  })');
        buffer.write('      : ');

        var first = true;
        for (final entry in initInBody.entries) {
          if (!first) buffer.write(',\n        ');
          buffer.write('${entry.key} = ${entry.key} ?? ${entry.value}');
          first = false;
        }

        buffer.writeln(';');
      } else {
        buffer.writeln('  });');
      }
    }

    // Only generate these methods if the class has fields or a parent with fields
    final hasFields = fields.isNotEmpty || (parent != null && hasParentFields(schema, parent));

    if (hasFields) {
      // Add toJson method
      buffer.writeln();
      buffer.writeln('  Map<String, dynamic> toJson() {');
      buffer.writeln('    final json = <String, dynamic>{');
      buffer.writeln('      \'$discriminatorField\': \'$className\',');

      for (final field in fields.entries) {
        final fieldName = field.key;
        buffer.writeln('      \'$fieldName\': $fieldName,');
      }

      buffer.writeln('    };');

      if (parent != null) {
        buffer.writeln('    // Add parent fields');
        buffer.writeln('    final parentJson = super.toJson();');
        buffer.writeln('    parentJson.remove(\'$discriminatorField\'); // Avoid duplicate type field');
        buffer.writeln('    json.addAll(parentJson);');
      }

      buffer.writeln('    return json;');
      buffer.writeln('  }');

      // Add fromJson static method
      buffer.writeln();
      buffer.writeln('  static $className fromJson(Map<String, dynamic> json) {');
      buffer.writeln('    return $className(');
      for (final field in fields.entries) {
        final fieldName = field.key;
        final fieldData = field.value as YamlMap;
        final fieldType = fieldData['type'];

        if (fieldType.toString().startsWith('List<')) {
          buffer.writeln('      $fieldName: (json[\'$fieldName\'] as List).cast<${fieldType.toString().substring(5, fieldType.toString().length - 1)}>(),');
        } else if (fieldType.toString().startsWith('Map<')) {
          buffer.writeln('      $fieldName: json[\'$fieldName\'] as $fieldType,');
        } else {
          buffer.writeln('      $fieldName: json[\'$fieldName\'] as $fieldType,');
        }
      }

      // Add parent fields
      if (parent != null) {
        buffer.write('      ${getParentJsonParams(schema, parent)}');
      }

      buffer.writeln('    );');
      buffer.writeln('  }');

      // Add copyWith method
      buffer.writeln();
      buffer.writeln('  $className copyWith({');
      for (final field in fields.entries) {
        final fieldName = field.key;
        final fieldData = field.value as YamlMap;
        final fieldType = fieldData['type'];
        buffer.writeln('    $fieldType? $fieldName,');
      }

      if (parent != null) {
        buffer.write('    ${getParentCopyWithParams(schema, parent)}');
      }

      buffer.writeln('  }) {');
      buffer.writeln('    return $className(');
      for (final field in fields.entries) {
        final fieldName = field.key;
        buffer.writeln('      $fieldName: $fieldName ?? this.$fieldName,');
      }

      if (parent != null) {
        buffer.write('      ${getParentCopyWithArgs(schema, parent)}');
      }

      buffer.writeln('    );');
      buffer.writeln('  }');

      // Add clone method
      buffer.writeln();
      buffer.writeln('  $className clone() => $className(');
      for (final field in fields.entries) {
        final fieldName = field.key;
        buffer.writeln('    $fieldName: $fieldName,');
      }

      // Add parent fields to clone
      if (parent != null) {
        buffer.write('    ${getParentCloneParams(schema, parent)}');
      }

      buffer.writeln('  );');
    } else {
      // For empty classes, just add minimal toJson and fromJson
      buffer.writeln();
      buffer.writeln('  Map<String, dynamic> toJson() {');
      buffer.writeln('    return {\'$discriminatorField\': \'$className\'};');
      buffer.writeln('  }');

      buffer.writeln();
      buffer.writeln('  static $className fromJson(Map<String, dynamic> json) {');
      buffer.writeln('    return $className();');
      buffer.writeln('  }');
    }

    // Override toString for all classes
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  String toString() {');
    if (fields.isEmpty && (parent == null || !hasParentFields(schema, parent))) {
      buffer.writeln('    return \'$className{}\';');
    } else {
      buffer.writeln('    return \'$className{\'');

      if (parent != null) {
        buffer.writeln('      \'${getParentToStringFields(schema, parent)}\'');
      }

      var isFirst = parent == null;
      for (final field in fields.entries) {
        final fieldName = field.key;
        if (isFirst) {
          buffer.writeln('      \'$fieldName: \$$fieldName\'');
          isFirst = false;
        } else {
          buffer.writeln('      \', $fieldName: \$$fieldName\'');
        }
      }

      buffer.writeln('      \'}\';');
    }
    buffer.writeln('  }');

    // Override equals for all classes
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  bool operator ==(Object other) {');
    buffer.writeln('    if (identical(this, other)) return true;');
    buffer.writeln('    if (other.runtimeType != runtimeType) return false;');

    if (fields.isEmpty && (parent == null || !hasParentFields(schema, parent))) {
      buffer.writeln('    return other is $className;');
    } else {
      buffer.writeln('    return other is $className');

      if (parent != null) {
        buffer.writeln('      && super == other');
      }

      for (final field in fields.entries) {
        final fieldName = field.key;
        final fieldData = field.value as YamlMap;
        final fieldType = fieldData['type'].toString();

        if (fieldType.startsWith('List<') || fieldType.startsWith('Map<')) {
          // Deep equality for collections
          buffer.writeln('      && _deepEquals($fieldName, other.$fieldName)');
        } else {
          buffer.writeln('      && $fieldName == other.$fieldName');
        }
      }

      buffer.writeln('    ;');
    }
    buffer.writeln('  }');

    // Override hashCode for all classes
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  int get hashCode {');

    if (fields.isEmpty && (parent == null || !hasParentFields(schema, parent))) {
      buffer.writeln('    return runtimeType.hashCode;');
    } else if (parent != null && fields.isNotEmpty) {
      buffer.writeln('    return Object.hash(');
      buffer.writeln('      super.hashCode,');

      final fieldsList = fields.entries.toList();
      for (var i = 0; i < fieldsList.length; i++) {
        final fieldName = fieldsList[i].key;
        if (i < fieldsList.length - 1) {
          buffer.writeln('      $fieldName,');
        } else {
          buffer.writeln('      $fieldName');
        }
      }

      buffer.writeln('    );');
    } else if (parent != null) {
      buffer.writeln('    return super.hashCode;');
    } else if (fields.length == 1) {
      final fieldName = fields.entries.first.key;
      buffer.writeln('    return $fieldName.hashCode;');
    } else if (fields.length > 1) {
      buffer.writeln('    return Object.hash(');

      final fieldsList = fields.entries.toList();
      for (var i = 0; i < fieldsList.length; i++) {
        final fieldName = fieldsList[i].key;
        if (i < fieldsList.length - 1) {
          buffer.writeln('      $fieldName,');
        } else {
          buffer.writeln('      $fieldName');
        }
      }

      buffer.writeln('    );');
    } else {
      buffer.writeln('    return runtimeType.hashCode;');
    }
    buffer.writeln('  }');

    buffer.writeln('}');
    buffer.writeln();
  }

  // Add ModelFactory at the end of the file
  buffer.writeln('/// Factory for creating components from JSON data');
  buffer.writeln('class ModelFactory {');

  // fromJson method
  buffer.writeln('  /// Creates a component instance from a JSON map');
  buffer.writeln('  /// The component type is determined by the \'$discriminatorField\' field');
  buffer.writeln('  static dynamic fromJson(Map<String, dynamic> json) {');
  buffer.writeln('    final type = json[\'$discriminatorField\'] as String;');
  buffer.writeln('    switch (type) {');

  for (final entry in classes.entries) {
    final className = entry.key;
    buffer.writeln('      case \'$className\':');
    buffer.writeln('        return $className.fromJson(json);');
  }

  buffer.writeln('      default:');
  buffer.writeln('        throw Exception(\'Unknown type: \$type\');');
  buffer.writeln('    }');
  buffer.writeln('  }');
  buffer.writeln();

  // fromJsonString method
  buffer.writeln('  /// Creates a component instance from a JSON string');
  buffer.writeln('  static dynamic fromJsonString(String jsonString) {');
  buffer.writeln('    final json = jsonDecode(jsonString) as Map<String, dynamic>;');
  buffer.writeln('    return fromJson(json);');
  buffer.writeln('  }');
  buffer.writeln();

  buffer.writeln('}');
  buffer.writeln();

  // Add helper method for deep equality
  buffer.writeln('// Helper method for deep equality of collections');
  buffer.writeln('bool _deepEquals(dynamic a, dynamic b) {');
  buffer.writeln('  if (a is List && b is List) {');
  buffer.writeln('    if (a.length != b.length) return false;');
  buffer.writeln('    for (var i = 0; i < a.length; i++) {');
  buffer.writeln('      if (!_deepEquals(a[i], b[i])) return false;');
  buffer.writeln('    }');
  buffer.writeln('    return true;');
  buffer.writeln('  } else if (a is Map && b is Map) {');
  buffer.writeln('    if (a.length != b.length) return false;');
  buffer.writeln('    for (final key in a.keys) {');
  buffer.writeln('      if (!b.containsKey(key)) return false;');
  buffer.writeln('      if (!_deepEquals(a[key], b[key])) return false;');
  buffer.writeln('    }');
  buffer.writeln('    return true;');
  buffer.writeln('  } else {');
  buffer.writeln('    return a == b;');
  buffer.writeln('  }');
  buffer.writeln('}');

  return buffer.toString();
}

bool hasParentFields(dynamic schema, String parentName) {
  final parentClass = schema['classes'][parentName];
  if (parentClass == null) return false;

  final parentFields = parentClass['fields'] as YamlMap? ?? YamlMap();
  final parentOfParent = parentClass['extends'];

  return parentFields.isNotEmpty || (parentOfParent != null && hasParentFields(schema, parentOfParent));
}

String getParentParams(dynamic schema, String parentName) {
  final parentClass = schema['classes'][parentName];
  if (parentClass == null) return '';

  final parentFields = parentClass['fields'] as YamlMap? ?? YamlMap();
  final parentOfParent = parentClass['extends'];

  final buffer = StringBuffer();

  for (final field in parentFields.entries) {
    final fieldName = field.key;
    final fieldData = field.value as YamlMap;
    final defaultValue = fieldData['default'];

    if (defaultValue != null) {
      buffer.writeln('    super.$fieldName = $defaultValue,');
    } else {
      buffer.writeln('    required super.$fieldName,');
    }
  }

  if (parentOfParent != null) {
    buffer.write(getParentParams(schema, parentOfParent));
  }

  return buffer.toString();
}

String getParentJsonParams(dynamic schema, String parentName) {
  final parentClass = schema['classes'][parentName];
  if (parentClass == null) return '';

  final parentFields = parentClass['fields'] as YamlMap? ?? YamlMap();
  final parentOfParent = parentClass['extends'];

  final buffer = StringBuffer();

  for (final field in parentFields.entries) {
    final fieldName = field.key;
    final fieldData = field.value as YamlMap;
    final fieldType = fieldData['type'];

    if (fieldType.toString().startsWith('List<')) {
      buffer.write('$fieldName: (json[\'$fieldName\'] as List).cast<${fieldType.toString().substring(5, fieldType.toString().length - 1)}>(), ');
    } else if (fieldType.toString().startsWith('Map<')) {
      buffer.write('$fieldName: json[\'$fieldName\'] as $fieldType, ');
    } else {
      buffer.write('$fieldName: json[\'$fieldName\'] as $fieldType, ');
    }
  }

  if (parentOfParent != null) {
    buffer.write(getParentJsonParams(schema, parentOfParent));
  }

  return buffer.toString();
}

String getParentCloneParams(dynamic schema, String parentName) {
  final parentClass = schema['classes'][parentName];
  if (parentClass == null) return '';

  final parentFields = parentClass['fields'] as YamlMap? ?? YamlMap();

  final buffer = StringBuffer();

  for (final field in parentFields.entries) {
    final fieldName = field.key;
    buffer.write('$fieldName: super.$fieldName, ');
  }

  return buffer.toString();
}

String getParentToStringFields(dynamic schema, String parentName) {
  final parentClass = schema['classes'][parentName];
  if (parentClass == null) return '';

  final parentFields = parentClass['fields'] as YamlMap? ?? YamlMap();
  final parentOfParent = parentClass['extends'];

  final buffer = StringBuffer();

  if (parentOfParent != null) {
    buffer.write(getParentToStringFields(schema, parentOfParent));
    if (parentFields.isNotEmpty) {
      buffer.write(', ');
    }
  }

  var isFirst = parentOfParent == null;
  for (final field in parentFields.entries) {
    final fieldName = field.key;
    if (isFirst) {
      buffer.write('$fieldName: \$$fieldName');
      isFirst = false;
    } else {
      buffer.write(', $fieldName: \$$fieldName');
    }
  }

  return buffer.toString();
}

String getParentCopyWithParams(dynamic schema, String parentName) {
  final parentClass = schema['classes'][parentName];
  if (parentClass == null) return '';

  final parentFields = parentClass['fields'] as YamlMap? ?? YamlMap();
  final parentOfParent = parentClass['extends'];

  final buffer = StringBuffer();

  for (final field in parentFields.entries) {
    final fieldName = field.key;
    final fieldData = field.value as YamlMap;
    final fieldType = fieldData['type'];

    buffer.write('$fieldType? $fieldName, ');
  }

  if (parentOfParent != null) {
    buffer.write(getParentCopyWithParams(schema, parentOfParent));
  }

  return buffer.toString();
}

String getParentCopyWithArgs(dynamic schema, String parentName) {
  final parentClass = schema['classes'][parentName];
  if (parentClass == null) return '';

  final parentFields = parentClass['fields'] as YamlMap? ?? YamlMap();

  final buffer = StringBuffer();

  for (final field in parentFields.entries) {
    final fieldName = field.key;
    buffer.write('$fieldName: $fieldName ?? super.$fieldName, ');
  }

  return buffer.toString();
}
