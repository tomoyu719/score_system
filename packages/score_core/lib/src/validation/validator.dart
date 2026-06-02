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
    for (final part in score.parts) {
      for (final staff in part.staves) {
        for (final entry in staff.measures.entries) {
          final measureNumber = entry.key;
          final measure = entry.value;
          final header = score.headerForMeasure(measureNumber);
          if (header == null) continue;
          final limit = header.timeSignature.measureDuration;

          for (final voiceEntry in measure.voices.entries) {
            final voice = voiceEntry.value;
            if (voice.totalDuration > limit) {
              errors.add(ValidationError(
                code: 'VOICE_OVERFLOW',
                message:
                    'Voice duration ${voice.totalDuration} exceeds measure '
                    'limit $limit in measure $measureNumber',
                partId: part.id.value,
                staffId: staff.id.value,
                measureNumber: measureNumber,
                voiceId: voice.id.value,
              ));
            }
          }
        }
      }
    }
  }

  // ── T25: All NoteEvents must be within MIDI pitch range 0–127 ──────────────

  void _checkPitchRange(Score score, List<ValidationError> errors) {
    for (final part in score.parts) {
      for (final staff in part.staves) {
        for (final entry in staff.measures.entries) {
          final measureNumber = entry.key;
          for (final voiceEntry in entry.value.voices.entries) {
            final voice = voiceEntry.value;
            for (final event in voice.events) {
              if (event is! NoteEvent) continue;
              final midi = event.pitch.midiPitch;
              if (midi < 0 || midi > 127) {
                errors.add(ValidationError(
                  code: 'PITCH_OUT_OF_RANGE',
                  message:
                      'Note "${event.id.value}" has MIDI pitch $midi '
                      '(must be 0–127)',
                  partId: part.id.value,
                  staffId: staff.id.value,
                  measureNumber: measureNumber,
                  voiceId: voice.id.value,
                ));
              }
            }
          }
        }
      }
    }
  }
}
