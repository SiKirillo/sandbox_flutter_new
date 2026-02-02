part of '../_common/common.dart';

/// Misc shared constants: animation duration, delay, and default scroll physics.
class OtherConstants {
  static const defaultAnimationDuration = Duration(milliseconds: 300);
  static const defaultDelayDuration = Duration(milliseconds: 50);
  static const defaultScrollPhysics = BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}