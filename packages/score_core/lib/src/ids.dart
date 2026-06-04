import 'package:uuid/uuid.dart';

extension type const NoteId(String value) {}

extension type const RestId(String value) {}

extension type const ChordId(String value) {}

extension type const VoiceId(String value) {}

extension type const MeasureId(String value) {}

extension type const StaffId(String value) {}

extension type const PartId(String value) {}

extension type const ScoreId(String value) {}

extension type const BeamGroupId(String value) {}

extension type const SlurId(String value) {}

extension type const TieId(String value) {}

extension type const TupletId(String value) {}

extension type const PercussionNoteId(String value) {}

/// Generates UUID v4 values for all ID types. Use only at system boundaries.
final class IdFactory {
  IdFactory._();

  static const _uuid = Uuid();

  static NoteId note() => NoteId(_uuid.v4());
  static RestId rest() => RestId(_uuid.v4());
  static ChordId chord() => ChordId(_uuid.v4());
  static VoiceId voice() => VoiceId(_uuid.v4());
  static MeasureId measure() => MeasureId(_uuid.v4());
  static StaffId staff() => StaffId(_uuid.v4());
  static PartId part() => PartId(_uuid.v4());
  static ScoreId score() => ScoreId(_uuid.v4());
  static BeamGroupId beamGroup() => BeamGroupId(_uuid.v4());
  static SlurId slur() => SlurId(_uuid.v4());
  static TieId tie() => TieId(_uuid.v4());
  static TupletId tuplet() => TupletId(_uuid.v4());
  static PercussionNoteId percussionNote() => PercussionNoteId(_uuid.v4());
}
