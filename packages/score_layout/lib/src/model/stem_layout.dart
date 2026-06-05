part of 'layout_element.dart';

/// Stem direction resolved for a specific note.
final class StemLayout extends LayoutElement {
  const StemLayout({required this.noteId, required this.direction});

  final NoteId noteId;
  final StemDirection direction;

  Map<String, Object?> toJson() => {
        'noteId': noteId.value,
        'direction': direction.name,
      };

  static StemLayout fromJson(Map<String, Object?> map) => StemLayout(
        noteId: NoteId(map['noteId'] as String),
        direction: StemDirection.values.byName(map['direction'] as String),
      );

  @override
  bool operator ==(Object other) {
    if (other is! StemLayout) return false;
    return noteId == other.noteId && direction == other.direction;
  }

  @override
  int get hashCode => Object.hash(noteId, direction);
}
