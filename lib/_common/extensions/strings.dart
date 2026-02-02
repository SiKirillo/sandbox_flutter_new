part of '../common.dart';

extension StringExtension on String {
  /// First letter uppercase, rest lowercase.
  String toCamelCase() {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Measures text size with [TextPainter] using optional [style], [maxLines], and [maxWidth].
  Size calculateSize({
    TextStyle? style,
    int maxLines = 1,
    double maxWidth = double.maxFinite,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: this,
        style: style,
      ),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return painter.size;
  }
}