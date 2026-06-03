import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';

import 'bounding_box.dart';
import 'layout_element.dart';
import 'layout_tree.dart';
import 'spacing/measure_spacing_engine.dart';
import 'spacing/note_layout.dart';
import 'spacing/staff_extents.dart';
import 'spacing/staff_spacing_engine.dart';
import 'voice/rest_positioning.dart';
import 'voice/stem_direction.dart';

/// Top-level entry point: computes a [LayoutTree] from a [Score].
final class LayoutEngine {
  const LayoutEngine({
    this.measureSpacing = const MeasureSpacingEngine(),
    this.staffSpacing = const StaffSpacingEngine(),
    this.noteLayout = const NoteLayout(),
    this.stemPolicy = const StemDirectionPolicy(),
    this.restPositioning = const RestPositioning(),
  });

  final MeasureSpacingEngine measureSpacing;
  final StaffSpacingEngine staffSpacing;
  final NoteLayout noteLayout;
  final StemDirectionPolicy stemPolicy;
  final RestPositioning restPositioning;

  static const _emptyBounds = BoundingBox(x: 0, y: 0, width: 0, height: 0);

  /// Computes the full [LayoutTree] for [score] using two-pass staff spacing.
  ///
  /// Pass 1 uses provisional uniform spacing; measured content extents then
  /// drive content-aware Y positions for the final pass.
  LayoutTree layout(Score score) {
    if (score.isEmpty) {
      return LayoutTree(parts: const IListConst([]), bounds: _emptyBounds);
    }

    // Collect all (part, staff) pairs in document order for a stable global index.
    final ordered = _orderedStaves(score);

    // Pass 1: provisional uniform spacing.
    final provisionalY = List.generate(ordered.length, (i) => staffSpacing.yForStaff(i));
    final pass1 = _buildLayoutParts(score, ordered, provisionalY);

    // Measure how far elements extend beyond each staff's lines.
    final extents = _extractExtents(pass1, ordered, provisionalY);

    // Pass 2: content-aware spacing derived from actual extents.
    final finalY = staffSpacing.yPositionsForExtents(extents);
    final finalParts = _buildLayoutParts(score, ordered, finalY);

    final treeBounds = finalParts.isEmpty
        ? _emptyBounds
        : finalParts.map((p) => p.bounds).reduce((a, b) => a.union(b));

    return LayoutTree(parts: IList(finalParts), bounds: treeBounds);
  }

