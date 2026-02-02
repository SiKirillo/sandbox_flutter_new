part of 'in_app_slider_provider.dart';

class InAppSlider extends StatefulWidget {
  final Object? sliderKey;
  final PageController? controller;
  final Function(int)? onPageChanged;
  final InAppSliderOptions options;
  final int? itemCount;
  final Widget Function(BuildContext, int)? itemBuilder;
  final List<Widget>? children;

  const InAppSlider({
    super.key,
    this.sliderKey,
    this.controller,
    this.onPageChanged,
    this.options = const InAppSliderOptions(),
    required this.children,
  })  : itemBuilder = null,
        itemCount = null;

  const InAppSlider.builder({
    super.key,
    this.sliderKey,
    this.controller,
    this.onPageChanged,
    this.options = const InAppSliderOptions(),
    required this.itemCount,
    required this.itemBuilder,
  })  : children = null;

  @override
  State<InAppSlider> createState() => _InAppSliderState();
}

class _InAppSliderState extends State<InAppSlider> {
  late final PageController _controller;
  bool get _isBuilder => widget.itemBuilder != null;
  int get _length => _isBuilder ? widget.itemCount! : widget.children!.length;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PageController();
    locator<InAppSliderProvider>().init(
      sliderKey: widget.sliderKey,
      initialIndex: _controller.initialPage,
      length: _length,
    );
  }

  @override
  void didUpdateWidget(covariant InAppSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newLength = _length;
    if (newLength != locator<InAppSliderProvider>().lengthOf(widget.sliderKey)) {
      locator<InAppSliderProvider>().update(sliderKey: widget.sliderKey, length: newLength);
    }
  }

  @override
  void dispose() {
    locator<InAppSliderProvider>().remove(widget.sliderKey);
    super.dispose();
  }

  void _onPageChangedHandler(int index) {
    locator<InAppSliderProvider>().update(sliderKey: widget.sliderKey, index: index);

    if (widget.onPageChanged != null) {
      widget.onPageChanged!(index);
    }
  }

  void _onHorizontalDragUpdateHandler(DragUpdateDetails details) {
    if (widget.options.physics is! NeverScrollableScrollPhysics) {
      return;
    }

    if (details.delta.dx >= 8.0) {
      _controller.previousPage(
        duration: widget.options.duration,
        curve: widget.options.animation,

      );
    } else if (details.delta.dx <= -8.0) {
      _controller.nextPage(
        duration: widget.options.duration,
        curve: widget.options.animation,
      );
    }
  }

  Widget _buildPageViewWidget() {
    if (_isBuilder) {
      return ExpandablePageView.builder(
        controller: _controller,
        onPageChanged: _onPageChangedHandler,
        animationCurve: widget.options.animation,
        physics: widget.options.physics,
        alignment: widget.options.alignment,
        itemCount: widget.itemCount!,
        itemBuilder: (context, index) {
          return Container(
            constraints: widget.options.constraints,
            margin: widget.options.margin,
            child: widget.itemBuilder!(context, index),
          );
        },
      );
    }

    return ExpandablePageView(
      controller: _controller,
      onPageChanged: _onPageChangedHandler,
      animationCurve: widget.options.animation,
      physics: widget.options.physics,
      alignment: widget.options.alignment,
      children: widget.children!.map((child) {
        return Container(
          constraints: widget.options.constraints,
          margin: widget.options.margin,
          child: child,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onHorizontalDragUpdate: _onHorizontalDragUpdateHandler,
          child: _buildPageViewWidget(),
        ),
        if (widget.options.opacityColor != null) ...[
          Positioned(
            top: 0.0,
            bottom: 0.0,
            left: 0.0,
            width: 20.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.options.opacityColor!,
                    widget.options.opacityColor!.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            bottom: 0.0,
            right: 0.0,
            width: 20.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.options.opacityColor!.withValues(alpha: 0.0),
                    widget.options.opacityColor!,
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class InAppSliderOptions {
  final Duration duration;
  final Curve animation;
  final ScrollPhysics physics;
  final Alignment alignment;
  final BoxConstraints? constraints;
  final EdgeInsets margin;
  final Color? opacityColor;

  const InAppSliderOptions({
    this.duration = const Duration(milliseconds: 300),
    this.animation = Curves.easeInOut,
    this.physics = const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
    this.alignment = Alignment.topCenter,
    this.constraints,
    this.margin = EdgeInsets.zero,
    this.opacityColor,
  });
}