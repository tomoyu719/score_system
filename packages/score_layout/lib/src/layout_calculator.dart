import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:score_core/score_core.dart';

import 'engine/clef_staff_line_mapper.dart';
import 'engine/measure_spacing_engine.dart';
import 'engine/rest_positioning_calculator.dart';
import 'engine/shared_notehead_detector.dart';
import 'engine/staff_spacing_engine.dart';
import 'engine/stem_direction_calculator.dart';
import 'layout_tree.dart';
import 'model/layout_element.dart'; // BeamLayout, NoteLayout, etc. via parts
import 'model/measure_layout.dart';
import 'model/system_layout.dart';
import 'model/voice_layout.dart';

/// Produces a [LayoutTree] from a [Score].
///
/// All computation is deterministic and pure — the same [Score] always
/// produces the same [LayoutTree].
final class LayoutCalculator {
  LayoutCalculator({
    ClefStaffLineMapper? mapper,
    StemDirectionCalculator? stemCalc,
    RestPositioningCalculator? restCalc,
    SharedNoteheadDetector? sharedDetector,
    MeasureSpacingEngine? spacingEngine,
    StaffSpacingEngine? staffEngine,
  })  : _mapper = mapper ?? const ClefStaffLineMapper(),
        _stemCalc = stemCalc ?? const StemDirectionCalculator(),
        _restCalc = restCalc ?? const RestPositioningCalculator(),
        _sharedDetector = sharedDetector ?? const SharedNoteheadDetector(),
        _spacingEngine = spacingEngine ?? const MeasureSpacingEngine(),
        _staffEngine = staffEngine ?? const StaffSpacingEngine();

  final ClefStaffLineMapper _mapper;
  final StemDirectionCalculator _stemCalc;
  final RestPositioningCalculator _restCalc;
  final SharedNoteheadDetector _sharedDetector;
  final MeasureSpacingEngine _spacingEngine;
  final StaffSpacingEngine _staffEngine;

