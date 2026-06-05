import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

NoteLayout note(String id, int staffLine, {String offset = '0/1'}) => NoteLayout(
      noteId: NoteId(id),
      offset: Fraction.fromString(offset),
      staffLine: staffLine,
      stemDirection: StemDirection.down,
    );

VoiceLayout voiceWith(List<NoteLayout> notes) => VoiceLayout(
      voiceId: const VoiceId('v'),
      notes: IList(notes),
    );

void main() {
  const detector = SharedNoteheadDetector();

  group('SharedNoteheadDetector', () {
    test('single voice — no shared noteheads', () {
      final voices = IList([voiceWith([note('n1', 4), note('n2', 6)])]);
      expect(detector.detect(voices), isEmpty);
    });

    test('two voices, same offset + staffLine → shared', () {
      final v1 = voiceWith([note('n1', 4)]);
      final v2 = voiceWith([note('n2', 4)]);
      final shared = detector.detect(IList([v1, v2]));
      expect(shared, containsAll([const NoteId('n1'), const NoteId('n2')]));
    });

    test('two voices, same offset but different staffLine → not shared', () {
      final v1 = voiceWith([note('n1', 4)]);
      final v2 = voiceWith([note('n2', 6)]);
      expect(detector.detect(IList([v1, v2])), isEmpty);
    });

    test('two voices, different offsets, same staffLine → not shared', () {
      final v1 = voiceWith([note('n1', 4, offset: '0/1')]);
      final v2 = voiceWith([note('n2', 4, offset: '1/4')]);
      expect(detector.detect(IList([v1, v2])), isEmpty);
    });

    test('three notes at same offset + staffLine → all three shared', () {
      final voices = IList([
        voiceWith([note('n1', 4)]),
        voiceWith([note('n2', 4)]),
        voiceWith([note('n3', 4)]),
      ]);
      final shared = detector.detect(voices);
      expect(shared.length, equals(3));
    });
  });
}
