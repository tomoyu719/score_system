import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'bounding_box.dart';
import 'layout_element.dart';

/// All layout elements belonging to one measure.
final class LayoutMeasure {
  const LayoutMeasure({
    required this.measureNumber,
    required this.elements,
    required this.bounds,
  });

  final int measureNumber;
  final IList<LayoutElement> elements;
  final BoundingBox bounds;

  LayoutMeasure copyWith({
    int? measureNumber,
    IList<LayoutElement>? elements,
    BoundingBox? bounds,
  }) =>
      LayoutMeasure(
        measureNumber: measureNumber ?? this.measureNumber,
        elements: elements ?? this.elements,
        bounds: bounds ?? this.bounds,
      );

  Map<String, Object?> toJson() => {
        'measureNumber': measureNumber,
        'bounds': bounds.toJson(),
        'elements': elements.map(_elementToJson).toList(),
      };
}

Map<String, Object?> _elementToJson(LayoutElement el) {
  final base = <String, Object?>{
    'type': el.runtimeType.toString(),
    'id': el.id,
    'isManualOverride': el.isManualOverride,
    'bounds': el.bounds.toJson(),
  };
  switch (el) {
    case NoteheadElement():
      base['noteId'] = el.noteId;
      base['midiPitch'] = el.midiPitch;
      base['staffLine'] = el.staffLine;
    case RestElement():
      base['restId'] = el.restId;
      base['staffLine'] = el.staffLine;
    case StemElement():
      base['noteId'] = el.noteId;
      base['direction'] = el.direction.name;
    case AccidentalElement():
      base['noteId'] = el.noteId;
      base['accidentalType'] = el.accidentalType.name;
    case BarlineElement():
      base['measureNumber'] = el.measureNumber;
      base['barlineType'] = el.barlineType;
    case ClefElement():
      base['clefType'] = el.clefType;
    case TimeSignatureElement():
      base['beats'] = el.beats;
      base['beatType'] = el.beatType;
    case KeySignatureElement():
      base['fifths'] = el.fifths;
    case DynamicElement():
      base['dynamicType'] = el.dynamicType;
      base['placement'] = el.placement;
    case LyricElement():
      base['text'] = el.text;
      base['syllabic'] = el.syllabic;
      base['lineNumber'] = el.lineNumber;
    case ArticulationElement():
      base['articulationType'] = el.articulationType;
      base['placement'] = el.placement;
  }
  return base;
}

/// All layout elements belonging to one staff across all measures.
final class LayoutStaff {
  const LayoutStaff({
    required this.staffId,
    required this.measures,
    required this.bounds,
  });

  final String staffId;
  final IList<LayoutMeasure> measures;
  final BoundingBox bounds;

  LayoutStaff copyWith({
    String? staffId,
    IList<LayoutMeasure>? measures,
    BoundingBox? bounds,
  }) =>
      LayoutStaff(
        staffId: staffId ?? this.staffId,
        measures: measures ?? this.measures,
        bounds: bounds ?? this.bounds,
      );

  Map<String, Object?> toJson() => {
        'staffId': staffId,
        'bounds': bounds.toJson(),
        'measures': measures.map((m) => m.toJson()).toList(),
      };
}

/// All layout elements belonging to one part across all staves.
final class LayoutPart {
  const LayoutPart({
    required this.partId,
    required this.staves,
    required this.bounds,
  });

  final String partId;
  final IList<LayoutStaff> staves;
  final BoundingBox bounds;

  LayoutPart copyWith({
    String? partId,
    IList<LayoutStaff>? staves,
    BoundingBox? bounds,
  }) =>
      LayoutPart(
        partId: partId ?? this.partId,
        staves: staves ?? this.staves,
        bounds: bounds ?? this.bounds,
      );

  Map<String, Object?> toJson() => {
        'partId': partId,
        'bounds': bounds.toJson(),
        'staves': staves.map((s) => s.toJson()).toList(),
      };
}

/// The complete layout of a score: hierarchy of parts → staves → measures → elements.
final class LayoutTree {
  const LayoutTree({
    required this.parts,
    required this.bounds,
  });

  final IList<LayoutPart> parts;
  final BoundingBox bounds;

  LayoutTree copyWith({
    IList<LayoutPart>? parts,
    BoundingBox? bounds,
  }) =>
      LayoutTree(
        parts: parts ?? this.parts,
        bounds: bounds ?? this.bounds,
      );

  /// Returns the [LayoutMeasure] for the given address, or null if not found.
  LayoutMeasure? findMeasure(
    String partId,
    String staffId,
    int measureNumber,
  ) {
    for (final part in parts) {
      if (part.partId != partId) continue;
      for (final staff in part.staves) {
        if (staff.staffId != staffId) continue;
        for (final measure in staff.measures) {
          if (measure.measureNumber == measureNumber) return measure;
        }
      }
    }
    return null;
  }

  /// Lazily yields every [LayoutElement] across all parts, staves, and measures.
  Iterable<LayoutElement> allElements() sync* {
    for (final part in parts) {
      for (final staff in part.staves) {
        for (final measure in staff.measures) {
          yield* measure.elements;
        }
      }
    }
  }

  /// Serialises the tree to a JSON-compatible map (for golden tests).
  Map<String, Object?> toJson() => {
        'parts': parts.map((p) => p.toJson()).toList(),
        'bounds': bounds.toJson(),
      };
}
