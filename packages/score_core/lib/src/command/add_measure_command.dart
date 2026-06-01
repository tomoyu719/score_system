part of 'command.dart';

/// Adds a [Measure] to a specific staff at a given measure number.
final class AddMeasureCommand extends Command {
  const AddMeasureCommand({
    required this.partId,
    required this.staffId,
    required this.measureNumber,
    required this.measure,
  });

  final PartId partId;
  final StaffId staffId;
  final int measureNumber;
  final Measure measure;
}
