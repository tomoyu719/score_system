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

  Measure copyWith({MeasureId? id, IMap<VoiceId, Voice>? voices}) => Measure(
        id: id ?? this.id,
        voices: voices ?? this.voices,
      );
}
