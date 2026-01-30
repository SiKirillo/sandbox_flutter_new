part of '../common.dart';

abstract class Failure {
  final String message;
  final String? comment;
  final bool isIgnored;

  const Failure({
    required this.message,
    this.comment,
    this.isIgnored = false,
  }) : super();

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