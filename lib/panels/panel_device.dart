import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spectrum_home2/controlWidgets/swtch.dart';
import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/dialogs/device_panel_dialog.dart';
import 'package:spectrum_home2/panels/panel_loading.dart';
import 'package:spectrum_home2/panels/panel_not_conneced.dart';
import 'package:spectrum_home2/panels/panel_base.dart';
import 'package:spectrum_home2/controlWidgets/brightnessSlider.dart';
import 'package:spectrum_home2/utils/hero_dialog_route.dart';
import 'package:spectrum_home2/utils/utils.dart';
import '../main.dart' as theme;

class DevicePanel extends StatefulWidget {
  final Device device;
  final bool panelHero;
  final bool base;
  const DevicePanel(
      {required this.device,
      Key? key,
      this.panelHero = false,
      this.base = false})
      : super(key: key);

  @override
  DevicePanelState createState() => DevicePanelState();
}

class DevicePanelState extends State<DevicePanel> {
  GlobalKey _key = GlobalKey();
  GlobalKey<BrightnessSliderState> _sliderKey = GlobalKey();

  late PageController _controller;

  late int _heroState; // 0 = icon; 1 == none; 2 == panel
  late int _heroStateGoal;

  Completer _completer = Completer();

  @override
  void initState() {
    _heroState = widget.panelHero ? 2 : 0;
    _heroStateGoal = widget.panelHero ? 2 : 0;
    _controller =
        PageController(initialPage: widget.device.connectionState.val);
    WidgetsBinding.instance!
        .addTimingsCallback((timeStamp) => _onBuildFinished());
    theme.system.addEvent("device-update-finished", _onUpdateFinished);
    theme.system.addEvent("update-connection", _onConnectionUpdate);
    theme.system.addEvent("update-device-animation", _onDeviceAnimationUpdate);
    super.initState();
  }

  void _onUpdateFinished(Device device) {
    if (widget.device == device && mounted) {
      setState(() {
        if (_sliderKey.currentState != null)
          _sliderKey.currentState!.setValue(widget.device.brightness);
      });
    }
  }

  void _onConnectionUpdate(Device dev) {
    if (dev == widget.device) {
      _controller.animateToPage(dev.connectionState.val,
          duration: Duration(milliseconds: 150), curve: theme.curve);
    }
  }

  void _updateHeroState(bool panel) {
    if (_heroState == 0 && panel) {
      _heroStateGoal = 2;
      setState(() {
        _heroState = 1;
      });
    } else if (_heroState == 2 && !panel) {
      _heroStateGoal = 0;
      setState(() {
        _heroState = 1;
      });
    }
  }

  @override
  void dispose() {
    theme.system.removeEvent(_onUpdateFinished);
    theme.system.removeEvent(_onConnectionUpdate);
    theme.system.removeEvent(_onDeviceAnimationUpdate);
    super.dispose();
  }

  Widget _getSwitch(BuildContext context) {
    return ToggleSwitch(
        state: widget.device.enabled,
        active: Color(0xfffffae8).withOpacity(.5),
        onChange: (b) {
          theme.server.updateState(
              device: widget.device, name: "toggle-state", value: b.toString());
        });
  }

  Widget _getText(BuildContext context) {
    return Text(
      widget.device.name,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: theme.h3,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool small = theme.isSmall(context);

    return _wrapWithHero(
        Container(
          height: small ? 120 : 200,
          width: small ? double.infinity : 200,
          child: Panel(
            key: _key,
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _controller,
              scrollDirection: Axis.vertical,
              children: [
                _getContent(context),
                LoadingPanel(),
                NotConnectedPanel(
                  device: widget.device,
                  onTap: () {
                    widget.device.connectionState =
                        DeviceConnectionState.unknown;
                    theme.system.call("update-connection", widget.device);
                    theme.server.checkConnection(widget.device);
                  },
                )
              ],
            ),
          ),
        ),
        _heroState == 2,
        widget.device);
  }

  Widget _wrapWithHero(Widget child, bool wrap, Object heroID) {
    if (!wrap) return child;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (context.findAncestorWidgetOfExactType<Hero>() != null) {
          print("ERROR: Hero was added twice");
          return child;
        }

        try {
          return Hero(
              tag: heroID,
              child: Material(color: Colors.transparent, child: child));
        } catch (err) {
          print("ERROR: Hero was added twice (2)");
          return child;
        }
      },
    );
  }

  void _onBuildFinished() {
    if (_heroState == 1 && mounted) {
      setState(() {
        _heroState = _heroStateGoal;
      });
      if (!_completer.isCompleted) _completer.complete();
      _completer = new Completer();
    }
  }

  GestureDetector _getContent(BuildContext context) {
    Widget icon = SvgPicture.asset(
      widget.device.iconPath!,
      width: 45,
      height: 45,
      color: Utils.adjustColor(widget.device.fill.avgColor),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.base
          ? () async {
              Navigator.push(context, HeroDialogRoute(builder: (context) {
                return DevicePanelDialog(
                  device: widget.device,
                  startHeight: _key.globalPaintBounds == null
                      ? 0
                      : _key.globalPaintBounds!.top,
                );
              }));
            }
          : null,
      child: LayoutBuilder(builder: (context, box) {
        double clampedWidth = box.maxWidth.clamp(200, 350).toDouble();
        return Align(
          alignment: Alignment.topLeft,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: 25,
                  child: BrightnessSlider(
                    key: _sliderKey,
                    fill: widget.device.fill,
                    startVaule: widget.device.brightness,
                    updateFinished: (d) {
                      theme.server.updateState(
                          device: widget.device,
                          name: "brightness",
                          value: d.toStringAsFixed(2));
                    },
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: clampedWidth.map(200, 350, 35, 0),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(child: _getText(context)),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: _wrapWithHero(
                              Center(
                                child: icon,
                              ),
                              _heroState == 0,
                              widget.device.name + "-icon"),
                        ),
                        Expanded(
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  child: _getText(context),
                                  width: clampedWidth.map(200, 350, 0, 300),
                                ))),
                        Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: _getSwitch(context))),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }),
    );
  }

  void _onDeviceAnimationUpdate(bool b) {
    _updateHeroState(b);
  }
}

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject != null) {
      return renderObject.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}

extension MapDouble on num {
  double map(double inmin, double inmax, double outmin, double outmax) {
    return (this - inmin) * (outmax - outmin) / (inmax - inmin) + outmin;
  }
}
