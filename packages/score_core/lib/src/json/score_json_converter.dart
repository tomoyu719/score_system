import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';
import '../model/articulation.dart';
import '../model/barline.dart';
import '../model/beam_group.dart';
import '../model/dynamic.dart';
import '../model/fingering.dart';
import '../model/fraction.dart';
import '../model/key_signature.dart';
import '../model/lyric.dart';
import '../model/measure.dart';
import '../model/measure_header.dart';
import '../model/music_event.dart'; // NoteEvent, RestEvent, ChordEvent, PercussionNote via parts
import '../model/note_type.dart';
import '../model/note_value.dart';
import '../model/part.dart';
import '../model/percussion/drum_instrument.dart';
import '../model/percussion/drum_mapping.dart';
import '../model/percussion/note_head_type.dart';
import '../model/percussion/percussion_config.dart';
import '../model/pitch.dart';
import '../model/placement.dart';
import '../model/rest_positioning_policy.dart';
import '../model/score.dart';
import '../model/slur.dart';
import '../model/staff.dart';
import '../model/stem_direction.dart';
import '../model/tab/guitar_technique.dart';
import '../model/tab/tab_config.dart';
import '../model/tab/tab_fret.dart';
import '../model/tempo.dart';
import '../model/tie.dart';
import '../model/time_signature.dart';
import '../model/tuplet.dart';
import '../model/voice.dart';
import '../score_exception.dart';

/// Converts [Score] to/from plain [Map] representations.
///
/// All model classes remain pure data classes; this class owns the wire format.
final class ScoreJsonConverter {
  const ScoreJsonConverter();

  Map<String, Object?> scoreToMap(Score score) => {
        'id': score.id.value,
        'title': score.title,
        'composer': score.composer,
        'parts': score.parts.map(_partToMap).toList(),
        'measureHeaders': score.measureHeaders.map(_measureHeaderToMap).toList(),
        'beamGroups': score.beamGroups.map(_beamGroupToMap).toList(),
        'slurs': score.slurs.map(_slurToMap).toList(),
        'ties': score.ties.map(_tieToMap).toList(),
        'tuplets': score.tuplets.map(_tupletToMap).toList(),
      };

  Score scoreFromMap(Map<String, Object?> map) => Score(
        id: ScoreId(map['id'] as String),
        title: map['title'] as String? ?? '',
        composer: map['composer'] as String? ?? '',
        parts: IList(
          (map['parts'] as List<dynamic>? ?? [])
              .map((e) => _partFromMap(e as Map<String, Object?>)),
        ),
        measureHeaders: IList(
          (map['measureHeaders'] as List<dynamic>? ?? [])
              .map((e) => _measureHeaderFromMap(e as Map<String, Object?>)),
        ),
        beamGroups: IList(
          (map['beamGroups'] as List<dynamic>? ?? [])
              .map((e) => _beamGroupFromMap(e as Map<String, Object?>)),
        ),
        slurs: IList(
          (map['slurs'] as List<dynamic>? ?? [])
              .map((e) => _slurFromMap(e as Map<String, Object?>)),
        ),
        ties: IList(
          (map['ties'] as List<dynamic>? ?? [])
              .map((e) => _tieFromMap(e as Map<String, Object?>)),
        ),
        tuplets: IList(
          (map['tuplets'] as List<dynamic>? ?? [])
              .map((e) => _tupletFromMap(e as Map<String, Object?>)),
        ),
      );

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

  Map<String, Object?> _staffToMap(Staff staff) {
    final m = <String, Object?>{
      'id': staff.id.value,
      'staffType': staff.staffType.name,
      'measures': {
        for (final entry in staff.measures.entries)
          entry.key.toString(): _measureToMap(entry.value),
      },
    };
    if (staff.tabConfig != null) m['tabConfig'] = _tabConfigToMap(staff.tabConfig!);
    if (staff.percussionConfig != null) {
      m['percussionConfig'] = _percussionConfigToMap(staff.percussionConfig!);
    }
    return m;
  }

