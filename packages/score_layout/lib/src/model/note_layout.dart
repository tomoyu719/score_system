part of 'layout_element.dart';

/// Layout data for a single pitched note (NoteEvent).
///
/// [staffLine] is computed by [ClefStaffLineMapper] from pitch + clef.
/// 0 = bottom staff line; positive = upward.
final class NoteLayout extends LayoutElement {
  const NoteLayout({
    required this.noteId,
    required this.offset,
    required this.staffLine,
    required this.stemDirection,
    this.isSharedNotehead = false,
    this.accidentals = const IListConst([]),
    this.articulations = const IListConst([]),
  });

  final NoteId noteId;
  final Fraction offset;
  final int staffLine;
  final StemDirection stemDirection;

  /// True when another voice has a note at the same offset + staffLine.
  final bool isSharedNotehead;

  final IList<AccidentalLayout> accidentals;
  final IList<ArticulationLayout> articulations;

  NoteLayout copyWith({
    NoteId? noteId,
    Fraction? offset,
    int? staffLine,
    StemDirection? stemDirection,
    bool? isSharedNotehead,
    IList<AccidentalLayout>? accidentals,
    IList<ArticulationLayout>? articulations,
  }) =>
      NoteLayout(
        noteId: noteId ?? this.noteId,
        offset: offset ?? this.offset,
        staffLine: staffLine ?? this.staffLine,
        stemDirection: stemDirection ?? this.stemDirection,
        isSharedNotehead: isSharedNotehead ?? this.isSharedNotehead,
        accidentals: accidentals ?? this.accidentals,
        articulations: articulations ?? this.articulations,
      );

  Map<String, Object?> toJson() => {
        'noteId': noteId.value,
        'offset': offset.toString(),
        'staffLine': staffLine,
        'stemDirection': stemDirection.name,
        'isSharedNotehead': isSharedNotehead,
        'accidentals': accidentals.map((a) => a.toJson()).toList(),
        'articulations': articulations.map((a) => a.toJson()).toList(),
      };

  static NoteLayout fromJson(Map<String, Object?> map) => NoteLayout(
        noteId: NoteId(map['noteId'] as String),
        offset: Fraction.fromString(map['offset'] as String),
        staffLine: map['staffLine'] as int,
        stemDirection: StemDirection.values.byName(map['stemDirection'] as String),
        isSharedNotehead: map['isSharedNotehead'] as bool? ?? false,
        accidentals: IList(
          (map['accidentals'] as List<dynamic>? ?? [])
              .map((e) => AccidentalLayout.fromJson(e as Map<String, Object?>)),
        ),
        articulations: IList(
          (map['articulations'] as List<dynamic>? ?? [])
              .map((e) => ArticulationLayout.fromJson(e as Map<String, Object?>)),
        ),
      );

  @override
  bool operator ==(Object other) {
    if (other is! NoteLayout) return false;
    return noteId == other.noteId &&
        offset == other.offset &&
        staffLine == other.staffLine &&
        stemDirection == other.stemDirection &&
        isSharedNotehead == other.isSharedNotehead &&
        accidentals == other.accidentals &&
        articulations == other.articulations;
  }

  @override
  int get hashCode => Object.hash(
        noteId,
        offset,
        staffLine,
        stemDirection,
        isSharedNotehead,
        accidentals,
        articulations,
      );
}
