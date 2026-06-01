import '../model/score.dart';

/// Result of a [CommandEngine.apply] call.
sealed class CommandResult {
  const CommandResult();
}

/// The command was applied successfully.
final class CommandSuccess extends CommandResult {
  const CommandSuccess({required this.scoreAfter});

  final Score scoreAfter;
}

/// The command failed due to a user error. The original [Score] is unchanged.
final class CommandFailure extends CommandResult {
  const CommandFailure({required this.scoreBefore, required this.reason});

  final Score scoreBefore;
  final String reason;
}
