part of '../_common/common.dart';

/// Asset paths for icons/images and [precacheAssets] for preloading.
class ImageConstants {
  static const svgPrefix = '.svg';

  static bool get _isLightTheme => locator<ThemeProvider>().isLight;

  /// Preloads SVG and image assets used in the app to avoid first-frame jank.
  static void precacheAssets(BuildContext context) {
    final svgLoaders = <SvgAssetLoader>[
      // const SvgAssetLoader(icBackground),
    ];

    for (final loader in svgLoaders) {
      svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
    }

    // precacheImage(AssetImage('something'), context);
  }

  /// Service
  static const alertTriangle = 'assets/icons/alert-triangle.svg';
  static const arrowLeft = 'assets/icons/arrow-left.svg';
  static const arrowRight = 'assets/icons/arrow-right.svg';
  static const calendar = 'assets/icons/calendar.svg';
  static const check = 'assets/icons/check.svg';
  static const chevronDown = 'assets/icons/chevron-down.svg';
  static const chevronRight = 'assets/icons/chevron-right.svg';
  static const circle = 'assets/icons/circle.svg';
  static const close = 'assets/icons/close.svg';
  static const closeCircle = 'assets/icons/close-circle.svg';
  static const eye = 'assets/icons/eye.svg';
  static const eyeOff = 'assets/icons/eye-off.svg';
  static const fileText = 'assets/icons/file-text.svg';
  static const globe = 'assets/icons/globe.svg';
  static const info = 'assets/icons/info.svg';
  static const mail = 'assets/icons/mail.svg';
  static const minus = 'assets/icons/minus.svg';
  static const plus = 'assets/icons/plus.svg';
  static const search = 'assets/icons/search.svg';
  static const settings = 'assets/icons/settings.svg';
  static const slidersHorizontal = 'assets/icons/sliders-horizontal.svg';
  static const success = 'assets/icons/success.svg';
  static const trash = 'assets/icons/trash.svg';
  static const trendingUp = 'assets/icons/trending-up.svg';
  static const user = 'assets/icons/user.svg';
}
