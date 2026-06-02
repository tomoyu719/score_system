import '../bounding_box.dart';
import '../layout_element.dart';

/// Applies a manual position override to a layout element.
final class ManualOverride {
  const ManualOverride();

  /// Returns a copy of [element] with [isManualOverride] set to true and
  /// [bounds] replaced by [newBounds].
  LayoutElement apply(LayoutElement element, BoundingBox newBounds) {
    final updated = element.withBounds(newBounds);
    // withBounds preserves the subtype; now rebuild with isManualOverride=true.
    return switch (updated) {
      NoteheadElement() => NoteheadElement(
          id: updated.id,
          bounds: newBounds,
          isManualOverride: true,
          noteId: updated.noteId,
          midiPitch: updated.midiPitch,
          staffLine: updated.staffLine,
        ),
      RestElement() => RestElement(
          id: updated.id,
          bounds: newBounds,
          isManualOverride: true,
          restId: updated.restId,
          staffLine: updated.staffLine,
        ),
      StemElement() => StemElement(
          id: updated.id,
          bounds: newBounds,
          isManualOverride: true,
          noteId: updated.noteId,
          direction: updated.direction,
        ),
      AccidentalElement() => AccidentalElement(
          id: updated.id,
          bounds: newBounds,
          isManualOverride: true,
          noteId: updated.noteId,
          accidentalType: updated.accidentalType,
        ),
      BarlineElement() => BarlineElement(
          id: updated.id,
          bounds: newBounds,
          isManualOverride: true,
          measureNumber: updated.measureNumber,
          barlineType: updated.barlineType,
        ),
      ClefElement() => ClefElement(
          id: updated.id,
          bounds: newBounds,
          isManualOverride: true,
          clefType: updated.clefType,
        ),
      TimeSignatureElement() => TimeSignatureElement(
          id: updated.id,
          bounds: newBounds,
          isManualOverride: true,
          beats: updated.beats,
          beatType: updated.beatType,
        ),
      KeySignatureElement() => KeySignatureElement(
          id: updated.id,
          bounds: newBounds,
          isManualOverride: true,
          fifths: updated.fifths,
        ),
      DynamicElement() => DynamicElement(
          id: updated.id,
          bounds: newBounds,
          isManualOverride: true,
          dynamicType: updated.dynamicType,
          placement: updated.placement,
        ),
      LyricElement() => LyricElement(
          id: updated.id,
          bounds: newBounds,
          isManualOverride: true,
          text: updated.text,
          syllabic: updated.syllabic,
          lineNumber: updated.lineNumber,
        ),
      ArticulationElement() => ArticulationElement(
          id: updated.id,
          bounds: newBounds,
          isManualOverride: true,
          articulationType: updated.articulationType,
          placement: updated.placement,
        ),
    };
  }
}
