import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import '../ids.dart';
import 'measure_header.dart';
import 'part.dart';
import 'voice.dart';
import 'voice_context.dart';

/// The root aggregate of a music score.
final class Score {
  const Score({
    required this.id,
    this.title = '',
    this.composer = '',
    this.parts = const IListConst([]),
    this.measureHeaders = const IListConst([]),
  });

  final ScoreId id;
  final String title;
  final String composer;
  final IList<Part> parts;

  /// Shared measure metadata (time/key signatures, tempo, barlines).
  final IList<MeasureHeader> measureHeaders;

  /// Returns the [MeasureHeader] for the given 1-based measure number, or null.
  MeasureHeader? headerForMeasure(int measureNumber) {
    for (final h in measureHeaders) {
      if (h.measureNumber == measureNumber) return h;
    }
    return null;
  }

  /// Returns the [MeasureHeader] whose [MeasureHeader.measureNumber] is the
  /// largest value ≤ [measureNumber], or null if no such header exists.
  MeasureHeader? effectiveHeaderForMeasure(int measureNumber) {
    MeasureHeader? result;
    for (final h in measureHeaders) {
      if (h.measureNumber <= measureNumber) {
        if (result == null || h.measureNumber > result.measureNumber) {
          result = h;
        }
      }
    }
    return result;
  }

  /// Lazily yields every [VoiceContext] in the score, in part → staff →
  /// measure → voice order. Callers need no knowledge of the hierarchy shape.
  Iterable<VoiceContext> get allVoices sync* {
    for (final part in parts) {
      for (final staff in part.staves) {
        for (final measureEntry in staff.measures.entries) {
          for (final voiceEntry in measureEntry.value.voices.entries) {
            yield VoiceContext(
              partId: part.id,
              staffId: staff.id,
              measureNumber: measureEntry.key,
              voiceId: voiceEntry.key,
              voice: voiceEntry.value,
            );
          }
        }
      }
    }
  }

  /// Returns the [Part] with the given [id], or null if not found.
  Part? findPart(PartId id) {
    final index = parts.indexWhere((p) => p.id == id);
    return index < 0 ? null : parts[index];
  }

  /// Returns the [Voice] at the given address, or null if any step is missing.
  Voice? findVoice(
          PartId partId, StaffId staffId, int measureNumber, VoiceId voiceId) =>
      findPart(partId)?.findStaff(staffId)?.findVoice(measureNumber, voiceId);

  /// Returns a new [Score] with the part identified by [id] transformed by
  /// [updater], or null if no part with that ID exists or [updater] returns null.
  Score? updatePart(PartId id, Part? Function(Part) updater) {
    final index = parts.indexWhere((p) => p.id == id);
    if (index < 0) return null;
    final updated = updater(parts[index]);
    if (updated == null) return null;
    return copyWith(parts: parts.replace(index, updated));
  }

  Score copyWith({
    ScoreId? id,
    String? title,
    String? composer,
    IList<Part>? parts,
    IList<MeasureHeader>? measureHeaders,
  }) =>
      Score(
        id: id ?? this.id,
        title: title ?? this.title,
        composer: composer ?? this.composer,
        parts: parts ?? this.parts,
        measureHeaders: measureHeaders ?? this.measureHeaders,
      );
}
