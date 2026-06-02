import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';

/// Serializes and deserializes [Score] to/from JSON maps and strings.
final class ScoreSerializer {
  const ScoreSerializer();

  static const int schemaVersion = 1;

  Map<String, Object?> toMap(Score score) => {
        r'$schema_version': schemaVersion,
        'id': score.id.value,
        'title': score.title,
        'composer': score.composer,
        'parts': score.parts.map(_partToMap).toList(),
        'measureHeaders': score.measureHeaders.map(_headerToMap).toList(),
        'beamGroups': score.beamGroups.map(_beamGroupToMap).toList(),
        'slurs': score.slurs.map(_slurToMap).toList(),
        'ties': score.ties.map(_tieToMap).toList(),
        'tuplets': score.tuplets.map(_tupletToMap).toList(),
      };

  Score fromMap(Map<String, Object?> map) => Score(
        id: ScoreId(map['id'] as String),
        title: map['title'] as String? ?? '',
        composer: map['composer'] as String? ?? '',
        parts: IList(
          (map['parts'] as List<dynamic>? ?? []).map((e) => _partFromMap(e as Map<String, Object?>)),
        ),
        measureHeaders: IList(
          (map['measureHeaders'] as List<dynamic>? ?? [])
              .map((e) => _headerFromMap(e as Map<String, Object?>)),
        ),
        beamGroups: IList(
          (map['beamGroups'] as List<dynamic>? ?? [])
              .map((e) => _beamGroupFromMap(e as Map<String, Object?>)),
        ),
        slurs: IList(
          (map['slurs'] as List<dynamic>? ?? []).map((e) => _slurFromMap(e as Map<String, Object?>)),
        ),
        ties: IList(
          (map['ties'] as List<dynamic>? ?? []).map((e) => _tieFromMap(e as Map<String, Object?>)),
        ),
        tuplets: IList(
          (map['tuplets'] as List<dynamic>? ?? [])
              .map((e) => _tupletFromMap(e as Map<String, Object?>)),
        ),
      );

  String toJson(Score score) =>
      const JsonEncoder.withIndent('  ').convert(toMap(score));

  Score fromJson(String json) =>
      fromMap(jsonDecode(json) as Map<String, Object?>);

  // --- Part ---

  Map<String, Object?> _partToMap(Part part) => {
        'id': part.id.value,
        'name': part.name,
        'shortName': part.shortName,
        'staves': part.staves.map(_staffToMap).toList(),
      };

  Part _partFromMap(Map<String, Object?> map) => Part(
        id: PartId(map['id'] as String),
        name: map['name'] as String,
        shortName: map['shortName'] as String? ?? '',
        staves: IList(
          (map['staves'] as List<dynamic>? ?? [])
              .map((e) => _staffFromMap(e as Map<String, Object?>)),
        ),
      );

  // --- Staff ---

  Map<String, Object?> _staffToMap(Staff staff) => {
        'id': staff.id.value,
        'staffType': staff.staffType.name,
        'measures': {
          for (final entry in staff.measures.entries)
            entry.key.toString(): _measureToMap(entry.value),
        },
      };

  Staff _staffFromMap(Map<String, Object?> map) {
    final measuresRaw = map['measures'] as Map<String, Object?>? ?? {};
    var measures = IMap<int, Measure>({});
    for (final entry in measuresRaw.entries) {
      measures = measures.add(
        int.parse(entry.key),
        _measureFromMap(entry.value as Map<String, Object?>),
      );
    }
    return Staff(
      id: StaffId(map['id'] as String),
      staffType: StaffType.values.byName(map['staffType'] as String? ?? 'standard'),
      measures: measures,
    );
  }

  // --- Measure ---

  Map<String, Object?> _measureToMap(Measure measure) => {
        'id': measure.id.value,
        'voices': {
          for (final entry in measure.voices.entries)
            entry.key.value: _voiceToMap(entry.value),
        },
      };

  Measure _measureFromMap(Map<String, Object?> map) {
    final voicesRaw = map['voices'] as Map<String, Object?>? ?? {};
    var voices = IMap<VoiceId, Voice>({});
    for (final entry in voicesRaw.entries) {
      final voiceId = VoiceId(entry.key);
      voices = voices.add(voiceId, _voiceFromMap(entry.value as Map<String, Object?>));
    }
    return Measure(
      id: MeasureId(map['id'] as String),
      voices: voices,
    );
  }

