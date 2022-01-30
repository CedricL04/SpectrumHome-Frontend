import 'package:flutter/material.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/utils/widgets/hover_animation.dart';

class Panel extends StatelessWidget {
  final Widget child;
  final BoxDecoration? decoration;
  final bool smallPanel;

  const Panel(
      {required this.child, this.decoration, this.smallPanel = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool small = theme.isSmall(context);
    return HoverAnimation(
      child: Container(
        clipBehavior: Clip.antiAlias,
        width: smallPanel ? 150 : (small ? double.infinity : 200),
        height: smallPanel ? 70 : (small ? 120 : 200),
        child: child,
        decoration: decoration ??
            BoxDecoration(
                borderRadius: theme.borderRadius,
                color: theme.elevation1,
                boxShadow: theme.elevation1shadow),
      ),
    );
  }
}
