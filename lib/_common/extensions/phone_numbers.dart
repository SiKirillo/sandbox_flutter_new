part of '../common.dart';

extension PhoneNumbersExtension on String {
  /// Strips non-digits; if [length] is set, keeps only the last [length] digits.
  String toDigits({int? length}) {
    final formattedNumber = replaceAll(RegExp(r'[\D+]'), '');
    if (length != null && formattedNumber.length > length) {
      return formattedNumber.substring(formattedNumber.length - length);
    }
    return formattedNumber;
  }

  /// Expects +XXX XX XXX-XX-XX pattern and formats accordingly (e.g. +375 29 123-45-67).
  String toFormattedPhoneNumber() {
    final regExp = RegExp(r'^\+(\d{3})(\d{2})(\d{3})(\d{2})(\d{2})$');
    return replaceAllMapped(regExp, (match) {
      return '+${match[1]} ${match[2]} ${match[3]}-${match[4]}-${match[5]}';
    });
  }
}