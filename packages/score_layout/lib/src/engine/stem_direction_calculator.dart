import 'package:score_core/score_core.dart';

/// Resolves the stem direction for a voice in a measure.
final class StemDirectionCalculator {
  const StemDirectionCalculator();

  /// Returns the [StemDirection] for [voice] given [voiceCountInMeasure].
  ///
  /// Policy:
  /// - Explicit `up` / `down` on voice → returned as-is.
  /// - `auto`, single voice → [StemDirection.down].
  /// - `auto`, multi-voice, `voice.priority == 0` → [StemDirection.up].
  /// - `auto`, multi-voice, other priorities → [StemDirection.down].
  StemDirection resolve(Voice voice, int voiceCountInMeasure) {
    if (voice.stemDirectionPolicy != StemDirection.auto) {
      return voice.stemDirectionPolicy;
    }
    if (voiceCountInMeasure == 1) return StemDirection.down;
    return voice.priority == 0 ? StemDirection.up : StemDirection.down;
  }
}
