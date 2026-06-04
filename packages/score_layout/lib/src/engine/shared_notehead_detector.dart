import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';

import '../model/voice_layout.dart';

/// Detects notes that share the same staff-line position at the same offset
/// across multiple voices in a measure.
final class SharedNoteheadDetector {
  const SharedNoteheadDetector();

  /// Returns the set of [NoteId]s that should be rendered as shared noteheads.
  ///
  /// A notehead is shared when ≥ 2 voices have a note at the same
  /// (offset, staffLine) within a single measure.
  Set<NoteId> detect(IList<VoiceLayout> voices) {
    // offset → staffLine → list of noteIds
    final bucket = <Fraction, Map<int, List<NoteId>>>{};

    for (final voice in voices) {
      for (final note in voice.notes) {
        bucket.putIfAbsent(note.offset, () => {});
        bucket[note.offset]!.putIfAbsent(note.staffLine, () => []);
        bucket[note.offset]![note.staffLine]!.add(note.noteId);
      }
    }

    final shared = <NoteId>{};
    for (final byStaffLine in bucket.values) {
      for (final noteIds in byStaffLine.values) {
        if (noteIds.length >= 2) shared.addAll(noteIds);
      }
    }
    return shared;
  }
}
