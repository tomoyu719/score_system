import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:test/test.dart';

void main() {
  group('NoteHeadType', () {
    test('all expected values exist', () {
      expect(NoteHeadType.values, contains(NoteHeadType.normal));
      expect(NoteHeadType.values, contains(NoteHeadType.cross));
      expect(NoteHeadType.values, contains(NoteHeadType.openCross));
      expect(NoteHeadType.values, contains(NoteHeadType.diamond));
    });
  });

  group('DrumInstrument', () {
    const snare = DrumInstrument(
      name: 'Snare',
      staffLine: 0,
      noteHeadType: NoteHeadType.normal,
      midiNote: 38,
    );

    test('stores fields correctly', () {
      expect(snare.name, equals('Snare'));
      expect(snare.staffLine, equals(0));
      expect(snare.noteHeadType, equals(NoteHeadType.normal));
      expect(snare.midiNote, equals(38));
    });

    test('copyWith overrides specified fields', () {
      final copy = snare.copyWith(staffLine: 2);
      expect(copy.name, equals('Snare'));
      expect(copy.staffLine, equals(2));
    });

    test('equality based on value', () {
      expect(
        snare,
        equals(const DrumInstrument(
          name: 'Snare',
          staffLine: 0,
          noteHeadType: NoteHeadType.normal,
          midiNote: 38,
        )),
      );
    });
  });

  group('DrumMapping', () {
    test('lookup returns correct instrument', () {
      const instrument =
          DrumInstrument(name: 'Kick', staffLine: -4, noteHeadType: NoteHeadType.normal, midiNote: 36);
      final mapping = DrumMapping(
        midiNoteToInstrument: IMap({36: instrument}),
      );
      expect(mapping.lookup(36), equals(instrument));
    });

    test('lookup returns null for unmapped note', () {
      final mapping = DrumMapping(midiNoteToInstrument: IMap({}));
      expect(mapping.lookup(99), isNull);
    });

    test('equality based on value', () {
      const instrument =
          DrumInstrument(name: 'Kick', staffLine: -4, noteHeadType: NoteHeadType.normal, midiNote: 36);
      expect(
        DrumMapping(midiNoteToInstrument: IMap({36: instrument})),
        equals(DrumMapping(midiNoteToInstrument: IMap({36: instrument}))),
      );
    });
  });

  group('generalMidiDrumMap', () {
    test('contains Snare at MIDI 38', () {
      final instrument = generalMidiDrumMap.lookup(38);
      expect(instrument, isNotNull);
      expect(instrument!.name, equals('Snare'));
      expect(instrument.noteHeadType, equals(NoteHeadType.normal));
    });

    test('contains Hi-Hat Closed at MIDI 42 with cross notehead', () {
      final instrument = generalMidiDrumMap.lookup(42);
      expect(instrument, isNotNull);
      expect(instrument!.name, equals('Hi-Hat Closed'));
      expect(instrument.noteHeadType, equals(NoteHeadType.cross));
    });

    test('contains Hi-Hat Open at MIDI 46 with openCross notehead', () {
      final instrument = generalMidiDrumMap.lookup(46);
      expect(instrument?.noteHeadType, equals(NoteHeadType.openCross));
    });

    test('contains Bass Drum 1 at MIDI 36', () {
      final instrument = generalMidiDrumMap.lookup(36);
      expect(instrument?.name, equals('Bass Drum 1'));
    });

    test('returns null for unmapped note', () {
      expect(generalMidiDrumMap.lookup(1), isNull);
    });
  });

  group('PercussionConfig', () {
    test('stores drumMapping', () {
      final config = PercussionConfig(drumMapping: generalMidiDrumMap);
      expect(config.drumMapping, equals(generalMidiDrumMap));
    });

    test('copyWith replaces drumMapping', () {
      final config = PercussionConfig(drumMapping: generalMidiDrumMap);
      final empty = DrumMapping(midiNoteToInstrument: IMap({}));
      final copy = config.copyWith(drumMapping: empty);
      expect(copy.drumMapping, equals(empty));
    });

    test('equality based on value', () {
      expect(
        PercussionConfig(drumMapping: generalMidiDrumMap),
        equals(PercussionConfig(drumMapping: generalMidiDrumMap)),
      );
    });
  });

  group('Staff.percussionConfig', () {
    test('defaults to null for standard staff', () {
      final staff = Staff(id: const StaffId('s1'));
      expect(staff.percussionConfig, isNull);
    });

    test('can be set on a percussion staff', () {
      final config = PercussionConfig(drumMapping: generalMidiDrumMap);
      final staff = Staff(
        id: const StaffId('s1'),
        staffType: StaffType.percussion,
        percussionConfig: config,
      );
      expect(staff.percussionConfig, equals(config));
    });
  });
}
