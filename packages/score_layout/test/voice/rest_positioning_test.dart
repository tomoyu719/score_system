import 'package:score_core/score_core.dart';
import 'package:score_layout/score_layout.dart';
import 'package:test/test.dart';

void main() {
  const positioning = RestPositioning();

  group('RestPositioning', () {
    test('whole note rest → staffLine 6', () {
      expect(positioning.staffLineForRest(NoteType.whole), 6.0);
    });

    test('half note rest → staffLine 6', () {
      expect(positioning.staffLineForRest(NoteType.half), 6.0);
    });

    test('quarter note rest → staffLine 4', () {
      expect(positioning.staffLineForRest(NoteType.quarter), 4.0);
    });

    test('eighth note rest → staffLine 4', () {
      expect(positioning.staffLineForRest(NoteType.eighth), 4.0);
    });

    test('sixteenth note rest → staffLine 4', () {
      expect(positioning.staffLineForRest(NoteType.sixteenth), 4.0);
    });

    test('thirtySecond note rest → staffLine 4', () {
      expect(positioning.staffLineForRest(NoteType.thirtySecond), 4.0);
    });

    test('sixtyFourth note rest → staffLine 4', () {
      expect(positioning.staffLineForRest(NoteType.sixtyFourth), 4.0);
    });
  });
}
