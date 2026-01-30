part of '../../camera.dart';

class CameraSettingsOptions {
  final CameraType type;
  final List<int> allowedFormats;
  final double maxSizeMB;
  final int maxHeightPx, maxWidthPx;
  final Function(CameraResultEntity)? onScanned;

  const CameraSettingsOptions({
    this.type = CameraType.camera,
    this.allowedFormats = const [Format.any],
    this.maxSizeMB = 3,
    this.maxHeightPx = 4032,
    this.maxWidthPx = 3024,
    this.onScanned,
  });
}