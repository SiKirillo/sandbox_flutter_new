part of '../_common/common.dart';

/// GoRouter configuration: routes (splash, camera, logger), [key], and [configs].
/// Use [defaultSwipeablePageBuilder] for swipe-back page construction.
class AppRouter {
  static GlobalKey<NavigatorState> get key => _rootRouterKey;
  static final _rootRouterKey = GlobalKey<NavigatorState>();
  static final _routingConfig = ValueNotifier<RoutingConfig>(_initialConfig);
  static final _initialConfig = RoutingConfig(
    routes: [
      /// Splash
      GoRoute(
        path: SplashScreen.routePath,
        name: SplashScreen.routePath,
        pageBuilder: (_, state) => defaultSwipeablePageBuilder(
          state.pageKey,
          SplashScreen.routePath,
          SplashScreen(),
        ),
      ),
      /// Camera
      GoRoute(
        path: CameraScreen.routePath,
        name: CameraScreen.routePath,
        pageBuilder: (_, state) => defaultSwipeablePageBuilder(
          state.pageKey,
          CameraScreen.routePath,
          CameraScreen(settings: (state.extra as CameraSettingsOptions?) ?? CameraSettingsOptions()),
        ),
      ),
      GoRoute(
        path: CameraPicturePreviewScreen.routePath,
        name: CameraPicturePreviewScreen.routePath,
        pageBuilder: (_, state) => defaultSwipeablePageBuilder(
          state.pageKey,
          CameraPicturePreviewScreen.routePath,
          CameraPicturePreviewScreen(
            data: state.extra as CameraPreviewEntity
          ),
        ),
      ),
      /// Logger
      GoRoute(
        path: LoggerScreen.routePath,
        name: LoggerScreen.routePath,
        pageBuilder: (_, state) => defaultSwipeablePageBuilder(
          state.pageKey,
          LoggerScreen.routePath,
          LoggerScreen(),
        ),
      ),
    ],
  );

  static final configs = GoRouter.routingConfig(
    navigatorKey: _rootRouterKey,
    initialLocation: SplashScreen.routePath,
    observers: [
      LoggerService.talkerRoute,
    ],
    routingConfig: _routingConfig,
  );

  /// Builds a [SwipeablePage] for [screen]; [canSwipe] enables edge-swipe back (disabled on web).
  static SwipeablePage defaultSwipeablePageBuilder(
    LocalKey? key,
    String? path,
    Widget screen, {
    bool canSwipe = true,
  }) {
    return SwipeablePage(
      key: key,
      name: path,
      canSwipe: canSwipe && !kIsWeb,
      canOnlySwipeFromEdge: true,
      builder: (context) => screen,
    );
  }
}
