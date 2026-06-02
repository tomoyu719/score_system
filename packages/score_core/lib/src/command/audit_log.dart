import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'command.dart';
import 'command_result.dart';

/// A single entry in the audit log.
final class AuditEntry {
  const AuditEntry({
    required this.command,
    required this.result,
    required this.timestamp,
  });

  final Command command;
  final CommandResult result;
  final DateTime timestamp;
}

/// Immutable append-only log of every command dispatched through [CommandEngine].
final class AuditLog {
  const AuditLog({this.entries = const IListConst([])});

  final IList<AuditEntry> entries;

  /// Returns a new [AuditLog] with [entry] appended.
  AuditLog append(AuditEntry entry) =>
      AuditLog(entries: entries.add(entry));
}
