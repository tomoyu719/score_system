import 'package:score_core/score_core.dart';
import 'package:xml/xml.dart';

/// Exports a [Score] to a MusicXML 3.1 partwise document string.
final class MusicXmlExporter {
  const MusicXmlExporter();

  static const int _divisions = 4;

  /// Returns the MusicXML 3.1 string for [score].
  String export(Score score) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.doctype(
      'score-partwise',
      publicId: '-//Recordare//DTD MusicXML 3.1 Partwise//EN',
      systemId: 'http://www.musicxml.org/dtds/partwise.dtd',
    );
    builder.element('score-partwise', attributes: {'version': '3.1'}, nest: () {
      if (score.title.isNotEmpty) {
        builder.element('movement-title', nest: score.title);
      }
      if (score.composer.isNotEmpty) {
        builder.element('identification', nest: () {
          builder.element(
            'creator',
            attributes: {'type': 'composer'},
            nest: score.composer,
          );
        });
      }
      _writePartList(builder, score);
      for (final part in score.parts) {
        _writePart(builder, score, part);
      }
    });
    return builder.buildDocument().toXmlString(pretty: true, indent: '  ');
  }

  void _writePartList(XmlBuilder builder, Score score) {
    builder.element('part-list', nest: () {
      for (final part in score.parts) {
        builder.element('score-part', attributes: {'id': part.id.value}, nest: () {
          builder.element('part-name', nest: part.name);
        });
      }
    });
  }

  void _writePart(XmlBuilder builder, Score score, Part part) {
    builder.element('part', attributes: {'id': part.id.value}, nest: () {
      final measureNumbers = _collectMeasureNumbers(part);
      for (final measureNumber in measureNumbers) {
        final header = score.headerForMeasure(measureNumber);
        _writeMeasure(builder, score, part, measureNumber, header);
      }
    });
  }

  List<int> _collectMeasureNumbers(Part part) {
    final numbers = <int>{};
    for (final staff in part.staves) {
      for (final key in staff.measures.keys) {
        numbers.add(key);
      }
    }
    final sorted = numbers.toList()..sort();
    return sorted;
  }

  void _writeMeasure(
    XmlBuilder builder,
    Score score,
    Part part,
    int measureNumber,
    MeasureHeader? header,
  ) {
    builder.element('measure', attributes: {'number': '$measureNumber'}, nest: () {
      if (header != null) {
        _writeAttributes(builder, header);
      }
      if (header?.tempo != null) {
        _writeTempoDirection(builder, header!.tempo!);
      }
      _writeVoiceEvents(builder, part, measureNumber);
      if (header != null) {
        _writeBarlines(builder, header);
      }
    });
  }

  void _writeAttributes(XmlBuilder builder, MeasureHeader header) {
    builder.element('attributes', nest: () {
      builder.element('divisions', nest: '$_divisions');
      builder.element('key', nest: () {
        builder.element('fifths', nest: '${header.keySignature.fifths}');
        builder.element('mode', nest: header.keySignature.mode.name);
      });
      builder.element('time', nest: () {
        builder.element('beats', nest: '${header.timeSignature.beats}');
        builder.element('beat-type', nest: '${header.timeSignature.beatType}');
      });
      builder.element('clef', nest: () {
        builder.element('sign', nest: 'G');
        builder.element('line', nest: '2');
      });
    });
  }

  void _writeTempoDirection(XmlBuilder builder, Tempo tempo) {
    builder.element('direction', nest: () {
      builder.element('direction-type', nest: () {
        builder.element('metronome', attributes: {'parentheses': 'no'}, nest: () {
          builder.element('beat-unit', nest: _noteTypeToMusicXml(tempo.beatUnit));
          builder.element('per-minute', nest: '${tempo.bpm.toInt()}');
        });
      });
    });
  }

  void _writeVoiceEvents(XmlBuilder builder, Part part, int measureNumber) {
    for (final staff in part.staves) {
      final measure = staff.measures[measureNumber];
      if (measure == null) continue;
      final staffNumber = _staffNumber(part, staff.id);
      for (final voiceEntry in measure.voices.entries) {
        final voiceId = voiceEntry.key.value;
        for (final event in voiceEntry.value.events) {
          switch (event) {
            case NoteEvent():
              _writeNoteEvent(builder, event, voiceId, staffNumber, false);
              _writeAttachedDynamics(builder, event.dynamics);
            case RestEvent():
              _writeRestEvent(builder, event, voiceId, staffNumber);
            case ChordEvent():
              _writeChordEvent(builder, event, voiceId, staffNumber);
              _writeAttachedDynamics(builder, event.dynamics);
            case PercussionNote():
              break; // percussion notes are not yet exported to MusicXML
          }
        }
      }
    }
  }

  void _writeNoteEvent(
    XmlBuilder builder,
    NoteEvent note,
    String voiceId,
    int staffNumber,
    bool isChordMember,
  ) {
    builder.element('note', nest: () {
      if (isChordMember) builder.element('chord');
      builder.element('pitch', nest: () {
        builder.element('step', nest: note.pitch.step.name.toUpperCase());
        if (note.pitch.alter != 0.0) {
          builder.element('alter', nest: '${note.pitch.alter}');
        }
        builder.element('octave', nest: '${note.pitch.octave}');
      });
      builder.element('duration', nest: '${_durationTicks(note.noteValue)}');
      builder.element('type', nest: _noteTypeToMusicXml(note.noteValue.noteType));
      for (var i = 0; i < note.noteValue.dots; i++) {
        builder.element('dot');
      }
      builder.element('voice', nest: voiceId);
      builder.element('staff', nest: '$staffNumber');
    });
  }

  void _writeRestEvent(
    XmlBuilder builder,
    RestEvent rest,
    String voiceId,
    int staffNumber,
  ) {
    builder.element('note', nest: () {
      builder.element('rest');
      builder.element('duration', nest: '${_durationTicks(rest.noteValue)}');
      builder.element('type', nest: _noteTypeToMusicXml(rest.noteValue.noteType));
      for (var i = 0; i < rest.noteValue.dots; i++) {
        builder.element('dot');
      }
      builder.element('voice', nest: voiceId);
      builder.element('staff', nest: '$staffNumber');
    });
  }

  void _writeChordEvent(
    XmlBuilder builder,
    ChordEvent chord,
    String voiceId,
    int staffNumber,
  ) {
    for (var i = 0; i < chord.notes.length; i++) {
      _writeNoteEvent(builder, chord.notes[i], voiceId, staffNumber, i > 0);
    }
  }

  void _writeAttachedDynamics(XmlBuilder builder, dynamic dynamics) {
    if (dynamics == null || (dynamics as Iterable).isEmpty) return;
    for (final dyn in dynamics) {
      final d = dyn as Dynamic;
      final attrs = <String, String>{};
      if (d.placement != null) attrs['placement'] = d.placement!.name;
      builder.element('direction', attributes: attrs, nest: () {
        builder.element('direction-type', nest: () {
          builder.element('dynamics', nest: () {
            builder.element(d.type.name);
          });
        });
      });
    }
  }

  void _writeBarlines(XmlBuilder builder, MeasureHeader header) {
    final endStyle = _barlineStyle(header.barlineEnd);
    if (endStyle != null) {
      builder.element('barline', attributes: {'location': 'right'}, nest: () {
        builder.element('bar-style', nest: endStyle);
      });
    }
    final startStyle = _barlineStyle(header.barlineStart);
    if (startStyle != null) {
      builder.element('barline', attributes: {'location': 'left'}, nest: () {
        builder.element('bar-style', nest: startStyle);
      });
    }
  }

  int _staffNumber(Part part, StaffId staffId) {
    for (var i = 0; i < part.staves.length; i++) {
      if (part.staves[i].id == staffId) return i + 1;
    }
    return 1;
  }

  int _durationTicks(NoteValue nv) {
    final fraction = nv.toFraction();
    return (fraction.numerator * _divisions * 4 / fraction.denominator).round();
  }

  String _noteTypeToMusicXml(NoteType type) => switch (type) {
        NoteType.whole => 'whole',
        NoteType.half => 'half',
        NoteType.quarter => 'quarter',
        NoteType.eighth => 'eighth',
        NoteType.sixteenth => '16th',
        NoteType.thirtySecond => '32nd',
        NoteType.sixtyFourth => '64th',
      };

  String? _barlineStyle(BarlineType type) => switch (type) {
        BarlineType.regular => null,
        BarlineType.double => 'light-light',
        BarlineType.finalBar => 'light-heavy',
        BarlineType.repeatStart => 'heavy-light',
        BarlineType.repeatEnd => 'light-heavy',
        BarlineType.dashed => 'dashed',
        BarlineType.dotted => 'dotted',
      };
}
