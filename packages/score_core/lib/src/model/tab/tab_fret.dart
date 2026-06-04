import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'guitar_technique.dart';

/// Fret/string assignment for a note in a TAB staff.
final class TabFret {
  const TabFret({
    required this.stringNumber,
    required this.fretNumber,
    this.techniques = const IListConst([]),
    this.isManualOverride = false,
  }) : assert(stringNumber >= 1, 'stringNumber must be >= 1'),
       assert(fretNumber >= 0, 'fretNumber must be >= 0');

  /// String number (1-indexed, 1 = lowest string).
  final int stringNumber;

  /// Fret number (0 = open string).
  final int fretNumber;

  /// Guitar techniques applied at this fret.
  final IList<GuitarTechnique> techniques;

  /// True when the user has manually overridden the auto-calculated fret.
  final bool isManualOverride;

  TabFret copyWith({
    int? stringNumber,
    int? fretNumber,
    IList<GuitarTechnique>? techniques,
    bool? isManualOverride,
  }) =>
      TabFret(
        stringNumber: stringNumber ?? this.stringNumber,
        fretNumber: fretNumber ?? this.fretNumber,
        techniques: techniques ?? this.techniques,
        isManualOverride: isManualOverride ?? this.isManualOverride,
      );

  @override
  bool operator ==(Object other) {
    if (other is! TabFret) return false;
    return stringNumber == other.stringNumber &&
        fretNumber == other.fretNumber &&
        techniques == other.techniques &&
        isManualOverride == other.isManualOverride;
  }

  @override
  int get hashCode =>
      Object.hash(stringNumber, fretNumber, techniques, isManualOverride);
}
