import 'package:flutter/material.dart';
import 'package:spectrum_home2/dataObjects/room.dart';
import 'package:spectrum_home2/panels/panel_device.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/panels/panel_scene.dart';
import 'package:spectrum_home2/settings/settings_button.dart';
import 'package:spectrum_home2/utils/widgets/panel_layout.dart';

class HomePage extends StatefulWidget {
  final bool small;
  final Room room;
  const HomePage(this.small, this.room, {Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    for (int i = 0; i < widget.room.devices.length; i++) {
      _keys.add(GlobalKey());
    }
    super.initState();
    Future.delayed(Duration(milliseconds: 1000)).then((value) {
      if (mounted) setState(() => _updateAnimating(true));
    });
  }

  void _updateAnimating(bool animating) {
    for (GlobalKey<DevicePanelState> key in _keys) {
      if (key.currentState != null)
        key.currentState!.updatePanelHero(animating);
    }
  }

  List<GlobalKey<DevicePanelState>> _keys = [];

  @override
  Widget build(BuildContext context) {
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
                      device: widget.room.devices[index],
                      key: _keys[index],
                      base: true,
                      panelHero: false,
                    )),
            "Snapshots": List.generate(10, (index) => ScenePanel())
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
