import 'package:args/args.dart';
import 'package:score_io/score_io.dart';

import '../output.dart';

/// Outputs a structural summary of a score.
final class InspectCommand {
  const InspectCommand();

  Future<int> run(ArgResults args, OutputWriter output) async {
    final inPath = args['in'] as String?;
    if (inPath == null || inPath.isEmpty) {
      output.writeError('--in is required', code: 1);
      return 1;
    }

    try {
      final score = await ScoreIo.loadJson(inPath);
      final useMidi = args['midi'] as bool? ?? false;

      if (useMidi) {
        output.writeSuccess(ScoreIo.dumpMidi(score));
      } else {
        final partsSummary = score.parts.map((p) {
          final measureCount = p.staves.isEmpty
              ? 0
              : p.staves
                  .map((s) => s.measures.length)
                  .reduce((a, b) => a > b ? a : b);
          return <String, Object?>{
            'id': p.id.value,
            'name': p.name,
            'staffCount': p.staves.length,
            'measureCount': measureCount,
          };
        }).toList();

        output.writeSuccess({
          'id': score.id.value,
          'title': score.title,
          'parts': partsSummary,
          'measureHeaderCount': score.measureHeaders.length,
        });
      }
    } catch (e) {
      output.writeError('Inspect failed: $e', code: 1);
      return 1;
    }

    return 0;
  }
}
