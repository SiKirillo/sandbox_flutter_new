part of '../common.dart';

/// Holds current app language; [init] loads from prefs/device, [updateLocale] saves and applies.
class LocaleProvider with ChangeNotifier {
  LanguageType _language = LanguageType.ru;
  LanguageType get language => _language;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    // Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
    // Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Latn'),
  ];

  Locale getLocale({LanguageType? language}) => (language ?? locator<LocaleProvider>().language).toLocale();

  Future<void> init() async {
    LoggerService.logTrace('LocaleProvider -> init()');

    /// Read saved locale
    final locale = await locator<AppPreferencesStorage>().readLocale();
    if (supportedLocales.contains(locale)) {
      _language = LanguageType.fromLocale(locale!);
      return;
    }

    /// Read device locale
    final languageCode = Platform.localeName.split(RegExp(r'[_.]')).first;
    final deviceLocale = Locale(languageCode);
    if (supportedLocales.contains(deviceLocale)) {
      _language = LanguageType.fromLocale(deviceLocale);
      return;
    }

    /// Default locale
    _language = LanguageType.ru;
  }

  Future<void> updateLocale({required BuildContext context, required LanguageType language}) async {
    LoggerService.logTrace('LocaleProvider -> updateLocale()');
    if (LanguageType.fromLocale(context.locale) == language) {
      return;
    }

    _language = language;
    await context.setLocale(language.toLocale());
    await locator<AppPreferencesStorage>().writeLocale(language.toLocale());
    notifyListeners();
  }
}

/// Loads translations from multiple JSON paths and merges (e.g. common + app).
class MergedAssetLoader extends localization.AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final languageSpecific = '${locale.languageCode}${locale.scriptCode != null ? '-${locale.scriptCode}' : ''}';
    final commonPath = 'packages/.../assets/translations/_common/$languageSpecific.json';
    final appPath = 'packages/.../assets/translations/.../$languageSpecific.json';

    final commonJson = await rootBundle.loadString(commonPath);
    final appJson = await rootBundle.loadString(appPath);

    final commonMap = json.decode(commonJson) as Map<String, dynamic>;
    final appMap = json.decode(appJson) as Map<String, dynamic>;

    return {
      ...commonMap,
      ...appMap,
    };
  }
}