  /// Calculates the full [LayoutTree] for [score].
  LayoutTree calculate(Score score) {
    final spacings = {
      for (final e in _spacingEngine.calculate(score))
        e.measureNumber: e.relativeWidth,
    };
    final staffLayouts = IList(_staffEngine.calculate(score));

    // Collect all measure numbers from headers
    final measureNumbers =
        score.measureHeaders.map((h) => h.measureNumber).toList()..sort();

    final measureLayouts = <MeasureLayout>[];

    for (final measureNumber in measureNumbers) {
      final relativeWidth = spacings[measureNumber] ?? 1.0;
      final voiceLayouts = <VoiceLayout>[];

      for (final part in score.parts) {
        for (final staff in part.staves) {
          final measure = staff.measures[measureNumber];
          if (measure == null) continue;

          final voiceCount = measure.voices.length;
          final voiceEntries = measure.voices.entries.toList();

          for (final voiceEntry in voiceEntries) {
            final voice = voiceEntry.value;
            final stemDir = _stemCalc.resolve(voice, voiceCount);

            // Build NoteLayouts
            var noteLayouts = IList(<NoteLayout>[]);
            var stemLayouts = IList(<StemLayout>[]);
            var accumulatedArticulations = IList(<ArticulationLayout>[]);

            for (final event in voice.events) {
              switch (event) {
                case NoteEvent():
                  final staffLine = _mapper.map(
                      event.pitch,
                      staff.effectiveClefAt(measureNumber, event.offset));
                  final accidentalType =
                      ClefStaffLineMapper.accidentalType(event.pitch.alter);
                  final accidentals = accidentalType != null
                      ? IList([
                          AccidentalLayout(
                            noteId: event.id,
                            type: accidentalType,
                          ),
                        ])
                      : const IListConst<AccidentalLayout>([]);
                  final articulationLayouts = IList(
                    event.articulations.map(
                      (a) => ArticulationLayout(
                        noteId: event.id,
                        articulationType: a.type.name,
                      ),
                    ),
                  );
                  noteLayouts = noteLayouts.add(NoteLayout(
                    noteId: event.id,
                    offset: event.offset,
                    staffLine: staffLine,
                    stemDirection: stemDir,
                    accidentals: accidentals,
                    articulations: articulationLayouts,
                  ));
                  stemLayouts = stemLayouts
                      .add(StemLayout(noteId: event.id, direction: stemDir));
                  accumulatedArticulations =
                      accumulatedArticulations.addAll(articulationLayouts);

                case ChordEvent():
                  for (final note in event.notes) {
                    final staffLine = _mapper.map(
                        note.pitch,
                        staff.effectiveClefAt(measureNumber, event.offset));
                    final accidentalType =
                        ClefStaffLineMapper.accidentalType(note.pitch.alter);
                    final accidentals = accidentalType != null
                        ? IList([
                            AccidentalLayout(
                              noteId: note.id,
                              type: accidentalType,
                            ),
                          ])
                        : const IListConst<AccidentalLayout>([]);
                    noteLayouts = noteLayouts.add(NoteLayout(
                      noteId: note.id,
                      offset: event.offset,
                      staffLine: staffLine,
                      stemDirection: stemDir,
                      accidentals: accidentals,
                    ));
                    stemLayouts = stemLayouts
                        .add(StemLayout(noteId: note.id, direction: stemDir));
                  }

                case RestEvent():
                  break; // handled below

                case PercussionNote():
                  break; // handled below
              }
            }

            // Build RestLayouts
            var restLayouts = IList(<RestLayout>[]);
            for (final event in voice.events) {
              if (event is RestEvent) {
                final staffLine = _restCalc.resolve(voice, voiceCount);
                restLayouts = restLayouts.add(RestLayout(
                  restId: event.id,
                  offset: event.offset,
                  staffLine: staffLine,
                ));
              }
            }

            // Build PercussionNoteLayouts
            var percussionLayouts = IList(<PercussionNoteLayout>[]);
            for (final event in voice.events) {
              if (event is PercussionNote) {
                percussionLayouts = percussionLayouts.add(PercussionNoteLayout(
                  percussionNoteId: event.id,
                  offset: event.offset,
                  staffLine: event.instrument.staffLine,
                  stemDirection: stemDir,
                ));
              }
            }

            // Build BeamLayouts: include beams whose notes are all in this voice
            final voiceNoteIds =
                noteLayouts.map((n) => n.noteId).toSet();
            var beamLayouts = IList(<BeamLayout>[]);
            for (final bg in part.beamGroups) {
              if (bg.noteIds.every(voiceNoteIds.contains)) {
                beamLayouts = beamLayouts.add(
                  BeamLayout(beamGroupId: bg.id, noteIds: bg.noteIds),
                );
              }
            }

            voiceLayouts.add(VoiceLayout(
              voiceId: voice.id,
              notes: noteLayouts,
              percussionNotes: percussionLayouts,
              rests: restLayouts,
              beams: beamLayouts,
              stems: stemLayouts,
            ));
          }
        }
      }

      // Apply shared notehead detection
      final sharedIds = _sharedDetector.detect(IList(voiceLayouts));
      final updatedVoices = IList(
        voiceLayouts.map((vl) => vl.copyWith(
          notes: IList(
            vl.notes.map((n) => sharedIds.contains(n.noteId)
                ? n.copyWith(isSharedNotehead: true)
                : n),
          ),
        )),
      );

      measureLayouts.add(MeasureLayout(
        measureNumber: measureNumber,
        relativeWidth: relativeWidth,
        voices: updatedVoices,
      ));
    }

    if (measureLayouts.isEmpty) return const LayoutTree();

    final system = SystemLayout(
      staves: staffLayouts,
      measures: IList(measureLayouts),
    );
    return LayoutTree(systems: IList([system]));
  }
}
