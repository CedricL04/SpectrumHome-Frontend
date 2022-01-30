import 'package:flutter/material.dart';

class OffsetAnimation extends StatefulWidget {
  final Duration offset;
  final Duration popOffset;
  final Duration duration;

  final Widget Function(BuildContext context, AnimationController controller)
      builder;

  const OffsetAnimation(
      {Key? key,
      required this.offset,
      required this.builder,
      this.popOffset = Duration.zero,
      this.duration = const Duration(milliseconds: 300)})
      : super(key: key);

  @override
  _OffsetAnimationState createState() => _OffsetAnimationState();
}

class _OffsetAnimationState extends State<OffsetAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: widget.duration);
    super.initState();
    Future.delayed(widget.offset).then((value) {
      try {
        _controller.forward();
      } catch (e) {
        //fmo
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: widget.builder(context, _controller),
        onWillPop: () async {
          _controller.reverse();
          await Future.delayed(widget.popOffset);
          return true;
        });
  }
}
