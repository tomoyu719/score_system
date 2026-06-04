part of 'layout_element.dart';

/// Layout data for a percussion/unpitched note (PercussionNote).
///
/// [staffLine] is taken directly from [DrumInstrument.staffLine] — it does not
/// depend on the active clef (clef-independent / "absolute" positioning).
final class PercussionNoteLayout extends LayoutElement {
  const PercussionNoteLayout({
    required this.percussionNoteId,
    required this.offset,
    required this.staffLine,
    required this.stemDirection,
  });

  final PercussionNoteId percussionNoteId;
  final Fraction offset;
  final int staffLine;
  final StemDirection stemDirection;

  Map<String, Object?> toJson() => {
        'percussionNoteId': percussionNoteId.value,
        'offset': offset.toString(),
        'staffLine': staffLine,
        'stemDirection': stemDirection.name,
      };

  static PercussionNoteLayout fromJson(Map<String, Object?> map) =>
      PercussionNoteLayout(
        percussionNoteId: PercussionNoteId(map['percussionNoteId'] as String),
        offset: Fraction.fromString(map['offset'] as String),
        staffLine: map['staffLine'] as int,
        stemDirection: StemDirection.values.byName(map['stemDirection'] as String),
      );

  @override
  bool operator ==(Object other) {
    if (other is! PercussionNoteLayout) return false;
    return percussionNoteId == other.percussionNoteId &&
        offset == other.offset &&
        staffLine == other.staffLine &&
        stemDirection == other.stemDirection;
  }

  @override
  int get hashCode => Object.hash(percussionNoteId, offset, staffLine, stemDirection);
}
