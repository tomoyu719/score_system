import 'note_type.dart';

/// A tempo marking.
final class Tempo {
  const Tempo({required this.bpm, this.beatUnit = NoteType.quarter})
      : assert(bpm > 0, 'bpm must be positive');

  /// Beats per minute.
  final double bpm;

  /// Note value that receives one beat.
  final NoteType beatUnit;

  Tempo copyWith({double? bpm, NoteType? beatUnit}) => Tempo(
        bpm: bpm ?? this.bpm,
        beatUnit: beatUnit ?? this.beatUnit,
      );

  @override
  bool operator ==(Object other) {
    if (other is! Tempo) return false;
    return bpm == other.bpm && beatUnit == other.beatUnit;
  }

  @override
  int get hashCode => Object.hash(bpm, beatUnit);
}
