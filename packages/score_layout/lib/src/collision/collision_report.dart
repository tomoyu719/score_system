import 'collision_detector.dart';

/// Summary of all detected collisions in a layout pass.
final class CollisionReport {
  const CollisionReport({
    required this.pairs,
    required this.timestamp,
  });

  final List<CollisionPair> pairs;
  final DateTime timestamp;

  bool get hasCollisions => pairs.isNotEmpty;
  int get count => pairs.length;

  Map<String, Object?> toJson() => {
        'hasCollisions': hasCollisions,
        'count': count,
        'timestamp': timestamp.toIso8601String(),
        'pairs': pairs
            .map(
              (p) => {
                'a': p.a.id,
                'b': p.b.id,
              },
            )
            .toList(),
      };
}
