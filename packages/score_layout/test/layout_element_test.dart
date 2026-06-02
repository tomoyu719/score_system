import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  const bounds = BoundingBox(x: 0.0, y: 0.0, width: 1.0, height: 1.0);
  const newBounds = BoundingBox(x: 1.0, y: 1.0, width: 2.0, height: 2.0);

  group('NoteheadElement', () {
    test('can be constructed with required fields', () {
      final el = NoteheadElement(
        id: 'n1',
        bounds: bounds,
        noteId: 'note-1',
        midiPitch: 60,
        staffLine: 0.0,
      );
      expect(el.id, 'n1');
      expect(el.noteId, 'note-1');
      expect(el.midiPitch, 60);
      expect(el.staffLine, 0.0);
      expect(el.isManualOverride, isFalse);
    });

    test('withBounds returns NoteheadElement with updated bounds', () {
      final el = NoteheadElement(
        id: 'n1',
        bounds: bounds,
        noteId: 'note-1',
        midiPitch: 60,
        staffLine: 0.0,
      );
      final updated = el.withBounds(newBounds);
      expect(updated, isA<NoteheadElement>());
      expect(updated.bounds, newBounds);
      expect(updated.noteId, 'note-1');
    });
  });

  group('RestElement', () {
    test('can be constructed and withBounds returns RestElement', () {
      final el = RestElement(
        id: 'r1',
        bounds: bounds,
        restId: 'rest-1',
        staffLine: 4.0,
      );
      expect(el.restId, 'rest-1');
      expect(el.staffLine, 4.0);
      final updated = el.withBounds(newBounds);
      expect(updated, isA<RestElement>());
      expect(updated.bounds, newBounds);
    });
  });

  group('StemElement', () {
    test('can be constructed and withBounds returns StemElement', () {
      final el = StemElement(
        id: 's1',
        bounds: bounds,
        noteId: 'note-1',
        direction: StemDirection.up,
      );
      expect(el.direction, StemDirection.up);
      final updated = el.withBounds(newBounds);
      expect(updated, isA<StemElement>());
    });
  });

  group('AccidentalElement', () {
    test('can be constructed and withBounds returns AccidentalElement', () {
      final el = AccidentalElement(
        id: 'a1',
        bounds: bounds,
        noteId: 'note-1',
        accidentalType: AccidentalType.sharp,
      );
      expect(el.accidentalType, AccidentalType.sharp);
      final updated = el.withBounds(newBounds);
      expect(updated, isA<AccidentalElement>());
    });
  });

  group('BarlineElement', () {
    test('can be constructed and withBounds returns BarlineElement', () {
      final el = BarlineElement(
        id: 'b1',
        bounds: bounds,
        measureNumber: 1,
        barlineType: 'regular',
      );
      expect(el.measureNumber, 1);
      expect(el.barlineType, 'regular');
      final updated = el.withBounds(newBounds);
      expect(updated, isA<BarlineElement>());
    });
  });

  group('ClefElement', () {
    test('can be constructed and withBounds returns ClefElement', () {
      final el = ClefElement(
        id: 'c1',
        bounds: bounds,
        clefType: 'treble',
      );
      expect(el.clefType, 'treble');
      final updated = el.withBounds(newBounds);
      expect(updated, isA<ClefElement>());
    });
  });

  group('TimeSignatureElement', () {
    test('can be constructed and withBounds returns TimeSignatureElement', () {
      final el = TimeSignatureElement(
        id: 'ts1',
        bounds: bounds,
        beats: 4,
        beatType: 4,
      );
      expect(el.beats, 4);
      expect(el.beatType, 4);
      final updated = el.withBounds(newBounds);
      expect(updated, isA<TimeSignatureElement>());
    });
  });

  group('KeySignatureElement', () {
    test('can be constructed and withBounds returns KeySignatureElement', () {
      final el = KeySignatureElement(
        id: 'ks1',
        bounds: bounds,
        fifths: 2,
      );
      expect(el.fifths, 2);
      final updated = el.withBounds(newBounds);
      expect(updated, isA<KeySignatureElement>());
    });
  });

  group('DynamicElement', () {
    test('can be constructed and withBounds returns DynamicElement', () {
      final el = DynamicElement(
        id: 'd1',
        bounds: bounds,
        dynamicType: 'forte',
        placement: 'below',
      );
      expect(el.dynamicType, 'forte');
      expect(el.placement, 'below');
      final updated = el.withBounds(newBounds);
      expect(updated, isA<DynamicElement>());
    });
  });

  group('LyricElement', () {
    test('can be constructed and withBounds returns LyricElement', () {
      final el = LyricElement(
        id: 'l1',
        bounds: bounds,
        text: 'hel',
        syllabic: 'begin',
        lineNumber: 1,
      );
      expect(el.text, 'hel');
      expect(el.syllabic, 'begin');
      expect(el.lineNumber, 1);
      final updated = el.withBounds(newBounds);
      expect(updated, isA<LyricElement>());
    });
  });

  group('ArticulationElement', () {
    test('can be constructed and withBounds returns ArticulationElement', () {
      final el = ArticulationElement(
        id: 'art1',
        bounds: bounds,
        articulationType: 'accent',
        placement: 'above',
      );
      expect(el.articulationType, 'accent');
      expect(el.placement, 'above');
      final updated = el.withBounds(newBounds);
      expect(updated, isA<ArticulationElement>());
    });
  });

  group('isManualOverride defaults', () {
    test('all elements default isManualOverride to false', () {
      final elements = <LayoutElement>[
        NoteheadElement(
          id: 'n',
          bounds: bounds,
          noteId: 'n',
          midiPitch: 60,
          staffLine: 0,
        ),
        RestElement(id: 'r', bounds: bounds, restId: 'r', staffLine: 4),
        StemElement(
          id: 's',
          bounds: bounds,
          noteId: 'n',
          direction: StemDirection.up,
        ),
        AccidentalElement(
          id: 'a',
          bounds: bounds,
          noteId: 'n',
          accidentalType: AccidentalType.flat,
        ),
        BarlineElement(
          id: 'b',
          bounds: bounds,
          measureNumber: 1,
          barlineType: 'regular',
        ),
        ClefElement(id: 'c', bounds: bounds, clefType: 'treble'),
        TimeSignatureElement(
          id: 'ts',
          bounds: bounds,
          beats: 4,
          beatType: 4,
        ),
        KeySignatureElement(id: 'ks', bounds: bounds, fifths: 0),
        DynamicElement(
          id: 'd',
          bounds: bounds,
          dynamicType: 'mp',
          placement: 'below',
        ),
        LyricElement(
          id: 'l',
          bounds: bounds,
          text: 'la',
          syllabic: 'single',
          lineNumber: 1,
        ),
        ArticulationElement(
          id: 'art',
          bounds: bounds,
          articulationType: 'staccato',
          placement: 'above',
        ),
      ];
      for (final el in elements) {
        expect(el.isManualOverride, isFalse, reason: '${el.runtimeType}');
      }
    });
  });
}