  // --- Voice ---

  Map<String, Object?> _voiceToMap(Voice voice) => {
        'id': voice.id.value,
        'events': voice.events.map(_eventToMap).toList(),
      };

  Voice _voiceFromMap(Map<String, Object?> map) => Voice(
        id: VoiceId(map['id'] as String),
        events: IList(
          (map['events'] as List<dynamic>? ?? [])
              .map((e) => _eventFromMap(e as Map<String, Object?>)),
        ),
      );

  // --- MusicEvent ---

  Map<String, Object?> _eventToMap(MusicEvent event) => switch (event) {
        NoteEvent() => _noteEventToMap(event),
        RestEvent() => _restEventToMap(event),
        ChordEvent() => _chordEventToMap(event),
      };

  MusicEvent _eventFromMap(Map<String, Object?> map) {
    final type = map['type'] as String;
    return switch (type) {
      'note' => _noteEventFromMap(map),
      'rest' => _restEventFromMap(map),
      'chord' => _chordEventFromMap(map),
      _ => throw ScoreException('Unknown event type: $type'),
    };
  }

  // --- NoteEvent ---

  Map<String, Object?> _noteEventToMap(NoteEvent note) {
    final m = <String, Object?>{
      'type': 'note',
      'id': note.id.value,
      'offset': note.offset.toString(),
      'noteValue': _noteValueToMap(note.noteValue),
      'pitch': _pitchToMap(note.pitch),
      'isGrace': note.isGrace,
      'articulations': note.articulations.map(_articulationToMap).toList(),
      'dynamics': note.dynamics.map(_dynamicToMap).toList(),
      'lyrics': note.lyrics.map(_lyricToMap).toList(),
    };
    if (note.fingering != null) {
      m['fingering'] = _fingeringToMap(note.fingering!);
    }
    return m;
  }

  NoteEvent _noteEventFromMap(Map<String, Object?> map) => NoteEvent(
        id: NoteId(map['id'] as String),
        offset: Fraction.fromString(map['offset'] as String),
        noteValue: _noteValueFromMap(map['noteValue'] as Map<String, Object?>),
        pitch: _pitchFromMap(map['pitch'] as Map<String, Object?>),
        isGrace: map['isGrace'] as bool? ?? false,
        articulations: IList(
          (map['articulations'] as List<dynamic>? ?? [])
              .map((e) => _articulationFromMap(e as Map<String, Object?>)),
        ),
        dynamics: IList(
          (map['dynamics'] as List<dynamic>? ?? [])
              .map((e) => _dynamicFromMap(e as Map<String, Object?>)),
        ),
        lyrics: IList(
          (map['lyrics'] as List<dynamic>? ?? [])
              .map((e) => _lyricFromMap(e as Map<String, Object?>)),
        ),
        fingering: map['fingering'] == null
            ? null
            : _fingeringFromMap(map['fingering'] as Map<String, Object?>),
      );

  // --- RestEvent ---

  Map<String, Object?> _restEventToMap(RestEvent rest) => {
        'type': 'rest',
        'id': rest.id.value,
        'offset': rest.offset.toString(),
        'noteValue': _noteValueToMap(rest.noteValue),
        'isFullMeasure': rest.isFullMeasure,
      };

  RestEvent _restEventFromMap(Map<String, Object?> map) => RestEvent(
        id: RestId(map['id'] as String),
        offset: Fraction.fromString(map['offset'] as String),
        noteValue: _noteValueFromMap(map['noteValue'] as Map<String, Object?>),
        isFullMeasure: map['isFullMeasure'] as bool? ?? false,
      );

  // --- ChordEvent ---

  Map<String, Object?> _chordEventToMap(ChordEvent chord) => {
        'type': 'chord',
        'id': chord.id.value,
        'offset': chord.offset.toString(),
        'noteValue': _noteValueToMap(chord.noteValue),
        'notes': chord.notes.map(_noteEventToMap).toList(),
        'articulations': chord.articulations.map(_articulationToMap).toList(),
        'dynamics': chord.dynamics.map(_dynamicToMap).toList(),
      };

