import 'package:args/args.dart';
import 'package:score_io/score_io.dart';
import 'package:score_layout/score_layout.dart';

import '../output.dart';

/// Runs layout and collision commands against a score.
final class LayoutCommand {
  const LayoutCommand();

  Future<int> runLayout(ArgResults args, OutputWriter output) async {
    final inPath = args['in'] as String?;
    if (inPath == null || inPath.isEmpty) {
      output.writeError('--in is required', code: 1);
      return 1;
    }

    try {
      final score = await ScoreIo.loadJson(inPath);
      final tree = const LayoutEngine().layout(score);
      output.writeSuccess(tree.toJson());
    } catch (e) {
      output.writeError('Layout failed: $e', code: 1);
      return 1;
    }

    return 0;
  }

  Future<int> runCollisions(ArgResults args, OutputWriter output) async {
    final inPath = args['in'] as String?;
    if (inPath == null || inPath.isEmpty) {
      output.writeError('--in is required', code: 1);
      return 1;
    }

    try {
      final score = await ScoreIo.loadJson(inPath);
      final tree = const LayoutEngine().layout(score);
      final elements = tree.allElements().toList();
      final pairs = const CollisionDetector().detect(elements);
      final report = CollisionReport(
        pairs: pairs,
        timestamp: DateTime.now(),
      );
      output.writeSuccess(report.toJson());
    } catch (e) {
      output.writeError('Collision detection failed: $e', code: 1);
      return 1;
    }

    return 0;
  }

}
