part of '../common.dart';

/// A dot page indicator showing the current page [index] of [count].
class CustomPageIndicator extends StatelessWidget {
  final int index;
  final int count;

  const CustomPageIndicator({
    super.key,
    required this.index,
    required this.count,
  })  : assert(index >= 0 && count >= 0),
        assert(index < count || count == 0);

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const SizedBox.shrink();
    }
    
    return AnimatedSmoothIndicator(
      activeIndex: index,
      count: count,
      effect: ExpandingDotsEffect(
        expansionFactor: 2.5,
        dotHeight: 6.0,
        dotWidth: 6.0,
        spacing: 8.0,
        radius: 6.0,
        activeDotColor: ColorConstants.pageIndicatorActive(),
        dotColor: ColorConstants.pageIndicatorDisable(),
      ),
    );
  }
}
