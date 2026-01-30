part of '../../camera.dart';

class CameraState extends BlocState {
  final List<CameraDescription> cameras;
  final CameraController? controller;
  final List<DeviceOrientation> orientations;
  final int scannerInitAttempt;

  final XFile? imageFile;
  final Set<Code> scannedCodes;

  final int selectedCameraIndex;
  final FlashMode selectedFlashMode;
  final bool isGridShowed;
  final bool isOrientationLocked;
  final double currentFocusPositionX;
  final double currentFocusPositionY;

  final double maxZoomLevel;
  final double minZoomLevel;

  final bool isPermissionGranted;
  final bool isCameraSwitching;

  const CameraState({
    required this.cameras,
    required this.controller,
    required this.orientations,
    required this.scannerInitAttempt,
    required this.imageFile,
    required this.scannedCodes,
    required this.selectedCameraIndex,
    required this.selectedFlashMode,
    required this.isGridShowed,
    required this.isOrientationLocked,
    required this.currentFocusPositionX,
    required this.currentFocusPositionY,
    required this.maxZoomLevel,
    required this.minZoomLevel,
    required this.isPermissionGranted,
    required this.isCameraSwitching,
    super.isProcessing = false,
    super.isReady = false,
  });

  bool get isCameraReady => controller != null && controller?.value.isInitialized == true;

  factory CameraState.initial() {
    return const CameraState(
      cameras: [],
      controller: null,
      orientations: [],
      scannerInitAttempt: 0,
      imageFile: null,
      scannedCodes: {},
      selectedCameraIndex: 0,
      selectedFlashMode: FlashMode.off,
      isGridShowed: false,
      isOrientationLocked: false,
      currentFocusPositionX: 0.0,
      currentFocusPositionY: 0.0,
      maxZoomLevel: 1.0,
      minZoomLevel: 1.0,
      isPermissionGranted: false,
      isCameraSwitching: false,
    );
  }

  @override
  CameraState copyWith({
    List<CameraDescription>? cameras,
    List<DeviceOrientation>? orientations,
    int? scannerInitAttempt,
    int? selectedCameraIndex,
    FlashMode? selectedFlashMode,
    bool? isGridShowed,
    bool? isOrientationLocked,
    double? currentFocusPositionX,
    double? currentFocusPositionY,
    double? maxZoomLevel,
    double? minZoomLevel,
    bool? isPermissionGranted,
    bool? isCameraSwitching,
    bool? isCameraRotating,
    bool? isProcessing,
    bool? isReady,
  }) {
    return CameraState(
      cameras: cameras ?? this.cameras,
      controller: controller,
      orientations: orientations ?? this.orientations,
      scannerInitAttempt: scannerInitAttempt ?? this.scannerInitAttempt,
      imageFile: imageFile,
      scannedCodes: scannedCodes,
      selectedCameraIndex: selectedCameraIndex ?? this.selectedCameraIndex,
      selectedFlashMode: selectedFlashMode ?? this.selectedFlashMode,
      isGridShowed: isGridShowed ?? this.isGridShowed,
      isOrientationLocked: isOrientationLocked ?? this.isOrientationLocked,
      currentFocusPositionX: currentFocusPositionX ?? this.currentFocusPositionX,
      currentFocusPositionY: currentFocusPositionY ?? this.currentFocusPositionY,
      maxZoomLevel: maxZoomLevel ?? this.maxZoomLevel,
      minZoomLevel: minZoomLevel ?? this.minZoomLevel,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      isCameraSwitching: isCameraSwitching ?? this.isCameraSwitching,
      isProcessing: isProcessing ?? this.isProcessing,
      isReady: isReady ?? this.isReady,
    );
  }

  @override
  CameraState copyWithForced({CameraController? controller}) {
    return CameraState(
      cameras: cameras,
      controller: controller,
      orientations: orientations,
      scannerInitAttempt: scannerInitAttempt,
      imageFile: imageFile,
      scannedCodes: scannedCodes,
      selectedCameraIndex: selectedCameraIndex,
      selectedFlashMode: selectedFlashMode,
      isGridShowed: isGridShowed,
      isOrientationLocked: isOrientationLocked,
      currentFocusPositionX: currentFocusPositionX,
      currentFocusPositionY: currentFocusPositionY,
      maxZoomLevel: maxZoomLevel,
      minZoomLevel: minZoomLevel,
      isPermissionGranted: isPermissionGranted,
      isCameraSwitching: isCameraSwitching,
      isProcessing: isProcessing,
      isReady: isReady,
    );
  }

  CameraState updatePhoto({XFile? imageFile}) {
    return CameraState(
      cameras: cameras,
      controller: controller,
      orientations: orientations,
      scannerInitAttempt: scannerInitAttempt,
      imageFile: imageFile,
      scannedCodes: scannedCodes,
      selectedCameraIndex: selectedCameraIndex,
      selectedFlashMode: selectedFlashMode,
      isGridShowed: isGridShowed,
      isOrientationLocked: isOrientationLocked,
      currentFocusPositionX: currentFocusPositionX,
      currentFocusPositionY: currentFocusPositionY,
      maxZoomLevel: maxZoomLevel,
      minZoomLevel: minZoomLevel,
      isPermissionGranted: isPermissionGranted,
      isCameraSwitching: isCameraSwitching,
      isProcessing: isProcessing,
      isReady: isReady,
    );
  }

  CameraState updateScans({Set<Code>? scannedCodes}) {
    return CameraState(
      cameras: cameras,
      controller: controller,
      orientations: orientations,
      scannerInitAttempt: scannerInitAttempt,
      imageFile: imageFile,
      scannedCodes: scannedCodes ?? {},
      selectedCameraIndex: selectedCameraIndex,
      selectedFlashMode: selectedFlashMode,
      isGridShowed: isGridShowed,
      isOrientationLocked: isOrientationLocked,
      currentFocusPositionX: currentFocusPositionX,
      currentFocusPositionY: currentFocusPositionY,
      maxZoomLevel: maxZoomLevel,
      minZoomLevel: minZoomLevel,
      isPermissionGranted: isPermissionGranted,
      isCameraSwitching: isCameraSwitching,
      isProcessing: isProcessing,
      isReady: isReady,
    );
  }
}

