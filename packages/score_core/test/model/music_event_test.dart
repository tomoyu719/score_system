import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/src/ids.dart';
import 'package:score_core/src/model/articulation.dart';
import 'package:score_core/src/model/dynamic.dart';
import 'package:score_core/src/model/fraction.dart';
import 'package:score_core/src/model/lyric.dart';
import 'package:score_core/src/model/music_event.dart';
import 'package:score_core/src/model/note_type.dart';
import 'package:score_core/src/model/note_value.dart';
import 'package:score_core/src/model/pitch.dart';
import 'package:test/test.dart';

NoteEvent _note({
  NoteId? id,
  Fraction? offset,
  NoteValue? noteValue,
  Pitch? pitch,
}) =>
    NoteEvent(
      id: id ?? const NoteId('n1'),
      offset: offset ?? Fraction.zero,
      noteValue: noteValue ?? NoteValue(noteType: NoteType.quarter),
      pitch: pitch ?? Pitch(step: Step.c, octave: 4),
    );

void main() {
  group('NoteEvent', () {
    test('carries pitch and timing', () {
      final n = _note(
        offset: Fraction(1, 4),
        pitch: Pitch(step: Step.a, octave: 4),
      );
      expect(n.pitch.step, equals(Step.a));
      expect(n.offset, equals(Fraction(1, 4)));
      expect(n.noteValue.toFraction(), equals(Fraction(1, 4)));
    });

    test('copyWith changes only specified fields', () {
      final original = _note(pitch: Pitch(step: Step.c, octave: 4));
      final modified = original.copyWith(
        pitch: Pitch(step: Step.d, octave: 4),
      );
      expect(modified.pitch.step, equals(Step.d));
      expect(original.pitch.step, equals(Step.c));
      expect(modified.id, equals(original.id));
    });

    test('isGrace defaults to false', () {
      expect(_note().isGrace, isFalse);
    });

    test('can attach articulations', () {
      final n = _note().copyWith(
        articulations: IList([const Articulation(type: ArticulationType.staccato)]),
      );
      expect(n.articulations.length, equals(1));
      expect(n.articulations.first.type, equals(ArticulationType.staccato));
    });

    test('can attach lyrics', () {
      final n = _note().copyWith(
        lyrics: IList([const Lyric(text: 'hel', syllabic: Syllabic.begin)]),
      );
      expect(n.lyrics.first.text, equals('hel'));
    });
  });

  group('RestEvent', () {
    final quarterRest = RestEvent(
      id: const RestId('r1'),
      offset: Fraction.zero,
      noteValue: NoteValue(noteType: NoteType.quarter),
    );

    test('isFullMeasure defaults to false', () {
      expect(quarterRest.isFullMeasure, isFalse);
    });

    test('copyWith changes isFullMeasure', () {
      final full = quarterRest.copyWith(isFullMeasure: true);
      expect(full.isFullMeasure, isTrue);
      expect(quarterRest.isFullMeasure, isFalse);
    });
  });

  group('ChordEvent', () {
    final c4 = Pitch(step: Step.c, octave: 4);
    final e4 = Pitch(step: Step.e, octave: 4);
    final g4 = Pitch(step: Step.g, octave: 4);

    NoteEvent chordNote(String id, Pitch pitch) => NoteEvent(
          id: NoteId(id),
          offset: Fraction.zero,
          noteValue: NoteValue(noteType: NoteType.quarter),
          pitch: pitch,
        );

    test('holds multiple notes', () {
      final chord = ChordEvent(
        id: const ChordId('ch1'),
        offset: Fraction.zero,
        noteValue: NoteValue(noteType: NoteType.quarter),
        notes: IList([
          chordNote('n1', c4),
          chordNote('n2', e4),
          chordNote('n3', g4),
        ]),
      );
      expect(chord.notes.length, equals(3));
    });

    test('copyWith replaces notes', () {
      final original = ChordEvent(
        id: const ChordId('ch1'),
        offset: Fraction.zero,
        noteValue: NoteValue(noteType: NoteType.quarter),
        notes: IList([chordNote('n1', c4)]),
      );
      final updated = original.copyWith(
        notes: IList([chordNote('n1', c4), chordNote('n2', e4)]),
      );
      expect(updated.notes.length, equals(2));
      expect(original.notes.length, equals(1));
    });

    test('can attach dynamics', () {
      final chord = ChordEvent(
        id: const ChordId('ch1'),
        offset: Fraction.zero,
        noteValue: NoteValue(noteType: NoteType.quarter),
        notes: IList([chordNote('n1', c4)]),
        dynamics: IList([const Dynamic(type: DynamicType.f)]),
      );
      expect(chord.dynamics.first.type, equals(DynamicType.f));
    });
  });

  group('MusicEvent sealed type', () {
    test('switch is exhaustive over all subtypes', () {
      final MusicEvent event = _note();
      final name = switch (event) {
        NoteEvent() => 'note',
        RestEvent() => 'rest',
        ChordEvent() => 'chord',
      };
      expect(name, equals('note'));
    });
  });
}
