part of 'layout_element.dart';

/// Layout data for a rest event.
final class RestLayout extends LayoutElement {
  const RestLayout({
    required this.restId,
    required this.offset,
    required this.staffLine,
  });

  final RestId restId;
  final Fraction offset;

  /// Vertical staff-line position for this rest.
  final int staffLine;

  Map<String, Object?> toJson() => {
        'restId': restId.value,
        'offset': offset.toString(),
        'staffLine': staffLine,
      };

  static RestLayout fromJson(Map<String, Object?> map) => RestLayout(
        restId: RestId(map['restId'] as String),
        offset: Fraction.fromString(map['offset'] as String),
        staffLine: map['staffLine'] as int,
      );

  @override
  bool operator ==(Object other) {
    if (other is! RestLayout) return false;
    return restId == other.restId &&
        offset == other.offset &&
        staffLine == other.staffLine;
  }

  @override
  int get hashCode => Object.hash(restId, offset, staffLine);
}
