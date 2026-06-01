import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';
import '../model/measure.dart';
import '../model/music_event.dart';
import '../model/part.dart';

part 'add_note_command.dart';
part 'remove_note_command.dart';
part 'add_part_command.dart';
part 'add_measure_command.dart';
part 'batch_command.dart';

/// Base class for all score mutation commands.
sealed class Command {
  const Command();
}
