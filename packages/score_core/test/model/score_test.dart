import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/src/ids.dart';
import 'package:score_core/src/model/key_signature.dart';
import 'package:score_core/src/model/measure.dart';
import 'package:score_core/src/model/measure_header.dart';
import 'package:score_core/src/model/part.dart';
import 'package:score_core/src/model/score.dart';
import 'package:score_core/src/model/staff.dart';
import 'package:score_core/src/model/time_signature.dart';
import 'package:score_core/src/model/voice.dart';
import 'package:test/test.dart';

Score _emptyScore() => Score(id: const ScoreId('s1'));

void main() {
  group('Score', () {
    test('empty score has no parts', () {
      expect(_emptyScore().parts.isEmpty, isTrue);
    });

    test('title defaults to empty', () {
      expect(_emptyScore().title, isEmpty);
    });

    test('copyWith title does not affect parts', () {
      final score = _emptyScore();
      final titled = score.copyWith(title: 'Symphony No. 5');
      expect(titled.title, equals('Symphony No. 5'));
      expect(titled.parts, same(score.parts)); // structural sharing
    });

    test('copyWith parts replaces parts list', () {
      final score = _emptyScore();
      final part = Part(id: const PartId('p1'), name: 'Violin');
      final updated = score.copyWith(parts: IList([part]));
      expect(updated.parts.length, equals(1));
      expect(score.parts.isEmpty, isTrue);
    });

    test('headerForMeasure returns correct header', () {
      const ts = TimeSignature(beats: 4, beatType: 4);
      const ks = KeySignature(fifths: 0);
      final h1 = MeasureHeader(
        measureNumber: 1,
        timeSignature: ts,
        keySignature: ks,
      );
      final h2 = MeasureHeader(
        measureNumber: 2,
        timeSignature: ts,
        keySignature: ks,
      );
      final score = _emptyScore().copyWith(
        measureHeaders: IList([h1, h2]),
      );
      expect(score.headerForMeasure(1), equals(h1));
      expect(score.headerForMeasure(2), equals(h2));
      expect(score.headerForMeasure(99), isNull);
    });

    test('allVoices yields empty iterable for score with no parts', () {
      expect(_emptyScore().allVoices, isEmpty);
    });

    test('allVoices yields one VoiceContext per voice', () {
      const voiceId = VoiceId('v1');
      final measure = const Measure(id: MeasureId('m1'))
          .updateVoice(voiceId, (v) => Voice(id: voiceId));
      final staff =
          Staff(id: const StaffId('s1')).updateMeasure(1, (_) => measure);
      final part = Part(
        id: const PartId('p1'),
        name: 'Piano',
        staves: Part(id: const PartId('p1'), name: '').staves.add(staff),
      );
      final score = _emptyScore().copyWith(parts: IList([part]));
      final contexts = score.allVoices.toList();
      expect(contexts.length, equals(1));
      expect(contexts[0].partId, equals(const PartId('p1')));
      expect(contexts[0].staffId, equals(const StaffId('s1')));
      expect(contexts[0].measureNumber, equals(1));
      expect(contexts[0].voiceId, equals(voiceId));
    });

    test('allVoices yields contexts for multiple parts and measures', () {
      Score addVoice(Score s, String partName, int measureNumber) {
        final pid = PartId(partName);
        final sid = const StaffId('s1');
        const vid = VoiceId('v1');
        final measure = const Measure(id: MeasureId('m'))
            .updateVoice(vid, (v) => Voice(id: vid));
        final staff =
            Staff(id: sid).updateMeasure(measureNumber, (_) => measure);
        final part = Part(
          id: pid,
          name: partName,
          staves: Part(id: pid, name: '').staves.add(staff),
        );
        return s.copyWith(parts: s.parts.add(part));
      }

      var score = _emptyScore();
      score = addVoice(score, 'p1', 1);
      score = addVoice(score, 'p2', 1);
      expect(score.allVoices.length, equals(2));
    });

    test('immutability: original unchanged after copyWith', () {
      final original = _emptyScore();
      original.copyWith(
        title: 'New',
        parts: IList([Part(id: const PartId('p1'), name: 'Piano')]),
      );
      expect(original.title, isEmpty);
      expect(original.parts.isEmpty, isTrue);
    });
  });
}
