/// Thrown for internal bugs in score_core. Never thrown for user errors.
final class ScoreException implements Exception {
  const ScoreException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => cause == null
      ? 'ScoreException: $message'
      : 'ScoreException: $message (caused by: $cause)';
}
