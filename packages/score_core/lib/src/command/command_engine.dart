import '../ids.dart';
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

  // ── Private navigation helper ──────────────────────────────────────────────

  Voice? _findVoice(Score score, PartId partId, StaffId staffId,
          int measureNumber, VoiceId voiceId) =>
      score.findPart(partId)?.findStaff(staffId)?.findVoice(measureNumber, voiceId);

  // ── AddNote ────────────────────────────────────────────────────────────────

  CommandResult _applyAddNote(AddNoteCommand cmd, Score score) {
    final existingVoice = _findVoice(
        score, cmd.partId, cmd.staffId, cmd.measureNumber, cmd.voiceId);
    if (existingVoice != null && existingVoice.containsNote(cmd.event.id)) {
      return CommandFailure(
        scoreBefore: score,
        reason: 'Note "${cmd.event.id.value}" already exists in voice',
      );
    }

    final updated = score.updatePart(
      cmd.partId,
      (p) => p.updateStaff(
        cmd.staffId,
        (s) => s.updateMeasure(
          cmd.measureNumber,
          (m) => m.updateVoice(
            cmd.voiceId,
            (v) => v.addNote(cmd.event),
          ),
        ),
      ),
    );
    if (updated == null) {
      return CommandFailure(
        scoreBefore: score,
        reason:
            'Part "${cmd.partId.value}" or Staff "${cmd.staffId.value}" not found',
      );
    }
    return CommandSuccess(scoreAfter: updated);
  }

  // ── RemoveNote ─────────────────────────────────────────────────────────────

  CommandResult _applyRemoveNote(RemoveNoteCommand cmd, Score score) {
    final existingVoice = _findVoice(
        score, cmd.partId, cmd.staffId, cmd.measureNumber, cmd.voiceId);
    if (existingVoice == null) {
      return CommandFailure(
        scoreBefore: score,
        reason: 'Part, Staff, Measure, or Voice not found',
      );
    }
    final eventIndex = existingVoice.indexOfNote(cmd.noteId);
    if (eventIndex < 0) {
      return CommandFailure(
        scoreBefore: score,
        reason: 'Note "${cmd.noteId.value}" not found',
      );
    }

    // Path is verified above — updatePart cannot return null here.
    final updated = score.updatePart(
      cmd.partId,
      (p) => p.updateStaff(
        cmd.staffId,
        (s) => s.updateMeasure(
          cmd.measureNumber,
          (m) => m.updateVoice(
            cmd.voiceId,
            (v) => v.removeNoteAt(eventIndex),
          ),
        ),
      ),
    );
    return CommandSuccess(scoreAfter: updated!);
  }

  // ── AddPart ────────────────────────────────────────────────────────────────

  CommandResult _applyAddPart(AddPartCommand cmd, Score score) {
    if (score.findPart(cmd.part.id) != null) {
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
    final updated = score.updatePart(
      cmd.partId,
      (p) => p.updateStaff(
        cmd.staffId,
        (s) => s.copyWith(
          measures: s.measures.add(cmd.measureNumber, cmd.measure),
        ),
      ),
    );
    if (updated == null) {
      return CommandFailure(
        scoreBefore: score,
        reason:
            'Part "${cmd.partId.value}" or Staff "${cmd.staffId.value}" not found',
      );
    }
    return CommandSuccess(scoreAfter: updated);
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
