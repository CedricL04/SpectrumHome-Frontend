import 'package:flutter/material.dart';
import 'package:spectrum_home2/dialogs/bouncy_gesture_detector.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/utils/data/fill_data.dart';

class FillItem extends StatefulWidget {
  final FillData fill;
  final void Function(FillData color)? onTap;
  const FillItem({required this.fill, this.onTap, Key? key}) : super(key: key);

  @override
  _FillItemState createState() => _FillItemState();
}

class _FillItemState extends State<FillItem>
    with SingleTickerProviderStateMixin {
  Offset offset = Offset.zero;
  Offset? _startOffset;

  late AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BouncyGestureDetector(
      onTap: () {
        if (widget.onTap != null) widget.onTap!(widget.fill);
      },
      child: Draggable<FillData>(
        data: widget.fill,
        dragAnchorStrategy: (draggable, context, position) => Offset.zero,
        feedback: Transform.translate(
          offset: Offset(-10, -10),
          child: Container(
              width: 20,
              height: 20,
              decoration: widget.fill.createDecoration(
                  borderRadius:
                      theme.borderRadius - BorderRadius.all(Radius.circular(5)),
                  shadow: theme.elevation1shadow)),
        ),
        onDragUpdate: (e) {
          if (_startOffset == null) _startOffset = e.globalPosition;
          setState(() {
            offset = (e.globalPosition - _startOffset!) / 3;
          });
        },
        onDragEnd: (e) {
          setState(() {
            offset = Offset.zero;
            _startOffset = null;
          });
        },
        child: SizedBox(
          width: 60,
          height: 60,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
                  curve: Curves.easeOutBack, parent: _controller)),
              child: Container(
                decoration: widget.fill.createDecoration(
                    borderRadius: theme.borderRadius -
                        BorderRadius.all(Radius.circular(5)),
                    shadow: theme.elevation1shadow),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
