part of 'command.dart';

/// Executes a sequence of commands atomically: all succeed or all are rolled back.
final class BatchCommand extends Command {
  const BatchCommand({required this.commands});

  final IList<Command> commands;
}
