import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/dataObjects/setting.dart';
import 'package:spectrum_home2/dialogs/bouncy_gesture_detector.dart';
import 'package:spectrum_home2/dialogs/setting_dialog.dart';
import 'package:spectrum_home2/dialogs/simple_color_picker.dart';
import 'package:spectrum_home2/main.dart' as style;
import 'package:spectrum_home2/settings/raw_device_item.dart';
import 'package:spectrum_home2/utils/data/synced_value.dart';
import 'package:spectrum_home2/utils/widgets/add_preset_draggable.dart';
import 'package:spectrum_home2/utils/data/fill_data.dart';
import 'package:spectrum_home2/utils/hero_dialog_route.dart';
import 'package:spectrum_home2/utils/utils.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/utils/widgets/fill_item.dart';

class GradientSettingGui extends StatefulWidget {
  final Setting setting;
  final List<Device> devices;

  const GradientSettingGui(this.setting, this.devices, {Key? key})
      : super(key: key);

  @override
  _GradientSettingGuiState createState() => _GradientSettingGuiState();
}

class _GradientSettingGuiState extends State<GradientSettingGui>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  List<GradientStop> _stops = [];

  SyncedCollectionValue<FillData> gradients = SyncedCollectionValue("gradietns",
      fromStr: Utils.stringToGradient, toStr: (e) => e.formatted);

  Device? selected;

  void _onDeviceSelected(Device device) {
    if (selected == device) return;
    selected = widget.devices.contains(device) ? device : null;
    if (selected != null) {
      _controller.forward();
      setState(() {
        _updateWithFill(selected!.gradient);
      });
    } else {
      _controller.reverse();
    }
  }

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _stops = [
      GradientStop(Colors.white, 0),
      GradientStop(Colors.black, 1),
      GradientStop(Colors.red, .3)
    ];
    theme.system.addEvent("device-selected", _onDeviceSelected);
    super.initState();
  }

  @override
  void dispose() {
    theme.system.removeEvent(_onDeviceSelected);
    super.dispose();
  }

  Offset? dragOffset;

  @override
  Widget build(BuildContext context) {
    _stops.sort((s1, s2) {
      return s1.stop > s2.stop ? 1 : -1;
    });
    return SettingDialog(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "Gradient Editor",
                  style: theme.h3,
                ),
              ),
              _getGradientBar(context),
              SizedBox(
                height: 20,
              ),
              Wrap(
                  children: widget.devices.map((e) {
                return GradientDeviceItem(
                  e,
                  dragCallback: (fill) {
                    setState(() {
                      _updateWithFill(fill, true);
                    });
                  },
                );
              }).toList()),
              SizedBox(
                height: 20,
              ),
              Wrap(
                  children: gradients.converted
                      .map((fill) => Container(
                              child: FillItem(
                            fill: fill,
                            onTap: (fill) {
                              setState(() {
                                if (selected != null)
                                  _updateWithFill(fill, true);
                              });
                            },
                          )))
                      .toList()
                    ..add(Container(
                        child: AddPresetDraggable<FillData>(
                      onUpdate: (g) {
                        setState(() {
                          List<FillData> converted = gradients.converted;
                          if (!converted.contains(g))
                            gradients.setConverted(converted..add(g));
                        });
                        return;
                      },
                      onDelete: (e1) {
                        setState(() {
                          gradients.setConverted(gradients.converted
                            ..removeWhere((e2) => e2 == e1));
                        });
                      },
                    )))),
            ],
          ),
        ),
        setting: widget.setting);
  }

  void _gradientUpdateFinished() {
    FillData data = FillData(_stops.map((e) => e.color).toList(),
        _stops.map((e) => e.stop).toList());
    if (selected != null)
      theme.server.updateState(
          device: selected!,
          name: "display",
          type: "gradient",
          value: data.formatted);
  }

  void _updateWithFill(FillData fill, [bool upload = false]) {
    _stops = List.generate(fill.length,
        (index) => GradientStop(fill.colors[index], fill.stops[index]));
    if (upload) {
      _gradientUpdateFinished();
    }
  }

  void _createStop(double posX, double width) {
    setState(() {
      double newStop = posX / width;

      Color? color;

      for (int i = 0; i < _stops.length; i++) {
        GradientStop stop = _stops[i];
        if (stop.stop >= newStop) {
          if (i > 0) {
            GradientStop first = _stops[i - 1];
            color = Color.lerp(first.color, stop.color,
                Utils.map(first.stop, stop.stop, 0, 1, newStop));
          } else {
            color = stop.color;
          }
          break;
        }
      }
      if (color == null) {
        color = _stops.last.color;
      }
      _stops.add(GradientStop(color, newStop));
    });
  }

  Widget _getGradientBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      clipBehavior: Clip.antiAlias,
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, -2), end: Offset.zero)
            .animate(CurvedAnimation(parent: _controller, curve: theme.curve)),
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth;
                  return GestureDetector(
                    onTap: () {},
                    onLongPressStart: (e) {
                      _createStop(e.localPosition.dx, width);
                    },
                    onSecondaryTapDown: (e) {
                      _createStop(e.localPosition.dx, width);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 100),
                      width: double.infinity,
                      height: 70,
                      decoration: BoxDecoration(
                          borderRadius: style.borderRadius,
                          boxShadow: theme.elevation1shadow,
                          gradient: LinearGradient(
                              colors: _stops.map((e) => e.color).toList(),
                              stops: _stops.map((e) => e.stop).toList())),
                    ),
                  );
                },
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;
                return Container(
                  height: 40,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: _stops
                        .map((stop) => Positioned(
                              key: ValueKey(stop),
                              left: (width - 80) * stop.stop + 20,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(context, HeroDialogRoute(
                                    builder: (context) {
                                      return SimpleColorPickerPopup(
                                        start: stop.color,
                                        onUpdate: (c) {},
                                        onUpdateFinished: (c) {
                                          setState(() {
                                            stop.color = c;
                                            _gradientUpdateFinished();
                                          });
                                        },
                                      );
                                    },
                                  ));
                                },
                                onHorizontalDragUpdate: (e) => {
                                  setState(() {
                                    stop.stop += e.delta.dx / (width - 80);
                                    stop.stop =
                                        stop.stop.clamp(0, 1).toDouble();
                                  })
                                },
                                onHorizontalDragEnd: (e) =>
                                    _gradientUpdateFinished(),
                                onLongPressStart: (e) {
                                  if (_stops.length > 2)
                                    setState(() {
                                      _stops.remove(stop);
                                      _gradientUpdateFinished();
                                    });
                                },
                                onSecondaryTapDown: (e) {
                                  if (_stops.length > 2)
                                    setState(() {
                                      _stops.remove(stop);
                                      _gradientUpdateFinished();
                                    });
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: stop.color,
                                      boxShadow: style.elevation1shadow,
                                      borderRadius: style.borderRadius),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class GradientDeviceItem extends StatefulWidget {
  final Device device;
  final void Function(FillData color)? dragCallback;

  const GradientDeviceItem(this.device, {Key? key, this.dragCallback})
      : super(key: key);

  @override
  _GradientDeviceItemState createState() => _GradientDeviceItemState();
}

class _GradientDeviceItemState extends State<GradientDeviceItem> {
  void _updateFill(FillData data) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Device d = widget.device;

    return BouncyGestureDetector(
      onTap: () {
        theme.system.call("device-selected", d);
      },
      child: RawDeviceItem<FillData>(
        device: d,
        onValueRequest: () => d.gradient,
        onValueUpdate: (e) {
          _updateFill(e);
          if (widget.dragCallback != null) widget.dragCallback!(e);
        },
        child: Container(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.all(5),
          width: 50,
          height: 50,
          child: Center(
              child: ShaderMask(
            shaderCallback: (b) =>
                widget.device.gradient.adjustedGradient.createShader(b),
            child: SvgPicture.asset(
              "assets/images/icons/${d.icon}.svg",
              width: 30,
              height: 30,
              color: Colors.white,
            ),
          )),
          decoration: BoxDecoration(
              color: theme.elevation2,
              boxShadow: theme.elevation1shadow,
              borderRadius:
                  theme.borderRadius - BorderRadius.all(Radius.circular(5))),
        ),
      ),
    );
  }
}

class GradientStop {
  Color color;
  double stop;

  GradientStop(this.color, this.stop);
}
