import 'package:flutter/material.dart';
import 'package:spectrum_home2/dialogs/bouncy_gesture_detector.dart';
import 'package:spectrum_home2/dialogs/overlay_page_base.dart';
import 'dart:math' as math;
import 'package:spectrum_home2/main.dart' as style;
import 'package:spectrum_home2/utils/widgets/offset_animation.dart';
import 'package:spectrum_home2/utils/data/synced_value.dart';
import 'package:spectrum_home2/utils/utils.dart';

class SimpleColorPickerPopup extends StatefulWidget {
  final Color start;
  final Function(Color)? onUpdate;
  final Function(Color)? onUpdateFinished;
  final Offset? position;

  const SimpleColorPickerPopup(
      {Key? key,
      this.start = const Color(0xFF00FF00),
      this.onUpdate,
      this.onUpdateFinished,
      this.position})
      : super(key: key);

  @override
  _SimpleColorPickerPopupState createState() => _SimpleColorPickerPopupState();
}

class _SimpleColorPickerPopupState extends State<SimpleColorPickerPopup>
    with SingleTickerProviderStateMixin {
  late Offset hsKnob;
  late Offset vKnob;

  int colorsPerPage = 8;

  late double pickerWidth;
  late double presetSize;
  late double presetDistance;

  late double width;
  late double rad;
  late double pickerRad;

  Color? color;
  late double value;

  late int pageCount;

  late AnimationController _controller;

  bool init = true;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    pickerWidth = 350;
    presetSize = 50;
    presetDistance = 40;

    width = pickerWidth + presetDistance * 2 + presetSize * 2;
    rad = width / 2;
    pickerRad = pickerWidth / 2;

    _setColor(widget.start);

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _callColorUpadte() {
    if (widget.onUpdate != null) widget.onUpdate!(_getColor());
  }

  void _callColorFinishedUpdate() {
    if (widget.onUpdateFinished != null) widget.onUpdateFinished!(_getColor());
  }

  void _setColor(Color color) {
    this.color = color;
    HSVColor hsv = HSVColor.fromColor(color);

    hsKnob = _radialToGrid(hsv.hue, hsv.saturation);

    value = hsv.value;

    vKnob = _radialToGrid((value * 360) * 3 / 4 - 45, 1);
  }

  Color _getColor() {
    Offset hs = _gridToRadial(hsKnob.dx, hsKnob.dy, 1);
    return HSVColor.fromAHSV(1, hs.dx % 360, hs.dy, value).toColor();
  }

  void _updateColor(Offset offset) {
    setState(() {
      Offset rad = _gridToRadial((offset.dx - pickerRad + 35),
          (offset.dy - pickerRad + 35), pickerRad - 35);
      double dy = rad.dy.clamp(0, 1).toDouble();
      HSVColor hsv = HSVColor.fromAHSV(1, (rad.dx % 360), dy, value);

      hsKnob = _radialToGrid(hsv.hue, hsv.saturation);
      _callColorUpadte();
    });
  }

  void _changePage(int delta) {
    if (mounted) {
      _controller.forward().then((value) {
        if (mounted) {
          setState(() {
            page = (page + delta).clamp(0, pageCount);
          });
          _controller.reverse();
        }
      });
    }
  }

  void _updateValue(Offset offset) {
    setState(() {
      Offset rad = _gridToRadial((offset.dx - pickerRad - 10),
          (offset.dy - pickerRad + 10), pickerRad - 10);
      double dx = ((rad.dx % 360).toDouble() / 360).toDouble();
      value = dx * 4 / 3 - (45 / 360);
      dx = (dx + .25) % 1;
      dx = dx.clamp(.125, .875);

      value = (dx - .125) * 4 / 3;

      vKnob = _radialToGrid(((dx - .25) * 360), 1);
      _callColorUpadte();
    });
  }

  int page = 0;

  SyncedValue<List> colors = SyncedValue("colors");

  @override
  Widget build(BuildContext context) {
    List<Color> presets =
        colors.vaule!.map((e) => Utils.stringToColor(e)).toList();

    pageCount = (presets.length / colorsPerPage).ceil() - 1;

    bool init = this.init;
    this.init = false;

    int val = (value * 255).toInt();
    int pageColors = colorsPerPage -
        (colorsPerPage - presets.length + colorsPerPage * page).clamp(0, 8);
    return WillPopScope(
      onWillPop: () async {
        _controller.forward();
        return true;
      },
      child: OverlayPageBase(
        slideIn: true,
        startOffset: Offset(0, 1),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Container(
                width: width,
                height: width,
                child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ScaleTransition(
                        scale: Tween<double>(begin: 1, end: .5).animate(
                            CurvedAnimation(
                                parent: _controller, curve: style.curve)),
                        child: Stack(
                            children: List.generate(pageColors, (index) {
                          double v = rad - presetSize / 2;
                          double posX = v +
                              v * math.sin(math.pi * 2 / colorsPerPage * index);
                          double posY = v -
                              v * math.cos(math.pi * 2 / colorsPerPage * index);
                          double animX = -(posX - v) / presetSize;
                          double animY = -(posY - v) / presetSize;

                          Color presetColor =
                              presets[page * colorsPerPage + index];

                          return Positioned(
                            left: posX,
                            top: posY,
                            child: OffsetAnimation(
                              builder: (context, _controller) =>
                                  SlideTransition(
                                position: Tween<Offset>(
                                        begin: init
                                            ? Offset(animX, animY)
                                            : Offset.zero,
                                        end: Offset.zero)
                                    .animate(CurvedAnimation(
                                        parent: _controller,
                                        curve: style.curve)),
                                child: PresetField(
                                  presetSize: presetSize,
                                  color: presetColor,
                                  callback: () {
                                    setState(() {
                                      _setColor(presetColor);
                                      _callColorFinishedUpdate();
                                    });
                                  },
                                ),
                              ),
                              offset: Duration(milliseconds: 150 + 50 * index),
                            ),
                          );
                        })),
                      )
                    ]..addAll([
                        Center(
                            child: SizedBox(
                          height: pickerWidth,
                          child: GestureDetector(
                            onTapUp: (d) => _callColorFinishedUpdate(),
                            onTapDown: (d) {
                              _updateValue(d.localPosition);
                            },
                            onPanUpdate: (d) {
                              _updateValue(d.localPosition);
                            },
                            onPanCancel: () => _callColorFinishedUpdate(),
                            onPanEnd: (d) => _callColorFinishedUpdate(),
                            child: Container(
                              width: pickerWidth,
                              height: pickerWidth,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                          "assets/images/valuewheel.png")),
                                  shape: BoxShape.circle),
                            ),
                          ),
                        )),
                        Center(
                          child: GestureDetector(
                            onTapUp: (d) => _callColorFinishedUpdate(),
                            onTapDown: (d) {
                              _updateColor(d.localPosition);
                            },
                            onPanUpdate: (d) {
                              _updateColor(d.localPosition);
                            },
                            onPanCancel: () => _callColorFinishedUpdate(),
                            onPanEnd: (d) => _callColorFinishedUpdate(),
                            child: Container(
                              width: pickerWidth - 70,
                              height: pickerWidth - 70,
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(1 - value)),
                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                          "assets/images/colorwheel.png"))),
                            ),
                          ),
                        ),
                        //arrow left
                        Positioned(
                          bottom: presetSize + presetDistance - 25,
                          left: presetSize + presetDistance + pickerRad - 100,
                          child: BouncyGestureDetector(
                              onTap: () => _changePage(-1),
                              child: Icon(
                                Icons.keyboard_arrow_left,
                                color: style.foregroundColor
                                    .withOpacity(page == 0 ? .3 : 1),
                                size: 50,
                              )),
                        ),
                        //arrow right
                        Positioned(
                          bottom: presetSize + presetDistance - 25,
                          right: presetSize + presetDistance + pickerRad - 100,
                          child: BouncyGestureDetector(
                              onTap: () => _changePage(1),
                              child: Icon(
                                Icons.keyboard_arrow_right,
                                color: style.foregroundColor
                                    .withOpacity(page >= pageCount ? .3 : 1),
                                size: 50,
                              )),
                        ),
                        //text
                        Positioned(
                            left: 0,
                            right: 0,
                            bottom: presetSize + presetDistance - 25,
                            child: SizedBox(
                                height: 50,
                                child: Center(
                                  child: Text(
                                    "${page + 1}",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ))),
                        //hue sat knob
                        Positioned(
                            left: presetSize +
                                presetDistance -
                                10 +
                                pickerRad +
                                (pickerRad - 35) * hsKnob.dx,
                            top: presetSize +
                                presetDistance -
                                10 +
                                pickerRad +
                                (pickerRad - 35) * hsKnob.dy,
                            child: Knob(
                              getColor: () => color,
                            )),
                        //val knob
                        Positioned(
                            left: presetSize +
                                presetDistance -
                                10 +
                                pickerRad +
                                (pickerRad - 10) * vKnob.dx,
                            top: presetSize +
                                presetDistance -
                                10 +
                                pickerRad +
                                (pickerRad - 10) * vKnob.dy,
                            child: Knob(
                                getColor: () =>
                                    Color.fromARGB(255, val, val, val)))
                      ])),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Offset _radialToGrid(double angle, double rad) {
    double radians = angle * math.pi / 180;
    double x = -math.cos(radians) * rad;
    double y = -math.sin(radians) * rad;

    return Offset(x, y);
  }

  Offset _gridToRadial(double x, double y, double radius) {
    return Offset(math.atan2(-x, y) * 180 / math.pi - 90,
        math.sqrt(x * x + y * y) / radius);
  }
}

class PresetField extends StatelessWidget {
  const PresetField({
    Key? key,
    required this.presetSize,
    required this.color,
    required this.callback,
  }) : super(key: key);

  final double? presetSize;
  final Color color;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    return BouncyGestureDetector(
      onTap: callback,
      child: Container(
        width: presetSize,
        height: presetSize,
        decoration:
            BoxDecoration(borderRadius: style.borderRadius, color: color),
      ),
    );
  }
}

class Knob extends StatelessWidget {
  final Color? Function() getColor;

  const Knob({required this.getColor, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: style.foregroundColor, width: 3),
            boxShadow: [
              BoxShadow(
                  color: style.backgroundColor.withOpacity(.3), blurRadius: 10)
            ]),
      ),
    );
  }
}
