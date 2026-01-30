part of '../../camera.dart';

class CameraSizeEntity {
  final double cameraViewHeight, cameraViewWidth;
  final double topOverlayHeight, bottomOverlayHeight;
  final double picturePreviewOverlayHeight;

  const CameraSizeEntity({
    required this.cameraViewHeight,
    required this.cameraViewWidth,
    required this.topOverlayHeight,
    required this.bottomOverlayHeight,
    required this.picturePreviewOverlayHeight,
  });

  factory CameraSizeEntity.calculate(double cameraAspectRatio, bool isPortrait, BuildContext context) {
    double calculateLongestSide(BuildContext context, bool isPortrait) {
      if (isPortrait) {
        return MediaQuery.sizeOf(context).longestSide - MediaQuery.viewPaddingOf(context).vertical;
      }

      return MediaQuery.sizeOf(context).longestSide - MediaQuery.viewPaddingOf(context).horizontal;
    }

    double calculateShortestSide(BuildContext context, bool isPortrait) {
      if (isPortrait) {
        return MediaQuery.sizeOf(context).shortestSide - MediaQuery.viewPaddingOf(context).horizontal;
      }

      return MediaQuery.sizeOf(context).shortestSide - MediaQuery.viewPaddingOf(context).vertical;
    }

    final maxCameraViewHeight = calculateLongestSide(context, isPortrait) - 200.0; /// cameraTopOverlaySize (80.0) + cameraBottomOverlaySize (120.0);
    final cameraViewHeight = math.min(maxCameraViewHeight, calculateShortestSide(context, isPortrait) * cameraAspectRatio);
    final cameraViewWidth = calculateShortestSide(context, isPortrait);

    final overlayAvailableHeight = calculateLongestSide(context, isPortrait) - cameraViewHeight;
    final cameraTopOverlaySize = 80.0;
    final cameraBottomOverlaySize = math.max(120.0, overlayAvailableHeight - cameraTopOverlaySize);
    final picturePreviewOverlaySize = (overlayAvailableHeight * 0.5).clamp(80.0, 100.0);

    return CameraSizeEntity(
      cameraViewHeight: cameraViewHeight,
      cameraViewWidth: cameraViewWidth,
      topOverlayHeight: cameraTopOverlaySize,
      bottomOverlayHeight: cameraBottomOverlaySize,
      picturePreviewOverlayHeight: picturePreviewOverlaySize,
    );
  }
}
