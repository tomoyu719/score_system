import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';

part 'note_layout.dart';
part 'percussion_note_layout.dart';
part 'rest_layout.dart';
part 'beam_layout.dart';
part 'stem_layout.dart';
part 'accidental_layout.dart';
part 'articulation_layout.dart';

/// Base for all logical layout elements in a [LayoutTree].
sealed class LayoutElement {
  const LayoutElement();
}
