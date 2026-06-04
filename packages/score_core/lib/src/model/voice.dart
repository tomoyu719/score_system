import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';
import 'fraction.dart';
import 'music_event.dart';
import 'rest_positioning_policy.dart';
import 'stem_direction.dart';

/// A single voice within a measure: an ordered sequence of music events.
final class Voice {
  const Voice({
    required this.id,
    this.voiceNumber = 1,
    this.priority = 0,
    this.stemDirectionPolicy = StemDirection.auto,
    this.restPositioningPolicy = RestPositioningPolicy.auto,
    this.isHidden = false,
    this.isPlayback = false,
    this.events = const IListConst([]),
  });

  final VoiceId id;

  /// Display number (1-indexed).
  final int voiceNumber;

  /// Rendering priority: lower value = higher priority (rendered first).
  final int priority;

  /// Preferred stem direction for notes in this voice.
  final StemDirection stemDirectionPolicy;

  /// How rests are vertically positioned when multiple voices share a staff.
  final RestPositioningPolicy restPositioningPolicy;

  /// When true, this voice is hidden from the printed score.
  final bool isHidden;

  /// When true, this voice is used for MIDI playback only (not printed).
  final bool isPlayback;

  final IList<MusicEvent> events;

  /// Total notated duration of all events in this voice.
  Fraction get totalDuration => events.fold(
        Fraction.zero,
        (acc, e) => acc + e.noteValue.toFraction(),
      );

  /// Returns true if this voice contains a [NoteEvent] with the given [id].
  bool containsNote(NoteId id) =>
      events.any((e) => e is NoteEvent && e.id == id);

  /// Returns the index of the [NoteEvent] with [id], or -1 if not found.
  int indexOfNote(NoteId id) =>
      events.indexWhere((e) => e is NoteEvent && e.id == id);

  /// Returns a new [Voice] with [event] appended.
  Voice addNote(NoteEvent event) => copyWith(events: events.add(event));

  /// Returns a new [Voice] with the event at [index] removed.
  Voice removeNoteAt(int index) => copyWith(events: events.removeAt(index));

  Voice copyWith({
    VoiceId? id,
    int? voiceNumber,
    int? priority,
    StemDirection? stemDirectionPolicy,
    RestPositioningPolicy? restPositioningPolicy,
    bool? isHidden,
    bool? isPlayback,
    IList<MusicEvent>? events,
  }) =>
      Voice(
        id: id ?? this.id,
        voiceNumber: voiceNumber ?? this.voiceNumber,
        priority: priority ?? this.priority,
        stemDirectionPolicy: stemDirectionPolicy ?? this.stemDirectionPolicy,
        restPositioningPolicy:
            restPositioningPolicy ?? this.restPositioningPolicy,
        isHidden: isHidden ?? this.isHidden,
        isPlayback: isPlayback ?? this.isPlayback,
        events: events ?? this.events,
      );
}
