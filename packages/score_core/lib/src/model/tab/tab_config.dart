import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../pitch.dart';

/// Configuration for a TAB staff: string count, open-string tuning, and capo.
final class TabConfig {
  const TabConfig({
    required this.stringCount,
    required this.tuning,
    this.capo = 0,
  }) : assert(stringCount >= 4 && stringCount <= 12, 'stringCount must be 4–12'),
       assert(capo >= 0, 'capo must be >= 0');

  /// Number of strings (4–12).
  final int stringCount;

  /// Open-string pitches from lowest (string 1) to highest.
  final IList<Pitch> tuning;

  /// Capo fret (0 = no capo).
  final int capo;

  TabConfig copyWith({int? stringCount, IList<Pitch>? tuning, int? capo}) =>
      TabConfig(
        stringCount: stringCount ?? this.stringCount,
        tuning: tuning ?? this.tuning,
        capo: capo ?? this.capo,
      );

  @override
  bool operator ==(Object other) {
    if (other is! TabConfig) return false;
    return stringCount == other.stringCount &&
        tuning == other.tuning &&
        capo == other.capo;
  }

  @override
  int get hashCode => Object.hash(stringCount, tuning, capo);
}

/// Standard 6-string guitar in EADGBE tuning (low to high: E2 A2 D3 G3 B3 E4).
final standardGuitar = TabConfig(
  stringCount: 6,
  tuning: IList([
    Pitch(step: Step.e, octave: 2),
    Pitch(step: Step.a, octave: 2),
    Pitch(step: Step.d, octave: 3),
    Pitch(step: Step.g, octave: 3),
    Pitch(step: Step.b, octave: 3),
    Pitch(step: Step.e, octave: 4),
  ]),
);

/// Standard 4-string bass in EADG tuning (low to high: E1 A1 D2 G2).
final standardBass = TabConfig(
  stringCount: 4,
  tuning: IList([
    Pitch(step: Step.e, octave: 1),
    Pitch(step: Step.a, octave: 1),
    Pitch(step: Step.d, octave: 2),
    Pitch(step: Step.g, octave: 2),
  ]),
);
