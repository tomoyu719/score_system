import 'bounding_box.dart';

/// Direction a stem points.
enum StemDirection { up, down }

/// Type of accidental mark.
enum AccidentalType { sharp, flat, natural, doubleSharp, doubleFlat }

/// Base class for every element placed on the layout canvas.
sealed class LayoutElement {
  const LayoutElement({
    required this.id,
    required this.bounds,
    this.isManualOverride = false,
  });

  final String id;
  final BoundingBox bounds;
  final bool isManualOverride;

  /// Returns a copy of this element with updated [bounds], preserving subtype.
  LayoutElement withBounds(BoundingBox bounds);
}

/// A rendered notehead.
final class NoteheadElement extends LayoutElement {
  const NoteheadElement({
    required super.id,
    required super.bounds,
    super.isManualOverride,
    required this.noteId,
    required this.midiPitch,
    required this.staffLine,
  });

  final String noteId;
  final int midiPitch;

  /// Position on staff: 0 = bottom line (E4 treble), each +1 = half space up.
  final double staffLine;

  @override
  NoteheadElement withBounds(BoundingBox bounds) => NoteheadElement(
        id: id,
        bounds: bounds,
        isManualOverride: isManualOverride,
        noteId: noteId,
        midiPitch: midiPitch,
        staffLine: staffLine,
      );
}

/// A rendered rest symbol.
final class RestElement extends LayoutElement {
  const RestElement({
    required super.id,
    required super.bounds,
    super.isManualOverride,
    required this.restId,
    required this.staffLine,
  });

  final String restId;
  final double staffLine;

  @override
  RestElement withBounds(BoundingBox bounds) => RestElement(
        id: id,
        bounds: bounds,
        isManualOverride: isManualOverride,
        restId: restId,
        staffLine: staffLine,
      );
}

/// A rendered stem line.
final class StemElement extends LayoutElement {
  const StemElement({
    required super.id,
    required super.bounds,
    super.isManualOverride,
    required this.noteId,
    required this.direction,
  });

  final String noteId;
  final StemDirection direction;

  @override
  StemElement withBounds(BoundingBox bounds) => StemElement(
        id: id,
        bounds: bounds,
        isManualOverride: isManualOverride,
        noteId: noteId,
        direction: direction,
      );
}

/// A rendered accidental sign.
final class AccidentalElement extends LayoutElement {
  const AccidentalElement({
    required super.id,
    required super.bounds,
    super.isManualOverride,
    required this.noteId,
    required this.accidentalType,
  });

  final String noteId;
  final AccidentalType accidentalType;

  @override
  AccidentalElement withBounds(BoundingBox bounds) => AccidentalElement(
        id: id,
        bounds: bounds,
        isManualOverride: isManualOverride,
        noteId: noteId,
        accidentalType: accidentalType,
      );
}

/// A rendered barline.
final class BarlineElement extends LayoutElement {
  const BarlineElement({
    required super.id,
    required super.bounds,
    super.isManualOverride,
    required this.measureNumber,
    required this.barlineType,
  });

  final int measureNumber;
  final String barlineType;

  @override
  BarlineElement withBounds(BoundingBox bounds) => BarlineElement(
        id: id,
        bounds: bounds,
        isManualOverride: isManualOverride,
        measureNumber: measureNumber,
        barlineType: barlineType,
      );
}

/// A rendered clef symbol.
final class ClefElement extends LayoutElement {
  const ClefElement({
    required super.id,
    required super.bounds,
    super.isManualOverride,
    required this.clefType,
  });

  /// "treble", "bass", or "alto".
  final String clefType;

  @override
  ClefElement withBounds(BoundingBox bounds) => ClefElement(
        id: id,
        bounds: bounds,
        isManualOverride: isManualOverride,
        clefType: clefType,
      );
}

/// A rendered time signature.
final class TimeSignatureElement extends LayoutElement {
  const TimeSignatureElement({
    required super.id,
    required super.bounds,
    super.isManualOverride,
    required this.beats,
    required this.beatType,
  });

  final int beats;
  final int beatType;

  @override
  TimeSignatureElement withBounds(BoundingBox bounds) => TimeSignatureElement(
        id: id,
        bounds: bounds,
        isManualOverride: isManualOverride,
        beats: beats,
        beatType: beatType,
      );
}

/// A rendered key signature.
final class KeySignatureElement extends LayoutElement {
  const KeySignatureElement({
    required super.id,
    required super.bounds,
    super.isManualOverride,
    required this.fifths,
  });

  final int fifths;

  @override
  KeySignatureElement withBounds(BoundingBox bounds) => KeySignatureElement(
        id: id,
        bounds: bounds,
        isManualOverride: isManualOverride,
        fifths: fifths,
      );
}

/// A rendered dynamic marking (p, f, mf, etc.).
final class DynamicElement extends LayoutElement {
  const DynamicElement({
    required super.id,
    required super.bounds,
    super.isManualOverride,
    required this.dynamicType,
    required this.placement,
  });

  final String dynamicType;

  /// "above" or "below".
  final String placement;

  @override
  DynamicElement withBounds(BoundingBox bounds) => DynamicElement(
        id: id,
        bounds: bounds,
        isManualOverride: isManualOverride,
        dynamicType: dynamicType,
        placement: placement,
      );
}

/// A rendered lyric syllable.
final class LyricElement extends LayoutElement {
  const LyricElement({
    required super.id,
    required super.bounds,
    super.isManualOverride,
    required this.text,
    required this.syllabic,
    required this.lineNumber,
  });

  final String text;
  final String syllabic;
  final int lineNumber;

  @override
  LyricElement withBounds(BoundingBox bounds) => LyricElement(
        id: id,
        bounds: bounds,
        isManualOverride: isManualOverride,
        text: text,
        syllabic: syllabic,
        lineNumber: lineNumber,
      );
}

/// A rendered articulation mark (staccato, accent, etc.).
final class ArticulationElement extends LayoutElement {
  const ArticulationElement({
    required super.id,
    required super.bounds,
    super.isManualOverride,
    required this.articulationType,
    required this.placement,
  });

  final String articulationType;
  final String placement;

  @override
  ArticulationElement withBounds(BoundingBox bounds) => ArticulationElement(
        id: id,
        bounds: bounds,
        isManualOverride: isManualOverride,
        articulationType: articulationType,
        placement: placement,
      );
}
