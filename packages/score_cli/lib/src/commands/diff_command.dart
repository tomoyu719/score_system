import 'package:args/args.dart';
import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';

import '../output.dart';

/// Compares two scores structurally.
final class DiffCommand {
  const DiffCommand();

  Future<int> run(ArgResults args, OutputWriter output) async {
    final pathA = args['a'] as String?;
    final pathB = args['b'] as String?;
    if (pathA == null || pathA.isEmpty) {
      output.writeError('--a is required', code: 1);
      return 1;
    }
    if (pathB == null || pathB.isEmpty) {
      output.writeError('--b is required', code: 1);
      return 1;
    }

    final Score scoreA;
    final Score scoreB;
    try {
      scoreA = await ScoreIo.loadJson(pathA);
      scoreB = await ScoreIo.loadJson(pathB);
    } catch (e) {
      output.writeError('Failed to load score: $e', code: 1);
      return 1;
    }

    final differences = <Map<String, Object?>>[];

    if (scoreA.title != scoreB.title) {
      differences.add({'field': 'title', 'a': scoreA.title, 'b': scoreB.title});
    }
    if (scoreA.composer != scoreB.composer) {
      differences.add({
        'field': 'composer',
        'a': scoreA.composer,
        'b': scoreB.composer,
      });
    }
    if (scoreA.parts.length != scoreB.parts.length) {
      differences.add({
        'field': 'parts.length',
        'a': scoreA.parts.length,
        'b': scoreB.parts.length,
      });
    }
    if (scoreA.measureHeaders.length != scoreB.measureHeaders.length) {
      differences.add({
        'field': 'measureHeaders.length',
        'a': scoreA.measureHeaders.length,
        'b': scoreB.measureHeaders.length,
      });
    }

    final notesA = _totalNoteCount(scoreA);
    final notesB = _totalNoteCount(scoreB);
    if (notesA != notesB) {
      differences.add({'field': 'noteCount', 'a': notesA, 'b': notesB});
    }

    output.writeSuccess({
      'same': differences.isEmpty,
      'differences': differences,
    });

    return 0;
  }

  int _totalNoteCount(Score score) {
    var count = 0;
    for (final ctx in score.allVoices) {
      for (final event in ctx.voice.events) {
        if (event is NoteEvent) count++;
      }
    }
    return count;
  }
}
