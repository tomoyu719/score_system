import 'dart:io';

import 'package:args/args.dart';
import 'package:score_io/score_io.dart';

import '../output.dart';

/// Exports a score to an external format.
final class ExportCommand {
  const ExportCommand();

  Future<int> run(
    String subformat,
    ArgResults args,
    OutputWriter output,
  ) async {
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

    try {
      final score = await ScoreIo.loadJson(inPath);

      switch (subformat) {
        case 'musicxml':
          final xml = ScoreIo.exportMusicXml(score);
          await File(outPath).writeAsString(xml);
          output.writeSuccess({'exported': outPath});
        case 'midi':
          final bytes = ScoreIo.encodeMidi(score);
          await File(outPath).writeAsBytes(bytes);
          output.writeSuccess({'exported': outPath});
        default:
          output.writeError('Unknown export format: $subformat', code: 1);
          return 1;
      }
    } catch (e) {
      output.writeError('Export failed: $e', code: 1);
      return 1;
    }

    return 0;
  }
}
