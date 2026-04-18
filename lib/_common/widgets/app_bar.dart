part of '../common.dart';

/// This is custom implementation of basic [AppBar] with morphing animation
/// Based on [MorphingAppBar] widget, to learn more visit https://pub.dev/packages/swipeable_page_route
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic content;
  final Widget? leading;
  final Widget? actions;
  final Widget? bottomContent;
  final VoidCallback? onGoBack;
  @override
  final Size preferredSize;
  final CustomAppBarOptions options;
  final bool isDisabled;

  const CustomAppBar({
    super.key,
    this.content,
    this.leading,
    this.actions,
    this.bottomContent,
    this.onGoBack,
    this.preferredSize = const Size.fromHeight(SizeConstants.defaultAppBarSize),
    this.options = const CustomAppBarOptions(),
    this.isDisabled = false,
  }) : assert(content is String || content is Widget || content == null);

  static Widget buildContentWidget(
    dynamic content, {
    required BuildContext context,
    CustomAppBarOptions? options,
  }) {
    assert(content is String || content is Widget || content == null);
    if (content is String) {
      return CustomText(
        text: content,
        style: options?.contentStyle ?? Theme.of(context).appBarTheme.titleTextStyle,
        textAlign: options?.textAlign ?? TextAlign.start,
        maxLines: 2,
        isVerticalCentered: false,
      );
    }

    return content ?? SizedBox.shrink();
  }

  static Widget buildLeadingWidget(
    Widget leading, {
    required BuildContext context,
    VoidCallback? onBackCallback,
    CustomAppBarOptions? options,
  }) {
    if (options?.withBackButton == true) {
      return CustomIconButton(
        content: SvgPicture.asset(
          ImageConstants.arrowLeft,
          colorFilter: options?.iconColor != null ? ColorFilter.mode(options!.iconColor!, BlendMode.srcIn) : null,
        ),
        onTap: onBackCallback ?? () => Navigator.of(context).pop(),
        options: CustomButtonOptions(
          size: 40.0,
          padding: EdgeInsets.zero,
        ),
      );
    }

    if (options?.withCloseButton == true) {
      return CustomIconButton(
        content: SvgPicture.asset(
          ImageConstants.close,
          colorFilter: options?.iconColor != null ? ColorFilter.mode(options!.iconColor!, BlendMode.srcIn) : null,
        ),
        onTap: onBackCallback ?? () => Navigator.of(context).pop(),
        options: CustomButtonOptions(
          size: 24.0,
          padding: EdgeInsets.zero,
        ),
      );
    }

    return leading;
  }

  @override
  Widget build(BuildContext context) {
    /// You can use MorphingAppBar after plugin fix compilation with flutter 3.35+ with heroTag: options.heroTag
    return PreferredSize(
      preferredSize: preferredSize,
      child: OpacityWrapper(
        isOpaque: isDisabled,
        child: AbsorbPointer(
          absorbing: isDisabled,
          child: AppBar(
            // heroTag: options.heroTag,
            backgroundColor: options.backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
            shadowColor: options.shadowColor ?? Theme.of(context).appBarTheme.shadowColor,
            elevation: options.withElevation ? Theme.of(context).appBarTheme.elevation : 0.0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            toolbarHeight: preferredSize.height,
            titleSpacing: 0.0,
            title: Padding(
              padding: options.padding,
              child: Row(
                mainAxisAlignment: options.mainAxisAlignment,
                crossAxisAlignment: options.crossAxisAlignment,
                children: [
                  if (leading != null)
                    CustomAppBar.buildLeadingWidget(
                      leading!,
                      context: context,
                      onBackCallback: onGoBack,
                      options: options,
                    ),
                  Expanded(
                    child: CustomAppBar.buildContentWidget(
                      content,
                      context: context,
                      options: options,
                    ),
                  ),
                  if (actions != null) actions!,
                ],
              ),
            ),
            bottom: bottomContent != null
                ? PreferredSize(
                    preferredSize: Size.zero,
                    child: bottomContent!,
                  )
                : null,
            shape: options.withDivider
                ? Border(
                    bottom: BorderSide(
                      color: ColorConstants.appBarDivider(),
                      width: 1.0,
                    ),
                  )
                : RoundedRectangleBorder(
                    borderRadius: options.borderRadius ?? BorderRadius.zero,
                  ),
          ),
        ),
      ),
    );
  }
}

/// This is custom implementation of basic [SliverAppBar] with morphing animation
/// Used only in some scrollable widgets like [ScrollableWrapper]
/// Based on [MorphingSliverAppBar] widget, to learn more visit https://pub.dev/packages/swipeable_page_route
class CustomSliverAppBar extends StatefulWidget implements PreferredSizeWidget {
  final dynamic content;
  final Widget? leading;
  final Widget? actions;
  final VoidCallback? onGoBack;
  @override
  final Size preferredSize;
  final CustomAppBarOptions options;

  /// You can use automatic responsive size calculator instead of setting const [flexibleSize] value
  /// Works well with static sized widgets, but can be some problematic with animated widgets
  /// If not null then the automatic calculator will work
  final GlobalKey? flexibleContentKey;
  final FlexibleSpaceBar? flexibleContent;
  final double? flexibleSize;
  final bool isDisabled;

