part of '../_common/common.dart';

/// Supported app languages; maps to/from [Locale] and DTO codes.
enum LanguageType {
  en,
  ru;

  /// Parses language code string (e.g. 'en', 'ru') to [LanguageType].
  static LanguageType fromDto(String code) {
    return switch (code) {
      'en' => LanguageType.en,
      'ru' => LanguageType.ru,
      _ => throw Exception('Unknown type code: $code'),
    };
  }

  /// Converts [Locale] to [LanguageType]; defaults to en if unknown.
  static LanguageType fromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'en': {
        return LanguageType.en;
      }

      case 'ru': {
        return LanguageType.ru;
      }

      /// Example with different language codes
      // case 'uz': {
      //   if (locale.scriptCode == 'Cyrl') {
      //     return LanguageType.uzCyrl;
      //   }
      //
      //   if (locale.scriptCode == 'Latn') {
      //     return LanguageType.uzLatn;
      //   }
      //
      //   return LanguageType.uzLatn;
      // }

      default:
        return LanguageType.en;
    }
  }

  /// Converts to Flutter [Locale] for [EasyLocalization] / [context.locale].
  Locale toLocale() {
    return switch (this) {
      LanguageType.en => Locale.fromSubtags(languageCode: 'en'),
      LanguageType.ru => Locale.fromSubtags(languageCode: 'ru'),
      // LanguageType.uzCyrl => Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
      // LanguageType.uzLatn => Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Latn'),
    };
  }

  String toJson() {
    return switch (this) {
      LanguageType.en => 'en',
      LanguageType.ru => 'ru',
      // LanguageType.uzCyrl => 'uzCyrl',
      // LanguageType.uzLatn => 'uzLatn',
    };
  }
}