  Staff _staffFromMap(Map<String, Object?> map) {
    final measuresRaw = map['measures'] as Map<String, Object?>? ?? {};
    var ms = IMap<int, Measure>({});
    for (final entry in measuresRaw.entries) {
      ms = ms.add(int.parse(entry.key), _measureFromMap(entry.value as Map<String, Object?>));
    }
    return Staff(
      id: StaffId(map['id'] as String),
      staffType: StaffType.values.byName(map['staffType'] as String? ?? 'standard'),
      tabConfig: map['tabConfig'] == null
          ? null
          : _tabConfigFromMap(map['tabConfig'] as Map<String, Object?>),
      percussionConfig: map['percussionConfig'] == null
          ? null
          : _percussionConfigFromMap(map['percussionConfig'] as Map<String, Object?>),
      measures: ms,
    );
  }

  Map<String, Object?> _measureToMap(Measure measure) => {
        'id': measure.id.value,
        'voices': {
          for (final entry in measure.voices.entries)
            entry.key.value: _voiceToMap(entry.value),
        },
      };

  Measure _measureFromMap(Map<String, Object?> map) {
    final voicesRaw = map['voices'] as Map<String, Object?>? ?? {};
    var vs = IMap<VoiceId, Voice>({});
    for (final entry in voicesRaw.entries) {
      vs = vs.add(VoiceId(entry.key), _voiceFromMap(entry.value as Map<String, Object?>));
    }
    return Measure(
      id: MeasureId(map['id'] as String),
      voices: vs,
    );
  }

  Map<String, Object?> _voiceToMap(Voice voice) => {
        'id': voice.id.value,
        'voiceNumber': voice.voiceNumber,
        'priority': voice.priority,
        'stemDirectionPolicy': voice.stemDirectionPolicy.name,
        'restPositioningPolicy': voice.restPositioningPolicy.name,
        'isHidden': voice.isHidden,
        'isPlayback': voice.isPlayback,
        'events': voice.events.map(_musicEventToMap).toList(),
      };

  Voice _voiceFromMap(Map<String, Object?> map) => Voice(
        id: VoiceId(map['id'] as String),
        voiceNumber: map['voiceNumber'] as int? ?? 1,
        priority: map['priority'] as int? ?? 0,
        stemDirectionPolicy: StemDirection.values.byName(
          map['stemDirectionPolicy'] as String? ?? 'auto',
        ),
        restPositioningPolicy: RestPositioningPolicy.values.byName(
          map['restPositioningPolicy'] as String? ?? 'auto',
        ),
        isHidden: map['isHidden'] as bool? ?? false,
        isPlayback: map['isPlayback'] as bool? ?? false,
        events: IList(
          (map['events'] as List<dynamic>? ?? [])
              .map((e) => _musicEventFromMap(e as Map<String, Object?>)),
        ),
      );

  Map<String, Object?> _musicEventToMap(MusicEvent event) => switch (event) {
        NoteEvent() => _noteEventToMap(event),
        RestEvent() => _restEventToMap(event),
        ChordEvent() => _chordEventToMap(event),
        PercussionNote() => _percussionNoteToMap(event),
      };

