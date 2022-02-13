import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/panels/panel_device.dart';
import 'package:spectrum_home2/utils/widgets/offset_animation.dart';

class PieMenuWrapper extends StatefulWidget {
  final String name;
  final List<PieMenuEntry> entries;
  final Widget child;

  const PieMenuWrapper(
      {required this.name,
      required this.entries,
      required this.child,
      Key? key})
      : super(key: key);

  @override
  State<PieMenuWrapper> createState() => _PieMenuWrapperState();
}

class _PieMenuWrapperState extends State<PieMenuWrapper> {
  OverlayEntry? _overlayEntry;
  GlobalKey _key = GlobalKey();
  GlobalKey<_PieOverlayState> _overlayKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onPanStart: (e) {
        if (Overlay.of(context) != null) {
          _overlayEntry = _createOverlayEntry();
          Overlay.of(context)!.insert(_overlayEntry!);
        }
      },
      onPanEnd: (e) {
        if (_overlayEntry != null) {
          _overlayKey.currentState!.animateBack();
          int sel = _overlayKey.currentState!.selected;
          if (sel > -1 && sel < widget.entries.length) {
            widget.entries[sel].onSelect();
          }
          Future.delayed(Duration(milliseconds: 100))
              .then((value) => _overlayEntry!.remove());
        }
      },
      onPanUpdate: (e) {
        if (_overlayEntry != null && _overlayKey.currentState != null)
          _overlayKey.currentState!.onDrag(e);
      },
      child: widget.child,
    );
  }

  OverlayEntry _createOverlayEntry() {
    Rect b = _key.globalPaintBounds!;

    double centerX = b.left + b.width / 2;
    double centerY = b.top + b.height / 2;

    return OverlayEntry(
      builder: (context) => PieOverlay(
        key: _overlayKey,
        center: Offset(centerX, centerY),
        entries: widget.entries,
        name: widget.name,
      ),
    );
  }
}

class PieOverlay extends StatefulWidget {
  final Offset center;
  final String name;
  final List<PieMenuEntry> entries;
  const PieOverlay(
      {required this.center,
      required this.entries,
      required this.name,
      Key? key})
      : super(key: key);

  @override
  _PieOverlayState createState() => _PieOverlayState();
}

class _PieOverlayState extends State<PieOverlay>
    with SingleTickerProviderStateMixin {
  final double itemRad = 30;
  final double itemDistance = 150;
  final double dragDistance = 10000; // (itemDistance/2)²

  int selected = -1;
  late AnimationController _backgroundController;

  @override
  void initState() {
    _backgroundController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
        reverseDuration: Duration(milliseconds: 100));
    super.initState();
    _backgroundController.forward();
    _backgroundController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void animateBack() {
    _backgroundController.reverse();
  }

  void onDrag(DragUpdateDetails e) {
    Offset relative = e.globalPosition - widget.center;

    if (relative.distanceSquared > dragDistance) {
      double angle = math.atan2(relative.dy, relative.dx);
      angle = (angle * 180 / math.pi + 360) % 360;

      int length = widget.entries.length;

      int sel = (angle / 360 * length).round() % length;
      if (selected != sel) {
        setState(() {
          selected = sel;
        });
      }
    } else if (selected != -1) {
      setState(() {
        selected = -1;
      });
    }
  }

  final Duration _duration = Duration(milliseconds: 100);

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    double itemCenterX = widget.center.dx - itemRad;
    double itemCenterY = widget.center.dy - itemRad;

    double co = itemRad + itemDistance + 20; //center offset (20 = padding)

    itemCenterX = itemCenterX.clamp(co, screen.width - co).toDouble();
    itemCenterY = itemCenterY.clamp(co, screen.height - co).toDouble();

    int itemCount = widget.entries.length;
    return Material(
      color: Color.lerp(
          Colors.transparent, Colors.black, _backgroundController.value * .5),
      child: Stack(children: [
        Positioned(
            left: widget.center.dx - itemDistance / 2,
            top: widget.center.dy - 25,
            child: Container(
              width: itemDistance,
              height: 50,
              child: Center(
                  child: Text(
                widget.name,
                style: theme.h1,
              )),
            )),
        ...List.generate(itemCount, (index) {
          double angle = 360 / itemCount * index;
          angle *= math.pi / 180;

          double relX = math.cos(angle) * itemDistance;
          double relY = math.sin(angle) * itemDistance;

          PieMenuEntry entry = widget.entries[index];

          return Positioned(
              left: itemCenterX + relX,
              top: itemCenterY + relY,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OffsetAnimation(
                    offset: Duration(milliseconds: (index * 300) ~/ itemCount),
                    builder: (context, controller) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                            curve: Interval(0, .3), parent: controller),
                        child: SlideTransition(
                          position: Tween(
                                  begin: Offset(
                                      -relX / itemRad / 2, -relY / itemRad / 2),
                                  end: Offset.zero)
                              .animate(CurvedAnimation(
                                  parent: controller,
                                  curve: Curves.easeOutBack)),
                          child: AnimatedScale(
                            duration: _duration,
                            scale: selected == index ? 1.2 : 1,
                            child: AnimatedContainer(
                              duration: _duration,
                              width: itemRad * 2,
                              height: itemRad * 2,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selected == index
                                      ? theme.elevation2
                                      : theme.elevation1,
                                  boxShadow: theme.elevation1shadow),
                              child: Center(
                                child: entry.child,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (selected == index)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        entry.text,
                        style: theme.h4,
                      ),
                    )
                ],
              ));
        })
      ]),
    );
  }
}

class PieMenuEntry {
  final String text;
  final Widget child;
  final void Function() onSelect;

  const PieMenuEntry(this.text, this.child, this.onSelect);
}
