/// score_layout public API — logical layout calculation for score_system.
library;

// Model — layout elements
export 'src/model/layout_element.dart'; // NoteLayout, PercussionNoteLayout, RestLayout, BeamLayout, StemLayout, AccidentalLayout, ArticulationLayout via parts
export 'src/model/voice_layout.dart';
export 'src/model/measure_layout.dart';
export 'src/model/staff_layout.dart';
export 'src/model/system_layout.dart';

// Model — root
export 'src/layout_tree.dart';

// Engines
export 'src/engine/clef_staff_line_mapper.dart';
export 'src/engine/stem_direction_calculator.dart';
export 'src/engine/rest_positioning_calculator.dart';
export 'src/engine/shared_notehead_detector.dart';
export 'src/engine/measure_spacing_engine.dart';
export 'src/engine/staff_spacing_engine.dart';

// Calculator + cache
export 'src/layout_calculator.dart';
export 'src/layout_cache.dart';
