import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';

import 'layout_element.dart';

/// Layout data for a single voice within a measure.
final class VoiceLayout {
  const VoiceLayout({
    required this.voiceId,
    this.notes = const IListConst([]),
    this.percussionNotes = const IListConst([]),
    this.rests = const IListConst([]),
    this.beams = const IListConst([]),
    this.stems = const IListConst([]),
  });

  final VoiceId voiceId;
  final IList<NoteLayout> notes;
  final IList<PercussionNoteLayout> percussionNotes;
  final IList<RestLayout> rests;
  final IList<BeamLayout> beams;
  final IList<StemLayout> stems;

  VoiceLayout copyWith({
    VoiceId? voiceId,
    IList<NoteLayout>? notes,
    IList<PercussionNoteLayout>? percussionNotes,
    IList<RestLayout>? rests,
    IList<BeamLayout>? beams,
    IList<StemLayout>? stems,
  }) =>
      VoiceLayout(
        voiceId: voiceId ?? this.voiceId,
        notes: notes ?? this.notes,
        percussionNotes: percussionNotes ?? this.percussionNotes,
        rests: rests ?? this.rests,
        beams: beams ?? this.beams,
        stems: stems ?? this.stems,
      );

  Map<String, Object?> toJson() => {
        'voiceId': voiceId.value,
        'notes': notes.map((n) => n.toJson()).toList(),
        'percussionNotes': percussionNotes.map((n) => n.toJson()).toList(),
        'rests': rests.map((r) => r.toJson()).toList(),
        'beams': beams.map((b) => b.toJson()).toList(),
        'stems': stems.map((s) => s.toJson()).toList(),
      };

  static VoiceLayout fromJson(Map<String, Object?> map) => VoiceLayout(
        voiceId: VoiceId(map['voiceId'] as String),
        notes: IList(
          (map['notes'] as List<dynamic>? ?? [])
              .map((e) => NoteLayout.fromJson(e as Map<String, Object?>)),
        ),
        percussionNotes: IList(
          (map['percussionNotes'] as List<dynamic>? ?? [])
              .map((e) => PercussionNoteLayout.fromJson(e as Map<String, Object?>)),
        ),
        rests: IList(
          (map['rests'] as List<dynamic>? ?? [])
              .map((e) => RestLayout.fromJson(e as Map<String, Object?>)),
        ),
        beams: IList(
          (map['beams'] as List<dynamic>? ?? [])
              .map((e) => BeamLayout.fromJson(e as Map<String, Object?>)),
        ),
        stems: IList(
          (map['stems'] as List<dynamic>? ?? [])
              .map((e) => StemLayout.fromJson(e as Map<String, Object?>)),
        ),
      );

  @override
  bool operator ==(Object other) {
    if (other is! VoiceLayout) return false;
    return voiceId == other.voiceId &&
        notes == other.notes &&
        percussionNotes == other.percussionNotes &&
        rests == other.rests &&
        beams == other.beams &&
        stems == other.stems;
  }

  @override
  int get hashCode =>
      Object.hash(voiceId, notes, percussionNotes, rests, beams, stems);
}
