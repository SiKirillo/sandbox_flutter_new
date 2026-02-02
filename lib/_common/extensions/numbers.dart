part of '../common.dart';

extension NumbersExtension on num {
  /// Formats integer with thousands separator (dot) using [LocaleProvider] for [language].
  String toFormattedWithDots({LanguageType? language}) {
    return localization.NumberFormat('#,###', locator<LocaleProvider>().getLocale(language: language).toString()).format(truncate()).replaceAll(' ', '.');
  }

  /// 00:00:00
  String toTimerFormat() {
    final hours = (this ~/ 3600).toInt();
    final minutes = ((this % 3600) ~/ 60).toInt();
    final seconds = (this % 60).toInt();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}