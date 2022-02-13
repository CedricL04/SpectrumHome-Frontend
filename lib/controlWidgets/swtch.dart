import 'package:flutter/material.dart';
import 'package:spectrum_home2/dialogs/bouncy_gesture_detector.dart';
import 'package:spectrum_home2/main.dart' as theme;

class ToggleSwitch extends StatelessWidget {
  final bool state;
  final void Function(bool state) onChange;
  final Color? active;

  const ToggleSwitch(
      {required this.state, required this.onChange, Key? key, this.active})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color def = theme.elevation2.withOpacity(.5);

    return BouncyGestureDetector(
      disableAnimationForClick: true,
      onTap: () => onChange(!state),
      child: AnimatedContainer(
        width: 58,
        height: 28,
        curve: theme.curve,
        decoration: BoxDecoration(
            color: state ? active ?? def : def,
            borderRadius: theme.borderRadius),
        duration: Duration(milliseconds: 200),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
                top: -1,
                left: state ? 29 : -1,
                duration: Duration(milliseconds: 200),
                curve: theme.curve,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: theme.elevation2,
                      borderRadius: theme.borderRadius,
                      boxShadow: theme.elevation1shadow),
                ))
          ],
        ),
      ),
    );
  }
}
