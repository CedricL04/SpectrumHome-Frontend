import 'package:flutter/material.dart';

class HoverAnimation extends StatefulWidget {
  final Widget child;

  const HoverAnimation({required this.child, Key? key}) : super(key: key);

  @override
  _HoverAnimationState createState() => _HoverAnimationState();
}

class _HoverAnimationState extends State<HoverAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: ScaleTransition(
          scale: Tween<double>(begin: 1, end: 0.98).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
          child: widget.child),
      onExit: (e) => _controller.reverse(),
      onEnter: (e) => _controller.forward(),
    );
  }
}
