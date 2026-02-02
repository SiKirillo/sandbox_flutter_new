import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../common.dart';
import '../../../services/logger/logger_service.dart';

part 'in_app_notification_data.dart';
part 'in_app_notification_builder.dart';

class InAppNotificationProvider with ChangeNotifier {
  final _inAppNotifications = <InAppNotificationData>[];
  InAppNotificationData? get notification => _inAppNotifications.isNotEmpty ? _inAppNotifications[0] : null;

  /// When [withValidation] is true, skips adding only if the same message+type is already the current (first) notification.
  void addNotification(
    InAppNotificationData notification, {
    bool withValidation = false,
  }) {
    LoggerService.logTrace('InAppNotificationProvider -> addNotification()');
    if (withValidation) {
      if (this.notification?.message == notification.message && this.notification?.type == notification.type) {
        return;
      }
    }

    if (notification.isIgnored) {
      return;
    }

    InAppNotificationData formattedNotification = notification;
    if (formattedNotification.message == null || formattedNotification.message.toString().isEmpty) {
      LoggerService.logWarning('InAppNotificationProvider -> addNotification(): notification message is empty');
      formattedNotification = InAppNotificationData(
        id: formattedNotification.id,
        message: 'errors.other.none'.tr(),
        type: InAppNotificationType.warning,
      );
    }

    bool isNeedNotify = _inAppNotifications.isEmpty;
    if (formattedNotification.isImportant) {
      _inAppNotifications.clear();
      isNeedNotify = true;
    }

    _inAppNotifications.add(formattedNotification);
    if (isNeedNotify) {
      notifyListeners();
    }
  }

  void addNotifications(List<InAppNotificationData> notifications) {
    LoggerService.logTrace('InAppNotificationProvider -> addNotifications()');
    for (final notification in notifications) {
      addNotification(notification);
    }
  }

  void removeNotification(InAppNotificationData notification) {
    LoggerService.logTrace('InAppNotificationProvider -> removeNotification()');
    _inAppNotifications.remove(notification);
    notifyListeners();
  }

  void clear() {
    LoggerService.logTrace('InAppNotificationProvider -> clear()');
    _inAppNotifications.clear();
    notifyListeners();
  }
}
