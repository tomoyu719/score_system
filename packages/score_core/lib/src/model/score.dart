import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';
import 'beam_group.dart';
import 'measure_header.dart';
import 'part.dart';
import 'slur.dart';
import 'tie.dart';
import 'tuplet.dart';

/// The root aggregate of a music score.
final class Score {
  const Score({
    required this.id,
    this.title = '',
    this.composer = '',
    this.parts = const IListConst([]),
    this.measureHeaders = const IListConst([]),
    this.beamGroups = const IListConst([]),
    this.slurs = const IListConst([]),
    this.ties = const IListConst([]),
    this.tuplets = const IListConst([]),
  });

  final ScoreId id;
  final String title;
  final String composer;
  final IList<Part> parts;

  /// Shared measure metadata (time/key signatures, tempo, barlines).
  final IList<MeasureHeader> measureHeaders;

  /// Beam groups referencing notes by ID.
  final IList<BeamGroup> beamGroups;

  /// Slurs referencing notes by ID.
  final IList<Slur> slurs;

  /// Ties referencing notes by ID.
  final IList<Tie> ties;

  /// Tuplet groups referencing notes by ID.
  final IList<Tuplet> tuplets;

  /// Returns the [MeasureHeader] for the given 1-based measure number, or null.
  MeasureHeader? headerForMeasure(int measureNumber) {
    for (final h in measureHeaders) {
      if (h.measureNumber == measureNumber) return h;
    }
    return null;
  }

  Score copyWith({
    ScoreId? id,
    String? title,
    String? composer,
    IList<Part>? parts,
    IList<MeasureHeader>? measureHeaders,
    IList<BeamGroup>? beamGroups,
    IList<Slur>? slurs,
    IList<Tie>? ties,
    IList<Tuplet>? tuplets,
  }) =>
      Score(
        id: id ?? this.id,
        title: title ?? this.title,
        composer: composer ?? this.composer,
        parts: parts ?? this.parts,
        measureHeaders: measureHeaders ?? this.measureHeaders,
        beamGroups: beamGroups ?? this.beamGroups,
        slurs: slurs ?? this.slurs,
        ties: ties ?? this.ties,
        tuplets: tuplets ?? this.tuplets,
      );
}
