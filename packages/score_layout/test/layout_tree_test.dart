import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  group('LayoutTree JSON roundtrip', () {
    test('empty tree', () {
      const tree = LayoutTree();
      final rt = LayoutTree.fromJson(tree.toJson());
      expect(rt, equals(tree));
    });

    test('tree with one system and one measure', () {
      final tree = LayoutTree(
        systems: IList([
          SystemLayout(
            staves: IList([
              const StaffLayout(
                partId: PartId('p1'),
                staffId: StaffId('s1'),
                relativeY: 0,
              ),
            ]),
            measures: IList([
              MeasureLayout(
                measureNumber: 1,
                relativeWidth: 1.0,
                voices: IList([
                  VoiceLayout(
                    voiceId: const VoiceId('v1'),
                    notes: IList([
                      NoteLayout(
                        noteId: const NoteId('n1'),
                        offset: Fraction.zero,
                        staffLine: 4,
                        stemDirection: StemDirection.down,
                      ),
                    ]),
                    rests: IList([
                      RestLayout(
                        restId: const RestId('r1'),
                        offset: Fraction(1, 4),
                        staffLine: 4,
                      ),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ]),
      );

      final rt = LayoutTree.fromJson(tree.toJson());
      expect(rt, equals(tree));
    });

    test('NoteLayout with accidentals roundtrip', () {
      final note = NoteLayout(
        noteId: const NoteId('n1'),
        offset: Fraction.zero,
        staffLine: 2,
        stemDirection: StemDirection.up,
        isSharedNotehead: true,
        accidentals: IList([
          const AccidentalLayout(noteId: NoteId('n1'), type: 'sharp'),
        ]),
        articulations: IList([
          const ArticulationLayout(
              noteId: NoteId('n1'), articulationType: 'accent'),
        ]),
      );
      final rt = NoteLayout.fromJson(note.toJson());
      expect(rt, equals(note));
    });

    test('PercussionNoteLayout roundtrip', () {
      final pn = PercussionNoteLayout(
        percussionNoteId: const PercussionNoteId('pn1'),
        offset: Fraction(0, 1),
        staffLine: 0,
        stemDirection: StemDirection.down,
      );
      final rt = PercussionNoteLayout.fromJson(pn.toJson());
      expect(rt, equals(pn));
    });
  });
}
