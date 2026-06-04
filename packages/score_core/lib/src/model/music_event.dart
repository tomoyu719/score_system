import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';
import 'articulation.dart';
import 'dynamic.dart';
import 'fingering.dart';
import 'fraction.dart';
import 'lyric.dart';
import 'note_value.dart';
import 'percussion/drum_instrument.dart';
import 'pitch.dart';
import 'tab/tab_fret.dart';

part 'note_event.dart';
part 'rest_event.dart';
part 'chord_event.dart';
part 'percussion_note.dart';

/// Base for all music events within a voice.
sealed class MusicEvent {
  const MusicEvent({required this.offset, required this.noteValue});

  /// Position within the measure in whole-note units.
  final Fraction offset;

  /// Duration of this event.
  final NoteValue noteValue;
}
