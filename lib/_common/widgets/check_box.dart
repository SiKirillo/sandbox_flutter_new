part of '../common.dart';

class CustomCheckBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onTap;
  final bool isProcessing;
  final CustomCheckBoxOptions options;

  const CustomCheckBox({
    super.key,
    required this.value,
    required this.onTap,
    this.isProcessing = false,
    this.options = const CustomCheckBoxOptions(),
  });

  void _onPressedHandler() {
    if (isProcessing) return;
    onTap(!value);
  }

  BoxDecoration _borderDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(options.borderRadius),
      border: Border.all(
        color: options.borderColor ?? ColorConstants.checkboxBorder(),
        width: options.borderWidth,
      ),
    );
  }

  Widget _buildCheckbox() {
    if (isProcessing) {
      return Container(
        key: const ValueKey('isProcessing'),
        decoration: _borderDecoration(),
        child: Center(
          child: CustomProgressIndicator.simple(
            size: 10.0,
            color: options.tappedColor ?? ColorConstants.checkboxActive(),
          ),
        ),
      );
    }

    if (value) {
      return Container(
        key: const ValueKey('isTapped'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(options.borderRadius),
          color: options.tappedColor ?? ColorConstants.checkboxActive(),
        ),
        child: Center(
          child: Icon(
            Icons.check,
            size: options.checkIconSize,
            color: options.checkColor ?? ColorConstants.checkboxCheck(),
          ),
        ),
      );
    }

    return Container(
      key: const ValueKey('!isTapped'),
      decoration: _borderDecoration(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      enabled: !isProcessing,
      child: InkWell(
        onTap: _onPressedHandler,
        borderRadius: BorderRadius.circular(options.borderRadius),
        child: Ink(
          height: options.size,
          width: options.size,
          padding: options.padding,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildCheckbox(),
          ),
        ),
      ),
    );
  }
}

class CustomCheckBoxOptions {
  final double size;
  final EdgeInsets padding;
  final double borderRadius;
  final double borderWidth;
  final double checkIconSize;
  final Color? tappedColor;
  final Color? borderColor;
  final Color? checkColor;

  const CustomCheckBoxOptions({
    this.size = 24.0,
    this.padding = const EdgeInsets.all(2.0),
    this.borderRadius = 4.0,
    this.borderWidth = 2.0,
    this.checkIconSize = 14.0,
    this.tappedColor,
    this.borderColor,
    this.checkColor,
  });
}