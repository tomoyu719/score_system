import 'barline.dart';
import 'fraction.dart';
import 'key_signature.dart';
import 'tempo.dart';
import 'time_signature.dart';

/// Shared metadata for a measure: time/key signatures, tempo, and barlines.
///
/// MeasureHeaders live on the Score (not inside Parts) so all parts share them.
final class MeasureHeader {
  const MeasureHeader({
    required this.measureNumber,
    required this.timeSignature,
    required this.keySignature,
    this.tempo,
    this.barlineStart = BarlineType.regular,
    this.barlineEnd = BarlineType.regular,
  });

  /// 1-based measure number.
  final int measureNumber;
  final TimeSignature timeSignature;

  /// Total notated duration of one measure under this header's time signature.
  Fraction get measureDuration => timeSignature.measureDuration;
  final KeySignature keySignature;
  final Tempo? tempo;
  final BarlineType barlineStart;
  final BarlineType barlineEnd;

  MeasureHeader copyWith({
    int? measureNumber,
    TimeSignature? timeSignature,
    KeySignature? keySignature,
    Tempo? tempo,
    BarlineType? barlineStart,
    BarlineType? barlineEnd,
  }) =>
      MeasureHeader(
        measureNumber: measureNumber ?? this.measureNumber,
        timeSignature: timeSignature ?? this.timeSignature,
        keySignature: keySignature ?? this.keySignature,
        tempo: tempo ?? this.tempo,
        barlineStart: barlineStart ?? this.barlineStart,
        barlineEnd: barlineEnd ?? this.barlineEnd,
      );

  @override
  bool operator ==(Object other) {
    if (other is! MeasureHeader) return false;
    return measureNumber == other.measureNumber &&
        timeSignature == other.timeSignature &&
        keySignature == other.keySignature &&
        tempo == other.tempo &&
        barlineStart == other.barlineStart &&
        barlineEnd == other.barlineEnd;
  }

  @override
  int get hashCode => Object.hash(
        measureNumber,
        timeSignature,
        keySignature,
        tempo,
        barlineStart,
        barlineEnd,
      );
}
