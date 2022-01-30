import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/dataObjects/setting.dart';
import 'package:spectrum_home2/dialogs/setting_dialog.dart';
import 'package:spectrum_home2/settings/raw_device_item.dart';
import 'package:spectrum_home2/utils/data/fill_data.dart';
import 'package:spectrum_home2/utils/widgets/add_preset_draggable.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/utils/data/synced_value.dart';
import 'dart:math' as math;

import 'package:spectrum_home2/utils/utils.dart';
import 'package:spectrum_home2/utils/widgets/fill_item.dart';

class ColorSettingGui extends StatefulWidget {
  final Setting setting;
  final List<Device> devices;

  const ColorSettingGui(this.setting, this.devices, {Key? key})
      : super(key: key);

  @override
  _ColorSettingGuiState createState() => _ColorSettingGuiState();
}

class _ColorSettingGuiState extends State<ColorSettingGui>
    with SingleTickerProviderStateMixin {
  SyncedCollectionValue<FillData> colors = SyncedCollectionValue("colors",
      fromStr: (s) => FillData([Utils.stringToColor(s)]),
      toStr: (fill) => Utils.colorToString(fill.first));

  static final double _itemSize = 30;
  static final Offset _itemSizeOffset = Offset(_itemSize, _itemSize);

  static final double _padding = 20;
  static final Offset _paddingOffset = Offset(_padding, _padding);

  Map<Device?, _OffsetKeyContainer?> items = {};

  Device? selected;
  double rad = 1;

  Offset dragOffset = _itemSizeOffset / 2;

  @override
  void initState() {
    for (Device d in widget.devices) {
      _updateWithColor(d);
    }
    theme.system.addEvent("device-selected", _onDeviceSelected);
    super.initState();
  }

  @override
  void dispose() {
    theme.system.removeEvent(_onDeviceSelected);
    super.dispose();
  }

  void _onDeviceSelected(Device dev) {
    if (items.containsKey(dev)) selected = dev;
  }

  void _updateWithGridCoords(Offset coords) {
    setState(() {
      Offset radCoords = _gridToRadial(coords.dx - rad, coords.dy - rad, rad);
      items[selected]!.offset =
          _radialToGrid(radCoords.dx, radCoords.dy.clamp(0, 1).toDouble());
      _updateDeviceItem(selected!, _getColor(selected));
    });
  }

  void _updateWithColor(Device dev, [Color? color]) {
    color ??= dev.color;
    HSVColor hsv = HSVColor.fromColor(color);
    Offset of = _radialToGrid(hsv.hue, hsv.saturation);
    items[dev] = _OffsetKeyContainer(
        of, items[dev] == null ? GlobalKey() : items[dev]!.key);
    _updateDeviceItem(dev, color);
  }

  void _updateDeviceItem(Device dev, [Color? color]) {
    color ??= dev.color;
    GlobalKey<_ColorDeviceItemState> key = items[dev]!.key;
    if (key.currentState != null) {
      key.currentState!._updateFill(FillData([color]));
    }
    ;
  }

  Color _getColor(Device? device) {
    Offset off = items[device]!.offset;
    Offset rad = _gridToRadial(off.dx, off.dy, 1);

    return HSVColor.fromAHSV(1, rad.dx % 360, rad.dy, 1).toColor();
  }

  void _updateColorState() {
    if (selected == null) return;
    theme.server.updateState(
        device: selected!,
        name: "display",
        type: "color",
        value: Utils.colorToString(_getColor(selected)));
  }

  Device? _checkActive(Offset pos) {
    for (int i = items.length - 1; i >= 0; i--) {
      MapEntry<Device?, _OffsetKeyContainer?> entry = items.entries.toList()[i];
      Device? dev = entry.key;

      double toAdd = rad + _itemSize;

      Offset off = entry.value!.offset * rad + Offset(toAdd, toAdd);
      Offset dif = off - pos;
      if (dif < _itemSizeOffset * 2 && dif > Offset.zero) {
        if (dev != selected) {
          theme.system.call("device-selected", dev);
          return dev;
        }
        break;
      }
    }
    return null;
  }

  Widget _getWheel(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onPanStart: (e) => _checkActive(e.localPosition - _paddingOffset),
        onTapUp: (e) {
          if (_checkActive(e.localPosition - _paddingOffset) == null &&
              selected != null) {
            _updateWithGridCoords(e.localPosition - _paddingOffset);
            _updateColorState();
          }
        },
        onPanUpdate: (e) {
          if (selected != null) {
            _updateWithGridCoords(e.localPosition - _paddingOffset);
          }
        },
        onPanCancel: () => _updateColorState(),
        onPanEnd: (e) => _updateColorState(),
        child: Container(
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Color(0x01000000)),
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
                boxShadow: theme.elevation1shadow,
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: AssetImage("assets/images/colorwheel.png"))),
            child: LayoutBuilder(
              builder: (context, constraints) {
                rad = constraints.maxWidth / 2;
                double itemRad = _itemSize / 2;

                return Stack(
                    clipBehavior: Clip.none,
                    children: List.generate(items.length, (index) {
                      MapEntry<Device?, _OffsetKeyContainer?> entry =
                          items.entries.toList()[index];
                      Device? dev = entry.key;
                      Offset off = entry.value!.offset;

                      return Positioned(
                        left: off.dx * rad + rad - itemRad,
                        top: off.dy * rad + rad - itemRad,
                        child: ColorDeviceItem(
                          device: dev,
                          key: entry.value!.key,
                          dragCallback: (c) {
                            setState(() {
                              _updateWithColor(dev!, c.first);
                              _updateColorState();
                            });
                          },
                        ),
                      );
                    }));
              },
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

  @override
  Widget build(BuildContext context) {
    // if (selected != null) {                is this code useless? we never know
    //   _OffsetKeyContainer? buffer = items[selected];
    //   items.remove(selected);
    //   items[selected] = buffer;
    // }

    return SettingDialog(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: _getWheel(context),
              ),
              Wrap(
                children: colors.converted
                    .map<Widget>((e) => FillItem(
                          fill: e,
                          onTap: (fill) {
                            if (selected != null) {
                              setState(() {
                                _updateWithColor(selected!, fill.first);
                                _updateColorState();
                              });
                            }
                          },
                        ))
                    .toList()
                  ..add(AddPresetDraggable<FillData>(
                    onUpdate: (c) {
                      setState(() {
                        List<FillData> converted = colors.converted;
                        if (!converted.contains(c))
                          colors.setConverted(colors.converted..add(c));
                      });
                      return;
                    },
                    onDelete: (e1) {
                      setState(() {
                        colors.setConverted(
                            colors.converted..removeWhere((e2) => e2 == e1));
                      });
                    },
                  )),
              )
            ],
          ),
        ),
        setting: widget.setting);
  }
}

