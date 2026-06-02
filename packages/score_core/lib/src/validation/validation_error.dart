/// A single validation problem found in a [Score].
final class ValidationError {
  const ValidationError({
    required this.code,
    required this.message,
    this.partId,
    this.staffId,
    this.measureNumber,
    this.voiceId,
  });

  /// Machine-readable error code (e.g. `'VOICE_OVERFLOW'`).
  final String code;

  /// Human-readable description of the problem.
  final String message;

  final String? partId;
  final String? staffId;
  final int? measureNumber;
  final String? voiceId;

  Map<String, Object?> toJson() => {
        'code': code,
        'message': message,
        if (partId != null) 'partId': partId,
        if (staffId != null) 'staffId': staffId,
        if (measureNumber != null) 'measureNumber': measureNumber,
        if (voiceId != null) 'voiceId': voiceId,
      };
}
