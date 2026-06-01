import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../model/score.dart';
import 'command_record.dart';

/// Immutable undo/redo stack. All mutation returns a new [ScoreHistory].
final class ScoreHistory {
  const ScoreHistory({
    this.undoStack = const IListConst([]),
    this.redoStack = const IListConst([]),
    this.maxSteps = 1000,
  });

  final IList<CommandRecord> undoStack;
  final IList<CommandRecord> redoStack;

  /// Maximum number of undo steps retained.
  final int maxSteps;

  /// Pushes [record] onto the undo stack and clears the redo stack.
  ///
  /// Drops the oldest entry when [maxSteps] is exceeded.
  ScoreHistory push(CommandRecord record) {
    var newUndo = undoStack.add(record);
    if (newUndo.length > maxSteps) newUndo = newUndo.removeAt(0);
    return ScoreHistory(
      undoStack: newUndo,
      redoStack: const IListConst([]),
      maxSteps: maxSteps,
    );
  }

  /// Returns the score to restore and the new [ScoreHistory], or null if empty.
  (Score, ScoreHistory)? undo() {
    if (undoStack.isEmpty) return null;
    final record = undoStack.last;
    return (
      record.scoreBefore,
      ScoreHistory(
        undoStack: undoStack.removeLast(),
        redoStack: redoStack.add(record),
        maxSteps: maxSteps,
      ),
    );
  }

  /// Returns the score to restore and the new [ScoreHistory], or null if empty.
  (Score, ScoreHistory)? redo() {
    if (redoStack.isEmpty) return null;
    final record = redoStack.last;
    return (
      record.scoreAfter,
      ScoreHistory(
        undoStack: undoStack.add(record),
        redoStack: redoStack.removeLast(),
        maxSteps: maxSteps,
      ),
    );
  }
}
