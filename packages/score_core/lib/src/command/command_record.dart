import '../model/score.dart';
import 'command.dart';

/// An immutable record of a successfully applied command.
///
/// Stores both the before and after [Score] for O(1) undo/redo.
final class CommandRecord {
  const CommandRecord({
    required this.command,
    required this.scoreBefore,
    required this.scoreAfter,
    required this.timestamp,
  });

  final Command command;
  final Score scoreBefore;
  final Score scoreAfter;
  final DateTime timestamp;
}
