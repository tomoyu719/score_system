import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:xml/xml.dart';

/// Parses a MusicXML 3.1 partwise document string into a [Score].
final class MusicXmlParser {
  const MusicXmlParser();

  /// Parses [xmlString] and returns a [Score].
  ///
  /// Throws [ScoreException] for malformed input.
  Score parse(String xmlString) {
    late XmlDocument doc;
    try {
      doc = XmlDocument.parse(xmlString);
    } catch (e) {
      throw ScoreException('Failed to parse MusicXML', cause: e);
    }

    final root = doc.findElements('score-partwise').firstOrNull;
    if (root == null) {
      throw const ScoreException('Missing <score-partwise> root element');
    }

    final title = root.findElements('movement-title').firstOrNull?.innerText ?? '';
    final composer = root
            .findElements('identification')
            .firstOrNull
            ?.findElements('creator')
            .where((e) => e.getAttribute('type') == 'composer')
            .firstOrNull
            ?.innerText ??
        '';

    final partInfos = _parsePartList(root);
    final measureHeadersMap = <int, MeasureHeader>{};
    final parts = <Part>[];

    for (final partEl in root.findElements('part')) {
      final partId = partEl.getAttribute('id') ?? '';
      final partName = partInfos[partId] ?? partId;
      final (staves, headers) = _parsePart(partEl, partId);
      parts.add(Part(id: PartId(partId), name: partName, staves: IList(staves)));
      for (final h in headers) {
        final existing = measureHeadersMap[h.measureNumber];
        if (existing == null) {
          measureHeadersMap[h.measureNumber] = h;
        } else {
          measureHeadersMap[h.measureNumber] = _mergeHeaders(existing, h);
        }
      }
    }

    final sortedHeaders = measureHeadersMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Score(
      id: IdFactory.score(),
      title: title,
      composer: composer,
      parts: IList(parts),
      measureHeaders: IList(sortedHeaders.map((e) => e.value)),
    );
  }

  Map<String, String> _parsePartList(XmlElement root) {
    final map = <String, String>{};
    for (final sp in root.findElements('part-list').expand((e) => e.findElements('score-part'))) {
      final id = sp.getAttribute('id') ?? '';
      final name = sp.findElements('part-name').firstOrNull?.innerText ?? id;
      map[id] = name;
    }
    return map;
  }

