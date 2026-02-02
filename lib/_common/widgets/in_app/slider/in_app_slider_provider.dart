import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';

import '../../../common.dart';
import '../../../services/logger/logger_service.dart';

part 'in_app_slider_builder.dart';

/// Default key for the "global" slider when [sliderKey] is not set.
/// Use a [sliderKey] when multiple sliders are on screen so each has its own index/length.
const Object _defaultSliderKey = _DefaultSliderKey();

class _DefaultSliderKey {
  const _DefaultSliderKey();
}

class InAppSliderProvider with ChangeNotifier {
  final Map<Object?, ({int index, int length})> _state = {};

  /// Index for the default (global) slider. Use [indexOf] when using [sliderKey].
  int get index => indexOf(_defaultSliderKey);
  /// Length for the default (global) slider. Use [lengthOf] when using [sliderKey].
  int get length => lengthOf(_defaultSliderKey);

  int indexOf(Object? key) => _state[key ?? _defaultSliderKey]?.index ?? 0;
  int lengthOf(Object? key) => _state[key ?? _defaultSliderKey]?.length ?? 0;

  void init({Object? sliderKey, int initialIndex = 0, int length = 1}) {
    assert(initialIndex >= 0 && length >= 1);

    final key = sliderKey ?? _defaultSliderKey;
    _state[key] = (index: initialIndex, length: length);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void update({Object? sliderKey, int? index, int? length}) {
    LoggerService.logTrace('InAppSliderProvider -> update(sliderKey: $sliderKey, index: $index, length: $length)');
    if (index == null && length == null) {
      return;
    }

    final key = sliderKey ?? _defaultSliderKey;
    final current = _state[key] ?? (index: 0, length: 0);

    final isIndexChanged = index != null && current.index != index;
    final isLengthChanged = length != null && current.length != length;
    if (!isIndexChanged && !isLengthChanged) {
      return;
    }

    _state[key] = (
      index: index ?? current.index,
      length: length ?? current.length,
    );
    notifyListeners();
  }

  /// Removes state for [sliderKey]. Called from [InAppSlider] dispose.
  void remove(Object? sliderKey) {
    if (_state.remove(sliderKey ?? _defaultSliderKey) != null) {
      notifyListeners();
    }
  }
}
