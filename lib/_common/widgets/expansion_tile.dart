part of '../common.dart';

class CustomExpansionTile extends StatefulWidget {
  final dynamic label;
  final dynamic content;
  final ValueChanged<bool>? onTap;
  final CustomExpansionTileOptions options;
  final bool isExpanded;
  final bool isDisabled;

  const CustomExpansionTile({
    super.key,
    required this.label,
    required this.content,
    this.onTap,
    this.options = const CustomExpansionTileOptions(),
    this.isExpanded = false,
    this.isDisabled = false,
  })  : assert(label is Widget || label is String),
        assert(content is Widget || content is String);

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final CurvedAnimation _heightFactor;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.options.animationDuration,
      vsync: this,
    );

    _heightFactor = CurvedAnimation(
      parent: _animationController.drive(Tween<double>(begin: 0.0, end: 1.0)),
      curve: Curves.easeIn,
    );

    final state = PageStorage.maybeOf(context)?.readState(context);
    _isExpanded = state is bool ? state : widget.isExpanded;
    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant CustomExpansionTile oldWidget) {
    if (widget.isExpanded != _isExpanded) {
      _onToggleExpansionHandler(withCallback: false);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heightFactor.dispose();
    super.dispose();
  }

  void _onToggleExpansionHandler({bool withCallback = true}) {
    _isExpanded = !_isExpanded;
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }

    setState(() {});
    PageStorage.maybeOf(context)?.writeState(context, _isExpanded);

    if (withCallback) {
      widget.onTap?.call(_isExpanded);
    }
  }

  Widget _buildLabelWidget() {
    if (widget.label is String) {
      final theme = Theme.of(context).textTheme;
      final textStyle = widget.options.buttonTextStyle ??
          theme.displayMedium ??
          theme.bodyLarge ??
          const TextStyle();
      return CustomText(
        text: widget.label,
        style: textStyle,
        maxLines: 100,
        isVerticalCentered: false,
      );
    }

    return widget.label;
  }

  Widget _buildContentWidget() {
    if (widget.content is String) {
      final theme = Theme.of(context).textTheme;
      final textStyle = widget.options.contentTextStyle ??
          theme.displayMedium ??
          theme.bodyLarge ??
          const TextStyle();
      return CustomText(
        text: widget.content,
        style: textStyle,
        maxLines: 100,
        isVerticalCentered: false,
      );
    }

    return widget.content;
  }

  Widget _buildExpansionButton(BuildContext context, Widget? child) {
    return Stack(
      children: [
        Positioned.fill(
          top: widget.options.contentBorderRadius,
          child: Container(
            decoration: BoxDecoration(
              color: widget.options.contentColor ?? ColorConstants.cardBG(),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(widget.options.contentBorderRadius),
                bottomRight: Radius.circular(widget.options.contentBorderRadius),
              ),
            ),
          ),
        ),
        ScrollableWrapper(
          options: ScrollableWrapperOptions(
            type: ScrollableWrapperType.dialog,
            padding: EdgeInsets.zero,
            isScrollEnabled: false,
          ),
          child: Column(
            children: [
              CustomButton(
                content: _buildLabelWidget(),
                onTap: _onToggleExpansionHandler,
                options: CustomButtonOptions(
                  height: null,
                  constraints: BoxConstraints(
                    minHeight: SizeConstants.defaultButtonHeight,
                  ),
                  padding: widget.options.buttonPadding,
                  color: widget.options.buttonColor,
                ),
                isDisabled: widget.isDisabled,
              ),
              ClipRRect(
                child: Align(
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHiddenDescription(bool isClosed) {
    return Offstage(
      offstage: isClosed,
      child: TickerMode(
        enabled: !isClosed,
        child: Padding(
          padding: widget.options.contentPadding,
          child: Row(
            children: [
              Flexible(
                child: _buildContentWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isClosed = !_isExpanded && _animationController.isDismissed;
    final isShouldRemove = isClosed && !widget.options.withMaintainState;
    final hiddenWidget = _buildHiddenDescription(isClosed);

    return AnimatedBuilder(
      animation: _animationController.view,
      builder: _buildExpansionButton,
      child: isShouldRemove ? null : hiddenWidget,
    );
  }
}

class CustomExpansionTileOptions {
  final bool withMaintainState;
  final Duration animationDuration;
  final double contentBorderRadius;
  final EdgeInsets buttonPadding;
  final EdgeInsets contentPadding;
  final Color? buttonColor;
  final Color? contentColor;
  final TextStyle? buttonTextStyle;
  final TextStyle? contentTextStyle;

  const CustomExpansionTileOptions({
    this.withMaintainState = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.contentBorderRadius = 12.0,
    this.buttonPadding = const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
    this.contentPadding = const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
    this.buttonColor,
    this.contentColor,
    this.buttonTextStyle,
    this.contentTextStyle,
  });
}