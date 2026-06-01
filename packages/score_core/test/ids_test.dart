import 'package:score_core/src/ids.dart';
import 'package:test/test.dart';

void main() {
  group('Type-safe IDs', () {
    test('NoteId equals same value', () {
      expect(NoteId('a'), equals(NoteId('a')));
    });

    test('RestId equals same value', () {
      expect(RestId('x'), equals(RestId('x')));
    });

    test('NoteId differs from different value', () {
      expect(NoteId('a'), isNot(equals(NoteId('b'))));
    });

    test('IdFactory generates unique NoteIds', () {
      final id1 = IdFactory.note();
      final id2 = IdFactory.note();
      expect(id1, isNot(equals(id2)));
    });

    test('IdFactory generates unique RestIds', () {
      final id1 = IdFactory.rest();
      final id2 = IdFactory.rest();
      expect(id1, isNot(equals(id2)));
    });

    test('IdFactory generates unique ChordIds', () {
      expect(IdFactory.chord(), isNot(equals(IdFactory.chord())));
    });

    test('NoteId has correct underlying value', () {
      const id = NoteId('test-123');
      expect(id.value, equals('test-123'));
    });

    test('VoiceId has correct underlying value', () {
      const id = VoiceId('voice-1');
      expect(id.value, equals('voice-1'));
    });
  });
}
