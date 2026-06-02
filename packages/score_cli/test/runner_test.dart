import 'package:score_cli/score_cli.dart';
import 'package:test/test.dart';

void main() {
  group('ScoreRunner', () {
    test('unknown subcommand returns exit 1', () async {
      final exitCode = await ScoreRunner().run(['totally-unknown-cmd']);
      expect(exitCode, equals(1));
    });

    test('no arguments returns exit 1', () async {
      final exitCode = await ScoreRunner().run([]);
      expect(exitCode, equals(1));
    });
  });
}
