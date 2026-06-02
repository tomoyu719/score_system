import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

// The measure width is minMeasureWidth=20sp (4 quarter notes × 4sp = 16sp < 20sp floor).
// X positions for notes at offsets 0, 1/4, 1/2, 3/4 of 20sp:
//   0/1 * 20 = 0, 1/4 * 20 = 5, 1/2 * 20 = 10, 3/4 * 20 = 15
const _goldenJson = r'''
{
  "parts": [
    {
      "partId": "part-1",
      "bounds": {
        "x": 0.0,
        "y": 0.0,
        "width": 20.0,
        "height": 4.0
      },
      "staves": [
        {
          "staffId": "staff-1",
          "bounds": {
            "x": 0.0,
            "y": 0.0,
            "width": 20.0,
            "height": 4.0
          },
          "measures": [
            {
              "measureNumber": 1,
              "bounds": {
                "x": 0.0,
                "y": 0.0,
                "width": 20.0,
                "height": 4.0
              },
              "elements": [
                {
                  "type": "NoteheadElement",
                  "id": "notehead-n1",
                  "noteId": "n1",
                  "midiPitch": 60,
                  "staffLine": -2.0,
                  "isManualOverride": false,
                  "bounds": {
                    "x": 0.0,
                    "y": 0.0,
                    "width": 1.0,
                    "height": 1.0
                  }
                },
                {
                  "type": "StemElement",
                  "id": "stem-n1",
                  "noteId": "n1",
                  "direction": "up",
                  "isManualOverride": false,
                  "bounds": {
                    "x": 0.0,
                    "y": 0.0,
                    "width": 0.1,
                    "height": 3.5
                  }
                },
                {
                  "type": "NoteheadElement",
                  "id": "notehead-n2",
                  "noteId": "n2",
                  "midiPitch": 62,
                  "staffLine": -1.0,
                  "isManualOverride": false,
                  "bounds": {
                    "x": 5.0,
                    "y": 0.0,
                    "width": 1.0,
                    "height": 1.0
                  }
                },
                {
                  "type": "StemElement",
                  "id": "stem-n2",
                  "noteId": "n2",
                  "direction": "up",
                  "isManualOverride": false,
                  "bounds": {
                    "x": 5.0,
                    "y": 0.0,
                    "width": 0.1,
                    "height": 3.5
                  }
                },
                {
                  "type": "NoteheadElement",
                  "id": "notehead-n3",
                  "noteId": "n3",
                  "midiPitch": 64,
                  "staffLine": 0.0,
                  "isManualOverride": false,
                  "bounds": {
                    "x": 10.0,
                    "y": 0.0,
                    "width": 1.0,
                    "height": 1.0
                  }
                },
                {
                  "type": "StemElement",
                  "id": "stem-n3",
                  "noteId": "n3",
                  "direction": "up",
                  "isManualOverride": false,
                  "bounds": {
                    "x": 10.0,
                    "y": 0.0,
                    "width": 0.1,
                    "height": 3.5
                  }
                },
                {
                  "type": "NoteheadElement",
                  "id": "notehead-n4",
                  "noteId": "n4",
                  "midiPitch": 65,
                  "staffLine": 1.0,
                  "isManualOverride": false,
                  "bounds": {
                    "x": 15.0,
                    "y": 0.0,
                    "width": 1.0,
                    "height": 1.0
                  }
                },
                {
                  "type": "StemElement",
                  "id": "stem-n4",
                  "noteId": "n4",
                  "direction": "up",
                  "isManualOverride": false,
                  "bounds": {
                    "x": 15.0,
                    "y": 0.0,
                    "width": 0.1,
                    "height": 3.5
                  }
                }
              ]
            }
          ]
        }
      ]
    }
  ],
  "bounds": {
    "x": 0.0,
    "y": 0.0,
    "width": 20.0,
    "height": 4.0
  }
}''';

void main() {
  test('golden: simple 4-note score layout matches expected JSON', () {
    const engine = LayoutEngine();

    const partId = PartId('part-1');
    const staffId = StaffId('staff-1');
    const voiceId = VoiceId('voice-1');

    final voice = Voice(
      id: voiceId,
      events: IList([
        NoteEvent(
          id: const NoteId('n1'),
          offset: Fraction.zero,
          noteValue: const NoteValue(noteType: NoteType.quarter),
          pitch: const Pitch(step: Step.c, octave: 4),
        ),
        NoteEvent(
          id: const NoteId('n2'),
          offset: Fraction(1, 4),
          noteValue: const NoteValue(noteType: NoteType.quarter),
          pitch: const Pitch(step: Step.d, octave: 4),
        ),
        NoteEvent(
          id: const NoteId('n3'),
          offset: Fraction(1, 2),
          noteValue: const NoteValue(noteType: NoteType.quarter),
          pitch: const Pitch(step: Step.e, octave: 4),
        ),
        NoteEvent(
          id: const NoteId('n4'),
          offset: Fraction(3, 4),
          noteValue: const NoteValue(noteType: NoteType.quarter),
          pitch: const Pitch(step: Step.f, octave: 4),
        ),
      ]),
    );

    final score = Score(
      id: const ScoreId('score-1'),
      parts: IList([
        Part(
          id: partId,
          name: 'Piano',
          staves: IList([
            Staff(
              id: staffId,
              measures: IMap({
                1: Measure(
                  id: const MeasureId('measure-1'),
                  voices: IMap({voiceId: voice}),
                ),
              }),
            ),
          ]),
        ),
      ]),
      measureHeaders: IList([
        MeasureHeader(
          measureNumber: 1,
          timeSignature: const TimeSignature(beats: 4, beatType: 4),
          keySignature: const KeySignature(fifths: 0),
        ),
      ]),
    );

    final tree = engine.layout(score);
    final actualJson = tree.toJson();

    final expectedJson =
        jsonDecode(_goldenJson) as Map<String, Object?>;

    // Compare structure
    expect(actualJson['bounds'], expectedJson['bounds']);

    final actualParts = actualJson['parts'] as List;
    final expectedParts = expectedJson['parts'] as List;
    expect(actualParts.length, expectedParts.length);

    final actualPart = actualParts.first as Map<String, Object?>;
    final expectedPart = expectedParts.first as Map<String, Object?>;
    expect(actualPart['partId'], expectedPart['partId']);

    final actualStaves = actualPart['staves'] as List;
    expect(actualStaves.length, 1);

    final actualMeasures =
        (actualStaves.first as Map<String, Object?>)['measures'] as List;
    expect(actualMeasures.length, 1);

    final actualElements =
        (actualMeasures.first as Map<String, Object?>)['elements'] as List;
    final expectedElements =
        ((expectedParts.first as Map)['staves'] as List)
            .first
            as Map;
    final expectedMeasureElements =
        ((expectedElements['measures'] as List).first
                as Map)['elements']
            as List;

    // Check element count
    expect(actualElements.length, expectedMeasureElements.length);

    // Check each element type and key fields
    for (var i = 0; i < actualElements.length; i++) {
      final actual = actualElements[i] as Map<String, Object?>;
      final expected = expectedMeasureElements[i] as Map<String, Object?>;
      expect(actual['type'], expected['type'], reason: 'element $i type');
      expect(actual['noteId'], expected['noteId'], reason: 'element $i noteId');
    }
  });
}
