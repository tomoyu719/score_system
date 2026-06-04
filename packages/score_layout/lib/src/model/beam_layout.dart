part of 'layout_element.dart';

/// Layout data for a beam group.
final class BeamLayout extends LayoutElement {
  const BeamLayout({required this.beamGroupId, required this.noteIds});

  final BeamGroupId beamGroupId;
  final IList<NoteId> noteIds;

  Map<String, Object?> toJson() => {
        'beamGroupId': beamGroupId.value,
        'noteIds': noteIds.map((n) => n.value).toList(),
      };

  static BeamLayout fromJson(Map<String, Object?> map) => BeamLayout(
        beamGroupId: BeamGroupId(map['beamGroupId'] as String),
        noteIds: IList(
          (map['noteIds'] as List<dynamic>).map((e) => NoteId(e as String)),
        ),
      );

  @override
  bool operator ==(Object other) {
    if (other is! BeamLayout) return false;
    return beamGroupId == other.beamGroupId && noteIds == other.noteIds;
  }

  @override
  int get hashCode => Object.hash(beamGroupId, noteIds);
}
