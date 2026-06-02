import '../model/music_event.dart';
import '../model/score.dart';
import 'validation_error.dart';
import 'validation_result.dart';

/// Stateless validator. Runs all built-in rules against a [Score].
///
/// Rules are additive — all rules run regardless of earlier failures.
/// Returns [ValidationSuccess] only when every rule passes.
final class Validator {
  const Validator();

  ValidationResult validate(Score score) {
    final errors = <ValidationError>[];
    _checkVoiceOverflow(score, errors);
    _checkPitchRange(score, errors);
    return errors.isEmpty
        ? const ValidationSuccess()
        : ValidationFailure(errors: errors);
  }

  // ── T24: Voice duration must not exceed the measure's time signature ────────

  void _checkVoiceOverflow(Score score, List<ValidationError> errors) {
    for (final ctx in score.allVoices) {
      final header = score.headerForMeasure(ctx.measureNumber);
      if (header == null) continue;
      if (ctx.voice.totalDuration > header.measureDuration) {
        errors.add(ValidationError(
          code: 'VOICE_OVERFLOW',
          message: 'Voice duration ${ctx.voice.totalDuration} exceeds measure '
              'limit ${header.measureDuration} in measure ${ctx.measureNumber}',
          partId: ctx.partId.value,
          staffId: ctx.staffId.value,
          measureNumber: ctx.measureNumber,
          voiceId: ctx.voiceId.value,
        ));
      }
    }
  }

  // ── T25: All NoteEvents must be within MIDI pitch range 0–127 ──────────────

  void _checkPitchRange(Score score, List<ValidationError> errors) {
    for (final ctx in score.allVoices) {
      for (final event in ctx.voice.events) {
        if (event is! NoteEvent) continue;
        final midi = event.pitch.midiPitch;
        if (midi < 0 || midi > 127) {
          errors.add(ValidationError(
            code: 'PITCH_OUT_OF_RANGE',
            message: 'Note "${event.id.value}" has MIDI pitch $midi '
                '(must be 0–127)',
            partId: ctx.partId.value,
            staffId: ctx.staffId.value,
            measureNumber: ctx.measureNumber,
            voiceId: ctx.voiceId.value,
          ));
        }
      }
    }
  }
}
