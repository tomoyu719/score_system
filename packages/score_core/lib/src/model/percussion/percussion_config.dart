import 'drum_mapping.dart';

/// Percussion configuration for a staff: wraps the active [DrumMapping].
final class PercussionConfig {
  const PercussionConfig({required this.drumMapping});

  final DrumMapping drumMapping;

  PercussionConfig copyWith({DrumMapping? drumMapping}) =>
      PercussionConfig(drumMapping: drumMapping ?? this.drumMapping);

  @override
  bool operator ==(Object other) {
    if (other is! PercussionConfig) return false;
    return drumMapping == other.drumMapping;
  }

  @override
  int get hashCode => drumMapping.hashCode;
}
