import 'package:flutter/material.dart';

class BouncyGestureDetector extends StatefulWidget {
  final void Function()? onTap;
  final void Function()? onSecondaryTap;
  final void Function()? onLongPress;
  final void Function(TapDownDetails d)? onTapDown;
  final void Function(DragUpdateDetails d)? onPanUpdate;
  final void Function(DragEndDetails d)? onPanEnd;
  final void Function(DragDownDetails d)? onPanDown;
  final GlobalKey? key;

  final Widget child;

  final Duration duration;

  final bool disableAnimationForClick;

  final double hoverScale;
  final double clickScale;

  final HitTestBehavior? behavior;

  const BouncyGestureDetector(
      {required this.child,
      this.onTap,
      this.onLongPress,
      this.key,
      this.behavior,
      this.onPanUpdate,
      this.onPanDown,
      this.onPanEnd,
      this.onSecondaryTap,
      this.onTapDown,
      this.duration = const Duration(milliseconds: 200),
      this.disableAnimationForClick = false,
      this.hoverScale = .45,
      this.clickScale = .55});

  @override
  _BouncyGestureDetectorState createState() => _BouncyGestureDetectorState();
}

class _BouncyGestureDetectorState extends State<BouncyGestureDetector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller =
        new AnimationController(vsync: this, duration: widget.duration)
          ..value = .5;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void animateTo(double scale) {
    _controller.animateTo(scale,
        curve: Curves.easeOutCubic, duration: Duration(milliseconds: 200));
  }

  bool mouseHovered = false;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 2).animate(_controller),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (e) {
          animateTo(widget.hoverScale);
          mouseHovered = true;
        },
        onExit: (e) {
          animateTo(.5);
          mouseHovered = false;
        },
        child: GestureDetector(
          behavior: widget.behavior,
          key: widget.key,
          onTap: widget.onTap,
          onSecondaryTap: widget.onSecondaryTap,
          onLongPress: widget.onLongPress,
          onTapDown: (e) {
            if (!widget.disableAnimationForClick) animateTo(widget.clickScale);
            if (widget.onTapDown != null) {
              widget.onTapDown!(e);
            }
          },
          onTapUp: (e) {
            if (!widget.disableAnimationForClick) {
              if (_controller.value < .5.lerp(widget.clickScale, .5))
                _controller.value = .5.lerp(widget.clickScale, .5);
              animateTo(mouseHovered ? widget.hoverScale : .5);
            }
          },
          onPanStart: (e) {},
          onPanDown: (e) {
            if (widget.onPanDown != null) widget.onPanDown!(e);
          },
          onPanEnd: (e) {
            if (widget.onPanEnd != null) widget.onPanEnd!(e);
          },
          onPanUpdate: (e) {
            if (widget.onPanUpdate != null) widget.onPanUpdate!(e);
          },
          onPanCancel: () => animateTo(mouseHovered ? widget.hoverScale : .5),
          child: widget.child,
        ),
      ),
    );
  }
}

extension DoubleLerp on double {
  double lerp(double second, double percent) {
    double iPercent = 1 - percent;
    return this * iPercent + second * percent;
  }
}
