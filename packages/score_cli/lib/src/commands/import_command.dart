import 'dart:io';

import 'package:args/args.dart';
import 'package:score_io/score_io.dart';

import '../output.dart';

/// Imports a score from an external format into .score.json.
final class ImportCommand {
  const ImportCommand();

  Future<int> run(
    String subformat,
    ArgResults args,
    OutputWriter output,
  ) async {
    if (subformat != 'musicxml') {
      output.writeError('Unknown import format: $subformat', code: 1);
      return 1;
    }

    final inPath = args['in'] as String?;
    final outPath = args['out'] as String?;
    if (inPath == null || inPath.isEmpty) {
      output.writeError('--in is required', code: 1);
      return 1;
    }
    if (outPath == null || outPath.isEmpty) {
      output.writeError('--out is required', code: 1);
      return 1;
    }

    final String xml;
    try {
      xml = await File(inPath).readAsString();
    } catch (e) {
      output.writeError('Failed to read input file: $e', code: 1);
      return 1;
    }

    try {
      final score = ScoreIo.parseMusicXml(xml);
      await ScoreIo.saveJson(score, outPath);
      output.writeSuccess({'imported': outPath});
    } catch (e) {
      output.writeError('Import failed: $e', code: 1);
      return 1;
    }

    return 0;
  }
}
