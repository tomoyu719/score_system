import 'package:score_core/score_core.dart';

/// Resolves the staff-line position for a rest in a voice.
final class RestPositioningCalculator {
  const RestPositioningCalculator();

  /// Returns the staff-line for a rest in [voice], given [voiceCountInMeasure].
  ///
  /// staffLine 4 = middle line of a 5-line staff (0-indexed: 0,2,4,6,8 are lines).
  int resolve(Voice voice, int voiceCountInMeasure) =>
      switch (voice.restPositioningPolicy) {
        RestPositioningPolicy.center => 4,
        RestPositioningPolicy.byVoice =>
          4 + (voice.voiceNumber - 1) * 2,
        RestPositioningPolicy.auto => _auto(voice, voiceCountInMeasure),
      };

  int _auto(Voice voice, int voiceCountInMeasure) {
    if (voiceCountInMeasure == 1) return 4;
    const upperVoiceLine = 6;
    const lowerVoiceLine = 2;
    return voice.priority == 0 ? upperVoiceLine : lowerVoiceLine;
  }
}
