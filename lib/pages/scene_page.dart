import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/dataObjects/room.dart';
import 'package:spectrum_home2/dialogs/name_dialog.dart';
import 'package:spectrum_home2/panels/panel_scene.dart';
import 'package:spectrum_home2/utils/data/fill_data.dart';
import 'package:spectrum_home2/utils/hero_dialog_route.dart';
import 'package:spectrum_home2/utils/utils.dart';
import 'package:spectrum_home2/utils/widgets/panel_layout.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/utils/widgets/request_handler.dart';

class ScenePage extends StatefulWidget {
  final Room room;

  const ScenePage({required this.room, Key? key}) : super(key: key);

  @override
  _ScenePageState createState() => _ScenePageState();

  static Widget getSceneWrap(BuildContext context, Room room) {
    return RequestHandler(
      builder: (context, data) {
        if (data.isEmpty) {
          return Container();
        }

        List<Widget> widgets = [];
        if (data.containsKey("scenes"))
          widgets = (data["scenes"] as List).map((scene) {
            FillData fill = FillData((scene["colors"] as List)
                .map((s) => Utils.stringToColor(s))
                .toList());

            return RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ScenePanel(
                    fill: fill, sceneName: scene["name"], room: room),
              ),
            );
          }).toList();
        if (widgets.isEmpty)
          return Container(
            width: double.infinity,
            height: 100,
            child: Center(
              child: Text("<No Snapshots found>", style: theme.h4),
            ),
          );
        return Wrap(children: widgets);
      },
      id: "scene:${room.name}${theme.server.user}",
      request: {
        "type": "scene",
        "action": "get",
        "values": {"room": room.name, "simple": true}
      },
    );
  }
}

class _ScenePageState extends State<ScenePage> {
  void initState() {
    theme.system.addEvent("device-update-all", _onDeviceUpdateAll);
    super.initState();
  }

  @override
  void dispose() {
    theme.system.removeEvent(_onDeviceUpdateAll);
    super.dispose();
  }

  void _onDeviceUpdateAll() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.push(
                context,
                HeroDialogRoute(
                  builder: (context) => NameDialog(
                      validator: (s) async {
                        Map body = await theme.server.sendRequest({
                          "type": "scene",
                          "action": "add",
                          "values": {"name": s, "room": widget.room.name}
                        });
                        if (body.containsKey("error")) return body["error"];
                        theme.system.call("request-update",
                            "scene:${widget.room.name}${theme.server.user}");
                        return null;
                      },
                      child: Hero(
                        tag: "current-scene-display",
                        child: CurrentSceneDisplay(
                          room: widget.room,
                          forceReload: false,
                        ),
                      )),
                )),
            child: Hero(
              tag: "current-scene-display",
              child: CurrentSceneDisplay(
                room: widget.room,
              ),
            ),
          ),
          Expanded(
            child: PanelLayout(data: {
              "Snapshots": ScenePage.getSceneWrap(context, widget.room)
            }),
          ),
        ],
      ),
    );
  }
}

class CurrentSceneDisplay extends StatelessWidget {
  const CurrentSceneDisplay({
    Key? key,
    required this.room,
    this.height = 150,
    this.iconSize = 30,
    this.iconPadding = 20,
    this.forceReload = true,
  }) : super(key: key);

  final Room room;
  final double height;
  final double iconSize;
  final double iconPadding;
  final bool forceReload;

  @override
  Widget build(BuildContext context) {
    return RequestHandler(
      id: "current-scene${room.name}",
      forceReload: forceReload,
      request: {
        "type": "scene",
        "action": "get-current",
        "values": {"room": room.name}
      },
      builder: (context, data) {
        if (data.isEmpty) return Container();
        List<Device> devs = [...room.devices];
        return Container(
          height: height,
          constraints: BoxConstraints(maxWidth: 600),
          child: LayoutBuilder(builder: (context, c) {
            return Stack(
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    width: double.infinity,
                    height: 1,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: devs
                                .map((e) => Utils.stringToColor(data[e.id]))
                                .toList())),
                  ),
                ),
                ...List.generate(devs.length, (index) {
                  Device dev = devs[index];
                  Color avg = Utils.stringToColor(data[dev.id]);
                  return Positioned(
                    top: (height - iconSize) / 2,
                    left: index /
                            (devs.length - 1) *
                            (c.maxWidth - iconSize - iconPadding * 2) +
                        iconPadding,
                    child: Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                          color: theme.backgroundColor,
                          border: Border.all(color: avg),
                          shape: BoxShape.circle),
                      child: Center(
                        child: SvgPicture.asset(
                          dev.iconPath!,
                          width: iconSize - 10,
                          height: iconSize - 10,
                          color: avg,
                        ),
                      ),
                    ),
                  );
                })
              ],
            );
          }),
        );
      },
    );
  }
}
