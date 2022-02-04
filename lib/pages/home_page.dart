import 'package:flutter/material.dart';
import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/dataObjects/room.dart';
import 'package:spectrum_home2/panels/panel_device.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/panels/panel_scene.dart';
import 'package:spectrum_home2/settings/settings_button.dart';
import 'package:spectrum_home2/utils/data/fill_data.dart';
import 'package:spectrum_home2/utils/utils.dart';
import 'package:spectrum_home2/utils/widgets/panel_layout.dart';
import 'package:spectrum_home2/utils/widgets/request_handler.dart';

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
            "Snapshots": RequestHandler(
              builder: (context, data) {
                if (data.isEmpty) {
                  return Container();
                }

                List<Widget> widgets = (data["scenes"] as List).map((scene) {
                  FillData fill = FillData((scene["colors"] as List)
                      .map((s) => Utils.stringToColor(s))
                      .toList());

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ScenePanel(fill: fill, sceneName: scene["name"],),
                  );
                }).toList();

                return Wrap(children: widgets);
              },
              id: "scene:${widget.room.name}${theme.server.user}",
              request: {
                "type": "scene",
                "action": "get",
                "values": {"room": widget.room.name, "simple": true}
              },
            )
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
