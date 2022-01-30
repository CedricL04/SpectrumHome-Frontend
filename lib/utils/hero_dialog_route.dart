import 'package:flutter/material.dart';

class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute(
      {required this.builder, this.millis = 500, this.transparent = true})
      : super();

  final int millis;
  final bool transparent;
  final WidgetBuilder builder;

  @override
  bool get opaque => !transparent;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: millis);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black.withOpacity(.5);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  String get barrierLabel => "";
}
