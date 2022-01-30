import 'package:flutter/material.dart';
import 'package:spectrum_home2/utils/data/fill_data.dart';

class BrightnessSlider extends StatefulWidget {
  final FillData fill;
  final double startVaule;

  final Function(double i)? update;
  final Function(double i)? updateFinished;

  const BrightnessSlider(
      {required this.fill,
      this.update,
      this.updateFinished,
      this.startVaule = 1,
      Key? key})
      : super(key: key);

  @override
  BrightnessSliderState createState() => BrightnessSliderState();
}

class BrightnessSliderState extends State<BrightnessSlider> {
  late double value;
  bool dragging = false;

  @override
  void initState() {
    value = widget.startVaule;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = Duration(milliseconds: 100);

    List<double> partBoundings = widget.fill.partBoundings;

    return LayoutBuilder(builder: (context, bounds) {
      return GestureDetector(
        onTapDown: (e) => setState(() {
          value = ((e.localPosition.dx) / (bounds.maxWidth - 5))
              .clamp(0, 1)
              .toDouble();
          if (widget.update != null) widget.update!(value);
        }),
        onHorizontalDragUpdate: (e) => setState(() {
          value = ((e.localPosition.dx) / (bounds.maxWidth - 5))
              .clamp(0, 1)
              .toDouble();
          if (widget.update != null) widget.update!(value);
        }),
        onHorizontalDragEnd: (e) {
          if (widget.updateFinished != null) widget.updateFinished!(value);
          setState(() {
            dragging = false;
          });
        },
        onHorizontalDragStart: (e) => dragging = true,
        onTapUp: (e) {
          if (widget.updateFinished != null) widget.updateFinished!(value);
        },
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                top: 0,
                child: Row(
                  children: List.generate(widget.fill.length, (index) {
                    Color c = widget.fill.colors[index];
                    HSVColor hsv = HSVColor.fromColor(c);

                    double start = partBoundings[index];
                    double end = partBoundings[index + 1];
                    int flex = ((end - start) * 100).round();

                    return Expanded(
                      flex: flex,
                      child: AnimatedContainer(
                          duration: duration,
                          height: 10,
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: c.withOpacity(value), blurRadius: 100),
                            BoxShadow(
                                color: hsv
                                    .withSaturation(hsv.saturation.clamp(0, .7))
                                    .withValue(1)
                                    .toColor()
                                    .withOpacity(.5 * value),
                                blurRadius: 70),
                            BoxShadow(
                                color: hsv
                                    .withSaturation(hsv.saturation.clamp(0, .5))
                                    .withValue(1)
                                    .toColor()
                                    .withOpacity(.3 * value),
                                blurRadius: 30)
                          ])),
                    );
                  }),
                ),
              ),
              // Container(
              //   height: 5,
              //   width: double.infinity,
              //   decoration:
              //       BoxDecoration(color: theme.elevation2.withOpacity(.5)),
              // ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  width: double.infinity,
                  duration: duration,
                  height: dragging ? bounds.maxHeight : 3,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: (bounds.maxWidth) * value,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          gradient: widget.fill.adjustedGradient),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  width: double.infinity,
                  duration: duration,
                  height: dragging ? bounds.maxHeight : 3,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: (bounds.maxWidth) * value,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          gradient: LinearGradient(colors: [
                            Color(0x88000000),
                            Color.lerp(
                                Color(0x88000000), Colors.transparent, value)!
                          ])),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void setValue(double d) {
    setState(() {
      value = d;
    });
  }
}
