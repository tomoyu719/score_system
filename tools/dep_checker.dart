import 'dart:io';

import 'package:yaml/yaml.dart';

const _allowedDeps = <String, Set<String>>{
  'score_core': {},
  'score_layout': {'score_core'},
  'score_io': {'score_core'},
  'score_cli': {'score_core', 'score_layout', 'score_io'},
  'score_tui': {'score_core', 'score_layout', 'score_io'},
  'score_mcp': {'score_core', 'score_layout', 'score_io'},
  'score_flutter': {'score_core', 'score_layout'},
};

void main() {
  final violations = <String>[];

  for (final entry in _allowedDeps.entries) {
    final packageName = entry.key;
    final allowed = entry.value;
    final pubspecFile = File('packages/$packageName/pubspec.yaml');

    if (!pubspecFile.existsSync()) continue;

    final content = pubspecFile.readAsStringSync();
    final yaml = loadYaml(content) as YamlMap;

    for (final section in ['dependencies', 'dev_dependencies']) {
      final depsMap = yaml[section] as YamlMap?;
      if (depsMap == null) continue;
      for (final key in depsMap.keys) {
        final name = key as String;
        if (!name.startsWith('score_')) continue;
        if (!allowed.contains(name)) {
          violations.add('$packageName illegally depends on $name');
        }
      }
    }
  }

  _checkNoIoImports('packages/score_core/lib', violations);

  if (violations.isNotEmpty) {
    for (final v in violations) {
      stderr.writeln('VIOLATION: $v');
    }
    exit(1);
  }

  print('Dependency boundary check passed.');
}

void _checkNoIoImports(String dir, List<String> violations) {
  final directory = Directory(dir);
  if (!directory.existsSync()) return;

  for (final entity in directory.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final content = entity.readAsStringSync();
    if (content.contains("import 'dart:io'") ||
        content.contains('import "dart:io"')) {
      violations.add('${entity.path} imports dart:io (forbidden in score_core)');
    }
  }
}
