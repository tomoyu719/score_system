import 'package:args/args.dart';
import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';

import '../output.dart';

/// Loads a score and runs the Validator against it.
final class ValidateCommand {
  const ValidateCommand();

  Future<int> run(ArgResults args, OutputWriter output) async {
    final inPath = args['in'] as String?;
    if (inPath == null || inPath.isEmpty) {
      output.writeError('--in is required', code: 1);
      return 1;
    }

    final Score score;
    try {
      score = await ScoreIo.loadJson(inPath);
    } catch (e) {
      output.writeError('Failed to load score: $e', code: 1);
      return 1;
    }

    final result = const Validator().validate(score);
    output.writeSuccess(result.toJson());

    return switch (result) {
      ValidationSuccess() => 0,
      ValidationFailure() => 2,
    };
  }
}
