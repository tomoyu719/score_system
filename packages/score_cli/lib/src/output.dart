import 'dart:convert';
import 'dart:io';

/// Output format for CLI commands.
enum OutputFormat { json, pretty }

/// Writes structured output to stdout (success) and stderr (errors).
final class OutputWriter {
  const OutputWriter({this.format = OutputFormat.json});

  final OutputFormat format;

  /// Writes a success payload to stdout.
  void writeSuccess(Map<String, Object?> data) {
    if (format == OutputFormat.pretty) {
      stdout.writeln(const JsonEncoder.withIndent('  ').convert(data));
    } else {
      stdout.writeln(jsonEncode(data));
    }
  }

  /// Writes an error to stderr as JSON always.
  void writeError(String message, {int code = 1}) {
    stderr.writeln(jsonEncode({'error': message, 'code': code}));
  }

  /// Writes plain human-readable text to stdout when format is pretty.
  void writePretty(String text) {
    if (format == OutputFormat.pretty) stdout.writeln(text);
  }
}
