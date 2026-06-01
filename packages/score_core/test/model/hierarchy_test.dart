import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/src/ids.dart';
import 'package:score_core/src/model/fraction.dart';
import 'package:score_core/src/model/measure.dart';
import 'package:score_core/src/model/music_event.dart';
import 'package:score_core/src/model/note_type.dart';
import 'package:score_core/src/model/note_value.dart';
import 'package:score_core/src/model/part.dart';
import 'package:score_core/src/model/pitch.dart';
import 'package:score_core/src/model/staff.dart';
import 'package:score_core/src/model/voice.dart';
import 'package:test/test.dart';

NoteEvent _qNote(String id, [Step step = Step.c]) => NoteEvent(
      id: NoteId(id),
      offset: Fraction.zero,
      noteValue: NoteValue(noteType: NoteType.quarter),
      pitch: Pitch(step: step, octave: 4),
    );

void main() {
  group('Voice', () {
    test('empty voice has zero totalDuration', () {
      final v = Voice(id: const VoiceId('v1'));
      expect(v.totalDuration, equals(Fraction.zero));
    });

    test('4 quarter notes = 1 whole', () {
      final v = Voice(
        id: const VoiceId('v1'),
        events: IList([
          _qNote('n1'),
          _qNote('n2'),
          _qNote('n3'),
          _qNote('n4'),
        ]),
      );
      expect(v.totalDuration, equals(Fraction(1, 1)));
    });

    test('copyWith events creates new Voice, original unchanged', () {
      final original = Voice(id: const VoiceId('v1'));
      final updated = original.copyWith(
        events: original.events.add(_qNote('n1')),
      );
      expect(updated.events.length, equals(1));
      expect(original.events.length, equals(0));
    });
  });

  group('Measure', () {
    test('empty measure has no voices', () {
      final m = Measure(id: const MeasureId('m1'));
      expect(m.voices.isEmpty, isTrue);
    });

    test('can add a voice', () {
      final v = Voice(id: const VoiceId('v1'));
      final m = Measure(
        id: const MeasureId('m1'),
        voices: IMap({const VoiceId('v1'): v}),
      );
      expect(m.voices.length, equals(1));
      expect(m.voices[const VoiceId('v1')], equals(v));
    });

    test('copyWith replaces voices map', () {
      final m1 = Measure(id: const MeasureId('m1'));
      final v = Voice(id: const VoiceId('v1'));
      final m2 = m1.copyWith(
        voices: IMap({const VoiceId('v1'): v}),
      );
      expect(m1.voices.isEmpty, isTrue);
      expect(m2.voices.length, equals(1));
    });
  });

  group('Staff', () {
    test('empty staff has no measures', () {
      final s = Staff(id: const StaffId('s1'));
      expect(s.measures.isEmpty, isTrue);
    });

    test('can add measures by number', () {
      final m = Measure(id: const MeasureId('m1'));
      final s = Staff(
        id: const StaffId('s1'),
        measures: IMap({1: m}),
      );
      expect(s.measures[1], equals(m));
    });

    test('staffType defaults to standard', () {
      final s = Staff(id: const StaffId('s1'));
      expect(s.staffType, equals(StaffType.standard));
    });

    test('copyWith changes staffType', () {
      final s = Staff(id: const StaffId('s1'));
      final tab = s.copyWith(staffType: StaffType.tab);
      expect(tab.staffType, equals(StaffType.tab));
      expect(s.staffType, equals(StaffType.standard));
    });
  });

  group('Part', () {
    test('part has required name', () {
      final p = Part(id: const PartId('p1'), name: 'Violin');
      expect(p.name, equals('Violin'));
    });

    test('shortName defaults to empty', () {
      final p = Part(id: const PartId('p1'), name: 'Violin');
      expect(p.shortName, isEmpty);
    });

    test('copyWith changes name only', () {
      final p = Part(id: const PartId('p1'), name: 'Violin');
      final p2 = p.copyWith(name: 'Viola');
      expect(p2.name, equals('Viola'));
      expect(p.name, equals('Violin'));
      expect(p2.id, equals(p.id));
    });

    test('can add staves', () {
      final s = Staff(id: const StaffId('s1'));
      final p = Part(
        id: const PartId('p1'),
        name: 'Piano',
        staves: IList([s]),
      );
      expect(p.staves.length, equals(1));
    });
  });
}
