part of 'music_event.dart';

/// A rest event.
final class RestEvent extends MusicEvent {
  const RestEvent({
    required this.id,
    required super.offset,
    required super.noteValue,
    this.isFullMeasure = false,
  });

  final RestId id;

  /// Whether this rest fills the entire measure (displayed as a whole-rest symbol
  /// regardless of time signature).
  final bool isFullMeasure;

  RestEvent copyWith({
    RestId? id,
    Fraction? offset,
    NoteValue? noteValue,
    bool? isFullMeasure,
  }) =>
      RestEvent(
        id: id ?? this.id,
        offset: offset ?? this.offset,
        noteValue: noteValue ?? this.noteValue,
        isFullMeasure: isFullMeasure ?? this.isFullMeasure,
      );
}
