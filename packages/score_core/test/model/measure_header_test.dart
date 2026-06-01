import 'package:score_core/src/model/barline.dart';
import 'package:score_core/src/model/fraction.dart';
import 'package:score_core/src/model/key_signature.dart';
import 'package:score_core/src/model/measure_header.dart';
import 'package:score_core/src/model/note_type.dart';
import 'package:score_core/src/model/tempo.dart';
import 'package:score_core/src/model/time_signature.dart';
import 'package:test/test.dart';

void main() {
  group('TimeSignature', () {
    test('4/4 measureDuration = 1', () {
      expect(
        const TimeSignature(beats: 4, beatType: 4).measureDuration,
        equals(Fraction(1, 1)),
      );
    });

    test('6/8 measureDuration = 3/4', () {
      expect(
        const TimeSignature(beats: 6, beatType: 8).measureDuration,
        equals(Fraction(3, 4)),
      );
    });

    test('3/4 measureDuration = 3/4', () {
      expect(
        const TimeSignature(beats: 3, beatType: 4).measureDuration,
        equals(Fraction(3, 4)),
      );
    });

    test('equality', () {
      expect(
        const TimeSignature(beats: 4, beatType: 4),
        equals(const TimeSignature(beats: 4, beatType: 4)),
      );
    });
  });

  group('KeySignature', () {
    test('C major has 0 fifths', () {
      expect(const KeySignature(fifths: 0).fifths, equals(0));
    });

    test('G major has 1 sharp', () {
      expect(const KeySignature(fifths: 1).fifths, equals(1));
    });

    test('mode defaults to major', () {
      expect(const KeySignature(fifths: 0).mode, equals(Mode.major));
    });

    test('equality', () {
      expect(
        const KeySignature(fifths: 2),
        equals(const KeySignature(fifths: 2)),
      );
    });
  });

  group('Tempo', () {
    test('tempo bpm stored correctly', () {
      expect(const Tempo(bpm: 120).bpm, equals(120.0));
    });

    test('beatUnit defaults to quarter', () {
      expect(const Tempo(bpm: 120).beatUnit, equals(NoteType.quarter));
    });

    test('copyWith changes bpm', () {
      const t = Tempo(bpm: 120);
      expect(t.copyWith(bpm: 60).bpm, equals(60.0));
      expect(t.bpm, equals(120.0));
    });
  });

  group('MeasureHeader', () {
    const ts = TimeSignature(beats: 4, beatType: 4);
    const ks = KeySignature(fifths: 0);

    test('holds time and key signatures', () {
      final h = MeasureHeader(
        measureNumber: 1,
        timeSignature: ts,
        keySignature: ks,
      );
      expect(h.measureNumber, equals(1));
      expect(h.timeSignature, equals(ts));
      expect(h.keySignature, equals(ks));
    });

    test('barlines default to regular', () {
      final h = MeasureHeader(
        measureNumber: 1,
        timeSignature: ts,
        keySignature: ks,
      );
      expect(h.barlineStart, equals(BarlineType.regular));
      expect(h.barlineEnd, equals(BarlineType.regular));
    });

    test('copyWith changes tempo', () {
      final h = MeasureHeader(
        measureNumber: 1,
        timeSignature: ts,
        keySignature: ks,
      );
      final h2 = h.copyWith(tempo: const Tempo(bpm: 120));
      expect(h.tempo, isNull);
      expect(h2.tempo?.bpm, equals(120.0));
    });

    test('equality', () {
      final h1 = MeasureHeader(
        measureNumber: 1,
        timeSignature: ts,
        keySignature: ks,
      );
      final h2 = MeasureHeader(
        measureNumber: 1,
        timeSignature: ts,
        keySignature: ks,
      );
      expect(h1, equals(h2));
    });
  });
}
