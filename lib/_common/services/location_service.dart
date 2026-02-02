part of '../common.dart';

/// Wraps [location] package: checks/requests location service and gets current position.
class LocationService {
  final _location = location.Location();

  Future<bool> isLocationServiceGranted() async {
    return _location.serviceEnabled();
  }

  Future<bool> requestLocationServicePermission() async {
    final isEnabled = await _location.serviceEnabled();
    return isEnabled || await _location.requestService();
  }

  Future<location.LocationData?> getLocationData() async {
    if (!await locator<PermissionService>().isLocationGranted()) {
      final isGranted = await locator<PermissionService>().requestLocationPermission();
      if (!isGranted) return null;
      await Future.delayed(OtherConstants.defaultAnimationDuration);
    }

    return await _location.getLocation();
  }
}