class _OffsetKeyContainer {
  GlobalKey<_ColorDeviceItemState> key;
  Offset offset;
  _OffsetKeyContainer(this.offset, this.key);
}

class ColorDeviceItem extends StatefulWidget {
  final Device? device;
  final void Function(FillData color)? dragCallback;

  const ColorDeviceItem({required this.device, Key? key, this.dragCallback})
      : super(key: key);

  @override
  _ColorDeviceItemState createState() => _ColorDeviceItemState();
}

class _ColorDeviceItemState extends State<ColorDeviceItem>
    with SingleTickerProviderStateMixin {
  HSVColor? color;

  @override
  void initState() {
    color = HSVColor.fromColor(widget.device!.color);
    FillData deviceColor = widget.device!.fill;
    _fill = deviceColor;
    super.initState();
  }

  late FillData _fill;

  void _updateFill(FillData color) {
    setState(() {
      _fill = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    double luminance = widget.device!.color.computeLuminance();
    return RawDeviceItem<FillData>(
      device: widget.device,
      onValueRequest: () => widget.device!.fill,
      onValueUpdate: (fill) {
        _updateFill(fill);
        if (widget.dragCallback != null) widget.dragCallback!(fill);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: 30,
        height: 30,
        decoration: _fill.createDecoration(
            borderRadius: BorderRadius.circular(200),
            shadow: theme.elevation1shadow,
            border: Border.all(
              color: luminance < .6 ? theme.foregroundColor : theme.elevation1,
              width: 2,
            )),
        child: Center(
          child: SvgPicture.asset(
            "assets/images/icons/${widget.device!.icon}.svg",
            width: 20,
            height: 20,
            color: luminance < .6 ? theme.foregroundColor : theme.elevation1,
          ),
        ),
      ),
    );
  }
}
