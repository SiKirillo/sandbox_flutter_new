part of '../common.dart';

/// Service for device and app metadata. Call [init] before using
/// [getFlavorMode], [getDeviceDescription], [getBuildPlaceholderLabel], etc.
class DeviceService {
  late final PackageInfo _packageData;
  final _deviceData = DeviceInfoPlugin();
  bool _isPhysicalDevice = false;

  static const _devPackageSuffix = '.dev';
  static const _stablePackageSuffix = '.stable';
  static const _stagingPackageSuffix = '.staging';

  PackageInfo get packageData => _packageData;
  DeviceInfoPlugin get deviceData => _deviceData;
  bool get isPhysicalDevice => _isPhysicalDevice;

  Future<DeviceData> getDeviceDescription() async {
    return DeviceData.fromData(Platform.operatingSystem, packageData, await _deviceData.deviceInfo);
  }

  bool get showExperimentalFeatures {
    final flavor = getFlavorMode();
    return flavor == FlavorMode.dev || flavor == FlavorMode.stable;
  }

  Future<void> init() async {
    _packageData = await PackageInfo.fromPlatform();

    if (kIsWeb) {
      return;
    }

    if (Platform.isAndroid) {
      _isPhysicalDevice = (await _deviceData.androidInfo).isPhysicalDevice;
    }

    if (Platform.isIOS) {
      _isPhysicalDevice = (await _deviceData.iosInfo).isPhysicalDevice;
    }
  }

  FlavorMode getFlavorMode() {
    if (_packageData.packageName.contains(_devPackageSuffix)) {
      return FlavorMode.dev;
    }

    if (_packageData.packageName.contains(_stablePackageSuffix)) {
      return FlavorMode.stable;
    }

    if (_packageData.packageName.contains(_stagingPackageSuffix)) {
      return FlavorMode.staging;
    }

    return FlavorMode.prod;
  }

  BuildMode getBuildMode() {
    if (kDebugMode) {
      return BuildMode.debug;
    }

    if (kProfileMode) {
      return BuildMode.profile;
    }

    return BuildMode.release;
  }

  String getBuildPlaceholderLabel({bool isFlavor = true}) {
    return '${isFlavor ? getFlavorMode().toStringLabel() : getBuildMode().toStringLabel()} ${_packageData.version}';
  }

  String getBuildVersionPlaceholder() {
    return _packageData.version;
  }

  List<DeviceOrientation> orientations(BuildContext context) {
    if (SizeConstants.isTablet(context: context)) {
      return [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ];
    } else {
      return [
        DeviceOrientation.portraitUp,
      ];
    }
  }
}

enum FlavorMode {
  dev,
  stable,
  staging,
  prod,
  none;

  String toStringLabel() {
    switch (this) {
      case FlavorMode.dev:
        return 'Dev';

      case FlavorMode.stable:
        return 'Stable';

      case FlavorMode.staging:
        return 'Staging';

      case FlavorMode.prod:
        return 'Production';

      default:
        return 'None';
    }
  }

  String toStringSuffix() {
    switch (this) {
      case FlavorMode.dev:
        return 'dev';

      case FlavorMode.stable:
        return 'stable';

      case FlavorMode.staging:
        return 'staging';

      case FlavorMode.prod:
        return 'production';

      default:
        return 'none';
    }
  }
}

enum BuildMode {
  debug,
  profile,
  release;

  String toStringLabel() {
    switch (this) {
      case BuildMode.debug:
        return 'Debug';

      case BuildMode.profile:
        return 'Profile';

      case BuildMode.release:
        return 'Release';
    }
  }
}

class DeviceData {
  final String appName;
  final String buildNumber;
  final String buildSignature;
  final String packageName;
  final String version;
  final String? installerStore;
  final DateTime? installTime, updateTime;
  final String platform;
  final BaseDeviceInfo data;

  const DeviceData({
    required this.platform,
    required this.appName,
    required this.buildNumber,
    required this.buildSignature,
    required this.packageName,
    required this.version,
    this.installerStore,
    this.installTime,
    this.updateTime,
    required this.data,
  });

  static DeviceData fromData(String platform, PackageInfo packageData, BaseDeviceInfo deviceData) {
    return DeviceData(
      platform: platform,
      appName: packageData.appName,
      buildNumber: packageData.buildNumber,
      buildSignature: packageData.buildSignature,
      packageName: packageData.packageName,
      version: packageData.version,
      installerStore: packageData.installerStore,
      installTime: packageData.installTime,
      updateTime: packageData.updateTime,
      data: deviceData,
    );
  }

  @override
  String toString() {
    return 'Platform: $platform\nApp name: $appName\nBuild number: $buildNumber\nBuild signature: $buildSignature\nPackage name: $packageName\nVersion: $version\nInstaller store: $installerStore\nInstall time: ${installTime.toString()}\nUpdate time: ${updateTime.toString()}\nData: ${data.toString()}';
  }
}