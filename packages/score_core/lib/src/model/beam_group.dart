import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';

/// A beam group connecting multiple notes by their stems.
final class BeamGroup {
  const BeamGroup({
    required this.id,
    required this.noteIds,
  });

  final BeamGroupId id;
  final IList<NoteId> noteIds;

  BeamGroup copyWith({BeamGroupId? id, IList<NoteId>? noteIds}) => BeamGroup(
        id: id ?? this.id,
        noteIds: noteIds ?? this.noteIds,
      );
}
