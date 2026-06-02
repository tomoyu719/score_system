/// Axis-aligned bounding box in Staff Space (sp) units.
final class BoundingBox {
  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  double get right => x + width;
  double get bottom => y + height;

  /// Returns true if this box intersects [other] (touching edges do not count).
  bool overlaps(BoundingBox other) =>
      x < other.right &&
      right > other.x &&
      y < other.bottom &&
      bottom > other.y;

  BoundingBox translate(double dx, double dy) =>
      BoundingBox(x: x + dx, y: y + dy, width: width, height: height);

  /// Returns the smallest box containing both this and [other].
  BoundingBox union(BoundingBox other) {
    final minX = x < other.x ? x : other.x;
    final minY = y < other.y ? y : other.y;
    final maxRight = right > other.right ? right : other.right;
    final maxBottom = bottom > other.bottom ? bottom : other.bottom;
    return BoundingBox(
      x: minX,
      y: minY,
      width: maxRight - minX,
      height: maxBottom - minY,
    );
  }

  BoundingBox copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
  }) =>
      BoundingBox(
        x: x ?? this.x,
        y: y ?? this.y,
        width: width ?? this.width,
        height: height ?? this.height,
      );

  @override
  bool operator ==(Object other) {
    if (other is! BoundingBox) return false;
    return x == other.x &&
        y == other.y &&
        width == other.width &&
        height == other.height;
  }

  @override
  int get hashCode => Object.hash(x, y, width, height);

  Map<String, Object?> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };
}
