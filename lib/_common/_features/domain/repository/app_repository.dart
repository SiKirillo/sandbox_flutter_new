part of '../../../common.dart';

class AppRepository {
  Future<void> init({bool isForced = false}) async {
    LoggerService.logTrace('AppRepository -> init(isForced: $isForced)');
    final isFirstLaunch = await locator<AppPreferencesStorage>().readInitialConfiguration();

    if (isFirstLaunch) {
      await Future.wait([
        AbstractSecureDatasource.deleteStorage(),
        AbstractSharedPreferencesDatasource.deletePreferences(),
        locator<AppPreferencesStorage>().writeInitialConfiguration(false),
      ]);
    } else if (isForced) {
      await Future.wait([
        AbstractSecureDatasource.deleteStorage(),
        AbstractSharedPreferencesDatasource.deletePreferencesSafely(),
        locator<AppPreferencesStorage>().writeInitialConfiguration(false),
      ]);
    }
  }

  Future<void> logout({bool isExpired = false}) async {
    LoggerService.logTrace('AppRepository -> logout(isExpired: $isExpired)');
    locator<InAppOverlayProvider>().show(text: 'button.logout_processing'.tr());

    try {
      /// Clear token
      // await locator<PushNotificationService>().clearToken();
    } on Exception catch (e) {
      LoggerService.logWarning('AppRepository -> logout() exception: ${e.toString()}');
    } finally {
      /// Clear token
      await Future.delayed(OtherConstants.defaultDelayDuration);
      AbstractRemoteDatasource.tokenData = null;
      AbstractRemoteDatasource.clearRetryQueue();

      /// Re-init
      locator<AppRepository>().init(isForced: true);
      locator<AppBloc>().add(Reset_AppEvent(isSessionExpired: isExpired));

      locator<CameraBloc>().add(Reset_CameraEvent());

      await Future.delayed(Duration(milliseconds: 1000));
      locator<InAppOverlayProvider>().hide();
    }
  }
}