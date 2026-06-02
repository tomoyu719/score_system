import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';

import 'bounding_box.dart';
import 'layout_element.dart';
import 'layout_tree.dart';
import 'spacing/measure_spacing_engine.dart';
import 'spacing/note_layout.dart';
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

  /// Computes the full [LayoutTree] for [score].
  LayoutTree layout(Score score) {
    if (score.parts.isEmpty) {
      return LayoutTree(
        parts: const IListConst([]),
        bounds: const BoundingBox(x: 0, y: 0, width: 0, height: 0),
      );
    }

    final layoutParts = <LayoutPart>[];

    for (final part in score.parts) {
      final layoutStaves = <LayoutStaff>[];
      var staffIndex = 0;

      for (final staff in part.staves) {
        final staffY = staffSpacing.yForStaff(staffIndex);
        final layoutMeasures = <LayoutMeasure>[];
        var measureX = 0.0;

        // Collect all measure numbers for this staff, sorted.
        final measureNumbers = staff.measures.keys.toList()..sort();

        for (final mNum in measureNumbers) {
          final measure = staff.measures[mNum]!;
          final header = score.headerForMeasure(mNum);
          final measureDuration =
              header?.measureDuration ?? Fraction(1, 1);

          // Use the widest voice to determine measure width.
          var mWidth = measureSpacing.minMeasureWidth;
          for (final voice in measure.voices.values) {
            final w = measureSpacing.measureWidth(voice, measureDuration);
            if (w > mWidth) mWidth = w;
          }

          final elements = <LayoutElement>[];

          for (final voice in measure.voices.values) {
            for (final event in voice.events) {
              _layoutEvent(
                event: event,
                measureX: measureX,
                staffY: staffY,
                measureWidth: mWidth,
                measureDuration: measureDuration,
                elements: elements,
              );
            }
          }

          final measureBounds = BoundingBox(
            x: measureX,
            y: staffY,
            width: mWidth,
            height: staffSpacing.staffHeight,
          );
          layoutMeasures.add(
            LayoutMeasure(
              measureNumber: mNum,
              elements: IList(elements),
              bounds: measureBounds,
            ),
          );
          measureX += mWidth;
        }

        final staffBounds = BoundingBox(
          x: 0,
          y: staffY,
          width: measureX,
          height: staffSpacing.staffHeight,
        );
        layoutStaves.add(
          LayoutStaff(
            staffId: staff.id.value,
            measures: IList(layoutMeasures),
            bounds: staffBounds,
          ),
        );
        staffIndex++;
      }

      final partBounds = layoutStaves.isEmpty
          ? const BoundingBox(x: 0, y: 0, width: 0, height: 0)
          : layoutStaves
              .map((s) => s.bounds)
              .reduce((a, b) => a.union(b));

      layoutParts.add(
        LayoutPart(
          partId: part.id.value,
          staves: IList(layoutStaves),
          bounds: partBounds,
        ),
      );
    }

    final treeBounds = layoutParts.isEmpty
        ? const BoundingBox(x: 0, y: 0, width: 0, height: 0)
        : layoutParts
            .map((p) => p.bounds)
            .reduce((a, b) => a.union(b));

    return LayoutTree(parts: IList(layoutParts), bounds: treeBounds);
  }

  /// Recomputes layout only for [measureNumber], preserving all other measures.
  LayoutTree relayout(
    LayoutTree existing,
    Score score,
    int measureNumber,
  ) {
    final updatedParts = existing.parts.map((layoutPart) {
      final scorePart = _findScorePart(score, layoutPart.partId);
      if (scorePart == null) return layoutPart;

      final updatedStaves = layoutPart.staves.map((layoutStaff) {
        final scoreStaff = _findScoreStaff(scorePart, layoutStaff.staffId);
        if (scoreStaff == null) return layoutStaff;

        final staffIndex = layoutPart.staves.indexWhere(
          (s) => s.staffId == layoutStaff.staffId,
        );
        final staffY = staffSpacing.yForStaff(staffIndex);

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

          final header = score.headerForMeasure(measureNumber);
          final measureDuration = header?.measureDuration ?? Fraction(1, 1);

          var mWidth = measureSpacing.minMeasureWidth;
          for (final voice in scoreMeasure.voices.values) {
            final w = measureSpacing.measureWidth(voice, measureDuration);
            if (w > mWidth) mWidth = w;
          }

          final elements = <LayoutElement>[];
          for (final voice in scoreMeasure.voices.values) {
            for (final event in voice.events) {
              _layoutEvent(
                event: event,
                measureX: currentX,
                staffY: staffY,
                measureWidth: mWidth,
                measureDuration: measureDuration,
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
        ? const BoundingBox(x: 0, y: 0, width: 0, height: 0)
        : updatedParts
            .map((p) => p.bounds)
            .reduce((a, b) => a.union(b));

    return existing.copyWith(
      parts: IList(updatedParts),
      bounds: treeBounds,
    );
  }

  void _layoutEvent({
    required MusicEvent event,
    required double measureX,
    required double staffY,
    required double measureWidth,
    required Fraction measureDuration,
    required List<LayoutElement> elements,
  }) {
    switch (event) {
      case NoteEvent():
        _layoutNoteEvent(
          note: event,
          measureX: measureX,
          staffY: staffY,
          measureWidth: measureWidth,
          measureDuration: measureDuration,
          elements: elements,
        );
      case RestEvent():
        _layoutRestEvent(
          rest: event,
          measureX: measureX,
          staffY: staffY,
          measureWidth: measureWidth,
          measureDuration: measureDuration,
          elements: elements,
        );
      case ChordEvent():
        for (final note in event.notes) {
          _layoutNoteEvent(
            note: note.copyWith(offset: event.offset),
            measureX: measureX,
            staffY: staffY,
            measureWidth: measureWidth,
            measureDuration: measureDuration,
            elements: elements,
          );
        }
    }
  }

  void _layoutNoteEvent({
    required NoteEvent note,
    required double measureX,
    required double staffY,
    required double measureWidth,
    required Fraction measureDuration,
    required List<LayoutElement> elements,
  }) {
    final x =
        measureX +
        noteLayout.xForOffset(note.offset, measureDuration, measureWidth);
    final sl = noteLayout.staffLineForPitch(note.pitch);
    final noteId = note.id.value;

    elements.add(
      NoteheadElement(
        id: 'notehead-$noteId',
        bounds: BoundingBox(x: x, y: staffY, width: 1.0, height: 1.0),
        noteId: noteId,
        midiPitch: note.pitch.midiPitch,
        staffLine: sl,
      ),
    );

    // Whole notes have no stem.
    if (note.noteValue.noteType != NoteType.whole) {
      final direction = stemPolicy.stemDirection(sl);
      elements.add(
        StemElement(
          id: 'stem-$noteId',
          bounds: BoundingBox(x: x, y: staffY, width: 0.1, height: 3.5),
          noteId: noteId,
          direction: direction,
        ),
      );
    }

    // Accidental for non-zero alter.
    if (note.pitch.alter != 0.0) {
      final accType = _accidentalType(note.pitch.alter);
      if (accType != null) {
        elements.add(
          AccidentalElement(
            id: 'acc-$noteId',
            bounds: BoundingBox(x: x - 1.0, y: staffY, width: 0.8, height: 1.0),
            noteId: noteId,
            accidentalType: accType,
          ),
        );
      }
    }
  }

  void _layoutRestEvent({
    required RestEvent rest,
    required double measureX,
    required double staffY,
    required double measureWidth,
    required Fraction measureDuration,
    required List<LayoutElement> elements,
  }) {
    final x =
        measureX +
        noteLayout.xForOffset(rest.offset, measureDuration, measureWidth);
    final sl = restPositioning.staffLineForRest(rest.noteValue.noteType);
    final restId = rest.id.value;

    elements.add(
      RestElement(
        id: 'rest-$restId',
        bounds: BoundingBox(x: x, y: staffY, width: 1.0, height: 1.0),
        restId: restId,
        staffLine: sl,
      ),
    );
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