  ChordEvent _chordEventFromMap(Map<String, Object?> map) => ChordEvent(
        id: ChordId(map['id'] as String),
        offset: Fraction.fromString(map['offset'] as String),
        noteValue: _noteValueFromMap(map['noteValue'] as Map<String, Object?>),
        notes: IList(
          (map['notes'] as List<dynamic>? ?? [])
              .map((e) => _noteEventFromMap(e as Map<String, Object?>)),
        ),
        articulations: IList(
          (map['articulations'] as List<dynamic>? ?? [])
              .map((e) => _articulationFromMap(e as Map<String, Object?>)),
        ),
        dynamics: IList(
          (map['dynamics'] as List<dynamic>? ?? [])
              .map((e) => _dynamicFromMap(e as Map<String, Object?>)),
        ),
      );

  // --- NoteValue ---

  Map<String, Object?> _noteValueToMap(NoteValue nv) {
    final m = <String, Object?>{
      'noteType': nv.noteType.name,
      'dots': nv.dots,
    };
    if (nv.tupletRatio != null) {
      m['tupletRatio'] = nv.tupletRatio.toString();
    }
    return m;
  }

  NoteValue _noteValueFromMap(Map<String, Object?> map) => NoteValue(
        noteType: NoteType.values.byName(map['noteType'] as String),
        dots: map['dots'] as int? ?? 0,
        tupletRatio: map['tupletRatio'] == null
            ? null
            : Fraction.fromString(map['tupletRatio'] as String),
      );

  // --- Pitch ---

  Map<String, Object?> _pitchToMap(Pitch pitch) => {
        'step': pitch.step.name,
        'alter': pitch.alter,
        'octave': pitch.octave,
      };

  Pitch _pitchFromMap(Map<String, Object?> map) => Pitch(
        step: Step.values.byName(map['step'] as String),
        alter: (map['alter'] as num).toDouble(),
        octave: map['octave'] as int,
      );

  // --- Articulation ---

  Map<String, Object?> _articulationToMap(Articulation a) {
    final m = <String, Object?>{'type': a.type.name};
    if (a.placement != null) m['placement'] = a.placement!.name;
    return m;
  }

  Articulation _articulationFromMap(Map<String, Object?> map) => Articulation(
        type: ArticulationType.values.byName(map['type'] as String),
        placement: map['placement'] == null
            ? null
            : Placement.values.byName(map['placement'] as String),
      );

  // --- Dynamic ---

  Map<String, Object?> _dynamicToMap(Dynamic d) {
    final m = <String, Object?>{'type': d.type.name};
    if (d.placement != null) m['placement'] = d.placement!.name;
    return m;
  }

  Dynamic _dynamicFromMap(Map<String, Object?> map) => Dynamic(
        type: DynamicType.values.byName(map['type'] as String),
        placement: map['placement'] == null
            ? null
            : Placement.values.byName(map['placement'] as String),
      );

  // --- Lyric ---

  Map<String, Object?> _lyricToMap(Lyric l) => {
        'text': l.text,
        'syllabic': l.syllabic.name,
        'number': l.number,
      };

  Lyric _lyricFromMap(Map<String, Object?> map) => Lyric(
        text: map['text'] as String,
        syllabic: Syllabic.values.byName(map['syllabic'] as String? ?? 'single'),
        number: map['number'] as int? ?? 1,
      );

  // --- Fingering ---

  Map<String, Object?> _fingeringToMap(Fingering f) => {
        'value': f.value,
        'isSubstitution': f.isSubstitution,
      };

  Fingering _fingeringFromMap(Map<String, Object?> map) => Fingering(
        value: map['value'] as int,
        isSubstitution: map['isSubstitution'] as bool? ?? false,
      );

  // --- MeasureHeader ---

  Map<String, Object?> _headerToMap(MeasureHeader h) {
    final m = <String, Object?>{
      'measureNumber': h.measureNumber,
      'timeSignature': _timeSigToMap(h.timeSignature),
      'keySignature': _keySigToMap(h.keySignature),
      'barlineStart': h.barlineStart.name,
      'barlineEnd': h.barlineEnd.name,
    };
    if (h.tempo != null) m['tempo'] = _tempoToMap(h.tempo!);
    return m;
  }

