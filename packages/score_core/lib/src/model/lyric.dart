/// Syllabic position within a word.
enum Syllabic { single, begin, middle, end }

/// A lyric syllable attached to a note.
final class Lyric {
  const Lyric({
    required this.text,
    this.syllabic = Syllabic.single,
    this.number = 1,
  });

  final String text;
  final Syllabic syllabic;

  /// Lyric line number (1-based, for multiple verses).
  final int number;

  Lyric copyWith({String? text, Syllabic? syllabic, int? number}) => Lyric(
        text: text ?? this.text,
        syllabic: syllabic ?? this.syllabic,
        number: number ?? this.number,
      );

  @override
  bool operator ==(Object other) {
    if (other is! Lyric) return false;
    return text == other.text &&
        syllabic == other.syllabic &&
        number == other.number;
  }

  @override
  int get hashCode => Object.hash(text, syllabic, number);
}
