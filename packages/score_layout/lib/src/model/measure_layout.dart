import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'voice_layout.dart';

/// Layout data for a single measure.
final class MeasureLayout {
  const MeasureLayout({
    required this.measureNumber,
    required this.relativeWidth,
    this.voices = const IListConst([]),
  });

  final int measureNumber;

  /// Proportional width relative to the narrowest measure (minimum = 1.0).
  final double relativeWidth;

  final IList<VoiceLayout> voices;

  MeasureLayout copyWith({
    int? measureNumber,
    double? relativeWidth,
    IList<VoiceLayout>? voices,
  }) =>
      MeasureLayout(
        measureNumber: measureNumber ?? this.measureNumber,
        relativeWidth: relativeWidth ?? this.relativeWidth,
        voices: voices ?? this.voices,
      );

  Map<String, Object?> toJson() => {
        'measureNumber': measureNumber,
        'relativeWidth': relativeWidth,
        'voices': voices.map((v) => v.toJson()).toList(),
      };

  static MeasureLayout fromJson(Map<String, Object?> map) => MeasureLayout(
        measureNumber: map['measureNumber'] as int,
        relativeWidth: (map['relativeWidth'] as num).toDouble(),
        voices: IList(
          (map['voices'] as List<dynamic>? ?? [])
              .map((e) => VoiceLayout.fromJson(e as Map<String, Object?>)),
        ),
      );

  @override
  bool operator ==(Object other) {
    if (other is! MeasureLayout) return false;
    return measureNumber == other.measureNumber &&
        relativeWidth == other.relativeWidth &&
        voices == other.voices;
  }

  @override
  int get hashCode => Object.hash(measureNumber, relativeWidth, voices);
}
