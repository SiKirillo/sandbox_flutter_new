part of '../common.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Size size;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = const Size(32.0, 18.0),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height,
      width: size.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: ColorConstants.switchActiveThumb(),
          activeTrackColor: ColorConstants.switchActiveBG(),
          inactiveThumbColor: ColorConstants.switchInactiveThumb(),
          inactiveTrackColor: ColorConstants.switchInactiveBG(),
          thumbIcon: WidgetStateProperty.all(null),
          trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return ColorConstants.switchActiveBG();
            }

            return ColorConstants.switchInactiveBG();
          }),
          trackOutlineWidth: WidgetStateProperty.all(0.0),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
