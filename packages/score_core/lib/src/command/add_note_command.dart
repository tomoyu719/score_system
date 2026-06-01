part of 'command.dart';

/// Adds a [NoteEvent] to a specific location in the score.
final class AddNoteCommand extends Command {
  const AddNoteCommand({
    required this.partId,
    required this.staffId,
    required this.measureNumber,
    required this.voiceId,
    required this.event,
  });

  final PartId partId;
  final StaffId staffId;
  final int measureNumber;
  final VoiceId voiceId;
  final NoteEvent event;
}