  MeasureHeader _headerFromMap(Map<String, Object?> map) => MeasureHeader(
        measureNumber: map['measureNumber'] as int,
        timeSignature: _timeSigFromMap(map['timeSignature'] as Map<String, Object?>),
        keySignature: _keySigFromMap(map['keySignature'] as Map<String, Object?>),
        tempo: map['tempo'] == null
            ? null
            : _tempoFromMap(map['tempo'] as Map<String, Object?>),
        barlineStart: BarlineType.values.byName(map['barlineStart'] as String? ?? 'regular'),
        barlineEnd: BarlineType.values.byName(map['barlineEnd'] as String? ?? 'regular'),
      );

  // --- TimeSignature ---

  Map<String, Object?> _timeSigToMap(TimeSignature ts) => {
        'beats': ts.beats,
        'beatType': ts.beatType,
      };

  TimeSignature _timeSigFromMap(Map<String, Object?> map) => TimeSignature(
        beats: map['beats'] as int,
        beatType: map['beatType'] as int,
      );

  // --- KeySignature ---

  Map<String, Object?> _keySigToMap(KeySignature ks) => {
        'fifths': ks.fifths,
        'mode': ks.mode.name,
      };

  KeySignature _keySigFromMap(Map<String, Object?> map) => KeySignature(
        fifths: map['fifths'] as int,
        mode: Mode.values.byName(map['mode'] as String? ?? 'major'),
      );

  // --- Tempo ---

  Map<String, Object?> _tempoToMap(Tempo t) => {
        'bpm': t.bpm,
        'beatUnit': t.beatUnit.name,
      };

  Tempo _tempoFromMap(Map<String, Object?> map) => Tempo(
        bpm: (map['bpm'] as num).toDouble(),
        beatUnit: NoteType.values.byName(map['beatUnit'] as String? ?? 'quarter'),
      );

  // --- BeamGroup ---

  Map<String, Object?> _beamGroupToMap(BeamGroup bg) => {
        'id': bg.id.value,
        'noteIds': bg.noteIds.map((id) => id.value).toList(),
      };

  BeamGroup _beamGroupFromMap(Map<String, Object?> map) => BeamGroup(
        id: BeamGroupId(map['id'] as String),
        noteIds: IList(
          (map['noteIds'] as List<dynamic>).map((e) => NoteId(e as String)),
        ),
      );

  // --- Slur ---

  Map<String, Object?> _slurToMap(Slur slur) {
    final m = <String, Object?>{
      'id': slur.id.value,
      'startNoteId': slur.startNoteId.value,
      'endNoteId': slur.endNoteId.value,
    };
    if (slur.placement != null) m['placement'] = slur.placement!.name;
    return m;
  }

  Slur _slurFromMap(Map<String, Object?> map) => Slur(
        id: SlurId(map['id'] as String),
        startNoteId: NoteId(map['startNoteId'] as String),
        endNoteId: NoteId(map['endNoteId'] as String),
        placement: map['placement'] == null
            ? null
            : Placement.values.byName(map['placement'] as String),
      );

  // --- Tie ---

  Map<String, Object?> _tieToMap(Tie tie) => {
        'id': tie.id.value,
        'startNoteId': tie.startNoteId.value,
        'endNoteId': tie.endNoteId.value,
      };

  Tie _tieFromMap(Map<String, Object?> map) => Tie(
        id: TieId(map['id'] as String),
        startNoteId: NoteId(map['startNoteId'] as String),
        endNoteId: NoteId(map['endNoteId'] as String),
      );

  // --- Tuplet ---

  Map<String, Object?> _tupletToMap(Tuplet tuplet) => {
        'id': tuplet.id.value,
        'noteIds': tuplet.noteIds.map((id) => id.value).toList(),
        'ratio': tuplet.ratio.toString(),
      };

  Tuplet _tupletFromMap(Map<String, Object?> map) => Tuplet(
        id: TupletId(map['id'] as String),
        noteIds: IList(
          (map['noteIds'] as List<dynamic>).map((e) => NoteId(e as String)),
        ),
        ratio: Fraction.fromString(map['ratio'] as String),
      );
}
