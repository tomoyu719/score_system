import 'package:score_cli/score_cli.dart';
import 'package:test/test.dart';

void main() {
  group('OutputFormat', () {
    test('has json and pretty values', () {
      expect(OutputFormat.values, contains(OutputFormat.json));
      expect(OutputFormat.values, contains(OutputFormat.pretty));
    });
  });

  group('OutputWriter', () {
    test('default format is json', () {
      const writer = OutputWriter();
      expect(writer.format, equals(OutputFormat.json));
    });

    test('can be constructed with pretty format', () {
      const writer = OutputWriter(format: OutputFormat.pretty);
      expect(writer.format, equals(OutputFormat.pretty));
    });
  });
}
