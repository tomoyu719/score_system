/// score_core public API — immutable data model, CommandEngine, and undo/redo.
library;

// IDs
export 'src/ids.dart';

// Exception
export 'src/score_exception.dart';

// Model — primitives
export 'src/model/fraction.dart';
export 'src/model/note_type.dart';
export 'src/model/note_value.dart';
export 'src/model/pitch.dart';
export 'src/model/placement.dart';

// Model — notation annotations
export 'src/model/articulation.dart';
export 'src/model/dynamic.dart';
export 'src/model/lyric.dart';
export 'src/model/fingering.dart';

// Model — events
export 'src/model/music_event.dart'; // re-exports NoteEvent, RestEvent, ChordEvent via parts

// Model — hierarchy
export 'src/model/voice.dart';
export 'src/model/measure.dart';
export 'src/model/staff.dart';
export 'src/model/part.dart';

// Model — headers and barlines
export 'src/model/time_signature.dart';
export 'src/model/key_signature.dart';
export 'src/model/tempo.dart';
export 'src/model/barline.dart';
export 'src/model/measure_header.dart';

// Model — edge elements
export 'src/model/beam_group.dart';
export 'src/model/slur.dart';
export 'src/model/tie.dart';
export 'src/model/tuplet.dart';

// Model — root aggregate
export 'src/model/score.dart';
export 'src/model/voice_context.dart';

// Commands
export 'src/command/command.dart'; // re-exports all command subclasses via parts
export 'src/command/command_result.dart';
export 'src/command/command_engine.dart';
export 'src/command/command_record.dart';
export 'src/command/score_history.dart';
export 'src/command/audit_log.dart';

// Validation
export 'src/validation/validation_error.dart';
export 'src/validation/validation_result.dart';
export 'src/validation/validator.dart';
