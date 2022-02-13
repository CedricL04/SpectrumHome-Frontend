import 'package:flutter/material.dart';
import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/dataObjects/room.dart';
import 'package:spectrum_home2/dialogs/name_dialog.dart';
import 'package:spectrum_home2/dialogs/pie_menu.dart';
import 'package:spectrum_home2/panels/panel_base.dart';
import 'package:spectrum_home2/utils/data/fill_data.dart';
import 'package:spectrum_home2/utils/hero_dialog_route.dart';
import 'package:spectrum_home2/utils/utils.dart';
import 'package:spectrum_home2/main.dart' as theme;

class ScenePanel extends StatelessWidget {
  const ScenePanel(
      {required this.fill,
      required this.sceneName,
      required this.room,
      Key? key})
      : super(key: key);

  final FillData fill;
  final Room room;
  final String sceneName;

  @override
  Widget build(BuildContext context) {
    List<Color> colors = fill.colors;
    return PieMenuWrapper(
      entries: [
        PieMenuEntry("Apply", Icon(Icons.check), () async {
          Map json = await theme.server.sendRequest({
            "type": "scene",
            "action": "apply",
            "values": {"name": sceneName, "room": room.name}
          });
          for (String devID in json.keys) {
            Device? device = theme.server.getDevice(devID);
            if (device != null) {
              device.updateStateJson(json[devID]["states"]);
            }
          }
          theme.system.call("device-update-all");
          theme.system.call("request-update", "current-scene${room.name}");
        }),
        PieMenuEntry("Edit", Icon(Icons.edit_outlined), () {
          Navigator.push(
              context,
              HeroDialogRoute(
                  builder: (context) => NameDialog(
                        child:
                            Padding(padding: EdgeInsets.all(30), child: this),
                        validator: (s) async {
                          Map body = await theme.server.sendRequest({
                            "type": "scene",
                            "action": "rename",
                            "values": {
                              "name": sceneName,
                              "new-name": s,
                              "room": room.name
                            }
                          });

                          if (body.containsKey("error")) return body["error"];

                          theme.system.call("request-update",
                              "scene:${room.name}${theme.server.user}");

                          return null;
                        },
                        text: sceneName,
                      )));
        }),
        PieMenuEntry("Delete", Icon(Icons.delete_outline), () async {
          await theme.server.sendRequest({
            "type": "scene",
            "action": "remove",
            "values": {"name": sceneName, "room": room.name}
          });
          theme.system
              .call("request-update", "scene:${room.name}${theme.server.user}");
        }),
        for (int i = 1; i < 4; i++)
          PieMenuEntry(
              "Mood $i",
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gradient_outlined),
                  Text(
                    "$i",
                    style: theme.h3,
                  )
                ],
              ),
              () {})
      ],
      name: sceneName,
      child: Hero(
        tag: "scene-hero:$sceneName",
        child: Panel(
            smallPanel: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: LayoutBuilder(builder: (context, c) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        children: List.generate(colors.length, (index) {
                          Color c = colors[index];
                          return Expanded(
                            child: Container(
                                height: 10,
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(color: c, blurRadius: 50),
                                ])),
                          );
                        }),
                      ),
                    ),
                    Center(
                      child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: colors))),
                    ),
                    ...List.generate(
                        colors.length,
                        (i) => Positioned(
                              left: Utils.map(0, 1, 0, c.maxWidth,
                                      i / (colors.length - 1)) -
                                  2,
                              top: c.maxHeight / 2 - 2,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: colors[i]),
                              ),
                            ))
                  ],
                );
              }),
            )),
      ),
    );
  }
}
