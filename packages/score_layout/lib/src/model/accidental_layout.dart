part of 'layout_element.dart';

/// Accidental symbol attached to a pitched note.
final class AccidentalLayout extends LayoutElement {
  const AccidentalLayout({required this.noteId, required this.type});

  final NoteId noteId;

  /// 'sharp' | 'flat' | 'doubleSharp' | 'doubleFlat'
  final String type;

  Map<String, Object?> toJson() => {'noteId': noteId.value, 'type': type};

  static AccidentalLayout fromJson(Map<String, Object?> map) =>
      AccidentalLayout(
        noteId: NoteId(map['noteId'] as String),
        type: map['type'] as String,
      );

  @override
  bool operator ==(Object other) =>
      other is AccidentalLayout && noteId == other.noteId && type == other.type;

  @override
  int get hashCode => Object.hash(noteId, type);
}
