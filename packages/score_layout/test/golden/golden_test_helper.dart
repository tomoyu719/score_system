import 'dart:convert';
import 'dart:io';

import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

/// Compares [tree]'s JSON against the golden file at
/// `test/golden/layout/<name>.golden.json`.
///
/// Set the `UPDATE_GOLDENS` environment variable to `'1'` to regenerate the
/// golden files instead of comparing:
///
/// ```sh
/// UPDATE_GOLDENS=1 dart test test/golden/
/// ```
void expectMatchesGolden(String name, LayoutTree tree) {
  const encoder = JsonEncoder.withIndent('  ');
  final actualJson = encoder.convert(tree.toJson());
  final goldenFile = File('test/golden/layout/$name.golden.json');

  if (Platform.environment['UPDATE_GOLDENS'] == '1') {
    goldenFile
      ..createSync(recursive: true)
      ..writeAsStringSync('$actualJson\n');
    return;
  }

  if (!goldenFile.existsSync()) {
    fail(
      'Golden file not found: ${goldenFile.path}\n'
      'Run with UPDATE_GOLDENS=1 to generate it.',
    );
  }
  final expected = goldenFile.readAsStringSync();
  expect('$actualJson\n', equals(expected),
      reason: 'LayoutTree JSON does not match golden: ${goldenFile.path}');
}
