int _gcd(int a, int b) {
  while (b != 0) {
    final t = b;
    b = a % b;
    a = t;
  }
  return a;
}

/// Rational number for musical timing. Never use `double` for musical offsets.
///
/// Always stored in reduced form: `Fraction(6, 4)` stores as `(3, 2)`.
/// Denominator is always positive.
final class Fraction implements Comparable<Fraction> {
  factory Fraction(int numerator, int denominator) {
    assert(denominator != 0, 'Denominator must not be zero');
    if (numerator == 0) return const Fraction._raw(0, 1);
    final sign = denominator < 0 ? -1 : 1;
    final g = _gcd(numerator.abs(), denominator.abs());
    return Fraction._raw(sign * numerator ~/ g, denominator.abs() ~/ g);
  }

  const Fraction._raw(this.numerator, this.denominator);

  factory Fraction.fromString(String s) {
    final parts = s.split('/');
    if (parts.length == 1) return Fraction(int.parse(parts[0]), 1);
    return Fraction(int.parse(parts[0]), int.parse(parts[1]));
  }

  static const zero = Fraction._raw(0, 1);
  static const one = Fraction._raw(1, 1);

  final int numerator;
  final int denominator;

  bool get isZero => numerator == 0;
  bool get isNegative => numerator < 0;
  double toDouble() => numerator / denominator;

  Fraction operator +(Fraction other) => Fraction(
        numerator * other.denominator + other.numerator * denominator,
        denominator * other.denominator,
      );

  Fraction operator -(Fraction other) => Fraction(
        numerator * other.denominator - other.numerator * denominator,
        denominator * other.denominator,
      );

  Fraction operator *(Fraction other) =>
      Fraction(numerator * other.numerator, denominator * other.denominator);

  Fraction operator /(Fraction other) =>
      Fraction(numerator * other.denominator, denominator * other.numerator);

  Fraction operator -() => Fraction._raw(-numerator, denominator);

  bool operator >(Fraction other) =>
      numerator * other.denominator > other.numerator * denominator;

  bool operator <(Fraction other) =>
      numerator * other.denominator < other.numerator * denominator;

  bool operator >=(Fraction other) =>
      numerator * other.denominator >= other.numerator * denominator;

  bool operator <=(Fraction other) =>
      numerator * other.denominator <= other.numerator * denominator;

  @override
  int compareTo(Fraction other) {
    final lhs = numerator * other.denominator;
    final rhs = other.numerator * denominator;
    return lhs.compareTo(rhs);
  }

  @override
  bool operator ==(Object other) {
    if (other is! Fraction) return false;
    return numerator == other.numerator && denominator == other.denominator;
  }

  @override
  int get hashCode => Object.hash(numerator, denominator);

  @override
  String toString() => '$numerator/$denominator';
}
