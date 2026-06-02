import 'dart:io';

import 'package:score_cli/score_cli.dart';

Future<void> main(List<String> args) async {
  final exitCode = await ScoreRunner().run(args);
  exit(exitCode);
}
