part of '../_common/common.dart';

/// Shared layout sizes (buttons, app bar, inputs) and breakpoints for mobile/tablet/web.
class SizeConstants {
  static const defaultButtonHeight = 56.0;
  static const defaultButtonIconSize = 24.0;
  static const defaultAppBarSize = 64.0;
  static const defaultNavigationBarSize = 58.0;
  static const defaultTextInputPadding = EdgeInsets.fromLTRB(16.0, 19.0, 16.0, 19.0);
  static const defaultTextInputOtpPadding = EdgeInsets.fromLTRB(16.0, 23.0, 12.0, 15.0);
  static const defaultTextInputSearchPadding = EdgeInsets.fromLTRB(16.0, 15.0, 16.0, 15.0);

  static const defaultSmallDeviceSize = 375.0;
  static const defaultTabletDeviceSize = 540.0;
  static const defaultWebDeviceSize = 850.0;

  /// True if screen width is below [defaultTabletDeviceSize].
  static bool isMobile({required BuildContext context}) {
    return MediaQuery.sizeOf(context).width < defaultTabletDeviceSize;
  }

  static bool isTablet({required BuildContext context}) {
    return MediaQuery.sizeOf(context).width >= defaultTabletDeviceSize;
  }

  /// True if tablet and device is in portrait.
  static bool isTabletPortrait({required BuildContext context}) {
    return isTablet(context: context) && MediaQuery.orientationOf(context) == Orientation.portrait;
  }

  /// True if tablet and device is in landscape.
  static bool isTabletLandscape({required BuildContext context}) {
    return isTablet(context: context) && MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  /// True if screen width is at least [defaultWebDeviceSize].
  static bool isWeb({required BuildContext context}) {
    return MediaQuery.sizeOf(context).width >= defaultWebDeviceSize;
  }
}
