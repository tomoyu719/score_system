import 'package:score_core/score_core.dart';

/// Detects noteheads shared between different voices (same pitch and offset).
final class SharedNoteheadDetector {
  const SharedNoteheadDetector();

  /// Returns pairs of note IDs from different voices that have the same pitch
  /// and beat offset (i.e., they should share a single notehead glyph).
  List<(String noteId1, String noteId2)> findShared(
    List<VoiceContext> voiceContexts,
  ) {
    // Build a flat list of (voiceId, noteId, pitch, offset) across all contexts.
    final entries = <_NoteEntry>[];
    for (final ctx in voiceContexts) {
      for (final event in ctx.voice.events) {
        if (event is NoteEvent) {
          entries.add(
            _NoteEntry(
              voiceId: ctx.voiceId.value,
              noteId: event.id.value,
              pitch: event.pitch,
              offset: event.offset,
            ),
          );
        }
      }
    }

    final pairs = <(String, String)>[];
    for (var i = 0; i < entries.length; i++) {
      for (var j = i + 1; j < entries.length; j++) {
        final a = entries[i];
        final b = entries[j];
        if (a.voiceId == b.voiceId) continue;
        if (a.pitch == b.pitch && a.offset == b.offset) {
          pairs.add((a.noteId, b.noteId));
        }
      }
    }
    return pairs;
  }
}

final class _NoteEntry {
  const _NoteEntry({
    required this.voiceId,
    required this.noteId,
    required this.pitch,
    required this.offset,
  });

  final String voiceId;
  final String noteId;
  final Pitch pitch;
  final Fraction offset;
}