  MusicEvent _musicEventFromMap(Map<String, Object?> map) =>
      switch (map['type'] as String) {
        'note' => _noteEventFromMap(map),
        'rest' => _restEventFromMap(map),
        'chord' => _chordEventFromMap(map),
        'percussion' => _percussionNoteFromMap(map),
        final t => throw ScoreException('Unknown event type: $t'),
      };

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
    if (note.fingering != null) m['fingering'] = _fingeringToMap(note.fingering!);
    if (note.tabFret != null) m['tabFret'] = _tabFretToMap(note.tabFret!);
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
        tabFret: map['tabFret'] == null
            ? null
            : _tabFretFromMap(map['tabFret'] as Map<String, Object?>),
      );

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

  Map<String, Object?> _noteValueToMap(NoteValue nv) {
    final m = <String, Object?>{
      'noteType': nv.noteType.name,
      'dots': nv.dots,
    };
    if (nv.tupletRatio != null) m['tupletRatio'] = nv.tupletRatio.toString();
    return m;
  }

  NoteValue _noteValueFromMap(Map<String, Object?> map) => NoteValue(
        noteType: NoteType.values.byName(map['noteType'] as String),
        dots: map['dots'] as int? ?? 0,
        tupletRatio: map['tupletRatio'] == null
            ? null
            : Fraction.fromString(map['tupletRatio'] as String),
      );

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

  Map<String, Object?> _fingeringToMap(Fingering f) => {
        'value': f.value,
        'isSubstitution': f.isSubstitution,
      };

  Fingering _fingeringFromMap(Map<String, Object?> map) => Fingering(
        value: map['value'] as int,
        isSubstitution: map['isSubstitution'] as bool? ?? false,
      );

  Map<String, Object?> _tabConfigToMap(TabConfig tc) => {
        'stringCount': tc.stringCount,
        'tuning': tc.tuning.map(_pitchToMap).toList(),
        'capo': tc.capo,
      };

  TabConfig _tabConfigFromMap(Map<String, Object?> map) => TabConfig(
        stringCount: map['stringCount'] as int,
        tuning: IList(
          (map['tuning'] as List<dynamic>)
              .map((e) => _pitchFromMap(e as Map<String, Object?>)),
        ),
        capo: map['capo'] as int? ?? 0,
      );

  Map<String, Object?> _tabFretToMap(TabFret tf) => {
        'stringNumber': tf.stringNumber,
        'fretNumber': tf.fretNumber,
        'techniques': tf.techniques.map((t) => t.name).toList(),
        'isManualOverride': tf.isManualOverride,
      };

  TabFret _tabFretFromMap(Map<String, Object?> map) => TabFret(
        stringNumber: map['stringNumber'] as int,
        fretNumber: map['fretNumber'] as int,
        techniques: IList(
          (map['techniques'] as List<dynamic>? ?? [])
              .map((e) => GuitarTechnique.values.byName(e as String)),
        ),
        isManualOverride: map['isManualOverride'] as bool? ?? false,
      );

  Map<String, Object?> _percussionConfigToMap(PercussionConfig pc) =>
      {'drumMapping': _drumMappingToMap(pc.drumMapping)};

  PercussionConfig _percussionConfigFromMap(Map<String, Object?> map) =>
      PercussionConfig(
        drumMapping: _drumMappingFromMap(map['drumMapping'] as Map<String, Object?>),
      );

  Map<String, Object?> _drumMappingToMap(DrumMapping dm) => {
        'instruments': {
          for (final entry in dm.midiNoteToInstrument.entries)
            entry.key.toString(): _drumInstrumentToMap(entry.value),
        },
      };

  DrumMapping _drumMappingFromMap(Map<String, Object?> map) {
    final raw = map['instruments'] as Map<String, Object?>? ?? {};
    var instruments = IMap<int, DrumInstrument>({});
    for (final entry in raw.entries) {
      instruments = instruments.add(
        int.parse(entry.key),
        _drumInstrumentFromMap(entry.value as Map<String, Object?>),
      );
    }
    return DrumMapping(midiNoteToInstrument: instruments);
  }

  Map<String, Object?> _drumInstrumentToMap(DrumInstrument di) => {
        'name': di.name,
        'staffLine': di.staffLine,
        'noteHeadType': di.noteHeadType.name,
        'midiNote': di.midiNote,
      };

  DrumInstrument _drumInstrumentFromMap(Map<String, Object?> map) =>
      DrumInstrument(
        name: map['name'] as String,
        staffLine: map['staffLine'] as int,
        noteHeadType: NoteHeadType.values.byName(map['noteHeadType'] as String),
        midiNote: map['midiNote'] as int,
      );

  Map<String, Object?> _percussionNoteToMap(PercussionNote pn) => {
        'type': 'percussion',
        'id': pn.id.value,
        'offset': pn.offset.toString(),
        'noteValue': _noteValueToMap(pn.noteValue),
        'instrument': _drumInstrumentToMap(pn.instrument),
        'isGrace': pn.isGrace,
        'articulations': pn.articulations.map(_articulationToMap).toList(),
      };

  PercussionNote _percussionNoteFromMap(Map<String, Object?> map) =>
      PercussionNote(
        id: PercussionNoteId(map['id'] as String),
        offset: Fraction.fromString(map['offset'] as String),
        noteValue: _noteValueFromMap(map['noteValue'] as Map<String, Object?>),
        instrument: _drumInstrumentFromMap(map['instrument'] as Map<String, Object?>),
        isGrace: map['isGrace'] as bool? ?? false,
        articulations: IList(
          (map['articulations'] as List<dynamic>? ?? [])
              .map((e) => _articulationFromMap(e as Map<String, Object?>)),
        ),
      );

  Map<String, Object?> _measureHeaderToMap(MeasureHeader h) {
    final m = <String, Object?>{
      'measureNumber': h.measureNumber,
      'timeSignature': _timeSignatureToMap(h.timeSignature),
      'keySignature': _keySignatureToMap(h.keySignature),
      'barlineStart': h.barlineStart.name,
      'barlineEnd': h.barlineEnd.name,
    };
    if (h.tempo != null) m['tempo'] = _tempoToMap(h.tempo!);
    return m;
  }

  MeasureHeader _measureHeaderFromMap(Map<String, Object?> map) => MeasureHeader(
        measureNumber: map['measureNumber'] as int,
        timeSignature: _timeSignatureFromMap(map['timeSignature'] as Map<String, Object?>),
        keySignature: _keySignatureFromMap(map['keySignature'] as Map<String, Object?>),
        tempo: map['tempo'] == null
            ? null
            : _tempoFromMap(map['tempo'] as Map<String, Object?>),
        barlineStart: BarlineType.values.byName(map['barlineStart'] as String? ?? 'regular'),
        barlineEnd: BarlineType.values.byName(map['barlineEnd'] as String? ?? 'regular'),
      );

  Map<String, Object?> _timeSignatureToMap(TimeSignature ts) => {
        'beats': ts.beats,
        'beatType': ts.beatType,
      };

  TimeSignature _timeSignatureFromMap(Map<String, Object?> map) => TimeSignature(
        beats: map['beats'] as int,
        beatType: map['beatType'] as int,
      );

  Map<String, Object?> _keySignatureToMap(KeySignature ks) => {
        'fifths': ks.fifths,
        'mode': ks.mode.name,
      };

  KeySignature _keySignatureFromMap(Map<String, Object?> map) => KeySignature(
        fifths: map['fifths'] as int,
        mode: Mode.values.byName(map['mode'] as String? ?? 'major'),
      );

  Map<String, Object?> _tempoToMap(Tempo t) => {
        'bpm': t.bpm,
        'beatUnit': t.beatUnit.name,
      };

  Tempo _tempoFromMap(Map<String, Object?> map) => Tempo(
        bpm: (map['bpm'] as num).toDouble(),
        beatUnit: NoteType.values.byName(map['beatUnit'] as String? ?? 'quarter'),
      );

  Map<String, Object?> _beamGroupToMap(BeamGroup bg) => {
        'id': bg.id.value,
        'noteIds': bg.noteIds.map((n) => n.value).toList(),
      };

  BeamGroup _beamGroupFromMap(Map<String, Object?> map) => BeamGroup(
        id: BeamGroupId(map['id'] as String),
        noteIds: IList(
          (map['noteIds'] as List<dynamic>).map((e) => NoteId(e as String)),
        ),
      );

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

  Map<String, Object?> _tupletToMap(Tuplet tuplet) => {
        'id': tuplet.id.value,
        'noteIds': tuplet.noteIds.map((n) => n.value).toList(),
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
