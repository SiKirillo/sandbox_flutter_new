part of '../../common.dart';

enum CustomButtonVariant {
  filled,
  outline,
  small,
}

enum CustomButtonType {
  blue,
  white,
  appbar,
  attention,
}

/// Styled button with [content], [onTap], [variant], and [CustomButtonOptions]; supports disabled/expanded.
class CustomButton extends StatelessWidget {
  final dynamic content;
  final VoidCallback onTap;
  final CustomButtonOptions options;
  final CustomButtonVariant variant;
  final bool isExpanded;
  final bool isDisabled;

  const CustomButton({
    super.key,
    required this.content,
    required this.onTap,
    this.options = const CustomButtonOptions(),
    this.variant = CustomButtonVariant.filled,
    this.isExpanded = true,
    this.isDisabled = false,
  }) : assert(content is Widget || content is String);

  BoxDecoration _getButtonDecoration(BuildContext context) {
    if (options.decoration != null) return options.decoration!;

    switch (variant) {
      case CustomButtonVariant.filled:
        return BoxDecoration(
          color: options.color ?? (isDisabled
              ? ColorConstants.buttonDisable()
              : ColorConstants.button(options.type)),
          borderRadius: options.borderRadius,
        );

      case CustomButtonVariant.outline:
        return BoxDecoration(
          color: isDisabled ? ColorConstants.buttonTextDisable() : null,
          border: isDisabled
              ? null
              : Border.all(
                  color: options.color ?? ColorConstants.buttonOutline(),
                ),
          borderRadius: options.borderRadius,
        );

      case CustomButtonVariant.small:
        return BoxDecoration(
          color: options.color ?? (isDisabled
              ? ColorConstants.buttonSmallDisable()
              : ColorConstants.buttonSmall(options.type)),
          borderRadius: options.borderRadius,
        );
    }
  }

  Color _getSplashColor() {
    switch (variant) {
      case CustomButtonVariant.filled:
        return options.splashColor ?? ColorConstants.buttonSplash(options.type);
      
      case CustomButtonVariant.outline:
        return options.splashColor ?? ColorConstants.buttonOutlineSplash();
      
      case CustomButtonVariant.small:
        return options.splashColor ?? ColorConstants.buttonSmallSplash(options.type);
    }
  }

  Widget _buildContentWidget(BuildContext context) {
    if (content is String) {
      final Color contentColor;
      switch (variant) {
        case CustomButtonVariant.filled:
          contentColor = options.color ?? (isDisabled
              ? ColorConstants.buttonContentDisable()
              : ColorConstants.buttonContent(options.type));
          break;

        case CustomButtonVariant.outline:
          contentColor = isDisabled
              ? ColorConstants.buttonContentDisable()
              : options.color ?? ColorConstants.buttonContentBlue();
          break;
          
        case CustomButtonVariant.small:
          contentColor = isDisabled
              ? ColorConstants.buttonContentDisable()
              : ColorConstants.buttonSmallContent(options.type);
          break;
      }

      final textStyle = options.textStyle ?? Theme.of(context).textTheme.displayMedium?.copyWith(
        color: contentColor,
        fontSize: variant == CustomButtonVariant.small ? 13.0 : null,
        height: variant == CustomButtonVariant.small ? 16.0 / 13.0 : null,
      );

      return CustomText(
        text: content,
        style: textStyle,
        maxLines: 1,
        isVerticalCentered: false,
      );
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isDisabled,
      child: Container(
        height: options.height,
        width: isExpanded ? double.maxFinite : options.width,
        constraints: options.constraints,
        decoration: _getButtonDecoration(context),
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: options.padding,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: _getSplashColor(),
            shape: RoundedRectangleBorder(
              borderRadius: options.borderRadius,
            ),
          ),
          child: _buildContentWidget(context),
        ),
      ),
    );
  }
}

/// Thin wrapper for outline style; delegates to [CustomButton] with [CustomButtonVariant.outline].
class CustomOutlineButton extends StatelessWidget {
  final dynamic content;
  final VoidCallback onTap;
  final CustomButtonOptions options;
  final bool isExpanded;
  final bool isDisabled;

  const CustomOutlineButton({
    super.key,
    required this.content,
    required this.onTap,
    this.options = const CustomButtonOptions(),
    this.isExpanded = true,
    this.isDisabled = false,
  }) : assert(content is Widget || content is String);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      content: content,
      onTap: onTap,
      options: options,
      variant: CustomButtonVariant.outline,
      isExpanded: isExpanded,
      isDisabled: isDisabled,
    );
  }
}

/// Thin wrapper for small style; delegates to [CustomButton] with [CustomButtonVariant.small].
class CustomSmallButton extends StatelessWidget {
  final dynamic content;
  final VoidCallback onTap;
  final CustomButtonOptions options;
  final CustomButtonType type;
  final bool isExpanded;
  final bool isDisabled;

  const CustomSmallButton({
    super.key,
    required this.content,
    required this.onTap,
    this.options = const CustomButtonOptions(
      height: 32.0,
      padding: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    this.type = CustomButtonType.white,
    this.isExpanded = false,
    this.isDisabled = false,
  }) : assert(content is Widget || content is String);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      content: content,
      onTap: onTap,
      options: CustomButtonOptions(
        height: options.height,
        width: options.width,
        constraints: options.constraints,
        padding: options.padding,
        borderRadius: options.borderRadius,
        decoration: options.decoration,
        color: options.color,
        splashColor: options.splashColor,
        textStyle: options.textStyle,
        type: type,
      ),
      variant: CustomButtonVariant.small,
      isExpanded: isExpanded,
      isDisabled: isDisabled,
    );
  }
}

class CustomButtonOptions {
  final double? height, width;
  final double? size;
  final BoxConstraints? constraints;
  final EdgeInsets padding;
  final BorderRadiusGeometry borderRadius;
  final BoxDecoration? decoration;
  final Color? color, splashColor;
  final TextStyle? textStyle;
  final CustomButtonType type;

  const CustomButtonOptions({
    this.height = SizeConstants.defaultButtonHeight,
    this.width,
    this.size = SizeConstants.defaultButtonIconSize,
    this.constraints,
    this.padding = const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
    this.decoration,
    this.color,
    this.splashColor,
    this.textStyle,
    this.type = CustomButtonType.blue,
  });
}