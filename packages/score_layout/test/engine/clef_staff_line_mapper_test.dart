import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  const mapper = ClefStaffLineMapper();

  group('ClefStaffLineMapper — treble clef', () {
    test('E4 → 0 (bottom line)', () {
      expect(mapper.map(const Pitch(step: Step.e, octave: 4), Clef.treble), equals(0));
    });

    test('F4 → 1 (first space)', () {
      expect(mapper.map(const Pitch(step: Step.f, octave: 4), Clef.treble), equals(1));
    });

    test('G4 → 2 (second line)', () {
      expect(mapper.map(const Pitch(step: Step.g, octave: 4), Clef.treble), equals(2));
    });

    test('B4 → 4 (middle line)', () {
      expect(mapper.map(const Pitch(step: Step.b, octave: 4), Clef.treble), equals(4));
    });

    test('F5 → 8 (top line)', () {
      expect(mapper.map(const Pitch(step: Step.f, octave: 5), Clef.treble), equals(8));
    });

    test('C4 → -2 (ledger line below)', () {
      expect(mapper.map(const Pitch(step: Step.c, octave: 4), Clef.treble), equals(-2));
    });

    test('D4 → -1 (below bottom line)', () {
      expect(mapper.map(const Pitch(step: Step.d, octave: 4), Clef.treble), equals(-1));
    });
  });

  group('ClefStaffLineMapper — bass clef', () {
    test('G2 → 0 (bottom line)', () {
      expect(mapper.map(const Pitch(step: Step.g, octave: 2), Clef.bass), equals(0));
    });

    test('F3 → 6 (fourth line)', () {
      expect(mapper.map(const Pitch(step: Step.f, octave: 3), Clef.bass), equals(6));
    });

    test('C3 → 3 (second space)', () {
      expect(mapper.map(const Pitch(step: Step.c, octave: 3), Clef.bass), equals(3));
    });
  });

  group('ClefStaffLineMapper — alto clef', () {
    test('F3 → 0 (bottom line)', () {
      expect(mapper.map(const Pitch(step: Step.f, octave: 3), Clef.alto), equals(0));
    });

    test('C4 → 4 (middle line)', () {
      expect(mapper.map(const Pitch(step: Step.c, octave: 4), Clef.alto), equals(4));
    });
  });

  group('ClefStaffLineMapper — tenor clef', () {
    test('C4 → 6 (fourth line)', () {
      expect(mapper.map(const Pitch(step: Step.c, octave: 4), Clef.tenor), equals(6));
    });
  });

  group('ClefStaffLineMapper — percussion clef', () {
    test('any pitch → 0', () {
      expect(mapper.map(const Pitch(step: Step.c, octave: 4), Clef.percussion), equals(0));
    });
  });

  group('accidentalType', () {
    test('1.0 → sharp', () => expect(ClefStaffLineMapper.accidentalType(1.0), equals('sharp')));
    test('-1.0 → flat', () => expect(ClefStaffLineMapper.accidentalType(-1.0), equals('flat')));
    test('2.0 → doubleSharp', () => expect(ClefStaffLineMapper.accidentalType(2.0), equals('doubleSharp')));
    test('-2.0 → doubleFlat', () => expect(ClefStaffLineMapper.accidentalType(-2.0), equals('doubleFlat')));
    test('0.0 → null (no accidental)', () => expect(ClefStaffLineMapper.accidentalType(0.0), isNull));
  });
}
