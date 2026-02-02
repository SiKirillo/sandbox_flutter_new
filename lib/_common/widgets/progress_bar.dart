part of '../common.dart';

/// A horizontal progress bar with gradient fill and configurable [ratio].
class CustomProgressBar extends StatelessWidget {
  final double ratio;
  final List<Color> gradientColors;
  final Color backgroundColor;

  const CustomProgressBar({
    super.key,
    required this.ratio,
    required this.gradientColors,
    required this.backgroundColor,
  }) : assert(gradientColors.length > 0);

  double get _ratio => math.min(math.max(ratio, 0.0), 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        color: backgroundColor,
      ),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final progressWidth = math.max(constraints.maxWidth * _ratio, 4.0);
          final hasMinSize = progressWidth > 4.0;

          return Row(
            children: [
              Container(
                width: progressWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  color: hasMinSize ? null : gradientColors.first,
                  gradient: hasMinSize ? LinearGradient(
                    colors: gradientColors,
                  ) : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
