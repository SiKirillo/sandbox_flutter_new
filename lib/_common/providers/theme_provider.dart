part of '../common.dart';

/// Holds current theme mode and brightness; [isLight] drives [ColorConstants] and UI.
class ThemeProvider with ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  Brightness _brightness = Brightness.light;

  ThemeMode get mode => _mode;
  Brightness get brightness => _brightness;
  bool get isLight => _mode == ThemeMode.light || (_mode == ThemeMode.system && _brightness == Brightness.light);

  void init({ThemeMode? mode, Brightness? brightness}) {
    LoggerService.logTrace('ThemeProvider -> init(mode: $mode, brightness: $brightness)');
    _mode = mode ?? _mode;
    _brightness = brightness ?? _brightness;
  }

  void update({ThemeMode? mode, Brightness? brightness}) {
    LoggerService.logTrace('ThemeProvider -> update(mode: $mode, brightness: $brightness)');
    bool icChanged = false;
    if (mode != null && _mode != mode) {
      _mode = mode;
      icChanged = true;
    }

    if (brightness != null && _brightness != brightness) {
      _brightness = brightness;
      icChanged = true;
    }

    if (icChanged) notifyListeners();
  }
}