  const CustomSliverAppBar({
    super.key,
    this.content,
    this.leading,
    this.actions,
    this.onGoBack,
    this.preferredSize = const Size.fromHeight(SizeConstants.defaultAppBarSize),
    this.options = const CustomAppBarOptions(),
    this.flexibleContentKey,
    this.flexibleContent,
    this.flexibleSize,
    this.isDisabled = false,
  }) : assert(content is String || content is Widget || content == null);

  @override
  State<CustomSliverAppBar> createState() => _CustomSliverAppBarState();
}

class _CustomSliverAppBarState extends State<CustomSliverAppBar> with WidgetsBindingObserver {
  double _flexibleSize = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.flexibleContentKey != null && widget.flexibleContent != null) {
      WidgetsBinding.instance.addPostFrameCallback(_handleFlexibleContentSize);
    }
  }

  @override
  void didUpdateWidget(covariant CustomSliverAppBar oldWidget) {
    if (widget.flexibleContentKey != null && widget.flexibleContent != null) {
      WidgetsBinding.instance.addPostFrameCallback(_handleFlexibleContentSize);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleFlexibleContentSize(void _) {
    final flexibleContext = widget.flexibleContentKey?.currentContext;
    if (flexibleContext == null) {
      return;
    }

    final size = flexibleContext.size;
    if (size == null) {
      return;
    }

    final previousSize = _flexibleSize;
    final newSize = size.height;

    if (mounted && previousSize != newSize) {
      setState(() {
        _flexibleSize = newSize;
      });

      WidgetsBinding.instance.addPostFrameCallback(_handleFlexibleContentSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    /// You can use MorphingSliverAppBar after plugin fix compilation with flutter 3.35+ with heroTag: options.heroTag
    return PreferredSize(
      preferredSize: widget.preferredSize,
      child: SliverAppBar(
        // heroTag: widget.options.heroTag,
        backgroundColor: widget.options.backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
        shadowColor: widget.options.shadowColor ?? Theme.of(context).appBarTheme.shadowColor,
        elevation: widget.options.withElevation ? Theme.of(context).appBarTheme.elevation : 0.0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        pinned: true,
        titleSpacing: 0.0,
        toolbarHeight: widget.preferredSize.height,
        collapsedHeight: widget.preferredSize.height,
        expandedHeight: widget.preferredSize.height + (widget.flexibleSize ?? _flexibleSize),
        title: Container(
          height: widget.preferredSize.height,
          padding: EdgeInsets.fromLTRB(
            widget.options.padding.left + ResponsiveWrapper.responsivePadding(context),
            widget.options.padding.top,
            widget.options.padding.right + ResponsiveWrapper.responsivePadding(context),
            widget.options.padding.bottom,
          ),
          decoration: BoxDecoration(
            borderRadius: widget.options.borderRadius,
            color: widget.options.backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
          ),
          child: Row(
            mainAxisAlignment: widget.options.mainAxisAlignment,
            crossAxisAlignment: widget.options.crossAxisAlignment,
            children: [
              if (widget.leading != null)
                CustomAppBar.buildLeadingWidget(
                  widget.leading!,
                  context: context,
                  onBackCallback: widget.onGoBack,
                  options: widget.options,
                ),
              Expanded(
                child: CustomAppBar.buildContentWidget(
                  widget.content,
                  context: context,
                  options: widget.options,
                ),
              ),
              if (widget.actions != null) widget.actions!,
            ],
          ),
        ),
        flexibleSpace: widget.flexibleContent != null
            ? SafeArea(
                child: ClipRRect(
                  borderRadius: widget.options.borderRadius ?? BorderRadius.zero,
                  child: Stack(
                    children: [
                      widget.flexibleContent!,
                      Positioned(
                        top: widget.preferredSize.height - 16.0,
                        left: 0.0,
                        right: 0.0,
                        child: CustomScrollOpacityGradient(
                          size: 4.0 + 16.0,
                          colors: [
                            widget.options.backgroundColor,
                            widget.options.backgroundColor?.withValues(alpha: 0.0),
                          ],
                          stops: [0.8, 1.0],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        shape: widget.options.withDivider
            ? Border(
                bottom: BorderSide(
                  color: ColorConstants.appBarDivider(),
                  width: 1.0,
                ),
              )
            : RoundedRectangleBorder(
                borderRadius: widget.options.borderRadius ?? BorderRadius.zero,
              ),
      ),
    );
  }
}

class CustomAppBarOptions {
  /// Reserved for future MorphingAppBar use; not passed to [AppBar] / [SliverAppBar] yet.
  final String heroTag;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final TextStyle? contentStyle;
  final TextAlign textAlign;

  /// When both are true, [buildLeadingWidget] shows back button (first check wins).
  final bool withBackButton;
  final bool withCloseButton;
  final bool withElevation;
  final bool withDivider;
  final Color? backgroundColor, shadowColor;
  final Color? iconColor;

  const CustomAppBarOptions({
    this.heroTag = 'MorphingAppBar',
    this.padding = const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
    this.borderRadius,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.contentStyle,
    this.textAlign = TextAlign.center,
    this.withBackButton = false,
    this.withCloseButton = false,
    this.withElevation = true,
    this.withDivider = false,
    this.backgroundColor,
    this.shadowColor,
    this.iconColor,
  });
}
