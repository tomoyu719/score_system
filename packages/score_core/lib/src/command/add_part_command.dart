part of 'command.dart';

/// Adds a [Part] to the score.
final class AddPartCommand extends Command {
  const AddPartCommand({required this.part});

  final Part part;
}