  (List<Staff>, List<MeasureHeader>) _parsePart(XmlElement partEl, String partId) {
    final staffMeasures = <int, Map<int, Measure>>{};
    final measureHeaders = <int, MeasureHeader>{};

    var currentDivisions = 4;
    var currentTimeSig = const TimeSignature(beats: 4, beatType: 4);
    var currentKeySig = const KeySignature(fifths: 0);
    BarlineType currentBarlineEnd = BarlineType.regular;
    BarlineType currentBarlineStart = BarlineType.regular;
    Tempo? currentTempo;

    for (final measureEl in partEl.findElements('measure')) {
      final measureNumberRaw = measureEl.getAttribute('number');
      final measureNumber = int.tryParse(measureNumberRaw ?? '') ?? 1;
      currentBarlineEnd = BarlineType.regular;
      currentBarlineStart = BarlineType.regular;
      currentTempo = null;

      final attrsEl = measureEl.findElements('attributes').firstOrNull;
      if (attrsEl != null) {
        final divEl = attrsEl.findElements('divisions').firstOrNull;
        if (divEl != null) currentDivisions = int.parse(divEl.innerText.trim());
        final keyEl = attrsEl.findElements('key').firstOrNull;
        if (keyEl != null) currentKeySig = _parseKeySig(keyEl);
        final timeEl = attrsEl.findElements('time').firstOrNull;
        if (timeEl != null) currentTimeSig = _parseTimeSig(timeEl);
      }

      for (final dirEl in measureEl.findElements('direction')) {
        final dtEl = dirEl.findElements('direction-type').firstOrNull;
        if (dtEl == null) continue;
        final metronomeEl = dtEl.findElements('metronome').firstOrNull;
        if (metronomeEl != null) {
          currentTempo = _parseTempo(metronomeEl);
        }
      }

      for (final barlineEl in measureEl.findElements('barline')) {
        final location = barlineEl.getAttribute('location') ?? 'right';
        final styleText = barlineEl.findElements('bar-style').firstOrNull?.innerText.trim() ?? '';
        final repeatDir = barlineEl.findElements('repeat').firstOrNull?.getAttribute('direction');
        final barlineType = _parseBarlineStyle(styleText, repeatDir);
        if (location == 'right') {
          currentBarlineEnd = barlineType;
        } else {
          currentBarlineStart = barlineType;
        }
      }

      measureHeaders[measureNumber] = MeasureHeader(
        measureNumber: measureNumber,
        timeSignature: currentTimeSig,
        keySignature: currentKeySig,
        tempo: currentTempo,
        barlineEnd: currentBarlineEnd,
        barlineStart: currentBarlineStart,
      );

      final voiceEventMap = <String, Map<int, List<MusicEvent>>>{};
      final voiceOffsets = <String, Fraction>{};

      _MusicEventPending? pending;

      void flushPending(String? nextVoiceId) {
        if (pending == null) return;
        final p = pending!;
        pending = null;
        final vId = p.voiceId;
        final staffNum = p.staffNumber;
        voiceOffsets[vId] ??= Fraction.zero;
        voiceEventMap[vId] ??= {};
        voiceEventMap[vId]![staffNum] ??= [];

        MusicEvent event;
        if (p.chordNotes.length == 1 && p.chordNotes[0] is NoteEvent) {
          event = p.chordNotes[0];
        } else if (p.chordNotes.length > 1) {
          final notes = p.chordNotes.cast<NoteEvent>();
          event = ChordEvent(
            id: IdFactory.chord(),
            offset: voiceOffsets[vId]!,
            noteValue: p.noteValue,
            notes: IList(notes),
          );
        } else {
          event = p.chordNotes[0];
        }

        voiceEventMap[vId]![staffNum]!.add(event);
        voiceOffsets[vId] = voiceOffsets[vId]! + p.noteValue.toFraction();
      }

      for (final noteEl in measureEl.findElements('note')) {
        final isChord = noteEl.findElements('chord').isNotEmpty;
        final isRest = noteEl.findElements('rest').isNotEmpty;
        final voiceId = noteEl.findElements('voice').firstOrNull?.innerText.trim() ?? '1';
        final staffNum = int.tryParse(
              noteEl.findElements('staff').firstOrNull?.innerText.trim() ?? '1',
            ) ??
            1;
        final dots = noteEl.findElements('dot').length;
        final durationText = noteEl.findElements('duration').firstOrNull?.innerText.trim() ?? '4';
        final durationTicks = int.tryParse(durationText) ?? 4;

        if (!isChord) {
          flushPending(voiceId);
          voiceOffsets[voiceId] ??= Fraction.zero;
          final offset = voiceOffsets[voiceId]!;

          if (isRest) {
            final rest = RestEvent(
              id: IdFactory.rest(),
              offset: offset,
              noteValue: _noteValueFromTicks(durationTicks, currentDivisions, dots),
            );
            pending = _MusicEventPending(
              chordNotes: [rest],
              noteValue: rest.noteValue,
              voiceId: voiceId,
              staffNumber: staffNum,
            );
          } else {
            final pitch = _parsePitch(noteEl);
            final note = NoteEvent(
              id: IdFactory.note(),
              offset: offset,
              noteValue: _noteValueFromTicks(durationTicks, currentDivisions, dots),
              pitch: pitch,
            );
            pending = _MusicEventPending(
              chordNotes: [note],
              noteValue: note.noteValue,
              voiceId: voiceId,
              staffNumber: staffNum,
            );
          }
        } else {
          if (pending != null && !isRest) {
            final offset = voiceOffsets[voiceId] ?? Fraction.zero;
            final pitch = _parsePitch(noteEl);
            final note = NoteEvent(
              id: IdFactory.note(),
              offset: offset,
              noteValue: _noteValueFromTicks(durationTicks, currentDivisions, dots),
              pitch: pitch,
            );
            pending!.chordNotes.add(note);
          }
        }
      }

      flushPending(null);

      final dynamicsPerVoice = <String, List<Dynamic>>{};
      for (final dirEl in measureEl.findElements('direction')) {
        final placement = dirEl.getAttribute('placement');
        final dtEl = dirEl.findElements('direction-type').firstOrNull;
        if (dtEl == null) continue;
        final dynEl = dtEl.findElements('dynamics').firstOrNull;
        if (dynEl == null) continue;
        final dynType = _parseDynamicType(dynEl);
        if (dynType == null) continue;
        final dyn = Dynamic(
          type: dynType,
          placement: placement == 'above'
              ? Placement.above
              : placement == 'below'
                  ? Placement.below
                  : null,
        );
        for (final voiceId in voiceEventMap.keys) {
          dynamicsPerVoice[voiceId] ??= [];
          dynamicsPerVoice[voiceId]!.add(dyn);
        }
      }

      _attachDynamicsToLastNote(voiceEventMap, dynamicsPerVoice);

      for (final voiceEntry in voiceEventMap.entries) {
        final vId = voiceEntry.key;
        for (final staffEntry in voiceEntry.value.entries) {
          final staffNum = staffEntry.key;
          staffMeasures[staffNum] ??= {};
          staffMeasures[staffNum]![measureNumber] = Measure(
            id: IdFactory.measure(),
            voices: IMap({
              VoiceId(vId): Voice(
                id: VoiceId(vId),
                events: IList(staffEntry.value),
              ),
            }),
          );
        }
      }
    }

    final staves = staffMeasures.entries
        .map((entry) => Staff(
              id: StaffId('S${entry.key}'),
              measures: IMap(entry.value),
            ))
        .toList();

    if (staves.isEmpty) {
      staves.add(Staff(id: const StaffId('S1')));
    }

    return (staves, measureHeaders.values.toList());
  }

