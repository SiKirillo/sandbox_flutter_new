part of '../../../common.dart';

class AppPreferencesStorage extends AbstractSharedPreferencesDatasource {
  AppPreferencesStorage() : super(id: 'core');

  Future<bool> readInitialConfiguration() async {
    LoggerService.logTrace('AppPreferencesStorage -> readInitialConfiguration()');
    return (await AppPreferencesStorage().read('is_first_launch')) ?? true;
  }

  Future<void> writeInitialConfiguration(bool isFirstLaunch) async {
    LoggerService.logTrace('AppPreferencesStorage -> writeInitialConfiguration()');
    await AppPreferencesStorage().write('is_first_launch', isFirstLaunch);
  }

  Future<Locale?> readLocale() async {
    LoggerService.logTrace('AppPreferencesStorage -> readLocale()');
    final languageCode = await AppPreferencesStorage().read('locale.language_code');
    final scriptCode = await AppPreferencesStorage().read('locale.script_code');
    if (languageCode == null || languageCode == '') {
      return null;
    }

    return Locale.fromSubtags(languageCode: languageCode, scriptCode: scriptCode);
  }

  Future<void> writeLocale(Locale locale) async {
    LoggerService.logTrace('AppPreferencesStorage -> writeLocale()');
    await AppPreferencesStorage().write('locale.language_code', locale.languageCode);
    await AppPreferencesStorage().write('locale.script_code', locale.scriptCode);
  }
}
