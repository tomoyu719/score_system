import 'package:score_core/score_core.dart';

/// Layout data for a single staff within a system.
final class StaffLayout {
  const StaffLayout({
    required this.partId,
    required this.staffId,
    required this.relativeY,
  });

  final PartId partId;
  final StaffId staffId;

  /// 0-based vertical ordering index within the system (0 = topmost staff).
  final int relativeY;

  Map<String, Object?> toJson() => {
        'partId': partId.value,
        'staffId': staffId.value,
        'relativeY': relativeY,
      };

  static StaffLayout fromJson(Map<String, Object?> map) => StaffLayout(
        partId: PartId(map['partId'] as String),
        staffId: StaffId(map['staffId'] as String),
        relativeY: map['relativeY'] as int,
      );

  @override
  bool operator ==(Object other) {
    if (other is! StaffLayout) return false;
    return partId == other.partId &&
        staffId == other.staffId &&
        relativeY == other.relativeY;
  }

  @override
  int get hashCode => Object.hash(partId, staffId, relativeY);
}
