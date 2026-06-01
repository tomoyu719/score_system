part of 'command.dart';

/// Removes a note by ID from a specific location in the score.
final class RemoveNoteCommand extends Command {
  const RemoveNoteCommand({
    required this.partId,
    required this.staffId,
    required this.measureNumber,
    required this.voiceId,
    required this.noteId,
  });

  final PartId partId;
  final StaffId staffId;
  final int measureNumber;
  final VoiceId voiceId;
  final NoteId noteId;
}
