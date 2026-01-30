part of '../../camera.dart';

class CameraScreen extends StatefulWidget {
  static const routePath = '/camera';

  final CameraSettingsOptions settings;

  const CameraScreen({
    super.key,
    this.settings = const CameraSettingsOptions(),
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  final _focusAreaKey = GlobalKey<_CameraFocusAreaState>();
  final _scannerAreaKey = GlobalKey<_CameraScannerAreaState>();
  double _currentZoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero).then((_) {
      locator<CameraBloc>().add(Init_CameraEvent(type: widget.settings.type, context: context));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      locator<CameraBloc>().state.controller?.resumePreview();
      locator<CameraBloc>().add(UpdatePermissionStatus_CameraEvent());
    }

    if (state == AppLifecycleState.inactive) {
      locator<CameraBloc>().state.controller?.pausePreview();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    locator<CameraBloc>().state.controller?.dispose();
    locator<CameraBloc>().add(Reset_CameraEvent());
    super.dispose();
  }

  Future<void> _onControllerCreated(CameraController? controller, Exception? exception) async {
    if (controller == null) return;
    locator<CameraBloc>().add(InitScanner_CameraEvent(controller: controller));
  }

  Future<void> _handlePermissionStatus() async {
    if (!await locator<PermissionService>().isCameraGranted) {
      final isPermissionGranted = await locator<PermissionService>().requestCameraPermission(context: context);
      locator<CameraBloc>().add(UpdatePermissionStatus_CameraEvent(isPermissionGranted: isPermissionGranted));
      await Future.delayed(OtherConstants.defaultAnimationDuration);
    }
  }

  Future<void> _onScanHandler(Code code) async {
    locator<CameraBloc>().add(TakeScan_CameraEvent(
      code: code,
      type: widget.settings.type,
      allowedFormats: widget.settings.allowedFormats,
      onResponse: BlocEventResponse(
        onResult: (result) {
          _scannerAreaKey.currentState?.startAnimation();
          if (widget.settings.onScanned != null) {
            widget.settings.onScanned!(CameraResultEntity(
              codes: {code},
            ));
          }

          if (widget.settings.type == CameraType.scannerOne) {
            AppRouter.configs.pop(CameraResultEntity(
              codes: locator<CameraBloc>().state.scannedCodes,
            ));
          }
        },
      ),
    ));
  }

  void _onTakePictureHandler() {
    locator<CameraBloc>().add(TakePhoto_CameraEvent(
      maxSizeMB: widget.settings.maxSizeMB,
      maxHeightPx: widget.settings.maxHeightPx,
      maxWidthPx: widget.settings.maxWidthPx,
    ));
  }

  void _onDeletePhotoHandler() {
    locator<CameraBloc>().add(ClearPhotoAndScans_CameraEvent());
  }

  void _onSendPhotoAndScansHandler() {
    AppRouter.configs.pop(CameraResultEntity(
      image: widget.settings.type == CameraType.camera ? locator<CameraBloc>().state.imageFile : null,
      codes: widget.settings.type != CameraType.camera ? locator<CameraBloc>().state.scannedCodes : null,
    ));
  }

  void _onFocusHandler(TapDownDetails details, BoxConstraints constraints) {
    locator<CameraBloc>().add(UpdateFocusPosition_CameraEvent(
      details: details,
      constraints: constraints,
      onResponse: BlocEventResponse(
        onResult: (result) {
          _focusAreaKey.currentState?.startAnimation();
        },
      ),
    ));
  }

  void _onHandleScaleUpdate(ScaleUpdateDetails details) {
    if (!context.read<CameraBloc>().state.isCameraReady) return;
    final cameraMinZoomLevel = context.read<CameraBloc>().state.minZoomLevel;
    final cameraMaxZoomLevel = context.read<CameraBloc>().state.maxZoomLevel;
    double zoom = _currentZoomLevel + (details.scale.clamp(0.975, 1.025) - 1.0);
    zoom = zoom.clamp(cameraMinZoomLevel, cameraMaxZoomLevel);
    setState(() {
      _currentZoomLevel = zoom;
    });

    context.read<CameraBloc>().state.controller!.setZoomLevel(zoom);
  }

  Widget _buildCameraPreviewPortrait(CameraController? controller) {
    if (controller == null) {
      return _buildLoadingPreview();
    }

    final cameraAspectRatio = controller.value.aspectRatio;
    final sizes = CameraSizeEntity.calculate(cameraAspectRatio, true, context);

    return Stack(
      fit: StackFit.expand,
      children: [
        /// Camera view
        BlocBuilder<CameraBloc, CameraState>(
          buildWhen: (prev, current) {
            return prev.isCameraSwitching != current.isCameraSwitching;
          },
          builder: (_, state) {
            if (state.isCameraSwitching) {
              return Positioned.fill(
                child: Container(
                  color: ColorConstants.cameraBG(),
                ),
              );
            }

            return Positioned(
              top: sizes.topOverlayHeight,
              left: 0.0,
              right: 0.0,
              child: LayoutBuilder(
                builder: (_, constraints) {
                  return FittedBox(
                    child: SizedBox(
                      height: sizes.cameraViewHeight,
                      width: sizes.cameraViewWidth,
                      child: GestureDetector(
                        onDoubleTapDown: (details) => _onFocusHandler(details, constraints),
                        onScaleUpdate: _onHandleScaleUpdate,
                        child: CameraPreview(controller),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        /// Grid
        BlocBuilder<CameraBloc, CameraState>(
          buildWhen: (prev, current) {
            return prev.isGridShowed != current.isGridShowed;
          },
          builder: (_, state) {
            if (state.isGridShowed) {
              return Positioned.fill(
                top: sizes.topOverlayHeight,
                bottom: sizes.bottomOverlayHeight,
                child: _CameraGridOverlay(),
              );
            }

            return SizedBox();
          },
        ),
        /// Corners
        Positioned.fill(
          top: sizes.topOverlayHeight,
          bottom: sizes.bottomOverlayHeight,
          child: _CameraCornersOverlay(length: MediaQuery.sizeOf(context).shortestSide * 0.15),
        ),
        /// Focus area
        BlocBuilder<CameraBloc, CameraState>(
          buildWhen: (prev, current) {
            return prev.currentFocusPositionY != current.currentFocusPositionY ||
                prev.currentFocusPositionX != current.currentFocusPositionX;
          },
          builder: (_, state) {
            return Positioned(
              top: state.currentFocusPositionY + _CameraFocusArea.calculateSize * 0.5,
              left: state.currentFocusPositionX - _CameraFocusArea.calculateSize * 0.5,
              child: _CameraFocusArea(key: _focusAreaKey),
            );
          },
        ),
        /// Blur
        BlocBuilder<CameraBloc, CameraState>(
          buildWhen: (prev, current) {
            return prev.isProcessing != current.isProcessing;
          },
          builder: (_, state) {
            if (state.isProcessing) {
              return Positioned.fill(
                top: sizes.topOverlayHeight,
                bottom: sizes.bottomOverlayHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _CameraBlurOverlay(),
                    ),
                    Center(
                      child: CustomProgressIndicator(),
                    ),
                  ],
                ),
              );
            }

            return SizedBox();
          },
        ),
        /// Top overlay
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          height: sizes.topOverlayHeight,
          child: _CameraTopOverlay(
            type: widget.settings.type,
            orientation: Orientation.portrait,
          ),
        ),
        /// Bottom overlay
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          height: sizes.bottomOverlayHeight,
          child: _CameraBottomOverlay(
            type: widget.settings.type,
            orientation: Orientation.portrait,
            offset: Offset.zero,
            onTakePicture: _onTakePictureHandler,
            onSendCodes: _onSendPhotoAndScansHandler,
          ),
        ),
        /// Picture preview
        BlocBuilder<CameraBloc, CameraState>(
          buildWhen: (prev, current) {
            return prev.imageFile != current.imageFile;
          },
          builder: (_, state) {
            if (state.imageFile != null) {
              return Positioned.fill(
                child: _PicturePreviewOverlay(
                  image: state.imageFile!,
                  orientation: Orientation.portrait,
                  isLandscapeLeft: false,
                  offset: Offset.zero,
                  borderSize: sizes.picturePreviewOverlayHeight,
                  onCancel: _onDeletePhotoHandler,
                  onSubmit: _onSendPhotoAndScansHandler,
                ),
              );
            }

            return SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildCameraPreviewLandscape(CameraController? controller, bool isLandscapeLeft) {
    if (controller == null) {
      return _buildLoadingPreview();
    }

    final cameraAspectRatio = controller.value.aspectRatio;
    final sizes = CameraSizeEntity.calculate(cameraAspectRatio, false, context);

    return Stack(
      fit: StackFit.expand,
      children: [
        /// Camera view
        BlocBuilder<CameraBloc, CameraState>(
          buildWhen: (prev, current) {
            return prev.isCameraSwitching != current.isCameraSwitching;
          },
          builder: (_, state) {
            if (state.isCameraSwitching) {
              return Positioned.fill(
                child: Container(
                  color: ColorConstants.cameraBG(),
                ),
              );
            }

            return Positioned(
              top: 0.0,
              bottom: 0.0,
              left: isLandscapeLeft ? sizes.topOverlayHeight: sizes.bottomOverlayHeight,
              child: LayoutBuilder(
                builder: (_, constraints) {
                  return FittedBox(
                    child: SizedBox(
                      height: sizes.cameraViewWidth,
                      width: sizes.cameraViewHeight,
                      child: GestureDetector(
                        onDoubleTapDown: (details) => _onFocusHandler(details, constraints),
                        onScaleUpdate: _onHandleScaleUpdate,
                        child: CameraPreview(controller),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        /// Grid
        BlocBuilder<CameraBloc, CameraState>(
          buildWhen: (prev, current) {
            return prev.isGridShowed != current.isGridShowed;
          },
          builder: (_, state) {
            if (state.isGridShowed) {
              return Positioned.fill(
                left: isLandscapeLeft ? sizes.topOverlayHeight : sizes.bottomOverlayHeight,
                right: isLandscapeLeft ? sizes.bottomOverlayHeight : sizes.topOverlayHeight,
                child: _CameraGridOverlay(),
              );
            }

            return SizedBox();
          },
        ),
        /// Corners
        Positioned.fill(
          left: isLandscapeLeft ? sizes.topOverlayHeight : sizes.bottomOverlayHeight,
          right: isLandscapeLeft ? sizes.bottomOverlayHeight : sizes.topOverlayHeight,
          child: _CameraCornersOverlay(length: MediaQuery.sizeOf(context).shortestSide * 0.15),
        ),
        /// Focus area
        BlocBuilder<CameraBloc, CameraState>(
          buildWhen: (prev, current) {
            return prev.currentFocusPositionY != current.currentFocusPositionY ||
                prev.currentFocusPositionX != current.currentFocusPositionX;
          },
          builder: (_, state) {
            final topPosition = state.currentFocusPositionY - _CameraFocusArea.calculateSize * 0.5;
            final leftPosition = state.currentFocusPositionX + _CameraFocusArea.calculateSize * 0.5;
            final rightPosition = sizes.cameraViewHeight + sizes.topOverlayHeight - (state.currentFocusPositionX + _CameraFocusArea.calculateSize * 0.5);

            return Positioned(
              top: topPosition,
              left: isLandscapeLeft ? leftPosition : null,
              right: isLandscapeLeft ? null : rightPosition,
              child: _CameraFocusArea(key: _focusAreaKey),
            );
          },
        ),
        /// Blur
        BlocBuilder<CameraBloc, CameraState>(
          buildWhen: (prev, current) {
            return prev.isProcessing != current.isProcessing;
          },
          builder: (_, state) {
            if (state.isProcessing) {
              return Positioned.fill(
                left: isLandscapeLeft ? sizes.topOverlayHeight : sizes.bottomOverlayHeight,
                right: isLandscapeLeft ? sizes.bottomOverlayHeight : sizes.topOverlayHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _CameraBlurOverlay(),
                    ),
                    Center(
                      child: CustomProgressIndicator(),
                    ),
                  ],
                ),
              );
            }

            return SizedBox();
          },
        ),
        /// Top overlay
        Positioned(
          top: 0.0,
          bottom: 0.0,
          left: isLandscapeLeft ? 0.0 : null,
          right: isLandscapeLeft ? null : 0.0,
          width: sizes.topOverlayHeight,
          child: _CameraTopOverlay(
            type: widget.settings.type,
            orientation: Orientation.landscape,
          ),
        ),
        /// Bottom overlay
        Positioned(
          top: 0.0,
          bottom: 0.0,
          left: isLandscapeLeft ? null : 0.0,
          right: isLandscapeLeft ? 0.0 : null,
          width: sizes.bottomOverlayHeight,
          child: _CameraBottomOverlay(
            type: widget.settings.type,
            orientation: Orientation.landscape,
            offset: Offset(0.0, 0.0),
            onTakePicture: _onTakePictureHandler,
            onSendCodes: _onSendPhotoAndScansHandler,
          ),
        ),
        /// Picture preview
        BlocBuilder<CameraBloc, CameraState>(
          buildWhen: (prev, current) {
            return prev.imageFile != current.imageFile;
          },
          builder: (_, state) {
            if (state.imageFile != null) {
              return Positioned.fill(
                child: _PicturePreviewOverlay(
                  image: state.imageFile!,
                  orientation: Orientation.landscape,
                  isLandscapeLeft: isLandscapeLeft,
                  offset: Offset(0.0, 0.0),
                  borderSize: sizes.picturePreviewOverlayHeight,
                  onCancel: _onDeletePhotoHandler,
                  onSubmit: _onSendPhotoAndScansHandler,
                ),
              );
            }

            return SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildScannerPreviewPortrait(CameraController? controller, bool isCameraReady) {
    final cameraAspectRatio = controller?.value.aspectRatio ?? (4 / 3);
    final sizes = CameraSizeEntity.calculate(cameraAspectRatio, true, context);

    return Stack(
      fit: StackFit.expand,
      children: [
        /// Scanner view
        BlocBuilder<CameraBloc, CameraState>(
          buildWhen: (prev, current) {
            return prev.scannerInitAttempt != current.scannerInitAttempt ||
                prev.isCameraSwitching != current.isCameraSwitching;
          },
          builder: (_, state) {
            if (state.isCameraSwitching) {
              return Positioned.fill(
                child: Container(
                  color: ColorConstants.cameraBG(),
                ),
              );
            }

            return Positioned(
              top: sizes.topOverlayHeight,
              left: 0.0,
              right: 0.0,
              child: LayoutBuilder(
                builder: (_, constraints) {
                  return FittedBox(
                    child: SizedBox(
                      height: sizes.cameraViewHeight,
                      width: sizes.cameraViewWidth,
                      child: GestureDetector(
                        onDoubleTapDown: (details) => _onFocusHandler(details, constraints),
                        onScaleUpdate: _onHandleScaleUpdate,
                        child: ReaderWidget(
                          key: ValueKey(state.scannerInitAttempt),
                          onControllerCreated: _onControllerCreated,
                          onScan: _onScanHandler,
                          scanDelay: Duration(milliseconds: 200),
                          scanDelaySuccess: Duration(milliseconds: 1500),
                          tryHarder: true,
                          tryInverted: true,
                          showScannerOverlay: false,
                          showGallery: false,
                          showFlashlight: false,
                          showToggleCamera: false,
                          resolution: ResolutionPreset.ultraHigh,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        if (controller != null && isCameraReady) ...[
          /// Focus area
          BlocBuilder<CameraBloc, CameraState>(
            buildWhen: (prev, current) {
              return prev.currentFocusPositionY != current.currentFocusPositionY ||
                  prev.currentFocusPositionX != current.currentFocusPositionX;
            },
            builder: (_, state) {
              return Positioned(
                top: state.currentFocusPositionY + _CameraFocusArea.calculateSize * 0.5,
                left: state.currentFocusPositionX - _CameraFocusArea.calculateSize * 0.5,
                child: _CameraFocusArea(key: _focusAreaKey),
              );
            },
          ),
          /// Scanner area
          Positioned.fill(
            top: sizes.topOverlayHeight,
            bottom: sizes.bottomOverlayHeight,
            child: IgnorePointer(
              child: Center(
                child: _CameraScannerArea(key: _scannerAreaKey),
              ),
            ),
          ),
          /// Blur
          BlocBuilder<CameraBloc, CameraState>(
            buildWhen: (prev, current) {
              return prev.isProcessing != current.isProcessing;
            },
            builder: (_, state) {
              if (state.isProcessing) {
                return Positioned.fill(
                  top: sizes.topOverlayHeight,
                  bottom: sizes.bottomOverlayHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _CameraBlurOverlay(),
                      ),
                      Center(
                        child: CustomProgressIndicator(),
                      ),
                    ],
                  ),
                );
              }

              return SizedBox();
            },
          ),
          /// Top overlay
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            height: sizes.topOverlayHeight,
            child: _CameraTopOverlay(
              type: widget.settings.type,
              orientation: Orientation.portrait,
            ),
          ),
          /// Bottom overlay
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            height: sizes.bottomOverlayHeight,
            child: _CameraBottomOverlay(
              type: widget.settings.type,
              orientation: Orientation.portrait,
              offset: Offset.zero,
              onTakePicture: _onTakePictureHandler,
              onSendCodes: _onSendPhotoAndScansHandler,
            ),
          ),
        ]
        else ...[
          Positioned.fill(
            child: Container(
              color: ColorConstants.cameraBG(),
            ),
          ),
          Center(
            child: CustomProgressIndicator(),
          ),
        ],
      ],
    );
  }

  Widget _buildScannerPreviewLandscape(CameraController? controller, bool isCameraReady, bool isLandscapeLeft) {
    final cameraAspectRatio = controller?.value.aspectRatio ?? (4 / 3);
    final sizes = CameraSizeEntity.calculate(cameraAspectRatio, false, context);

    return Stack(
      fit: StackFit.expand,
      children: [
        /// Scanner view
        BlocBuilder<CameraBloc, CameraState>(
          buildWhen: (prev, current) {
            return prev.scannerInitAttempt != current.scannerInitAttempt ||
                prev.isCameraSwitching != current.isCameraSwitching;
          },
          builder: (_, state) {
            if (state.isCameraSwitching) {
              return Positioned.fill(
                child: Container(
                  color: ColorConstants.cameraBG(),
                ),
              );
            }

            return Positioned(
              top: 0.0,
              bottom: 0.0,
              left: isLandscapeLeft ? sizes.topOverlayHeight : sizes.bottomOverlayHeight,
              child: LayoutBuilder(
                builder: (_, constraints) {
                  return FittedBox(
                    child: SizedBox(
                      height: sizes.cameraViewWidth,
                      width: sizes.cameraViewHeight,
                      child: GestureDetector(
                        onDoubleTapDown: (details) => _onFocusHandler(details, constraints),
                        onScaleUpdate: _onHandleScaleUpdate,
                        child: ReaderWidget(
                          key: ValueKey(state.scannerInitAttempt),
                          onControllerCreated: _onControllerCreated,
                          onScan: _onScanHandler,
                          scanDelay: Duration(milliseconds: 200),
                          scanDelaySuccess: Duration(milliseconds: 1500),
                          tryHarder: true,
                          tryInverted: true,
                          showScannerOverlay: false,
                          showGallery: false,
                          showFlashlight: false,
                          showToggleCamera: false,
                          resolution: ResolutionPreset.ultraHigh,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        if (controller != null && isCameraReady) ...[
          /// Focus area
          BlocBuilder<CameraBloc, CameraState>(
            buildWhen: (prev, current) {
              return prev.currentFocusPositionY != current.currentFocusPositionY ||
                  prev.currentFocusPositionX != current.currentFocusPositionX;
            },
            builder: (_, state) {
              final topPosition = state.currentFocusPositionY - _CameraFocusArea.calculateSize * 0.5;
              final leftPosition = state.currentFocusPositionX + _CameraFocusArea.calculateSize * 0.5;
              final rightPosition = sizes.cameraViewHeight + sizes.topOverlayHeight - (state.currentFocusPositionX + _CameraFocusArea.calculateSize * 0.5);

              return Positioned(
                top: topPosition,
                left: isLandscapeLeft ? leftPosition : null,
                right: isLandscapeLeft ? null : rightPosition,
                child: _CameraFocusArea(key: _focusAreaKey),
              );
            },
          ),
          /// Scanner area
          Positioned.fill(
            left: isLandscapeLeft ? sizes.topOverlayHeight : sizes.bottomOverlayHeight,
            right: isLandscapeLeft ? sizes.bottomOverlayHeight : sizes.topOverlayHeight,
            child: IgnorePointer(
              child: Center(
                child: _CameraScannerArea(key: _scannerAreaKey),
              ),
            ),
          ),
          /// Blur
          BlocBuilder<CameraBloc, CameraState>(
            buildWhen: (prev, current) {
              return prev.isProcessing != current.isProcessing;
            },
            builder: (_, state) {
              if (state.isProcessing) {
                return Positioned.fill(
                  left: isLandscapeLeft ? sizes.topOverlayHeight : sizes.bottomOverlayHeight,
                  right: isLandscapeLeft ? sizes.bottomOverlayHeight : sizes.topOverlayHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _CameraBlurOverlay(),
                      ),
                      Center(
                        child: CustomProgressIndicator(),
                      ),
                    ],
                  ),
                );
              }

              return SizedBox();
            },
          ),
          /// Top overlay
          Positioned(
            top: 0.0,
            bottom: 0.0,
            left: isLandscapeLeft ? 0.0 : null,
            right: isLandscapeLeft ? null : 0.0,
            width: sizes.topOverlayHeight,
            child: _CameraTopOverlay(
              type: widget.settings.type,
              orientation: Orientation.landscape,
            ),
          ),
          /// Bottom overlay
          Positioned(
            top: 0.0,
            bottom: 0.0,
            left: isLandscapeLeft ? null : 0.0,
            right: isLandscapeLeft ? 0.0 : null,
            width: sizes.bottomOverlayHeight,
            child: _CameraBottomOverlay(
              type: widget.settings.type,
              orientation: Orientation.landscape,
              offset: Offset(0.0, 0.0),
              onTakePicture: _onTakePictureHandler,
              onSendCodes: _onSendPhotoAndScansHandler,
            ),
          ),
        ]
        else ...[
          Positioned.fill(
            child: Container(
              color: ColorConstants.cameraBG(),
            ),
          ),
          Center(
            child: CustomProgressIndicator(),
          ),
        ],
      ],
    );
  }

  Widget _buildNoCamerasErrorPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Container(
            color: ColorConstants.cameraOverlayBG(),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: 'camera.no_cameras.label'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: ColorConstants.textWhite(),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
                SizedBox(height: 12.0),
                CustomText(
                  text: 'camera.no_cameras.description'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ColorConstants.textWhite().withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
                SizedBox(height: 20.0),
                CustomTextButton(
                  content: 'camera.no_cameras.button'.tr(),
                  onTap: _handlePermissionStatus,
                  isExpanded: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionErrorPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Container(
            color: ColorConstants.cameraOverlayBG(),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: 'camera.no_permission.label'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: ColorConstants.textWhite(),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
                SizedBox(height: 12.0),
                CustomText(
                  text: 'camera.no_permission.description'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ColorConstants.textWhite().withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
                SizedBox(height: 20.0),
                CustomTextButton(
                  content: 'camera.no_permission.button'.tr(),
                  onTap: _handlePermissionStatus,
                  isExpanded: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Container(
            color: ColorConstants.cameraOverlayBG(),
          ),
        ),
        Center(
          child: CustomProgressIndicator(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      options: ScaffoldWrapperOptions(
        safeArea: [SafeAreaType.all],
        withKeyboardResize: false,
        backgroundColor: ColorConstants.cameraBG(),
      ),
      child: BlocBuilder<CameraBloc, CameraState>(
        buildWhen: (prev, current) {
          return prev.controller != current.controller ||
              prev.isCameraReady != current.isCameraReady ||
              prev.isPermissionGranted != current.isPermissionGranted ||
              prev.isOrientationLocked != current.isOrientationLocked ||
              prev.isProcessing != current.isProcessing ||
              prev.isReady != current.isReady;
        },
        builder: (_, state) {
          if (!state.isReady) {
            return _buildLoadingPreview();
          }

          if (state.cameras.isEmpty) {
            return _buildNoCamerasErrorPreview();
          }

          if (widget.settings.type == CameraType.camera && !state.isCameraReady) {
            return _buildLoadingPreview();
          }

          if (!state.isPermissionGranted) {
            return _buildPermissionErrorPreview();
          }

          return AbsorbPointer(
            absorbing: state.isProcessing,
            child: ClipRRect(
              child: NativeDeviceOrientedWidget(
                key: ValueKey(state.isOrientationLocked),
                portrait: (_) {
                  return widget.settings.type == CameraType.camera
                      ? _buildCameraPreviewPortrait(state.controller)
                      : _buildScannerPreviewPortrait(state.controller, state.isCameraReady);
                },
                landscapeLeft: (_) {
                  return widget.settings.type == CameraType.camera
                      ? _buildCameraPreviewLandscape(state.controller, true)
                      : _buildScannerPreviewLandscape(state.controller, state.isCameraReady, true);
                },
                landscapeRight: (_) {
                  return widget.settings.type == CameraType.camera
                      ? _buildCameraPreviewLandscape(state.controller, false)
                      : _buildScannerPreviewLandscape(state.controller, state.isCameraReady, false);
                },
                fallback: (_) {
                  return widget.settings.type == CameraType.camera
                      ? _buildCameraPreviewPortrait(state.controller)
                      : _buildScannerPreviewPortrait(state.controller, state.isCameraReady);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CameraTopOverlay extends StatelessWidget {
  final CameraType type;
  final Orientation orientation;

  const _CameraTopOverlay({
    required this.type,
    required this.orientation,
  });

  void _onToggleFlashHandler() {
    locator<CameraBloc>().add(ToggleFlashMode_CameraEvent(
      type: type,
    ));
  }

  void _onToggleGridHandler() {
    locator<CameraBloc>().add(ToggleGridMode_CameraEvent());
  }

  void _onToggleOrientationHandler() {
    locator<CameraBloc>().add(ToggleOrientationMode_CameraEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      buildWhen: (prev, current) {
        return prev.selectedFlashMode != current.selectedFlashMode ||
            prev.isGridShowed != current.isGridShowed ||
            prev.isOrientationLocked != current.isOrientationLocked;
      },
      builder: (_, state) {
        return Container(
          padding: orientation == Orientation.portrait
              ? EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0)
              : EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
          color: ColorConstants.cameraBG(),
          child: Flex(
            direction: orientation == Orientation.portrait ? Axis.horizontal : Axis.vertical,
            children: [
              CustomIconButton(
                content: Icon(
                  switch (state.selectedFlashMode) {
                    FlashMode.off => type == CameraType.camera ? Icons.flash_off : Icons.flashlight_off,
                    FlashMode.auto => type == CameraType.camera ? Icons.flash_auto : Icons.flashlight_on,
                    FlashMode.always => type == CameraType.camera ? Icons.flash_auto : Icons.flashlight_on,
                    FlashMode.torch => Icons.flashlight_on,
                  },
                  size: 30.0,
                  color: ColorConstants.cameraButtonWhite(),
                ),
                onTap: _onToggleFlashHandler,
                options: CustomButtonOptions(
                  size: 48.0,
                  padding: EdgeInsets.zero,
                  splashColor: ColorConstants.cameraButtonWhite().withValues(alpha: 0.2),
                ),
              ),
              if (type == CameraType.camera) ...[
                SizedBox.square(dimension: 12.0),
                CustomIconButton(
                  content: Icon(
                    state.isGridShowed ? Icons.grid_on : Icons.grid_off,
                    size: 30.0,
                    color: ColorConstants.cameraButtonWhite(),
                  ),
                  onTap: _onToggleGridHandler,
                  options: CustomButtonOptions(
                    size: 48.0,
                    padding: EdgeInsets.zero,
                    splashColor: ColorConstants.cameraButtonWhite().withValues(alpha: 0.2),
                  ),
                ),
              ],
              Spacer(),
              if (locator<DeviceService>().orientations(context).length > 1) ...[
                SizedBox.square(dimension: 20.0),
                CustomIconButton(
                  content: Transform.rotate(
                    angle: state.isOrientationLocked ? 0.0 : math.pi / 4.0,
                    child: Icon(
                      state.isOrientationLocked ? Icons.sync_disabled : Icons.sync,
                      size: 30.0,
                      color: ColorConstants.cameraButtonWhite(),
                    ),
                  ),
                  onTap: _onToggleOrientationHandler,
                  options: CustomButtonOptions(
                    size: 48.0,
                    padding: EdgeInsets.zero,
                    splashColor: ColorConstants.cameraButtonWhite().withValues(alpha: 0.2),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CameraBottomOverlay extends StatelessWidget {
  final CameraType type;
  final Orientation orientation;
  final Offset offset;
  final VoidCallback onTakePicture;
  final VoidCallback onSendCodes;

  const _CameraBottomOverlay({
    required this.type,
    required this.orientation,
    required this.offset,
    required this.onTakePicture,
    required this.onSendCodes,
  });

  // void _onSwitchCameraHandler() {
  //   locator<CameraBloc>().add(SwitchCamera_CameraEvent(
  //     type: type,
  //   ));
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: orientation == Orientation.portrait
          ? EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0)
          : EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
      color: ColorConstants.cameraBG(),
      child: Transform.translate(
        offset: offset,
        child: LayoutBuilder(
          builder: (_, constraints) {
            final shortestSide = math.min(constraints.maxHeight, constraints.maxWidth);
            final actionButtonSize = (shortestSide * 0.8).clamp(80.0, 100.0);

            return Flex(
              direction: orientation == Orientation.portrait ? Axis.horizontal : Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (type == CameraType.camera) ...[
                  Spacer(),
                  // SizedBox.square(dimension: 48.0),
                  // Spacer(),
                  _CameraActionButton(
                    size: actionButtonSize,
                    onTap: onTakePicture,
                  ),
                  // Spacer(),
                  // CustomIconButton(
                  //   content: Icon(
                  //     Icons.cameraswitch,
                  //     size: 30.0,
                  //     color: ColorConstants.cameraButtonWhite(),
                  //   ),
                  //   onTap: _onSwitchCameraHandler,
                  //   options: CustomButtonOptions(
                  //     size: 48.0,
                  //     padding: EdgeInsets.zero,
                  //     splashColor: ColorConstants.cameraButtonWhite().withValues(alpha: 0.2),
                  //   ),
                  // ),
                  Spacer(),
                ],
                if (type == CameraType.scannerMany)
                  BlocBuilder<CameraBloc, CameraState>(
                    buildWhen: (prev, current) {
                      return prev.scannedCodes != current.scannedCodes;
                    },
                    builder: (_, state) {
                      if (state.scannedCodes.isNotEmpty) {
                        final buttonSize = shortestSide.clamp(80.0, 100.0) * 0.6;

                        return CustomIconButton(
                          content: SvgPicture.asset(
                            ImageConstants.icSuccess,
                            height: buttonSize * 0.6,
                            width: buttonSize * 0.6,
                            fit: BoxFit.fill,
                          ),
                          onTap: onSendCodes,
                          options: CustomButtonOptions(
                            size: buttonSize * 0.6,
                            padding: EdgeInsets.zero,
                          ),
                        );
                      }

                      return SizedBox();
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CameraActionButton extends StatefulWidget {
  final double size;
  final VoidCallback onTap;

  const _CameraActionButton({
    required this.size,
    required this.onTap,
  }) : assert(size >= 0.0);

  @override
  State<_CameraActionButton> createState() => _CameraActionButtonState();
}

class _CameraActionButtonState extends State<_CameraActionButton> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 50.0),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 50.0),
    ]).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapHandler() {
    _animationController.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _onTapHandler,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: widget.size,
                  width: widget.size,
                  decoration: BoxDecoration(
                    color: ColorConstants.cameraButtonWhite(),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  height: widget.size - 8.0,
                  width: widget.size - 8.0,
                  decoration: BoxDecoration(
                    color: ColorConstants.cameraButtonBlack(),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  height: widget.size - 16.0,
                  width: widget.size - 16.0,
                  decoration: BoxDecoration(
                    color: ColorConstants.cameraButtonWhite(),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CameraFocusArea extends StatefulWidget {
  const _CameraFocusArea({super.key});

  static double get calculateSize => 80.0;

  @override
  State<_CameraFocusArea> createState() => _CameraFocusAreaState();
}

class _CameraFocusAreaState extends State<_CameraFocusArea> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 20.0),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 80.0),
    ]).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _opacityAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20.0),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 10.0),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 10.0),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 10.0),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 10.0),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20.0),
    ]).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void startAnimation() {
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: _CameraFocusArea.calculateSize,
            width: _CameraFocusArea.calculateSize,
            decoration: BoxDecoration(
              border: Border.all(
                color: ColorConstants.cameraFocusArea().withValues(alpha: _opacityAnimation.value),
                width: 2.0,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CameraScannerArea extends StatefulWidget {
  const _CameraScannerArea({super.key});

  @override
  State<_CameraScannerArea> createState() => _CameraScannerAreaState();
}

class _CameraScannerAreaState extends State<_CameraScannerArea> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: ColorConstants.cameraScannerArea(), end: ColorConstants.cameraScannerSuccess()),
        weight: 20.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: ColorConstants.cameraScannerSuccess(), end: ColorConstants.cameraScannerSuccess()),
        weight: 60.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: ColorConstants.cameraScannerSuccess(), end: ColorConstants.cameraScannerArea()),
        weight: 20.0,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void startAnimation() {
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, child) {
        return Container(
          height: 200.0,
          width: 200.0,
          decoration: BoxDecoration(
            border: Border.all(color: _colorAnimation.value ?? ColorConstants.cameraScannerArea(), width: 3.0),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        );
      },
    );
  }
}

class _CameraGridOverlay extends StatelessWidget {
  final int columns, rows;
  final Color? color;
  final double strokeWidth;

  const _CameraGridOverlay({
    this.columns = 3,
    this.rows = 3,
    this.color,
    this.strokeWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (_, constraints) {
          final cellHeight = constraints.maxHeight / rows;
          final cellWidth = constraints.maxWidth / columns;

          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _CameraGridPainter(
              columns: columns,
              rows: rows,
              cellHeight: cellHeight,
              cellWidth: cellWidth,
              color: color ?? ColorConstants.cameraGridOverlay(),
              strokeWidth: strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _CameraGridPainter extends CustomPainter {
  final int columns, rows;
  final double cellHeight, cellWidth;
  final Color color;
  final double strokeWidth;

  const _CameraGridPainter({
    required this.rows,
    required this.columns,
    required this.color,
    required this.strokeWidth,
    required this.cellWidth,
    required this.cellHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < columns; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (int i = 1; i < rows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CameraCornersOverlay extends StatelessWidget {
  final double length, thickness;
  final double padding;
  final Color color;

  const _CameraCornersOverlay({
    this.length = 60.0,
    this.thickness = 4.0,
    this.padding = 0.0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (_, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _CameraCornerPainter(
              length: length,
              thickness: thickness,
              padding: padding,
              color: color,
            ),
          );
        },
      ),
    );
  }
}

class _CameraCornerPainter extends CustomPainter {
  final double length, thickness;
  final double padding;
  final Color color;

  const _CameraCornerPainter({
    required this.length,
    required this.thickness,
    required this.padding,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final left = padding;
    final top = padding;
    final right = size.width - padding;
    final bottom = size.height - padding;

    canvas.drawLine(
      Offset(left, top),
      Offset(left + length, top),
      paint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + length),
      paint,
    );

    canvas.drawLine(
      Offset(right, top),
      Offset(right - length, top),
      paint,
    );
    canvas.drawLine(
      Offset(right, top),
      Offset(right, top + length),
      paint,
    );

    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + length, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left, bottom - length),
      paint,
    );

    canvas.drawLine(
      Offset(right, bottom),
      Offset(right - length, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - length),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CameraBlurOverlay extends StatelessWidget {
  const _CameraBlurOverlay();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
      child: Container(color: ColorConstants.cameraBlurOverlay()),
    );
  }
}

class _PicturePreviewOverlay extends StatelessWidget {
  final XFile image;
  final Orientation orientation;
  final bool isLandscapeLeft;
  final Offset offset;
  final double borderSize;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const _PicturePreviewOverlay({
    required this.image,
    required this.orientation,
    required this.isLandscapeLeft,
    required this.offset,
    required this.borderSize,
    required this.onCancel,
    required this.onSubmit,
  });

  void _onToggleOrientationHandler() {
    locator<CameraBloc>().add(ToggleOrientationMode_CameraEvent());

  }

  Widget _buildTopOverlay(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      buildWhen: (prev, current) {
        return prev.isOrientationLocked != current.isOrientationLocked;
      },
      builder: (_, state) {
        return Container(
          padding: orientation == Orientation.portrait
              ? EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0)
              : EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
          color: ColorConstants.cameraBG(),
          child: Flex(
            direction: orientation == Orientation.portrait ? Axis.horizontal : Axis.vertical,
            children: [
              Spacer(),
              if (locator<DeviceService>().orientations(context).length > 1) ...[
                SizedBox.square(dimension: 20.0),
                CustomIconButton(
                  content: Transform.rotate(
                    angle: state.isOrientationLocked ? 0.0 : math.pi / 4.0,
                    child: Icon(
                      state.isOrientationLocked ? Icons.sync_disabled : Icons.sync,
                      size: 30.0,
                      color: ColorConstants.cameraButtonWhite(),
                    ),
                  ),
                  onTap: _onToggleOrientationHandler,
                  options: CustomButtonOptions(
                    size: 48.0,
                    padding: EdgeInsets.zero,
                    splashColor: ColorConstants.cameraButtonWhite().withValues(alpha: 0.2),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomOverlay() {
    return Container(
      padding: orientation == Orientation.portrait
          ? EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0)
          : EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
      color: ColorConstants.cameraBG(),
      child: Transform.translate(
        offset: offset,
        child: Flex(
          direction: orientation == Orientation.portrait ? Axis.horizontal : Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomIconButton(
              content: SvgPicture.asset(
                ImageConstants.icWarning,
                height: borderSize * 0.6,
                width: borderSize * 0.6,
                fit: BoxFit.fill,
              ),
              onTap: onCancel,
              options: CustomButtonOptions(
                size: borderSize * 0.6,
                padding: EdgeInsets.zero,
              ),
            ),
            CustomIconButton(
              content: SvgPicture.asset(
                ImageConstants.icSuccess,
                height: borderSize * 0.6,
                width: borderSize * 0.6,
                fit: BoxFit.fill,
              ),
              onTap: onSubmit,
              options: CustomButtonOptions(
                size: borderSize * 0.6,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    late Widget topOverlay;
    if (orientation == Orientation.portrait) {
      topOverlay = Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        height: borderSize,
        child: _buildTopOverlay(context),
      );
    } else {
      topOverlay = Positioned(
        top: 0.0,
        bottom: 0.0,
        left: isLandscapeLeft ? 0.0 : null,
        right: isLandscapeLeft ? null : 0.0,
        width: borderSize,
        child: _buildTopOverlay(context),
      );
    }

    late Widget bottomOverlay;
    if (orientation == Orientation.portrait) {
      bottomOverlay = Positioned(
        bottom: 0.0,
        left: 0.0,
        right: 0.0,
        height: borderSize,
        child: _buildBottomOverlay(),
      );
    } else {
      bottomOverlay = Positioned(
        top: 0.0,
        bottom: 0.0,
        left: isLandscapeLeft ? null : 0.0,
        right: isLandscapeLeft ? 0.0 : null,
        width: borderSize,
        child: _buildBottomOverlay(),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: ColorConstants.cameraBG(),
          ),
        ),
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: locator<CameraBloc>().state.controller!.value.aspectRatio,
            child: InteractiveViewer(
              maxScale: 5.0,
              minScale: 1.0,
              child: Image.file(
                File(image.path),
              ),
            ),
          ),
        ),
        topOverlay,
        bottomOverlay,
      ],
    );
  }
}