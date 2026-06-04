import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:test/test.dart';

void main() {
  group('GuitarTechnique', () {
    test('all expected values exist', () {
      const techniques = GuitarTechnique.values;
      expect(techniques, contains(GuitarTechnique.hammerOn));
      expect(techniques, contains(GuitarTechnique.pullOff));
      expect(techniques, contains(GuitarTechnique.slideUp));
      expect(techniques, contains(GuitarTechnique.slideDown));
      expect(techniques, contains(GuitarTechnique.bend));
      expect(techniques, contains(GuitarTechnique.release));
      expect(techniques, contains(GuitarTechnique.vibrato));
      expect(techniques, contains(GuitarTechnique.palmMute));
      expect(techniques, contains(GuitarTechnique.harmonic));
      expect(techniques, contains(GuitarTechnique.tapping));
      expect(techniques, contains(GuitarTechnique.deadNote));
      expect(techniques, contains(GuitarTechnique.ghostNote));
    });
  });

  group('TabConfig', () {
    test('stores fields correctly', () {
      final tuning = IList(List.generate(4, (_) => const Pitch(step: Step.e, octave: 2)));
      final config = TabConfig(stringCount: 4, tuning: tuning, capo: 2);
      expect(config.stringCount, equals(4));
      expect(config.tuning, equals(tuning));
      expect(config.capo, equals(2));
    });

    test('capo defaults to 0', () {
      final config = TabConfig(
        stringCount: 6,
        tuning: IList(List.generate(6, (_) => const Pitch(step: Step.e, octave: 2))),
      );
      expect(config.capo, equals(0));
    });

    test('copyWith overrides specified fields', () {
      final original = TabConfig(
        stringCount: 6,
        tuning: IList(List.generate(6, (_) => const Pitch(step: Step.e, octave: 2))),
        capo: 0,
      );
      final copy = original.copyWith(capo: 2);
      expect(copy.capo, equals(2));
      expect(copy.stringCount, equals(6));
    });

    test('equality based on value', () {
      final t = IList([const Pitch(step: Step.e, octave: 2)]);
      expect(
        TabConfig(stringCount: 4, tuning: t),
        equals(TabConfig(stringCount: 4, tuning: t)),
      );
    });

    group('preset tunings', () {
      test('standardGuitar has 6 strings', () {
        expect(standardGuitar.stringCount, equals(6));
        expect(standardGuitar.tuning.length, equals(6));
        expect(standardGuitar.capo, equals(0));
      });

      test('standardGuitar lowest string is E2', () {
        expect(standardGuitar.tuning.first.step, equals(Step.e));
        expect(standardGuitar.tuning.first.octave, equals(2));
      });

      test('standardGuitar highest string is E4', () {
        expect(standardGuitar.tuning.last.step, equals(Step.e));
        expect(standardGuitar.tuning.last.octave, equals(4));
      });

      test('standardBass has 4 strings starting at E1', () {
        expect(standardBass.stringCount, equals(4));
        expect(standardBass.tuning.first.step, equals(Step.e));
        expect(standardBass.tuning.first.octave, equals(1));
      });
    });
  });

  group('TabFret', () {
    test('stores fields correctly', () {
      const fret = TabFret(stringNumber: 3, fretNumber: 5);
      expect(fret.stringNumber, equals(3));
      expect(fret.fretNumber, equals(5));
      expect(fret.techniques, isEmpty);
      expect(fret.isManualOverride, isFalse);
    });

    test('open string is fretNumber 0', () {
      const fret = TabFret(stringNumber: 1, fretNumber: 0);
      expect(fret.fretNumber, equals(0));
    });

    test('stores techniques', () {
      final fret = TabFret(
        stringNumber: 2,
        fretNumber: 7,
        techniques: IList([GuitarTechnique.hammerOn, GuitarTechnique.bend]),
      );
      expect(fret.techniques, hasLength(2));
      expect(fret.techniques, contains(GuitarTechnique.hammerOn));
    });

    test('copyWith overrides specified fields', () {
      const original = TabFret(stringNumber: 1, fretNumber: 3);
      final copy = original.copyWith(fretNumber: 5, isManualOverride: true);
      expect(copy.stringNumber, equals(1));
      expect(copy.fretNumber, equals(5));
      expect(copy.isManualOverride, isTrue);
    });

    test('equality based on value', () {
      expect(
        const TabFret(stringNumber: 1, fretNumber: 3),
        equals(const TabFret(stringNumber: 1, fretNumber: 3)),
      );
      expect(
        const TabFret(stringNumber: 1, fretNumber: 3),
        isNot(equals(const TabFret(stringNumber: 2, fretNumber: 3))),
      );
    });
  });

  group('NoteEvent.tabFret', () {
    test('defaults to null', () {
      final note = NoteEvent(
        id: const NoteId('n1'),
        offset: Fraction.zero,
        noteValue: NoteValue(noteType: NoteType.quarter),
        pitch: const Pitch(step: Step.c, octave: 4),
      );
      expect(note.tabFret, isNull);
    });

    test('can be set', () {
      final note = NoteEvent(
        id: const NoteId('n1'),
        offset: Fraction.zero,
        noteValue: NoteValue(noteType: NoteType.quarter),
        pitch: const Pitch(step: Step.c, octave: 4),
        tabFret: const TabFret(stringNumber: 2, fretNumber: 5),
      );
      expect(note.tabFret?.stringNumber, equals(2));
    });

    test('copyWith preserves tabFret', () {
      final note = NoteEvent(
        id: const NoteId('n1'),
        offset: Fraction.zero,
        noteValue: NoteValue(noteType: NoteType.quarter),
        pitch: const Pitch(step: Step.c, octave: 4),
        tabFret: const TabFret(stringNumber: 2, fretNumber: 5),
      );
      final copy = note.copyWith(isGrace: true);
      expect(copy.tabFret?.stringNumber, equals(2));
    });
  });

  group('Staff.tabConfig', () {
    test('defaults to null for standard staff', () {
      final staff = Staff(id: const StaffId('s1'));
      expect(staff.tabConfig, isNull);
    });

    test('can be set on a tab staff', () {
      final staff = Staff(
        id: const StaffId('s1'),
        staffType: StaffType.tab,
        tabConfig: standardGuitar,
      );
      expect(staff.tabConfig?.stringCount, equals(6));
    });

    test('percussionTab is a valid StaffType', () {
      final staff = Staff(
        id: const StaffId('s1'),
        staffType: StaffType.percussionTab,
      );
      expect(staff.staffType, equals(StaffType.percussionTab));
    });
  });
}
