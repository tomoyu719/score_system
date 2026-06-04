part of 'layout_element.dart';

/// Articulation mark attached to a pitched note.
final class ArticulationLayout extends LayoutElement {
  const ArticulationLayout({
    required this.noteId,
    required this.articulationType,
  });

  final NoteId noteId;

  /// Value of [ArticulationType.name].
  final String articulationType;

  Map<String, Object?> toJson() =>
      {'noteId': noteId.value, 'articulationType': articulationType};

  static ArticulationLayout fromJson(Map<String, Object?> map) =>
      ArticulationLayout(
        noteId: NoteId(map['noteId'] as String),
        articulationType: map['articulationType'] as String,
      );

  @override
  bool operator ==(Object other) =>
      other is ArticulationLayout &&
      noteId == other.noteId &&
      articulationType == other.articulationType;

  @override
  int get hashCode => Object.hash(noteId, articulationType);
}