  void _attachDynamicsToLastNote(
    Map<String, Map<int, List<MusicEvent>>> voiceEventMap,
    Map<String, List<Dynamic>> dynamicsPerVoice,
  ) {
    for (final voiceId in dynamicsPerVoice.keys) {
      final dyns = dynamicsPerVoice[voiceId]!;
      if (dyns.isEmpty) continue;
      final staffEvents = voiceEventMap[voiceId];
      if (staffEvents == null) continue;
      for (final events in staffEvents.values) {
        if (events.isEmpty) continue;
        final last = events.last;
        if (last is NoteEvent) {
          events[events.length - 1] = last.copyWith(
            dynamics: last.dynamics.addAll(IList(dyns)),
          );
        } else if (last is ChordEvent) {
          events[events.length - 1] = last.copyWith(
            dynamics: last.dynamics.addAll(IList(dyns)),
          );
        }
      }
    }
  }

  MeasureHeader _mergeHeaders(MeasureHeader existing, MeasureHeader update) =>
      existing.copyWith(
        tempo: update.tempo ?? existing.tempo,
        barlineEnd: update.barlineEnd != BarlineType.regular ? update.barlineEnd : existing.barlineEnd,
        barlineStart: update.barlineStart != BarlineType.regular ? update.barlineStart : existing.barlineStart,
      );

  TimeSignature _parseTimeSig(XmlElement el) => TimeSignature(
        beats: int.parse(el.findElements('beats').first.innerText.trim()),
        beatType: int.parse(el.findElements('beat-type').first.innerText.trim()),
      );

  KeySignature _parseKeySig(XmlElement el) {
    final fifths = int.parse(el.findElements('fifths').first.innerText.trim());
    final modeText = el.findElements('mode').firstOrNull?.innerText.trim() ?? 'major';
    final mode = modeText == 'minor' ? Mode.minor : Mode.major;
    return KeySignature(fifths: fifths, mode: mode);
  }

  Tempo _parseTempo(XmlElement metronomeEl) {
    final beatUnitText = metronomeEl.findElements('beat-unit').firstOrNull?.innerText.trim() ?? 'quarter';
    final perMinuteText = metronomeEl.findElements('per-minute').firstOrNull?.innerText.trim() ?? '120';
    final bpm = double.tryParse(perMinuteText) ?? 120.0;
    final beatUnit = _parseNoteType(beatUnitText);
    return Tempo(bpm: bpm, beatUnit: beatUnit);
  }

  Pitch _parsePitch(XmlElement noteEl) {
    final pitchEl = noteEl.findElements('pitch').first;
    final stepText = pitchEl.findElements('step').first.innerText.trim().toLowerCase();
    final alter = double.tryParse(
          pitchEl.findElements('alter').firstOrNull?.innerText.trim() ?? '0',
        ) ??
        0.0;
    final octave = int.parse(pitchEl.findElements('octave').first.innerText.trim());
    return Pitch(
      step: Step.values.byName(stepText),
      alter: alter,
      octave: octave,
    );
  }

  NoteValue _noteValueFromTicks(int ticks, int divisions, int dots) {
    final wholeTicks = divisions * 4;
    final fraction = Fraction(ticks, wholeTicks);
    for (final type in NoteType.values) {
      final nv = NoteValue(noteType: type, dots: dots);
      if (nv.toFraction() == fraction) return nv;
    }
    for (final type in NoteType.values) {
      final nv = NoteValue(noteType: type);
      if (nv.toFraction() == fraction) return nv;
    }
    return const NoteValue(noteType: NoteType.quarter);
  }

  NoteType _parseNoteType(String text) => switch (text) {
        'whole' => NoteType.whole,
        'half' => NoteType.half,
        'quarter' => NoteType.quarter,
        'eighth' => NoteType.eighth,
        '16th' => NoteType.sixteenth,
        '32nd' => NoteType.thirtySecond,
        '64th' => NoteType.sixtyFourth,
        _ => NoteType.quarter,
      };

  BarlineType _parseBarlineStyle(String style, String? repeatDirection) {
    if (style == 'heavy-light') return BarlineType.repeatStart;
    if (style == 'light-heavy') {
      if (repeatDirection == 'backward') return BarlineType.repeatEnd;
      return BarlineType.finalBar;
    }
    return switch (style) {
      'light-light' => BarlineType.double,
      'dashed' => BarlineType.dashed,
      'dotted' => BarlineType.dotted,
      _ => BarlineType.regular,
    };
  }

  DynamicType? _parseDynamicType(XmlElement dynEl) {
    for (final child in dynEl.childElements) {
      final name = child.localName;
      try {
        return DynamicType.values.byName(name);
      } catch (_) {
        continue;
      }
    }
    return null;
  }
}

class _MusicEventPending {
  _MusicEventPending({
    required this.chordNotes,
    required this.noteValue,
    required this.voiceId,
    required this.staffNumber,
  });

  final List<MusicEvent> chordNotes;
  final NoteValue noteValue;
  final String voiceId;
  final int staffNumber;
}
