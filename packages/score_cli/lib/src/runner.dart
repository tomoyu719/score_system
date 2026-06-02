import 'package:args/args.dart';

import 'commands/diff_command.dart';
import 'commands/export_command.dart';
import 'commands/import_command.dart';
import 'commands/inspect_command.dart';
import 'commands/layout_command.dart';
import 'commands/new_command.dart';
import 'commands/validate_command.dart';
import 'output.dart';

/// Top-level CLI runner: parses arguments and dispatches to commands.
final class ScoreRunner {
  const ScoreRunner();

  Future<int> run(List<String> arguments) async {
    final output = const OutputWriter();

    if (arguments.isEmpty) {
      output.writeError('No command specified. Use --help for usage.', code: 1);
      return 1;
    }

    final command = arguments[0];
    final rest = arguments.sublist(1);

    switch (command) {
      case 'new':
        return _runNew(rest, output);
      case 'validate':
        return _runValidate(rest, output);
      case 'import':
        return _runImport(rest, output);
      case 'export':
        return _runExport(rest, output);
      case 'layout':
        return _runLayout(rest, output);
      case 'collisions':
        return _runCollisions(rest, output);
      case 'fix-collisions':
        return _runFixCollisions(rest, output);
      case 'inspect':
        return _runInspect(rest, output);
      case 'diff':
        return _runDiff(rest, output);
      case 'tui':
        output.writeError(
          'not yet implemented',
          code: 1,
        );
        return 1;
      case 'mcp':
        output.writeError(
          'not yet implemented',
          code: 1,
        );
        return 1;
      default:
        output.writeError('Unknown command: $command', code: 1);
        return 1;
    }
  }

  Future<int> _runNew(List<String> args, OutputWriter output) async {
    final parser = ArgParser()
      ..addOption('title', defaultsTo: '')
      ..addOption('composer', defaultsTo: '')
      ..addOption('out');

    final ArgResults parsed;
    try {
      parsed = parser.parse(args);
    } catch (e) {
      output.writeError('Invalid arguments: $e', code: 1);
      return 1;
    }

    return const NewCommand().run(parsed, output);
  }

  Future<int> _runValidate(List<String> args, OutputWriter output) async {
    final parser = ArgParser()..addOption('in');

    final ArgResults parsed;
    try {
      parsed = parser.parse(args);
    } catch (e) {
      output.writeError('Invalid arguments: $e', code: 1);
      return 1;
    }

    return const ValidateCommand().run(parsed, output);
  }

  Future<int> _runImport(List<String> args, OutputWriter output) async {
    if (args.isEmpty) {
      output.writeError('import requires a format (e.g. musicxml)', code: 1);
      return 1;
    }

    final subformat = args[0];
    final parser = ArgParser()
      ..addOption('in')
      ..addOption('out');

    final ArgResults parsed;
    try {
      parsed = parser.parse(args.sublist(1));
    } catch (e) {
      output.writeError('Invalid arguments: $e', code: 1);
      return 1;
    }

    return const ImportCommand().run(subformat, parsed, output);
  }

  Future<int> _runExport(List<String> args, OutputWriter output) async {
    if (args.isEmpty) {
      output.writeError(
        'export requires a format (e.g. musicxml, midi)',
        code: 1,
      );
      return 1;
    }

    final subformat = args[0];
    final parser = ArgParser()
      ..addOption('in')
      ..addOption('out');

    final ArgResults parsed;
    try {
      parsed = parser.parse(args.sublist(1));
    } catch (e) {
      output.writeError('Invalid arguments: $e', code: 1);
      return 1;
    }

    return const ExportCommand().run(subformat, parsed, output);
  }

  Future<int> _runLayout(List<String> args, OutputWriter output) async {
    final parser = ArgParser()..addOption('in');

    final ArgResults parsed;
    try {
      parsed = parser.parse(args);
    } catch (e) {
      output.writeError('Invalid arguments: $e', code: 1);
      return 1;
    }

    return const LayoutCommand().runLayout(parsed, output);
  }

  Future<int> _runCollisions(List<String> args, OutputWriter output) async {
    final parser = ArgParser()..addOption('in');

    final ArgResults parsed;
    try {
      parsed = parser.parse(args);
    } catch (e) {
      output.writeError('Invalid arguments: $e', code: 1);
      return 1;
    }

    return const LayoutCommand().runCollisions(parsed, output);
  }

  Future<int> _runFixCollisions(List<String> args, OutputWriter output) async {
    final parser = ArgParser()
      ..addOption('in')
      ..addOption('out');

    final ArgResults parsed;
    try {
      parsed = parser.parse(args);
    } catch (e) {
      output.writeError('Invalid arguments: $e', code: 1);
      return 1;
    }

    return const LayoutCommand().runFixCollisions(parsed, output);
  }

  Future<int> _runInspect(List<String> args, OutputWriter output) async {
    final parser = ArgParser()
      ..addOption('in')
      ..addFlag('midi', defaultsTo: false);

    final ArgResults parsed;
    try {
      parsed = parser.parse(args);
    } catch (e) {
      output.writeError('Invalid arguments: $e', code: 1);
      return 1;
    }

    return const InspectCommand().run(parsed, output);
  }

  Future<int> _runDiff(List<String> args, OutputWriter output) async {
    final parser = ArgParser()
      ..addOption('a')
      ..addOption('b');

    final ArgResults parsed;
    try {
      parsed = parser.parse(args);
    } catch (e) {
      output.writeError('Invalid arguments: $e', code: 1);
      return 1;
    }

    return const DiffCommand().run(parsed, output);
  }
}
