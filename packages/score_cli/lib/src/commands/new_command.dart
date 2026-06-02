import 'package:args/args.dart';
import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';

import '../output.dart';

/// Creates a new empty score and saves it to a file.
final class NewCommand {
  const NewCommand();

  Future<int> run(ArgResults args, OutputWriter output) async {
    final outPath = args['out'] as String?;
    if (outPath == null || outPath.isEmpty) {
      output.writeError('--out is required', code: 1);
      return 1;
    }

    final title = (args['title'] as String?) ?? '';
    final composer = (args['composer'] as String?) ?? '';

    final score = Score(
      id: IdFactory.score(),
      title: title,
      composer: composer,
    );

    try {
      await ScoreIo.saveJson(score, outPath);
    } catch (e) {
      output.writeError('Failed to write file: $e', code: 1);
      return 1;
    }

    output.writeSuccess({
      'id': score.id.value,
      'title': score.title,
      'composer': score.composer,
      'parts': <Object?>[],
      'measureHeaders': <Object?>[],
    });
    return 0;
  }
}
