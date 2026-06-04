import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';
import 'clef.dart';
import 'measure.dart';
import 'percussion/percussion_config.dart';
import 'tab/tab_config.dart';
import 'voice.dart';

/// Staff type determines how the staff is rendered and edited.
enum StaffType { standard, tab, percussion, percussionTab }

/// A single staff (line group) within a Part.
///
/// Measures are keyed by 1-based measure number.
final class Staff {
  const Staff({
    required this.id,
    this.staffType = StaffType.standard,
    this.clef = Clef.treble,
    this.tabConfig,
    this.percussionConfig,
    this.measures = const IMapConst({}),
  });

  final StaffId id;
  final StaffType staffType;

  /// Active clef; drives pitch-to-staff-line conversion in score_layout.
  final Clef clef;

  /// TAB configuration; non-null when [staffType] is [StaffType.tab].
  final TabConfig? tabConfig;

  /// Percussion configuration; non-null when [staffType] is [StaffType.percussion] or [StaffType.percussionTab].
  final PercussionConfig? percussionConfig;

  /// Measures keyed by 1-based measure number.
  final IMap<int, Measure> measures;

  /// Returns the [Voice] at [measureNumber] with [voiceId], or null if either
  /// the measure or the voice does not exist.
  Voice? findVoice(int measureNumber, VoiceId voiceId) =>
      measures[measureNumber]?.voices[voiceId];

  /// Returns a new [Staff] with the measure at [measureNumber] transformed by
  /// [updater]. Creates an empty [Measure] if that number does not yet exist.
  Staff updateMeasure(int measureNumber, Measure Function(Measure) updater) {
    final existing = measures[measureNumber] ?? Measure(id: IdFactory.measure());
    return copyWith(measures: measures.add(measureNumber, updater(existing)));
  }

  Staff copyWith({
    StaffId? id,
    StaffType? staffType,
    Clef? clef,
    TabConfig? tabConfig,
    PercussionConfig? percussionConfig,
    IMap<int, Measure>? measures,
  }) =>
      Staff(
        id: id ?? this.id,
        staffType: staffType ?? this.staffType,
        clef: clef ?? this.clef,
        tabConfig: tabConfig ?? this.tabConfig,
        percussionConfig: percussionConfig ?? this.percussionConfig,
        measures: measures ?? this.measures,
      );
}
