import '../ids.dart';
import '../model/measure.dart';
import '../model/music_event.dart';
import '../model/score.dart';
import '../model/voice.dart';
import 'command.dart';
import 'command_result.dart';

/// Stateless, pure command processor. Never holds score or history state.
///
/// Returns [CommandFailure] for user errors; throws [ScoreException] for
/// internal bugs only.
final class CommandEngine {
  const CommandEngine();

  CommandResult apply(Command command, Score score) =>
      _dispatch(command, score);

  /// Identical to [apply]; present for semantic clarity in callers that want
  /// to preview a change without committing it.
  CommandResult dryRun(Command command, Score score) =>
      _dispatch(command, score);

  CommandResult _dispatch(Command command, Score score) => switch (command) {
        final AddNoteCommand c => _applyAddNote(c, score),
        final RemoveNoteCommand c => _applyRemoveNote(c, score),
        final AddPartCommand c => _applyAddPart(c, score),
        final AddMeasureCommand c => _applyAddMeasure(c, score),
        final BatchCommand c => _applyBatch(c, score),
      };

  // ── AddNote ────────────────────────────────────────────────────────────────

  CommandResult _applyAddNote(AddNoteCommand cmd, Score score) {
    final partIndex = score.parts.indexWhere((p) => p.id == cmd.partId);
    if (partIndex < 0) {
      return CommandFailure(
        scoreBefore: score,
        reason: 'Part "${cmd.partId.value}" not found',
      );
    }
    final part = score.parts[partIndex];

    final staffIndex = part.staves.indexWhere((s) => s.id == cmd.staffId);
    if (staffIndex < 0) {
      return CommandFailure(
        scoreBefore: score,
        reason: 'Staff "${cmd.staffId.value}" not found',
      );
    }
    final staff = part.staves[staffIndex];

    final measure =
        staff.measures[cmd.measureNumber] ?? Measure(id: IdFactory.measure());
    final voice = measure.voices[cmd.voiceId] ?? Voice(id: cmd.voiceId);

    final isDuplicate =
        voice.events.any((e) => e is NoteEvent && e.id == cmd.event.id);
    if (isDuplicate) {
      return CommandFailure(
        scoreBefore: score,
        reason: 'Note "${cmd.event.id.value}" already exists in voice',
      );
    }

    final updatedVoice = voice.copyWith(events: voice.events.add(cmd.event));
    final updatedMeasure = measure.copyWith(
      voices: measure.voices.add(cmd.voiceId, updatedVoice),
    );
    final updatedStaff = staff.copyWith(
      measures: staff.measures.add(cmd.measureNumber, updatedMeasure),
    );
    final updatedPart =
        part.copyWith(staves: part.staves.replace(staffIndex, updatedStaff));
    return CommandSuccess(
      scoreAfter: score.copyWith(
        parts: score.parts.replace(partIndex, updatedPart),
      ),
    );
  }

  // ── RemoveNote ─────────────────────────────────────────────────────────────

  CommandResult _applyRemoveNote(RemoveNoteCommand cmd, Score score) {
    final partIndex = score.parts.indexWhere((p) => p.id == cmd.partId);
    if (partIndex < 0) {
      return CommandFailure(
        scoreBefore: score,
        reason: 'Part "${cmd.partId.value}" not found',
      );
    }
    final part = score.parts[partIndex];

    final staffIndex = part.staves.indexWhere((s) => s.id == cmd.staffId);
    if (staffIndex < 0) {
      return CommandFailure(
        scoreBefore: score,
        reason: 'Staff "${cmd.staffId.value}" not found',
      );
    }
    final staff = part.staves[staffIndex];
    final measure = staff.measures[cmd.measureNumber];
    if (measure == null) {
      return CommandFailure(
        scoreBefore: score,
        reason: 'Measure ${cmd.measureNumber} not found',
      );
    }
    final voice = measure.voices[cmd.voiceId];
    if (voice == null) {
      return CommandFailure(
        scoreBefore: score,
        reason: 'Voice "${cmd.voiceId.value}" not found',
      );
    }

    final eventIndex = voice.events
        .indexWhere((e) => e is NoteEvent && e.id == cmd.noteId);
    if (eventIndex < 0) {
      return CommandFailure(
        scoreBefore: score,
        reason: 'Note "${cmd.noteId.value}" not found',
      );
    }

    final updatedVoice =
        voice.copyWith(events: voice.events.removeAt(eventIndex));
    final updatedMeasure = measure.copyWith(
      voices: measure.voices.add(cmd.voiceId, updatedVoice),
    );
    final updatedStaff = staff.copyWith(
      measures: staff.measures.add(cmd.measureNumber, updatedMeasure),
    );
    final updatedPart =
        part.copyWith(staves: part.staves.replace(staffIndex, updatedStaff));
    return CommandSuccess(
      scoreAfter: score.copyWith(
        parts: score.parts.replace(partIndex, updatedPart),
      ),
    );
  }

  // ── AddPart ────────────────────────────────────────────────────────────────

  CommandResult _applyAddPart(AddPartCommand cmd, Score score) {
    final alreadyExists = score.parts.any((p) => p.id == cmd.part.id);
    if (alreadyExists) {
      return CommandFailure(
        scoreBefore: score,
        reason: 'Part "${cmd.part.id.value}" already exists',
      );
    }
    return CommandSuccess(
      scoreAfter: score.copyWith(parts: score.parts.add(cmd.part)),
    );
  }

  // ── AddMeasure ─────────────────────────────────────────────────────────────

  CommandResult _applyAddMeasure(AddMeasureCommand cmd, Score score) {
    final partIndex = score.parts.indexWhere((p) => p.id == cmd.partId);
    if (partIndex < 0) {
      return CommandFailure(
        scoreBefore: score,
        reason: 'Part "${cmd.partId.value}" not found',
      );
    }
    final part = score.parts[partIndex];
    final staffIndex = part.staves.indexWhere((s) => s.id == cmd.staffId);
    if (staffIndex < 0) {
      return CommandFailure(
        scoreBefore: score,
        reason: 'Staff "${cmd.staffId.value}" not found',
      );
    }
    final staff = part.staves[staffIndex];
    final updatedStaff = staff.copyWith(
      measures: staff.measures.add(cmd.measureNumber, cmd.measure),
    );
    final updatedPart =
        part.copyWith(staves: part.staves.replace(staffIndex, updatedStaff));
    return CommandSuccess(
      scoreAfter: score.copyWith(
        parts: score.parts.replace(partIndex, updatedPart),
      ),
    );
  }

  // ── Batch ──────────────────────────────────────────────────────────────────

  CommandResult _applyBatch(BatchCommand batch, Score originalScore) {
    var current = originalScore;
    for (final cmd in batch.commands) {
      final result = _dispatch(cmd, current);
      if (result is CommandFailure) {
        return CommandFailure(
          scoreBefore: originalScore,
          reason: result.reason,
        );
      }
      current = (result as CommandSuccess).scoreAfter;
    }
    return CommandSuccess(scoreAfter: current);
  }

}
