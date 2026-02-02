part of 'firebase_core_service.dart';

class FirebaseRemoteConfigService {
  static late FirebaseRemoteConfig _remoteConfig;

  static Future<void> init(FlavorMode flavor, FirebaseApp app) async {
    LoggerService.logTrace('FirebaseRemoteConfigService -> init(flavor: $flavor)');
    _remoteConfig = FirebaseRemoteConfig.instanceFor(app: app);

    try {
      await Future.wait([
        _remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        )),
        _remoteConfig.ensureInitialized(),
        _remoteConfig.fetchAndActivate(),
        _remoteConfig.setDefaults(_getFlavorModeSettings(flavor)),
      ]);
    } on Exception catch (e) {
      LoggerService.logError('FirebaseRemoteConfigService -> init()', exception: e);
    }
  }

  static bool isFeatureEnabled(FirebaseRemoteFlag flag) {
    return _remoteConfig.getBool(flag.key);
  }

  static double getFlappyBirdParam(FirebaseRemoteFlag flag) {
    return _remoteConfig.getDouble(flag.key);
  }

  static Map<String, dynamic> _getFlavorModeSettings(FlavorMode flavor) {
    if (flavor == FlavorMode.prod) {
      return {
        FirebaseRemoteFlag.commonSelectLanguage.key: true,
      };
    }

    if (flavor == FlavorMode.staging) {
      return {
        FirebaseRemoteFlag.commonSelectLanguage.key: true,
      };
    }

    if (flavor == FlavorMode.stable) {
      return {
        FirebaseRemoteFlag.commonSelectLanguage.key: true,
      };
    }

    return {
      FirebaseRemoteFlag.commonSelectLanguage.key: true,
    };
  }
}

enum FirebaseRemoteFlag {
  /// Common
  commonSelectLanguage,
}

extension FirebaseRemoteFlagExtension on FirebaseRemoteFlag {
  String get key => switch (this) {
    FirebaseRemoteFlag.commonSelectLanguage => 'select_language_enabled',
  };
}
