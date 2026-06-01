/// The letter name of a pitch.
enum Step { c, d, e, f, g, a, b }

/// Staff-space pitch representation: step, octave (0–9), and chromatic alteration.
final class Pitch {
  const Pitch({
    required this.step,
    this.alter = 0.0,
    required this.octave,
  })  : assert(alter >= -2.0 && alter <= 2.0, 'alter must be -2.0 to 2.0'),
        assert(octave >= 0 && octave <= 9, 'octave must be 0–9');

  final Step step;

  /// Chromatic alteration in semitones: -2.0 (bb) to +2.0 (x).
  final double alter;

  final int octave;

  static const _stepBase = {
    Step.c: 0,
    Step.d: 2,
    Step.e: 4,
    Step.f: 5,
    Step.g: 7,
    Step.a: 9,
    Step.b: 11,
  };

  /// MIDI pitch number where C4 = 60.
  int get midiPitch =>
      (octave + 1) * 12 + _stepBase[step]! + alter.round();

  Pitch copyWith({Step? step, double? alter, int? octave}) => Pitch(
        step: step ?? this.step,
        alter: alter ?? this.alter,
        octave: octave ?? this.octave,
      );

  @override
  bool operator ==(Object other) {
    if (other is! Pitch) return false;
    return step == other.step && alter == other.alter && octave == other.octave;
  }

  @override
  int get hashCode => Object.hash(step, alter, octave);
}
