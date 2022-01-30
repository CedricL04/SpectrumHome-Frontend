import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spectrum_home2/main.dart' as theme;

class OverlayPageBase extends StatefulWidget {
  final Widget child;
  final bool blur;
  final bool slideIn;
  final Offset startOffset;

  const OverlayPageBase(
      {required this.child,
      Key? key,
      this.blur = true,
      this.slideIn = false,
      this.startOffset = const Offset(-1, 0)})
      : super(key: key);

  @override
  _OverlayPageBaseState createState() => _OverlayPageBaseState();
}

class _OverlayPageBaseState extends State<OverlayPageBase>
    with SingleTickerProviderStateMixin {
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (ModalRoute.of(context)?.animation != null)
      ModalRoute.of(context)!.animation!.addListener(() {
        if (mounted) setState(() {});
      });
  }

  late AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool small = theme.isSmall(context);
    Widget content = GestureDetector(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          child: widget.child,
          onTap: () {},
        ),
      ),
      onTap: () => Navigator.maybePop(context),
    );

    double blur = ModalRoute.of(context) == null
        ? 25
        : Tween<double>(begin: 1, end: 25)
            .animate(CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!, curve: theme.curve))
            .value;

    if (widget.slideIn) {
      CurvedAnimation anim =
          CurvedAnimation(parent: _controller, curve: theme.curve);

      content = WillPopScope(
        onWillPop: () async {
          _controller.reverse();
          return true;
        },
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            //just as a placeholder because [BackdropFilter] doesn't render the blur if its child is not visible
            color: Color(0x01000000),
            child: FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position:
                    Tween<Offset>(begin: widget.startOffset, end: Offset.zero)
                        .animate(anim),
                child: ScaleTransition(
                  scale: Tween<double>(begin: small ? .8 : .9, end: 1)
                      .animate(anim),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!widget.blur) return content;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: content,
    );
  }
}
