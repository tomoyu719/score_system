import 'validation_error.dart';

/// The outcome of running [Validator.validate] on a [Score].
sealed class ValidationResult {
  const ValidationResult();

  /// Serialises this result to a JSON-compatible map.
  Map<String, Object?> toJson();
}

/// All rules passed.
final class ValidationSuccess extends ValidationResult {
  const ValidationSuccess();

  @override
  Map<String, Object?> toJson() => {'valid': true, 'errors': <Object?>[]};
}

/// One or more rules failed.
final class ValidationFailure extends ValidationResult {
  const ValidationFailure({required this.errors});

  final List<ValidationError> errors;

  @override
  Map<String, Object?> toJson() => {
        'valid': false,
        'errors': errors.map((e) => e.toJson()).toList(),
      };
}
