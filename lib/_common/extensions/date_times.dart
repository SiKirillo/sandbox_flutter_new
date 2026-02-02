part of '../common.dart';

extension DateTimeExtension on DateTime? {
  /// Returns date as 'YYYY-MM-DD' or null if this is null.
  String? toFormattedDate() {
    if (this == null) return null;
    final year = this!.year.toString().padLeft(4, '0');
    final month = this!.month.toString().padLeft(2, '0');
    final day = this!.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

extension DurationExtension on Duration? {
  /// Formats as 'MM:SS'; [isShort] omits leading zero for minutes. Returns '00:00' if null.
  String toMinutesAndSeconds({bool isShort = false}) {
    if (this == null) return '00:00';
    final time = this!.toString().split('.').first.padLeft(8, '0');
    final minutes = isShort ? time.split(':')[1][1] : time.split(':')[1];
    final seconds = time.split(':')[2];
    return '$minutes:$seconds';
  }
}
