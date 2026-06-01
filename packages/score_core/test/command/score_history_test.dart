import 'package:score_core/src/command/command.dart';
import 'package:score_core/src/command/command_record.dart';
import 'package:score_core/src/command/score_history.dart';
import 'package:score_core/src/ids.dart';
import 'package:score_core/src/model/part.dart';
import 'package:score_core/src/model/score.dart';
import 'package:test/test.dart';

Score _score(String id) => Score(id: ScoreId(id));

CommandRecord _makeRecord(Score before, Score after) => CommandRecord(
      command: AddPartCommand(
        part: Part(id: const PartId('p'), name: 'x'),
      ),
      scoreBefore: before,
      scoreAfter: after,
      timestamp: DateTime(2024),
    );

void main() {
  group('ScoreHistory', () {
    test('starts empty', () {
      const h = ScoreHistory();
      expect(h.undoStack.isEmpty, isTrue);
      expect(h.redoStack.isEmpty, isTrue);
    });

    test('push adds to undoStack and clears redoStack', () {
      final before = _score('s1');
      final after = _score('s2');
      final record = _makeRecord(before, after);
      const h = ScoreHistory();
      final h2 = h.push(record);
      expect(h2.undoStack.length, equals(1));
      expect(h2.redoStack.isEmpty, isTrue);
    });

    test('undo returns previous score and moves to redoStack', () {
      final before = _score('s1');
      final after = _score('s2');
      const h = ScoreHistory();
      final h2 = h.push(_makeRecord(before, after));
      final (restoredScore, h3) = h2.undo()!;
      expect(restoredScore, same(before));
      expect(h3.undoStack.isEmpty, isTrue);
      expect(h3.redoStack.length, equals(1));
    });

    test('redo after undo restores forward state', () {
      final s1 = _score('s1');
      final s2 = _score('s2');
      const h = ScoreHistory();
      final h2 = h.push(_makeRecord(s1, s2));
      final (_, h3) = h2.undo()!;
      final (redoScore, h4) = h3.redo()!;
      expect(redoScore, same(s2));
      expect(h4.undoStack.length, equals(1));
      expect(h4.redoStack.isEmpty, isTrue);
    });

    test('undo on empty history returns null', () {
      const h = ScoreHistory();
      expect(h.undo(), isNull);
    });

    test('redo on empty history returns null', () {
      const h = ScoreHistory();
      expect(h.redo(), isNull);
    });

    test('new push after undo clears redoStack', () {
      final s1 = _score('s1');
      final s2 = _score('s2');
      final s3 = _score('s3');
      const h = ScoreHistory();
      final h2 = h.push(_makeRecord(s1, s2));
      final (_, h3) = h2.undo()!;
      expect(h3.redoStack.length, equals(1));
      final h4 = h3.push(_makeRecord(s1, s3));
      expect(h4.redoStack.isEmpty, isTrue);
      expect(h4.undoStack.length, equals(1));
    });

    test('push drops oldest record when exceeding maxSteps', () {
      final s0 = _score('s0');
      var h = const ScoreHistory(maxSteps: 3);
      for (var i = 1; i <= 4; i++) {
        final sNext = _score('s$i');
        h = h.push(_makeRecord(s0, sNext));
      }
      expect(h.undoStack.length, equals(3));
    });

    test('undo/redo chain across multiple commands', () {
      final scores = List.generate(5, (i) => _score('s$i'));
      var h = const ScoreHistory();
      for (var i = 0; i < 4; i++) {
        h = h.push(_makeRecord(scores[i], scores[i + 1]));
      }
      expect(h.undoStack.length, equals(4));

      // Undo 2 steps
      final (r1, h2) = h.undo()!;
      expect(r1, same(scores[3]));
      final (r2, h3) = h2.undo()!;
      expect(r2, same(scores[2]));

      // Redo 1 step: restores the most recently undone state (s3→s4's scoreBefore was s3,
      // so redo of (s2→s3) yields scoreAfter = s3 = scores[3])
      final (r3, _) = h3.redo()!;
      expect(r3, same(scores[3]));
    });
  });
}
