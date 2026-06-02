import 'package:score_core/src/command/audit_log.dart';
import 'package:score_core/src/command/command.dart';
import 'package:score_core/src/command/command_result.dart';
import 'package:score_core/src/ids.dart';
import 'package:score_core/src/model/part.dart';
import 'package:score_core/src/model/score.dart';
import 'package:test/test.dart';

AuditEntry _entry() => AuditEntry(
      command: AddPartCommand(part: Part(id: const PartId('p'), name: 'x')),
      result: CommandSuccess(
          scoreAfter: Score(id: const ScoreId('s'))),
      timestamp: DateTime(2024),
    );

void main() {
  group('AuditLog', () {
    test('starts empty', () {
      const log = AuditLog();
      expect(log.entries.isEmpty, isTrue);
    });

    test('append adds entry', () {
      const log = AuditLog();
      final log2 = log.append(_entry());
      expect(log2.entries.length, equals(1));
    });

    test('append does not mutate original', () {
      const log = AuditLog();
      log.append(_entry());
      expect(log.entries.isEmpty, isTrue);
    });

    test('entries preserve insertion order', () {
      const log = AuditLog();
      final e1 = _entry();
      final e2 = _entry();
      final log2 = log.append(e1).append(e2);
      expect(log2.entries[0], same(e1));
      expect(log2.entries[1], same(e2));
    });
  });
}
