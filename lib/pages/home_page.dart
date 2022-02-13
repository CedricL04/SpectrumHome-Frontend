import 'package:flutter/material.dart';
import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/dataObjects/room.dart';
import 'package:spectrum_home2/pages/scene_page.dart';
import 'package:spectrum_home2/panels/panel_device.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/settings/settings_button.dart';
import 'package:spectrum_home2/utils/widgets/panel_layout.dart';

class HomePage extends StatefulWidget {
  final bool small;
  final Room room;
  final bool init;
  const HomePage(this.init, this.small, this.room, {Key? key})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    theme.system.addEvent("device-update-all", _onDeviceUpdateAll);
    theme.system.addEvent("update-scenes", _onDeviceUpdateAll);
    super.initState();
    Future.delayed(Duration(milliseconds: 1000)).then((value) {
      if (mounted) setState(() => _updateAnimating(true));
    });
  }

  @override
  void dispose() {
    theme.system.removeEvent(_onDeviceUpdateAll);
    super.dispose();
  }

  void _updateAnimating(bool animating) {
    theme.system.call("update-device-animation", animating);
  }

  void _onDeviceUpdateAll() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Device> devs = widget.room.devices;
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress) return false;
        setState(() {
          _updateAnimating(false);
        });
        return true;
      },
      child: Stack(
        children: [
          PanelLayout(data: {
            "Lamps": List.generate(
                widget.room.devices.length,
                (index) => DevicePanel(
                      device: devs[index],
                      key: ValueKey(devs[index].id),
                      base: true,
                      panelHero: !widget.init,
                    )),
            "Snapshots": ScenePage.getSceneWrap(context, widget.room)
          }),
          Positioned(
            child: Column(
              children: theme.settings
                  .map((e) => SettingsButton(
                        setting: e,
                        devices: widget.room.devices,
                      ))
                  .toList(),
            ),
            bottom: 10,
            right: 10,
          )
        ],
      ),
    );
  }
}
