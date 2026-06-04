import 'package:score_core/score_core.dart';
import 'package:test/test.dart';

const _snare = DrumInstrument(
  name: 'Snare',
  staffLine: 0,
  noteHeadType: NoteHeadType.normal,
  midiNote: 38,
);

PercussionNote _snareHit() => PercussionNote(
      id: const PercussionNoteId('pn1'),
      offset: Fraction.zero,
      noteValue: NoteValue(noteType: NoteType.quarter),
      instrument: _snare,
    );

void main() {
  group('PercussionNote', () {
    test('is a MusicEvent', () {
      expect(_snareHit(), isA<MusicEvent>());
    });

    test('stores fields correctly', () {
      final hit = _snareHit();
      expect(hit.id, equals(const PercussionNoteId('pn1')));
      expect(hit.instrument, equals(_snare));
      expect(hit.offset, equals(Fraction.zero));
      expect(hit.isGrace, isFalse);
      expect(hit.articulations, isEmpty);
    });

    test('copyWith overrides specified fields', () {
      final original = _snareHit();
      final copy = original.copyWith(isGrace: true);
      expect(copy.isGrace, isTrue);
      expect(copy.id, equals(original.id));
      expect(copy.instrument, equals(_snare));
    });

    test('equality based on value', () {
      expect(_snareHit(), equals(_snareHit()));
    });

    test('switch exhaustiveness — PercussionNote is a sealed variant', () {
      final MusicEvent event = _snareHit();
      final label = switch (event) {
        NoteEvent() => 'note',
        RestEvent() => 'rest',
        ChordEvent() => 'chord',
        PercussionNote() => 'percussion',
      };
      expect(label, equals('percussion'));
    });
  });

  group('PercussionNoteId', () {
    test('IdFactory.percussionNote() generates unique ids', () {
      final id1 = IdFactory.percussionNote();
      final id2 = IdFactory.percussionNote();
      expect(id1.value, isNotEmpty);
      expect(id1, isNot(equals(id2)));
    });
  });
}
