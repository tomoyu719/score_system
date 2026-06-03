import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';
import 'articulation.dart';
import 'dynamic.dart';
import 'fingering.dart';
import 'fraction.dart';
import 'lyric.dart';
import 'note_value.dart';
import 'pitch.dart';

part 'note_event.dart';
part 'rest_event.dart';
part 'chord_event.dart';

/// Base for all music events within a voice.
sealed class MusicEvent {
  const MusicEvent({required this.offset, required this.noteValue});

  /// Position within the measure in whole-note units.
  final Fraction offset;

  /// Duration of this event.
  final NoteValue noteValue;

  /// Actual duration in whole-note units.
  Fraction get duration => noteValue.toFraction();
}
