part of '../common.dart';

/// Base type for all failure/error representations in the app.
/// Subclasses define specific failure kinds (e.g. [HttpFailure], [CommonFailure]).
/// Use [log] to send the failure to [LoggerService] when needed.
abstract class Failure {
  final String message;
  final String? comment;
  final bool isIgnored;

  const Failure({
    required this.message,
    this.comment,
    this.isIgnored = false,
  });

  void log({bool isImportant = true}) {
    if (isImportant) {
      LoggerService.logError(
        '$runtimeType'
        '\nMessage: $message'
        '${comment != null ? '\nComment: $comment' : ''}',
      );
    } else {
      LoggerService.logWarning(
        '$runtimeType'
        '\nMessage: $message'
        '${comment != null ? '\nComment: $comment' : ''}',
      );
    }
  }
}