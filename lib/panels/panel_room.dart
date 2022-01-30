import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spectrum_home2/controlWidgets/swtch.dart';
import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/dataObjects/room.dart';
import 'package:spectrum_home2/navigation_base.dart';
import 'package:spectrum_home2/pages/home_page.dart';
import 'package:spectrum_home2/pages/scene_page.dart';
import 'package:spectrum_home2/panels/panel_base.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/controlWidgets/brightnessSlider.dart';
import 'package:spectrum_home2/utils/data/fill_data.dart';
import 'package:spectrum_home2/utils/hero_dialog_route.dart';
import 'package:spectrum_home2/utils/utils.dart';

class RoomPanel extends StatefulWidget {
  final Room room;

  const RoomPanel({required this.room, Key? key}) : super(key: key);

  @override
  _RoomPanelState createState() => _RoomPanelState();
}

class _RoomPanelState extends State<RoomPanel> {
  void _onDeviceColorUpdateFinished(Device device) {
    if (widget.room.devices.contains(device) && mounted) {
      setState(() {
        _sortDeviceList();
      });
    }
  }

  void _sortDeviceList() {
    widget.room.devices.sort((c1, c2) {
      double hue1 = HSVColor.fromColor(c1.fill.avgColor).hue;
      double hue2 = HSVColor.fromColor(c2.fill.avgColor).hue;
      if (hue1 > hue2) return 1;
      if (hue2 > hue1) return -1;
      return 0;
    });
  }

  @override
  void initState() {
    theme.system
        .addEvent("device-update-finished", _onDeviceColorUpdateFinished);
    _sortDeviceList();
    super.initState();
  }

  @override
  void dispose() {
    theme.system.removeEvent(_onDeviceColorUpdateFinished);
    super.dispose();
  }

  GlobalKey<BrightnessSliderState> _sliderKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    bool small = theme.isSmall(context);

    Widget heading = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.room.name,
          style: TextStyle(
            color: theme.foregroundColor,
            fontSize: 18,
          ),
        ),
        Text(
          "${widget.room.devices.length} Device${widget.room.devices.length > 1 ? "s" : ""}",
          style: TextStyle(
              color: theme.foregroundColor,
              fontSize: 14,
              fontWeight: FontWeight.w300),
        )
      ],
    );

    //Color roomColor = Color.lerp(theme.backgroundColor, Colors.white, .5);
    FillData gradient = widget.room.avgFill;

    return GestureDetector(
      onTap: () => Navigator.push(
              context,
              HeroDialogRoute(
                  millis: 700,
                  builder: (context) {
                    return NavigationBase(
                      pages: [
                        NavigationEntry("Devices", Icons.devices_other_outlined,
                            HomePage(small, widget.room)),
                        NavigationEntry(
                            "Snapshots",
                            Icons.chair_outlined,
                            ScenePage(
                              room: widget.room,
                            )),
                        NavigationEntry(
                            "Statistics", Icons.graphic_eq, Container())
                      ],
                      popButton: true,
                    );
                  },
                  transparent: false))
          .then((value) {
        if (_sliderKey.currentState != null)
          _sliderKey.currentState!.setValue(widget.room.avgOpcaity);
      }),
      child: Panel(
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 20,
                child: BrightnessSlider(
                    key: _sliderKey,
                    startVaule: widget.room.avgOpcaity,
                    updateFinished: (val) => {
                          for (Device d in widget.room.devices)
                            theme.server.updateState(
                                device: d, name: "brightness", value: "$val")
                        },
                    fill: gradient),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                small
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              heading,
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: _getIcons(small),
                                  ),
                                ),
                              ),
                              _getSwitch()
                            ],
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 20, left: 20),
                        child: Row(
                          children: [
                            heading,
                            Expanded(
                              child: Center(child: _getSwitch()),
                            )
                          ],
                        ),
                      ),
                if (!small)
                  Expanded(
                    child: Row(
                        children: _getIcons(small)
                            .map((e) => Expanded(
                                  child: Center(
                                    child: e,
                                  ),
                                ))
                            .toList()),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ToggleSwitch _getSwitch() {
    return ToggleSwitch(
        state: widget.room.toggleState,
        active: theme.foregroundColor.withOpacity(.5),
        onChange: (b) {
          for (Device d in widget.room.devices) {
            if (d.enabled != b)
              theme.server
                  .updateState(device: d, name: "toggle-state", value: "$b");
          }
        });
  }

  List<Widget> _getIcons(bool small) {
    return List.generate(widget.room.devices.length, (index) {
      Device device = widget.room.devices[index];
      Color color = device.fill.avgColor;
      bool toggled = device.enabled;
      Widget icon = Hero(
          tag: device.name + "-icon",
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(boxShadow: [
                    if (toggled)
                      BoxShadow(
                        color: color,
                        blurRadius: 50,
                      ),
                    if (toggled)
                      BoxShadow(
                        color: color,
                        blurRadius: 35,
                      )
                  ]),
                ),
              ),
              Center(
                child: SvgPicture.asset(
                  "assets/images/icons/${device.icon}.svg",
                  width: 35,
                  color: Utils.adjustColor(color),
                ),
              ),
            ],
          ));
      if (small)
        return Padding(
          padding: const EdgeInsets.only(left: 10),
          child: icon,
        );
      return icon;
    });
  }
}
