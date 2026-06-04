import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';
import 'voice.dart';

/// A single measure containing one or more voices.
final class Measure {
  const Measure({
    required this.id,
    this.voices = const IMapConst({}),
  });

  final MeasureId id;

  /// Voices keyed by VoiceId.
  final IMap<VoiceId, Voice> voices;

  /// Returns a new [Measure] with the voice identified by [id] transformed by
  /// [updater]. Creates an empty [Voice] if that ID does not yet exist.
  Measure updateVoice(VoiceId id, Voice Function(Voice) updater) {
    final existing = voices[id] ?? Voice(id: id);
    return copyWith(voices: voices.add(id, updater(existing)));
  }

  /// Returns voices sorted by [Voice.priority] ascending, then [Voice.voiceNumber] ascending.
  Iterable<Voice> get voicesSortedByPriority {
    final sorted = voices.values.toList()
      ..sort((a, b) {
        final p = a.priority.compareTo(b.priority);
        return p != 0 ? p : a.voiceNumber.compareTo(b.voiceNumber);
      });
    return sorted;
  }

  Measure copyWith({MeasureId? id, IMap<VoiceId, Voice>? voices}) => Measure(
        id: id ?? this.id,
        voices: voices ?? this.voices,
      );
}
