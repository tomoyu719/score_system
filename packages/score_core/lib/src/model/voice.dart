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
        (acc, e) => acc + e.noteValue.toFraction(),
      );

  Voice copyWith({VoiceId? id, IList<MusicEvent>? events}) => Voice(
        id: id ?? this.id,
        events: events ?? this.events,
      );
}