  /// Recomputes layout only for [measureNumber], preserving all other measures.
  LayoutTree relayout(LayoutTree existing, Score score, int measureNumber) {
    final updatedParts = existing.parts.map((layoutPart) {
      final scorePart = _findScorePart(score, layoutPart.partId);
      if (scorePart == null) return layoutPart;

      final updatedStaves = layoutPart.staves.map((layoutStaff) {
        final scoreStaff = _findScoreStaff(scorePart, layoutStaff.staffId);
        if (scoreStaff == null) return layoutStaff;

        // Preserve existing staff Y rather than recomputing.
        final staffY = layoutStaff.bounds.y;

        var measureX = 0.0;
        final updatedMeasures = layoutStaff.measures.map((lm) {
          final currentX = measureX;
          if (lm.measureNumber != measureNumber) {
            measureX += lm.bounds.width;
            return lm;
          }

          final scoreMeasure = scoreStaff.measures[measureNumber];
          if (scoreMeasure == null) {
            measureX += lm.bounds.width;
            return lm;
          }

          var mWidth = measureSpacing.minMeasureWidth;
          for (final voice in scoreMeasure.allVoices) {
            final w = measureSpacing.measureWidth(voice);
            if (w > mWidth) mWidth = w;
          }

          final offsetX = measureSpacing.xPositions(scoreMeasure.allVoices);
          final elements = <LayoutElement>[];
          for (final voice in scoreMeasure.allVoices) {
            for (final event in voice.events) {
              _layoutEvent(
                event: event,
                measureX: currentX,
                staffY: staffY,
                offsetX: offsetX,
                elements: elements,
              );
            }
          }

          measureX += mWidth;
          return LayoutMeasure(
            measureNumber: measureNumber,
            elements: IList(elements),
            bounds: BoundingBox(
              x: currentX,
              y: staffY,
              width: mWidth,
              height: staffSpacing.staffHeight,
            ),
          );
        }).toList();

        return layoutStaff.copyWith(measures: IList(updatedMeasures));
      }).toList();

      return layoutPart.copyWith(staves: IList(updatedStaves));
    }).toList();

    final treeBounds = updatedParts.isEmpty
        ? _emptyBounds
        : updatedParts.map((p) => p.bounds).reduce((a, b) => a.union(b));

    return existing.copyWith(parts: IList(updatedParts), bounds: treeBounds);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  List<(Part, Staff)> _orderedStaves(Score score) => [
        for (final part in score.parts)
          for (final staff in part.staves) (part, staff),
      ];

  List<LayoutPart> _buildLayoutParts(
    Score score,
    List<(Part, Staff)> ordered,
    List<double> staffYList,
  ) {
    // Build (partId, staffId) → staffY lookup from the global ordered list.
    final staffYMap = <(String, String), double>{};
    for (var i = 0; i < ordered.length; i++) {
      final (part, staff) = ordered[i];
      staffYMap[(part.id.value, staff.id.value)] = staffYList[i];
    }

    final layoutParts = <LayoutPart>[];
    for (final part in score.parts) {
      final layoutStaves = <LayoutStaff>[];

      for (final staff in part.staves) {
        final staffY = staffYMap[(part.id.value, staff.id.value)]!;
        final layoutMeasures = <LayoutMeasure>[];
        var measureX = 0.0;

        final measureNumbers = staff.measures.keys.toList()..sort();
        for (final mNum in measureNumbers) {
          final measure = staff.measures[mNum]!;

          var mWidth = measureSpacing.minMeasureWidth;
          for (final voice in measure.allVoices) {
            final w = measureSpacing.measureWidth(voice);
            if (w > mWidth) mWidth = w;
          }

          final offsetX = measureSpacing.xPositions(measure.allVoices);
          final elements = <LayoutElement>[];
          for (final voice in measure.allVoices) {
            for (final event in voice.events) {
              _layoutEvent(
                event: event,
                measureX: measureX,
                staffY: staffY,
                offsetX: offsetX,
                elements: elements,
              );
            }
          }

          layoutMeasures.add(LayoutMeasure(
            measureNumber: mNum,
            elements: IList(elements),
            bounds: BoundingBox(
              x: measureX,
              y: staffY,
              width: mWidth,
              height: staffSpacing.staffHeight,
            ),
          ));
          measureX += mWidth;
        }

        final staffBounds = layoutMeasures.isEmpty
            ? BoundingBox(x: 0, y: staffY, width: 0, height: staffSpacing.staffHeight)
            : layoutMeasures.map((m) => m.bounds).reduce((a, b) => a.union(b));
        layoutStaves.add(LayoutStaff(
          staffId: staff.id.value,
          measures: IList(layoutMeasures),
          bounds: staffBounds,
        ));
      }

      final partBounds = layoutStaves.isEmpty
          ? _emptyBounds
          : layoutStaves.map((s) => s.bounds).reduce((a, b) => a.union(b));
      layoutParts.add(LayoutPart(
        partId: part.id.value,
        staves: IList(layoutStaves),
        bounds: partBounds,
      ));
    }
    return layoutParts;
  }

  /// Measures how far each staff's elements extend beyond its staff lines.
  List<StaffExtents> _extractExtents(
    List<LayoutPart> parts,
    List<(Part, Staff)> ordered,
    List<double> staffYList,
  ) {
    // Build (partId, staffId) → LayoutStaff lookup.
    final staffMap = <(String, String), LayoutStaff>{};
    for (final part in parts) {
      for (final staff in part.staves) {
        staffMap[(part.partId, staff.staffId)] = staff;
      }
    }

    return [
      for (var i = 0; i < ordered.length; i++)
        () {
          final (part, staff) = ordered[i];
          final staffY = staffYList[i];
          final staffBottom = staffY + staffSpacing.staffHeight;
          final layoutStaff = staffMap[(part.id.value, staff.id.value)];
          if (layoutStaff == null) return const StaffExtents();

          var minY = staffY;
          var maxY = staffBottom;
          for (final measure in layoutStaff.measures) {
            for (final el in measure.elements) {
              if (el.bounds.y < minY) minY = el.bounds.y;
              final bottom = el.bounds.y + el.bounds.height;
              if (bottom > maxY) maxY = bottom;
            }
          }
          return StaffExtents(
            aboveExtra: (staffY - minY).clamp(0.0, double.infinity),
            belowExtra: (maxY - staffBottom).clamp(0.0, double.infinity),
          );
        }(),
    ];
  }

  void _layoutEvent({
    required MusicEvent event,
    required double measureX,
    required double staffY,
    required Map<Fraction, double> offsetX,
    required List<LayoutElement> elements,
  }) {
    switch (event) {
      case NoteEvent():
        _layoutNoteEvent(
          note: event,
          measureX: measureX,
          staffY: staffY,
          offsetX: offsetX,
          elements: elements,
        );
      case RestEvent():
        _layoutRestEvent(
          rest: event,
          measureX: measureX,
          staffY: staffY,
          offsetX: offsetX,
          elements: elements,
        );
      case ChordEvent():
        for (final note in event.notes) {
          _layoutNoteEvent(
            note: note.copyWith(offset: event.offset),
            measureX: measureX,
            staffY: staffY,
            offsetX: offsetX,
            elements: elements,
          );
        }
    }
  }

  void _layoutNoteEvent({
    required NoteEvent note,
    required double measureX,
    required double staffY,
    required Map<Fraction, double> offsetX,
    required List<LayoutElement> elements,
  }) {
    final x = measureX + (offsetX[note.offset] ?? 0.0);
    final sl = noteLayout.staffLineForPitch(note.pitch);
    final noteId = note.id.value;

    elements.add(NoteheadElement(
      id: 'notehead-$noteId',
      bounds: BoundingBox(x: x, y: staffY, width: 1.0, height: 1.0),
      noteId: noteId,
      midiPitch: note.pitch.midiPitch,
      staffLine: sl,
    ));

    if (note.noteValue.noteType != NoteType.whole) {
      final direction = stemPolicy.stemDirection(sl);
      elements.add(StemElement(
        id: 'stem-$noteId',
        bounds: BoundingBox(x: x, y: staffY, width: 0.1, height: 3.5),
        noteId: noteId,
        direction: direction,
      ));
    }

    if (note.pitch.alter != 0.0) {
      final accType = _accidentalType(note.pitch.alter);
      if (accType != null) {
        elements.add(AccidentalElement(
          id: 'acc-$noteId',
          bounds: BoundingBox(x: x - 1.0, y: staffY, width: 0.8, height: 1.0),
          noteId: noteId,
          accidentalType: accType,
        ));
      }
    }
  }

  void _layoutRestEvent({
    required RestEvent rest,
    required double measureX,
    required double staffY,
    required Map<Fraction, double> offsetX,
    required List<LayoutElement> elements,
  }) {
    final x = measureX + (offsetX[rest.offset] ?? 0.0);
    final sl = restPositioning.staffLineForRest(rest.noteValue.noteType);
    final restId = rest.id.value;

    elements.add(RestElement(
      id: 'rest-$restId',
      bounds: BoundingBox(x: x, y: staffY, width: 1.0, height: 1.0),
      restId: restId,
      staffLine: sl,
    ));
  }

  AccidentalType? _accidentalType(double alter) => switch (alter) {
        1.0 => AccidentalType.sharp,
        -1.0 => AccidentalType.flat,
        0.0 => null,
        2.0 => AccidentalType.doubleSharp,
        -2.0 => AccidentalType.doubleFlat,
        _ => AccidentalType.natural,
      };

  Part? _findScorePart(Score score, String partId) {
    for (final p in score.parts) {
      if (p.id.value == partId) return p;
    }
    return null;
  }

  Staff? _findScoreStaff(Part part, String staffId) {
    for (final s in part.staves) {
      if (s.id.value == staffId) return s;
    }
    return null;
  }
}
