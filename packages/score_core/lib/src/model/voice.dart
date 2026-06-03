import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';
import 'fraction.dart';
import 'music_event.dart';

/// A single voice within a measure: an ordered sequence of music events.
final class Voice {
  const Voice({
    required this.id,
    this.events = const IListConst([]),
  });

  final VoiceId id;
  final IList<MusicEvent> events;

  /// Total notated duration of all events in this voice.
  Fraction get totalDuration => events.fold(
        Fraction.zero,
        (acc, e) => acc + e.duration,
      );

  /// Returns true if this voice contains a [NoteEvent] with the given [id].
  bool containsNote(NoteId id) =>
      events.any((e) => e is NoteEvent && e.id == id);

  /// Returns the index of the [NoteEvent] with [id], or -1 if not found.
  int indexOfNote(NoteId id) =>
      events.indexWhere((e) => e is NoteEvent && e.id == id);

  /// Returns a new [Voice] with [event] appended.
  Voice addNote(NoteEvent event) =>
      copyWith(events: events.add(event));

  /// Returns a new [Voice] with the event at [index] removed.
  Voice removeNoteAt(int index) =>
      copyWith(events: events.removeAt(index));

  Voice copyWith({VoiceId? id, IList<MusicEvent>? events}) => Voice(
        id: id ?? this.id,
        events: events ?? this.events,
      );
}
